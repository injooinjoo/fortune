-- ============================================
-- Content Tagging System - Interaction Logging
-- Purpose: User behavior tracking for ML/recommendations
-- Frontend: Not exposed (internal analytics only)
-- ============================================

-- ============================================
-- 1. user_content_interactions: Detailed behavior logging
-- ============================================
CREATE TABLE IF NOT EXISTS user_content_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Who
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- What
  content_id UUID REFERENCES content_items(id) ON DELETE SET NULL,
  content_type TEXT NOT NULL,
  content_key TEXT NOT NULL,

  -- Action
  interaction_type TEXT NOT NULL CHECK (interaction_type IN (
    'view',           -- Viewed content (entered page)
    'complete',       -- Completed (full result shown)
    'share',          -- Shared result
    'save',           -- Saved/bookmarked
    'rate',           -- Rated content (1-5 stars)
    'feedback',       -- Gave text feedback
    'purchase',       -- Purchased/used tokens
    'chip_click',     -- Clicked recommendation chip
    'search',         -- Searched for this content
    'skip',           -- Skipped/dismissed
    'unblur'          -- Paid to unblur premium content
  )),

  -- Context
  source TEXT,                 -- 'home', 'chat', 'explore', 'recommendation', 'search'
  referrer_content_id UUID,    -- What led to this interaction
  session_id TEXT,             -- Session tracking for funnel analysis

  -- Interaction details
  duration_seconds INTEGER,    -- Time spent on content
  scroll_depth NUMERIC(3,2),   -- 0.00 to 1.00 (percentage scrolled)
  rating INTEGER CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5)),

  -- Device context
  platform TEXT,               -- 'ios', 'android', 'web'
  app_version TEXT,

  -- Additional metadata
  metadata JSONB DEFAULT '{}',

  -- Timestamp
  created_at TIMESTAMPTZ DEFAULT now(),
  interaction_date DATE DEFAULT CURRENT_DATE
);

-- Indexes for analytics queries
CREATE INDEX IF NOT EXISTS idx_interactions_user ON user_content_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_interactions_content ON user_content_interactions(content_id);
CREATE INDEX IF NOT EXISTS idx_interactions_type ON user_content_interactions(interaction_type);
CREATE INDEX IF NOT EXISTS idx_interactions_date ON user_content_interactions(interaction_date);
CREATE INDEX IF NOT EXISTS idx_interactions_user_date ON user_content_interactions(user_id, interaction_date);
CREATE INDEX IF NOT EXISTS idx_interactions_source ON user_content_interactions(source);
CREATE INDEX IF NOT EXISTS idx_interactions_content_type_key ON user_content_interactions(content_type, content_key);


-- ============================================
-- 2. user_tag_affinity: Calculated user preferences
-- ============================================
CREATE TABLE IF NOT EXISTS user_tag_affinity (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,

  -- Affinity scores
  affinity_score NUMERIC(5,4) DEFAULT 0.5,   -- 0.0000 to 1.0000
  interaction_count INTEGER DEFAULT 0,

  -- Decay tracking (for time-weighted preferences)
  last_interaction_at TIMESTAMPTZ,
  decay_factor NUMERIC(3,2) DEFAULT 1.0,

  -- Computed metrics
  completion_rate NUMERIC(3,2),              -- 0.00 to 1.00
  avg_rating NUMERIC(2,1),                   -- 1.0 to 5.0
  share_count INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(user_id, tag_id)
);

-- Indexes for recommendation queries
CREATE INDEX IF NOT EXISTS idx_user_affinity_user ON user_tag_affinity(user_id);
CREATE INDEX IF NOT EXISTS idx_user_affinity_score ON user_tag_affinity(user_id, affinity_score DESC);
CREATE INDEX IF NOT EXISTS idx_user_affinity_tag ON user_tag_affinity(tag_id);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_user_tag_affinity_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_tag_affinity_updated_at
  BEFORE UPDATE ON user_tag_affinity
  FOR EACH ROW
  EXECUTE FUNCTION update_user_tag_affinity_updated_at();


-- ============================================
-- 3. recommendation_logs: Track recommendation effectiveness
-- ============================================
CREATE TABLE IF NOT EXISTS recommendation_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- What was recommended
  recommended_content_ids UUID[],
  recommended_tags UUID[],

  -- Algorithm metadata
  algorithm_version TEXT,
  model_weights JSONB,
  ranking_scores JSONB,                -- Score for each recommendation

  -- Result tracking
  clicked_content_id UUID,
  position_clicked INTEGER,            -- Which position was clicked (1-based)

  -- Context
  source TEXT,                         -- 'chat_chips', 'home', 'explore', 'related'
  session_id TEXT,

  -- Performance metrics
  impressions INTEGER DEFAULT 1,
  clicks INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for analytics
