-- 관상 컨디션 트래킹 테이블
-- 2025-12-24: 관상 앱 리디자인 - 컨디션 변화 추적
-- 그래프, 트렌드 분석을 위한 상세 컨디션 데이터

-- ============================================
-- 1. face_reading_conditions 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS face_reading_conditions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  history_id UUID REFERENCES face_reading_history(id) ON DELETE CASCADE,

  -- 날짜 (일별 유니크)
  analysis_date DATE NOT NULL,

  -- 컨디션 점수들
  complexion_score INT NOT NULL CHECK (complexion_score >= 0 AND complexion_score <= 100),
  complexion_description TEXT,

  puffiness_level INT NOT NULL CHECK (puffiness_level >= 0 AND puffiness_level <= 100),
  puffiness_description TEXT,

  fatigue_level INT NOT NULL CHECK (fatigue_level >= 0 AND fatigue_level <= 100),
  fatigue_description TEXT,

  overall_score INT NOT NULL CHECK (overall_score >= 0 AND overall_score <= 100),
  today_summary TEXT,

  -- 감정 분석
  smile_percentage NUMERIC(5,2) DEFAULT 0,
  tension_percentage NUMERIC(5,2) DEFAULT 0,
  neutral_percentage NUMERIC(5,2) DEFAULT 0,
  relaxed_percentage NUMERIC(5,2) DEFAULT 0,
  dominant_emotion TEXT,

  -- 개선 팁 (JSON)
  improvement_tips JSONB DEFAULT '[]',

  -- 타임스탬프
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- 일별 유니크 제약
  UNIQUE(user_id, analysis_date)
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_face_reading_conditions_user_id ON face_reading_conditions(user_id);
CREATE INDEX IF NOT EXISTS idx_face_reading_conditions_date ON face_reading_conditions(analysis_date DESC);
CREATE INDEX IF NOT EXISTS idx_face_reading_conditions_user_date ON face_reading_conditions(user_id, analysis_date DESC);

-- ============================================
-- 2. RLS 정책
-- ============================================
ALTER TABLE face_reading_conditions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own face reading conditions"
  ON face_reading_conditions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own face reading conditions"
  ON face_reading_conditions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own face reading conditions"
  ON face_reading_conditions FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- 3. 트렌드 분석 함수
-- ============================================

-- 주간 트렌드 분석
CREATE OR REPLACE FUNCTION get_face_condition_trend(p_user_id UUID, p_days INT DEFAULT 7)
RETURNS TABLE (
  weekly_average NUMERIC,
  weekly_change NUMERIC,
  trend_direction TEXT,
  trend_insight TEXT,
  avg_smile_percentage NUMERIC
) AS $$
DECLARE
  v_this_week_avg NUMERIC;
  v_last_week_avg NUMERIC;
  v_change NUMERIC;
  v_direction TEXT;
  v_insight TEXT;
  v_smile_avg NUMERIC;
BEGIN
  -- 이번 주 평균
  SELECT AVG(overall_score), AVG(smile_percentage)
  INTO v_this_week_avg, v_smile_avg
  FROM face_reading_conditions
  WHERE user_id = p_user_id
    AND analysis_date >= CURRENT_DATE - p_days;

  -- 지난 주 평균
  SELECT AVG(overall_score)
  INTO v_last_week_avg
  FROM face_reading_conditions
  WHERE user_id = p_user_id
    AND analysis_date >= CURRENT_DATE - (p_days * 2)
    AND analysis_date < CURRENT_DATE - p_days;

  -- 변화율 계산
  IF v_last_week_avg IS NOT NULL AND v_last_week_avg > 0 THEN
    v_change := ((v_this_week_avg - v_last_week_avg) / v_last_week_avg) * 100;
  ELSE
    v_change := 0;
  END IF;

  -- 방향 결정
  IF v_change > 5 THEN
    v_direction := 'improving';
    v_insight := '요즘 표정이 점점 밝아지고 있어요 ✨';
  ELSIF v_change < -5 THEN
    v_direction := 'declining';
    v_insight := '조금 피곤해 보이는 날이 많았네요. 충분히 쉬어가세요 💤';
  ELSE
    v_direction := 'stable';
    v_insight := '안정적인 컨디션을 유지하고 있어요 👍';
  END IF;

  RETURN QUERY SELECT
    COALESCE(v_this_week_avg, 0) as weekly_average,
    COALESCE(v_change, 0) as weekly_change,
    v_direction as trend_direction,
    v_insight as trend_insight,
    COALESCE(v_smile_avg, 0) as avg_smile_percentage;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 두 날짜 비교 함수
