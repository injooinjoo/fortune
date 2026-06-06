-- Rewarded ad tokens must be granted from verified AdMob SSV only.
-- Client POST self-attestation can mint paid-equivalent tokens without ad proof, so
-- every verified AdMob transaction_id is recorded exactly once, even when the
-- user has already reached the daily cap.

CREATE TABLE IF NOT EXISTS ad_reward_ssv_ledger (
  transaction_id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reward_date DATE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('granted', 'limit_reached')),
  tokens_granted INTEGER NOT NULL DEFAULT 0,
  ad_unit TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE ad_reward_ssv_ledger ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ad_reward_ssv_ledger_service_all" ON ad_reward_ssv_ledger;
CREATE POLICY "ad_reward_ssv_ledger_service_all" ON ad_reward_ssv_ledger
  FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_ad_reward_ssv_ledger_user_date
  ON ad_reward_ssv_ledger (user_id, reward_date);

CREATE INDEX IF NOT EXISTS idx_ad_reward_log_ssv_signature
  ON ad_reward_log (ssv_signature)
  WHERE ssv_signature IS NOT NULL;

CREATE OR REPLACE FUNCTION grant_ad_reward_atomic(
  p_user_id UUID,
  p_ad_unit TEXT,
  p_transaction_id TEXT,
  p_tokens INTEGER DEFAULT 1,
  p_daily_limit INTEGER DEFAULT 5
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $grant_ad_reward_atomic$
DECLARE
  v_today DATE := (now() AT TIME ZONE 'Asia/Seoul')::date;
  v_used_today INTEGER := 0;
  v_balance INTEGER := 0;
  v_total_earned INTEGER := 0;
  v_total_spent INTEGER := 0;
  v_new_balance INTEGER := 0;
  v_transaction_id TEXT := btrim(p_transaction_id);
  v_existing_status TEXT;
  v_existing_tokens INTEGER := 0;
  v_existing_user_id UUID;
BEGIN
  IF p_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'missing user id',
      'errorCode', 'unauthorized'
    );
  END IF;

  IF v_transaction_id IS NULL OR v_transaction_id = '' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'missing AdMob transaction id',
      'errorCode', 'missing_transaction'
    );
  END IF;

  IF p_tokens IS NULL OR p_daily_limit IS NULL OR p_tokens <= 0 OR p_daily_limit <= 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'invalid reward configuration',
      'errorCode', 'invalid_configuration'
    );
  END IF;

  -- Serialize the same AdMob transaction across all users before checking or
  -- writing its ledger row.
  PERFORM pg_advisory_xact_lock(hashtextextended(v_transaction_id, 0));

  SELECT status, tokens_granted, user_id
    INTO v_existing_status, v_existing_tokens, v_existing_user_id
    FROM public.ad_reward_ssv_ledger
   WHERE transaction_id = v_transaction_id;

  IF FOUND THEN
    IF v_existing_user_id IS DISTINCT FROM p_user_id THEN
      RETURN jsonb_build_object(
        'success', false,
        'tokensGranted', 0,
        'error', 'AdMob transaction belongs to a different user',
        'errorCode', 'unauthorized',
        'duplicate', true,
        'duplicateStatus', v_existing_status
      );
    END IF;

    SELECT COALESCE(balance, 0)
      INTO v_balance
      FROM public.token_balance
     WHERE user_id = p_user_id;

    SELECT COUNT(*)
      INTO v_used_today
      FROM public.ad_reward_ssv_ledger
     WHERE user_id = p_user_id
       AND reward_date = v_today
       AND status = 'granted';

    RETURN jsonb_build_object(
      'success', true,
      'tokensGranted', 0,
      'newBalance', COALESCE(v_balance, 0),
      'remainingToday', GREATEST(0, p_daily_limit - COALESCE(v_used_today, 0)),
      'duplicate', true,
      'duplicateStatus', v_existing_status,
      'originalTokensGranted', COALESCE(v_existing_tokens, 0)
    );
  END IF;

  INSERT INTO public.token_balance (user_id, balance, total_earned, total_spent, updated_at)
  VALUES (p_user_id, 0, 0, 0, NOW())
  ON CONFLICT (user_id) DO NOTHING;

  SELECT COALESCE(balance, 0), COALESCE(total_earned, 0), COALESCE(total_spent, 0)
    INTO v_balance, v_total_earned, v_total_spent
    FROM public.token_balance
   WHERE user_id = p_user_id
   FOR UPDATE;

  SELECT COUNT(*)
    INTO v_used_today
    FROM public.ad_reward_ssv_ledger
   WHERE user_id = p_user_id
     AND reward_date = v_today
     AND status = 'granted';

  IF v_used_today >= p_daily_limit THEN
    INSERT INTO public.ad_reward_ssv_ledger (
      transaction_id,
      user_id,
      reward_date,
      status,
      tokens_granted,
      ad_unit
    ) VALUES (
      v_transaction_id,
      p_user_id,
      v_today,
      'limit_reached',
      0,
      p_ad_unit
    );

    RETURN jsonb_build_object(
      'success', false,
      'error', '오늘 광고 시청 한도에 도달했어요',
      'errorCode', 'limit_reached',
      'remainingToday', 0
    );
  END IF;

  v_new_balance := v_balance + p_tokens;

  UPDATE public.token_balance
     SET balance = v_new_balance,
         total_earned = v_total_earned + p_tokens,
         total_spent = v_total_spent,
         updated_at = NOW()
   WHERE user_id = p_user_id;

  INSERT INTO public.token_transactions (
    user_id,
    transaction_type,
    amount,
    balance_after,
    description,
    reference_type,
    reference_id,
    idempotency_key
  ) VALUES (
    p_user_id,
    'earn',
    p_tokens,
    v_new_balance,
    '광고 시청 보상',
    'ad_reward',
    v_transaction_id,
    'ad_reward:' || v_transaction_id
  );

  INSERT INTO public.ad_reward_log (
    user_id,
    reward_date,
    tokens_granted,
    ad_unit,
    ssv_signature
  ) VALUES (
    p_user_id,
    v_today,
    p_tokens,
    p_ad_unit,
    v_transaction_id
  );

  INSERT INTO public.ad_reward_ssv_ledger (
    transaction_id,
    user_id,
    reward_date,
    status,
    tokens_granted,
    ad_unit
  ) VALUES (
    v_transaction_id,
    p_user_id,
    v_today,
    'granted',
    p_tokens,
    p_ad_unit
  );

  RETURN jsonb_build_object(
    'success', true,
    'tokensGranted', p_tokens,
    'newBalance', v_new_balance,
    'remainingToday', GREATEST(0, p_daily_limit - v_used_today - 1)
  );
EXCEPTION
  WHEN foreign_key_violation THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'unknown user id',
      'errorCode', 'unauthorized'
    );
END;
$grant_ad_reward_atomic$;

