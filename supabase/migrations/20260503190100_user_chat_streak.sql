-- Free 사용자 streak 기반 일일 채팅 한도.
-- streak_days = 1: 30 메시지/일
-- streak_days = 2: 100/일
-- streak_days = 3: 200/일
-- streak_days >= 4: 400/일
-- 연속 끊기면 streak_days = 1 로 리셋.

CREATE TABLE IF NOT EXISTS user_chat_streak (
  user_id           uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  streak_days       integer NOT NULL DEFAULT 1,
  last_active_date  date    NOT NULL DEFAULT CURRENT_DATE,
  today_count       integer NOT NULL DEFAULT 0,
  today_date        date    NOT NULL DEFAULT CURRENT_DATE,
  updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_chat_streak_user ON user_chat_streak(user_id);

ALTER TABLE user_chat_streak ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_chat_streak_self_read" ON user_chat_streak
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "user_chat_streak_service_all" ON user_chat_streak
  FOR ALL TO service_role USING (true) WITH CHECK (true);

-- 한도 계산 함수.
CREATE OR REPLACE FUNCTION chat_streak_limit(streak integer)
RETURNS integer LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE
    WHEN streak >= 4 THEN 400
    WHEN streak = 3 THEN 200
    WHEN streak = 2 THEN 100
    ELSE 30
  END;
$$;

-- streak 갱신 + 한도 체크 + (한도 내면) today_count 증가 를 atomic 하게 수행.
-- 반환: (allowed, current_count, limit, streak_days)
CREATE OR REPLACE FUNCTION consume_chat_streak(p_user_id uuid)
RETURNS TABLE(
  allowed       boolean,
  current_count integer,
  daily_limit   integer,
  streak_days   integer
)
LANGUAGE plpgsql AS $$
DECLARE
  v_today        date := CURRENT_DATE;
  v_streak       integer;
  v_today_count  integer;
  v_today_date   date;
  v_last_active  date;
  v_limit        integer;
BEGIN
  -- upsert (없으면 첫 row)
  INSERT INTO user_chat_streak (user_id, streak_days, last_active_date, today_count, today_date)
  VALUES (p_user_id, 1, v_today, 0, v_today)
  ON CONFLICT (user_id) DO NOTHING;

  SELECT s.streak_days, s.today_count, s.today_date, s.last_active_date
    INTO v_streak, v_today_count, v_today_date, v_last_active
  FROM user_chat_streak s WHERE s.user_id = p_user_id
  FOR UPDATE;

  -- 새 날짜 진입 시 streak / today_count 갱신
  IF v_today_date < v_today THEN
    IF v_today - v_last_active = 1 THEN
      v_streak := v_streak + 1;          -- 연속 출석
    ELSIF v_today = v_last_active THEN
      -- 같은 날 (가능성 낮음, 안전)
      NULL;
    ELSE
      v_streak := 1;                     -- 끊김
    END IF;
    v_today_count := 0;
    v_today_date  := v_today;
    v_last_active := v_today;
  END IF;

  v_limit := chat_streak_limit(v_streak);

  IF v_today_count >= v_limit THEN
    -- 한도 초과 → 차단, count 증가 안 함
    UPDATE user_chat_streak
       SET streak_days = v_streak,
           today_count = v_today_count,
           today_date  = v_today_date,
           last_active_date = v_last_active,
           updated_at = now()
     WHERE user_id = p_user_id;

    RETURN QUERY SELECT false, v_today_count, v_limit, v_streak;
    RETURN;
  END IF;

  v_today_count := v_today_count + 1;

  UPDATE user_chat_streak
     SET streak_days = v_streak,
         today_count = v_today_count,
         today_date  = v_today_date,
         last_active_date = v_last_active,
         updated_at = now()
   WHERE user_id = p_user_id;

  RETURN QUERY SELECT true, v_today_count, v_limit, v_streak;
END;
$$;
