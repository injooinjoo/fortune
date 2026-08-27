BEGIN;

DO $$
DECLARE
  v_balance INTEGER;
  v_total_earned INTEGER;
  v_initial_txns INTEGER;
  v_claim JSONB;
BEGIN
  -- New anonymous accounts receive 5 Ondo and a durable initial-grant ledger row.
  INSERT INTO auth.users (id, is_anonymous)
  VALUES ('00000000-0000-0000-0000-000000000001', TRUE);

  SELECT balance, total_earned
    INTO v_balance, v_total_earned
    FROM public.token_balance
   WHERE user_id = '00000000-0000-0000-0000-000000000001';

  IF v_balance <> 5 OR v_total_earned <> 5 THEN
    RAISE EXCEPTION 'new anonymous account expected 5/5, got %/%', v_balance, v_total_earned;
  END IF;

  SELECT COUNT(*) INTO v_initial_txns
    FROM public.token_transactions
   WHERE user_id = '00000000-0000-0000-0000-000000000001'
     AND idempotency_key = 'account-initial:00000000-0000-0000-0000-000000000001'
     AND transaction_type = 'earn'
     AND amount = 5
     AND balance_after = 5;

  IF v_initial_txns <> 1 THEN
    RAISE EXCEPTION 'initial grant ledger expected exactly one row, got %', v_initial_txns;
  END IF;

  -- Anonymous sessions cannot claim the Google-account upgrade bonus.
  PERFORM set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', TRUE);
  SELECT public.claim_account_upgrade_bonus() INTO v_claim;
  IF (v_claim ->> 'reason') <> 'ANONYMOUS_USER' OR (v_claim ->> 'granted')::BOOLEAN THEN
    RAISE EXCEPTION 'anonymous claim should be rejected, got %', v_claim;
  END IF;

  -- Once the same account is linked to Google, exactly 45 is added once.
  UPDATE auth.users
     SET is_anonymous = FALSE
   WHERE id = '00000000-0000-0000-0000-000000000001';

  SELECT public.claim_account_upgrade_bonus() INTO v_claim;
  IF NOT (v_claim ->> 'granted')::BOOLEAN
     OR (v_claim ->> 'bonus')::INTEGER <> 45
     OR (v_claim ->> 'balance')::INTEGER <> 50 THEN
    RAISE EXCEPTION 'first linked-account claim expected +45 to 50, got %', v_claim;
  END IF;

  SELECT public.claim_account_upgrade_bonus() INTO v_claim;
  IF (v_claim ->> 'reason') <> 'ALREADY_GRANTED'
     OR (v_claim ->> 'granted')::BOOLEAN
     OR (v_claim ->> 'balance')::INTEGER <> 50 THEN
    RAISE EXCEPTION 'replayed linked-account claim should be a no-op, got %', v_claim;
  END IF;

  SELECT balance, total_earned
    INTO v_balance, v_total_earned
    FROM public.token_balance
   WHERE user_id = '00000000-0000-0000-0000-000000000001';
  IF v_balance <> 50 OR v_total_earned <> 50 THEN
    RAISE EXCEPTION 'linked account expected final 50/50, got %/%', v_balance, v_total_earned;
  END IF;

  SELECT COUNT(*) INTO v_initial_txns
    FROM public.token_transactions
   WHERE user_id = '00000000-0000-0000-0000-000000000001'
     AND idempotency_key = 'account-upgrade:00000000-0000-0000-0000-000000000001'
     AND amount = 45;
  IF v_initial_txns <> 1 THEN
    RAISE EXCEPTION 'upgrade ledger expected exactly one row, got %', v_initial_txns;
  END IF;

  -- A direct Google signup also starts at 5 and reaches 50 through the same claim.
  INSERT INTO auth.users (id, is_anonymous)
  VALUES ('00000000-0000-0000-0000-000000000002', FALSE);
  PERFORM set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000002', TRUE);
  SELECT public.claim_account_upgrade_bonus() INTO v_claim;
  IF NOT (v_claim ->> 'granted')::BOOLEAN OR (v_claim ->> 'balance')::INTEGER <> 50 THEN
    RAISE EXCEPTION 'direct Google signup expected final balance 50, got %', v_claim;
  END IF;

  -- Legacy users were already given 50 before this migration; no extra 45 is added.
  FOR v_claim IN
    SELECT jsonb_build_object('user_id', id)
      FROM auth.users
     WHERE id IN (
       '00000000-0000-0000-0000-000000000090',
       '00000000-0000-0000-0000-000000000091'
     )
  LOOP
    PERFORM set_config('request.jwt.claim.sub', v_claim ->> 'user_id', TRUE);
    SELECT public.claim_account_upgrade_bonus() INTO v_claim;
    IF (v_claim ->> 'reason') <> 'ALREADY_GRANTED'
       OR (v_claim ->> 'granted')::BOOLEAN
       OR (v_claim ->> 'balance')::INTEGER <> 50 THEN
      RAISE EXCEPTION 'legacy user should not receive an extra grant, got %', v_claim;
    END IF;
  END LOOP;
END
$$;

ROLLBACK;
