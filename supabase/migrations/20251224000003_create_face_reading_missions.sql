-- 관상 미션 시스템 테이블
-- 2025-12-24: 관상 앱 리디자인 - 미소 챌린지 등 미션 시스템
-- 자기계발 느낌 ❌, 재미있는 놀이형 챌린지 ✅

-- ============================================
-- 1. face_reading_missions 테이블 (미션 정의)
-- ============================================
CREATE TABLE IF NOT EXISTS face_reading_missions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- 미션 정보
  mission_type TEXT NOT NULL,  -- 'smile_challenge', 'weekly_streak', 'condition_goal'
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  emoji TEXT DEFAULT '😊',

  -- 목표 설정
  goal_type TEXT NOT NULL,  -- 'count', 'streak', 'score'
  goal_value INT NOT NULL,

  -- 보상
  reward_type TEXT,  -- 'badge', 'unlock_feature', 'special_reading'
  reward_value TEXT,

  -- 기간 설정
  duration_days INT,  -- NULL이면 영구

  -- 활성화 여부
  is_active BOOLEAN DEFAULT TRUE,

  -- 순서
  display_order INT DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 기본 미션 데이터 삽입
INSERT INTO face_reading_missions (mission_type, title, description, emoji, goal_type, goal_value, reward_type, duration_days, display_order)
VALUES
  ('smile_challenge', '미소 짓는 관상 만들기', '일주일 동안 매일 관상을 분석하고 미소 지수를 높여보세요!', '😊', 'streak', 7, 'badge', 7, 1),
  ('weekly_streak', '꾸준한 나', '7일 연속으로 관상을 분석해보세요', '📅', 'streak', 7, 'badge', NULL, 2),
  ('condition_goal', '빛나는 컨디션', '컨디션 점수 80점 이상을 달성해보세요', '✨', 'score', 80, 'badge', NULL, 3),
  ('smile_master', '미소 마스터', '미소 지수 70% 이상을 3일 연속 유지해보세요', '🌟', 'streak', 3, 'badge', NULL, 4)
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. face_reading_mission_progress 테이블 (사용자별 진행도)
-- ============================================
CREATE TABLE IF NOT EXISTS face_reading_mission_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mission_id UUID NOT NULL REFERENCES face_reading_missions(id) ON DELETE CASCADE,

  -- 진행 상태
  status TEXT NOT NULL DEFAULT 'in_progress',  -- 'in_progress', 'completed', 'expired'

  -- 진행도
  current_value INT DEFAULT 0,
  streak_count INT DEFAULT 0,  -- 연속 달성 횟수
  last_progress_date DATE,

  -- 시작/완료 시간
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,

  -- 보상 수령 여부
  reward_claimed BOOLEAN DEFAULT FALSE,

  -- 유니크 제약 (한 사용자당 하나의 미션)
  UNIQUE(user_id, mission_id)
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_mission_progress_user ON face_reading_mission_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_mission_progress_status ON face_reading_mission_progress(status);
CREATE INDEX IF NOT EXISTS idx_mission_progress_user_status ON face_reading_mission_progress(user_id, status);

-- ============================================
-- 3. RLS 정책
-- ============================================
ALTER TABLE face_reading_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE face_reading_mission_progress ENABLE ROW LEVEL SECURITY;

-- 미션 정의는 모든 사용자가 조회 가능
CREATE POLICY "Anyone can view active missions"
  ON face_reading_missions FOR SELECT
  USING (is_active = TRUE);

-- 미션 진행도는 본인만 접근
CREATE POLICY "Users can view own mission progress"
  ON face_reading_mission_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own mission progress"
  ON face_reading_mission_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own mission progress"
  ON face_reading_mission_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- 4. 미션 진행도 업데이트 함수
-- ============================================

-- 관상 분석 시 미션 진행도 자동 업데이트
CREATE OR REPLACE FUNCTION update_face_reading_mission_progress(
  p_user_id UUID,
  p_condition_score INT,
  p_smile_percentage NUMERIC
)
RETURNS VOID AS $$
DECLARE
  r RECORD;
  v_today DATE := CURRENT_DATE;
