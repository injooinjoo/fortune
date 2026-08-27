CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role NOLOGIN;
  END IF;
END
$$;

CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE auth.users (
  id UUID PRIMARY KEY,
  is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION auth.uid()
RETURNS UUID
LANGUAGE SQL
STABLE
AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.sub', TRUE), '')::UUID;
$$;

CREATE TABLE public.token_balance (
  user_id UUID PRIMARY KEY,
  balance INTEGER NOT NULL DEFAULT 0,
  total_earned INTEGER NOT NULL DEFAULT 0,
  total_spent INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.token_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  transaction_type TEXT NOT NULL CHECK (
    transaction_type IN ('earn', 'spend', 'purchase', 'refund', 'consumption', 'chargeback')
  ),
  amount INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  description TEXT,
  reference_id TEXT,
  reference_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  idempotency_key TEXT
);

CREATE UNIQUE INDEX idx_token_transactions_idempotency_key
  ON public.token_transactions (user_id, idempotency_key)
  WHERE idempotency_key IS NOT NULL;

CREATE OR REPLACE FUNCTION public.grant_initial_tokens()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.token_balance (user_id, balance, total_earned, created_at, updated_at)
  VALUES (NEW.id, 50, 50, NOW(), NOW())
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created_grant_tokens
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.grant_initial_tokens();

-- Existing production-era accounts received the legacy 50-token grant before
-- the new 5 + 45 policy migration is applied.
INSERT INTO auth.users (id, is_anonymous)
VALUES
  ('00000000-0000-0000-0000-000000000090', TRUE),
  ('00000000-0000-0000-0000-000000000091', FALSE);
