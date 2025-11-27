-- 유명인 테이블 백업 (데이터 정리 전)
-- 문제 발생 시 롤백용

CREATE TABLE IF NOT EXISTS celebrities_backup_20251128 AS
SELECT *, NOW() as backup_date FROM celebrities;

-- 백업 테이블에 인덱스 추가 (복원 시 빠른 조회)
CREATE INDEX IF NOT EXISTS idx_backup_20251128_id ON celebrities_backup_20251128(id);
CREATE INDEX IF NOT EXISTS idx_backup_20251128_name ON celebrities_backup_20251128(name);

-- 코멘트
COMMENT ON TABLE celebrities_backup_20251128 IS '2025-11-28 유명인 데이터 정리 전 백업';
