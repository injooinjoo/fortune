-- UGC Moderation: message reports + character blocks + server moderation flags
-- Apple Guideline 5.2.3 대응. Additive only — 기존 스키마 영향 없음.

-- === Table A: message_reports (사용자가 AI 메시지를 신고) ===
CREATE TABLE IF NOT EXISTS message_reports (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id  TEXT NOT NULL,
  message_id    TEXT,
  message_text  TEXT NOT NULL,
  reason_code   TEXT NOT NULL CHECK (reason_code IN
                  ('sexual','violence','self_harm','minor','hate','spam','other')),
  reason_note   TEXT,
  status        TEXT NOT NULL DEFAULT 'pending' CHECK (status IN
                  ('pending','reviewed','actioned','dismissed')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at   TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_message_reports_reporter
  ON message_reports(reporter_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_message_reports_pending
  ON message_reports(status, created_at) WHERE status = 'pending';

ALTER TABLE message_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY mr_insert_self ON message_reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY mr_select_self ON message_reports FOR SELECT
  USING (auth.uid() = reporter_id);
-- UPDATE/DELETE는 정책 없음 → service_role만 가능 (운영 리뷰어 권한).

COMMENT ON TABLE message_reports IS
  '사용자가 AI 캐릭터 챗의 부적절한 응답을 신고. 24h 이내 검토 원칙.';


-- === Table B: character_blocks (사용자가 캐릭터를 차단) ===
CREATE TABLE IF NOT EXISTS character_blocks (
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id  TEXT NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  unblocked_at  TIMESTAMPTZ,
  PRIMARY KEY (user_id, character_id)
);

ALTER TABLE character_blocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY cb_all_self ON character_blocks FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

COMMENT ON TABLE character_blocks IS
  '사용자가 해제 전까지 목록/채팅에서 숨길 캐릭터. unblocked_at 로 soft-undo.';


-- === Table C: moderation_flags (서버-측 자동 필터 감사 로그, 클라이언트 비노출) ===
CREATE TABLE IF NOT EXISTS moderation_flags (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  character_id TEXT,
  source       TEXT NOT NULL CHECK (source IN ('user_input','model_output','user_image')),
  categories   JSONB NOT NULL,
  flagged      BOOLEAN NOT NULL,
  text_sample  TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_moderation_flags_user_recent
  ON moderation_flags(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_moderation_flags_flagged
  ON moderation_flags(flagged, created_at) WHERE flagged = true;

ALTER TABLE moderation_flags ENABLE ROW LEVEL SECURITY;
-- service_role 만 쓰기/읽기. 클라이언트에는 정책 없음.

COMMENT ON TABLE moderation_flags IS
  '서버-측 moderation API 호출 결과 감사 로그. text_sample은 최대 500자.';
