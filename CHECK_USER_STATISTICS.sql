-- user_statistics 테이블의 컬럼 확인
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'user_statistics'
ORDER BY ordinal_position;
