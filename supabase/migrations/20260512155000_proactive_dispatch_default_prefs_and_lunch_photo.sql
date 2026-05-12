-- RCA 2026-05-12: proactive lunch push did not reach users.
--
-- The Edge Function now synthesizes default preferences for luts users with no
-- user_proactive_preferences row, but the pg_cron caller also needs a durable
-- worker credential. Supabase managed pg_cron has previously returned NULL for
-- current_setting('app.settings.*', true), so prefer a vault secret and only use
-- current_setting as a fallback for environments that explicitly set it.
--
-- Required production precondition if not already present:
--   SELECT vault.create_secret('<service-role-or-CRON_SECRET>', 'proactive_dispatch_worker_token');

ALTER TABLE user_proactive_preferences
  ALTER COLUMN enabled SET DEFAULT true;

UPDATE user_proactive_preferences
SET enabled = true
WHERE enabled IS NULL;

ALTER TABLE user_proactive_preferences
  ALTER COLUMN enabled SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM vault.decrypted_secrets
    WHERE name = 'proactive_dispatch_worker_token'
      AND NULLIF(decrypted_secret, '') IS NOT NULL
  ) AND NULLIF(current_setting('app.settings.service_role_key', true), '') IS NULL THEN
    RAISE EXCEPTION
      'proactive-message-dispatch cron worker token missing: create vault secret proactive_dispatch_worker_token or set app.settings.service_role_key';
  END IF;

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
        'Authorization',
        'Bearer ' || COALESCE(
          (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'proactive_dispatch_worker_token' LIMIT 1),
          NULLIF(current_setting('app.settings.service_role_key', true), '')
        ),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb,
      timeout_milliseconds := 30000
    ) AS request_id;
    $cron$
  );
END $$;
