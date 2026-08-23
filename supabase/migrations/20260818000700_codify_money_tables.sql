-- 원장 테이블 스키마/권한 성문화.
--
-- token_balance 와 token_transactions 는 supabase/migrations/*.sql 어디에도
-- CREATE TABLE 도 RLS DDL 도 없다 — 대시보드에서 out-of-band 로 생성됐다.
-- 브라우저에 anon key 가 실려나가는 웹 출시 전에 실제 정책을 마이그레이션으로
-- 고정해야 한다. 아래 정의는 2026-08-18 라이브 introspection 결과와 일치한다.
--
-- 실측 결과 요약:
--   token_balance       RLS ON, 정책은 SELECT 1개뿐 (user_id = auth.uid())
--   token_transactions  RLS ON, 정책은 SELECT 1개뿐 (user_id = auth.uid())
--   verified_purchases  RLS ON, verified_purchases_self_read (authenticated)
--   subscriptions       RLS ON, service_role ALL + 본인 SELECT
--   → INSERT/UPDATE/DELETE 정책이 없으므로 RLS 가 클라이언트 쓰기를 이미 막고 있다.
--
-- 다만 네 테이블 모두 anon/authenticated 에게 테이블 수준
-- INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER 권한이 남아 있다
-- (Supabase 기본 GRANT ALL). TRUNCATE 는 RLS 적용 대상이 아니다.
-- PostgREST 가 TRUNCATE 를 발행하지 않아 현재 공개 API 로는 도달 불가하지만,
-- RLS 하나에만 의존하지 않도록 쓰기 권한 자체를 회수한다.
--
-- 클라이언트 직접 접근 확인 (grep apps/mobile-rn):
--   subscriptions  → premium-remote.ts:164 SELECT only
--   token_balance / token_transactions / verified_purchases → 직접 접근 0건
--   전부 Edge Function(service_role) 경유. SELECT 만 남겨도 회귀 없음.
--
-- daily_free_fortune 은 본 마이그레이션에서 건드리지 않는다 — 사용자 INSERT 정책이
-- 있고 클라이언트 삽입 경로를 확정하지 못했다. 웹 게스트 퍼널 작업 시 재검토.

-- ── 스키마 성문화 (이미 존재하면 no-op) ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS token_balance (
  user_id       UUID PRIMARY KEY,
  balance       INTEGER NOT NULL DEFAULT 0,
  total_earned  INTEGER NOT NULL DEFAULT 0,
  total_spent   INTEGER NOT NULL DEFAULT 0,
  last_daily_claim TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS token_transactions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL,
  transaction_type TEXT NOT NULL,
  amount           INTEGER NOT NULL,
  balance_after    INTEGER NOT NULL,
  description      TEXT,
  reference_id     TEXT,
  reference_type   TEXT,
  created_at       TIMESTAMPTZ DEFAULT now(),
  idempotency_key  TEXT
);

ALTER TABLE token_balance      ENABLE ROW LEVEL SECURITY;
ALTER TABLE token_transactions ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy
     WHERE polrelid = 'public.token_balance'::regclass
       AND polname = 'Users can view own token balance'
  ) THEN
    CREATE POLICY "Users can view own token balance"
      ON token_balance FOR SELECT
      USING (user_id = auth.uid());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policy
     WHERE polrelid = 'public.token_transactions'::regclass
       AND polname = 'Users can view own token transactions'
  ) THEN
    CREATE POLICY "Users can view own token transactions"
      ON token_transactions FOR SELECT
      USING (user_id = auth.uid());
  END IF;
END $$;

-- ── 클라이언트 쓰기 권한 회수 (RLS 에만 의존하지 않는다) ────────────────────

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE token_balance      FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE token_transactions FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE verified_purchases FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLE subscriptions      FROM anon, authenticated;

-- SELECT 는 유지 (RLS 정책이 본인 행으로 좁힌다).
GRANT SELECT ON TABLE token_balance      TO authenticated;
GRANT SELECT ON TABLE token_transactions TO authenticated;
GRANT SELECT ON TABLE verified_purchases TO authenticated;
GRANT SELECT ON TABLE subscriptions      TO authenticated;

-- service_role 은 모든 권한 유지 (Edge Function 이 유일한 쓰기 주체).
GRANT ALL ON TABLE token_balance      TO service_role;
GRANT ALL ON TABLE token_transactions TO service_role;
GRANT ALL ON TABLE verified_purchases TO service_role;
GRANT ALL ON TABLE subscriptions      TO service_role;

COMMENT ON TABLE token_balance IS
  '토큰 잔액 원장. 쓰기는 service_role Edge Function 경유 RPC 만 허용된다.';
COMMENT ON TABLE token_transactions IS
  '토큰 거래 이력. transaction_type 허용값은 token_transactions_transaction_type_check 참고.';
