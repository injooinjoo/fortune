-- 광고 시청 → 토큰 보상 로그 테이블.
-- 일일 5회 한도 / abuse 방지용 frequency cap.

CREATE TABLE IF NOT EXISTS ad_reward_log (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reward_date date NOT NULL DEFAULT CURRENT_DATE,
  tokens_granted integer NOT NULL DEFAULT 1,
  ad_unit     text,
  -- AdMob SSV (Server Side Verification) 가 활성화되면 검증된 토큰을 저장.
  ssv_signature text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ad_reward_user_date
  ON ad_reward_log(user_id, reward_date);

ALTER TABLE ad_reward_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ad_reward_log_self_read" ON ad_reward_log
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "ad_reward_log_service_all" ON ad_reward_log
  FOR ALL TO service_role USING (true) WITH CHECK (true);