CREATE INDEX IF NOT EXISTS idx_recommendation_user ON recommendation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_recommendation_date ON recommendation_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_recommendation_source ON recommendation_logs(source);
CREATE INDEX IF NOT EXISTS idx_recommendation_clicked ON recommendation_logs(clicked_content_id) WHERE clicked_content_id IS NOT NULL;


-- ============================================
-- 4. Trigger: Auto-update user_tag_affinity on interaction
-- ============================================
CREATE OR REPLACE FUNCTION update_user_tag_affinity_on_interaction()
RETURNS TRIGGER AS $$
DECLARE
  affinity_delta NUMERIC(5,4);
BEGIN
  -- Calculate affinity delta based on interaction type
  affinity_delta := CASE
    WHEN NEW.interaction_type = 'complete' THEN 0.08
    WHEN NEW.interaction_type = 'rate' AND NEW.rating >= 4 THEN 0.10
    WHEN NEW.interaction_type = 'rate' AND NEW.rating >= 3 THEN 0.05
    WHEN NEW.interaction_type = 'rate' AND NEW.rating < 3 THEN -0.05
    WHEN NEW.interaction_type = 'share' THEN 0.12
    WHEN NEW.interaction_type = 'save' THEN 0.10
    WHEN NEW.interaction_type = 'purchase' THEN 0.15
    WHEN NEW.interaction_type = 'unblur' THEN 0.12
    WHEN NEW.interaction_type = 'view' THEN 0.02
    WHEN NEW.interaction_type = 'chip_click' THEN 0.05
    WHEN NEW.interaction_type = 'skip' THEN -0.03
    ELSE 0.01
  END;

  -- Update affinity for all tags of the content
  INSERT INTO user_tag_affinity (
    user_id,
    tag_id,
    interaction_count,
    last_interaction_at,
    affinity_score,
    share_count,
    avg_rating
  )
  SELECT
    NEW.user_id,
    ct.tag_id,
    1,
    NOW(),
    GREATEST(0, LEAST(1, 0.5 + affinity_delta)),
    CASE WHEN NEW.interaction_type = 'share' THEN 1 ELSE 0 END,
    NEW.rating
  FROM content_tags ct
  WHERE ct.content_id = NEW.content_id
  ON CONFLICT (user_id, tag_id) DO UPDATE SET
    interaction_count = user_tag_affinity.interaction_count + 1,
    last_interaction_at = NOW(),
    affinity_score = GREATEST(0, LEAST(1,
      user_tag_affinity.affinity_score + affinity_delta
    )),
    share_count = user_tag_affinity.share_count +
      CASE WHEN NEW.interaction_type = 'share' THEN 1 ELSE 0 END,
    avg_rating = CASE
      WHEN NEW.rating IS NOT NULL THEN
        COALESCE(
          (user_tag_affinity.avg_rating * user_tag_affinity.interaction_count + NEW.rating) /
          (user_tag_affinity.interaction_count + 1),
          NEW.rating
        )
      ELSE user_tag_affinity.avg_rating
    END,
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_affinity_on_interaction
  AFTER INSERT ON user_content_interactions
  FOR EACH ROW
  WHEN (NEW.content_id IS NOT NULL)
  EXECUTE FUNCTION update_user_tag_affinity_on_interaction();


-- ============================================
-- 5. Helper Functions for Recommendations
-- ============================================

