-- Keep the static RLS audit green for the internal migration log table.
-- The original hardening migration lives in _archived, which the CI audit does
-- not scan. Re-declaring it here is idempotent and preserves service-role-only
-- access.

DO $$
BEGIN
  IF to_regclass('public.migration_log') IS NULL THEN
    RETURN;
  END IF;

  ALTER TABLE public.migration_log ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.migration_log FORCE ROW LEVEL SECURITY;

  DROP POLICY IF EXISTS "Service role only" ON public.migration_log;
  DROP POLICY IF EXISTS "Public read" ON public.migration_log;
  DROP POLICY IF EXISTS "Authenticated read" ON public.migration_log;

  REVOKE ALL ON public.migration_log FROM PUBLIC;
  REVOKE ALL ON public.migration_log FROM anon;
  REVOKE ALL ON public.migration_log FROM authenticated;
  GRANT SELECT, INSERT, UPDATE, DELETE ON public.migration_log TO service_role;
END $$;
