-- Add emotion column to fortune_results table
-- Purpose: Fix PGRST204 error when saving daily fortune results
-- Date: 2025-01-10

BEGIN;

-- Add emotion column for daily fortune conditions
ALTER TABLE fortune_results
ADD COLUMN IF NOT EXISTS emotion TEXT;

-- Add index for emotion-based queries
CREATE INDEX IF NOT EXISTS idx_fortune_results_emotion
  ON fortune_results(emotion)
  WHERE emotion IS NOT NULL;

-- Add comment
COMMENT ON COLUMN fortune_results.emotion IS 'User emotion state for daily fortune (e.g., happy, sad, anxious)';

COMMIT;

-- Verify migration
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'fortune_results'
      AND column_name = 'emotion'
  ) THEN
    RAISE NOTICE '✅ emotion column added successfully';
  ELSE
    RAISE EXCEPTION '❌ emotion column creation failed';
  END IF;
END $$;
