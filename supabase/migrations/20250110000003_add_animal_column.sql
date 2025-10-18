-- Add animal column to fortune_results table
-- Purpose: Fix PGRST204 error when saving personality-dna fortune results
-- Date: 2025-01-10

BEGIN;

-- Add animal column for zodiac animal (십이지신)
ALTER TABLE fortune_results
ADD COLUMN IF NOT EXISTS animal TEXT;

-- Add index for animal-based queries
CREATE INDEX IF NOT EXISTS idx_fortune_results_animal
  ON fortune_results(animal)
  WHERE animal IS NOT NULL;

-- Add comment
COMMENT ON COLUMN fortune_results.animal IS 'Zodiac animal for personality-dna fortune (e.g., 용, 호랑이, 토끼)';

COMMIT;

-- Verify migration
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'fortune_results'
      AND column_name = 'animal'
  ) THEN
    RAISE NOTICE '✅ animal column added successfully';
  ELSE
    RAISE EXCEPTION '❌ animal column creation failed';
  END IF;
END $$;
