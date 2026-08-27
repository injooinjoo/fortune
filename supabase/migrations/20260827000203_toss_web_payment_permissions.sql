DO $permissions$
BEGIN
  EXECUTE 'REVOKE ALL ON FUNCTION public.complete_web_payment_atomic(UUID, TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ) FROM PUBLIC, anon, authenticated';
  EXECUTE 'GRANT EXECUTE ON FUNCTION public.complete_web_payment_atomic(UUID, TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ) TO service_role';
  EXECUTE 'REVOKE ALL ON FUNCTION public.request_web_payment_refund(TEXT, TEXT) FROM PUBLIC, anon';
  EXECUTE 'GRANT EXECUTE ON FUNCTION public.request_web_payment_refund(TEXT, TEXT) TO authenticated';
END;
$permissions$;
