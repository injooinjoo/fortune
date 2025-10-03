-- Fix existing tables to add missing columns
-- This migration adds columns that are missing from existing tables

-- 1. Fix user_statistics table (if exists)
DO $$
BEGIN
  -- Add consecutive_days column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_statistics' AND column_name = 'consecutive_days'
  ) THEN
    ALTER TABLE user_statistics ADD COLUMN consecutive_days INTEGER DEFAULT 0 NOT NULL;
    CREATE INDEX IF NOT EXISTS idx_user_statistics_consecutive_days ON user_statistics(consecutive_days DESC);
  END IF;

  -- Add fortune_type_count column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_statistics' AND column_name = 'fortune_type_count'
  ) THEN
    ALTER TABLE user_statistics ADD COLUMN fortune_type_count JSONB DEFAULT '{}'::jsonb NOT NULL;
  END IF;

  -- Add last_login column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_statistics' AND column_name = 'last_login'
  ) THEN
    ALTER TABLE user_statistics ADD COLUMN last_login TIMESTAMP WITH TIME ZONE;
  END IF;

  -- Add favorite_fortune_type column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_statistics' AND column_name = 'favorite_fortune_type'
  ) THEN
    ALTER TABLE user_statistics ADD COLUMN favorite_fortune_type VARCHAR(50);
  END IF;
END $$;

-- 2. Fix fortune_cache table (if exists)
DO $$
BEGIN
  -- Add cache_key column if it doesn't exist
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_cache') THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'fortune_cache' AND column_name = 'cache_key'
    ) THEN
      ALTER TABLE fortune_cache ADD COLUMN cache_key VARCHAR(255);

      -- Generate cache_key for existing rows
      UPDATE fortune_cache
      SET cache_key = COALESCE(user_id::text, 'anonymous') || '_' || fortune_type || '_' || DATE(created_at)
      WHERE cache_key IS NULL;

      -- Make it NOT NULL and UNIQUE after populating
      ALTER TABLE fortune_cache ALTER COLUMN cache_key SET NOT NULL;
      CREATE UNIQUE INDEX IF NOT EXISTS idx_fortune_cache_key_unique ON fortune_cache(cache_key);
    END IF;

    -- Add result column if it doesn't exist (rename fortune_data to result)
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'fortune_cache' AND column_name = 'result'
    ) THEN
      IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'fortune_cache' AND column_name = 'fortune_data'
      ) THEN
        ALTER TABLE fortune_cache RENAME COLUMN fortune_data TO result;
      ELSE
        ALTER TABLE fortune_cache ADD COLUMN result JSONB NOT NULL DEFAULT '{}'::jsonb;
      END IF;
    END IF;

    -- Add expires_at column with default if it doesn't exist
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'fortune_cache' AND column_name = 'expires_at'
    ) THEN
      ALTER TABLE fortune_cache ADD COLUMN expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours') NOT NULL;

      -- Update existing rows to have expires_at = created_at + 24 hours
      UPDATE fortune_cache
      SET expires_at = created_at + INTERVAL '24 hours'
      WHERE expires_at IS NULL;
    END IF;

    -- Create missing indexes
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_key ON fortune_cache(cache_key);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_type ON fortune_cache(fortune_type);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_user_id ON fortune_cache(user_id);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_expires ON fortune_cache(expires_at);
  END IF;
END $$;

-- 3. Ensure RLS is enabled on both tables
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_cache ENABLE ROW LEVEL SECURITY;

-- 4. Create or replace RLS policies for user_statistics (safe to re-run)
DROP POLICY IF EXISTS "Users can view own statistics" ON user_statistics;
CREATE POLICY "Users can view own statistics" ON user_statistics
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own statistics" ON user_statistics;
CREATE POLICY "Users can insert own statistics" ON user_statistics
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own statistics" ON user_statistics;
CREATE POLICY "Users can update own statistics" ON user_statistics
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own statistics" ON user_statistics;
CREATE POLICY "Users can delete own statistics" ON user_statistics
  FOR DELETE USING (auth.uid() = user_id);

-- 5. Create or replace RLS policies for fortune_cache (safe to re-run)
DROP POLICY IF EXISTS "Public can view fortune cache" ON fortune_cache;
CREATE POLICY "Public can view fortune cache" ON fortune_cache
  FOR SELECT USING (user_id IS NULL OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Authenticated users can insert fortune cache" ON fortune_cache;
CREATE POLICY "Authenticated users can insert fortune cache" ON fortune_cache
  FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

DROP POLICY IF EXISTS "Users can update own fortune cache" ON fortune_cache;
CREATE POLICY "Users can update own fortune cache" ON fortune_cache
  FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);

DROP POLICY IF EXISTS "Users can delete own fortune cache" ON fortune_cache;
CREATE POLICY "Users can delete own fortune cache" ON fortune_cache
  FOR DELETE USING (auth.uid() = user_id OR user_id IS NULL);

-- 6. Create helper function to update user statistics
CREATE OR REPLACE FUNCTION update_user_statistics_on_fortune()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert or update user statistics
  INSERT INTO user_statistics (user_id, total_fortunes, last_login, fortune_type_count)
  VALUES (
    NEW.user_id,
    1,
    NOW(),
    jsonb_build_object(NEW.fortune_type, 1)
  )
  ON CONFLICT (user_id) DO UPDATE SET
    total_fortunes = user_statistics.total_fortunes + 1,
    last_login = NOW(),
    fortune_type_count = user_statistics.fortune_type_count ||
      jsonb_build_object(
        NEW.fortune_type,
        COALESCE((user_statistics.fortune_type_count->>NEW.fortune_type)::int, 0) + 1
      ),
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Create trigger if it doesn't exist
DROP TRIGGER IF EXISTS trigger_update_user_statistics ON fortune_history;
CREATE TRIGGER trigger_update_user_statistics
  AFTER INSERT ON fortune_history
  FOR EACH ROW
  EXECUTE FUNCTION update_user_statistics_on_fortune();

-- 8. Create cleanup function for fortune_cache
CREATE OR REPLACE FUNCTION clean_expired_fortune_cache()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete expired fortune cache
  DELETE FROM fortune_cache WHERE expires_at < NOW();
  GET DIAGNOSTICS deleted_count = ROW_COUNT;

  -- Delete expired fortune stories (if table exists)
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_stories') THEN
    DELETE FROM fortune_stories WHERE expires_at < NOW();
    GET DIAGNOSTICS deleted_count = deleted_count + ROW_COUNT;
  END IF;

  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION update_user_statistics_on_fortune() TO authenticated;
GRANT EXECUTE ON FUNCTION clean_expired_fortune_cache() TO authenticated;
GRANT EXECUTE ON FUNCTION clean_expired_fortune_cache() TO anon;
