-- pg_cron 으로 매 분 process-poster-jobs Edge Function 호출.
-- pending 큐가 길면 매 사이클 1개씩 처리 — 큐 적체 시 별도 worker 추가 검토.

-- pg_cron, pg_net 활성화 (이미 활성화돼 있어도 idempotent)
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 기존 잡 제거 (재배포 시 중복 방지)
DO $$
BEGIN
  PERFORM cron.unschedule('process-poster-jobs-every-minute');
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END $$;

-- 1분 간격으로 Edge Function 호출.
-- net.http_post 비동기 — cron 시간 지연시키지 않음.
SELECT cron.schedule(
  'process-poster-jobs-every-minute',
  '* * * * *',
  $$
  SELECT net.http_post(
    url := current_setting('app.settings.supabase_url', true) || '/functions/v1/process-poster-jobs',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := '{}'::jsonb
  );
  $$
);

COMMENT ON EXTENSION pg_cron IS
  'pg_cron used for: deliver-due-replies (chat), process-poster-jobs (palm-reading 등 비동기).';
