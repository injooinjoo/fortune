-- Repair LLM guard schema drift in production.
-- This migration is intentionally idempotent so it is safe to run
-- even when migration history and live schema are out of sync.

BEGIN;

CREATE TABLE IF NOT EXISTS public.llm_model_config (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  fortune_type VARCHAR(50) NOT NULL UNIQUE,
  provider VARCHAR(20) NOT NULL DEFAULT 'gemini',
  model VARCHAR(100) NOT NULL,
  temperature DECIMAL(3, 2) DEFAULT 0.70,
  max_tokens INTEGER DEFAULT 2048,
  is_active BOOLEAN DEFAULT true,
  ab_test_enabled BOOLEAN DEFAULT false,
  ab_test_model VARCHAR(100),
  ab_test_provider VARCHAR(20),
  ab_test_percentage INTEGER DEFAULT 0
    CHECK (ab_test_percentage >= 0 AND ab_test_percentage <= 100),
  description TEXT,
  priority INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_llm_model_config_fortune_type
  ON public.llm_model_config (fortune_type);
CREATE INDEX IF NOT EXISTS idx_llm_model_config_is_active
  ON public.llm_model_config (is_active)
  WHERE is_active = true;

ALTER TABLE public.llm_model_config ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'llm_model_config'
      AND policyname = 'llm_model_config_service_read'
  ) THEN
    CREATE POLICY "llm_model_config_service_read" ON public.llm_model_config
      FOR SELECT USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'llm_model_config'
      AND policyname = 'llm_model_config_service_all'
  ) THEN
    CREATE POLICY "llm_model_config_service_all" ON public.llm_model_config
      FOR ALL USING (auth.role() = 'service_role');
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.update_llm_model_config_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'llm_model_config_updated_at_trigger'
      AND tgrelid = 'public.llm_model_config'::regclass
  ) THEN
    CREATE TRIGGER llm_model_config_updated_at_trigger
      BEFORE UPDATE ON public.llm_model_config
      FOR EACH ROW
      EXECUTE FUNCTION public.update_llm_model_config_updated_at();
  END IF;
END $$;

