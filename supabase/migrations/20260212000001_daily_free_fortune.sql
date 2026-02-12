-- 일일 무료 운세 사용 기록 테이블
-- 매일 기본 일일 운세(1토큰) 1회 무료 제공

CREATE TABLE IF NOT EXISTS daily_free_fortune (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  used_at DATE NOT NULL DEFAULT CURRENT_DATE,
  fortune_type VARCHAR(50) DEFAULT 'daily',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, used_at)
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_daily_free_fortune_user ON daily_free_fortune(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_free_fortune_date ON daily_free_fortune(used_at DESC);

-- RLS 정책
ALTER TABLE daily_free_fortune ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own free fortune usage"
  ON daily_free_fortune FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own free fortune usage"
  ON daily_free_fortune FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 서비스 역할은 모든 작업 가능
CREATE POLICY "Service role has full access"
  ON daily_free_fortune FOR ALL
  USING (auth.role() = 'service_role');
