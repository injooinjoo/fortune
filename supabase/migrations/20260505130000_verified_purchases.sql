-- /ultrareview BM P0 #1 + #3 보강: 결제 검증 단일 진실 소스.
--
-- payment-verify-purchase 가 Apple/Google 검증 통과 시 이 테이블에 INSERT.
-- subscription-activate / 기타 결제-후속 함수는 이 테이블 lookup 으로만
-- 가입 활성화 가능 — 클라가 productId/purchaseId 만 들고 직접 호출하는 우회
-- 경로 차단.
--
-- (user_id, platform, verified_transaction_id) UNIQUE → replay 차단 (DB-level).
-- payment-verify-purchase 의 token_transactions 기반 replay 체크와 중복이지만
-- 의도적 — 토큰 미지급 product (subscription 등) 도 여기엔 기록되므로.

CREATE TABLE IF NOT EXISTS verified_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
  verified_product_id TEXT NOT NULL,
  verified_transaction_id TEXT NOT NULL,
  environment TEXT,
  verified_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  consumed_for_subscription BOOLEAN NOT NULL DEFAULT false,
  consumed_for_token_grant BOOLEAN NOT NULL DEFAULT false,
  raw_meta JSONB DEFAULT '{}'::jsonb
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_verified_purchases_replay
  ON verified_purchases (user_id, platform, verified_transaction_id);

CREATE INDEX IF NOT EXISTS idx_verified_purchases_user
  ON verified_purchases (user_id, verified_at DESC);

ALTER TABLE verified_purchases ENABLE ROW LEVEL SECURITY;

-- 사용자는 자기 row 만 읽을 수 있음. 쓰기는 service_role 만 (Edge Function).
CREATE POLICY verified_purchases_self_read
  ON verified_purchases FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

COMMENT ON TABLE verified_purchases IS
  'Apple/Google 영수증 검증 통과 기록. subscription-activate / token grant 의 단일 진실 소스 (P0 BM #1, #3).';
