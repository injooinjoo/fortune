-- 크론 작업 로그 테이블
CREATE TABLE IF NOT EXISTS cron_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_name TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('success', 'partial_success', 'error')),
  processed_count INTEGER DEFAULT 0,
  error_count INTEGER DEFAULT 0,
  error_message TEXT,
  details JSONB,
  executed_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_cron_logs_job_name ON cron_logs(job_name);
CREATE INDEX idx_cron_logs_executed_at ON cron_logs(executed_at DESC);

-- 프로필 테이블에 필요한 컬럼 추가 (없는 경우)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- 사용자 설정 테이블 (알림 설정용)
CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notifications_enabled BOOLEAN DEFAULT true,
  push_token TEXT,
  email_notifications BOOLEAN DEFAULT false,
  daily_fortune_time TIME DEFAULT '09:00:00',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- RLS 정책
ALTER TABLE cron_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- 크론 로그는 서비스 역할만 접근 가능
CREATE POLICY "Service role only for cron_logs"
  ON cron_logs
  FOR ALL
  USING (auth.role() = 'service_role');

-- 사용자 설정은 본인만 접근 가능
CREATE POLICY "Users can view their own settings"
  ON user_settings
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own settings"
  ON user_settings
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own settings"
  ON user_settings
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 활성 사용자를 위한 뷰
CREATE OR REPLACE VIEW active_users AS
SELECT 
  p.id,
  p.name,
  p.birth_date,
  p.birth_time,
  p.gender,
  p.mbti,
  p.zodiac_sign,
  p.relationship_status,
  p.last_seen_at,
  s.notifications_enabled,
  s.daily_fortune_time
FROM profiles p
LEFT JOIN user_settings s ON p.id = s.user_id
WHERE p.is_active = true
  AND p.last_seen_at >= NOW() - INTERVAL '7 days'
  AND (s.notifications_enabled IS NULL OR s.notifications_enabled = true);

-- 뷰에 대한 권한 설정
GRANT SELECT ON active_users TO service_role;