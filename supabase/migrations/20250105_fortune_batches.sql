-- Fortune Batches 테이블 생성
-- 효율적인 배치 운세 저장을 위한 스키마

-- 배치 운세 테이블
CREATE TABLE IF NOT EXISTS fortune_batches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  batch_type VARCHAR(50) NOT NULL, -- 'signup', 'daily', 'manual'
  fortunes JSONB NOT NULL, -- 모든 운세 데이터를 하나의 JSON으로 저장
  token_usage INTEGER, -- API 토큰 사용량 추적
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  expires_at TIMESTAMP WITH TIME ZONE, -- NULL이면 영구 보관
  
  -- 복합 유니크 제약 (사용자별 배치 타입별 하루에 하나만)
  CONSTRAINT unique_user_batch_daily UNIQUE (user_id, batch_type, DATE(created_at))
);

-- 인덱스 생성
CREATE INDEX idx_fortune_batches_user ON fortune_batches(user_id);
CREATE INDEX idx_fortune_batches_type ON fortune_batches(batch_type);
CREATE INDEX idx_fortune_batches_expires ON fortune_batches(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_fortune_batches_created ON fortune_batches(created_at);

-- 개별 운세 캐시 테이블 (빠른 조회용)
CREATE TABLE IF NOT EXISTS fortune_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fortune_category VARCHAR(100) NOT NULL,
  fortune_group VARCHAR(50) NOT NULL,
  data JSONB NOT NULL,
  batch_id UUID REFERENCES fortune_batches(id) ON DELETE CASCADE, -- 배치에서 생성된 경우
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  expires_at TIMESTAMP WITH TIME ZONE,
  last_accessed TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  access_count INTEGER DEFAULT 1,
  
  -- 복합 유니크 제약
  CONSTRAINT unique_user_fortune UNIQUE (user_id, fortune_category)
);

-- 캐시 조회 최적화 인덱스
CREATE INDEX idx_fortune_cache_lookup ON fortune_cache(user_id, fortune_category);
CREATE INDEX idx_fortune_cache_expires ON fortune_cache(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_fortune_cache_accessed ON fortune_cache(last_accessed);

-- 이미지 기반 운세 저장 테이블
CREATE TABLE IF NOT EXISTS fortune_images (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fortune_type VARCHAR(50) NOT NULL, -- 'face-reading', 'palmistry'
  image_url TEXT NOT NULL, -- Supabase Storage URL
  analysis_result JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  
  CONSTRAINT check_fortune_type CHECK (fortune_type IN ('face-reading', 'palmistry'))
);

-- 이미지 운세 인덱스
CREATE INDEX idx_fortune_images_user ON fortune_images(user_id, fortune_type);

-- 특수 운세 입력 데이터 테이블 (궁합, 이사 등)
CREATE TABLE IF NOT EXISTS fortune_special_inputs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fortune_type VARCHAR(100) NOT NULL,
  input_data JSONB NOT NULL, -- 특수 입력 데이터 (파트너 정보, 이사 정보 등)
  result_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 특수 입력 인덱스
CREATE INDEX idx_fortune_special_user ON fortune_special_inputs(user_id, fortune_type);

-- 사용자 활동 추적 (일일 배치용)
CREATE TABLE IF NOT EXISTS user_activity (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  daily_batch_generated_at DATE,
  total_fortunes_viewed INTEGER DEFAULT 0
);

-- 활동 추적 인덱스
CREATE INDEX idx_user_activity_seen ON user_activity(last_seen_at);
CREATE INDEX idx_user_activity_batch ON user_activity(daily_batch_generated_at);

-- 만료된 배치 자동 삭제 함수
CREATE OR REPLACE FUNCTION delete_expired_batches()
RETURNS void AS $$
BEGIN
  DELETE FROM fortune_batches 
  WHERE expires_at IS NOT NULL 
  AND expires_at < NOW();
  
  DELETE FROM fortune_cache
  WHERE expires_at IS NOT NULL
  AND expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- 매일 자정에 만료된 데이터 삭제하는 크론 작업 (pg_cron 확장 필요)
-- SELECT cron.schedule('delete-expired-fortunes', '0 0 * * *', $$SELECT delete_expired_batches();$$);

-- 뷰: 사용자별 최신 배치 운세
CREATE OR REPLACE VIEW latest_user_batches AS
SELECT DISTINCT ON (user_id, batch_type)
  user_id,
  batch_type,
  fortunes,
  created_at,
  expires_at
FROM fortune_batches
ORDER BY user_id, batch_type, created_at DESC;

-- 뷰: 활성 사용자 (24시간 내 접속)
CREATE OR REPLACE VIEW active_users AS
SELECT 
  u.id,
  u.email,
  u.raw_user_meta_data->>'name' as name,
  u.raw_user_meta_data->>'birth_date' as birth_date,
  u.raw_user_meta_data->>'gender' as gender,
  u.raw_user_meta_data->>'mbti' as mbti,
  u.raw_user_meta_data->>'blood_type' as blood_type,
  ua.last_seen_at,
  ua.daily_batch_generated_at
FROM auth.users u
LEFT JOIN user_activity ua ON u.id = ua.user_id
WHERE ua.last_seen_at > NOW() - INTERVAL '24 hours'
  AND (ua.daily_batch_generated_at IS NULL OR ua.daily_batch_generated_at < CURRENT_DATE);

-- RLS (Row Level Security) 정책
ALTER TABLE fortune_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_special_inputs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activity ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 운세만 조회 가능
CREATE POLICY "Users can view own fortune batches" ON fortune_batches
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own fortune cache" ON fortune_cache
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own fortune images" ON fortune_images
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own special inputs" ON fortune_special_inputs
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own activity" ON user_activity
  FOR ALL USING (auth.uid() = user_id);

-- 서비스 역할은 모든 작업 가능 (백엔드용)
CREATE POLICY "Service role full access" ON fortune_batches
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role full access cache" ON fortune_cache
  FOR ALL USING (auth.role() = 'service_role');

COMMENT ON TABLE fortune_batches IS '배치로 생성된 운세 데이터 저장';
COMMENT ON TABLE fortune_cache IS '빠른 조회를 위한 개별 운세 캐시';
COMMENT ON TABLE fortune_images IS '관상, 손금 등 이미지 기반 운세';
COMMENT ON TABLE fortune_special_inputs IS '궁합, 이사 등 특수 입력이 필요한 운세';
COMMENT ON TABLE user_activity IS '사용자 활동 추적 (일일 배치용)';