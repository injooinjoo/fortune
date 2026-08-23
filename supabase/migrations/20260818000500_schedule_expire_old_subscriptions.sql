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
