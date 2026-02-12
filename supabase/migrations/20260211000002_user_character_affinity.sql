-- =============================================================================
-- 캐릭터 호감도/관계 시스템 테이블
-- 생성일: 2026-02-11
-- 목적: 사용자-캐릭터 간 호감도 영속성 및 관계 진행 추적
-- =============================================================================

-- 1. 메인 테이블 생성
CREATE TABLE IF NOT EXISTS user_character_affinity (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id TEXT NOT NULL,

  -- Core Stats (핵심 호감도)
  love_points INT NOT NULL DEFAULT 0 CHECK (love_points >= 0 AND love_points <= 1000),
  phase TEXT NOT NULL DEFAULT 'stranger' CHECK (phase IN ('stranger', 'acquaintance', 'friend', 'closeFriend', 'romantic', 'soulmate')),

  -- Interaction Stats (상호작용 통계)
  total_messages INT NOT NULL DEFAULT 0,
  positive_interactions INT NOT NULL DEFAULT 0,
  negative_interactions INT NOT NULL DEFAULT 0,
  first_interaction TIMESTAMPTZ DEFAULT now(),

  -- Daily Limits (일일 한도)
  daily_points_earned INT NOT NULL DEFAULT 0,
  last_daily_reset DATE DEFAULT CURRENT_DATE,

  -- Milestone Tracking (단계 달성 기록)
  phase_history JSONB DEFAULT '{}',

  -- Streak System (연속 접속)
  current_streak INT NOT NULL DEFAULT 0,
  longest_streak INT NOT NULL DEFAULT 0,
  last_chat_date DATE,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- Unique constraint: 사용자당 캐릭터별 1개 레코드
  UNIQUE(user_id, character_id)
);

-- 2. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_character_affinity_user_id
  ON user_character_affinity(user_id);

CREATE INDEX IF NOT EXISTS idx_user_character_affinity_character_id
  ON user_character_affinity(character_id);

CREATE INDEX IF NOT EXISTS idx_user_character_affinity_phase
  ON user_character_affinity(phase);

CREATE INDEX IF NOT EXISTS idx_user_character_affinity_streak
  ON user_character_affinity(current_streak DESC);

-- 3. RLS (Row Level Security) 활성화
ALTER TABLE user_character_affinity ENABLE ROW LEVEL SECURITY;

-- 4. RLS 정책
-- 4.1 사용자는 자신의 호감도만 조회 가능
CREATE POLICY "Users can view own affinity"
  ON user_character_affinity FOR SELECT
  USING (auth.uid() = user_id);

-- 4.2 사용자는 자신의 호감도만 생성 가능
CREATE POLICY "Users can insert own affinity"
  ON user_character_affinity FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 4.3 사용자는 자신의 호감도만 수정 가능
CREATE POLICY "Users can update own affinity"
  ON user_character_affinity FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 4.4 사용자는 자신의 호감도만 삭제 가능
CREATE POLICY "Users can delete own affinity"
  ON user_character_affinity FOR DELETE
  USING (auth.uid() = user_id);

-- 5. updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_user_character_affinity_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_character_affinity_updated_at
  BEFORE UPDATE ON user_character_affinity
  FOR EACH ROW
  EXECUTE FUNCTION update_user_character_affinity_updated_at();

-- 6. 일일 리셋 함수 (daily_points_earned 초기화)
CREATE OR REPLACE FUNCTION reset_daily_affinity_points()
RETURNS void AS $$
BEGIN
  UPDATE user_character_affinity
  SET daily_points_earned = 0,
      last_daily_reset = CURRENT_DATE
  WHERE last_daily_reset < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. 호감도 업데이트 함수 (원자적 연산)
CREATE OR REPLACE FUNCTION update_character_affinity(
  p_user_id UUID,
  p_character_id TEXT,
  p_points_delta INT,
  p_interaction_type TEXT DEFAULT 'neutral'
)
RETURNS user_character_affinity AS $$
DECLARE
  v_result user_character_affinity;
  v_new_points INT;
  v_new_phase TEXT;
  v_today DATE := CURRENT_DATE;
