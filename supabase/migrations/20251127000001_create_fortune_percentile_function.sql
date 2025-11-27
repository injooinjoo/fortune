-- 운세 점수 퍼센타일 계산 함수
-- 오늘 해당 운세를 본 사람들 중 상위 몇 %인지 계산
-- "오늘운세본사람들사이에서 상위 n%" 표시용

-- 함수: 오늘 특정 운세 타입의 점수 퍼센타일 계산
CREATE OR REPLACE FUNCTION get_fortune_percentile(
  target_fortune_type VARCHAR(50),
  target_score INTEGER
)
RETURNS TABLE (
  percentile INTEGER,           -- 상위 퍼센타일 (예: 15 = 상위 15%)
  total_today INTEGER,          -- 오늘 해당 운세 본 총 인원수
  is_valid BOOLEAN              -- 최소 샘플 수 충족 여부 (10명 이상)
) AS $$
DECLARE
  min_sample_size INTEGER := 10;  -- 최소 샘플 수
  today_count INTEGER;
  higher_score_count INTEGER;
  percentile_value INTEGER;
BEGIN
  -- 오늘 해당 운세 타입의 총 개수 (점수가 있는 것만)
  SELECT COUNT(*) INTO today_count
  FROM fortune_history
  WHERE fortune_type = target_fortune_type
    AND fortune_date = CURRENT_DATE
    AND score IS NOT NULL;

  -- 최소 샘플 수 체크
  IF today_count < min_sample_size THEN
    RETURN QUERY SELECT
      NULL::INTEGER as percentile,
      today_count as total_today,
      FALSE as is_valid;
    RETURN;
  END IF;

  -- 타겟 점수보다 높은 점수 개수 계산
  SELECT COUNT(*) INTO higher_score_count
  FROM fortune_history
  WHERE fortune_type = target_fortune_type
    AND fortune_date = CURRENT_DATE
    AND score IS NOT NULL
    AND score > target_score;

  -- 상위 퍼센타일 계산: (높은 점수 개수 / 전체) * 100 + 1
  -- 예: 100명 중 10명이 더 높은 점수 -> 상위 11%
  percentile_value := CEIL((higher_score_count::NUMERIC / today_count::NUMERIC) * 100) + 1;

  -- 최소 1%, 최대 100%로 제한
  percentile_value := GREATEST(1, LEAST(100, percentile_value));

  RETURN QUERY SELECT
    percentile_value as percentile,
    today_count as total_today,
    TRUE as is_valid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 권한 부여 (익명 사용자 포함 - Edge Function에서 호출)
GRANT EXECUTE ON FUNCTION get_fortune_percentile(VARCHAR(50), INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_fortune_percentile(VARCHAR(50), INTEGER) TO anon;

-- 성능을 위한 인덱스 추가 (fortune_type + fortune_date + score)
CREATE INDEX IF NOT EXISTS idx_fortune_history_type_date_score
ON fortune_history(fortune_type, fortune_date, score)
WHERE score IS NOT NULL;

COMMENT ON FUNCTION get_fortune_percentile IS '오늘 특정 운세를 본 사람들 중 상위 퍼센타일 계산. 최소 10명 이상일 때만 유효.';
