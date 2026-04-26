-- Guard LLM model config against runaway cost
-- 1) Ensure active runtime fortune types exist with safe defaults
-- 2) Disable A/B variants globally for emergency stabilization
-- 3) Force high-cost Gemini model patterns back to safe flash-lite

BEGIN;

INSERT INTO llm_model_config (
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
  ('_default', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard default model', 0, '{}'::jsonb),
  ('daily', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('love', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('career', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('health', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('moving', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('compatibility', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('blind-date', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('ex-lover', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('dream', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('face-reading', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('biorhythm', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('avoid-people', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('lucky-items', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('investment', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('time', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('mbti', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('traditional-saju', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('pet-compatibility', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('talent', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('tarot', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('wish', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('exam', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('free-chat', 'gemini', 'gemini-2.5-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('chat-insight', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('character-chat', 'gemini', 'gemini-2.0-flash-lite', 0.60, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('saju', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('decision', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('exercise', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('wealth', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('naming', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('baby-nickname', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('home-fengshui', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('health-document', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('game-enhance', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-story', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('ootd-evaluation', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('family-change', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('family-children', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('family-health', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('family-relationship', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('family-wealth', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('new-year', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('past-life', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('match-insight', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('celebrity', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-recommend', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-time', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-biorhythm', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-pet', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-new-year', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-past-life', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-match-insight', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-lucky-items', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-celebrity', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb),
  ('fortune-face-reading', 'gemini', 'gemini-2.0-flash-lite', 0.70, 2048, true, false, NULL, NULL, 0, 'Cost guard', 0, '{}'::jsonb)
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

-- Emergency: disable A/B model variants globally
UPDATE llm_model_config
SET
  ab_test_enabled = false,
  ab_test_model = NULL,
  ab_test_provider = NULL,
  ab_test_percentage = 0,
  updated_at = NOW();

-- Emergency: block expensive Gemini model patterns
UPDATE llm_model_config
SET
  model = CASE WHEN fortune_type = 'free-chat' THEN 'gemini-2.5-flash-lite' ELSE 'gemini-2.0-flash-lite' END,
  max_tokens = LEAST(COALESCE(max_tokens, 2048), 2048),
  temperature = COALESCE(temperature, 0.70),
  updated_at = NOW()
WHERE provider = 'gemini'
  AND (
    model ~* '^gemini-3'
    OR model ~* '(^|-)pro($|-)'
    OR model ~* 'ultra'
  );

COMMIT;
