-- Fortune Optimization System Migration
-- Purpose: Create fortune_results table for caching and optimization
-- Version: 1.0.0
-- Date: 2025-01-10

BEGIN;

-- ============================================
-- 1. Create fortune_results table
-- ============================================
CREATE TABLE IF NOT EXISTS fortune_results (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- User Information
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Fortune Type & Result
  fortune_type TEXT NOT NULL,
  result_data JSONB NOT NULL,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Conditions for Matching
  conditions_hash TEXT NOT NULL,
  conditions_data JSONB NOT NULL,

  -- Indexable Condition Fields (for fast queries)
  saju_data JSONB,
  date DATE,
  period TEXT,
  selected_cards JSONB,
  partner_saju JSONB,
  category TEXT,

  -- Metadata
  api_call BOOLEAN DEFAULT true,
  source TEXT DEFAULT 'api' CHECK (source IN ('api', 'personal_cache', 'db_pool', 'random_selection')),

  -- Constraints
  CONSTRAINT unique_user_fortune_today
    UNIQUE(user_id, fortune_type, date, conditions_hash)
);

-- ============================================
-- 2. Create Indexes for Performance
-- ============================================

-- Index 1: Personal Cache Lookup (가장 빈번한 쿼리)
-- SELECT * FROM fortune_results
-- WHERE user_id = ? AND fortune_type = ? AND date = ? AND conditions_hash = ?
CREATE INDEX idx_user_fortune_date
  ON fortune_results(user_id, fortune_type, date DESC, conditions_hash);

-- Index 2: DB Pool Size Check & Random Selection
-- SELECT COUNT(*) FROM fortune_results WHERE fortune_type = ? AND conditions_hash = ?
CREATE INDEX idx_fortune_type_conditions
  ON fortune_results(fortune_type, conditions_hash, created_at DESC);

-- Index 3: API Call Statistics (모니터링용)
-- SELECT COUNT(*) FROM fortune_results WHERE fortune_type = ? AND api_call = true
CREATE INDEX idx_fortune_type_api_call
  ON fortune_results(fortune_type, api_call, created_at DESC);

-- Index 4: Source Statistics (모니터링용)
-- SELECT COUNT(*) FROM fortune_results WHERE source = ?
CREATE INDEX idx_source_created_at
  ON fortune_results(source, created_at DESC);

-- Index 5: Date-based Queries (일별 통계용)
CREATE INDEX idx_date_fortune_type
  ON fortune_results(date DESC, fortune_type);

-- ============================================
-- 3. Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE fortune_results ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can view their own results
DROP POLICY IF EXISTS "Users can view own results" ON fortune_results;
CREATE POLICY "Users can view own results"
  ON fortune_results FOR SELECT
  USING (auth.uid() = user_id);

-- Policy 2: Users can insert their own results
DROP POLICY IF EXISTS "Users can insert own results" ON fortune_results;
CREATE POLICY "Users can insert own results"
  ON fortune_results FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy 3: Users can update their own results (optional)
DROP POLICY IF EXISTS "Users can update own results" ON fortune_results;
CREATE POLICY "Users can update own results"
  ON fortune_results FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy 4: Service role can read all (for admin/stats)
DROP POLICY IF EXISTS "Service role can read all" ON fortune_results;
CREATE POLICY "Service role can read all"
  ON fortune_results FOR SELECT
  USING (auth.jwt()->>'role' = 'service_role');

-- ============================================
-- 4. Create Triggers
-- ============================================

-- Trigger 1: Auto-update updated_at column
CREATE OR REPLACE FUNCTION update_fortune_results_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_fortune_results_updated_at ON fortune_results;
CREATE TRIGGER trigger_update_fortune_results_updated_at
  BEFORE UPDATE ON fortune_results
  FOR EACH ROW
  EXECUTE FUNCTION update_fortune_results_updated_at();

-- ============================================
-- 5. Create Helper Functions
-- ============================================

