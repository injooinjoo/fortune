-- SAFE migration: Only fixes what exists, no errors
-- 실행 전에 반드시 Supabase SQL Editor에서 위 check_db_schema.sql을 먼저 실행하세요

-- ====================================================================
-- PART 1: user_statistics 테이블 수정 (존재하는 경우만)
-- ====================================================================
DO $$
BEGIN
  -- user_statistics 테이블이 존재하는지 확인
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_statistics') THEN

    -- consecutive_days 컬럼 추가
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'user_statistics' AND column_name = 'consecutive_days'
    ) THEN
      ALTER TABLE user_statistics ADD COLUMN consecutive_days INTEGER DEFAULT 0 NOT NULL;
      CREATE INDEX idx_user_statistics_consecutive_days ON user_statistics(consecutive_days DESC);
      RAISE NOTICE 'Added consecutive_days column to user_statistics';
    END IF;

    -- fortune_type_count 컬럼 추가
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'user_statistics' AND column_name = 'fortune_type_count'
    ) THEN
      ALTER TABLE user_statistics ADD COLUMN fortune_type_count JSONB DEFAULT '{}'::jsonb NOT NULL;
      RAISE NOTICE 'Added fortune_type_count column to user_statistics';
    END IF;

    -- last_login 컬럼 추가
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'user_statistics' AND column_name = 'last_login'
    ) THEN
      ALTER TABLE user_statistics ADD COLUMN last_login TIMESTAMP WITH TIME ZONE;
      RAISE NOTICE 'Added last_login column to user_statistics';
    END IF;

    -- favorite_fortune_type 컬럼 추가
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'user_statistics' AND column_name = 'favorite_fortune_type'
    ) THEN
      ALTER TABLE user_statistics ADD COLUMN favorite_fortune_type VARCHAR(50);
      RAISE NOTICE 'Added favorite_fortune_type column to user_statistics';
    END IF;

    RAISE NOTICE 'user_statistics table updated successfully';
  ELSE
    RAISE NOTICE 'user_statistics table does not exist - skipping';
  END IF;
END $$;

-- ====================================================================
-- PART 2: fortune_cache 테이블 수정 (존재하는 경우만)
-- ====================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_cache') THEN

    -- cache_key 컬럼 추가
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'fortune_cache' AND column_name = 'cache_key'
    ) THEN
      -- 먼저 NULL 허용으로 추가
      ALTER TABLE fortune_cache ADD COLUMN cache_key VARCHAR(255);

      -- 기존 데이터에 대해 cache_key 생성
      UPDATE fortune_cache
      SET cache_key = COALESCE(user_id::text, 'anonymous') || '_' || fortune_type || '_' || DATE(created_at)
      WHERE cache_key IS NULL;

      -- NULL 불가로 변경하고 UNIQUE 제약조건 추가
      ALTER TABLE fortune_cache ALTER COLUMN cache_key SET NOT NULL;

      -- UNIQUE 인덱스 추가 (중복 체크)
      BEGIN
        CREATE UNIQUE INDEX idx_fortune_cache_key_unique ON fortune_cache(cache_key);
      EXCEPTION WHEN unique_violation THEN
        -- 중복이 있으면 중복 제거 후 다시 시도
        DELETE FROM fortune_cache a USING fortune_cache b
        WHERE a.id > b.id AND a.cache_key = b.cache_key;
        CREATE UNIQUE INDEX idx_fortune_cache_key_unique ON fortune_cache(cache_key);
      END;

      RAISE NOTICE 'Added cache_key column to fortune_cache';
    END IF;

    -- result 컬럼 확인/추가
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'fortune_cache' AND column_name = 'result'
    ) THEN
      -- fortune_data 컬럼이 있으면 이름 변경
      IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'fortune_cache' AND column_name = 'fortune_data'
      ) THEN
        ALTER TABLE fortune_cache RENAME COLUMN fortune_data TO result;
        RAISE NOTICE 'Renamed fortune_data to result in fortune_cache';
      ELSE
        -- 없으면 새로 생성
        ALTER TABLE fortune_cache ADD COLUMN result JSONB NOT NULL DEFAULT '{}'::jsonb;
        RAISE NOTICE 'Added result column to fortune_cache';
      END IF;
    END IF;

    -- expires_at 컬럼 추가
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'fortune_cache' AND column_name = 'expires_at'
    ) THEN
      ALTER TABLE fortune_cache ADD COLUMN expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours') NOT NULL;

      -- 기존 데이터에 expires_at 설정
      UPDATE fortune_cache
      SET expires_at = COALESCE(created_at + INTERVAL '24 hours', NOW() + INTERVAL '24 hours')
      WHERE expires_at IS NULL;

      RAISE NOTICE 'Added expires_at column to fortune_cache';
    END IF;

    -- 인덱스 생성
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_key ON fortune_cache(cache_key);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_type ON fortune_cache(fortune_type);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_user_id ON fortune_cache(user_id);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_expires ON fortune_cache(expires_at);

    RAISE NOTICE 'fortune_cache table updated successfully';
  ELSE
    RAISE NOTICE 'fortune_cache table does not exist - skipping';
  END IF;
