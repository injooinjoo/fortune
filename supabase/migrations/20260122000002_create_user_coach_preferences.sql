-- =====================================================
-- User Coach Preferences Table
-- ZPZG Decision Coach Pivot - Phase 1.1
-- AI 코칭 개인화 설정
-- =====================================================

-- =====================================================
-- Main Table: user_coach_preferences
-- AI 코치 톤/스타일 개인화 설정
-- =====================================================
CREATE TABLE IF NOT EXISTS user_coach_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- AI 톤 설정
  tone_preference TEXT DEFAULT 'adaptive' CHECK (tone_preference IN ('friendly', 'professional', 'adaptive')),
  -- friendly: 친근한 친구 톤
  -- professional: 전문 컨설턴트 톤
  -- adaptive: 상황에 맞게 자동 조절

  -- 응답 길이 선호
  response_length TEXT DEFAULT 'balanced' CHECK (response_length IN ('concise', 'balanced', 'detailed')),
  -- concise: 짧고 핵심적
  -- balanced: 적절한 분량
  -- detailed: 상세한 설명

  -- 결정 스타일
  decision_style TEXT DEFAULT 'balanced' CHECK (decision_style IN ('logic', 'empathy', 'balanced')),
  -- logic: 논리/데이터 중심
  -- empathy: 감정/공감 중심
  -- balanced: 균형 잡힌 접근

  -- 사용자 컨텍스트
  relationship_status TEXT CHECK (relationship_status IN ('single', 'dating', 'married', 'complicated', 'prefer_not_to_say')),
  age_group TEXT CHECK (age_group IN ('teens', '20s', '30s', '40s', '50s_plus', 'prefer_not_to_say')),
  occupation_type TEXT,  -- 직업군 (자유 입력)

  -- 카테고리 선호도
  preferred_categories TEXT[] DEFAULT ARRAY['dating', 'career', 'lifestyle'],

  -- 알림 설정
  follow_up_reminder_enabled BOOLEAN DEFAULT TRUE,
  follow_up_days INTEGER DEFAULT 7 CHECK (follow_up_days >= 1 AND follow_up_days <= 30),
  push_notification_enabled BOOLEAN DEFAULT TRUE,

  -- 개인화 데이터 (AI 학습용)
  interaction_summary JSONB DEFAULT '{}',
  -- {
  --   "total_sessions": 0,
  --   "avg_confidence": 0,
  --   "positive_outcome_rate": 0,
  --   "most_discussed_topics": [],
  --   "last_updated": null
  -- }

  -- 익명 커뮤니티 설정
  community_anonymous_prefix TEXT DEFAULT 'animal',  -- 'animal', 'color', 'random'
  community_participation_enabled BOOLEAN DEFAULT TRUE,

  -- 메타데이터
  metadata JSONB DEFAULT '{}',

  -- 타임스탬프
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Indexes
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_user_coach_preferences_tone
  ON user_coach_preferences(tone_preference);

CREATE INDEX IF NOT EXISTS idx_user_coach_preferences_categories
  ON user_coach_preferences USING GIN (preferred_categories);

-- =====================================================
-- Updated_at Trigger
-- =====================================================
CREATE OR REPLACE FUNCTION update_user_coach_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_user_coach_preferences_updated_at ON user_coach_preferences;
CREATE TRIGGER trigger_user_coach_preferences_updated_at
  BEFORE UPDATE ON user_coach_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_user_coach_preferences_updated_at();

-- =====================================================
-- RLS Policies
-- =====================================================
ALTER TABLE user_coach_preferences ENABLE ROW LEVEL SECURITY;

-- Users can only see their own preferences
CREATE POLICY "Users can view own coach preferences"
  ON user_coach_preferences
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own preferences
CREATE POLICY "Users can insert own coach preferences"
  ON user_coach_preferences
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own preferences
CREATE POLICY "Users can update own coach preferences"
  ON user_coach_preferences
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own preferences
CREATE POLICY "Users can delete own coach preferences"
  ON user_coach_preferences
  FOR DELETE
  USING (auth.uid() = user_id);

