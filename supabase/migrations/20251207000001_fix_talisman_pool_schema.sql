-- 누락된 talisman 스키마 수정 마이그레이션
-- 원인: 20251128000012 마이그레이션이 기록만 되고 실제 적용되지 않음

-- ============================================
-- 1. talisman_images 테이블 컬럼 추가
-- ============================================

ALTER TABLE talisman_images
  ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS quality_score INTEGER DEFAULT 80,
  ADD COLUMN IF NOT EXISTS usage_count INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_used_at TIMESTAMP WITH TIME ZONE;

-- 공용 풀 조회용 인덱스
CREATE INDEX IF NOT EXISTS idx_talisman_images_public_pool
  ON talisman_images(category, is_public)
  WHERE is_public = true;

-- 사용 횟수 기반 정렬용 인덱스
CREATE INDEX IF NOT EXISTS idx_talisman_images_usage
  ON talisman_images(category, usage_count DESC)
  WHERE is_public = true;

-- ============================================
-- 2. talisman_user_cache 테이블 생성
-- ============================================

CREATE TABLE IF NOT EXISTS talisman_user_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  category TEXT NOT NULL,
  image_id UUID REFERENCES talisman_images(id) ON DELETE CASCADE NOT NULL,
  cache_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, category, cache_date),

  CONSTRAINT valid_cache_category CHECK (category IN (
    'disease_prevention', 'love_relationship', 'wealth_career',
    'disaster_removal', 'home_protection', 'academic_success', 'health_longevity'
  ))
);

-- 캐시 조회 최적화 인덱스
CREATE INDEX IF NOT EXISTS idx_talisman_user_cache_lookup
  ON talisman_user_cache(user_id, category, cache_date);

CREATE INDEX IF NOT EXISTS idx_talisman_user_cache_date
  ON talisman_user_cache(cache_date);

-- ============================================
-- 3. talisman_pool_settings 테이블 생성
-- ============================================

CREATE TABLE IF NOT EXISTS talisman_pool_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category TEXT UNIQUE NOT NULL,
  target_pool_size INTEGER DEFAULT 100,
  max_pool_size INTEGER DEFAULT 500,
  random_selection_probability DECIMAL(3,2) DEFAULT 0.30,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CONSTRAINT valid_talisman_category CHECK (category IN (
    'disease_prevention', 'love_relationship', 'wealth_career',
    'disaster_removal', 'home_protection', 'academic_success', 'health_longevity'
  ))
);

-- 기본값 삽입
INSERT INTO talisman_pool_settings (category) VALUES
  ('disease_prevention'),
  ('love_relationship'),
  ('wealth_career'),
  ('disaster_removal'),
  ('home_protection'),
  ('academic_success'),
  ('health_longevity')
ON CONFLICT (category) DO NOTHING;

-- ============================================
-- 4. RLS 정책
-- ============================================

-- talisman_pool_settings RLS
ALTER TABLE talisman_pool_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view pool settings" ON talisman_pool_settings;
CREATE POLICY "Anyone can view pool settings"
  ON talisman_pool_settings FOR SELECT
  USING (true);

-- talisman_user_cache RLS
ALTER TABLE talisman_user_cache ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own cache" ON talisman_user_cache;
CREATE POLICY "Users can view own cache"
  ON talisman_user_cache FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own cache" ON talisman_user_cache;
CREATE POLICY "Users can insert own cache"
  ON talisman_user_cache FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- talisman_images 공용 풀 정책 업데이트
DROP POLICY IF EXISTS "Users can view public or own talisman images" ON talisman_images;
CREATE POLICY "Users can view public or own talisman images"
  ON talisman_images FOR SELECT
  USING (is_public = true OR auth.uid() = user_id);

-- ============================================
-- 5. 헬퍼 함수
-- ============================================

CREATE OR REPLACE FUNCTION increment_talisman_usage(p_image_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE talisman_images
  SET
    usage_count = usage_count + 1,
    last_used_at = NOW()
  WHERE id = p_image_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_talisman_pool_size(p_category TEXT)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER
  FROM talisman_images
  WHERE category = p_category
  AND is_public = true;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION get_random_talisman_from_pool(p_category TEXT)
RETURNS TABLE (
  id UUID,
  image_url TEXT,
  characters TEXT[],
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
  SELECT
    id,
    image_url,
    characters,
    created_at
  FROM talisman_images
  WHERE category = p_category
  AND is_public = true
  ORDER BY RANDOM()
  LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- 코멘트
COMMENT ON COLUMN talisman_images.is_public IS '공용 풀 포함 여부';
COMMENT ON COLUMN talisman_images.usage_count IS '재사용 횟수';
COMMENT ON TABLE talisman_user_cache IS '부적 개인 캐시 (하루 1회 제한)';
COMMENT ON TABLE talisman_pool_settings IS '부적 이미지 풀 설정';
