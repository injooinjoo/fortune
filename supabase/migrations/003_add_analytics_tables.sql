-- 운세 완성률 추적 테이블
CREATE TABLE IF NOT EXISTS fortune_completions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  fortune_type TEXT NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  duration_seconds INTEGER,
  user_satisfaction INTEGER CHECK (user_satisfaction >= 1 AND user_satisfaction <= 5),
  feedback TEXT,
  created_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_fortune_completions_user_id 
ON fortune_completions(user_id);

CREATE INDEX IF NOT EXISTS idx_fortune_completions_fortune_type 
ON fortune_completions(fortune_type);

CREATE INDEX IF NOT EXISTS idx_fortune_completions_created_date 
ON fortune_completions(created_date);

CREATE INDEX IF NOT EXISTS idx_fortune_completions_user_type_date 
ON fortune_completions(user_id, fortune_type, created_date);

-- 사용자 선호도 추적 테이블
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  favorite_types JSONB DEFAULT '[]'::jsonb,
  avoid_types JSONB DEFAULT '[]'::jsonb,
  preferred_time_slots JSONB DEFAULT '[]'::jsonb,
  preferred_categories JSONB DEFAULT '[]'::jsonb,
  notification_settings JSONB DEFAULT '{}'::jsonb,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id 
ON user_preferences(user_id);

-- 운세 피드백 테이블
CREATE TABLE IF NOT EXISTS fortune_feedback (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  fortune_type TEXT NOT NULL,
  daily_fortune_id UUID REFERENCES daily_fortunes(id),
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  accuracy_rating INTEGER CHECK (accuracy_rating >= 1 AND accuracy_rating <= 5),
  helpful_rating INTEGER CHECK (helpful_rating >= 1 AND helpful_rating <= 5),
  comment TEXT,
  tags JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_fortune_feedback_user_id 
ON fortune_feedback(user_id);

CREATE INDEX IF NOT EXISTS idx_fortune_feedback_fortune_type 
ON fortune_feedback(fortune_type);

CREATE INDEX IF NOT EXISTS idx_fortune_feedback_daily_fortune_id 
ON fortune_feedback(daily_fortune_id);

-- 운세 조회/생성 로그 테이블 (성능 및 사용 패턴 분석용)
CREATE TABLE IF NOT EXISTS fortune_access_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  fortune_type TEXT NOT NULL,
  action_type TEXT NOT NULL, -- 'view', 'generate', 'share', 'save'
  device_info JSONB DEFAULT '{}'::jsonb,
  session_id TEXT,
  ip_address INET,
  user_agent TEXT,
  referrer TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성 (파티션 고려)
CREATE INDEX IF NOT EXISTS idx_fortune_access_logs_user_id 
ON fortune_access_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_fortune_access_logs_created_at 
ON fortune_access_logs(created_at);

CREATE INDEX IF NOT EXISTS idx_fortune_access_logs_fortune_type 
ON fortune_access_logs(fortune_type);

-- 일별 집계 테이블 (성능 최적화)
CREATE TABLE IF NOT EXISTS daily_fortune_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  stat_date DATE NOT NULL,
  fortune_type TEXT NOT NULL,
  total_generations INTEGER DEFAULT 0,
  total_views INTEGER DEFAULT 0,
  unique_users INTEGER DEFAULT 0,
  avg_satisfaction DECIMAL(3,2),
  completion_rate DECIMAL(5,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(stat_date, fortune_type)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_daily_fortune_stats_date 
ON daily_fortune_stats(stat_date);

CREATE INDEX IF NOT EXISTS idx_daily_fortune_stats_fortune_type 
ON daily_fortune_stats(fortune_type);

-- RLS (Row Level Security) 정책 설정
ALTER TABLE fortune_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_access_logs ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 데이터만 조회/수정 가능
CREATE POLICY "Users can view own completion data" ON fortune_completions
FOR SELECT USING (auth.uid()::text = user_id OR user_id LIKE 'guest_%');

CREATE POLICY "Users can insert own completion data" ON fortune_completions
FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id LIKE 'guest_%');

CREATE POLICY "Users can view own preferences" ON user_preferences
FOR SELECT USING (auth.uid()::text = user_id OR user_id LIKE 'guest_%');

CREATE POLICY "Users can update own preferences" ON user_preferences
FOR ALL USING (auth.uid()::text = user_id OR user_id LIKE 'guest_%');

CREATE POLICY "Users can view own feedback" ON fortune_feedback
FOR SELECT USING (auth.uid()::text = user_id OR user_id LIKE 'guest_%');

CREATE POLICY "Users can insert own feedback" ON fortune_feedback
FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id LIKE 'guest_%');

-- 관리자는 모든 데이터 조회 가능 (통계용)
CREATE POLICY "Admins can view all stats" ON daily_fortune_stats
FOR SELECT USING (true);

-- 트리거 함수 생성 (자동 업데이트)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 적용
CREATE TRIGGER update_fortune_completions_updated_at 
BEFORE UPDATE ON fortune_completions 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at 
BEFORE UPDATE ON user_preferences 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_fortune_stats_updated_at 
BEFORE UPDATE ON daily_fortune_stats 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 함수: 일별 통계 집계 (매일 실행)
CREATE OR REPLACE FUNCTION aggregate_daily_fortune_stats(target_date DATE DEFAULT CURRENT_DATE - 1)
RETURNS VOID AS $$
BEGIN
    INSERT INTO daily_fortune_stats (
        stat_date,
        fortune_type,
        total_generations,
        total_views,
        unique_users,
        avg_satisfaction,
        completion_rate
    )
    SELECT 
        target_date,
        df.fortune_type,
        COUNT(df.id) as total_generations,
        COALESCE(log_stats.total_views, 0) as total_views,
        COUNT(DISTINCT df.user_id) as unique_users,
        ROUND(AVG(ff.rating), 2) as avg_satisfaction,
        CASE 
            WHEN COUNT(fc.id) > 0 THEN 
                ROUND((COUNT(fc.completed_at) * 100.0 / COUNT(fc.id)), 2)
            ELSE NULL 
        END as completion_rate
    FROM daily_fortunes df
    LEFT JOIN fortune_feedback ff ON df.id = ff.daily_fortune_id
    LEFT JOIN fortune_completions fc ON df.user_id = fc.user_id 
        AND df.fortune_type = fc.fortune_type 
        AND df.created_date = fc.created_date
    LEFT JOIN (
        SELECT 
            fortune_type,
            COUNT(*) as total_views
        FROM fortune_access_logs 
        WHERE DATE(created_at) = target_date 
        AND action_type = 'view'
        GROUP BY fortune_type
    ) log_stats ON df.fortune_type = log_stats.fortune_type
    WHERE df.created_date = target_date
    GROUP BY df.fortune_type, log_stats.total_views
    ON CONFLICT (stat_date, fortune_type) 
    DO UPDATE SET
        total_generations = EXCLUDED.total_generations,
        total_views = EXCLUDED.total_views,
        unique_users = EXCLUDED.unique_users,
        avg_satisfaction = EXCLUDED.avg_satisfaction,
        completion_rate = EXCLUDED.completion_rate,
        updated_at = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql; 