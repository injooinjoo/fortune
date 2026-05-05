-- /ultrareview BM P0 #2 보강 + soul-consume RPC 누락 보완 + 스키마 정정.
--
-- 1) reference_id 컬럼 타입 uuid → text. Apple/Google transaction id 같은
--    비-UUID 문자열을 받기 위함. 기존 row 는 모두 NULL 이라 데이터 손실 0.
-- 2) idempotency_key text 컬럼 신규 + UNIQUE INDEX (user_id, idempotency_key).
-- 3) refund_token_atomic 재정의 (text 인자).
-- 4) consume_token_atomic 신규 — soul-consume 이 이미 호출 중인데 RPC 미존재였음.
--
-- 양쪽 RPC 모두 atomic + idempotent + lock 처리.

ALTER TABLE token_transactions
  ALTER COLUMN reference_id TYPE TEXT USING reference_id::TEXT;

ALTER TABLE token_transactions
  ADD COLUMN IF NOT EXISTS idempotency_key TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_token_transactions_idempotency_key
  ON token_transactions (user_id, idempotency_key)
  WHERE idempotency_key IS NOT NULL;

DROP FUNCTION IF EXISTS refund_token_atomic(UUID, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION refund_token_atomic(
  p_user_id UUID,
  p_consume_reference_id TEXT,
  p_description TEXT,
  p_reference_type TEXT,
  p_idempotency_key TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_consume_id UUID;
  v_consume_amount INTEGER;
  v_existing_refund_id UUID;
  v_balance INTEGER;
  v_total_earned INTEGER;
  v_total_spent INTEGER;
  v_new_balance INTEGER;
  v_new_total_spent INTEGER;
  v_new_refund_id UUID;
BEGIN
  SELECT id, amount
    INTO v_consume_id, v_consume_amount
    FROM token_transactions
   WHERE user_id = p_user_id
     AND reference_id = p_consume_reference_id
     AND transaction_type = 'consume'
   ORDER BY created_at DESC
   LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NO_MATCHING_CONSUME'
      USING ERRCODE = 'P0002',
            DETAIL = format('user=%s reference_id=%s', p_user_id, p_consume_reference_id);
  END IF;

  SELECT id INTO v_existing_refund_id
    FROM token_transactions
   WHERE user_id = p_user_id
     AND transaction_type = 'refund'
     AND (
       reference_id = p_consume_reference_id
       OR (p_idempotency_key IS NOT NULL AND idempotency_key = p_idempotency_key)
     )
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
      'refunded', false,
      'replayed', true,
      'refund_transaction_id', v_existing_refund_id::TEXT,
      'original_transaction_id', v_consume_id::TEXT,
      'refund_amount', v_consume_amount
    );
  END IF;

  SELECT balance, total_earned, total_spent
    INTO v_balance, v_total_earned, v_total_spent
    FROM token_balance
   WHERE user_id = p_user_id
   FOR UPDATE;

  IF NOT FOUND THEN
    INSERT INTO token_balance (user_id, balance, total_earned, total_spent, updated_at)
      VALUES (p_user_id, v_consume_amount, v_consume_amount, 0, now());
    v_new_balance := v_consume_amount;
    v_new_total_spent := 0;
    v_total_earned := v_consume_amount;
  ELSE
    v_new_balance := v_balance + v_consume_amount;
    v_new_total_spent := GREATEST(0, v_total_spent - v_consume_amount);
    UPDATE token_balance
       SET balance = v_new_balance,
           total_spent = v_new_total_spent,
           updated_at = now()
     WHERE user_id = p_user_id;
  END IF;

  INSERT INTO token_transactions (
    user_id, transaction_type, amount, balance_after,
    description, reference_type, reference_id, idempotency_key
  ) VALUES (
    p_user_id, 'refund', v_consume_amount, v_new_balance,
    p_description, p_reference_type, p_consume_reference_id, p_idempotency_key
  )
  RETURNING id INTO v_new_refund_id;

  RETURN jsonb_build_object(
    'balance', v_new_balance,
    'total_earned', v_total_earned,
    'total_spent', v_new_total_spent,
    'refunded', true,
    'replayed', false,
    'refund_transaction_id', v_new_refund_id::TEXT,
    'original_transaction_id', v_consume_id::TEXT,
    'refund_amount', v_consume_amount
  );
END;
$$;

GRANT EXECUTE ON FUNCTION refund_token_atomic(UUID, TEXT, TEXT, TEXT, TEXT)
  TO service_role, authenticated;

CREATE OR REPLACE FUNCTION consume_token_atomic(
  p_user_id UUID,
  p_cost INTEGER,
  p_description TEXT,
  p_reference_type TEXT,
  p_reference_id TEXT DEFAULT NULL,
  p_idempotency_key TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_balance INTEGER;
  v_total_earned INTEGER;
  v_total_spent INTEGER;
  v_existing_consume_id UUID;
  v_new_consume_id UUID;
  v_new_balance INTEGER;
  v_new_total_spent INTEGER;
BEGIN
  IF p_cost IS NULL OR p_cost <= 0 THEN
    RAISE EXCEPTION 'INVALID_COST'
      USING ERRCODE = '22023', DETAIL = format('cost=%s', p_cost);
  END IF;

  IF p_idempotency_key IS NOT NULL THEN
    SELECT id INTO v_existing_consume_id
      FROM token_transactions
     WHERE user_id = p_user_id
       AND transaction_type = 'consume'
       AND idempotency_key = p_idempotency_key
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
        'consumed', false,
        'replayed', true,
        'consume_transaction_id', v_existing_consume_id::TEXT,
        'cost', p_cost
      );
    END IF;
  END IF;

  SELECT balance, total_earned, total_spent
    INTO v_balance, v_total_earned, v_total_spent
    FROM token_balance
   WHERE user_id = p_user_id
   FOR UPDATE;

  IF NOT FOUND OR COALESCE(v_balance, 0) < p_cost THEN
    RAISE EXCEPTION 'INSUFFICIENT_TOKENS'
      USING ERRCODE = 'P0001',
            DETAIL = format('balance=%s cost=%s', COALESCE(v_balance, 0), p_cost);
  END IF;

  v_new_balance := v_balance - p_cost;
  v_new_total_spent := COALESCE(v_total_spent, 0) + p_cost;

  UPDATE token_balance
     SET balance = v_new_balance,
         total_spent = v_new_total_spent,
         updated_at = now()
   WHERE user_id = p_user_id;

  INSERT INTO token_transactions (
    user_id, transaction_type, amount, balance_after,
    description, reference_type, reference_id, idempotency_key
  ) VALUES (
    p_user_id, 'consume', p_cost, v_new_balance,
    p_description, p_reference_type, p_reference_id, p_idempotency_key
  )
  RETURNING id INTO v_new_consume_id;

  RETURN jsonb_build_object(
    'balance', v_new_balance,
    'total_earned', COALESCE(v_total_earned, 0),
    'total_spent', v_new_total_spent,
    'consumed', true,
    'replayed', false,
    'consume_transaction_id', v_new_consume_id::TEXT,
    'cost', p_cost
  );
END;
$$;

GRANT EXECUTE ON FUNCTION consume_token_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  TO service_role, authenticated;

COMMENT ON FUNCTION refund_token_atomic IS 'soul-refund atomic. consume 검증 + idempotent + UNIQUE 안전망.';
COMMENT ON FUNCTION consume_token_atomic IS 'soul-consume atomic. 잔액 lock + idempotent.';
