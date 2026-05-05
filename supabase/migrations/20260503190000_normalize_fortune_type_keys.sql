-- DB 에 같은 운세가 dailyCalendar / daily_calendar / daily-calendar 등 3 가지
-- 형태로 저장되어 토큰 차감 / 분석 / 캐시 lookup 이 깨지고 있어 kebab-case 로
-- 통일. 향후 신규 INSERT 는 normalizeFortuneType (TS) 가 막는다.

-- 정규화 함수 (camelCase / snake_case → kebab-case).
CREATE OR REPLACE FUNCTION normalize_fortune_type(input text)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT lower(
    regexp_replace(
      replace(input, '_', '-'),
      '([a-z0-9])([A-Z])', '\1-\2', 'g'
    )
  );
$$;

-- 영향 범위: fortune_history (1763 rows), fortune_results (374), llm_usage_logs (477).
UPDATE fortune_history
SET fortune_type = normalize_fortune_type(fortune_type)
WHERE fortune_type <> normalize_fortune_type(fortune_type);

UPDATE fortune_results
SET fortune_type = normalize_fortune_type(fortune_type)
WHERE fortune_type <> normalize_fortune_type(fortune_type);

UPDATE llm_usage_logs
SET fortune_type = normalize_fortune_type(fortune_type)
WHERE fortune_type <> normalize_fortune_type(fortune_type);

-- fortune_cache 도 fortune_type 컬럼 보유 시 정규화.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fortune_cache' AND column_name = 'fortune_type'
  ) THEN
    EXECUTE $sql$
      UPDATE fortune_cache
      SET fortune_type = normalize_fortune_type(fortune_type)
      WHERE fortune_type <> normalize_fortune_type(fortune_type);
    $sql$;
  END IF;
END
$$;
