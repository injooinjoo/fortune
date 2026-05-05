-- /ultrareview SRE P0 #6 fix.
--
-- 기존 proactive-message-dispatch + deliver-due-replies cron 은
-- vault.decrypted_secrets 의 'proactive_dispatch_anon_key' (= 공개 anon key) 를
-- Authorization Bearer 로 보내고 있었다. anon key 는 의도적으로 public 이라
-- 사실상 무인증. 외부 호출자가 cron 엔드포인트를 강제로 트리거할 수 있었다.
--
-- 두 cron 을 service_role_key 로 재발급. Edge Function 측에서는
-- _shared/worker_auth.ts 의 requireWorkerAuth() 가 SUPABASE_SERVICE_ROLE_KEY
-- 또는 CRON_SECRET 만 통과시킨다.
--
-- 적용 후 cron.job 테이블에 jobname 'proactive-message-dispatch-5min',
-- 'deliver-due-replies-1min' 두 개가 service_role_key 헤더로 호출하게 된다.
-- pg cron 컨텍스트의 `current_setting('app.settings.service_role_key', true)` 가
-- 이미 process-poster-jobs cron 에서 사용 중이므로 동일 패턴.

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'proactive-message-dispatch-5min') THEN
    PERFORM cron.unschedule('proactive-message-dispatch-5min');
  END IF;
  PERFORM cron.schedule(
    'proactive-message-dispatch-5min',
    '*/5 * * * *',
    $cron$
    SELECT net.http_post(
      url := 'https://hayjukwfcsdmppairazc.supabase.co/functions/v1/proactive-message-dispatch',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb,
      timeout_milliseconds := 30000
    ) AS request_id;
    $cron$
  );
END $$;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'deliver-due-replies-1min') THEN
    PERFORM cron.unschedule('deliver-due-replies-1min');
  END IF;
  PERFORM cron.schedule(
    'deliver-due-replies-1min',
    '* * * * *',
    $cron$
    SELECT net.http_post(
      url := 'https://hayjukwfcsdmppairazc.supabase.co/functions/v1/deliver-due-replies',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb,
      timeout_milliseconds := 30000
    ) AS request_id;
    $cron$
  );
END $$;

-- 더 이상 사용 안 하는 vault secret 은 그대로 두어도 무해 (cron 이 참조 안 함).
-- 안전 정리 원하면 별도로:
--   SELECT vault.delete_secret(id) FROM vault.secrets WHERE name = 'proactive_dispatch_anon_key';
