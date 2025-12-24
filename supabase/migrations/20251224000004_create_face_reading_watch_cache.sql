-- Apple Watch용 관상 데이터 캐시 테이블
-- 2025-12-24: 관상 앱 리디자인 - Watch 연동
-- 경량 데이터로 Watch에서 빠르게 조회

-- ============================================
-- 1. face_reading_watch_cache 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS face_reading_watch_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 날짜 (일별 유니크)
  cache_date DATE NOT NULL,

  -- Watch용 경량 데이터
  lucky_direction TEXT NOT NULL,  -- 오늘의 행운 방향
  lucky_color_name TEXT NOT NULL,  -- 행운 색상 이름 (한국어)
  lucky_color_code TEXT NOT NULL,  -- 행운 색상 코드 (#RRGGBB)
  lucky_time_periods JSONB DEFAULT '[]',  -- 행운 시간대 목록

  -- 리마인더 메시지
  daily_reminder_message TEXT NOT NULL,  -- "지금 1분만 숨을 고르세요"

  -- 간단한 운세
  brief_fortune TEXT NOT NULL,  -- 간단한 오늘의 운세

  -- 점수
  condition_score INT NOT NULL CHECK (condition_score >= 0 AND condition_score <= 100),
  smile_score INT NOT NULL CHECK (smile_score >= 0 AND smile_score <= 100),

  -- 관련 히스토리
  history_id UUID REFERENCES face_reading_history(id) ON DELETE SET NULL,

  -- 만료 시간 (다음 날 00:00)
  expires_at TIMESTAMPTZ NOT NULL,

  -- 타임스탬프
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- 일별 유니크 제약
  UNIQUE(user_id, cache_date)
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_watch_cache_user ON face_reading_watch_cache(user_id);
CREATE INDEX IF NOT EXISTS idx_watch_cache_date ON face_reading_watch_cache(cache_date DESC);
CREATE INDEX IF NOT EXISTS idx_watch_cache_expires ON face_reading_watch_cache(expires_at);

-- ============================================
-- 2. RLS 정책
-- ============================================
ALTER TABLE face_reading_watch_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own watch cache"
  ON face_reading_watch_cache FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own watch cache"
  ON face_reading_watch_cache FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own watch cache"
  ON face_reading_watch_cache FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- 3. 자동 갱신 트리거
-- ============================================
CREATE OR REPLACE FUNCTION update_watch_cache_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_watch_cache_updated_at ON face_reading_watch_cache;
CREATE TRIGGER set_watch_cache_updated_at
  BEFORE UPDATE ON face_reading_watch_cache
  FOR EACH ROW EXECUTE FUNCTION update_watch_cache_updated_at();

-- ============================================
-- 4. Watch 데이터 조회 함수
-- ============================================

-- 오늘의 Watch 데이터 조회 (없으면 NULL)
CREATE OR REPLACE FUNCTION get_today_watch_data(p_user_id UUID)
RETURNS TABLE (
  lucky_direction TEXT,
  lucky_color_name TEXT,
  lucky_color_code TEXT,
  lucky_time_periods JSONB,
  daily_reminder_message TEXT,
  brief_fortune TEXT,
  condition_score INT,
  smile_score INT,
  has_data BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    w.lucky_direction,
    w.lucky_color_name,
    w.lucky_color_code,
    w.lucky_time_periods,
    w.daily_reminder_message,
    w.brief_fortune,
    w.condition_score,
    w.smile_score,
    TRUE as has_data
  FROM face_reading_watch_cache w
  WHERE w.user_id = p_user_id
    AND w.cache_date = CURRENT_DATE
    AND w.expires_at > NOW()
  LIMIT 1;

  -- 데이터가 없으면 빈 결과 반환
  IF NOT FOUND THEN
    RETURN QUERY SELECT
      NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::JSONB,
      NULL::TEXT, NULL::TEXT, NULL::INT, NULL::INT, FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Watch 캐시 업데이트 (관상 분석 후 호출)
CREATE OR REPLACE FUNCTION upsert_watch_cache(
  p_user_id UUID,
  p_lucky_direction TEXT,
  p_lucky_color_name TEXT,
  p_lucky_color_code TEXT,
  p_lucky_time_periods JSONB,
  p_daily_reminder TEXT,
  p_brief_fortune TEXT,
  p_condition_score INT,
  p_smile_score INT,
  p_history_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_cache_id UUID;
  v_tomorrow TIMESTAMPTZ;
BEGIN
  -- 내일 00:00:00 계산
  v_tomorrow := DATE_TRUNC('day', NOW() + INTERVAL '1 day');

  INSERT INTO face_reading_watch_cache (
    user_id, cache_date, lucky_direction, lucky_color_name, lucky_color_code,
    lucky_time_periods, daily_reminder_message, brief_fortune,
    condition_score, smile_score, history_id, expires_at
  ) VALUES (
    p_user_id, CURRENT_DATE, p_lucky_direction, p_lucky_color_name, p_lucky_color_code,
    p_lucky_time_periods, p_daily_reminder, p_brief_fortune,
    p_condition_score, p_smile_score, p_history_id, v_tomorrow
  )
  ON CONFLICT (user_id, cache_date) DO UPDATE SET
    lucky_direction = EXCLUDED.lucky_direction,
    lucky_color_name = EXCLUDED.lucky_color_name,
    lucky_color_code = EXCLUDED.lucky_color_code,
    lucky_time_periods = EXCLUDED.lucky_time_periods,
    daily_reminder_message = EXCLUDED.daily_reminder_message,
    brief_fortune = EXCLUDED.brief_fortune,
    condition_score = EXCLUDED.condition_score,
    smile_score = EXCLUDED.smile_score,
    history_id = EXCLUDED.history_id,
    expires_at = EXCLUDED.expires_at
  RETURNING id INTO v_cache_id;

  RETURN v_cache_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. 만료 데이터 정리 (스케줄러용)
-- ============================================
CREATE OR REPLACE FUNCTION cleanup_expired_watch_cache()
RETURNS INT AS $$
DECLARE
  v_deleted INT;
BEGIN
  DELETE FROM face_reading_watch_cache
  WHERE expires_at < NOW();

  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  RETURN v_deleted;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. 코멘트
-- ============================================
COMMENT ON TABLE face_reading_watch_cache IS 'Apple Watch용 관상 데이터 캐시';
COMMENT ON COLUMN face_reading_watch_cache.lucky_direction IS '오늘의 행운 방향';
COMMENT ON COLUMN face_reading_watch_cache.lucky_color_name IS '행운 색상 이름 (한국어)';
COMMENT ON COLUMN face_reading_watch_cache.lucky_time_periods IS '행운 시간대 목록 ["오전 10시", "오후 3시"]';
COMMENT ON COLUMN face_reading_watch_cache.daily_reminder_message IS '일일 리마인더 메시지';
COMMENT ON COLUMN face_reading_watch_cache.expires_at IS '캐시 만료 시간 (다음 날 00:00)';