CREATE OR REPLACE FUNCTION compare_face_conditions(
  p_user_id UUID,
  p_date1 DATE,
  p_date2 DATE
)
RETURNS TABLE (
  date1 DATE,
  date2 DATE,
  complexion_change INT,
  puffiness_change INT,
  fatigue_change INT,
  overall_change INT,
  smile_change NUMERIC,
  comparison_summary TEXT
) AS $$
DECLARE
  v_cond1 RECORD;
  v_cond2 RECORD;
  v_overall_change INT;
  v_summary TEXT;
BEGIN
  -- 첫 번째 날짜 데이터
  SELECT * INTO v_cond1
  FROM face_reading_conditions
  WHERE user_id = p_user_id AND analysis_date = p_date1;

  -- 두 번째 날짜 데이터
  SELECT * INTO v_cond2
  FROM face_reading_conditions
  WHERE user_id = p_user_id AND analysis_date = p_date2;

  IF v_cond1 IS NULL OR v_cond2 IS NULL THEN
    RETURN QUERY SELECT
      p_date1, p_date2, 0, 0, 0, 0, 0::NUMERIC, '비교할 데이터가 부족해요'::TEXT;
    RETURN;
  END IF;

  v_overall_change := v_cond2.overall_score - v_cond1.overall_score;

  -- 요약 생성
  IF v_overall_change > 10 THEN
    v_summary := '전반적으로 컨디션이 많이 좋아졌어요! 🎉';
  ELSIF v_overall_change > 0 THEN
    v_summary := '조금씩 좋아지고 있어요 😊';
  ELSIF v_overall_change < -10 THEN
    v_summary := '컨디션 관리가 필요해 보여요 💪';
  ELSE
    v_summary := '비슷한 컨디션을 유지하고 있어요';
  END IF;

  RETURN QUERY SELECT
    p_date1 as date1,
    p_date2 as date2,
    (v_cond2.complexion_score - v_cond1.complexion_score) as complexion_change,
    (v_cond2.puffiness_level - v_cond1.puffiness_level) as puffiness_change,
    (v_cond2.fatigue_level - v_cond1.fatigue_level) as fatigue_change,
    v_overall_change as overall_change,
    (v_cond2.smile_percentage - v_cond1.smile_percentage) as smile_change,
    v_summary as comparison_summary;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 4. 코멘트
-- ============================================
COMMENT ON TABLE face_reading_conditions IS '관상 컨디션 일별 트래킹 데이터';
COMMENT ON COLUMN face_reading_conditions.analysis_date IS '분석 날짜 (일별 유니크)';
COMMENT ON COLUMN face_reading_conditions.complexion_score IS '혈색 점수 (0-100)';
COMMENT ON COLUMN face_reading_conditions.puffiness_level IS '붓기 레벨 (0-100, 낮을수록 좋음)';
COMMENT ON COLUMN face_reading_conditions.fatigue_level IS '피로도 레벨 (0-100, 낮을수록 좋음)';
COMMENT ON COLUMN face_reading_conditions.smile_percentage IS '미소 지수 (0-100%)';
COMMENT ON COLUMN face_reading_conditions.improvement_tips IS '컨디션 개선 팁 목록';
