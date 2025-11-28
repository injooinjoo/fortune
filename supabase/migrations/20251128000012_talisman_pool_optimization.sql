-- 부적 이미지 풀 최적화 마이그레이션
-- 목적: UnifiedFortuneService 패턴을 부적 시스템에 적용하여 API 비용 70-80% 절감

-- ============================================
-- 1. talisman_images 테이블 확장 (공용 풀 지원)
-- ============================================

-- 공용 풀 관련 컬럼 추가
ALTER TABLE talisman_images
  ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS quality_score INTEGER DEFAULT 80,
  ADD COLUMN IF NOT EXISTS usage_count INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_used_at TIMESTAMP WITH TIME ZONE;

-- 모델 버전 컬럼 업데이트 (기존 값 변경)
UPDATE talisman_images
SET model_used = 'dall-e-3'
WHERE model_used = 'gemini-2.0-flash-exp';

-- 기존 이미지는 공용 풀에서 제외 (Gemini 새 이미지만 사용)
UPDATE talisman_images
SET is_public = false
WHERE model_used != 'gemini-2.5-flash-image';

-- 공용 풀 조회용 인덱스
CREATE INDEX IF NOT EXISTS idx_talisman_images_public_pool
  ON talisman_images(category, is_public)
  WHERE is_public = true;

-- 사용 횟수 기반 정렬용 인덱스
CREATE INDEX IF NOT EXISTS idx_talisman_images_usage
  ON talisman_images(category, usage_count DESC)
  WHERE is_public = true;

-- ============================================
-- 2. talisman_pool_settings 테이블 (풀 설정)
-- ============================================

CREATE TABLE IF NOT EXISTS talisman_pool_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category TEXT UNIQUE NOT NULL,
  target_pool_size INTEGER DEFAULT 100,  -- 목표 풀 크기 (100개 기본)
  max_pool_size INTEGER DEFAULT 500,     -- 최대 풀 크기
  random_selection_probability DECIMAL(3,2) DEFAULT 0.30,  -- 30% 확률
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CONSTRAINT valid_talisman_category CHECK (category IN (
    'disease_prevention', 'love_relationship', 'wealth_career',
    'disaster_removal', 'home_protection', 'academic_success', 'health_longevity'
  ))
);

-- 7개 카테고리 기본값 삽입
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
-- 3. talisman_user_cache 테이블 (개인 캐시)
-- ============================================

CREATE TABLE IF NOT EXISTS talisman_user_cache (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  category TEXT NOT NULL,
  image_id UUID REFERENCES talisman_images(id) ON DELETE CASCADE NOT NULL,
  cache_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 유니크 제약: 사용자 + 카테고리 + 날짜당 1개 (하루 1회 제한)
  UNIQUE(user_id, category, cache_date),

  CONSTRAINT valid_cache_category CHECK (category IN (
    'disease_prevention', 'love_relationship', 'wealth_career',
    'disaster_removal', 'home_protection', 'academic_success', 'health_longevity'
  ))
);

-- 캐시 조회 최적화 인덱스
CREATE INDEX IF NOT EXISTS idx_talisman_user_cache_lookup
  ON talisman_user_cache(user_id, category, cache_date);

-- 날짜별 정리용 인덱스
CREATE INDEX IF NOT EXISTS idx_talisman_user_cache_date
  ON talisman_user_cache(cache_date);

-- ============================================
-- 4. RLS 정책
-- ============================================

-- talisman_pool_settings: 모든 사용자 읽기 가능
ALTER TABLE talisman_pool_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view pool settings"
  ON talisman_pool_settings FOR SELECT
  USING (true);

-- talisman_user_cache: 사용자 본인만 접근
ALTER TABLE talisman_user_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cache"
  ON talisman_user_cache FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cache"
  ON talisman_user_cache FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- talisman_images: 공용 풀 조회 정책 추가
DROP POLICY IF EXISTS "Users can view own talisman images" ON talisman_images;

CREATE POLICY "Users can view public or own talisman images"
  ON talisman_images FOR SELECT
  USING (is_public = true OR auth.uid() = user_id);

-- ============================================
-- 5. 헬퍼 함수들
-- ============================================

-- 사용 횟수 증가 함수
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

-- 카테고리별 공용 풀 크기 조회 함수
CREATE OR REPLACE FUNCTION get_talisman_pool_size(p_category TEXT)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER
  FROM talisman_images
  WHERE category = p_category
  AND is_public = true;
$$ LANGUAGE SQL STABLE;

-- 공용 풀에서 랜덤 선택 함수
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

-- 오래된 캐시 정리 함수 (30일 이전)
CREATE OR REPLACE FUNCTION cleanup_old_talisman_cache()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM talisman_user_cache
  WHERE cache_date < CURRENT_DATE - INTERVAL '30 days';

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. 코멘트
-- ============================================

COMMENT ON TABLE talisman_pool_settings IS '부적 이미지 풀 설정 (카테고리당 100개 기본)';
COMMENT ON TABLE talisman_user_cache IS '부적 개인 캐시 (하루 1회 제한 관리)';
COMMENT ON COLUMN talisman_images.is_public IS '공용 풀 포함 여부 (Gemini 생성 이미지만 true)';
COMMENT ON COLUMN talisman_images.usage_count IS '재사용 횟수 (인기도 지표)';
COMMENT ON FUNCTION increment_talisman_usage IS '부적 이미지 사용 횟수 증가';
COMMENT ON FUNCTION get_talisman_pool_size IS '카테고리별 공용 풀 크기 조회';
COMMENT ON FUNCTION get_random_talisman_from_pool IS '공용 풀에서 랜덤 부적 선택';
