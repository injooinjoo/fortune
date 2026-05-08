-- =============================================================================
-- pg_cron: 매분 process-pending-reply-jobs 호출
-- =============================================================================
-- 30 초 grace 후 답장 미생성 user 메시지 픽업 → character-chat 호출 → done.
-- service_role_key 사용 (proactive-message-dispatch / deliver-due-replies 와 동일 패턴).
--
-- 매시간 cleanup_pending_reply_jobs (7일 보존) + recover_stuck_pending_reply_jobs (5분 stuck) 호출.

CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'process-pending-reply-jobs-1min') THEN
    PERFORM cron.unschedule('process-pending-reply-jobs-1min');
  END IF;
  PERFORM cron.schedule(
    'process-pending-reply-jobs-1min',
    '* * * * *',
    $cron$
    SELECT net.http_post(
      url := 'https://hayjukwfcsdmppairazc.supabase.co/functions/v1/process-pending-reply-jobs',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb,
      timeout_milliseconds := 60000
    ) AS request_id;
    $cron$
  );
END $$;

-- 보존정책 + stuck 복구는 1시간 주기로 직접 RPC 호출 (Edge Function 안 거침).
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'pending-reply-jobs-housekeeping-hourly') THEN
    PERFORM cron.unschedule('pending-reply-jobs-housekeeping-hourly');
  END IF;
  PERFORM cron.schedule(
    'pending-reply-jobs-housekeeping-hourly',
    '17 * * * *',
    $cron$
    SELECT recover_stuck_pending_reply_jobs(5);
    SELECT cleanup_pending_reply_jobs(7);
    $cron$
  );
END $$;
