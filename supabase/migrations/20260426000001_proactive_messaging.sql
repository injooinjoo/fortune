-- =============================================================================
-- 캐릭터 선톡(Proactive Messaging) 시스템
-- 설계 문서: docs/features/PROACTIVE_MESSAGING_PLAN.md
-- 1차 슬라이스: 사용자 설정 + 발송 로그 + character_dm 외 알림 채널 토글
-- =============================================================================

-- 1. 사용자별 선톡 설정
CREATE TABLE IF NOT EXISTS user_proactive_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  enabled BOOLEAN NOT NULL DEFAULT true,
  -- Quiet hours: 사용자 timezone 기준 시간(0-23). start > end 면 자정 넘어감(예: 22-9).
  quiet_hours_start INT NOT NULL DEFAULT 22 CHECK (quiet_hours_start BETWEEN 0 AND 23),
  quiet_hours_end INT NOT NULL DEFAULT 9 CHECK (quiet_hours_end BETWEEN 0 AND 23),
  timezone TEXT NOT NULL DEFAULT 'Asia/Seoul',
  -- 빈도 단계. 디스패처가 일일 cap을 결정.
  frequency_tier TEXT NOT NULL DEFAULT 'moderate'
    CHECK (frequency_tier IN ('low', 'moderate', 'high')),
  -- 빈 배열 = 모든 캐릭터 허용. 명시적 화이트리스트만 받고 싶을 때 채움.
  enabled_character_ids TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  -- 비활성 슬롯 키 목록(예: 'lunch_share', 'goodnight').
  disabled_slot_keys TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION update_user_proactive_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_user_proactive_preferences_updated_at
  ON user_proactive_preferences;
CREATE TRIGGER trigger_user_proactive_preferences_updated_at
  BEFORE UPDATE ON user_proactive_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_user_proactive_preferences_updated_at();

ALTER TABLE user_proactive_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own proactive preferences"
  ON user_proactive_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own proactive preferences"
  ON user_proactive_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own proactive preferences"
  ON user_proactive_preferences FOR UPDATE
  USING (auth.uid() = user_id);

COMMENT ON TABLE user_proactive_preferences IS '캐릭터 선톡 사용자 설정';
COMMENT ON COLUMN user_proactive_preferences.timezone IS 'IANA timezone (예: Asia/Seoul). 슬롯 윈도우/quiet hours 계산 기준';
COMMENT ON COLUMN user_proactive_preferences.frequency_tier IS 'low(2회), moderate(3회), high(8회) — 일일 cap';
COMMENT ON COLUMN user_proactive_preferences.enabled_character_ids IS '빈 배열이면 모든 캐릭터 허용';

-- 2. 선톡 발송 로그 (빈도 제어 + 분석용)
CREATE TABLE IF NOT EXISTS proactive_message_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id TEXT NOT NULL,
  -- 슬롯 키: 'morning_greet', 'lunch_share', 'absence_6h' 등
  slot_key TEXT NOT NULL,
  content_kind TEXT NOT NULL CHECK (content_kind IN ('text', 'image')),
  message_id TEXT NOT NULL,
  -- 사용자 timezone 기준 캘린더 날짜. 일일 cap 체크용.
  user_local_date DATE NOT NULL,
  user_replied BOOLEAN NOT NULL DEFAULT false,
  user_replied_at TIMESTAMPTZ,
  scheduled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  push_sent_count INT NOT NULL DEFAULT 0,
  push_skipped_reason TEXT,
  meta JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_proactive_log_user_date
  ON proactive_message_log(user_id, user_local_date DESC);
CREATE INDEX IF NOT EXISTS idx_proactive_log_user_char_date
  ON proactive_message_log(user_id, character_id, user_local_date DESC);
CREATE INDEX IF NOT EXISTS idx_proactive_log_user_slot_date
  ON proactive_message_log(user_id, slot_key, user_local_date DESC);

ALTER TABLE proactive_message_log ENABLE ROW LEVEL SECURITY;

-- 클라이언트는 read-only로 자기 로그만 조회. 쓰기는 service role 만.
CREATE POLICY "Users can view own proactive log"
  ON proactive_message_log FOR SELECT
  USING (auth.uid() = user_id);

COMMENT ON TABLE proactive_message_log IS '선톡 발송 기록 (빈도 제어 + 답장률 분석)';
COMMENT ON COLUMN proactive_message_log.user_local_date IS '사용자 timezone 기준 캘린더 날짜 (일일 cap 체크용)';
COMMENT ON COLUMN proactive_message_log.user_replied IS '발송 후 사용자가 그 캐릭터에게 답장했는지(별도 잡으로 갱신)';

-- 3. 알림 채널 토글 — 기존 user_notification_preferences에 character_proactive 추가.
-- 테이블이 없으면 생성, 있으면 컬럼만 추가.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'user_notification_preferences'
  ) THEN
    CREATE TABLE user_notification_preferences (
      user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
      enabled BOOLEAN NOT NULL DEFAULT true,
      character_dm BOOLEAN NOT NULL DEFAULT true,
      character_proactive BOOLEAN NOT NULL DEFAULT true,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
    ALTER TABLE user_notification_preferences ENABLE ROW LEVEL SECURITY;
    CREATE POLICY "Users can view own notification prefs"
      ON user_notification_preferences FOR SELECT
      USING (auth.uid() = user_id);
    CREATE POLICY "Users can upsert own notification prefs"
      ON user_notification_preferences FOR ALL
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  ELSE
    ALTER TABLE user_notification_preferences
      ADD COLUMN IF NOT EXISTS character_proactive BOOLEAN NOT NULL DEFAULT true;
  END IF;
END $$;

COMMENT ON COLUMN user_notification_preferences.character_proactive
  IS '캐릭터 선톡 알림 별도 토글. character_dm OFF여도 이건 별도로 받을 수 있음';
