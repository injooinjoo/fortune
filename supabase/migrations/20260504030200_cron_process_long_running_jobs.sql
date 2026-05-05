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

-- 인증: vault 의 proactive_dispatch_anon_key 사용. process-long-running-jobs 는
-- --no-verify-jwt 라 무인증 호출 OK 이지만 anon key 가 deliver-due-replies 등
-- 다른 cron 과 일관된 표준 패턴. (current_setting('app.settings.*') 는 Supabase
-- managed 환경에서 NULL 반환되어 작동 X — vault.decrypted_secrets 가 표준.)
SELECT cron.schedule(
  'process-long-running-jobs-every-minute',
  '* * * * *',
  $$
  SELECT net.http_post(
    url := 'https://hayjukwfcsdmppairazc.supabase.co/functions/v1/process-long-running-jobs',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'proactive_dispatch_anon_key'),
      'Content-Type', 'application/json'
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 90000
  ) AS request_id;
  $$
);
