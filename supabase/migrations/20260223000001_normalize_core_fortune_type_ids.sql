-- Core fortune type canonicalization (kebab-case)
-- Hard cutover: normalize legacy snake_case/camelCase ids to canonical ids.

BEGIN;

CREATE TEMP TABLE tmp_fortune_type_map (
  legacy_type text PRIMARY KEY,
  canonical_type text NOT NULL
) ON COMMIT DROP;

INSERT INTO tmp_fortune_type_map (legacy_type, canonical_type) VALUES
  ('daily_calendar', 'daily-calendar'),
  ('dailyCalendar', 'daily-calendar'),
  ('new_year', 'new-year'),
  ('newYear', 'new-year'),
  ('yearlyEncounter', 'yearly-encounter'),
  ('gameEnhance', 'game-enhance'),
  ('babyNickname', 'baby-nickname'),
  ('ex_lover', 'ex-lover'),
  ('blindDate', 'blind-date'),
  ('blind_date', 'blind-date'),
  ('exLover', 'ex-lover'),
  ('avoidPeople', 'avoid-people'),
  ('sportsGame', 'match-insight'),
  ('sports_game', 'match-insight'),
  ('fortuneCookie', 'fortune-cookie'),
  ('personalityDna', 'personality-dna'),
  ('ootdEvaluation', 'ootd-evaluation'),
  ('pet', 'pet-compatibility'),
  ('money', 'wealth'),
  ('luckyItems', 'lucky-items'),
  ('traditional', 'traditional-saju'),
  ('traditional_saju', 'traditional-saju'),
  ('mbti_dimensions', 'mbti-dimensions'),
  ('mbtiDimensions', 'mbti-dimensions');

DO $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN
    SELECT * FROM (
      VALUES
        ('fortune_history', 'fortune_type'),
        ('fortune_cache', 'fortune_type'),
        ('fortune_stories', 'fortune_type'),
        ('fortune_results', 'fortune_type'),
        ('cohort_fortune_pool', 'fortune_type'),
        ('cohort_pool_settings', 'fortune_type'),
        ('llm_model_config', 'fortune_type'),
        ('llm_usage_logs', 'fortune_type'),
        ('api_call_statistics', 'fortune_type'),
        ('user_statistics', 'favorite_fortune_type')
    ) AS t(table_name, column_name)
  LOOP
    IF EXISTS (
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = rec.table_name
        AND column_name = rec.column_name
    ) THEN
      EXECUTE format(
        'UPDATE public.%I AS dst
         SET %I = map.canonical_type
         FROM tmp_fortune_type_map AS map
         WHERE dst.%I = map.legacy_type',
        rec.table_name,
        rec.column_name,
        rec.column_name
      );
    END IF;
  END LOOP;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_statistics'
      AND column_name = 'fortune_type_count'
  ) THEN
    UPDATE public.user_statistics AS us
    SET fortune_type_count = (
      SELECT COALESCE(
        jsonb_object_agg(item.key, to_jsonb(item.total_count)),
        '{}'::jsonb
      )
      FROM (
        SELECT
          COALESCE(map.canonical_type, kv.key) AS key,
          SUM((kv.value)::int) AS total_count
        FROM jsonb_each_text(COALESCE(us.fortune_type_count, '{}'::jsonb)) AS kv(key, value)
        LEFT JOIN tmp_fortune_type_map AS map
          ON map.legacy_type = kv.key
        GROUP BY COALESCE(map.canonical_type, kv.key)
      ) AS item
    );
  END IF;
END $$;

DROP INDEX IF EXISTS public.idx_fortune_results_ex_lover;
DROP INDEX IF EXISTS public.idx_fortune_results_ex_lover_canonical;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'fortune_results' AND column_name = 'user_id'
  )
  AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'fortune_results' AND column_name = 'created_at'
  )
  AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'fortune_results' AND column_name = 'fortune_type'
  ) THEN
    CREATE INDEX idx_fortune_results_ex_lover_canonical
      ON public.fortune_results(user_id, created_at DESC)
      WHERE fortune_type = 'ex-lover';
  END IF;
END $$;

COMMIT;
