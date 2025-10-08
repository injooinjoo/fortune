-- API 비용 최적화를 위한 fortune_history 메타데이터 개선
-- 유사 운세 검색 성능 향상

-- 1. metadata 컬럼에 GIN 인덱스 추가 (JSONB 검색 최적화)
CREATE INDEX IF NOT EXISTS idx_fortune_history_metadata_gin
ON fortune_history USING GIN(metadata jsonb_path_ops);

-- 2. 운세 타입 + 메타데이터 복합 인덱스
CREATE INDEX IF NOT EXISTS idx_fortune_history_type_metadata
ON fortune_history(fortune_type, ((metadata->>'gender')), ((metadata->>'age_group')));

-- 3. 유사 운세 검색 함수 (정확한 매칭)
CREATE OR REPLACE FUNCTION find_similar_fortune_exact(
  p_fortune_type VARCHAR,
  p_gender VARCHAR,
  p_age_group VARCHAR,
  p_mbti VARCHAR,
  p_days_ago INTEGER DEFAULT 30
)
RETURNS TABLE (
  fortune_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  score INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    fh.fortune_data,
    fh.created_at,
    fh.score
  FROM fortune_history fh
  WHERE fh.fortune_type = p_fortune_type
    AND fh.metadata->>'gender' = p_gender
    AND fh.metadata->>'age_group' = p_age_group
    AND fh.metadata->>'mbti' = p_mbti
    AND fh.created_at >= NOW() - (p_days_ago || ' days')::INTERVAL
  ORDER BY fh.created_at DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. 유사 운세 검색 함수 (완화된 매칭)
CREATE OR REPLACE FUNCTION find_similar_fortune_relaxed(
  p_fortune_type VARCHAR,
  p_gender VARCHAR,
  p_age_group VARCHAR,
  p_days_ago INTEGER DEFAULT 60
)
RETURNS TABLE (
  fortune_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  score INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    fh.fortune_data,
    fh.created_at,
    fh.score
  FROM fortune_history fh
  WHERE fh.fortune_type = p_fortune_type
    AND fh.metadata->>'gender' = p_gender
    AND fh.metadata->>'age_group' = p_age_group
    AND fh.created_at >= NOW() - (p_days_ago || ' days')::INTERVAL
  ORDER BY fh.created_at DESC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. 유사 운세 검색 함수 (타입만 매칭)
CREATE OR REPLACE FUNCTION find_similar_fortune_by_type(
  p_fortune_type VARCHAR,
  p_days_ago INTEGER DEFAULT 90
)
RETURNS TABLE (
  fortune_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  score INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    fh.fortune_data,
    fh.created_at,
    fh.score
  FROM fortune_history fh
  WHERE fh.fortune_type = p_fortune_type
    AND fh.created_at >= NOW() - (p_days_ago || ' days')::INTERVAL
  ORDER BY fh.created_at DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. 사용자 등급 계산 함수 (VIP/신규/일반/휴면 판단)
CREATE OR REPLACE FUNCTION calculate_user_grade(p_user_id UUID)
RETURNS TABLE (
  grade VARCHAR,
  total_fortunes BIGINT,
  recent_fortunes BIGINT,
  days_since_first INTEGER,
  days_since_last INTEGER
) AS $$
DECLARE
  v_total BIGINT;
  v_recent BIGINT;
  v_first_date TIMESTAMP;
  v_last_date TIMESTAMP;
  v_days_first INTEGER;
  v_days_last INTEGER;
  v_grade VARCHAR;
BEGIN
  -- 전체 운세 수
  SELECT COUNT(*) INTO v_total
  FROM fortune_history
  WHERE user_id = p_user_id;

  -- 최근 7일 운세 수
  SELECT COUNT(*) INTO v_recent
  FROM fortune_history
  WHERE user_id = p_user_id
    AND created_at >= NOW() - INTERVAL '7 days';

  -- 첫 운세 날짜
  SELECT MIN(created_at) INTO v_first_date
  FROM fortune_history
  WHERE user_id = p_user_id;

  -- 마지막 운세 날짜
  SELECT MAX(created_at) INTO v_last_date
  FROM fortune_history
  WHERE user_id = p_user_id;

  -- 경과 일수 계산
  v_days_first := EXTRACT(DAY FROM NOW() - COALESCE(v_first_date, NOW()));
  v_days_last := EXTRACT(DAY FROM NOW() - COALESCE(v_last_date, NOW()));

  -- 등급 판단
  IF v_total = 0 THEN
    v_grade := 'NEW'; -- 신규
  ELSIF v_recent >= 5 THEN
    v_grade := 'VIP'; -- VIP
  ELSIF v_days_last >= 30 THEN
    v_grade := 'DORMANT'; -- 휴면
  ELSE
    v_grade := 'REGULAR'; -- 일반
  END IF;

  RETURN QUERY SELECT v_grade, v_total, v_recent, v_days_first, v_days_last;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. API 호출 통계 테이블 생성 (비용 추적용)
CREATE TABLE IF NOT EXISTS api_call_statistics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  fortune_type VARCHAR(50) NOT NULL,
  call_type VARCHAR(20) NOT NULL, -- 'API' or 'REUSE'
  user_grade VARCHAR(20), -- 'VIP', 'NEW', 'REGULAR', 'DORMANT'
  decision_probability NUMERIC(4,3), -- 최종 확률 (0.000 ~ 1.000)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. API 호출 통계 인덱스
CREATE INDEX idx_api_stats_user ON api_call_statistics(user_id, created_at DESC);
CREATE INDEX idx_api_stats_type ON api_call_statistics(fortune_type, call_type, created_at DESC);
CREATE INDEX idx_api_stats_grade ON api_call_statistics(user_grade, call_type);

-- 9. API 호출 통계 조회 함수 (일별 집계)
CREATE OR REPLACE FUNCTION get_api_call_stats_daily(p_days INTEGER DEFAULT 7)
RETURNS TABLE (
  date DATE,
  total_calls BIGINT,
  api_calls BIGINT,
  reuse_calls BIGINT,
  api_rate NUMERIC(5,2),
  cost_savings NUMERIC(10,2)
) AS $$
BEGIN
  RETURN QUERY
  WITH daily_stats AS (
    SELECT
      created_at::DATE as stat_date,
      COUNT(*) as total,
      COUNT(*) FILTER (WHERE call_type = 'API') as api,
      COUNT(*) FILTER (WHERE call_type = 'REUSE') as reuse
    FROM api_call_statistics
    WHERE created_at >= NOW() - (p_days || ' days')::INTERVAL
    GROUP BY created_at::DATE
  )
  SELECT
    stat_date,
    total,
    api,
    reuse,
    ROUND((api::NUMERIC / NULLIF(total, 0)) * 100, 2) as api_rate,
    ROUND(reuse * 0.01, 2) as cost_savings -- 재사용당 $0.01 절감 가정
  FROM daily_stats
  ORDER BY stat_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. RLS 정책 설정
ALTER TABLE api_call_statistics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own API stats" ON api_call_statistics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert API stats" ON api_call_statistics
  FOR INSERT WITH CHECK (true); -- 시스템이 자동 기록

-- 11. 권한 부여
GRANT EXECUTE ON FUNCTION find_similar_fortune_exact(VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION find_similar_fortune_relaxed(VARCHAR, VARCHAR, VARCHAR, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION find_similar_fortune_by_type(VARCHAR, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_user_grade(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_api_call_stats_daily(INTEGER) TO authenticated;

-- 완료 메시지
DO $$
BEGIN
  RAISE NOTICE '✅ API 비용 최적화 마이그레이션 완료';
  RAISE NOTICE '   - 메타데이터 인덱스 추가';
  RAISE NOTICE '   - 유사 운세 검색 함수 3종';
  RAISE NOTICE '   - 사용자 등급 계산 함수';
  RAISE NOTICE '   - API 호출 통계 테이블 및 함수';
END $$;
