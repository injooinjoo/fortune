-- LLM 호출 로그 테이블
-- 비용 분석, 성능 모니터링, A/B 테스트 결과 추적

CREATE TABLE IF NOT EXISTS llm_usage_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- 요청 정보
  fortune_type VARCHAR(50) NOT NULL,
  user_id UUID,
  request_id VARCHAR(100),  -- 클라이언트 추적용

  -- LLM 설정
  provider VARCHAR(20) NOT NULL,
  model VARCHAR(100) NOT NULL,
  is_ab_test BOOLEAN DEFAULT false,

  -- 토큰 사용량
  prompt_tokens INTEGER NOT NULL DEFAULT 0,
  completion_tokens INTEGER NOT NULL DEFAULT 0,
  total_tokens INTEGER NOT NULL DEFAULT 0,

  -- 성능 메트릭
  latency_ms INTEGER NOT NULL DEFAULT 0,

  -- 비용 추정 (USD, 소수점 6자리)
  estimated_cost DECIMAL(10, 6) DEFAULT 0,

  -- 응답 정보
  finish_reason VARCHAR(20),  -- 'stop', 'length', 'error'
  success BOOLEAN DEFAULT true,
  error_message TEXT,

  -- 메타데이터
  metadata JSONB DEFAULT '{}',

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_fortune_type ON llm_usage_logs(fortune_type);
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_provider ON llm_usage_logs(provider);
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_user_id ON llm_usage_logs(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_created_at ON llm_usage_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_is_ab_test ON llm_usage_logs(is_ab_test) WHERE is_ab_test = true;

-- 날짜별 집계용 인덱스
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_date ON llm_usage_logs(DATE(created_at));

-- RLS 활성화
ALTER TABLE llm_usage_logs ENABLE ROW LEVEL SECURITY;

-- 서비스 역할만 쓰기/읽기 가능
CREATE POLICY "llm_usage_logs_service_all" ON llm_usage_logs
  FOR ALL USING (auth.role() = 'service_role');

-- 분석 쿼리용 뷰 (일별 요약)
CREATE OR REPLACE VIEW llm_usage_daily_summary AS
SELECT
  DATE(created_at) as date,
  fortune_type,
  provider,
  model,
  is_ab_test,
  COUNT(*) as total_calls,
  SUM(CASE WHEN success THEN 1 ELSE 0 END) as successful_calls,
  SUM(CASE WHEN NOT success THEN 1 ELSE 0 END) as failed_calls,
  SUM(total_tokens) as total_tokens,
  SUM(prompt_tokens) as total_prompt_tokens,
  SUM(completion_tokens) as total_completion_tokens,
  AVG(latency_ms)::INTEGER as avg_latency_ms,
  MIN(latency_ms) as min_latency_ms,
  MAX(latency_ms) as max_latency_ms,
  SUM(estimated_cost) as total_cost
FROM llm_usage_logs
GROUP BY DATE(created_at), fortune_type, provider, model, is_ab_test;

-- 프로바이더별 요약 뷰
CREATE OR REPLACE VIEW llm_usage_provider_summary AS
SELECT
  provider,
  model,
  COUNT(*) as total_calls,
  SUM(total_tokens) as total_tokens,
  AVG(latency_ms)::INTEGER as avg_latency_ms,
  SUM(estimated_cost) as total_cost,
  AVG(CASE WHEN success THEN 1.0 ELSE 0.0 END) * 100 as success_rate
FROM llm_usage_logs
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY provider, model;

-- 코멘트 추가
COMMENT ON TABLE llm_usage_logs IS 'LLM API 호출 로그 - 비용/성능 분석용';
COMMENT ON COLUMN llm_usage_logs.estimated_cost IS 'USD 기준 추정 비용';
COMMENT ON COLUMN llm_usage_logs.is_ab_test IS 'A/B 테스트 변형 사용 여부';
