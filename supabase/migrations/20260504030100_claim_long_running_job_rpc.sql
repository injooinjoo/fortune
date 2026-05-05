-- claim_next_long_running_job() — atomic claim, scheduled_poster_jobs 와 동일 패턴.
-- FOR UPDATE SKIP LOCKED 로 동시 cron 인스턴스 race 회피.

CREATE OR REPLACE FUNCTION claim_next_long_running_job()
RETURNS long_running_jobs
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_job long_running_jobs;
BEGIN
  WITH next_job AS (
    SELECT id
    FROM long_running_jobs
    WHERE status = 'pending'
    ORDER BY created_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED
  )
  UPDATE long_running_jobs lrj
  SET
    status = 'processing',
    started_at = NOW(),
    retry_count = retry_count + 1
  FROM next_job
  WHERE lrj.id = next_job.id
  RETURNING lrj.* INTO v_job;

  RETURN v_job;
END;
$$;

REVOKE ALL ON FUNCTION claim_next_long_running_job() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION claim_next_long_running_job() TO service_role;

COMMENT ON FUNCTION claim_next_long_running_job() IS
  'Atomic claim — pending → processing. Used by process-long-running-jobs cron worker. '
  'Same pattern as claim_next_poster_job() but for the generic long_running_jobs queue.';
