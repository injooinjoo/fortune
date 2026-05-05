-- BM v2.2: 가입 보너스 30 → 50 토큰 상향.
-- 신규 사용자 retention 강화 (이전엔 paywall 도달까지 ~30분).

CREATE OR REPLACE FUNCTION grant_initial_tokens()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_initial_tokens INT := 50; -- BM v2.2: 30 → 50
BEGIN
  INSERT INTO token_balance (user_id, balance, total_earned, created_at, updated_at)
  VALUES (NEW.id, v_initial_tokens, v_initial_tokens, NOW(), NOW())
  ON CONFLICT (user_id) DO NOTHING;

  RAISE LOG '[grant_initial_tokens] Granted % tokens to new user: %', v_initial_tokens, NEW.id;
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION grant_initial_tokens() IS 'BM v2.2: 신규 사용자에게 50 토큰 자동 지급';
