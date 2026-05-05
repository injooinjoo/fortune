-- /ultrareview BM P0 #2: soul-refund 무한 환불 차단.
-- 같은 (user_id, transaction_type='refund', reference_id) 조합은 1번만 허용.
-- application-level 의 existingRefund lookup 이 race 또는 버그로 우회되어도
-- DB 가 두 번째 INSERT 를 거부.

CREATE UNIQUE INDEX IF NOT EXISTS idx_token_transactions_refund_unique
  ON token_transactions (user_id, reference_id)
  WHERE transaction_type = 'refund' AND reference_id IS NOT NULL;

COMMENT ON INDEX idx_token_transactions_refund_unique IS
  'soul-refund replay 방지. 같은 referenceId 로 두 번 환불 차단.';
