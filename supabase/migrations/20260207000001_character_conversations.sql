-- =============================================================================
-- 캐릭터 대화 스레드 테이블
-- 유저+캐릭터 조합당 하나의 스레드를 저장하여 대화 지속성 제공
-- =============================================================================

-- 캐릭터 대화 스레드 테이블
CREATE TABLE IF NOT EXISTS character_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id TEXT NOT NULL,

  -- 메시지 히스토리 (최근 50개만 저장)
  -- 형식: [{ "id": "uuid", "type": "user|character", "content": "...", "timestamp": "..." }]
  messages JSONB NOT NULL DEFAULT '[]'::jsonb,

  -- 메타데이터
  last_message_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- 유저+캐릭터 조합당 하나의 스레드만 허용
  UNIQUE(user_id, character_id)
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_character_conversations_user
  ON character_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_character_conversations_updated
  ON character_conversations(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_character_conversations_character
  ON character_conversations(character_id);

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_character_conversations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_character_conversations_updated_at ON character_conversations;
CREATE TRIGGER trigger_character_conversations_updated_at
  BEFORE UPDATE ON character_conversations
  FOR EACH ROW
  EXECUTE FUNCTION update_character_conversations_updated_at();

-- =============================================================================
-- RLS 정책 (Row Level Security)
-- =============================================================================

ALTER TABLE character_conversations ENABLE ROW LEVEL SECURITY;

-- 자신의 대화만 조회 가능
CREATE POLICY "Users can view own conversations"
  ON character_conversations FOR SELECT
  USING (auth.uid() = user_id);

-- 자신의 대화만 생성 가능
CREATE POLICY "Users can insert own conversations"
  ON character_conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 자신의 대화만 수정 가능
CREATE POLICY "Users can update own conversations"
  ON character_conversations FOR UPDATE
  USING (auth.uid() = user_id);

-- 자신의 대화만 삭제 가능
CREATE POLICY "Users can delete own conversations"
  ON character_conversations FOR DELETE
  USING (auth.uid() = user_id);

-- =============================================================================
-- 코멘트
-- =============================================================================

COMMENT ON TABLE character_conversations IS '캐릭터별 대화 스레드 저장 테이블';
COMMENT ON COLUMN character_conversations.user_id IS '사용자 ID (auth.users 참조)';
COMMENT ON COLUMN character_conversations.character_id IS '캐릭터 ID (앱 내 정의)';
COMMENT ON COLUMN character_conversations.messages IS '메시지 히스토리 (JSONB 배열, 최근 50개)';
COMMENT ON COLUMN character_conversations.last_message_at IS '마지막 메시지 시간';
