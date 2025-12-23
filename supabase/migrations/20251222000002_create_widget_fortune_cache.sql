-- 위젯용 운세 캐시 테이블
-- 앱 미접속 시에도 백그라운드에서 위젯 데이터를 조회할 수 있도록 캐싱

CREATE TABLE IF NOT EXISTS widget_fortune_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fortune_date DATE NOT NULL,

  -- 총운 데이터
  overall_score INT NOT NULL DEFAULT 80,
  overall_grade VARCHAR(10) NOT NULL DEFAULT '길',
  overall_message TEXT,

  -- 카테고리별 점수 (JSONB)
  -- { "love": { "score": 75, "message": "..." }, "money": {...}, ... }
  categories JSONB NOT NULL DEFAULT '{}'::jsonb,

  -- 시간대별 운세 (JSONB)
  -- [ { "key": "morning", "score": 80, "message": "..." }, ... ]
  time_slots JSONB NOT NULL DEFAULT '[]'::jsonb,

  -- 로또 번호
  lotto_numbers INT[] DEFAULT ARRAY[]::INT[],

  -- 행운 아이템 (Watch용)
  lucky_items JSONB DEFAULT '{}'::jsonb,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- 사용자별 날짜당 하나의 캐시만 유지
  UNIQUE(user_id, fortune_date)
);

-- 인덱스: 사용자별 최신 데이터 조회 최적화
CREATE INDEX IF NOT EXISTS idx_widget_cache_user_date
  ON widget_fortune_cache(user_id, fortune_date DESC);

-- 오래된 데이터 자동 정리용 인덱스 (7일 이전)
CREATE INDEX IF NOT EXISTS idx_widget_cache_fortune_date
  ON widget_fortune_cache(fortune_date);

-- RLS 활성화
ALTER TABLE widget_fortune_cache ENABLE ROW LEVEL SECURITY;

-- 정책: 사용자는 자신의 캐시만 조회 가능
CREATE POLICY "Users can view own widget cache"
  ON widget_fortune_cache
  FOR SELECT
  USING (auth.uid() = user_id);

-- 정책: 서비스 역할은 모든 작업 가능 (Edge Function에서 사용)
CREATE POLICY "Service can manage widget cache"
  ON widget_fortune_cache
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_widget_cache_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_widget_cache_updated_at
  BEFORE UPDATE ON widget_fortune_cache
  FOR EACH ROW
  EXECUTE FUNCTION update_widget_cache_updated_at();

-- 7일 이전 데이터 정리 함수
CREATE OR REPLACE FUNCTION cleanup_old_widget_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM widget_fortune_cache
  WHERE fortune_date < CURRENT_DATE - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE widget_fortune_cache IS '위젯용 운세 데이터 캐시 - 앱 미접속 시 백그라운드 갱신용';
