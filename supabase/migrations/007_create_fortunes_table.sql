-- 운세 데이터 저장 테이블 생성
CREATE TABLE fortunes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id text NOT NULL,
  fortune_type text NOT NULL,
  fortune_category text NOT NULL,
  data jsonb NOT NULL,
  input_hash text, -- 상호작용 입력값 해시 (null 허용)
  expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  
  -- 복합 유니크 키 (사용자별, 카테고리별, 입력해시별로 중복 방지)
  UNIQUE(user_id, fortune_category, COALESCE(input_hash, ''))
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_fortunes_user_category ON fortunes(user_id, fortune_category);
CREATE INDEX idx_fortunes_expires ON fortunes(expires_at);
CREATE INDEX idx_fortunes_type ON fortunes(fortune_type);
CREATE INDEX idx_fortunes_created ON fortunes(created_at DESC);

-- RLS (Row Level Security) 활성화
ALTER TABLE fortunes ENABLE ROW LEVEL SECURITY;

-- RLS 정책 생성 (모든 사용자가 접근 가능 - 익명 사용자 지원)
CREATE POLICY "Everyone can access fortunes" ON fortunes
  FOR ALL USING (true);

-- 만료된 운세 자동 정리 함수
CREATE OR REPLACE FUNCTION cleanup_expired_fortunes()
RETURNS void AS $$
BEGIN
  DELETE FROM fortunes 
  WHERE expires_at IS NOT NULL AND expires_at < now();
END;
$$ LANGUAGE plpgsql;

-- 매일 새벽 2시에 만료된 운세 정리하는 cron job 
SELECT cron.schedule(
  'cleanup-expired-fortunes',
  '0 2 * * *', -- 매일 새벽 2시
  'SELECT cleanup_expired_fortunes();'
);