END $$;

-- ====================================================================
-- PART 3: RLS 정책 설정
-- ====================================================================

-- user_statistics RLS
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_statistics') THEN
    ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;

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

    RAISE NOTICE 'user_statistics RLS policies created';
  END IF;
END $$;

-- fortune_cache RLS
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_cache') THEN
    ALTER TABLE fortune_cache ENABLE ROW LEVEL SECURITY;

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

    RAISE NOTICE 'fortune_cache RLS policies created';
  END IF;
END $$;

-- ====================================================================
-- PART 4: 헬퍼 함수 생성 (fortune_history가 있을 때만)
-- ====================================================================

-- fortune_history 테이블이 있을 때만 트리거 함수 생성
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_history') THEN
    -- 함수 생성
    CREATE OR REPLACE FUNCTION update_user_statistics_on_fortune()
    RETURNS TRIGGER AS $func$
    BEGIN
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
    $func$ LANGUAGE plpgsql SECURITY DEFINER;

    -- 트리거 생성
    DROP TRIGGER IF EXISTS trigger_update_user_statistics ON fortune_history;
    CREATE TRIGGER trigger_update_user_statistics
      AFTER INSERT ON fortune_history
      FOR EACH ROW
      EXECUTE FUNCTION update_user_statistics_on_fortune();

    GRANT EXECUTE ON FUNCTION update_user_statistics_on_fortune() TO authenticated;

    RAISE NOTICE 'fortune_history trigger created successfully';
  ELSE
    RAISE NOTICE 'fortune_history table does not exist - skipping trigger creation';
  END IF;
END $$;

-- ====================================================================
-- PART 5: 캐시 정리 함수
-- ====================================================================

CREATE OR REPLACE FUNCTION clean_expired_fortune_cache()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER := 0;
  temp_count INTEGER;
BEGIN
  -- fortune_cache 정리
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_cache') THEN
    DELETE FROM fortune_cache WHERE expires_at < NOW();
    GET DIAGNOSTICS temp_count = ROW_COUNT;
    deleted_count := deleted_count + temp_count;
  END IF;

  -- fortune_stories 정리 (있는 경우만)
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_stories') THEN
    DELETE FROM fortune_stories WHERE expires_at < NOW();
    GET DIAGNOSTICS temp_count = ROW_COUNT;
    deleted_count := deleted_count + temp_count;
  END IF;

  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION clean_expired_fortune_cache() TO authenticated;
GRANT EXECUTE ON FUNCTION clean_expired_fortune_cache() TO anon;

-- 완료 메시지
DO $$
BEGIN
  RAISE NOTICE '=== Migration completed successfully ===';
  RAISE NOTICE 'Check the messages above for details on what was updated';
END $$;
