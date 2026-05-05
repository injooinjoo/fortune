-- pg_cron: 매 분 process-long-running-jobs Edge Function 호출.
-- scheduled_poster_jobs 의 cron 과 다른 워커지만 동일한 1분 패턴.

-- pg_cron, pg_net 활성화 (poster-jobs cron 이 이미 활성화 했더라도 idempotent)
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 기존 잡 제거 (재배포 시 중복 방지)
DO $$
BEGIN
  PERFORM cron.unschedule('process-long-running-jobs-every-minute');
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END $$;

SELECT cron.schedule(
  'process-long-running-jobs-every-minute',
  '* * * * *',
  $$
  SELECT net.http_post(
    url := current_setting('app.settings.supabase_url', true) || '/functions/v1/process-long-running-jobs',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := '{}'::jsonb
  );
  $$
);
