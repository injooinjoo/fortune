COMMENT ON FUNCTION public.activate_subscription_purchase_atomic IS 'Verified subscription transaction을 row lock으로 1회 소비해 entitlement + 월 토큰 자동충전을 한 DB transaction 안에서 처리한다.';
