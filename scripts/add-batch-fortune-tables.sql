-- 토큰 사용량 추적 테이블
CREATE TABLE IF NOT EXISTS token_usage (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  package_name VARCHAR(255) NOT NULL,
  prompt_tokens INTEGER NOT NULL DEFAULT 0,
  completion_tokens INTEGER NOT NULL DEFAULT 0,
  total_tokens INTEGER NOT NULL,
  cost DECIMAL(10, 6) NOT NULL,
  duration INTEGER NOT NULL,
  model VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_user_id (user_id),
  INDEX idx_created_at (created_at),
  INDEX idx_package_name (package_name)
);

-- 에러 로그 테이블
CREATE TABLE IF NOT EXISTS error_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  error_type VARCHAR(100),
  error_message TEXT,
  error_stack TEXT,
  url TEXT,
  method VARCHAR(10),
  headers JSONB,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_error_type (error_type),
  INDEX idx_created_at (created_at),
  INDEX idx_user_id (user_id)
);

-- 개별 운세 저장 테이블 (배치 생성된 운세의 개별 저장)
CREATE TABLE IF NOT EXISTS user_fortunes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fortune_type VARCHAR(100) NOT NULL,
  fortune_data JSONB NOT NULL,
  batch_id VARCHAR(255),
  generated_at TIMESTAMP WITH TIME ZONE NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 유니크 제약 (사용자별, 운세 타입별, 날짜별 중복 방지)
  UNIQUE(user_id, fortune_type, DATE(generated_at)),
  
  -- 인덱스
  INDEX idx_user_fortune (user_id, fortune_type),
  INDEX idx_batch_id (batch_id),
  INDEX idx_expires_at (expires_at)
);

-- RLS (Row Level Security) 활성화
ALTER TABLE token_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_fortunes ENABLE ROW LEVEL SECURITY;

-- RLS 정책 설정
-- token_usage: 관리자만 전체 조회, 사용자는 자신의 데이터만
CREATE POLICY "Users can view own token usage" ON token_usage
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage token usage" ON token_usage
  FOR ALL USING (auth.role() = 'service_role');

-- error_logs: 관리자만 조회 가능
CREATE POLICY "Only service role can manage error logs" ON error_logs
  FOR ALL USING (auth.role() = 'service_role');

-- user_fortunes: 사용자는 자신의 운세만 조회
CREATE POLICY "Users can view own fortunes" ON user_fortunes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage user fortunes" ON user_fortunes
  FOR ALL USING (auth.role() = 'service_role');

-- 토큰 사용량 집계 뷰
CREATE OR REPLACE VIEW token_usage_summary AS
SELECT 
  user_id,
  DATE(created_at) as date,
  package_name,
  COUNT(*) as request_count,
  SUM(total_tokens) as total_tokens,
  SUM(cost) as total_cost,
  AVG(duration) as avg_duration
FROM token_usage
GROUP BY user_id, DATE(created_at), package_name;

-- 월간 토큰 사용량 집계 뷰
CREATE OR REPLACE VIEW monthly_token_usage AS
SELECT 
  user_id,
  DATE_TRUNC('month', created_at) as month,
  SUM(total_tokens) as total_tokens,
  SUM(cost) as total_cost,
  COUNT(DISTINCT package_name) as unique_packages,
  COUNT(*) as total_requests
FROM token_usage
GROUP BY user_id, DATE_TRUNC('month', created_at);