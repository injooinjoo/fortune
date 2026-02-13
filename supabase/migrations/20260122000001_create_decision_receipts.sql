-- =====================================================
-- Decision Receipts Table
-- ZPZG Decision Coach Pivot - Phase 1.1
-- 결정 기록 및 팔로업 시스템
-- =====================================================

-- Enable UUID extension if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Main Table: decision_receipts
-- 사용자의 결정 기록 저장
-- =====================================================
CREATE TABLE IF NOT EXISTS decision_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 결정 유형
  decision_type TEXT NOT NULL CHECK (decision_type IN ('dating', 'career', 'money', 'wellness', 'lifestyle', 'relationship')),

  -- 질문 및 선택
  question TEXT NOT NULL,
  chosen_option TEXT NOT NULL,
  reasoning TEXT,  -- 선택 이유 (사용자 입력)

  -- AI 분석 결과
  options_analyzed JSONB,  -- { "optionA": {...}, "optionB": {...} }
  ai_recommendation TEXT,
  ai_analysis_summary TEXT,

  -- 확신도 및 감정
  confidence_level INTEGER CHECK (confidence_level >= 1 AND confidence_level <= 5),  -- 1-5
  emotional_state TEXT,  -- 'anxious', 'confident', 'confused', 'hopeful', 'neutral'

  -- 결과 추적
  outcome_status TEXT DEFAULT 'pending' CHECK (outcome_status IN ('pending', 'positive', 'negative', 'neutral', 'mixed')),
  outcome_notes TEXT,
  outcome_rating INTEGER CHECK (outcome_rating >= 1 AND outcome_rating <= 5),  -- 결과 만족도
  outcome_recorded_at TIMESTAMPTZ,

  -- 팔로업
  follow_up_date TIMESTAMPTZ,
  follow_up_sent BOOLEAN DEFAULT FALSE,
  follow_up_count INTEGER DEFAULT 0,

  -- 관련 채팅 메시지 연결
  chat_message_id TEXT,  -- 채팅 메시지 ID 참조

  -- 메타데이터
  metadata JSONB DEFAULT '{}',
  tags TEXT[],

  -- 타임스탬프
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Indexes for Performance
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_decision_receipts_user_id
  ON decision_receipts(user_id);

CREATE INDEX IF NOT EXISTS idx_decision_receipts_decision_type
  ON decision_receipts(decision_type);

