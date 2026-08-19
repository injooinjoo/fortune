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
