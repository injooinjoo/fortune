\set ON_ERROR_STOP on
BEGIN;

DO $$
DECLARE
  hash text := repeat('a', 64);
  claim jsonb;
  old_token uuid;
  next_token uuid;
  result boolean;
BEGIN
  claim := public.claim_daily_advice(hash, 'test-v1');
  ASSERT claim->>'action' = 'generate', 'cold pool must reserve one generation';
  old_token := (claim->>'leaseToken')::uuid;
  ASSERT public.claim_daily_advice(hash, 'test-v1')->>'action' = 'busy', 'second cold request must not generate';
  ASSERT NOT public.complete_daily_advice(hash, 'test-v1', gen_random_uuid(), '"wrong owner"'), 'lease fencing';
  ASSERT public.complete_daily_advice(hash, 'test-v1', old_token, '"sample one"'), 'first completion';
  ASSERT NOT public.complete_daily_advice(hash, 'test-v1', old_token, '"duplicate"'), 'same lease cannot commit twice';

  claim := public.claim_daily_advice(hash, 'test-v1');
  ASSERT claim->>'action' = 'generate', 'warmup must grow beyond one sample';
  old_token := (claim->>'leaseToken')::uuid;
  ASSERT public.claim_daily_advice(hash, 'test-v1')->>'action' = 'hit', 'contention reuses an existing sample';
  ASSERT public.complete_daily_advice(hash, 'test-v1', old_token, '"sample two"');
  claim := public.claim_daily_advice(hash, 'test-v1');
  ASSERT claim->>'action' = 'generate';
  ASSERT public.complete_daily_advice(hash, 'test-v1', (claim->>'leaseToken')::uuid, '"sample three"');
  ASSERT public.claim_daily_advice(hash, 'test-v1')->>'action' = 'hit', 'three samples stop generation';
  ASSERT (SELECT jsonb_array_length(variants) = 3 AND generation_count = 3 FROM public.daily_advice_pool WHERE condition_hash = hash AND prompt_version = 'test-v1');

  ASSERT public.claim_daily_advice(hash, 'test-v2')->>'action' = 'generate', 'prompt versions are isolated';
  UPDATE public.daily_advice_pool SET expires_at = now() - interval '1 second' WHERE condition_hash = hash AND prompt_version = 'test-v1';
  claim := public.claim_daily_advice(hash, 'test-v1');
  ASSERT claim->>'action' = 'generate', 'expired content is not reused';
  old_token := (claim->>'leaseToken')::uuid;
  ASSERT (SELECT variants = '[]'::jsonb FROM public.daily_advice_pool WHERE condition_hash = hash AND prompt_version = 'test-v1');
  UPDATE public.daily_advice_pool SET lease_expires_at = now() - interval '1 second' WHERE condition_hash = hash AND prompt_version = 'test-v1';
  claim := public.claim_daily_advice(hash, 'test-v1');
  next_token := (claim->>'leaseToken')::uuid;
  ASSERT next_token <> old_token, 'expired leases get a new fence';
  ASSERT NOT public.complete_daily_advice(hash, 'test-v1', old_token, '"stale completion"');
  ASSERT public.complete_daily_advice(hash, 'test-v1', next_token, NULL), 'failure releases without storing';
  ASSERT (SELECT variants = '[]'::jsonb FROM public.daily_advice_pool WHERE condition_hash = hash AND prompt_version = 'test-v1');

  ASSERT NOT has_table_privilege('anon', 'public.daily_advice_pool', 'SELECT');
  ASSERT NOT has_table_privilege('authenticated', 'public.daily_advice_pool', 'SELECT');
  ASSERT NOT has_function_privilege('anon', 'public.claim_daily_advice(text,text)', 'EXECUTE');
  ASSERT NOT has_function_privilege('authenticated', 'public.complete_daily_advice(text,text,uuid,jsonb)', 'EXECUTE');
  ASSERT has_function_privilege('service_role', 'public.claim_daily_advice(text,text)', 'EXECUTE');
END;
$$;

SET LOCAL ROLE anon;
DO $$ BEGIN
  PERFORM public.claim_daily_advice(repeat('b',64), 'test-v1');
  RAISE EXCEPTION 'anon unexpectedly claimed a generation';
EXCEPTION WHEN insufficient_privilege THEN NULL; END $$;
RESET ROLE;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
  PERFORM * FROM public.daily_advice_pool;
  RAISE EXCEPTION 'authenticated unexpectedly read shared content';
EXCEPTION WHEN insufficient_privilege THEN NULL; END $$;
RESET ROLE;
SET LOCAL ROLE service_role;
DO $$ BEGIN
  ASSERT public.claim_daily_advice(repeat('b',64), 'test-v1')->>'action' = 'generate';
END $$;
RESET ROLE;

ROLLBACK;
SELECT 'daily advice pool: threshold, lease fencing, TTL, version and role checks passed' AS result;
