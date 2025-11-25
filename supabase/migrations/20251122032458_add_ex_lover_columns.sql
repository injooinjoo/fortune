-- Add ex-lover fortune specific columns to fortune_results table
-- Purpose: Store ex-lover fortune condition fields for fast querying and matching
-- Date: 2025-01-22

-- Add ex-lover specific condition columns
ALTER TABLE fortune_results
  ADD COLUMN IF NOT EXISTS time_since_breakup TEXT,
  ADD COLUMN IF NOT EXISTS current_emotion TEXT,
  ADD COLUMN IF NOT EXISTS main_curiosity TEXT,
  ADD COLUMN IF NOT EXISTS ex_birth_date DATE,
  ADD COLUMN IF NOT EXISTS breakup_reason TEXT;

-- Create index for ex-lover fortune queries
-- This enables fast lookup of similar ex-lover fortunes
CREATE INDEX IF NOT EXISTS idx_fortune_results_ex_lover
  ON fortune_results(fortune_type, time_since_breakup, current_emotion, main_curiosity)
  WHERE fortune_type = 'ex_lover';

-- Add comments for documentation
COMMENT ON COLUMN fortune_results.time_since_breakup IS 'Time since breakup for ex-lover fortune (e.g., 1개월, 3개월, 6개월, 1년)';
COMMENT ON COLUMN fortune_results.current_emotion IS 'Current emotion for ex-lover fortune (e.g., 그리움, 후회, 분노, 무관심)';
COMMENT ON COLUMN fortune_results.main_curiosity IS 'Main curiosity for ex-lover fortune (e.g., reunion, feelings, moving_on)';
COMMENT ON COLUMN fortune_results.ex_birth_date IS 'Ex-partner birth date for compatibility analysis (optional)';
COMMENT ON COLUMN fortune_results.breakup_reason IS 'Reason for breakup (optional, for deeper analysis)';