INSERT INTO public.llm_model_config (
  fortune_type,
  provider,
  model,
  temperature,
  max_tokens,
  is_active,
  ab_test_enabled,
  ab_test_model,
  ab_test_provider,
  ab_test_percentage,
  description,
  priority,
  metadata
)
VALUES
  ('_default', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed default model', 0, '{}'::jsonb),
  ('daily', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('love', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('career', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('health', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('moving', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('compatibility', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('blind-date', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('ex-lover', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('dream', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('face-reading', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('biorhythm', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('avoid-people', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('lucky-series', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('lucky-items', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('investment', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('time', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('mbti', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('traditional-saju', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('pet-compatibility', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('family-harmony', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('family-change', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('family-children', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('family-health', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('family-relationship', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('family-wealth', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('talent', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('tarot', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('wish', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('exam', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('free-chat', 'gemini', 'gemini-2.5-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('chat-insight', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('character-chat', 'gemini', 'gemini-2.0-flash-lite', 0.60, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('saju', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('decision', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('exercise', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('wealth', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('naming', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('baby-nickname', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('home-fengshui', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('health-document', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('game-enhance', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-story', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('ootd-evaluation', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('new-year', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('past-life', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('match-insight', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('celebrity', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-recommend', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-time', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-biorhythm', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-pet', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-new-year', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-past-life', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-match-insight', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-lucky-items', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-celebrity', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb),
  ('fortune-face-reading', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Repair seed', 0, '{}'::jsonb)
ON CONFLICT (fortune_type) DO UPDATE
SET
  provider = EXCLUDED.provider,
  model = EXCLUDED.model,
  temperature = EXCLUDED.temperature,
  max_tokens = EXCLUDED.max_tokens,
  is_active = true,
  ab_test_enabled = false,
  ab_test_model = NULL,
  ab_test_provider = NULL,
  ab_test_percentage = 0,
  description = EXCLUDED.description,
  priority = EXCLUDED.priority,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();

CREATE TABLE IF NOT EXISTS public.llm_usage_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  fortune_type VARCHAR(50) NOT NULL,
  user_id UUID,
  request_id VARCHAR(100),
  provider VARCHAR(20) NOT NULL,
  model VARCHAR(100) NOT NULL,
  is_ab_test BOOLEAN DEFAULT false,
  prompt_tokens INTEGER NOT NULL DEFAULT 0,
  completion_tokens INTEGER NOT NULL DEFAULT 0,
  total_tokens INTEGER NOT NULL DEFAULT 0,
  latency_ms INTEGER NOT NULL DEFAULT 0,
  estimated_cost DECIMAL(10, 6) DEFAULT 0,
  finish_reason VARCHAR(20),
  success BOOLEAN DEFAULT true,
  error_message TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_fortune_type
  ON public.llm_usage_logs (fortune_type);
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_provider
  ON public.llm_usage_logs (provider);
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_user_id
  ON public.llm_usage_logs (user_id)
  WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_created_at
  ON public.llm_usage_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_is_ab_test
  ON public.llm_usage_logs (is_ab_test)
  WHERE is_ab_test = true;
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_provider_created_at
  ON public.llm_usage_logs (provider, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_provider_feature_created_at
  ON public.llm_usage_logs (provider, fortune_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_llm_usage_logs_guard_state
  ON public.llm_usage_logs (provider, created_at DESC)
  WHERE fortune_type = 'llm-guard' AND model = 'guard-state';

ALTER TABLE public.llm_usage_logs ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'llm_usage_logs'
      AND policyname = 'llm_usage_logs_service_all'
  ) THEN
    CREATE POLICY "llm_usage_logs_service_all" ON public.llm_usage_logs
      FOR ALL USING (auth.role() = 'service_role');
  END IF;
END $$;

CREATE OR REPLACE VIEW public.llm_usage_daily_summary AS
SELECT
  DATE(created_at) AS date,
  fortune_type,
  provider,
  model,
  is_ab_test,
  COUNT(*) AS total_calls,
  SUM(CASE WHEN success THEN 1 ELSE 0 END) AS successful_calls,
  SUM(CASE WHEN NOT success THEN 1 ELSE 0 END) AS failed_calls,
  SUM(total_tokens) AS total_tokens,
  SUM(prompt_tokens) AS total_prompt_tokens,
  SUM(completion_tokens) AS total_completion_tokens,
  AVG(latency_ms)::INTEGER AS avg_latency_ms,
  MIN(latency_ms) AS min_latency_ms,
  MAX(latency_ms) AS max_latency_ms,
  SUM(estimated_cost) AS total_cost
FROM public.llm_usage_logs
GROUP BY DATE(created_at), fortune_type, provider, model, is_ab_test;

CREATE OR REPLACE VIEW public.llm_usage_provider_summary AS
SELECT
  provider,
  model,
  COUNT(*) AS total_calls,
  SUM(total_tokens) AS total_tokens,
  AVG(latency_ms)::INTEGER AS avg_latency_ms,
  SUM(estimated_cost) AS total_cost,
  AVG(CASE WHEN success THEN 1.0 ELSE 0.0 END) * 100 AS success_rate
FROM public.llm_usage_logs
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY provider, model;

COMMENT ON TABLE public.llm_model_config IS
  'LLM model routing config used by runtime cost guards';
COMMENT ON TABLE public.llm_usage_logs IS
  'LLM request log used for cost guard windows, analytics, and incident response';
COMMENT ON COLUMN public.llm_usage_logs.estimated_cost IS
  'Estimated USD cost per call';
COMMENT ON COLUMN public.llm_usage_logs.is_ab_test IS
  'Whether this request used an A/B model variant';

COMMIT;
