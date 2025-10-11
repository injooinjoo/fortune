-- 운세 표준화: input_conditions 필드 추가 및 중복 방지 인덱스 생성
-- 목적: 같은 날 + 같은 유저 + 같은 운세 타입 + 같은 조건 = 중복 방지

-- Step 1: input_conditions 컬럼 추가
ALTER TABLE fortune_history
ADD COLUMN IF NOT EXISTS input_conditions JSONB;

COMMENT ON COLUMN fortune_history.input_conditions IS
'사용자 입력 조건 (타로 카드 선택, MBTI 타입, 생년월일 등). 중복 방지 및 결과 재사용에 사용됨.';

-- Step 2: 기존 데이터에 대한 기본값 설정 (빈 JSON 객체)
UPDATE fortune_history
SET input_conditions = '{}'::jsonb
WHERE input_conditions IS NULL;

-- Step 3: 복합 유니크 인덱스 생성 (중복 방지)
-- 같은 user_id + fortune_type + fortune_date + input_conditions는 유일해야 함
-- 주의: JSONB 컬럼은 직접 UNIQUE 제약을 걸 수 없으므로 text 캐스팅 사용
DROP INDEX IF EXISTS idx_fortune_unique_daily;

CREATE UNIQUE INDEX idx_fortune_unique_daily
ON fortune_history(
  user_id,
  fortune_type,
  fortune_date,
  (input_conditions::text)
)
WHERE input_conditions IS NOT NULL;

COMMENT ON INDEX idx_fortune_unique_daily IS
'중복 방지 인덱스: 같은 날짜 + 같은 유저 + 같은 운세 + 같은 조건은 하나만 허용';

-- Step 4: input_conditions 조회를 위한 GIN 인덱스
-- JSONB 필드 내부 검색을 빠르게 하기 위함
CREATE INDEX IF NOT EXISTS idx_fortune_input_conditions
ON fortune_history USING GIN(input_conditions)
WHERE input_conditions IS NOT NULL AND input_conditions != '{}'::jsonb;

-- Step 5: 검증 함수 생성 (중복 확인용)
CREATE OR REPLACE FUNCTION check_duplicate_fortune(
  p_user_id UUID,
  p_fortune_type VARCHAR(50),
  p_fortune_date DATE,
  p_input_conditions JSONB
)
RETURNS TABLE (
  fortune_id UUID,
  is_duplicate BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    id as fortune_id,
    TRUE as is_duplicate
  FROM fortune_history
  WHERE user_id = p_user_id
    AND fortune_type = p_fortune_type
    AND fortune_date = p_fortune_date
    AND input_conditions::text = p_input_conditions::text
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION check_duplicate_fortune IS
'중복 운세 확인 함수: 같은 조건의 운세가 이미 있는지 확인';

-- 권한 부여
GRANT EXECUTE ON FUNCTION check_duplicate_fortune(UUID, VARCHAR, DATE, JSONB) TO authenticated;

-- Step 6: 마이그레이션 완료 로그
DO $$
BEGIN
  RAISE NOTICE '✅ fortune_history 테이블 확장 완료:';
  RAISE NOTICE '  - input_conditions JSONB 컬럼 추가';
  RAISE NOTICE '  - 중복 방지 유니크 인덱스 생성 (idx_fortune_unique_daily)';
  RAISE NOTICE '  - JSONB 검색용 GIN 인덱스 생성 (idx_fortune_input_conditions)';
  RAISE NOTICE '  - 중복 확인 함수 생성 (check_duplicate_fortune)';
END $$;
