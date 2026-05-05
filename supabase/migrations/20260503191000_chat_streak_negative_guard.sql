-- consume_chat_streak: last_active_date 가 미래값 (시간대 / 시계 역행 / import)
-- 인 케이스 가드. 기존 ELSE 절이 streak=1 로 리셋시켜 사용자 부당 손해.
-- 미래면 그대로 유지하고 streak 변경 안 함.

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
  INSERT INTO user_chat_streak (user_id, streak_days, last_active_date, today_count, today_date)
  VALUES (p_user_id, 1, v_today, 0, v_today)
  ON CONFLICT (user_id) DO NOTHING;

  SELECT s.streak_days, s.today_count, s.today_date, s.last_active_date
    INTO v_streak, v_today_count, v_today_date, v_last_active
  FROM user_chat_streak s WHERE s.user_id = p_user_id
  FOR UPDATE;

  -- last_active_date 미래값 (시간대/시계 역행) 가드.
  IF v_last_active > v_today THEN
    NULL;  -- 변경 안 함, today_count 만 그대로 유지
  ELSIF v_today_date < v_today THEN
    IF v_today - v_last_active = 1 THEN
      v_streak := v_streak + 1;
    ELSIF v_today - v_last_active > 1 THEN
      v_streak := 1;
    END IF;
    -- = 0 (오늘 첫 INSERT) 은 변경 X
    v_today_count := 0;
    v_today_date  := v_today;
    v_last_active := v_today;
  END IF;

  v_limit := chat_streak_limit(v_streak);

  IF v_today_count >= v_limit THEN
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
