CREATE OR REPLACE FUNCTION public.request_web_payment_refund(
  p_order_id TEXT,
  p_reason TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_user_id UUID := auth.uid();
  v_order public.web_payment_orders%ROWTYPE;
  v_request_id UUID;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
  END IF;
  IF p_reason IS NULL OR char_length(trim(p_reason)) NOT BETWEEN 2 AND 200 THEN
    RAISE EXCEPTION 'REFUND_REASON_INVALID' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_order
    FROM public.web_payment_orders
   WHERE order_id = p_order_id
     AND user_id = v_user_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'WEB_PAYMENT_ORDER_NOT_FOUND' USING ERRCODE = 'P0002';
  END IF;
  IF v_order.status <> 'paid' THEN
    RAISE EXCEPTION 'WEB_PAYMENT_NOT_REFUNDABLE' USING ERRCODE = '55000';
  END IF;
  IF v_order.paid_at < now() - INTERVAL '7 days' THEN
    RAISE EXCEPTION 'WEB_PAYMENT_REFUND_WINDOW_EXPIRED' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.web_payment_refund_requests (order_id, user_id, amount, reason)
  VALUES (v_order.order_id, v_user_id, v_order.amount, trim(p_reason))
  RETURNING id INTO v_request_id;

  UPDATE public.web_payment_orders
     SET status = 'cancel_requested', updated_at = now()
   WHERE order_id = v_order.order_id;

  RETURN v_request_id;
END;
$function$;