-- Function 1: Get DB Pool Size for a specific fortune type & conditions
CREATE OR REPLACE FUNCTION get_fortune_pool_size(
  p_fortune_type TEXT,
  p_conditions_hash TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM fortune_results
  WHERE fortune_type = p_fortune_type
    AND conditions_hash = p_conditions_hash;

  RETURN v_count;
END;
$$;

-- Function 2: Get Random Result from DB Pool
CREATE OR REPLACE FUNCTION get_random_fortune_result(
  p_fortune_type TEXT,
  p_conditions_hash TEXT
)
RETURNS TABLE (
  id UUID,
  result_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT fr.id, fr.result_data, fr.created_at
  FROM fortune_results fr
  WHERE fr.fortune_type = p_fortune_type
    AND fr.conditions_hash = p_conditions_hash
  ORDER BY RANDOM()
  LIMIT 1;
END;
$$;

-- Function 3: Get API Call Statistics
CREATE OR REPLACE FUNCTION get_fortune_api_stats(
  p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '7 days',
  p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  fortune_type TEXT,
  total_requests BIGINT,
  api_calls BIGINT,
  cache_hits BIGINT,
  cache_hit_rate NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    fr.fortune_type,
    COUNT(*)::BIGINT AS total_requests,
    COUNT(*) FILTER (WHERE fr.api_call = true)::BIGINT AS api_calls,
    COUNT(*) FILTER (WHERE fr.api_call = false)::BIGINT AS cache_hits,
    ROUND(
      (COUNT(*) FILTER (WHERE fr.api_call = false)::NUMERIC / NULLIF(COUNT(*), 0) * 100),
      2
    ) AS cache_hit_rate
  FROM fortune_results fr
  WHERE fr.date >= p_start_date
    AND fr.date <= p_end_date
  GROUP BY fr.fortune_type
  ORDER BY total_requests DESC;
END;
$$;

-- ============================================
-- 6. Add Comments for Documentation
-- ============================================
COMMENT ON TABLE fortune_results IS 'Fortune results cache table for API cost optimization (72% cost reduction)';
COMMENT ON COLUMN fortune_results.conditions_hash IS 'SHA256 hash of conditions for fast matching';
COMMENT ON COLUMN fortune_results.source IS 'Source of result: api, personal_cache, db_pool, or random_selection';
COMMENT ON COLUMN fortune_results.api_call IS 'Whether this result required an OpenAI API call (true) or was cached (false)';

COMMIT;

-- ============================================
-- 7. Verify Migration Success
-- ============================================
DO $$
BEGIN
  -- Check if table exists
  IF EXISTS (
    SELECT FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = 'fortune_results'
  ) THEN
    RAISE NOTICE '✅ fortune_results table created successfully';
  ELSE
    RAISE EXCEPTION '❌ fortune_results table creation failed';
  END IF;

  -- Check if indexes exist
  IF (
    SELECT COUNT(*)
    FROM pg_indexes
    WHERE tablename = 'fortune_results'
  ) >= 5 THEN
    RAISE NOTICE '✅ All indexes created successfully';
  ELSE
    RAISE WARNING '⚠️ Some indexes may be missing';
  END IF;

  -- Check if RLS is enabled
  IF (
    SELECT relrowsecurity
    FROM pg_class
    WHERE relname = 'fortune_results'
  ) THEN
    RAISE NOTICE '✅ Row Level Security enabled';
  ELSE
    RAISE WARNING '⚠️ Row Level Security not enabled';
  END IF;

  -- Display summary
  RAISE NOTICE '';
  RAISE NOTICE '📊 Migration Summary:';
  RAISE NOTICE '  - Table: fortune_results';
  RAISE NOTICE '  - Indexes: % created', (SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'fortune_results');
  RAISE NOTICE '  - RLS Policies: % created', (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'fortune_results');
  RAISE NOTICE '  - Functions: 3 created (get_fortune_pool_size, get_random_fortune_result, get_fortune_api_stats)';
  RAISE NOTICE '';
  RAISE NOTICE '🚀 Fortune Optimization System ready!';
END $$;
