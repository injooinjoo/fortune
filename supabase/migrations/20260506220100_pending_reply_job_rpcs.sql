-- =============================================================================
-- RPCs for pending_character_reply_jobs
-- =============================================================================

-- enqueue_pending_reply_job — 클라가 send 시 호출.
-- 동작:
--   1. (user, character, user_message_id) 이미 있으면 기존 row 반환 (idempotent).
--      자동 재개 useEffect 가 같은 메시지로 재호출해도 cron 호출 두 배가 안 남.
--   2. 같은 (user, character) 의 status='pending' 다른 row 들은 'canceled' 마킹
--      (cancel-and-replace: "한 답장은 가장 최신 user context 기준").
--      processing 상태인 prior job 은 건드리지 않음 — LLM 진행 중이므로 결과는
--      scheduled_character_replies 의 canceled_at 으로 cancel 됨 (기존 로직).
--   3. 새 row INSERT (status='pending').
--
-- 반환: (job_id, job_status, is_new).
CREATE OR REPLACE FUNCTION enqueue_pending_reply_job(
  p_character_id TEXT,
  p_character_name TEXT,
  p_user_message_id TEXT,
  p_user_message TEXT,
  p_request_payload JSONB
)
RETURNS TABLE (
  job_id UUID,
  job_status TEXT,
  is_new BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id UUID;
  v_existing_id UUID;
  v_existing_status TEXT;
  v_new_id UUID;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'enqueue_pending_reply_job requires authenticated user';
  END IF;

  -- idempotency
  SELECT id, status INTO v_existing_id, v_existing_status
  FROM pending_character_reply_jobs
  WHERE user_id = v_user_id
    AND character_id = p_character_id
    AND user_message_id = p_user_message_id;

  IF FOUND THEN
    job_id := v_existing_id;
    job_status := v_existing_status;
    is_new := FALSE;
    RETURN NEXT;
    RETURN;
  END IF;

  -- cancel-and-replace
  UPDATE pending_character_reply_jobs
  SET status = 'canceled', updated_at = now()
  WHERE user_id = v_user_id
    AND character_id = p_character_id
    AND status = 'pending';

  INSERT INTO pending_character_reply_jobs (
    user_id, character_id, character_name,
    user_message_id, user_message, request_payload
  ) VALUES (
    v_user_id, p_character_id, p_character_name,
    p_user_message_id, p_user_message, p_request_payload
  )
  RETURNING id INTO v_new_id;

  job_id := v_new_id;
  job_status := 'pending';
  is_new := TRUE;
  RETURN NEXT;
END;
$$;

REVOKE ALL ON FUNCTION enqueue_pending_reply_job(TEXT, TEXT, TEXT, TEXT, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION enqueue_pending_reply_job(TEXT, TEXT, TEXT, TEXT, JSONB) TO authenticated, service_role;

COMMENT ON FUNCTION enqueue_pending_reply_job(TEXT, TEXT, TEXT, TEXT, JSONB) IS
  '클라가 메시지 send 시 호출. idempotent on user_message_id, '
  '같은 (user,character) 의 prior pending 은 canceled 마킹.';

-- =============================================================================
-- claim_next_pending_reply_job — cron 이 픽업.
-- p_grace_seconds: created_at 이 이만큼 지났을 때만 픽업 (foreground 클라
-- invoke 가 먼저 처리할 시간 양보).
-- FOR UPDATE SKIP LOCKED 로 동시 실행 race 회피.
CREATE OR REPLACE FUNCTION claim_next_pending_reply_job(p_grace_seconds INT DEFAULT 30)
RETURNS pending_character_reply_jobs
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_job pending_character_reply_jobs;
BEGIN
  WITH next_job AS (
    SELECT id
    FROM pending_character_reply_jobs
    WHERE status = 'pending'
      AND next_attempt_at <= now()
      AND created_at <= now() - make_interval(secs => p_grace_seconds)
    ORDER BY created_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED
  )
  UPDATE pending_character_reply_jobs j
  SET
    status = 'processing',
    started_at = COALESCE(j.started_at, now()),
    attempt_count = j.attempt_count + 1,
    updated_at = now()
  FROM next_job
  WHERE j.id = next_job.id
  RETURNING j.* INTO v_job;

  RETURN v_job;
END;
$$;

REVOKE ALL ON FUNCTION claim_next_pending_reply_job(INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION claim_next_pending_reply_job(INT) TO service_role;

COMMENT ON FUNCTION claim_next_pending_reply_job(INT) IS
  'cron 픽업: 가장 오래된 pending row 1개 atomic 클레임. '
  'p_grace_seconds 안의 row 는 클라 invoke 에 양보.';

-- =============================================================================
-- claim_pending_reply_job_by_id — character-chat 가 클라가 보낸 jobId 로 클레임.
-- 이미 processing/done/canceled 면 NULL (= 다른 워커가 가져갔거나 superseded).
CREATE OR REPLACE FUNCTION claim_pending_reply_job_by_id(p_job_id UUID)
RETURNS pending_character_reply_jobs
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_job pending_character_reply_jobs;
BEGIN
  UPDATE pending_character_reply_jobs
  SET
    status = 'processing',
    started_at = COALESCE(started_at, now()),
    attempt_count = attempt_count + 1,
    updated_at = now()
  WHERE id = p_job_id AND status = 'pending'
  RETURNING * INTO v_job;

  RETURN v_job;
END;
$$;

REVOKE ALL ON FUNCTION claim_pending_reply_job_by_id(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION claim_pending_reply_job_by_id(UUID) TO service_role;

COMMENT ON FUNCTION claim_pending_reply_job_by_id(UUID) IS
  'character-chat 가 받은 jobId 로 atomic 클레임. NULL 반환이면 이미 처리 중.';

-- =============================================================================
-- 보존정책: 종료된 job 은 7일 후 정리. cron 에서 호출.
CREATE OR REPLACE FUNCTION cleanup_pending_reply_jobs(p_retention_days INT DEFAULT 7)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_deleted INT;
BEGIN
  WITH d AS (
    DELETE FROM pending_character_reply_jobs
    WHERE status IN ('done', 'failed', 'canceled')
      AND updated_at < now() - make_interval(days => p_retention_days)
    RETURNING 1
  )
  SELECT COUNT(*) INTO v_deleted FROM d;
  RETURN v_deleted;
END;
$$;

REVOKE ALL ON FUNCTION cleanup_pending_reply_jobs(INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION cleanup_pending_reply_jobs(INT) TO service_role;

-- =============================================================================
-- 스턱 잡 복구: processing 상태로 5분 이상 멈춰있는 row 는 다시 pending 으로.
-- (Edge Function 타임아웃, OOM, 크래시 등으로 마무리 못 한 케이스)
CREATE OR REPLACE FUNCTION recover_stuck_pending_reply_jobs(p_stuck_minutes INT DEFAULT 5)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_recovered INT;
BEGIN
  WITH r AS (
    UPDATE pending_character_reply_jobs
    SET status = 'pending',
        next_attempt_at = now(),
        updated_at = now()
    WHERE status = 'processing'
      AND started_at < now() - make_interval(mins => p_stuck_minutes)
      AND attempt_count < 3
    RETURNING 1
  )
  SELECT COUNT(*) INTO v_recovered FROM r;

  -- 시도횟수 초과 stuck 은 failed 로.
  UPDATE pending_character_reply_jobs
  SET status = 'failed',
      error_message = COALESCE(error_message, '') || '[stuck max attempts]',
      completed_at = now(),
      updated_at = now()
  WHERE status = 'processing'
    AND started_at < now() - make_interval(mins => p_stuck_minutes)
    AND attempt_count >= 3;

  RETURN v_recovered;
END;
$$;

REVOKE ALL ON FUNCTION recover_stuck_pending_reply_jobs(INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION recover_stuck_pending_reply_jobs(INT) TO service_role;
