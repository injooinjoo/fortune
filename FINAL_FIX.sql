-- 최종 수정 SQL - 한 번에 복사해서 실행하세요
-- 이거 실행하면 끝입니다!

-- ====================================================================
-- PART 1: user_statistics 테이블 수정
-- ====================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_statistics') THEN
    -- consecutive_days 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_statistics' AND column_name = 'consecutive_days') THEN
      ALTER TABLE user_statistics ADD COLUMN consecutive_days INTEGER DEFAULT 0 NOT NULL;
      CREATE INDEX idx_user_statistics_consecutive_days ON user_statistics(consecutive_days DESC);
    END IF;

    -- fortune_type_count 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_statistics' AND column_name = 'fortune_type_count') THEN
      ALTER TABLE user_statistics ADD COLUMN fortune_type_count JSONB DEFAULT '{}'::jsonb NOT NULL;
    END IF;

    -- last_login 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_statistics' AND column_name = 'last_login') THEN
      ALTER TABLE user_statistics ADD COLUMN last_login TIMESTAMP WITH TIME ZONE;
    END IF;

    -- favorite_fortune_type 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_statistics' AND column_name = 'favorite_fortune_type') THEN
      ALTER TABLE user_statistics ADD COLUMN favorite_fortune_type VARCHAR(50);
    END IF;
  END IF;
END $$;

-- ====================================================================
-- PART 2: fortune_cache 테이블 수정
-- ====================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_cache') THEN
    -- cache_key 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fortune_cache' AND column_name = 'cache_key') THEN
      ALTER TABLE fortune_cache ADD COLUMN cache_key VARCHAR(255);
      UPDATE fortune_cache SET cache_key = COALESCE(user_id::text, 'anonymous') || '_' || fortune_type || '_' || DATE(created_at) WHERE cache_key IS NULL;
      ALTER TABLE fortune_cache ALTER COLUMN cache_key SET NOT NULL;
    END IF;

    -- UNIQUE 인덱스 추가 (없을 때만)
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_fortune_cache_key_unique') THEN
      DELETE FROM fortune_cache a USING fortune_cache b WHERE a.id > b.id AND a.cache_key = b.cache_key;
      CREATE UNIQUE INDEX idx_fortune_cache_key_unique ON fortune_cache(cache_key);
    END IF;

    -- result 컬럼 확인/추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fortune_cache' AND column_name = 'result') THEN
      IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fortune_cache' AND column_name = 'fortune_data') THEN
        ALTER TABLE fortune_cache RENAME COLUMN fortune_data TO result;
      ELSE
        ALTER TABLE fortune_cache ADD COLUMN result JSONB NOT NULL DEFAULT '{}'::jsonb;
      END IF;
    END IF;

    -- expires_at 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'fortune_cache' AND column_name = 'expires_at') THEN
      ALTER TABLE fortune_cache ADD COLUMN expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours') NOT NULL;
      UPDATE fortune_cache SET expires_at = COALESCE(created_at + INTERVAL '24 hours', NOW() + INTERVAL '24 hours') WHERE expires_at IS NULL;
    END IF;

    -- 인덱스 생성
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_key ON fortune_cache(cache_key);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_type ON fortune_cache(fortune_type);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_user_id ON fortune_cache(user_id);
    CREATE INDEX IF NOT EXISTS idx_fortune_cache_expires ON fortune_cache(expires_at);
  END IF;
END $$;

-- ====================================================================
-- PART 3: RLS 정책
-- ====================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_statistics') THEN
    ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "Users can view own statistics" ON user_statistics;
    CREATE POLICY "Users can view own statistics" ON user_statistics FOR SELECT USING (auth.uid() = user_id);
    DROP POLICY IF EXISTS "Users can insert own statistics" ON user_statistics;
    CREATE POLICY "Users can insert own statistics" ON user_statistics FOR INSERT WITH CHECK (auth.uid() = user_id);
    DROP POLICY IF EXISTS "Users can update own statistics" ON user_statistics;
    CREATE POLICY "Users can update own statistics" ON user_statistics FOR UPDATE USING (auth.uid() = user_id);
    DROP POLICY IF EXISTS "Users can delete own statistics" ON user_statistics;
    CREATE POLICY "Users can delete own statistics" ON user_statistics FOR DELETE USING (auth.uid() = user_id);
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_cache') THEN
    ALTER TABLE fortune_cache ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "Public can view fortune cache" ON fortune_cache;
    CREATE POLICY "Public can view fortune cache" ON fortune_cache FOR SELECT USING (user_id IS NULL OR auth.uid() = user_id);
    DROP POLICY IF EXISTS "Authenticated users can insert fortune cache" ON fortune_cache;
    CREATE POLICY "Authenticated users can insert fortune cache" ON fortune_cache FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
    DROP POLICY IF EXISTS "Users can update own fortune cache" ON fortune_cache;
    CREATE POLICY "Users can update own fortune cache" ON fortune_cache FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);
    DROP POLICY IF EXISTS "Users can delete own fortune cache" ON fortune_cache;
    CREATE POLICY "Users can delete own fortune cache" ON fortune_cache FOR DELETE USING (auth.uid() = user_id OR user_id IS NULL);
  END IF;
END $$;

-- ====================================================================
-- PART 4: 함수들 (기존 함수 먼저 삭제 후 재생성)
-- ====================================================================

-- 기존 함수 삭제
DROP FUNCTION IF EXISTS clean_expired_fortune_cache();
DROP FUNCTION IF EXISTS update_user_statistics_on_fortune() CASCADE;

-- fortune_history 테이블이 있을 때만 트리거 함수 생성
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_history') THEN
    EXECUTE 'CREATE FUNCTION update_user_statistics_on_fortune() RETURNS TRIGGER AS $func$
    BEGIN
      INSERT INTO user_statistics (user_id, total_fortunes, last_login, fortune_type_count)
      VALUES (NEW.user_id, 1, NOW(), jsonb_build_object(NEW.fortune_type, 1))
      ON CONFLICT (user_id) DO UPDATE SET
        total_fortunes = user_statistics.total_fortunes + 1,
        last_login = NOW(),
        fortune_type_count = user_statistics.fortune_type_count || jsonb_build_object(NEW.fortune_type, COALESCE((user_statistics.fortune_type_count->>NEW.fortune_type)::int, 0) + 1),
        updated_at = NOW();
      RETURN NEW;
    END;
    $func$ LANGUAGE plpgsql SECURITY DEFINER';

    DROP TRIGGER IF EXISTS trigger_update_user_statistics ON fortune_history;
    EXECUTE 'CREATE TRIGGER trigger_update_user_statistics AFTER INSERT ON fortune_history FOR EACH ROW EXECUTE FUNCTION update_user_statistics_on_fortune()';

    GRANT EXECUTE ON FUNCTION update_user_statistics_on_fortune() TO authenticated;
  END IF;
END $$;

-- 캐시 정리 함수
CREATE FUNCTION clean_expired_fortune_cache()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER := 0;
  temp_count INTEGER;
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fortune_cache') THEN
    DELETE FROM fortune_cache WHERE expires_at < NOW();
    GET DIAGNOSTICS temp_count = ROW_COUNT;
    deleted_count := deleted_count + temp_count;
  END IF;

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
