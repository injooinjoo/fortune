-- =============================================================================
-- 사용자-캐릭터 장기 메모리 테이블
-- 생성일: 2026-02-15
-- 목적: 관계 단계/핵심 사실/요약을 user_id + character_id 단위로 영속 저장
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_character_memory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id TEXT NOT NULL,

  -- 요약 메모리 본문
  summary TEXT NOT NULL DEFAULT '',
  key_facts JSONB NOT NULL DEFAULT '[]'::jsonb,
  relationship_directives JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- 요약 갱신 기준 추적
  message_count_snapshot INT NOT NULL DEFAULT 0,
  last_summarized_at TIMESTAMPTZ,

  -- 공통 타임스탬프
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- 사용자-캐릭터 1:1
  UNIQUE(user_id, character_id)
);

CREATE INDEX IF NOT EXISTS idx_user_character_memory_user_id
  ON user_character_memory(user_id);

CREATE INDEX IF NOT EXISTS idx_user_character_memory_character_id
  ON user_character_memory(character_id);

CREATE INDEX IF NOT EXISTS idx_user_character_memory_updated_at
  ON user_character_memory(updated_at DESC);

ALTER TABLE user_character_memory ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own character memory"
  ON user_character_memory FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own character memory"
  ON user_character_memory FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own character memory"
  ON user_character_memory FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own character memory"
  ON user_character_memory FOR DELETE
  USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_user_character_memory_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_user_character_memory_updated_at
  ON user_character_memory;

CREATE TRIGGER trigger_update_user_character_memory_updated_at
  BEFORE UPDATE ON user_character_memory
  FOR EACH ROW
  EXECUTE FUNCTION update_user_character_memory_updated_at();

COMMENT ON TABLE user_character_memory IS '사용자-캐릭터 장기 메모리(요약/핵심 사실/관계 지시)';
COMMENT ON COLUMN user_character_memory.summary IS '장기 대화 요약';
COMMENT ON COLUMN user_character_memory.key_facts IS '장기 기억 핵심 사실 목록(JSON 배열)';
COMMENT ON COLUMN user_character_memory.relationship_directives IS '관계 단계별 응답 지시(JSON 객체)';
COMMENT ON COLUMN user_character_memory.message_count_snapshot IS '요약 시점의 누적 메시지 개수';
COMMENT ON COLUMN user_character_memory.last_summarized_at IS '마지막 요약 갱신 시각';
