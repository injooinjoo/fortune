-- ============================================================================
-- Ondo P0 마이그레이션 통합본 (8개)
--
-- supabase CLI 의 db push 가 20260818000200 에서
--   ERROR: cannot insert multiple commands into a prepared statement (42601)
-- 로 멈춘다. CLI 의 statement 분할 문제이며 SQL 자체는 정상이므로,
-- Supabase 대시보드 SQL Editor 에 이 파일을 통째로 붙여넣어 실행한다.
--
--   https://supabase.com/dashboard/project/hayjukwfcsdmppairazc/sql/new
--
-- 마지막에 supabase_migrations.schema_migrations 에 버전을 기록하므로
-- 이후 db push 가 이 8개를 다시 적용하려 하지 않는다.
-- 20260818000100 은 이미 적용됨 (CLI 로 성공).
-- ============================================================================


-- ==== 20260818000200_revoke_money_rpc_execute.sql =====================
-- P0 보안: SECURITY DEFINER 금전 RPC 가 anon / authenticated 에게 열려 있다.
--
-- 라이브 ACL 실측 (2026-08-18, pg_proc.proacl + has_function_privilege):
--   grant_purchase_tokens_atomic   anon=X authenticated=X   ← 토큰 무한 발행
--   consume_token_atomic           anon=X authenticated=X
--   refund_token_atomic            anon=X authenticated=X   ← 환불 파밍
--   consume_chat_streak            anon=X authenticated=X
--   expire_old_subscriptions       anon=X authenticated=X
--   grant_initial_tokens           anon=X authenticated=X
--
-- 2026-06 하드닝 스윕(20260606143001/143020/143040/143060)은 grant_ad_reward_atomic,
-- activate_subscription_purchase_atomic, schedule_poster_job_with_charge,
-- claim_next_poster_job 네 개만 잠갔다. 20260606143000_harden_atomic_rpc_execute_grants.sql
-- 은 내용이 `SELECT 1` 한 줄뿐이라 아무것도 하지 않았다.
--
-- grant_purchase_tokens_atomic 이 특히 위험하다 — SECURITY DEFINER 이고 p_user_id 와
-- p_base_amount 를 인자로 받으며 auth.uid() 검사가 없다. anon key 만으로
-- POST /rest/v1/rpc/grant_purchase_tokens_atomic 을 호출해 임의 수량을 발행할 수 있고
-- 50% 첫구매 보너스까지 얹힌다. anon key 는 앱 번들에 이미 실려 있고, 웹을 열면
-- 브라우저 devtools 로 즉시 접근 가능해진다.
--
-- 호출부 확인 — 아래 6개 함수는 전부 service_role 클라이언트에서만 호출된다:
--   grant_purchase_tokens_atomic : payment-verify-purchase (SERVICE_ROLE_KEY)
--   consume_token_atomic         : soul-consume, _shared/token_charge.ts(character-chat /
--                                  generate-friend-avatar / generate-character-proactive-image,
--                                  전부 SERVICE_ROLE_KEY), fortune-tarot(supabaseAdmin)
--   refund_token_atomic          : soul-refund, _shared/token_charge.ts, process-poster-jobs
--   consume_chat_streak          : character-chat (SERVICE_ROLE_KEY)
--   expire_old_subscriptions     : 호출부 없음 (cron 전용, 20260818000500 에서 스케줄)
--   grant_initial_tokens         : auth.users AFTER INSERT 트리거 전용
--
-- 아래 2개는 클라이언트가 authenticated 로 직접 호출하므로 authenticated 를 유지한다:
--   merge_character_conversation_messages : character-conversation-save 가 anon key +
--     호출자 Authorization 으로 호출 → authenticated 롤로 실행된다. 함수 본문에 이미
--     `auth.role()='authenticated' AND auth.uid() <> p_user_id → 42501` 가드가 있어
--     타인 대화 덮어쓰기는 막혀 있다. anon 만 회수한다.
--   enqueue_pending_reply_job : RN 클라이언트가 직접 호출
--     (chat-screen.tsx:3674, story-chat-runtime.ts:1279). anon 만 회수한다.

-- ── 완전 잠금 (service_role 전용) ────────────────────────────────────────────

REVOKE ALL ON FUNCTION public.grant_purchase_tokens_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.grant_purchase_tokens_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  TO service_role;

