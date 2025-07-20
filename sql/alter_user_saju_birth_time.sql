-- user_saju 테이블의 birth_time 필드 타입 변경
-- TIME 타입에서 VARCHAR로 변경하여 한국 전통 시간 표기 저장 가능

-- 1. 기존 컬럼 타입 변경
ALTER TABLE user_saju 
ALTER COLUMN birth_time TYPE VARCHAR(50) USING birth_time::text;

-- 2. 코멘트 추가 (선택사항)
COMMENT ON COLUMN user_saju.birth_time IS '생시 정보 (예: "축시 (01:00 - 03:00)")';

-- 3. 데이터 확인
SELECT user_id, birth_time FROM user_saju LIMIT 10;