-- Service role can do anything (for Edge Functions)
CREATE POLICY "Service role full access on coach preferences"
  ON user_coach_preferences
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- =====================================================
-- Helper Functions
-- =====================================================

-- Get or create user preferences (upsert pattern)
CREATE OR REPLACE FUNCTION get_or_create_coach_preferences(p_user_id UUID)
RETURNS user_coach_preferences AS $$
DECLARE
  result user_coach_preferences;
BEGIN
  -- Try to get existing
  SELECT * INTO result FROM user_coach_preferences WHERE user_id = p_user_id;

  -- If not found, create default
  IF NOT FOUND THEN
    INSERT INTO user_coach_preferences (user_id)
    VALUES (p_user_id)
    RETURNING * INTO result;
  END IF;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update interaction summary (called by Edge Functions after each session)
CREATE OR REPLACE FUNCTION update_coach_interaction_summary(
  p_user_id UUID,
  p_confidence INTEGER DEFAULT NULL,
  p_outcome_positive BOOLEAN DEFAULT NULL,
  p_topics TEXT[] DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  current_summary JSONB;
  new_total INTEGER;
  new_avg_confidence NUMERIC;
  new_positive_rate NUMERIC;
  existing_topics TEXT[];
  merged_topics TEXT[];
BEGIN
  -- Get current summary
  SELECT interaction_summary INTO current_summary
  FROM user_coach_preferences
  WHERE user_id = p_user_id;

  IF current_summary IS NULL THEN
    current_summary := '{}'::jsonb;
  END IF;

  -- Calculate new values
  new_total := COALESCE((current_summary->>'total_sessions')::INTEGER, 0) + 1;

  IF p_confidence IS NOT NULL THEN
    new_avg_confidence := (
      COALESCE((current_summary->>'avg_confidence')::NUMERIC, 0) *
      (new_total - 1) + p_confidence
    ) / new_total;
  ELSE
    new_avg_confidence := COALESCE((current_summary->>'avg_confidence')::NUMERIC, 0);
  END IF;

  IF p_outcome_positive IS NOT NULL THEN
    new_positive_rate := (
      COALESCE((current_summary->>'positive_outcome_rate')::NUMERIC, 0) *
      (new_total - 1) + (CASE WHEN p_outcome_positive THEN 1 ELSE 0 END)
    ) / new_total;
  ELSE
    new_positive_rate := COALESCE((current_summary->>'positive_outcome_rate')::NUMERIC, 0);
  END IF;

  -- Merge topics (keep unique, limit to 20)
  existing_topics := COALESCE(ARRAY(SELECT jsonb_array_elements_text(current_summary->'most_discussed_topics')), ARRAY[]::TEXT[]);
  merged_topics := (SELECT ARRAY_AGG(DISTINCT topic) FROM (
    SELECT unnest(existing_topics || COALESCE(p_topics, ARRAY[]::TEXT[])) as topic
  ) t LIMIT 20);

  -- Update summary
  UPDATE user_coach_preferences
  SET interaction_summary = jsonb_build_object(
    'total_sessions', new_total,
    'avg_confidence', ROUND(new_avg_confidence, 2),
    'positive_outcome_rate', ROUND(new_positive_rate, 2),
    'most_discussed_topics', to_jsonb(merged_topics),
    'last_updated', NOW()
  )
  WHERE user_id = p_user_id;

  -- Create if not exists
  IF NOT FOUND THEN
    INSERT INTO user_coach_preferences (user_id, interaction_summary)
    VALUES (p_user_id, jsonb_build_object(
      'total_sessions', 1,
      'avg_confidence', COALESCE(p_confidence, 0),
      'positive_outcome_rate', CASE WHEN p_outcome_positive THEN 1.0 ELSE 0 END,
      'most_discussed_topics', to_jsonb(COALESCE(p_topics, ARRAY[]::TEXT[])),
      'last_updated', NOW()
    ));
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Generate AI prompt context from preferences
CREATE OR REPLACE FUNCTION get_ai_prompt_context(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
  prefs user_coach_preferences;
BEGIN
  SELECT * INTO prefs FROM user_coach_preferences WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    -- Return default context
    RETURN jsonb_build_object(
      'tone', 'adaptive',
      'response_length', 'balanced',
      'decision_style', 'balanced',
      'user_context', jsonb_build_object(),
      'interaction_history', jsonb_build_object()
    );
  END IF;

  RETURN jsonb_build_object(
    'tone', prefs.tone_preference,
    'response_length', prefs.response_length,
    'decision_style', prefs.decision_style,
    'user_context', jsonb_build_object(
      'relationship_status', prefs.relationship_status,
      'age_group', prefs.age_group,
      'occupation_type', prefs.occupation_type,
      'preferred_categories', prefs.preferred_categories
    ),
    'interaction_history', prefs.interaction_summary
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Anonymous ID Generator for Community
-- =====================================================
CREATE OR REPLACE FUNCTION generate_anonymous_id(p_prefix_type TEXT DEFAULT 'animal')
RETURNS TEXT AS $$
DECLARE
  animals TEXT[] := ARRAY['고양이', '강아지', '토끼', '곰', '여우', '늑대', '호랑이', '사자', '판다', '코알라', '펭귄', '부엉이', '다람쥐', '햄스터', '거북이', '고래', '돌고래', '수달', '물개', '알파카'];
  colors TEXT[] := ARRAY['빨간', '파란', '초록', '노란', '보라', '분홍', '하늘', '연두', '주황', '은빛'];
  random_words TEXT[] := ARRAY['반짝이는', '졸린', '신나는', '배고픈', '용감한', '조용한', '씩씩한', '귀여운', '멋진', '따뜻한'];
  selected_word TEXT;
  random_number INTEGER;
BEGIN
  random_number := floor(random() * 1000)::INTEGER;

  IF p_prefix_type = 'animal' THEN
    selected_word := animals[1 + floor(random() * array_length(animals, 1))::INTEGER];
  ELSIF p_prefix_type = 'color' THEN
    selected_word := colors[1 + floor(random() * array_length(colors, 1))::INTEGER];
  ELSE
    selected_word := random_words[1 + floor(random() * array_length(random_words, 1))::INTEGER];
  END IF;

  RETURN '익명의 ' || selected_word || ' ' || random_number::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Grant Permissions
-- =====================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON user_coach_preferences TO authenticated;
GRANT EXECUTE ON FUNCTION get_or_create_coach_preferences TO authenticated;
GRANT EXECUTE ON FUNCTION update_coach_interaction_summary TO authenticated;
GRANT EXECUTE ON FUNCTION get_ai_prompt_context TO authenticated;
GRANT EXECUTE ON FUNCTION generate_anonymous_id TO authenticated;

-- =====================================================
-- Comments
-- =====================================================
COMMENT ON TABLE user_coach_preferences IS 'ZPZG Decision Coach - AI 코칭 개인화 설정';
COMMENT ON COLUMN user_coach_preferences.tone_preference IS 'AI 톤: friendly(친구), professional(컨설턴트), adaptive(자동)';
COMMENT ON COLUMN user_coach_preferences.response_length IS '응답 길이: concise, balanced, detailed';
COMMENT ON COLUMN user_coach_preferences.decision_style IS '결정 스타일: logic(논리), empathy(공감), balanced';
COMMENT ON COLUMN user_coach_preferences.interaction_summary IS 'AI 학습용 상호작용 요약 데이터';
COMMENT ON FUNCTION generate_anonymous_id IS '커뮤니티 익명 ID 생성 (예: 익명의 고양이 42)';
