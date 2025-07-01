-- 운세 캐시 테이블 생성
CREATE TABLE fortune_cache (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  cache_key text NOT NULL UNIQUE,
  result jsonb NOT NULL,
  package_type text NOT NULL,
  user_info jsonb,
  expires_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- 사용자 알림 테이블 생성
CREATE TABLE user_notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id text NOT NULL,
  message text NOT NULL,
  type text DEFAULT 'info',
  data jsonb,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now()
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_fortune_cache_key ON fortune_cache(cache_key);
CREATE INDEX idx_fortune_cache_expires ON fortune_cache(expires_at);
CREATE INDEX idx_user_notifications_user ON user_notifications(user_id, created_at DESC);

-- RLS (Row Level Security) 활성화
ALTER TABLE fortune_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_notifications ENABLE ROW LEVEL SECURITY;

-- RLS 정책 생성 (모든 사용자가 자신의 데이터에만 접근 가능)
CREATE POLICY "Users can access their own fortune cache" ON fortune_cache
  FOR ALL USING (true); -- 임시로 모든 접근 허용 (익명 사용자 지원)

CREATE POLICY "Users can access their own notifications" ON user_notifications
  FOR ALL USING (true); -- 임시로 모든 접근 허용 (익명 사용자 지원)

-- 만료된 캐시 자동 정리 함수
CREATE OR REPLACE FUNCTION cleanup_expired_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM fortune_cache 
  WHERE expires_at < now();
END;
$$ LANGUAGE plpgsql;

-- 매일 자정에 만료된 캐시 정리하는 cron job 
SELECT cron.schedule(
  'cleanup-expired-cache',
  '0 0 * * *', -- 매일 자정
  'SELECT cleanup_expired_cache();'
);

-- 실시간 알림을 위한 publication 생성
CREATE PUBLICATION fortune_realtime FOR TABLE user_notifications; 