-- character-chat 동적 LLM 기본 설정 upsert

INSERT INTO llm_model_config (
  fortune_type,
  provider,
  model,
  temperature,
  max_tokens,
  is_active,
  description,
  priority,
  metadata
)
VALUES (
  'character-chat',
  'gemini',
  'gemini-2.0-flash-lite',
  0.6,
  2048,
  true,
  '캐릭터 채팅 기본 모델 설정',
  0,
  '{}'::jsonb
)
ON CONFLICT (fortune_type) DO UPDATE
SET
  provider = EXCLUDED.provider,
  model = EXCLUDED.model,
  temperature = EXCLUDED.temperature,
  max_tokens = EXCLUDED.max_tokens,
  is_active = EXCLUDED.is_active,
  description = EXCLUDED.description,
  priority = EXCLUDED.priority,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();
