-- /ultrareview BM P0 #3: payment-verify-purchase replay 방지를 위한 DB-level
-- UNIQUE 제약. application-level 체크 (existingTxn lookup) 가 race 또는 버그로
-- 우회되어도 DB 가 두 번째 INSERT 를 거부하도록 안전망 추가.
--
-- 같은 (user_id, transaction_type='purchase', reference_id) 조합은 1번만 가능.
-- reference_id 가 NULL 인 row 는 제약 미적용 (legacy 보호).
--
-- 기존 데이터에 중복이 있으면 마이그레이션 실패 — 그 경우 사전에 dedup 필요.
-- (DB advisor 에서 dedup 쿼리 별도 안내.)

CREATE UNIQUE INDEX IF NOT EXISTS idx_token_transactions_purchase_unique
  ON token_transactions (user_id, reference_id)
  WHERE transaction_type = 'purchase' AND reference_id IS NOT NULL;

COMMENT ON INDEX idx_token_transactions_purchase_unique IS
  'payment-verify-purchase replay 방지. 같은 verified transaction id 로 두 번 지급 차단.';
