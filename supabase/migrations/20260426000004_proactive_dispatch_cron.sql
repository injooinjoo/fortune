-- pg_cron 으로 proactive-message-dispatch 5분마다 자동 호출
-- mcp execute_sql 로 production 적용 완료 (jobid=2).
-- vault에 anon JWT 저장하고 cron.job 안에서 vault.decrypted_secrets 참조 (credential leakage 방지).

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- vault.create_secret('eyJ...anon JWT...', 'proactive_dispatch_anon_key', '...')
-- production 적용은 mcp 로 직접 수행 (vault SQL 자체는 idempotent 안 함 — 이미 등록된 secret 이름이면 실패).
-- 새 환경에서 적용 시 위 secret 을 먼저 등록한 뒤 아래 cron.schedule 실행할 것.

-- cron job 등록 (idempotent): 같은 jobname 이면 cron.unschedule 후 재등록.
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
        'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'proactive_dispatch_anon_key'),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb,
      timeout_milliseconds := 30000
    ) AS request_id;
    $cron$
  );
END $$;
