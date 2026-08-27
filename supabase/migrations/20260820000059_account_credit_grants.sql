-- Web account credit policy: 5 Ondo at account creation, then 45 exactly once
-- after the account is non-anonymous (direct Google signup or anonymous -> Google link).
--
-- Existing users already passed through the legacy 30/50-token trigger. They are
-- backfilled as completed without mutating balances, so this migration cannot add
-- another 45 to production-era accounts.

CREATE TABLE IF NOT EXISTS public.account_credit_grants (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  initial_amount INTEGER NOT NULL CHECK (initial_amount >= 0),
  initial_granted_at TIMESTAMPTZ NOT NULL,
  upgrade_amount INTEGER NOT NULL CHECK (upgrade_amount >= 0),
  upgrade_granted_at TIMESTAMPTZ,
  legacy_backfilled BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.account_credit_grants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own account credit grants"
  ON public.account_credit_grants;
CREATE POLICY "Users can view own account credit grants"
  ON public.account_credit_grants
  FOR SELECT
  USING (user_id = auth.uid());

REVOKE ALL ON TABLE public.account_credit_grants FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.account_credit_grants TO authenticated;
GRANT ALL ON TABLE public.account_credit_grants TO service_role;

-- Existing balances are historical truth. Do not infer their original signup grant
-- from total_earned because that aggregate may also include purchases and rewards.
INSERT INTO public.account_credit_grants (
  user_id,
  initial_amount,
  initial_granted_at,
  upgrade_amount,
  upgrade_granted_at,
  legacy_backfilled,
  created_at,
  updated_at
)
SELECT
  u.id,
  0,
  u.created_at,
  0,
  NOW(),
  TRUE,
  NOW(),
  NOW()
FROM auth.users AS u
ON CONFLICT (user_id) DO NOTHING;

CREATE OR REPLACE FUNCTION public.grant_initial_tokens()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_initial_tokens CONSTANT INTEGER := 5;
  v_balance INTEGER;
BEGIN
  INSERT INTO public.account_credit_grants (
    user_id,
    initial_amount,
    initial_granted_at,
    upgrade_amount,
    legacy_backfilled,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    v_initial_tokens,
    NOW(),
    45,
    FALSE,
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO public.token_balance (
    user_id,
    balance,
    total_earned,
    total_spent,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    v_initial_tokens,
    v_initial_tokens,
    0,
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO NOTHING
  RETURNING balance INTO v_balance;

  IF v_balance IS NULL THEN
    SELECT balance
      INTO v_balance
      FROM public.token_balance
     WHERE user_id = NEW.id;
  END IF;

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
    NEW.id,
    'earn',
    v_initial_tokens,
    v_balance,
    '계정 생성 온도',
    'bonus',
    'account_initial',
    'account-initial:' || NEW.id::TEXT
  )
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.grant_initial_tokens()
  FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.claim_account_upgrade_bonus()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_is_anonymous BOOLEAN;
  v_upgrade_granted_at TIMESTAMPTZ;
  v_bonus INTEGER;
  v_balance INTEGER;
  v_total_earned INTEGER;
  v_total_spent INTEGER;
  v_transaction_id UUID;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHENTICATED' USING ERRCODE = '28000';
  END IF;

  SELECT COALESCE(u.is_anonymous, TRUE)
    INTO v_is_anonymous
    FROM auth.users AS u
   WHERE u.id = v_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'USER_NOT_FOUND' USING ERRCODE = 'P0002';
  END IF;

  SELECT g.upgrade_granted_at, g.upgrade_amount
    INTO v_upgrade_granted_at, v_bonus
    FROM public.account_credit_grants AS g
   WHERE g.user_id = v_user_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ACCOUNT_CREDIT_STATE_MISSING' USING ERRCODE = 'P0002';
  END IF;

  IF v_upgrade_granted_at IS NOT NULL THEN
    SELECT balance, total_earned, total_spent
      INTO v_balance, v_total_earned, v_total_spent
      FROM public.token_balance
     WHERE user_id = v_user_id;

    RETURN jsonb_build_object(
      'granted', FALSE,
      'reason', 'ALREADY_GRANTED',
      'balance', COALESCE(v_balance, 0),
      'total_earned', COALESCE(v_total_earned, 0),
      'total_spent', COALESCE(v_total_spent, 0)
    );
  END IF;

  IF v_is_anonymous THEN
    SELECT balance, total_earned, total_spent
      INTO v_balance, v_total_earned, v_total_spent
      FROM public.token_balance
     WHERE user_id = v_user_id;

    RETURN jsonb_build_object(
      'granted', FALSE,
      'reason', 'ANONYMOUS_USER',
      'balance', COALESCE(v_balance, 0),
      'total_earned', COALESCE(v_total_earned, 0),
      'total_spent', COALESCE(v_total_spent, 0)
    );
  END IF;

  UPDATE public.account_credit_grants
     SET upgrade_granted_at = NOW(),
         updated_at = NOW()
   WHERE user_id = v_user_id
     AND upgrade_granted_at IS NULL;

  INSERT INTO public.token_balance (
    user_id,
    balance,
    total_earned,
    total_spent,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    v_bonus,
    v_bonus,
    0,
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE
     SET balance = public.token_balance.balance + EXCLUDED.balance,
         total_earned = public.token_balance.total_earned + EXCLUDED.total_earned,
         updated_at = NOW()
  RETURNING balance, total_earned, total_spent
       INTO v_balance, v_total_earned, v_total_spent;

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
    v_user_id,
    'earn',
    v_bonus,
    v_balance,
    'Google 계정 전환 온도',
    'bonus',
    'account_upgrade',
    'account-upgrade:' || v_user_id::TEXT
  )
  RETURNING id INTO v_transaction_id;

  RETURN jsonb_build_object(
    'granted', TRUE,
    'bonus', v_bonus,
    'balance', v_balance,
    'total_earned', v_total_earned,
    'total_spent', COALESCE(v_total_spent, 0),
    'transaction_id', v_transaction_id
  );
END;
$$;

REVOKE ALL ON FUNCTION public.claim_account_upgrade_bonus()
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.claim_account_upgrade_bonus()
  TO authenticated, service_role;

COMMENT ON TABLE public.account_credit_grants IS
  '계정 생성 5온도와 비익명 전환 45온도의 정확히 한 번 지급 상태. legacy_backfilled 행은 기존 잔액을 변경하지 않는다.';
COMMENT ON FUNCTION public.grant_initial_tokens() IS
  '신규 auth.users 계정에 5온도와 account-initial 원장 행을 원자적으로 생성한다.';
COMMENT ON FUNCTION public.claim_account_upgrade_bonus() IS
  'auth.uid()의 비익명 전환 보너스 45온도를 row lock과 원장으로 정확히 한 번 지급한다.';
