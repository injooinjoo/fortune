-- PR-0a: token_transactions에 idempotency_key 추가.
-- 클라가 네트워크 실패/재시도 후 같은 요청을 재전송할 때 이중 차감 차단.
--
-- 마이그레이션 안전 패턴:
-- 1) NULLABLE 컬럼 추가 — 옛 클라(키 미전송) 정상
-- 2) Partial unique index — NULL 허용, 비-NULL만 unique
-- 3) NOT NULL 강제 안 함 — 모든 클라가 키 전송한다고 보장 못 함
--
-- 호환성:
-- - 옛 row의 idempotency_key 는 NULL — partial index 영향 없음
-- - 옛 클라가 키 미전송 — 서버는 idempotency 우회, 기존 동작 유지
-- - 새 클라가 키 전송 — DB 가 중복 차단

ALTER TABLE token_transactions
ADD COLUMN IF NOT EXISTS idempotency_key TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_token_transactions_idempotency_key_uidx
  ON token_transactions (idempotency_key)
  WHERE idempotency_key IS NOT NULL;

COMMENT ON COLUMN token_transactions.idempotency_key IS
  'PR-0a: 클라가 생성하는 요청 단위 unique key. 같은 키 재전송 = 1 transaction만 기록.';

COMMENT ON INDEX idx_token_transactions_idempotency_key_uidx IS
  'PR-0a: 이중 차감/환불 차단. NULL 허용 (옛 row 호환).';
