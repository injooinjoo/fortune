-- Privacy-minimized web funnel/error telemetry.
-- Direct table access is denied; clients can only call the validated RPC.

CREATE TABLE IF NOT EXISTS public.web_analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_name TEXT NOT NULL CHECK (event_name IN (
    'page_view',
    'auth_started',
    'auth_completed',
    'fortune_started',
    'fortune_completed',
    'chat_started',
    'chat_completed',
    'payment_started',
    'payment_completed',
    'client_error'
  )),
  session_id UUID NOT NULL,
  path TEXT NOT NULL CHECK (char_length(path) BETWEEN 1 AND 500),
  properties JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_web_analytics_events_created
  ON public.web_analytics_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_web_analytics_events_funnel
  ON public.web_analytics_events(event_name, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_web_analytics_events_user_rate
  ON public.web_analytics_events(user_id, created_at DESC);

ALTER TABLE public.web_analytics_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.web_analytics_events FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.record_web_analytics_event(
  p_event_name TEXT,
  p_session_id UUID,
  p_path TEXT,
  p_properties JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_event_id UUID;
  v_properties JSONB := COALESCE(p_properties, '{}'::jsonb);
BEGIN
  -- Do not create a tracking identity for signed-out visitors. Anonymous Supabase
  -- users have an auth.uid() and are covered by the same deletion lifecycle.
  IF v_user_id IS NULL THEN
    RETURN NULL;
  END IF;

  IF p_event_name IS NULL OR p_event_name NOT IN (
    'page_view',
    'auth_started',
    'auth_completed',
    'fortune_started',
    'fortune_completed',
    'chat_started',
    'chat_completed',
    'payment_started',
    'payment_completed',
    'client_error'
  ) THEN
    RAISE EXCEPTION 'unsupported analytics event' USING ERRCODE = '22023';
  END IF;

  IF p_session_id IS NULL THEN
    RAISE EXCEPTION 'analytics session is required' USING ERRCODE = '22023';
  END IF;

  IF p_path IS NULL OR char_length(p_path) NOT BETWEEN 1 AND 500 THEN
    RAISE EXCEPTION 'invalid analytics path' USING ERRCODE = '22023';
  END IF;

  IF jsonb_typeof(v_properties) <> 'object' OR pg_column_size(v_properties) > 2048 THEN
    RAISE EXCEPTION 'invalid analytics properties' USING ERRCODE = '22023';
  END IF;

  -- Per-account protection for both anonymous and linked accounts.
  IF (
    SELECT count(*)
    FROM public.web_analytics_events
    WHERE user_id = v_user_id
      AND created_at > now() - INTERVAL '1 hour'
  ) >= 120 THEN
    RETURN NULL;
  END IF;

  INSERT INTO public.web_analytics_events (
    user_id,
    event_name,
    session_id,
    path,
    properties
  ) VALUES (
    v_user_id,
    p_event_name,
    p_session_id,
    p_path,
    v_properties
  )
  RETURNING id INTO v_event_id;

  RETURN v_event_id;
END;
$$;

REVOKE ALL ON FUNCTION public.record_web_analytics_event(TEXT, UUID, TEXT, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.record_web_analytics_event(TEXT, UUID, TEXT, JSONB)
  TO anon, authenticated;

COMMENT ON TABLE public.web_analytics_events IS
  'Privacy-minimized Ondo web funnel and error events. Delete with the owning auth user; operational retention target is 90 days.';
COMMENT ON FUNCTION public.record_web_analytics_event(TEXT, UUID, TEXT, JSONB) IS
  'Records an allowlisted, size-bounded analytics event for the current authenticated or anonymous Supabase user.';
