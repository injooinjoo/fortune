-- P0: activate_subscription_purchase_atomic 의 결함 2건.
--
-- (1) 한 번의 결제로 구독을 영구 갱신할 수 있다.
--     subscription-activate/index.ts:70 은 {productId, purchaseId, platform} + JWT 만 받고
--     영수증을 재검증하지 않는다 — verified_purchases 행의 존재에만 의존한다.
--     그런데 replay 분기(v_consumed_for_subscription = true)가
--       IF v_expires_at <= now() OR status <> 'active' THEN
--         v_expires_at := GREATEST(v_expires_at, now() + p_duration_days)
--         UPDATE subscriptions SET status='active', expires_at=...
--     로 기간을 연장한다. verified_purchases_self_read 정책이 본인
--     verified_transaction_id 읽기를 허용하므로: 구독 → 해지 → 만료 후 같은 purchaseId
--     재전송 = 결제 없이 한 주기 추가. 무한 반복 가능.
--     → replay 는 기존 행을 변경 없이 반환한다. 기간 연장은 새 verified transaction 으로만.
--
-- (2) 다른 채널의 살아있는 구독을 조용히 expired 로 만든다.
--       UPDATE subscriptions SET status='expired'
--        WHERE user_id=... AND status='active'
--          AND NOT (platform=p_platform AND purchase_id=p_purchase_id)
--     Apple 구독 중인 사용자가 웹/안드로이드에서 결제하면 Apple 은 계속 청구하는데
--     우리 DB 의 Apple 행만 만료된다 = 이중 과금 민원.
--     → 다른 platform 의 유효한 활성 구독이 있으면 만료시키지 않고 거절한다.
--       만료 UPDATE 는 같은 platform 안으로만 좁힌다.
--
-- 술어에 `expires_at > now()` 를 반드시 넣는다: expire_old_subscriptions() 가
-- 한 번도 cron.schedule 된 적이 없어(20260818000500 에서 해결) status 는 만료일이
-- 지나도 영구히 'active' 다. status 만 보면 몇 달 전 끊긴 Apple 구독 때문에
-- 정상 결제가 거절된다.
--
-- 본문은 라이브 pg_get_functiondef 를 그대로 옮기고 위 두 지점만 수정했다.

CREATE OR REPLACE FUNCTION public.activate_subscription_purchase_atomic(
  p_user_id UUID,
  p_product_id TEXT,
  p_platform TEXT,
  p_purchase_id TEXT,
  p_duration_days INTEGER,
  p_monthly_tokens INTEGER,
  p_ip_address TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_vp_id UUID;
  v_verified_product_id TEXT;
  v_consumed_for_subscription BOOLEAN;
  v_consumed_for_token_grant BOOLEAN;
  v_existing_subscription_id UUID;
  v_existing_subscription_status TEXT;
  v_subscription_id UUID;
  v_expires_at TIMESTAMPTZ;
  v_cross_platform TEXT;
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
      -- (1) 수정: 이미 이 결제로 소비된 구독이다. 기간을 절대 연장하지 않는다.
      -- 연장은 새로운 verified transaction id 를 동반한 호출로만 일어난다.
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
    -- (2) 수정: 다른 채널에 유효한 활성 구독이 있으면 조용히 만료시키지 않고 거절한다.
    -- 우리는 Apple/Google 구독을 대신 해지할 수 없으므로, 사용자가 먼저 해지해야 한다.
    SELECT platform
      INTO v_cross_platform
      FROM subscriptions
     WHERE user_id = p_user_id
       AND status = 'active'
       AND expires_at > now()
       AND platform <> p_platform
     ORDER BY expires_at DESC
     LIMIT 1;

    IF FOUND THEN
      RAISE EXCEPTION 'CROSS_PLATFORM_SUBSCRIPTION_ACTIVE'
        USING ERRCODE = 'P0001',
              DETAIL = format('user=%s active_platform=%s requested_platform=%s',
                              p_user_id, v_cross_platform, p_platform);
    END IF;

    -- 같은 채널 안의 이전 구독만 만료 처리한다.
    UPDATE subscriptions
       SET status = 'expired',
           updated_at = now()
     WHERE user_id = p_user_id
       AND status = 'active'
       AND platform = p_platform
       AND purchase_id IS DISTINCT FROM p_purchase_id;

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
$$;

-- CREATE OR REPLACE 는 ACL 을 보존하지만, 20260606143020 의 회수를 명시적으로 재적용한다.
REVOKE ALL ON FUNCTION public.activate_subscription_purchase_atomic(UUID, TEXT, TEXT, TEXT, INTEGER, INTEGER, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.activate_subscription_purchase_atomic(UUID, TEXT, TEXT, TEXT, INTEGER, INTEGER, TEXT)
  TO service_role;
