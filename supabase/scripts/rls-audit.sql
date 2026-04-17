-- RLS audit diagnostic.
--
-- Run against the production Supabase project:
--   supabase db dump --linked --role postgres --file - < supabase/scripts/rls-audit.sql
-- or paste into the SQL editor in the Supabase dashboard.
--
-- Reports every table in the `public` schema that does NOT have Row Level
-- Security enabled. Under the current anon API key, any such table is
-- readable by anonymous clients, which is the P0 finding from the service
-- review (20+ tables exposed).
--
-- Expected healthy state: ZERO rows returned.

SELECT
  n.nspname AS schema,
  c.relname AS table_name,
  c.relrowsecurity AS rls_enabled,
  c.relforcerowsecurity AS rls_forced,
  (
    SELECT count(*) FROM pg_policies p
    WHERE p.schemaname = n.nspname AND p.tablename = c.relname
  ) AS policy_count
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
  AND n.nspname = 'public'
  AND c.relrowsecurity = FALSE
ORDER BY c.relname;

-- Secondary: tables WITH RLS but ZERO policies — those effectively deny-all,
-- which is also suspect (usually means a policy was dropped by mistake).
SELECT
  n.nspname AS schema,
  c.relname AS table_name,
  c.relrowsecurity AS rls_enabled,
  (
    SELECT count(*) FROM pg_policies p
    WHERE p.schemaname = n.nspname AND p.tablename = c.relname
  ) AS policy_count
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
  AND n.nspname = 'public'
  AND c.relrowsecurity = TRUE
  AND (
    SELECT count(*) FROM pg_policies p
    WHERE p.schemaname = n.nspname AND p.tablename = c.relname
  ) = 0
ORDER BY c.relname;
