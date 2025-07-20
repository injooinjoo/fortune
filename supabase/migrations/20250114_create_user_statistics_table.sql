-- user_statistics 테이블 생성: 사용자별 통계 정보 저장
CREATE TABLE IF NOT EXISTS user_statistics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- 운세 관련 통계
  total_fortunes_viewed INTEGER DEFAULT 0,
  favorite_fortune_type VARCHAR(50),
  last_fortune_date TIMESTAMP WITH TIME ZONE,
  
  -- 사용자 활동 통계
  login_count INTEGER DEFAULT 0,
  last_login_date TIMESTAMP WITH TIME ZONE,
  streak_days INTEGER DEFAULT 0,
  
  -- 토큰 관련
  total_tokens_earned INTEGER DEFAULT 0,
  total_tokens_spent INTEGER DEFAULT 0,
  
  -- 기타 통계
  profile_completion_percentage INTEGER DEFAULT 0,
  achievements JSONB DEFAULT '[]'::jsonb,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- 유니크 제약
  UNIQUE(user_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_statistics_user_id ON user_statistics(user_id);

-- RLS 정책 설정
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 통계만 조회 가능
CREATE POLICY "Users can view own statistics" ON user_statistics
FOR SELECT USING (auth.uid() = user_id);

-- 사용자는 자신의 통계만 수정 가능
CREATE POLICY "Users can update own statistics" ON user_statistics
FOR UPDATE USING (auth.uid() = user_id);

-- 사용자는 자신의 통계만 삽입 가능
CREATE POLICY "Users can insert own statistics" ON user_statistics
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 업데이트 트리거
CREATE TRIGGER update_user_statistics_updated_at 
BEFORE UPDATE ON user_statistics 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- update_updated_at_column 함수가 없다면 생성
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;