CREATE INDEX IF NOT EXISTS idx_decision_receipts_created_at
  ON decision_receipts(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_decision_receipts_outcome_status
  ON decision_receipts(outcome_status);

CREATE INDEX IF NOT EXISTS idx_decision_receipts_follow_up_date
  ON decision_receipts(follow_up_date)
  WHERE follow_up_date IS NOT NULL AND follow_up_sent = FALSE;

CREATE INDEX IF NOT EXISTS idx_decision_receipts_user_type_created
  ON decision_receipts(user_id, decision_type, created_at DESC);

-- GIN index for JSONB search
CREATE INDEX IF NOT EXISTS idx_decision_receipts_metadata
  ON decision_receipts USING GIN (metadata);

CREATE INDEX IF NOT EXISTS idx_decision_receipts_tags
  ON decision_receipts USING GIN (tags);

-- =====================================================
-- Updated_at Trigger
-- =====================================================
CREATE OR REPLACE FUNCTION update_decision_receipts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_decision_receipts_updated_at ON decision_receipts;
CREATE TRIGGER trigger_decision_receipts_updated_at
  BEFORE UPDATE ON decision_receipts
  FOR EACH ROW
  EXECUTE FUNCTION update_decision_receipts_updated_at();

-- =====================================================
-- RLS Policies
-- =====================================================
ALTER TABLE decision_receipts ENABLE ROW LEVEL SECURITY;

-- Users can only see their own receipts
CREATE POLICY "Users can view own decision receipts"
  ON decision_receipts
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own receipts
CREATE POLICY "Users can insert own decision receipts"
  ON decision_receipts
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own receipts
CREATE POLICY "Users can update own decision receipts"
  ON decision_receipts
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own receipts
CREATE POLICY "Users can delete own decision receipts"
  ON decision_receipts
  FOR DELETE
  USING (auth.uid() = user_id);

-- Service role can do anything (for Edge Functions)
CREATE POLICY "Service role full access on decision receipts"
  ON decision_receipts
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- =====================================================
-- Helper Functions
-- =====================================================

-- Get pending follow-ups for a specific date
CREATE OR REPLACE FUNCTION get_pending_follow_ups(target_date DATE DEFAULT CURRENT_DATE)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  decision_type TEXT,
  question TEXT,
  chosen_option TEXT,
  follow_up_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    dr.id,
    dr.user_id,
    dr.decision_type,
    dr.question,
    dr.chosen_option,
    dr.follow_up_date,
    dr.created_at
  FROM decision_receipts dr
  WHERE dr.follow_up_date::DATE <= target_date
    AND dr.follow_up_sent = FALSE
    AND dr.outcome_status = 'pending'
  ORDER BY dr.follow_up_date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get user decision statistics
CREATE OR REPLACE FUNCTION get_user_decision_stats(p_user_id UUID)
RETURNS TABLE (
  total_decisions BIGINT,
  positive_outcomes BIGINT,
  negative_outcomes BIGINT,
  pending_outcomes BIGINT,
  avg_confidence NUMERIC,
  avg_outcome_rating NUMERIC,
  most_common_type TEXT,
  decisions_by_type JSONB
) AS $$
BEGIN
  RETURN QUERY
  WITH stats AS (
    SELECT
      COUNT(*) as total,
      COUNT(*) FILTER (WHERE outcome_status = 'positive') as positive,
      COUNT(*) FILTER (WHERE outcome_status = 'negative') as negative,
      COUNT(*) FILTER (WHERE outcome_status = 'pending') as pending,
      AVG(confidence_level)::NUMERIC as avg_conf,
      AVG(outcome_rating)::NUMERIC as avg_rating
    FROM decision_receipts
    WHERE user_id = p_user_id
  ),
  type_stats AS (
    SELECT
      decision_type,
      COUNT(*) as count
    FROM decision_receipts
    WHERE user_id = p_user_id
    GROUP BY decision_type
    ORDER BY count DESC
  ),
  type_json AS (
    SELECT jsonb_object_agg(decision_type, count) as by_type
    FROM type_stats
  )
  SELECT
    s.total,
    s.positive,
    s.negative,
    s.pending,
    ROUND(s.avg_conf, 2),
    ROUND(s.avg_rating, 2),
    (SELECT decision_type FROM type_stats LIMIT 1),
    COALESCE(t.by_type, '{}'::jsonb)
  FROM stats s
  CROSS JOIN type_json t;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get recent decisions with outcome patterns
CREATE OR REPLACE FUNCTION get_decision_patterns(p_user_id UUID, p_limit INTEGER DEFAULT 20)
RETURNS TABLE (
  id UUID,
  decision_type TEXT,
  question TEXT,
  chosen_option TEXT,
  confidence_level INTEGER,
  outcome_status TEXT,
  outcome_rating INTEGER,
  days_to_outcome INTEGER,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    dr.id,
    dr.decision_type,
    dr.question,
    dr.chosen_option,
    dr.confidence_level,
    dr.outcome_status,
    dr.outcome_rating,
    EXTRACT(DAY FROM (dr.outcome_recorded_at - dr.created_at))::INTEGER as days_to_outcome,
    dr.created_at
  FROM decision_receipts dr
  WHERE dr.user_id = p_user_id
  ORDER BY dr.created_at DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Grant Permissions
-- =====================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON decision_receipts TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_follow_ups TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_decision_stats TO authenticated;
GRANT EXECUTE ON FUNCTION get_decision_patterns TO authenticated;

-- =====================================================
-- Comments
-- =====================================================
COMMENT ON TABLE decision_receipts IS 'ZPZG Decision Coach - 사용자 결정 기록 및 팔로업 추적';
COMMENT ON COLUMN decision_receipts.decision_type IS '결정 카테고리: dating, career, money, wellness, lifestyle, relationship';
COMMENT ON COLUMN decision_receipts.confidence_level IS '결정 확신도 1-5 (1=매우 불확실, 5=매우 확신)';
COMMENT ON COLUMN decision_receipts.outcome_status IS '결과 상태: pending, positive, negative, neutral, mixed';
COMMENT ON COLUMN decision_receipts.follow_up_date IS '팔로업 알림 예정일';
