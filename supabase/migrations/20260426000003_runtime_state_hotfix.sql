-- character_conversations.runtime_state 핫픽스
-- character-conversation-save 함수가 INSERT 시도하던 컬럼이 production에 없어 500 에러 반복.
-- 보류된 20260407000002_character_conversations_runtime_state.sql 의 동일 SQL을
-- 단독 마이그레이션으로 분리해 즉시 적용. Idempotent (IF NOT EXISTS).
-- mcp execute_sql 로 production 적용 완료(2026-04-26 21:50 KST).

ALTER TABLE character_conversations
ADD COLUMN IF NOT EXISTS runtime_state JSONB NOT NULL DEFAULT '{}'::jsonb;
