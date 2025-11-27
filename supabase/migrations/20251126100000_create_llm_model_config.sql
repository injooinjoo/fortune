-- LLM 모델 설정 테이블
-- 운세 타입별 동적 모델 설정 및 A/B 테스트 지원

CREATE TABLE IF NOT EXISTS llm_model_config (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  fortune_type VARCHAR(50) NOT NULL UNIQUE,
  provider VARCHAR(20) NOT NULL DEFAULT 'gemini',
  model VARCHAR(100) NOT NULL,
  temperature DECIMAL(3,2) DEFAULT 1.0,
  max_tokens INTEGER DEFAULT 8192,
  is_active BOOLEAN DEFAULT true,

  -- A/B 테스트 지원
  ab_test_enabled BOOLEAN DEFAULT false,
  ab_test_model VARCHAR(100),
  ab_test_provider VARCHAR(20),
  ab_test_percentage INTEGER DEFAULT 0 CHECK (ab_test_percentage >= 0 AND ab_test_percentage <= 100),

  -- 메타데이터
  description TEXT,
  priority INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}',

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_llm_model_config_fortune_type ON llm_model_config(fortune_type);
CREATE INDEX IF NOT EXISTS idx_llm_model_config_is_active ON llm_model_config(is_active) WHERE is_active = true;

-- RLS 활성화
ALTER TABLE llm_model_config ENABLE ROW LEVEL SECURITY;

-- 서비스 역할 읽기 정책
CREATE POLICY "llm_model_config_service_read" ON llm_model_config
  FOR SELECT USING (true);

-- 서비스 역할 전체 권한 (관리자용)
CREATE POLICY "llm_model_config_service_all" ON llm_model_config
  FOR ALL USING (auth.role() = 'service_role');

-- updated_at 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_llm_model_config_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER llm_model_config_updated_at_trigger
  BEFORE UPDATE ON llm_model_config
  FOR EACH ROW
  EXECUTE FUNCTION update_llm_model_config_updated_at();

-- 초기 데이터 삽입 (gemini-2.0-flash-lite 기본값)
INSERT INTO llm_model_config (fortune_type, provider, model, description) VALUES
  ('_default', 'gemini', 'gemini-2.0-flash-lite', '글로벌 기본값'),
  ('daily', 'gemini', 'gemini-2.0-flash-lite', '일일운세'),
  ('love', 'gemini', 'gemini-2.0-flash-lite', '연애운세'),
  ('career', 'gemini', 'gemini-2.0-flash-lite', '커리어운세'),
  ('health', 'gemini', 'gemini-2.0-flash-lite', '건강운세'),
  ('moving', 'gemini', 'gemini-2.0-flash-lite', '이사운세'),
  ('compatibility', 'gemini', 'gemini-2.0-flash-lite', '궁합운세'),
  ('blind-date', 'gemini', 'gemini-2.0-flash-lite', '소개팅운세'),
  ('ex-lover', 'gemini', 'gemini-2.0-flash-lite', '전애인운세'),
  ('dream', 'gemini', 'gemini-2.0-flash-lite', '꿈해몽'),
  ('face-reading', 'gemini', 'gemini-2.0-flash-lite', '관상운세'),
  ('biorhythm', 'gemini', 'gemini-2.0-flash-lite', '바이오리듬'),
  ('avoid-people', 'gemini', 'gemini-2.0-flash-lite', '피해야할사람'),
  ('lucky-series', 'gemini', 'gemini-2.0-flash-lite', '행운연속'),
  ('talent', 'gemini', 'gemini-2.0-flash-lite', '재능운세'),
  ('lucky-items', 'gemini', 'gemini-2.0-flash-lite', '행운아이템'),
  ('investment', 'gemini', 'gemini-2.0-flash-lite', '투자운세'),
  ('time', 'gemini', 'gemini-2.0-flash-lite', '시간운세'),
  ('mbti', 'gemini', 'gemini-2.0-flash-lite', 'MBTI운세'),
  ('traditional-saju', 'gemini', 'gemini-2.0-flash-lite', '전통사주'),
  ('pet-compatibility', 'gemini', 'gemini-2.0-flash-lite', '반려동물궁합'),
  ('family-harmony', 'gemini', 'gemini-2.0-flash-lite', '가족화목')
ON CONFLICT (fortune_type) DO NOTHING;

-- 코멘트 추가
COMMENT ON TABLE llm_model_config IS 'LLM 모델 설정 - 운세 타입별 동적 모델 설정 및 A/B 테스트 지원';
COMMENT ON COLUMN llm_model_config.fortune_type IS '운세 타입 (_default는 글로벌 기본값)';
COMMENT ON COLUMN llm_model_config.provider IS 'LLM 프로바이더 (gemini, openai, anthropic, grok)';
COMMENT ON COLUMN llm_model_config.ab_test_percentage IS 'A/B 테스트 트래픽 비율 (0-100%)';