BEGIN
  -- 활성 미션들에 대해 진행도 업데이트
  FOR r IN (
    SELECT mp.*, m.goal_type, m.goal_value, m.mission_type
    FROM face_reading_mission_progress mp
    JOIN face_reading_missions m ON mp.mission_id = m.id
    WHERE mp.user_id = p_user_id AND mp.status = 'in_progress'
  ) LOOP

    -- streak 타입 미션
    IF r.goal_type = 'streak' THEN
      -- 오늘 이미 진행했으면 스킵
      IF r.last_progress_date = v_today THEN
        CONTINUE;
      END IF;

      -- 어제 진행했으면 연속, 아니면 리셋
      IF r.last_progress_date = v_today - 1 OR r.last_progress_date IS NULL THEN
        UPDATE face_reading_mission_progress
        SET
          current_value = current_value + 1,
          streak_count = COALESCE(streak_count, 0) + 1,
          last_progress_date = v_today,
          status = CASE WHEN current_value + 1 >= r.goal_value THEN 'completed' ELSE 'in_progress' END,
          completed_at = CASE WHEN current_value + 1 >= r.goal_value THEN NOW() ELSE NULL END
        WHERE id = r.id;
      ELSE
        -- 연속 끊김 - 리셋
        UPDATE face_reading_mission_progress
        SET
          current_value = 1,
          streak_count = 1,
          last_progress_date = v_today
        WHERE id = r.id;
      END IF;

    -- score 타입 미션 (컨디션 점수)
    ELSIF r.goal_type = 'score' AND r.mission_type = 'condition_goal' THEN
      IF p_condition_score >= r.goal_value THEN
        UPDATE face_reading_mission_progress
        SET
          current_value = p_condition_score,
          status = 'completed',
          completed_at = NOW(),
          last_progress_date = v_today
        WHERE id = r.id;
      ELSE
        UPDATE face_reading_mission_progress
        SET
          current_value = p_condition_score,
          last_progress_date = v_today
        WHERE id = r.id;
      END IF;

    -- smile_master 미션 (미소 70% 이상 3일 연속)
    ELSIF r.mission_type = 'smile_master' THEN
      IF p_smile_percentage >= 70 THEN
        IF r.last_progress_date = v_today - 1 OR r.last_progress_date IS NULL THEN
          UPDATE face_reading_mission_progress
          SET
            current_value = current_value + 1,
            streak_count = COALESCE(streak_count, 0) + 1,
            last_progress_date = v_today,
            status = CASE WHEN current_value + 1 >= r.goal_value THEN 'completed' ELSE 'in_progress' END,
            completed_at = CASE WHEN current_value + 1 >= r.goal_value THEN NOW() ELSE NULL END
          WHERE id = r.id;
        ELSE
          UPDATE face_reading_mission_progress
          SET current_value = 1, streak_count = 1, last_progress_date = v_today
          WHERE id = r.id;
        END IF;
      ELSE
        -- 미소 70% 미달 - 연속 끊김
        UPDATE face_reading_mission_progress
        SET current_value = 0, streak_count = 0
        WHERE id = r.id;
      END IF;
    END IF;

  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 사용자의 미션 현황 조회
CREATE OR REPLACE FUNCTION get_user_mission_status(p_user_id UUID)
RETURNS TABLE (
  mission_id UUID,
  mission_type TEXT,
  title TEXT,
  description TEXT,
  emoji TEXT,
  goal_value INT,
  current_value INT,
  status TEXT,
  progress_percentage INT,
  streak_count INT,
  reward_claimed BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.id as mission_id,
    m.mission_type,
    m.title,
    m.description,
    m.emoji,
    m.goal_value,
    COALESCE(mp.current_value, 0) as current_value,
    COALESCE(mp.status, 'not_started') as status,
    CASE
      WHEN mp.current_value IS NULL THEN 0
      ELSE LEAST(100, (mp.current_value * 100 / m.goal_value))
    END as progress_percentage,
    COALESCE(mp.streak_count, 0) as streak_count,
    COALESCE(mp.reward_claimed, FALSE) as reward_claimed
  FROM face_reading_missions m
  LEFT JOIN face_reading_mission_progress mp ON m.id = mp.mission_id AND mp.user_id = p_user_id
  WHERE m.is_active = TRUE
  ORDER BY m.display_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. 코멘트
-- ============================================
COMMENT ON TABLE face_reading_missions IS '관상 미션 정의 테이블';
COMMENT ON TABLE face_reading_mission_progress IS '사용자별 미션 진행도';
COMMENT ON COLUMN face_reading_missions.mission_type IS '미션 타입 (smile_challenge, weekly_streak 등)';
COMMENT ON COLUMN face_reading_missions.goal_type IS '목표 타입 (count, streak, score)';
COMMENT ON COLUMN face_reading_mission_progress.streak_count IS '연속 달성 횟수';