REVOKE ALL ON FUNCTION public.consume_token_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.consume_token_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  TO service_role;

REVOKE ALL ON FUNCTION public.refund_token_atomic(UUID, TEXT, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.refund_token_atomic(UUID, TEXT, TEXT, TEXT, TEXT)
  TO service_role;

REVOKE ALL ON FUNCTION public.consume_chat_streak(UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.consume_chat_streak(UUID)
  TO service_role;

REVOKE ALL ON FUNCTION public.expire_old_subscriptions()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.expire_old_subscriptions()
  TO service_role;

REVOKE ALL ON FUNCTION public.grant_initial_tokens()
  FROM PUBLIC, anon, authenticated;

-- ── anon 만 회수 (authenticated 는 실사용 경로가 있어 유지) ──────────────────

REVOKE ALL ON FUNCTION public.merge_character_conversation_messages(UUID, TEXT, JSONB, JSONB, INTEGER)
  FROM PUBLIC, anon;

REVOKE ALL ON FUNCTION public.enqueue_pending_reply_job(TEXT, TEXT, TEXT, TEXT, JSONB)
  FROM PUBLIC, anon;


-- ==== 20260818000300_token_rpc_replay_user_scope.sql ==================
-- P0 보안: 멱등키 replay 조회에 user_id 스코프가 없다.
--
-- consume_token_atomic / refund_token_atomic 은 idempotency_key 만으로 기존 거래를
-- 찾는다. 키 공간이 전역이므로
--   (a) 한 사용자가 고정 키를 반복 전송하면 첫 호출만 과금되고 이후는 replayed=true 로
--       무과금 통과한다 (_shared/token_charge.ts 는 replayed 를 charged:true 로 반환하고
--       모든 호출부가 !charged 만 검사한다 → LLM 은 계속 돈다).
--   (b) 다른 사용자의 키를 알아내면 그 키로 자기 요청을 무과금 통과시킬 수 있다.
--
-- 여기서는 (b) 를 원천 차단하고 (a) 를 완화한다. (a) 의 완전한 해결은
-- supabase/functions/_shared/fortune_charge.ts 가 멱등키를 서버에서 파생하고
-- replay 시 저장된 결과를 반환(LLM 재실행 없음)하는 것이며 그쪽에서 처리한다.
--
-- 본문은 라이브 pg_proc.prosrc 를 그대로 옮기고 replay SELECT 에
-- `AND user_id = p_user_id` 한 줄만 추가했다. 그 외 동작 변화 없음.

CREATE OR REPLACE FUNCTION public.consume_token_atomic(
  p_user_id UUID,
  p_cost INTEGER,
  p_description TEXT,
  p_reference_type TEXT,
  p_reference_id TEXT,
  p_idempotency_key TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_existing_id UUID;
  v_existing_balance_after INT;
  v_balance INT;
  v_total_earned INT;
  v_total_spent INT;
  v_new_balance INT;
  v_new_transaction_id UUID;
BEGIN
  IF p_cost < 0 THEN
    RAISE EXCEPTION 'INVALID_COST' USING ERRCODE = 'P0003', DETAIL = 'cost must be >= 0';
  END IF;

  IF p_idempotency_key IS NOT NULL THEN
    SELECT id, balance_after
      INTO v_existing_id, v_existing_balance_after
      FROM token_transactions
     WHERE idempotency_key = p_idempotency_key
       AND transaction_type = 'consumption'
       AND user_id = p_user_id          -- ← 추가: 타인의 키로 무과금 통과 차단
     LIMIT 1;

    IF FOUND THEN
      SELECT balance, total_earned, total_spent
        INTO v_balance, v_total_earned, v_total_spent
        FROM token_balance
       WHERE user_id = p_user_id;

      RETURN jsonb_build_object(
        'balance',       COALESCE(v_balance, v_existing_balance_after),
        'total_earned',  COALESCE(v_total_earned, 0),
        'total_spent',   COALESCE(v_total_spent, 0),
        'replayed',      true,
        'transaction_id', v_existing_id
      );
    END IF;
  END IF;

  SELECT balance, total_earned, total_spent
    INTO v_balance, v_total_earned, v_total_spent
    FROM token_balance
   WHERE user_id = p_user_id
     FOR UPDATE;

  IF NOT FOUND THEN
    IF p_cost > 0 THEN
      RAISE EXCEPTION 'INSUFFICIENT_TOKENS' USING ERRCODE = 'P0001', DETAIL = 'no balance row';
    END IF;
    INSERT INTO token_balance (user_id, balance, total_earned, total_spent, updated_at)
    VALUES (p_user_id, 0, 0, 0, NOW());
    v_balance := 0;
    v_total_earned := 0;
    v_total_spent := 0;
  END IF;

  IF v_balance < p_cost THEN
    RAISE EXCEPTION 'INSUFFICIENT_TOKENS' USING ERRCODE = 'P0001',
      DETAIL = format('have=%s, need=%s', v_balance, p_cost);
  END IF;

  v_new_balance := v_balance - p_cost;

  UPDATE token_balance
     SET balance = v_new_balance,
         total_spent = v_total_spent + p_cost,
         updated_at = NOW()
   WHERE user_id = p_user_id;

  INSERT INTO token_transactions (
    user_id, transaction_type, amount, balance_after,
    description, reference_type, reference_id, idempotency_key
  ) VALUES (
    p_user_id, 'consumption', -p_cost, v_new_balance,
    p_description, p_reference_type, p_reference_id, p_idempotency_key
  )
  RETURNING id INTO v_new_transaction_id;

  RETURN jsonb_build_object(
    'balance',        v_new_balance,
    'total_earned',   v_total_earned,
    'total_spent',    v_total_spent + p_cost,
    'replayed',       false,
    'transaction_id', v_new_transaction_id
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.refund_token_atomic(
  p_user_id UUID,
  p_consume_reference_id TEXT,
  p_description TEXT,
  p_reference_type TEXT,
  p_idempotency_key TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_consume_id UUID;
  v_consume_amount INT;
  v_existing_refund_id UUID;
  v_balance INT;
  v_total_earned INT;
  v_total_spent INT;
  v_new_balance INT;
  v_new_total_spent INT;
  v_refund_amount INT;
  v_new_refund_id UUID;
BEGIN
  IF p_consume_reference_id IS NULL OR length(p_consume_reference_id) = 0 THEN
    RAISE EXCEPTION 'MISSING_REFERENCE_ID' USING ERRCODE = 'P0004';
  END IF;

  IF p_idempotency_key IS NOT NULL THEN
    SELECT id INTO v_existing_refund_id
      FROM token_transactions
     WHERE idempotency_key = p_idempotency_key
       AND transaction_type = 'refund'
       AND user_id = p_user_id          -- ← 추가
     LIMIT 1;

    IF FOUND THEN
      SELECT balance, total_earned, total_spent
        INTO v_balance, v_total_earned, v_total_spent
        FROM token_balance
       WHERE user_id = p_user_id;

      RETURN jsonb_build_object(
        'balance',                COALESCE(v_balance, 0),
        'total_earned',           COALESCE(v_total_earned, 0),
        'total_spent',            COALESCE(v_total_spent, 0),
        'refunded',               false,
        'replayed',               true,
        'refund_transaction_id',  v_existing_refund_id
      );
    END IF;
  END IF;

  SELECT id, amount
    INTO v_consume_id, v_consume_amount
    FROM token_transactions
   WHERE user_id = p_user_id
     AND reference_id = p_consume_reference_id
     AND transaction_type = 'consumption'
   ORDER BY created_at DESC
   LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NO_MATCHING_CONSUME' USING ERRCODE = 'P0002',
      DETAIL = format('reference_id=%s', p_consume_reference_id);
  END IF;

  SELECT id INTO v_existing_refund_id
    FROM token_transactions
   WHERE user_id = p_user_id
     AND reference_id = p_consume_reference_id
     AND transaction_type = 'refund'
   LIMIT 1;

  IF FOUND THEN
    SELECT balance, total_earned, total_spent
      INTO v_balance, v_total_earned, v_total_spent
      FROM token_balance
     WHERE user_id = p_user_id;

    RETURN jsonb_build_object(
      'balance',                COALESCE(v_balance, 0),
      'total_earned',           COALESCE(v_total_earned, 0),
      'total_spent',            COALESCE(v_total_spent, 0),
      'refunded',               false,
      'replayed',               true,
      'refund_transaction_id',  v_existing_refund_id,
      'original_transaction_id', v_consume_id
    );
  END IF;

  v_refund_amount := ABS(v_consume_amount);

  SELECT balance, total_earned, total_spent
    INTO v_balance, v_total_earned, v_total_spent
    FROM token_balance
   WHERE user_id = p_user_id
     FOR UPDATE;

  IF NOT FOUND THEN
    INSERT INTO token_balance (user_id, balance, total_earned, total_spent, updated_at)
    VALUES (p_user_id, 0, 0, 0, NOW());
    v_balance := 0;
    v_total_earned := 0;
    v_total_spent := 0;
  END IF;

  v_new_balance := v_balance + v_refund_amount;
  v_new_total_spent := GREATEST(0, v_total_spent - v_refund_amount);

  UPDATE token_balance
     SET balance = v_new_balance,
         total_spent = v_new_total_spent,
         updated_at = NOW()
   WHERE user_id = p_user_id;

  INSERT INTO token_transactions (
    user_id, transaction_type, amount, balance_after,
    description, reference_type, reference_id, idempotency_key
  ) VALUES (
    p_user_id, 'refund', v_refund_amount, v_new_balance,
    p_description, p_reference_type, p_consume_reference_id, p_idempotency_key
  )
  RETURNING id INTO v_new_refund_id;

  RETURN jsonb_build_object(
    'balance',                v_new_balance,
    'total_earned',           v_total_earned,
    'total_spent',            v_new_total_spent,
    'refunded',               true,
    'replayed',               false,
    'refund_transaction_id',  v_new_refund_id,
    'original_transaction_id', v_consume_id,
    'refund_amount',          v_refund_amount
  );
END;
$$;

-- CREATE OR REPLACE 는 기존 ACL 을 보존하므로 20260818000200 의 회수를 다시 적용한다.
REVOKE ALL ON FUNCTION public.consume_token_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.consume_token_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  TO service_role;

REVOKE ALL ON FUNCTION public.refund_token_atomic(UUID, TEXT, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.refund_token_atomic(UUID, TEXT, TEXT, TEXT, TEXT)
  TO service_role;


-- ==== 20260818000400_subscription_replay_and_cross_platform_guard.sql =
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


-- ==== 20260818000500_schedule_expire_old_subscriptions.sql ============
-- expire_old_subscriptions() 는 20251203100001 에서 정의만 되고 한 번도
-- cron.schedule 된 적이 없다. 그래서 subscriptions.status 는 expires_at 이 지나도
-- 영구히 'active' 로 남는다.
--
-- 지금까지는 모든 reader 가 `.gt('expires_at', now())` 로 보정하고 있어 드러나지
-- 않았지만(premium-remote.ts:164, subscription-status 등), 20260818000400 의
-- 크로스채널 가드가 status 기반 판정을 하게 되므로 스케줄링이 선행돼야 한다.
-- 가드 술어에도 expires_at > now() 를 넣어 이중으로 방어했지만, status 가 실제
-- 상태를 반영하도록 만드는 것이 근본 수정이다.
--
-- 웹 PG 정기결제의 dunning 설계도 status 전환에 의존하므로 여기서 확정한다.
-- (plans/web-first-pivot.md §7.3 subscription-web-renew)

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 기존 잡 제거 (재배포 시 중복 방지)
DO $$
BEGIN
  PERFORM cron.unschedule('expire-old-subscriptions-hourly');
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END $$;

-- 매시 정각. DB 내부 함수라 net.http_post 가 필요 없다.
SELECT cron.schedule(
  'expire-old-subscriptions-hourly',
  '0 * * * *',
  $$
  SELECT public.expire_old_subscriptions();
  $$
);

COMMENT ON FUNCTION public.expire_old_subscriptions() IS
  'expires_at 이 지난 active 구독을 expired 로 전환. cron: expire-old-subscriptions-hourly (매시 정각).';


-- ==== 20260818000600_profile_completion_bonus_atomic.sql ==============
-- profile-completion-bonus 의 레이스 수정.
--
-- 현행 supabase/functions/profile-completion-bonus/index.ts 는 4개의 독립 문장으로
-- 보너스를 지급한다:
--   1) token_balance SELECT (balance, total_earned, total_spent)
--   2) token_balance UPSERT — **절대값**으로 balance = 읽은값 + 5 를 쓴다
--   3) user_profiles UPDATE (profile_completion_bonus_granted = true)
--   4) token_transactions INSERT (idempotency_key 없음)
--
-- 1)과 2) 사이에 grant_purchase_tokens_atomic 이 완료되면 **결제로 지급된 토큰이
-- 통째로 덮어써진다.** 고객이 돈 주고 산 토큰이 흔적 없이 사라지는 경로다.
-- 2)와 3) 사이에서 실패하면 플래그 없이 토큰만 지급돼 재호출 시 중복 지급된다.
-- 두 창 모두 웹 가입 퍼널에서 호출량이 늘면 실제로 터진다 — 이 엔드포인트는
-- 3필드 입력(생년월일+태어난시간)이 트리거이므로 웹 온보딩의 핵심 경로다.
--
-- 해결: 단일 트랜잭션 RPC. 프로필 행을 FOR UPDATE 로 잠가 동시 호출을 직렬화하고,
-- 잔액은 절대값이 아니라 **상대 증분**으로 갱신한다.

