-- 관상 분석 히스토리 테이블
-- 2025-12-24: 관상 앱 리디자인 - 풀 트래킹 기능
-- 캘린더, 그래프, 비교 분석을 위한 히스토리 저장

-- ============================================
-- 1. face_reading_history 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS face_reading_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  result_id UUID NOT NULL,  -- 상세 결과 조회용 ID

  -- 사용자 정보
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
  age_group TEXT,  -- '20s', '30s', etc.

  -- 썸네일 (선택적 - 사용자 동의 시)
  thumbnail_url TEXT,

  -- 컨디션 스냅샷 (JSON)
  face_condition JSONB NOT NULL,
  -- {complexionScore, puffinessLevel, fatigueLevel, overallScore, todaySummary}

  -- 감정 분석 스냅샷 (JSON)
  emotion_analysis JSONB NOT NULL,
  -- {smilePercentage, tensionPercentage, neutralPercentage, dominantEmotion}

  -- 핵심 포인트 요약 (JSON)
  priority_insights JSONB NOT NULL DEFAULT '[]',
  -- [{category, message, score, emoji}]

  -- 점수들
  overall_fortune_score INT NOT NULL CHECK (overall_fortune_score >= 0 AND overall_fortune_score <= 100),

  -- 카테고리별 점수 (JSON)
  category_scores JSONB NOT NULL,
  -- {loveScore, marriageScore, relationshipScore, careerScore, wealthScore, healthScore, impressionScore}

  -- 사용자 메모
  user_note TEXT,

  -- 미션 완료 여부
  mission_completed BOOLEAN DEFAULT FALSE,

  -- 타임스탬프
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_face_reading_history_user_id ON face_reading_history(user_id);
CREATE INDEX IF NOT EXISTS idx_face_reading_history_created_at ON face_reading_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_face_reading_history_user_date ON face_reading_history(user_id, created_at DESC);

-- 날짜별 검색을 위한 인덱스 (캘린더용)
CREATE INDEX IF NOT EXISTS idx_face_reading_history_date ON face_reading_history(DATE(created_at));

-- ============================================
-- 2. RLS 정책
-- ============================================
ALTER TABLE face_reading_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own face reading history"
  ON face_reading_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own face reading history"
  ON face_reading_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own face reading history"
  ON face_reading_history FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own face reading history"
  ON face_reading_history FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 3. updated_at 자동 갱신 트리거
-- ============================================
CREATE OR REPLACE FUNCTION update_face_reading_history_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_face_reading_history_updated_at ON face_reading_history;
CREATE TRIGGER set_face_reading_history_updated_at
  BEFORE UPDATE ON face_reading_history
  FOR EACH ROW EXECUTE FUNCTION update_face_reading_history_updated_at();

-- ============================================
-- 4. 통계 조회 함수들
-- ============================================

-- 사용자의 히스토리 통계 조회
CREATE OR REPLACE FUNCTION get_face_reading_stats(p_user_id UUID)
RETURNS TABLE (
  total_analysis_count INT,
  streak_days INT,
  longest_streak INT,
  this_month_count INT,
  average_condition_score NUMERIC,
  average_smile_percentage NUMERIC,
  best_condition_date DATE,
  mission_completion_rate NUMERIC
) AS $$
DECLARE
  v_streak_days INT := 0;
  v_longest_streak INT := 0;
  v_current_streak INT := 0;
  v_prev_date DATE;
  r RECORD;
BEGIN
  -- 연속 기록 계산
  FOR r IN (
    SELECT DISTINCT DATE(created_at) as analysis_date
    FROM face_reading_history
    WHERE user_id = p_user_id
    ORDER BY analysis_date DESC
  ) LOOP
    IF v_prev_date IS NULL OR r.analysis_date = v_prev_date - INTERVAL '1 day' THEN
      v_current_streak := v_current_streak + 1;
    ELSE
      IF v_current_streak > v_longest_streak THEN
        v_longest_streak := v_current_streak;
      END IF;
      v_current_streak := 1;
    END IF;
    v_prev_date := r.analysis_date;
  END LOOP;

  -- 마지막 streak 확인
  IF v_current_streak > v_longest_streak THEN
    v_longest_streak := v_current_streak;
  END IF;

  -- 오늘부터 연속인 경우만 현재 streak으로
  IF EXISTS (
    SELECT 1 FROM face_reading_history
    WHERE user_id = p_user_id AND DATE(created_at) = CURRENT_DATE
  ) THEN
    v_streak_days := v_current_streak;
  ELSE
    v_streak_days := 0;
  END IF;

  RETURN QUERY
  SELECT
    COUNT(*)::INT as total_analysis_count,
    v_streak_days as streak_days,
    v_longest_streak as longest_streak,
    COUNT(*) FILTER (WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', NOW()))::INT as this_month_count,
    AVG((face_condition->>'overallScore')::INT)::NUMERIC as average_condition_score,
    AVG((emotion_analysis->>'smilePercentage')::NUMERIC)::NUMERIC as average_smile_percentage,
    (SELECT DATE(created_at) FROM face_reading_history
     WHERE user_id = p_user_id
     ORDER BY (face_condition->>'overallScore')::INT DESC LIMIT 1) as best_condition_date,
    (COUNT(*) FILTER (WHERE mission_completed = TRUE)::NUMERIC / NULLIF(COUNT(*), 0) * 100)::NUMERIC as mission_completion_rate
  FROM face_reading_history
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 최근 7일간 일별 컨디션 조회
CREATE OR REPLACE FUNCTION get_weekly_face_condition(p_user_id UUID)
RETURNS TABLE (
  analysis_date DATE,
  overall_score INT,
  complexion_score INT,
  puffiness_level INT,
  fatigue_level INT,
  smile_percentage NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    DATE(created_at) as analysis_date,
    (face_condition->>'overallScore')::INT as overall_score,
    (face_condition->>'complexionScore')::INT as complexion_score,
    (face_condition->>'puffinessLevel')::INT as puffiness_level,
    (face_condition->>'fatigueLevel')::INT as fatigue_level,
    (emotion_analysis->>'smilePercentage')::NUMERIC as smile_percentage
  FROM face_reading_history
  WHERE user_id = p_user_id
    AND created_at >= NOW() - INTERVAL '7 days'
  ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. 코멘트
-- ============================================
COMMENT ON TABLE face_reading_history IS '관상 분석 히스토리 - 캘린더, 그래프, 비교 분석용';
COMMENT ON COLUMN face_reading_history.result_id IS '상세 결과 조회용 ID (fortune_results 테이블)';
COMMENT ON COLUMN face_reading_history.face_condition IS '얼굴 컨디션 스냅샷 (혈색, 붓기, 피로도)';
COMMENT ON COLUMN face_reading_history.emotion_analysis IS '감정 분석 스냅샷 (미소, 긴장, 무표정 %)';
COMMENT ON COLUMN face_reading_history.priority_insights IS '핵심 포인트 3가지';
COMMENT ON COLUMN face_reading_history.category_scores IS '카테고리별 운세 점수 (연애, 결혼, 직업 등)';
COMMENT ON COLUMN face_reading_history.mission_completed IS '미소 미션 완료 여부';
