-- Fortune Optimization System Rollback Migration
-- Purpose: Safely rollback fortune_results table and related objects
-- Version: 1.0.0
-- Date: 2025-01-10
-- Usage: Only run this if you need to undo the fortune_results table creation

BEGIN;

-- ============================================
-- Rollback Order (reverse of creation)
-- ============================================

-- 1. Drop Helper Functions
DROP FUNCTION IF EXISTS get_fortune_api_stats(DATE, DATE);
DROP FUNCTION IF EXISTS get_random_fortune_result(TEXT, TEXT);
DROP FUNCTION IF EXISTS get_fortune_pool_size(TEXT, TEXT);

RAISE NOTICE '✅ Helper functions dropped';

-- 2. Drop Triggers
DROP TRIGGER IF EXISTS trigger_update_fortune_results_updated_at ON fortune_results;
DROP FUNCTION IF EXISTS update_fortune_results_updated_at();

RAISE NOTICE '✅ Triggers dropped';

-- 3. Drop RLS Policies
DROP POLICY IF EXISTS "Service role can read all" ON fortune_results;
DROP POLICY IF EXISTS "Users can update own results" ON fortune_results;
DROP POLICY IF EXISTS "Users can insert own results" ON fortune_results;
DROP POLICY IF EXISTS "Users can view own results" ON fortune_results;

RAISE NOTICE '✅ RLS policies dropped';

-- 4. Drop Indexes
DROP INDEX IF EXISTS idx_date_fortune_type;
DROP INDEX IF EXISTS idx_source_created_at;
DROP INDEX IF EXISTS idx_fortune_type_api_call;
DROP INDEX IF EXISTS idx_fortune_type_conditions;
DROP INDEX IF EXISTS idx_user_fortune_date;

RAISE NOTICE '✅ Indexes dropped';

-- 5. Drop Table
DROP TABLE IF EXISTS fortune_results CASCADE;

RAISE NOTICE '✅ fortune_results table dropped';

COMMIT;

-- ============================================
-- Verification
-- ============================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = 'fortune_results'
  ) THEN
    RAISE NOTICE '';
    RAISE NOTICE '✅ Rollback completed successfully';
    RAISE NOTICE '📊 All fortune_results objects have been removed';
    RAISE NOTICE '';
  ELSE
    RAISE EXCEPTION '❌ Rollback failed - fortune_results table still exists';
  END IF;
END $$;
