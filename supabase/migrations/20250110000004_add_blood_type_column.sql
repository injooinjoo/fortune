-- Add blood_type column to fortune_results table
-- Purpose: Fix PGRST204 error when saving personality-dna fortune results
-- Date: 2025-01-10

BEGIN;

-- Add blood_type column for blood type (혈액형)
ALTER TABLE fortune_results
ADD COLUMN IF NOT EXISTS blood_type TEXT;

-- Add index for blood_type-based queries
CREATE INDEX IF NOT EXISTS idx_fortune_results_blood_type
  ON fortune_results(blood_type)
  WHERE blood_type IS NOT NULL;

-- Add comment
COMMENT ON COLUMN fortune_results.blood_type IS 'Blood type for personality-dna fortune (e.g., A, B, O, AB)';

COMMIT;

-- Verify migration
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'fortune_results'
      AND column_name = 'blood_type'
  ) THEN
    RAISE NOTICE '✅ blood_type column added successfully';
  ELSE
    RAISE EXCEPTION '❌ blood_type column creation failed';
  END IF;
END $$;
