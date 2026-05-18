-- App Store / Google Play purchase token grant hardening.
--
-- Fixes:
-- 1) A store transaction can be credited only once globally, not once per app user.
-- 2) Token balance update + purchase transaction insert happen in one DB transaction.
-- 3) First-purchase bonus flag is locked/updated in the same transaction as the grant.

CREATE UNIQUE INDEX IF NOT EXISTS idx_verified_purchases_global_replay
  ON verified_purchases (platform, verified_transaction_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_token_transactions_purchase_global_unique
  ON token_transactions (reference_id)
  WHERE transaction_type = 'purchase' AND reference_id IS NOT NULL;

COMMENT ON INDEX idx_verified_purchases_global_replay IS
  'Store transaction replay 방지. 같은 Apple/Google transaction id 는 앱 계정 전체에서 1회만 검증 row 로 인정.';

COMMENT ON INDEX idx_token_transactions_purchase_global_unique IS
  'Store transaction token grant replay 방지. 같은 Apple/Google transaction id 는 앱 계정 전체에서 1회만 토큰 지급.';

CREATE OR REPLACE FUNCTION grant_purchase_tokens_atomic(
  p_user_id UUID,
  p_base_amount INTEGER,
  p_description TEXT,
  p_reference_type TEXT,
  p_reference_id TEXT,
  p_idempotency_key TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_existing_purchase_id UUID;
  v_existing_purchase_user_id UUID;
  v_balance INTEGER;
  v_total_earned INTEGER;
  v_total_spent INTEGER;
  v_bonus_granted BOOLEAN;
  v_bonus_amount INTEGER := 0;
  v_actual_amount INTEGER;
  v_new_balance INTEGER;
  v_new_total_earned INTEGER;
  v_new_purchase_id UUID;
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'MISSING_USER_ID'
      USING ERRCODE = '22023';
  END IF;

  IF p_base_amount IS NULL OR p_base_amount <= 0 THEN
    RAISE EXCEPTION 'INVALID_PURCHASE_AMOUNT'
      USING ERRCODE = '22023', DETAIL = format('amount=%s', p_base_amount);
  END IF;

  IF p_reference_id IS NULL OR length(trim(p_reference_id)) = 0 THEN
    RAISE EXCEPTION 'MISSING_PURCHASE_REFERENCE'
      USING ERRCODE = '22023';
  END IF;

  SELECT id, user_id
    INTO v_existing_purchase_id, v_existing_purchase_user_id
    FROM token_transactions
   WHERE transaction_type = 'purchase'
     AND reference_id = p_reference_id
   ORDER BY created_at DESC
   LIMIT 1;

  IF FOUND THEN
    SELECT balance, total_earned, total_spent
      INTO v_balance, v_total_earned, v_total_spent
      FROM token_balance
     WHERE user_id = p_user_id;

    RETURN jsonb_build_object(
      'balance', COALESCE(v_balance, 0),
      'total_earned', COALESCE(v_total_earned, 0),
      'total_spent', COALESCE(v_total_spent, 0),
      'granted', false,
      'replayed', true,
      'owned_by_current_user', v_existing_purchase_user_id = p_user_id,
      'purchase_transaction_id', v_existing_purchase_id::TEXT,
      'base_tokens', p_base_amount,
      'bonus_tokens', 0,
      'tokens_added', 0,
      'is_first_purchase', false
    );
  END IF;

  SELECT first_purchase_bonus_granted
    INTO v_bonus_granted
    FROM user_profiles
   WHERE id = p_user_id
   FOR UPDATE;

  IF FOUND AND COALESCE(v_bonus_granted, false) = false THEN
    v_bonus_amount := floor(p_base_amount * 0.5)::INTEGER;
    UPDATE user_profiles
       SET first_purchase_bonus_granted = true,
           updated_at = now()
     WHERE id = p_user_id;
  END IF;

  v_actual_amount := p_base_amount + v_bonus_amount;

  SELECT balance, total_earned, total_spent
    INTO v_balance, v_total_earned, v_total_spent
    FROM token_balance
   WHERE user_id = p_user_id
   FOR UPDATE;

  IF NOT FOUND THEN
    v_new_balance := v_actual_amount;
    v_new_total_earned := v_actual_amount;
    v_total_spent := 0;

    INSERT INTO token_balance (user_id, balance, total_earned, total_spent, updated_at)
      VALUES (p_user_id, v_new_balance, v_new_total_earned, 0, now());
  ELSE
    v_new_balance := COALESCE(v_balance, 0) + v_actual_amount;
    v_new_total_earned := COALESCE(v_total_earned, 0) + v_actual_amount;

    UPDATE token_balance
       SET balance = v_new_balance,
           total_earned = v_new_total_earned,
           updated_at = now()
     WHERE user_id = p_user_id;
  END IF;

  INSERT INTO token_transactions (
    user_id, transaction_type, amount, balance_after,
    description, reference_type, reference_id, idempotency_key
  ) VALUES (
    p_user_id, 'purchase', v_actual_amount, v_new_balance,
    p_description, p_reference_type, p_reference_id,
    COALESCE(p_idempotency_key, 'purchase:' || p_reference_id)
  )
  RETURNING id INTO v_new_purchase_id;

  UPDATE verified_purchases
     SET consumed_for_token_grant = true
   WHERE user_id = p_user_id
     AND verified_transaction_id = p_reference_id;

  RETURN jsonb_build_object(
    'balance', v_new_balance,
    'total_earned', v_new_total_earned,
    'total_spent', COALESCE(v_total_spent, 0),
    'granted', true,
    'replayed', false,
    'owned_by_current_user', true,
    'purchase_transaction_id', v_new_purchase_id::TEXT,
    'base_tokens', p_base_amount,
    'bonus_tokens', v_bonus_amount,
    'tokens_added', v_actual_amount,
    'is_first_purchase', v_bonus_amount > 0
  );
END;
$function$;

