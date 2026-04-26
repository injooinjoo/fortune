-- =============================================================================
-- Push 인프라 정상화: fcm_tokens 테이블 + user_notification_preferences 확장
-- =============================================================================
-- production schema와 코드(sync-notification-device, _shared/notification_push)
-- 사이의 분기를 메우기 위한 마이그레이션.

CREATE TABLE IF NOT EXISTS fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  device_info JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user_active ON fcm_tokens(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_active_only ON fcm_tokens(token) WHERE is_active = true;

CREATE OR REPLACE FUNCTION update_fcm_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_fcm_tokens_updated_at ON fcm_tokens;
CREATE TRIGGER trigger_fcm_tokens_updated_at
  BEFORE UPDATE ON fcm_tokens FOR EACH ROW
  EXECUTE FUNCTION update_fcm_tokens_updated_at();

ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own fcm tokens" ON fcm_tokens;
CREATE POLICY "Users can view own fcm tokens"
  ON fcm_tokens FOR SELECT USING (auth.uid() = user_id);

COMMENT ON TABLE fcm_tokens IS 'Expo push 토큰 저장소. 한 사용자의 같은 토큰은 1개만 (UNIQUE user_id,token). 토큰 회전 시 is_active=false로 비활성화.';

ALTER TABLE user_notification_preferences ADD COLUMN IF NOT EXISTS daily_fortune BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE user_notification_preferences ADD COLUMN IF NOT EXISTS token_alert BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE user_notification_preferences ADD COLUMN IF NOT EXISTS promotion BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE user_notification_preferences ADD COLUMN IF NOT EXISTS preferred_hour INT;
