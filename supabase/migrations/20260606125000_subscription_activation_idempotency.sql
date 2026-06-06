-- Subscription activation + monthly token grant idempotency.
--
-- For subscriptions, payment-verify-purchase records Apple/Google verification only.
-- This RPC consumes that verified transaction exactly once and, in the same DB
-- transaction, creates/repairs the entitlement row and grants the monthly token
-- allowance. It prevents partial states such as "tokens granted but subscription
-- activation failed" and races where a retry expires the just-created row.

CREATE INDEX IF NOT EXISTS idx_subscriptions_platform_purchase_id
  ON subscriptions (platform, purchase_id)
  WHERE purchase_id IS NOT NULL;

COMMENT ON INDEX idx_subscriptions_platform_purchase_id IS
  'Subscription activation replay 조회용. 신규 중복 방지는 activate_subscription_purchase_atomic row lock으로 처리한다.';

CREATE OR REPLACE FUNCTION activate_subscription_purchase_atomic(
  p_user_id UUID,
  p_product_id TEXT,
  p_platform TEXT,
  p_purchase_id TEXT,
  p_duration_days INTEGER,
  p_monthly_tokens INTEGER,
  p_ip_address TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $activate_subscription_purchase_atomic$
DECLARE
  v_vp_id UUID;
  v_verified_product_id TEXT;
  v_consumed_for_subscription BOOLEAN;
  v_consumed_for_token_grant BOOLEAN;
  v_existing_subscription_id UUID;
  v_existing_subscription_status TEXT;
  v_subscription_id UUID;
  v_expires_at TIMESTAMPTZ;
  v_balance INTEGER;
  v_total_earned INTEGER;
  v_total_spent INTEGER;
  v_new_balance INTEGER;
  v_new_total_earned INTEGER;
  v_purchase_txn_id UUID;
  v_token_granted BOOLEAN := false;
  v_replayed BOOLEAN := false;
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'MISSING_USER_ID' USING ERRCODE = '22023';
  END IF;
  IF p_product_id IS NULL OR length(trim(p_product_id)) = 0 THEN
    RAISE EXCEPTION 'MISSING_PRODUCT_ID' USING ERRCODE = '22023';
  END IF;
  IF p_platform IS NULL OR length(trim(p_platform)) = 0 THEN
    RAISE EXCEPTION 'MISSING_PLATFORM' USING ERRCODE = '22023';
  END IF;
  IF p_purchase_id IS NULL OR length(trim(p_purchase_id)) = 0 THEN
    RAISE EXCEPTION 'MISSING_PURCHASE_ID' USING ERRCODE = '22023';
  END IF;
  IF p_duration_days IS NULL OR p_duration_days <= 0 THEN
    RAISE EXCEPTION 'INVALID_DURATION_DAYS' USING ERRCODE = '22023';
  END IF;
  IF p_monthly_tokens IS NULL OR p_monthly_tokens < 0 THEN
    RAISE EXCEPTION 'INVALID_MONTHLY_TOKENS' USING ERRCODE = '22023';
  END IF;

  SELECT id, verified_product_id, consumed_for_subscription, consumed_for_token_grant
    INTO v_vp_id, v_verified_product_id, v_consumed_for_subscription, v_consumed_for_token_grant
    FROM verified_purchases
   WHERE user_id = p_user_id
     AND platform = p_platform
     AND verified_transaction_id = p_purchase_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'VERIFIED_PURCHASE_NOT_FOUND'
      USING ERRCODE = 'P0002', DETAIL = format('user=%s platform=%s purchase=%s', p_user_id, p_platform, p_purchase_id);
  END IF;

  IF v_verified_product_id IS DISTINCT FROM p_product_id THEN
    RAISE EXCEPTION 'VERIFIED_PRODUCT_MISMATCH'
      USING ERRCODE = 'P0001', DETAIL = format('verified=%s requested=%s', v_verified_product_id, p_product_id);
  END IF;

  SELECT id, status, expires_at
    INTO v_existing_subscription_id, v_existing_subscription_status, v_expires_at
    FROM subscriptions
   WHERE user_id = p_user_id
     AND platform = p_platform
     AND purchase_id = p_purchase_id
   ORDER BY created_at DESC
   LIMIT 1
   FOR UPDATE;

  IF v_consumed_for_subscription THEN
    IF v_existing_subscription_id IS NOT NULL THEN
      IF v_expires_at <= now() OR v_existing_subscription_status <> 'active' THEN
        v_expires_at := GREATEST(v_expires_at, now() + (p_duration_days || ' days')::interval);
        UPDATE subscriptions
           SET status = 'active',
               product_id = p_product_id,
               expires_at = v_expires_at,
               auto_renewing = true,
               updated_at = now()
         WHERE id = v_existing_subscription_id;
      END IF;

      RETURN jsonb_build_object(
        'success', true,
        'replayed', true,
        'subscriptionId', v_existing_subscription_id::TEXT,
        'expiresAt', v_expires_at,
        'productId', p_product_id,
        'tokensAdded', 0,
        'tokenGranted', false
      );
    END IF;

    RAISE EXCEPTION 'SUBSCRIPTION_CONSUMED_WITHOUT_ROW'
      USING ERRCODE = 'P0002', DETAIL = format('verified_purchase=%s', v_vp_id);
  END IF;

  v_expires_at := now() + (p_duration_days || ' days')::interval;

  IF v_existing_subscription_id IS NULL THEN
    UPDATE subscriptions
       SET status = 'expired',
           updated_at = now()
     WHERE user_id = p_user_id
       AND status = 'active'
       AND NOT (platform = p_platform AND purchase_id = p_purchase_id);

    INSERT INTO subscriptions (
      user_id,
      product_id,
      platform,
      purchase_id,
      status,
      started_at,
      expires_at,
      auto_renewing
    ) VALUES (
      p_user_id,
      p_product_id,
      p_platform,
      p_purchase_id,
      'active',
      now(),
      v_expires_at,
      true
    )
    RETURNING id INTO v_subscription_id;
  ELSE
    v_subscription_id := v_existing_subscription_id;
    UPDATE subscriptions
       SET product_id = p_product_id,
           status = 'active',
           expires_at = GREATEST(expires_at, v_expires_at),
           auto_renewing = true,
           updated_at = now()
     WHERE id = v_subscription_id
     RETURNING expires_at INTO v_expires_at;
  END IF;

  SELECT id
    INTO v_purchase_txn_id
    FROM token_transactions
   WHERE transaction_type = 'purchase'
     AND reference_id = p_purchase_id
   LIMIT 1
   FOR UPDATE;

  IF p_monthly_tokens > 0 AND v_purchase_txn_id IS NULL AND NOT COALESCE(v_consumed_for_token_grant, false) THEN
    SELECT balance, total_earned, total_spent
      INTO v_balance, v_total_earned, v_total_spent
      FROM token_balance
     WHERE user_id = p_user_id
     FOR UPDATE;

    IF NOT FOUND THEN
      v_new_balance := p_monthly_tokens;
      v_new_total_earned := p_monthly_tokens;
      v_total_spent := 0;
      INSERT INTO token_balance (user_id, balance, total_earned, total_spent, updated_at)
        VALUES (p_user_id, v_new_balance, v_new_total_earned, 0, now());
    ELSE
      v_new_balance := COALESCE(v_balance, 0) + p_monthly_tokens;
      v_new_total_earned := COALESCE(v_total_earned, 0) + p_monthly_tokens;
      UPDATE token_balance
         SET balance = v_new_balance,
             total_earned = v_new_total_earned,
             updated_at = now()
       WHERE user_id = p_user_id;
    END IF;

    INSERT INTO token_transactions (
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
      'purchase',
      p_monthly_tokens,
      v_new_balance,
      format('구독 월 토큰 %s개 자동충전', p_monthly_tokens),
      'subscription_renewal',
      p_purchase_id,
      format('subscription:%s:%s', p_platform, p_purchase_id)
    )
    RETURNING id INTO v_purchase_txn_id;

    v_token_granted := true;
  END IF;

  UPDATE verified_purchases
     SET consumed_for_subscription = true,
         consumed_for_token_grant = true
   WHERE id = v_vp_id;

  INSERT INTO subscription_events (
    user_id,
    subscription_id,
    event_type,
    product_id,
    platform,
    purchase_id,
    ip_address,
    metadata
  ) VALUES (
    p_user_id,
    v_subscription_id,
    CASE WHEN v_replayed THEN 'renewed' ELSE 'activated' END,
    p_product_id,
    p_platform,
    p_purchase_id,
    COALESCE(p_ip_address, 'unknown'),
    jsonb_build_object(
      'activated_at', now(),
      'expires_at', v_expires_at,
      'monthly_tokens', p_monthly_tokens,
      'tokens_added', CASE WHEN v_token_granted THEN p_monthly_tokens ELSE 0 END,
      'token_transaction_id', v_purchase_txn_id::TEXT,
      'grant_source', 'subscription-activate-rpc'
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'replayed', false,
    'subscriptionId', v_subscription_id::TEXT,
    'expiresAt', v_expires_at,
    'productId', p_product_id,
    'tokensAdded', CASE WHEN v_token_granted THEN p_monthly_tokens ELSE 0 END,
    'tokenGranted', v_token_granted
  );
END;
$activate_subscription_purchase_atomic$;

