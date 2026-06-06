-- P0: poster/image fortune jobs must be charged before they can enter the worker queue.
-- Fixes unsafe client order: queue INSERT first, token consume later.

ALTER TABLE public.scheduled_poster_jobs
  ADD COLUMN IF NOT EXISTS charge_transaction_id UUID,
  ADD COLUMN IF NOT EXISTS charge_reference_id TEXT;

CREATE INDEX IF NOT EXISTS idx_poster_jobs_pending_charged
  ON public.scheduled_poster_jobs (created_at)
  WHERE status = 'pending' AND charge_transaction_id IS NOT NULL;

DROP FUNCTION IF EXISTS public.schedule_poster_job_with_charge(
  UUID,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  INTEGER
);

CREATE OR REPLACE FUNCTION public.schedule_poster_job_with_charge(
  p_user_id UUID,
  p_character_id TEXT,
  p_character_name TEXT,
  p_poster_type TEXT,
  p_image_base64 TEXT,
  p_context_text TEXT,
  p_cost INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $schedule_poster_job_with_charge$
DECLARE
  v_job_id UUID := gen_random_uuid();
  v_active_count INTEGER := 0;
  v_reference_id TEXT;
  v_consume JSONB;
  v_subscription_id UUID;
BEGIN
  IF p_user_id IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'missing user id', 'code', 'UNAUTHORIZED');
  END IF;
  IF p_character_id IS NULL OR btrim(p_character_id) = '' OR
     p_character_name IS NULL OR btrim(p_character_name) = '' THEN
    RETURN jsonb_build_object('success', false, 'error', 'character info missing', 'code', 'INVALID_REQUEST');
  END IF;
  IF p_poster_type IS NULL OR btrim(p_poster_type) = '' THEN
    RETURN jsonb_build_object('success', false, 'error', 'poster type missing', 'code', 'INVALID_REQUEST');
  END IF;
  IF p_cost IS NULL OR p_cost <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid cost', 'code', 'INVALID_CONFIGURATION');
  END IF;

  -- Serialize per user so active-count and token charge/job insert cannot race.
  PERFORM pg_advisory_xact_lock(hashtextextended('poster-job:' || p_user_id::text, 0));

  SELECT COUNT(*)
    INTO v_active_count
    FROM public.scheduled_poster_jobs
   WHERE user_id = p_user_id
     AND status IN ('pending', 'processing');

  IF v_active_count >= 5 THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', '진행 중인 운세가 너무 많습니다. 끝난 후 다시 시도해주세요.',
      'code', 'QUEUE_LIMIT_REACHED'
    );
  END IF;

  v_reference_id := 'fortune:' || p_character_id || ':' || p_poster_type || ':' || v_job_id::text;

  SELECT id
    INTO v_subscription_id
    FROM public.subscriptions
   WHERE user_id = p_user_id
     AND status = 'active'
     AND expires_at > NOW()
   ORDER BY expires_at DESC
   LIMIT 1;

  IF v_subscription_id IS NULL THEN
    -- Same idempotency/reference id as the eventual job id. Because this function
    -- runs in one DB transaction, INSERT failure rolls the consume back too.
    v_consume := public.consume_token_atomic(
      p_user_id,
      p_cost,
      p_poster_type || ' 운세 이용',
      'fortune',
      v_reference_id,
      v_reference_id
    );
  ELSE
    v_consume := jsonb_build_object(
      'balance', NULL,
      'total_earned', NULL,
      'total_spent', NULL,
      'replayed', false,
      'transaction_id', NULL,
      'subscriptionId', v_subscription_id
    );
  END IF;

  INSERT INTO public.scheduled_poster_jobs (
    id,
    user_id,
    character_id,
    character_name,
    poster_type,
    image_base64,
    context_text,
    status,
    charge_transaction_id,
    charge_reference_id
  ) VALUES (
    v_job_id,
    p_user_id,
    p_character_id,
    p_character_name,
    p_poster_type,
    p_image_base64,
    p_context_text,
    'pending',
    CASE
      WHEN (v_consume->>'transaction_id') IS NULL OR (v_consume->>'transaction_id') = ''
        THEN v_job_id
      ELSE (v_consume->>'transaction_id')::uuid
    END,
    v_reference_id
  );

  RETURN jsonb_build_object(
    'success', true,
    'jobId', v_job_id,
    'status', 'pending',
    'estimatedSeconds', 60,
    'chargeReferenceId', v_reference_id,
    'chargeTransactionId', v_consume->>'transaction_id',
    'isUnlimited', v_subscription_id IS NOT NULL,
    'replayed', COALESCE((v_consume->>'replayed')::boolean, false)
  );
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', '토큰이 부족합니다',
      'code', 'INSUFFICIENT_TOKENS'
    );
END;
$schedule_poster_job_with_charge$;


CREATE OR REPLACE FUNCTION public.claim_next_poster_job()
RETURNS public.scheduled_poster_jobs
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $claim_next_poster_job$
DECLARE
  v_job public.scheduled_poster_jobs;
BEGIN
  -- Only charged jobs are claimable. Any legacy/orphan pending row without
  -- charge_transaction_id remains inert and cannot spend OpenAI image quota.
  WITH next_job AS (
    SELECT id
      FROM public.scheduled_poster_jobs
     WHERE status = 'pending'
       AND charge_transaction_id IS NOT NULL
     ORDER BY created_at ASC
     LIMIT 1
     FOR UPDATE SKIP LOCKED
  )
  UPDATE public.scheduled_poster_jobs sj
     SET status = 'processing',
         started_at = NOW(),
         retry_count = retry_count + 1
    FROM next_job
   WHERE sj.id = next_job.id
  RETURNING sj.* INTO v_job;

  RETURN v_job;
END;
$claim_next_poster_job$;