-- Get personalized content recommendations for a user
CREATE OR REPLACE FUNCTION get_personalized_recommendations(
  p_user_id UUID,
  p_content_type TEXT DEFAULT 'fortune',
  p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
  content_id UUID,
  content_key TEXT,
  display_name TEXT,
  recommendation_score NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  WITH user_preferences AS (
    SELECT tag_id, affinity_score
    FROM user_tag_affinity
    WHERE user_id = p_user_id
    ORDER BY affinity_score DESC
    LIMIT 30
  ),
  content_scores AS (
    SELECT
      ci.id,
      ci.content_key,
      ci.display_name,
      COALESCE(
        SUM(ct.relevance_score * COALESCE(up.affinity_score, 0.3)),
        0
      ) as score
    FROM content_items ci
    JOIN content_tags ct ON ci.id = ct.content_id
    LEFT JOIN user_preferences up ON ct.tag_id = up.tag_id
    WHERE ci.is_active = true
      AND ci.content_type = p_content_type
    GROUP BY ci.id, ci.content_key, ci.display_name
  )
  SELECT
    cs.id,
    cs.content_key,
    cs.display_name,
    cs.score
  FROM content_scores cs
  ORDER BY cs.score DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- Get similar content based on shared tags
CREATE OR REPLACE FUNCTION get_similar_content(
  p_content_id UUID,
  p_limit INTEGER DEFAULT 5
)
RETURNS TABLE(
  content_id UUID,
  content_key TEXT,
  display_name TEXT,
  shared_tags INTEGER,
  similarity_score NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  WITH source_tags AS (
    SELECT tag_id FROM content_tags WHERE content_id = p_content_id
  ),
  similar_content AS (
    SELECT
      ci.id,
      ci.content_key,
      ci.display_name,
      COUNT(DISTINCT ct.tag_id)::INTEGER as shared_tag_count,
      SUM(ct.relevance_score) as total_relevance
    FROM content_items ci
    JOIN content_tags ct ON ci.id = ct.content_id
    WHERE ct.tag_id IN (SELECT tag_id FROM source_tags)
      AND ci.id != p_content_id
      AND ci.is_active = true
    GROUP BY ci.id, ci.content_key, ci.display_name
  )
  SELECT
    sc.id,
    sc.content_key,
    sc.display_name,
    sc.shared_tag_count,
    sc.total_relevance
  FROM similar_content sc
  ORDER BY sc.shared_tag_count DESC, sc.total_relevance DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- Get trending content based on recent interactions
CREATE OR REPLACE FUNCTION get_trending_content(
  p_content_type TEXT DEFAULT 'fortune',
  p_days INTEGER DEFAULT 7,
  p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
  content_id UUID,
  content_key TEXT,
  display_name TEXT,
  interaction_count BIGINT,
  completion_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ci.id,
    ci.content_key,
    ci.display_name,
    COUNT(uci.id) as total_interactions,
    ROUND(
      COUNT(CASE WHEN uci.interaction_type = 'complete' THEN 1 END)::NUMERIC /
      NULLIF(COUNT(CASE WHEN uci.interaction_type = 'view' THEN 1 END), 0),
      2
    ) as comp_rate
  FROM content_items ci
  JOIN user_content_interactions uci ON ci.id = uci.content_id
  WHERE ci.content_type = p_content_type
    AND ci.is_active = true
    AND uci.created_at >= NOW() - (p_days || ' days')::INTERVAL
  GROUP BY ci.id, ci.content_key, ci.display_name
  ORDER BY total_interactions DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;


-- ============================================
-- 6. RLS Policies
-- ============================================

-- Enable RLS
ALTER TABLE user_content_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tag_affinity ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendation_logs ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
CREATE POLICY "Users read own interactions" ON user_content_interactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users insert own interactions" ON user_content_interactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users read own affinity" ON user_tag_affinity
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users read own recommendations" ON recommendation_logs
  FOR SELECT USING (auth.uid() = user_id);

-- Service role can do everything (for Edge Functions and analytics)
CREATE POLICY "Service role full access interactions" ON user_content_interactions
  FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Service role full access affinity" ON user_tag_affinity
  FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Service role full access recommendations" ON recommendation_logs
  FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');


-- ============================================
-- Comments for documentation
-- ============================================
COMMENT ON TABLE user_content_interactions IS 'Detailed user behavior logging for ML/recommendations. Backend-only.';
COMMENT ON TABLE user_tag_affinity IS 'Auto-calculated user preferences based on interactions.';
COMMENT ON TABLE recommendation_logs IS 'Track recommendation effectiveness for algorithm improvement.';

COMMENT ON COLUMN user_content_interactions.interaction_type IS 'Action type: view, complete, share, save, rate, feedback, purchase, chip_click, search, skip, unblur';
COMMENT ON COLUMN user_content_interactions.source IS 'Where interaction originated: home, chat, explore, recommendation, search';
COMMENT ON COLUMN user_tag_affinity.affinity_score IS 'User preference for this tag: 0.0 (low) to 1.0 (high)';
COMMENT ON COLUMN user_tag_affinity.decay_factor IS 'Time decay multiplier for stale preferences';
