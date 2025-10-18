-- Add mbti and zodiac columns to fortune_results table
-- Purpose: Fix PGRST204 error when saving personality-dna fortune results
-- Date: 2025-01-10

BEGIN;

-- Add mbti column for MBTI type
ALTER TABLE fortune_results
ADD COLUMN IF NOT EXISTS mbti TEXT;

-- Add zodiac column for zodiac sign
ALTER TABLE fortune_results
ADD COLUMN IF NOT EXISTS zodiac TEXT;

-- Add indexes for mbti and zodiac-based queries
CREATE INDEX IF NOT EXISTS idx_fortune_results_mbti
  ON fortune_results(mbti)
  WHERE mbti IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_fortune_results_zodiac
  ON fortune_results(zodiac)
  WHERE zodiac IS NOT NULL;

-- Add comments
COMMENT ON COLUMN fortune_results.mbti IS 'MBTI personality type (e.g., ENTJ, INFP)';
COMMENT ON COLUMN fortune_results.zodiac IS 'Zodiac sign (e.g., 처녀자리, 사자자리)';

COMMIT;

-- Verify migration
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'fortune_results'
      AND column_name = 'mbti'
  ) AND EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'fortune_results'
      AND column_name = 'zodiac'
  ) THEN
    RAISE NOTICE '✅ mbti and zodiac columns added successfully';
  ELSE
    RAISE EXCEPTION '❌ mbti or zodiac column creation failed';
  END IF;
END $$;
