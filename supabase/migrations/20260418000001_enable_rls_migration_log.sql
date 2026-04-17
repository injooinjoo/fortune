-- Enable Row Level Security on public.migration_log.
--
-- migration_log is an internal audit/bookkeeping table. Without RLS, anonymous
-- clients with the Supabase anon key can read every migration history entry,
-- which leaks the schema evolution timeline + internal comments. This
-- migration enables RLS and installs a deny-all default for anon + authenticated
-- roles. Only the service_role (server-side) can read/write migration_log.

ALTER TABLE IF EXISTS public.migration_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.migration_log FORCE ROW LEVEL SECURITY;

-- Drop any stale permissive policy so the deny-all default takes effect.
DROP POLICY IF EXISTS "Service role only" ON public.migration_log;
DROP POLICY IF EXISTS "Public read" ON public.migration_log;
DROP POLICY IF EXISTS "Authenticated read" ON public.migration_log;

-- No policy is intentionally created. Without a policy, both anon and
-- authenticated roles are denied by RLS. The service_role bypasses RLS.

REVOKE ALL ON public.migration_log FROM PUBLIC;
REVOKE ALL ON public.migration_log FROM anon;
REVOKE ALL ON public.migration_log FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.migration_log TO service_role;
