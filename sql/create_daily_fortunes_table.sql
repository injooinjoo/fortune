-- 데일리 운세 저장 테이블 생성
CREATE TABLE IF NOT EXISTS daily_fortunes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL, -- 인증된 사용자 ID 또는 게스트 ID
  fortune_type TEXT NOT NULL, -- 운세 타입 (lucky-hiking, lucky-color, saju, mbti 등)
  fortune_data JSONB NOT NULL, -- 운세 결과 데이터 (JSON 형태)
  created_date DATE NOT NULL, -- 운세 생성 날짜 (YYYY-MM-DD)
  created_at TIMESTAMPTZ DEFAULT NOW(), -- 생성 시간
  updated_at TIMESTAMPTZ DEFAULT NOW(), -- 수정 시간
  
  -- 사용자당 하루에 하나의 운세만 허용
  UNIQUE(user_id, fortune_type, created_date)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_daily_fortunes_user_date 
ON daily_fortunes (user_id, created_date DESC);

CREATE INDEX IF NOT EXISTS idx_daily_fortunes_type_date 
ON daily_fortunes (fortune_type, created_date DESC);

CREATE INDEX IF NOT EXISTS idx_daily_fortunes_user_type_date 
ON daily_fortunes (user_id, fortune_type, created_date DESC);

-- updated_at 자동 업데이트를 위한 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
CREATE TRIGGER update_daily_fortunes_updated_at 
    BEFORE UPDATE ON daily_fortunes 
    FOR EACH ROW 
    EXECUTE PROCEDURE update_updated_at_column();

-- RLS (Row Level Security) 정책 설정
ALTER TABLE daily_fortunes ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 운세만 조회/수정/삭제 가능
CREATE POLICY "사용자는 자신의 운세만 조회 가능" ON daily_fortunes
    FOR SELECT USING (
        user_id = auth.uid()::TEXT OR 
        user_id LIKE 'guest_%'
    );

CREATE POLICY "사용자는 자신의 운세만 추가 가능" ON daily_fortunes
    FOR INSERT WITH CHECK (
        user_id = auth.uid()::TEXT OR 
        user_id LIKE 'guest_%'
    );

CREATE POLICY "사용자는 자신의 운세만 수정 가능" ON daily_fortunes
    FOR UPDATE USING (
        user_id = auth.uid()::TEXT OR 
        user_id LIKE 'guest_%'
    );

CREATE POLICY "사용자는 자신의 운세만 삭제 가능" ON daily_fortunes
    FOR DELETE USING (
        user_id = auth.uid()::TEXT OR 
        user_id LIKE 'guest_%'
    );

-- 댓글 및 설명
COMMENT ON TABLE daily_fortunes IS '사용자별 데일리 운세 저장 테이블';
COMMENT ON COLUMN daily_fortunes.user_id IS '사용자 ID (인증된 사용자 또는 게스트)';
COMMENT ON COLUMN daily_fortunes.fortune_type IS '운세 타입 (lucky-hiking, saju 등)';
COMMENT ON COLUMN daily_fortunes.fortune_data IS '운세 결과 데이터 (JSON)';
COMMENT ON COLUMN daily_fortunes.created_date IS '운세 생성 날짜';

-- 샘플 데이터 (개발용, 프로덕션에서는 제거)
-- INSERT INTO daily_fortunes (user_id, fortune_type, fortune_data, created_date) VALUES
-- ('guest_sample_123', 'lucky-hiking', '{"overall_luck": 85, "summit_luck": 90}', CURRENT_DATE); 