-- 운세 히스토리 테이블 생성 (영구 저장)
-- 모든 운세 결과를 영구적으로 저장하여 사용자가 나중에 다시 볼 수 있도록 함

-- 기존 테이블이 있다면 삭제 (개발 환경용)
DROP TABLE IF EXISTS fortune_history CASCADE;

-- fortune_history 테이블 생성 (영구 저장)
CREATE TABLE fortune_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fortune_type VARCHAR(50) NOT NULL, -- 'daily', 'weekly', 'monthly', 'yearly', etc.
  title VARCHAR(255) NOT NULL, -- 운세 제목
  summary JSONB NOT NULL, -- 운세 요약 정보 (점수, 메시지 등)
  fortune_data JSONB NOT NULL, -- 전체 운세 데이터 (API 응답 전체)
  score INTEGER, -- 운세 점수 (그래프용)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 추가 메타데이터
  metadata JSONB, -- 사용자 입력 정보, 설정값 등
  tags TEXT[], -- 운세 관련 태그들
  view_count INTEGER DEFAULT 1, -- 조회수
  is_shared BOOLEAN DEFAULT FALSE, -- 공유 여부
  last_viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), -- 마지막 조회 시간
  mood VARCHAR(50), -- 당시 기분/상태
  actual_result TEXT, -- 실제 결과 (사용자가 나중에 기록)
  
  -- 날짜별 조회를 위한 Generated Column
  fortune_date DATE GENERATED ALWAYS AS (created_at::DATE) STORED
);

-- 성능을 위한 인덱스 생성
CREATE INDEX idx_fortune_history_user_date ON fortune_history(user_id, fortune_date DESC);
CREATE INDEX idx_fortune_history_user_type ON fortune_history(user_id, fortune_type, created_at DESC);
CREATE INDEX idx_fortune_history_score ON fortune_history(user_id, score DESC) WHERE score IS NOT NULL;
CREATE INDEX idx_fortune_history_tags ON fortune_history USING GIN(tags) WHERE tags IS NOT NULL;

-- RLS (Row Level Security) 정책 설정
ALTER TABLE fortune_history ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 히스토리만 접근 가능
CREATE POLICY "Users can view own fortune history" ON fortune_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fortune history" ON fortune_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fortune history" ON fortune_history
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own fortune history" ON fortune_history
  FOR DELETE USING (auth.uid() = user_id);

-- 통계 조회를 위한 함수들 생성
CREATE OR REPLACE FUNCTION get_user_fortune_stats(target_user_id UUID)
RETURNS TABLE (
  total_fortunes BIGINT,
  avg_score NUMERIC,
  best_score INTEGER,
  worst_score INTEGER,
  most_common_type TEXT,
  fortune_streak INTEGER
) AS $$
BEGIN
  RETURN QUERY
  WITH stats AS (
    SELECT 
      COUNT(*) as total,
      ROUND(AVG(score), 1) as avg_score_val,
      MAX(score) as best_score_val,
      MIN(score) as worst_score_val,
      MODE() WITHIN GROUP (ORDER BY fortune_type) as common_type
    FROM fortune_history 
    WHERE user_id = target_user_id AND score IS NOT NULL
  ),
  streak AS (
    SELECT COUNT(*) as current_streak
    FROM (
      SELECT fortune_date,
             ROW_NUMBER() OVER (ORDER BY fortune_date DESC) -
             ROW_NUMBER() OVER (PARTITION BY fortune_date - INTERVAL '1 day' * ROW_NUMBER() OVER (ORDER BY fortune_date DESC) ORDER BY fortune_date DESC) as grp
      FROM fortune_history 
      WHERE user_id = target_user_id 
        AND fortune_type = 'daily'
        AND fortune_date <= CURRENT_DATE
      ORDER BY fortune_date DESC
    ) t
    WHERE grp = 0
  )
  SELECT s.total, s.avg_score_val, s.best_score_val, s.worst_score_val, s.common_type, st.current_streak
  FROM stats s, streak st;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 월별 운세 점수 조회 함수
CREATE OR REPLACE FUNCTION get_monthly_fortune_scores(target_user_id UUID, target_year INTEGER, target_month INTEGER)
RETURNS TABLE (
  fortune_date DATE,
  score INTEGER,
  fortune_type TEXT,
  title TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT fh.fortune_date, fh.score, fh.fortune_type, fh.title
  FROM fortune_history fh
  WHERE fh.user_id = target_user_id
    AND EXTRACT(YEAR FROM fh.fortune_date) = target_year
    AND EXTRACT(MONTH FROM fh.fortune_date) = target_month
    AND fh.score IS NOT NULL
  ORDER BY fh.fortune_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7일간 일일 운세 점수 조회 함수 (그래프용)
CREATE OR REPLACE FUNCTION get_last_7_days_scores(target_user_id UUID)
RETURNS TABLE (
  day_offset INTEGER,
  fortune_date DATE,
  score INTEGER
) AS $$
BEGIN
  RETURN QUERY
  WITH date_series AS (
    SELECT 
      generate_series(0, 6) as day_offset,
      (CURRENT_DATE - generate_series(6, 0, -1))::DATE as fortune_date
  )
  SELECT 
    ds.day_offset,
    ds.fortune_date,
    COALESCE(fh.score, 0) as score
  FROM date_series ds
  LEFT JOIN fortune_history fh ON (
    fh.user_id = target_user_id 
    AND fh.fortune_date = ds.fortune_date 
    AND fh.fortune_type = 'daily'
  )
  ORDER BY ds.day_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 권한 부여
GRANT EXECUTE ON FUNCTION get_user_fortune_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_monthly_fortune_scores(UUID, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_last_7_days_scores(UUID) TO authenticated;