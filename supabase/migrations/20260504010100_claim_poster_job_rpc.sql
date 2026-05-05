-- claim_next_poster_job() — atomic claim 으로 동시 cron 인스턴스 race 회피.
-- FOR UPDATE SKIP LOCKED 으로 lock 잡힌 row 는 다른 인스턴스에 양보.

CREATE OR REPLACE FUNCTION claim_next_poster_job()
RETURNS scheduled_poster_jobs
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_job scheduled_poster_jobs;
BEGIN
  -- 가장 오래된 pending 1개 atomic 픽업.
  WITH next_job AS (
    SELECT id
    FROM scheduled_poster_jobs
    WHERE status = 'pending'
    ORDER BY created_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED
  )
  UPDATE scheduled_poster_jobs sj
  SET
    status = 'processing',
    started_at = NOW(),
    retry_count = retry_count + 1
  FROM next_job
  WHERE sj.id = next_job.id
  RETURNING sj.* INTO v_job;

  RETURN v_job;
END;
$$;

REVOKE ALL ON FUNCTION claim_next_poster_job() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION claim_next_poster_job() TO service_role;

COMMENT ON FUNCTION claim_next_poster_job() IS
  'Atomic claim — pending → processing. Used by process-poster-jobs cron worker. '
  'FOR UPDATE SKIP LOCKED prevents race between concurrent cron instances.';
