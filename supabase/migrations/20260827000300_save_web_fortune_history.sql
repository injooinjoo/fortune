ALTER TABLE public.fortune_history
  ADD COLUMN IF NOT EXISTS history_key TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_fortune_history_web_idempotency
  ON public.fortune_history(user_id, history_key)
  WHERE history_key IS NOT NULL;

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE public.fortune_history FROM anon, authenticated;
GRANT SELECT ON TABLE public.fortune_history TO authenticated;
GRANT ALL ON TABLE public.fortune_history TO service_role;

CREATE OR REPLACE FUNCTION public.save_web_fortune_history(
  p_fortune_type TEXT,
  p_title TEXT,
  p_summary JSONB,
  p_fortune_data JSONB,
  p_score INTEGER,
  p_history_key TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_user_id UUID := auth.uid();
  v_history_id UUID;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'AUTH_REQUIRED' USING ERRCODE = '42501';
  END IF;
  IF p_fortune_type IS NULL OR char_length(p_fortune_type) NOT BETWEEN 1 AND 50 THEN
    RAISE EXCEPTION 'INVALID_FORTUNE_TYPE' USING ERRCODE = '22023';
  END IF;
  IF p_title IS NULL OR char_length(p_title) NOT BETWEEN 1 AND 120 THEN
    RAISE EXCEPTION 'INVALID_FORTUNE_TITLE' USING ERRCODE = '22023';
  END IF;
  IF p_history_key IS NULL OR p_history_key !~ '^[a-f0-9]{64}$' THEN
    RAISE EXCEPTION 'INVALID_HISTORY_KEY' USING ERRCODE = '22023';
  END IF;
  IF jsonb_typeof(p_summary) <> 'object' OR pg_column_size(p_summary) > 16384 THEN
    RAISE EXCEPTION 'INVALID_FORTUNE_SUMMARY' USING ERRCODE = '22023';
  END IF;
  IF jsonb_typeof(p_fortune_data) NOT IN ('object', 'array')
     OR pg_column_size(p_fortune_data) > 262144 THEN
    RAISE EXCEPTION 'INVALID_FORTUNE_DATA' USING ERRCODE = '22023';
  END IF;
  IF p_score IS NOT NULL AND p_score NOT BETWEEN 0 AND 100 THEN
    RAISE EXCEPTION 'INVALID_FORTUNE_SCORE' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.fortune_history (
    user_id,
    fortune_type,
    title,
    summary,
    fortune_data,
    score,
    metadata,
    history_key
  ) VALUES (
    v_user_id,
    p_fortune_type,
    p_title,
    p_summary,
    p_fortune_data,
    p_score,
    jsonb_build_object('source', 'web'),
    p_history_key
  )
  ON CONFLICT (user_id, history_key) WHERE history_key IS NOT NULL
  DO UPDATE SET last_viewed_at = now()
  RETURNING id INTO v_history_id;

  RETURN v_history_id;
END;
$function$;
