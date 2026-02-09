-- Point System Migration: 토큰 → 포인트 전환
-- 실행 전 백업 필수!

-- 1. subscriptions 테이블 확장 (구독자 일일 한도)
ALTER TABLE subscriptions
ADD COLUMN IF NOT EXISTS daily_point_limit INT DEFAULT 1000,
ADD COLUMN IF NOT EXISTS points_used_today INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_point_reset TIMESTAMPTZ DEFAULT NOW();

-- 기존 활성 구독자에게 일일 한도 적용
UPDATE subscriptions
SET daily_point_limit = 1000,
    points_used_today = 0,
    last_point_reset = NOW()
WHERE status = 'active';

-- 2. 출석체크 테이블 생성
CREATE TABLE IF NOT EXISTS daily_check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  checked_at DATE NOT NULL DEFAULT CURRENT_DATE,
  points_earned INT NOT NULL DEFAULT 100,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, checked_at)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_daily_check_ins_user ON daily_check_ins(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_check_ins_date ON daily_check_ins(checked_at DESC);

-- 3. 기존 토큰 → 포인트 변환 (1:10 비율)
UPDATE token_balance
SET balance = balance * 10,
    total_earned = COALESCE(total_earned, 0) * 10,
    total_spent = COALESCE(total_spent, 0) * 10
WHERE balance > 0;

-- 4. CRON Job: 매일 자정(KST) 구독자 포인트 리셋
-- pg_cron 확장이 설치되어 있어야 함
-- SELECT cron.schedule(
--   'reset-subscriber-daily-points',
--   '0 15 * * *', -- UTC 15:00 = KST 00:00
--   $$
--   UPDATE subscriptions
--   SET points_used_today = 0, last_point_reset = NOW()
--   WHERE status = 'active' AND expires_at > NOW();
--   $$
-- );

-- 5. RLS 정책 (daily_check_ins)
ALTER TABLE daily_check_ins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own check-ins"
  ON daily_check_ins FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own check-ins"
  ON daily_check_ins FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 6. 함수: 출석체크 처리
CREATE OR REPLACE FUNCTION process_daily_checkin(p_user_id UUID)
RETURNS TABLE(success BOOLEAN, points_earned INT, already_checked BOOLEAN, new_balance INT) AS $$
DECLARE
  v_existing RECORD;
  v_current_balance INT;
  v_new_balance INT;
BEGIN
  -- 오늘 이미 체크인했는지 확인
  SELECT * INTO v_existing
  FROM daily_check_ins
  WHERE user_id = p_user_id AND checked_at = CURRENT_DATE;

  IF FOUND THEN
    -- 이미 체크인함
    SELECT balance INTO v_current_balance FROM token_balance WHERE user_id = p_user_id;
    RETURN QUERY SELECT FALSE, 0, TRUE, COALESCE(v_current_balance, 0);
    RETURN;
  END IF;

  -- 체크인 기록 추가
  INSERT INTO daily_check_ins (user_id, checked_at, points_earned)
  VALUES (p_user_id, CURRENT_DATE, 100);

  -- 포인트 추가
  INSERT INTO token_balance (user_id, balance, total_earned)
  VALUES (p_user_id, 100, 100)
  ON CONFLICT (user_id)
  DO UPDATE SET
    balance = token_balance.balance + 100,
    total_earned = COALESCE(token_balance.total_earned, 0) + 100,
    updated_at = NOW();

  -- 새 잔액 조회
  SELECT balance INTO v_new_balance FROM token_balance WHERE user_id = p_user_id;

  RETURN QUERY SELECT TRUE, 100, FALSE, v_new_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
