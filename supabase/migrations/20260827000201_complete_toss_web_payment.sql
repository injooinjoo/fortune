CREATE OR REPLACE FUNCTION public.complete_web_payment_atomic(
  p_user_id UUID,
  p_order_id TEXT,
  p_payment_key TEXT,
  p_toss_transaction_key TEXT,
  p_payment_method TEXT,
  p_approved_at TIMESTAMPTZ
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_order public.web_payment_orders%ROWTYPE;
  v_grant JSONB;
  v_tokens_added INTEGER;
BEGIN
  SELECT * INTO v_order
    FROM public.web_payment_orders
   WHERE order_id = p_order_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'WEB_PAYMENT_ORDER_NOT_FOUND' USING ERRCODE = 'P0002';
  END IF;
  IF v_order.user_id <> p_user_id THEN
    RAISE EXCEPTION 'WEB_PAYMENT_ORDER_OWNER_MISMATCH' USING ERRCODE = '42501';
  END IF;

  IF v_order.status = 'paid' THEN
    IF v_order.payment_key IS DISTINCT FROM p_payment_key THEN
      RAISE EXCEPTION 'WEB_PAYMENT_REPLAY_MISMATCH' USING ERRCODE = '23505';
    END IF;
    RETURN jsonb_build_object(
      'paid', true,
      'replayed', true,
      'order_id', v_order.order_id,
      'granted_tokens', v_order.granted_tokens,
      'payment_transaction_id', NULL
    );
  END IF;

  IF v_order.status <> 'pending' THEN
    RAISE EXCEPTION 'WEB_PAYMENT_ORDER_NOT_PENDING' USING ERRCODE = '55000';
  END IF;
  IF p_payment_key IS NULL OR char_length(p_payment_key) NOT BETWEEN 1 AND 200 THEN
    RAISE EXCEPTION 'WEB_PAYMENT_KEY_INVALID' USING ERRCODE = '22023';
  END IF;

  v_grant := public.grant_purchase_tokens_atomic(
    p_user_id,
    v_order.base_tokens,
    format('%s 웹 결제', v_order.order_name),
    'toss_web_payment',
    'toss:' || p_payment_key,
    'toss:confirm:' || p_order_id
  );

  IF COALESCE((v_grant->>'owned_by_current_user')::BOOLEAN, false) = false THEN
    RAISE EXCEPTION 'WEB_PAYMENT_CREDIT_OWNER_MISMATCH' USING ERRCODE = '42501';
  END IF;

  v_tokens_added := CASE
    WHEN COALESCE((v_grant->>'granted')::BOOLEAN, false)
      THEN COALESCE((v_grant->>'tokens_added')::INTEGER, v_order.base_tokens)
    ELSE v_order.base_tokens
  END;

  UPDATE public.web_payment_orders
     SET status = 'paid',
         payment_key = p_payment_key,
         toss_transaction_key = NULLIF(p_toss_transaction_key, ''),
         payment_method = left(NULLIF(p_payment_method, ''), 40),
         granted_tokens = v_tokens_added,
         paid_at = COALESCE(p_approved_at, now()),
         updated_at = now()
   WHERE order_id = p_order_id;

  RETURN jsonb_build_object(
    'paid', true,
    'replayed', false,
    'order_id', p_order_id,
    'granted_tokens', v_tokens_added,
    'balance', v_grant->'balance',
    'payment_transaction_id', v_grant->'purchase_transaction_id'
  );
END;
$function$;
