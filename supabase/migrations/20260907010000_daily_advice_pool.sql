-- Identity-free daily advice only. Never copy personalized legacy cohort rows.
CREATE TABLE public.daily_advice_pool (
  condition_hash text NOT NULL CHECK (condition_hash ~ '^[a-f0-9]{64}$'),
  prompt_version text NOT NULL CHECK (length(prompt_version) BETWEEN 1 AND 80),
  variants jsonb NOT NULL DEFAULT '[]'::jsonb
    CHECK (jsonb_typeof(variants) = 'array' AND jsonb_array_length(variants) <= 3),
  lease_token uuid,
  lease_expires_at timestamptz,
  expires_at timestamptz NOT NULL DEFAULT now() + interval '30 days',
  hit_count bigint NOT NULL DEFAULT 0,
  generation_count bigint NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (condition_hash, prompt_version)
);

ALTER TABLE public.daily_advice_pool ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.daily_advice_pool FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.daily_advice_pool TO service_role;
CREATE POLICY daily_advice_pool_service ON public.daily_advice_pool
  FOR ALL TO service_role USING (true) WITH CHECK (true);

-- A row lock exists only for this RPC, never while an external model is running.
CREATE FUNCTION public.claim_daily_advice(p_condition_hash text, p_prompt_version text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  item public.daily_advice_pool%ROWTYPE;
  token uuid;
  count integer;
BEGIN
  INSERT INTO public.daily_advice_pool(condition_hash, prompt_version)
    VALUES (p_condition_hash, p_prompt_version)
    ON CONFLICT DO NOTHING;
  SELECT * INTO STRICT item FROM public.daily_advice_pool
    WHERE condition_hash = p_condition_hash AND prompt_version = p_prompt_version
    FOR UPDATE;

  IF item.expires_at <= now() THEN
    UPDATE public.daily_advice_pool SET variants = '[]'::jsonb,
      lease_token = NULL, lease_expires_at = NULL,
      expires_at = now() + interval '30 days', updated_at = now()
      WHERE condition_hash = p_condition_hash AND prompt_version = p_prompt_version
      RETURNING * INTO item;
  END IF;
  count := jsonb_array_length(item.variants);

  -- Once three samples exist, generation stops. During warmup contention,
  -- reuse an existing sample; a completely cold row returns a cheap fallback.
  IF count >= 3 OR (count > 0 AND item.lease_expires_at > now()) THEN
    UPDATE public.daily_advice_pool SET hit_count = hit_count + 1, updated_at = now()
      WHERE condition_hash = p_condition_hash AND prompt_version = p_prompt_version;
    RETURN jsonb_build_object('action', 'hit', 'advice', item.variants->floor(random() * count)::integer);
  END IF;
  IF item.lease_expires_at > now() THEN
    RETURN jsonb_build_object('action', 'busy');
  END IF;

  token := gen_random_uuid();
  UPDATE public.daily_advice_pool SET lease_token = token,
    lease_expires_at = now() + interval '90 seconds', updated_at = now()
    WHERE condition_hash = p_condition_hash AND prompt_version = p_prompt_version;
  RETURN jsonb_build_object('action', 'generate', 'leaseToken', token);
END;
$$;

CREATE FUNCTION public.complete_daily_advice(
  p_condition_hash text, p_prompt_version text, p_lease_token uuid, p_advice jsonb
) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  changed integer;
BEGIN
  -- A null result releases a failed generation without caching its fallback.
  IF p_advice IS NOT NULL AND (
    jsonb_typeof(p_advice) NOT IN ('string', 'object') OR
    octet_length(p_advice::text) > 16000
  ) THEN
    RAISE EXCEPTION 'Invalid advice payload';
  END IF;

  UPDATE public.daily_advice_pool SET
    variants = CASE WHEN p_advice IS NULL THEN variants ELSE variants || jsonb_build_array(p_advice) END,
    generation_count = generation_count + CASE WHEN p_advice IS NULL THEN 0 ELSE 1 END,
    lease_token = NULL, lease_expires_at = NULL, updated_at = now()
    WHERE condition_hash = p_condition_hash AND prompt_version = p_prompt_version
      AND lease_token = p_lease_token AND lease_expires_at > now()
      AND expires_at > now() AND jsonb_array_length(variants) < 3;
  GET DIAGNOSTICS changed = ROW_COUNT;
  RETURN changed = 1;
END;
$$;

REVOKE ALL ON FUNCTION public.claim_daily_advice(text, text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.complete_daily_advice(text, text, uuid, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_daily_advice(text, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.complete_daily_advice(text, text, uuid, jsonb) TO service_role;

COMMENT ON TABLE public.daily_advice_pool IS
  'Private, identity-free daily advice. Three variants per condition/version; 30-day TTL; atomic 90-second generation lease. Expired rows are reset on use.';
