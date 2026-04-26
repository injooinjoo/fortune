ALTER TABLE character_conversations
ADD COLUMN IF NOT EXISTS runtime_state JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMENT ON COLUMN character_conversations.runtime_state IS
  '스토리 런타임 상태 (romanceState, sceneIntent, responseGoal, safeAffectionCap, followUpHint)';