BEGIN
  -- Upsert: 없으면 생성, 있으면 업데이트
  INSERT INTO user_character_affinity (user_id, character_id, love_points, phase)
  VALUES (p_user_id, p_character_id, GREATEST(0, LEAST(1000, p_points_delta)),
          CASE
            WHEN p_points_delta >= 900 THEN 'soulmate'
            WHEN p_points_delta >= 700 THEN 'romantic'
            WHEN p_points_delta >= 500 THEN 'closeFriend'
            WHEN p_points_delta >= 300 THEN 'friend'
            WHEN p_points_delta >= 100 THEN 'acquaintance'
            ELSE 'stranger'
          END)
  ON CONFLICT (user_id, character_id) DO UPDATE SET
    -- 포인트 계산 (0-1000 범위)
    love_points = GREATEST(0, LEAST(1000, user_character_affinity.love_points + p_points_delta)),

    -- 단계 재계산
    phase = CASE
      WHEN GREATEST(0, LEAST(1000, user_character_affinity.love_points + p_points_delta)) >= 900 THEN 'soulmate'
      WHEN GREATEST(0, LEAST(1000, user_character_affinity.love_points + p_points_delta)) >= 700 THEN 'romantic'
      WHEN GREATEST(0, LEAST(1000, user_character_affinity.love_points + p_points_delta)) >= 500 THEN 'closeFriend'
      WHEN GREATEST(0, LEAST(1000, user_character_affinity.love_points + p_points_delta)) >= 300 THEN 'friend'
      WHEN GREATEST(0, LEAST(1000, user_character_affinity.love_points + p_points_delta)) >= 100 THEN 'acquaintance'
      ELSE 'stranger'
    END,

    -- 메시지 수 증가
    total_messages = user_character_affinity.total_messages + 1,

    -- 상호작용 타입별 카운트
    positive_interactions = user_character_affinity.positive_interactions +
      CASE WHEN p_interaction_type = 'positive' THEN 1 ELSE 0 END,
    negative_interactions = user_character_affinity.negative_interactions +
      CASE WHEN p_interaction_type = 'negative' THEN 1 ELSE 0 END,

    -- 일일 포인트 (양수만)
    daily_points_earned = CASE
      WHEN user_character_affinity.last_daily_reset < v_today THEN GREATEST(0, p_points_delta)
      ELSE user_character_affinity.daily_points_earned + GREATEST(0, p_points_delta)
    END,
    last_daily_reset = v_today,

    -- 스트릭 계산
    current_streak = CASE
      WHEN user_character_affinity.last_chat_date = v_today - 1
        THEN user_character_affinity.current_streak + 1
      WHEN user_character_affinity.last_chat_date = v_today
        THEN user_character_affinity.current_streak
      ELSE 1
    END,
    longest_streak = GREATEST(
      user_character_affinity.longest_streak,
      CASE
        WHEN user_character_affinity.last_chat_date = v_today - 1
          THEN user_character_affinity.current_streak + 1
        WHEN user_character_affinity.last_chat_date = v_today
          THEN user_character_affinity.current_streak
        ELSE 1
      END
    ),
    last_chat_date = v_today,

    updated_at = now()
  RETURNING * INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. 장기 부재 패널티 적용 함수 (주당 -5점, 최대 -50)
CREATE OR REPLACE FUNCTION apply_absence_penalty()
RETURNS void AS $$
BEGIN
  UPDATE user_character_affinity
  SET
    love_points = GREATEST(0, love_points -
      LEAST(50, 5 * FLOOR(EXTRACT(EPOCH FROM (now() - (last_chat_date::TIMESTAMPTZ + INTERVAL '7 days'))) / 604800))),
    phase = CASE
      WHEN GREATEST(0, love_points - LEAST(50, 5 * FLOOR(EXTRACT(EPOCH FROM (now() - (last_chat_date::TIMESTAMPTZ + INTERVAL '7 days'))) / 604800))) >= 900 THEN 'soulmate'
      WHEN GREATEST(0, love_points - LEAST(50, 5 * FLOOR(EXTRACT(EPOCH FROM (now() - (last_chat_date::TIMESTAMPTZ + INTERVAL '7 days'))) / 604800))) >= 700 THEN 'romantic'
      WHEN GREATEST(0, love_points - LEAST(50, 5 * FLOOR(EXTRACT(EPOCH FROM (now() - (last_chat_date::TIMESTAMPTZ + INTERVAL '7 days'))) / 604800))) >= 500 THEN 'closeFriend'
      WHEN GREATEST(0, love_points - LEAST(50, 5 * FLOOR(EXTRACT(EPOCH FROM (now() - (last_chat_date::TIMESTAMPTZ + INTERVAL '7 days'))) / 604800))) >= 300 THEN 'friend'
      WHEN GREATEST(0, love_points - LEAST(50, 5 * FLOOR(EXTRACT(EPOCH FROM (now() - (last_chat_date::TIMESTAMPTZ + INTERVAL '7 days'))) / 604800))) >= 100 THEN 'acquaintance'
      ELSE 'stranger'
    END,
    updated_at = now()
  WHERE last_chat_date < CURRENT_DATE - 7;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. 코멘트 추가
COMMENT ON TABLE user_character_affinity IS '캐릭터 호감도 및 관계 진행 상태';
COMMENT ON COLUMN user_character_affinity.love_points IS '호감도 포인트 (0-1000)';
COMMENT ON COLUMN user_character_affinity.phase IS '관계 단계 (stranger, acquaintance, friend, closeFriend, romantic, soulmate)';
COMMENT ON COLUMN user_character_affinity.daily_points_earned IS '오늘 획득한 포인트 (일일 한도 체크용)';
COMMENT ON COLUMN user_character_affinity.phase_history IS '각 단계 최초 달성 시간 기록 (JSON)';
COMMENT ON COLUMN user_character_affinity.current_streak IS '현재 연속 접속일';
COMMENT ON FUNCTION update_character_affinity IS '호감도 원자적 업데이트 (포인트, 단계, 스트릭 동시 처리)';