CREATE OR REPLACE FUNCTION public.grant_profile_completion_bonus_atomic(
  p_user_id UUID,
  p_bonus INTEGER DEFAULT 5
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_birth_date TEXT;
  v_birth_time TEXT;
  v_already BOOLEAN;
  v_new_balance INTEGER;
  v_new_total_earned INTEGER;
  v_total_spent INTEGER;
  v_txn_id UUID;
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'MISSING_USER_ID' USING ERRCODE = '22023';
  END IF;
  IF p_bonus IS NULL OR p_bonus <= 0 THEN
    RAISE EXCEPTION 'INVALID_BONUS' USING ERRCODE = '22023';
  END IF;

  -- 프로필 행 잠금 — 동시 호출 직렬화
  SELECT birth_date::TEXT,
         birth_time::TEXT,
         COALESCE(profile_completion_bonus_granted, false)
    INTO v_birth_date, v_birth_time, v_already
    FROM user_profiles
   WHERE id = p_user_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('granted', false, 'reason', 'PROFILE_NOT_FOUND');
  END IF;

  IF v_already THEN
    SELECT balance, total_earned, total_spent
      INTO v_new_balance, v_new_total_earned, v_total_spent
      FROM token_balance
     WHERE user_id = p_user_id;

    RETURN jsonb_build_object(
      'granted', false,
      'reason', 'ALREADY_GRANTED',
      'balance', COALESCE(v_new_balance, 0),
      'total_earned', COALESCE(v_new_total_earned, 0),
      'total_spent', COALESCE(v_total_spent, 0)
    );
  END IF;

  IF v_birth_date IS NULL OR v_birth_time IS NULL THEN
    RETURN jsonb_build_object('granted', false, 'reason', 'PROFILE_INCOMPLETE');
  END IF;

  -- 상대 증분 — 동시에 진행 중인 결제 지급을 덮어쓰지 않는다.
  INSERT INTO token_balance (user_id, balance, total_earned, total_spent, updated_at)
  VALUES (p_user_id, p_bonus, p_bonus, 0, NOW())
  ON CONFLICT (user_id) DO UPDATE
     SET balance      = token_balance.balance + p_bonus,
         total_earned = token_balance.total_earned + p_bonus,
         updated_at   = NOW()
  RETURNING balance, total_earned, total_spent
       INTO v_new_balance, v_new_total_earned, v_total_spent;

  INSERT INTO token_transactions (
    user_id, transaction_type, amount, balance_after,
    description, reference_type, reference_id, idempotency_key
  ) VALUES (
    p_user_id, 'earn', p_bonus, v_new_balance,
    '프로필 완성 보너스', 'bonus', 'profile_completion',
    'profile-completion:' || p_user_id::TEXT
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_txn_id;

  UPDATE user_profiles
     SET profile_completion_bonus_granted = true
   WHERE id = p_user_id;

  RETURN jsonb_build_object(
    'granted', true,
    'bonus', p_bonus,
    'balance', v_new_balance,
    'total_earned', v_new_total_earned,
    'total_spent', COALESCE(v_total_spent, 0),
    'transaction_id', v_txn_id
  );
END;
$$;

REVOKE ALL ON FUNCTION public.grant_profile_completion_bonus_atomic(UUID, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.grant_profile_completion_bonus_atomic(UUID, INTEGER)
  TO service_role;

COMMENT ON FUNCTION public.grant_profile_completion_bonus_atomic(UUID, INTEGER) IS
  '프로필 완성 보너스 원자 지급. 절대값 upsert 로 결제 토큰을 덮어쓰던 레이스를 대체한다.';


-- ==== 20260818000700_codify_money_tables.sql ==========================
-- 원장 테이블 스키마/권한 성문화.
--
-- token_balance 와 token_transactions 는 supabase/migrations/*.sql 어디에도
-- CREATE TABLE 도 RLS DDL 도 없다 — 대시보드에서 out-of-band 로 생성됐다.
-- 브라우저에 anon key 가 실려나가는 웹 출시 전에 실제 정책을 마이그레이션으로
-- 고정해야 한다. 아래 정의는 2026-08-18 라이브 introspection 결과와 일치한다.
--
-- 실측 결과 요약:
--   token_balance       RLS ON, 정책은 SELECT 1개뿐 (user_id = auth.uid())
--   token_transactions  RLS ON, 정책은 SELECT 1개뿐 (user_id = auth.uid())
--   verified_purchases  RLS ON, verified_purchases_self_read (authenticated)
--   subscriptions       RLS ON, service_role ALL + 본인 SELECT
--   → INSERT/UPDATE/DELETE 정책이 없으므로 RLS 가 클라이언트 쓰기를 이미 막고 있다.
--
-- 다만 네 테이블 모두 anon/authenticated 에게 테이블 수준
-- INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER 권한이 남아 있다
-- (Supabase 기본 GRANT ALL). TRUNCATE 는 RLS 적용 대상이 아니다.
-- PostgREST 가 TRUNCATE 를 발행하지 않아 현재 공개 API 로는 도달 불가하지만,
-- RLS 하나에만 의존하지 않도록 쓰기 권한 자체를 회수한다.
--
-- 클라이언트 직접 접근 확인 (grep apps/mobile-rn):
--   subscriptions  → premium-remote.ts:164 SELECT only
--   token_balance / token_transactions / verified_purchases → 직접 접근 0건
--   전부 Edge Function(service_role) 경유. SELECT 만 남겨도 회귀 없음.
--
-- daily_free_fortune 은 본 마이그레이션에서 건드리지 않는다 — 사용자 INSERT 정책이
-- 있고 클라이언트 삽입 경로를 확정하지 못했다. 웹 게스트 퍼널 작업 시 재검토.

-- ── 스키마 성문화 (이미 존재하면 no-op) ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS token_balance (
  user_id       UUID PRIMARY KEY,
  balance       INTEGER NOT NULL DEFAULT 0,
  total_earned  INTEGER NOT NULL DEFAULT 0,
  total_spent   INTEGER NOT NULL DEFAULT 0,
  last_daily_claim TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS token_transactions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL,
  transaction_type TEXT NOT NULL,
  amount           INTEGER NOT NULL,
  balance_after    INTEGER NOT NULL,
  description      TEXT,
  reference_id     TEXT,
  reference_type   TEXT,
  created_at       TIMESTAMPTZ DEFAULT now(),
  idempotency_key  TEXT
);

ALTER TABLE token_balance      ENABLE ROW LEVEL SECURITY;
ALTER TABLE token_transactions ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy
     WHERE polrelid = 'public.token_balance'::regclass
       AND polname = 'Users can view own token balance'
  ) THEN
    CREATE POLICY "Users can view own token balance"
      ON token_balance FOR SELECT
      USING (user_id = auth.uid());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policy
     WHERE polrelid = 'public.token_transactions'::regclass
       AND polname = 'Users can view own token transactions'
  ) THEN
    CREATE POLICY "Users can view own token transactions"
      ON token_transactions FOR SELECT
      USING (user_id = auth.uid());
  END IF;
END $$;

-- ── 클라이언트 쓰기 권한 회수 (RLS 에만 의존하지 않는다) ────────────────────

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE token_balance      FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE token_transactions FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE verified_purchases FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE subscriptions      FROM anon, authenticated;

-- SELECT 는 유지 (RLS 정책이 본인 행으로 좁힌다).
GRANT SELECT ON TABLE token_balance      TO authenticated;
GRANT SELECT ON TABLE token_transactions TO authenticated;
GRANT SELECT ON TABLE verified_purchases TO authenticated;
GRANT SELECT ON TABLE subscriptions      TO authenticated;

-- service_role 은 모든 권한 유지 (Edge Function 이 유일한 쓰기 주체).
GRANT ALL ON TABLE token_balance      TO service_role;
GRANT ALL ON TABLE token_transactions TO service_role;
GRANT ALL ON TABLE verified_purchases TO service_role;
GRANT ALL ON TABLE subscriptions      TO service_role;

COMMENT ON TABLE token_balance IS
  '토큰 잔액 원장. 쓰기는 service_role Edge Function 경유 RPC 만 허용된다.';
COMMENT ON TABLE token_transactions IS
  '토큰 거래 이력. transaction_type 허용값은 token_transactions_transaction_type_check 참고.';


-- ==== 20260818000800_close_static_audit_gaps.sql ======================
-- supabase/scripts/rls-static-audit.sh 의 새 게이트가 찾아낸 잔여 항목 정리.
--
-- 이전 감사 스크립트는 `CREATE TABLE ... public.` 형태만 매칭해서 100개 중 26개만
-- 검사했다. 비수식 선언까지 보도록 고치고 SECURITY DEFINER + p_user_id RPC 의
-- REVOKE 여부 게이트를 추가하니 아래 4건이 남았다.
--
-- 라이브 실측 (2026-08-18):
--   auspicious_days   RLS ON, 정책 1개  ← 대시보드에서 out-of-band 적용, 마이그레이션에 기록 없음
--   korean_holidays   RLS ON, 정책 1개  ← 동일
--   check_duplicate_fortune            ← SECURITY DEFINER, p_user_id 인자, anon 실행 가능
--   calculate_engagement_score         ← 라이브에 존재하지 않음 (마이그레이션에만 있는 유령)
--
-- 두 룩업 테이블은 이미 보호돼 있지만 상태가 코드에 없어 다음 환경 복제 시 재현되지
-- 않는다. 여기서 idempotent 하게 성문화한다.

-- ── 룩업 테이블 RLS 성문화 ─────────────────────────────────────────────────
-- 공개 참조 데이터(길일/공휴일)이므로 읽기는 전체 허용, 쓰기는 service_role 전용.

ALTER TABLE IF EXISTS korean_holidays ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS auspicious_days ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF to_regclass('public.korean_holidays') IS NOT NULL
     AND NOT EXISTS (
       SELECT 1 FROM pg_policy
        WHERE polrelid = 'public.korean_holidays'::regclass
          AND polname = 'korean_holidays_public_read'
     ) THEN
    CREATE POLICY korean_holidays_public_read
      ON korean_holidays FOR SELECT
      USING (true);
  END IF;

  IF to_regclass('public.auspicious_days') IS NOT NULL
     AND NOT EXISTS (
       SELECT 1 FROM pg_policy
        WHERE polrelid = 'public.auspicious_days'::regclass
          AND polname = 'auspicious_days_public_read'
     ) THEN
    CREATE POLICY auspicious_days_public_read
      ON auspicious_days FOR SELECT
      USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF to_regclass('public.korean_holidays') IS NOT NULL THEN
    REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLE korean_holidays FROM anon, authenticated;
  END IF;
  IF to_regclass('public.auspicious_days') IS NOT NULL THEN
    REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLE auspicious_days FROM anon, authenticated;
  END IF;
END $$;

-- ── SECURITY DEFINER RPC 회수 ──────────────────────────────────────────────
-- 두 함수 모두 리포 전체(apps/mobile-rn, supabase/functions)에서 호출부 0건.

REVOKE ALL ON FUNCTION public.check_duplicate_fortune(UUID, VARCHAR, DATE, JSONB)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.check_duplicate_fortune(UUID, VARCHAR, DATE, JSONB)
  TO service_role;

-- calculate_engagement_score 는 마이그레이션에만 있고 라이브에는 없다.
-- 존재할 때만 회수한다 (다른 환경에서 적용됐을 수 있음).
-- 평문 REVOKE 를 쓰면 함수가 없는 환경에서 마이그레이션이 통째로 실패하므로 동적 실행.
-- audit-ack: calculate_engagement_score — 아래 DO 블록에서 동적으로 REVOKE 한다
DO $$
DECLARE
  v_sig TEXT;
BEGIN
  FOR v_sig IN
    SELECT format('public.%I(%s)', p.proname, pg_get_function_identity_arguments(p.oid))
      FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'public' AND p.proname = 'calculate_engagement_score'
  LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC, anon, authenticated', v_sig);
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO service_role', v_sig);
  END LOOP;
END $$;


-- ==== 20260819100000_fortune_result_cache.sql =========================
-- 운세 생성 결과 캐시 — 서버 주도 idempotency 의 저장소.
--
-- 배경: fortune-* Edge Function 이 클라이언트의 soul-consume 호출에 의존해
-- 브라우저에서 직접 호출하면 무과금 LLM 사용이 가능했다. _shared/fortune_charge.ts
-- 가 서버에서 차감하도록 바뀌면서, "같은 요청을 다시 보내면 다시 과금되는" 문제와
-- "클라가 idempotency key 를 고정해 공짜 재생성을 노리는" 구멍을 동시에 막기 위해
-- 서버가 만든 키(user + fortuneType + 정규화 body 해시)로 결과를 캐싱한다.
--
-- 키는 24h 윈도우 인덱스를 포함한다: fortune:<uid>:<type>:<bodyHash>:<floor(now/24h)>.
--
-- 처음에는 "TTL 이 유일한 시간 축" 으로 설계했으나 그건 영구 무료 구멍이었다:
-- consume_token_atomic 은 같은 멱등키에 대해 **영원히** replayed=true 를 돌려주고
-- _shared/token_charge.ts 는 replayed 를 charged:true 로 매핑해 차감을 건너뛴다.
-- 반면 이 테이블의 row 는 24h 뒤 사라진다. 결과적으로
--   1회 과금 → 24h 대기 → 캐시 미스 + 차감 replay → LLM 무료 실행 → 무한 반복
-- 이 성립했다. 키와 캐시가 같은 주기로 만료돼야 이 창이 닫힌다.
-- storeFortuneResult 도 expires_at 을 컬럼 기본값이 아니라 **윈도우 종료 시각**으로
-- 명시해 둘의 수명을 정확히 일치시킨다.
--
-- 잔여(경계 있음): 같은 윈도우 안에서 캐시 저장이 실패했거나 생성 실패 후 환불된
-- 요청이 재시도되면 차감 replay 로 1회 무료 생성이 가능하다. 원장이 "환불된 consume"
-- 을 구분하지 못해 스키마 변경 없이는 못 막는다. 발생 시
-- '[fortune_charge] 차감 replay (무차감 생성)' 경고가 함수 로그에 남는다.
--
-- service_role 전용 테이블. payload 에 사용자 운세 본문이 그대로 들어가므로
-- anon / authenticated 에게는 self-read 조차 열지 않는다 (Edge Function 만 접근).

CREATE TABLE IF NOT EXISTS fortune_result_cache (
  idempotency_key TEXT PRIMARY KEY,
  user_id UUID NOT NULL,
  fortune_type TEXT NOT NULL,
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT now() + interval '24 hours'
);

CREATE INDEX IF NOT EXISTS idx_fortune_result_cache_user_created
  ON fortune_result_cache (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_fortune_result_cache_expires
  ON fortune_result_cache (expires_at);

ALTER TABLE fortune_result_cache ENABLE ROW LEVEL SECURITY;

-- service_role 만 읽기/쓰기. 사용자 직접 조회 경로 없음.
DROP POLICY IF EXISTS "fortune_result_cache_service_all" ON fortune_result_cache;
CREATE POLICY "fortune_result_cache_service_all" ON fortune_result_cache
  FOR ALL USING (auth.role() = 'service_role');

REVOKE ALL ON TABLE fortune_result_cache FROM anon, authenticated;

COMMENT ON TABLE fortune_result_cache IS
  '운세 생성 결과 캐시 (서버 주도 idempotency). service_role 전용. TTL 24시간.';

-- 만료 row 정리 — pg_cron 매일 03:10 (UTC).
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 기존 잡 제거 (재배포 시 중복 방지)
DO $$
BEGIN
  PERFORM cron.unschedule('cleanup-fortune-result-cache-daily');
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END $$;

SELECT cron.schedule(
  'cleanup-fortune-result-cache-daily',
  '10 3 * * *',
  $$
  DELETE FROM fortune_result_cache WHERE expires_at < now();
  $$
);


-- ==== 마이그레이션 이력 기록 ====================================
INSERT INTO supabase_migrations.schema_migrations (version)
VALUES
  ('20260818000200'),
  ('20260818000300'),
  ('20260818000400'),
  ('20260818000500'),
  ('20260818000600'),
  ('20260818000700'),
  ('20260818000800'),
  ('20260819100000')
ON CONFLICT (version) DO NOTHING;
