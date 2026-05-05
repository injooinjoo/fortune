-- PR-0a: 토큰 차감/환불 atomic RPC.
-- 기존 코드는 token_balance UPDATE + token_transactions INSERT 가 분리되어
-- 부분 실패 시 잔액-거래 불일치 + race window 존재. 동일 트랜잭션 안에서 처리.
--
-- 호환성:
-- - 기존 RPC 미사용 코드 (soul-consume의 옛 경로) 는 본 PR에서 RPC 호출로 마이그레이션
-- - 다른 Edge Function (_shared/token_charge.ts 등) 도 본 PR에서 마이그레이션
--
-- 결정:
-- - 무제한 구독자 체크는 RPC 밖 (Edge Function 책임). RPC 는 토큰 path만 다룸
-- - daily_free_fortune 도 RPC 밖
-- - INSUFFICIENT_TOKENS 는 EXCEPTION (P0001) — 호출자가 catch 후 도메인 에러 변환

-- ─────────────────────────────────────────────────────────────────────────────
-- consume_token_atomic
-- ─────────────────────────────────────────────────────────────────────────────
--
-- Returns JSONB:
--   { balance, total_earned, total_spent, replayed: bool, transaction_id: UUID }
--
-- replayed=true 인 경우: idempotency_key 가 이미 존재 — 기존 차감 그대로 반환
-- replayed=false 인 경우: 신규 차감 수행
-- INSUFFICIENT_TOKENS: RAISE EXCEPTION 'INSUFFICIENT_TOKENS' SQLSTATE 'P0001'

CREATE OR REPLACE FUNCTION consume_token_atomic(
  p_user_id UUID,
  p_cost INT,
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

  -- 1. Idempotency 우선 검사 — 이미 처리된 키면 기록 그대로 반환
  IF p_idempotency_key IS NOT NULL THEN
    SELECT id, balance_after
      INTO v_existing_id, v_existing_balance_after
      FROM token_transactions
     WHERE idempotency_key = p_idempotency_key
       AND transaction_type = 'consumption'
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

  -- 2. 잔액 row lock
  SELECT balance, total_earned, total_spent
    INTO v_balance, v_total_earned, v_total_spent
    FROM token_balance
   WHERE user_id = p_user_id
     FOR UPDATE;

  IF NOT FOUND THEN
    -- 잔액 row 없음 — cost 0 이면 빈 row 만들고 통과, 아니면 부족
    IF p_cost > 0 THEN
      RAISE EXCEPTION 'INSUFFICIENT_TOKENS' USING ERRCODE = 'P0001', DETAIL = 'no balance row';
    END IF;
    INSERT INTO token_balance (user_id, balance, total_earned, total_spent, updated_at)
    VALUES (p_user_id, 0, 0, 0, NOW());
    v_balance := 0;
    v_total_earned := 0;
    v_total_spent := 0;
  END IF;

  -- 3. 잔액 부족 체크
  IF v_balance < p_cost THEN
    RAISE EXCEPTION 'INSUFFICIENT_TOKENS' USING ERRCODE = 'P0001',
      DETAIL = format('have=%s, need=%s', v_balance, p_cost);
  END IF;

  v_new_balance := v_balance - p_cost;

  -- 4. 잔액 차감 + 거래 기록 (동일 트랜잭션)
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

COMMENT ON FUNCTION consume_token_atomic IS
  'PR-0a: 토큰 차감 atomic RPC. idempotency_key 로 재시도 안전. INSUFFICIENT_TOKENS = SQLSTATE P0001.';

-- ─────────────────────────────────────────────────────────────────────────────
-- refund_token_atomic
-- ─────────────────────────────────────────────────────────────────────────────
--
-- 환불 단위: 같은 user + 같은 reference_id 의 'consumption' 1건을 환불.
-- p_idempotency_key 는 환불 자체의 키 (consume 의 키와 별개).
--
-- Returns JSONB:
--   { balance, total_earned, total_spent,
--     refunded: bool,            -- 신규 환불 수행 여부
--     replayed: bool,            -- 키 또는 reference_id 로 이미 환불됨
--     refund_transaction_id, original_transaction_id, refund_amount }
--
-- NO_MATCHING_CONSUME: SQLSTATE 'P0002' — 같은 reference_id 의 consume 없음.

CREATE OR REPLACE FUNCTION refund_token_atomic(
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

  -- 1. idempotency_key 로 이미 처리된 환불 검사
  IF p_idempotency_key IS NOT NULL THEN
    SELECT id INTO v_existing_refund_id
      FROM token_transactions
     WHERE idempotency_key = p_idempotency_key
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
        'refund_transaction_id',  v_existing_refund_id
      );
    END IF;
  END IF;

  -- 2. 원본 consume 찾기 (가장 최근)
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

  -- 3. reference_id 기반 중복 환불 검사 (legacy refund_unique 인덱스도 지키지만 명시 체크)
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

  -- 4. 환불 금액 = 원본 consume 의 |amount| (음수로 기록되어 있음)
  v_refund_amount := ABS(v_consume_amount);

  -- 5. 잔액 row lock + 복구
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

COMMENT ON FUNCTION refund_token_atomic IS
  'PR-0a: 토큰 환불 atomic RPC. consume reference_id 로 원본 찾기 + idempotency_key 로 재시도 안전. NO_MATCHING_CONSUME = P0002.';

-- 권한: 인증된 사용자가 직접 호출하지 않고 service_role/Edge Function 만 호출.
-- Supabase 기본은 anon/authenticated 모두 EXECUTE 허용이라 명시적 REVOKE.
REVOKE EXECUTE ON FUNCTION consume_token_atomic FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION refund_token_atomic FROM PUBLIC;
GRANT EXECUTE ON FUNCTION consume_token_atomic TO service_role;
GRANT EXECUTE ON FUNCTION refund_token_atomic TO service_role;
