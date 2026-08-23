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
