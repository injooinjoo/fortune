-- ============================================
-- Content Tagging System - Historical Data Backfill
-- Converts fortune_history to user_content_interactions
-- ============================================

-- ============================================
-- 1. Backfill user_content_interactions from fortune_history
-- ============================================

-- Insert historical interactions as 'complete' type (since they have results)
INSERT INTO user_content_interactions (
  user_id,
  content_id,
  content_type,
  content_key,
  interaction_type,
  source,
  metadata,
  created_at,
  interaction_date
)
SELECT
  fh.user_id,
  ci.id as content_id,
  'fortune' as content_type,
  fh.fortune_type as content_key,
  'complete' as interaction_type,
  'history_migration' as source,
  jsonb_build_object(
    'migrated_from', 'fortune_history',
    'original_id', fh.id,
    'had_result', fh.fortune_data IS NOT NULL
  ) as metadata,
  fh.created_at,
  fh.created_at::date as interaction_date
FROM fortune_history fh
LEFT JOIN content_items ci ON ci.content_key = fh.fortune_type AND ci.content_type = 'fortune'
WHERE fh.user_id IS NOT NULL
ON CONFLICT DO NOTHING;


-- ============================================
-- 2. Backfill from fortune_feedback (ratings)
-- ============================================

-- Check if fortune_feedback table exists and has data
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'fortune_feedback') THEN
    INSERT INTO user_content_interactions (
      user_id,
      content_id,
      content_type,
      content_key,
      interaction_type,
      source,
      rating,
      metadata,
      created_at,
      interaction_date
    )
    SELECT
      ff.user_id,
      ci.id as content_id,
      'fortune' as content_type,
      ff.fortune_type as content_key,
      'rate' as interaction_type,
      'feedback_migration' as source,
      ff.rating,
      jsonb_build_object(
        'migrated_from', 'fortune_feedback',
        'original_id', ff.id,
        'feedback_text', ff.feedback
      ) as metadata,
      ff.created_at,
      ff.created_at::date as interaction_date
    FROM fortune_feedback ff
    LEFT JOIN content_items ci ON ci.content_key = ff.fortune_type AND ci.content_type = 'fortune'
    WHERE ff.user_id IS NOT NULL
      AND ff.rating IS NOT NULL
    ON CONFLICT DO NOTHING;
  END IF;
END $$;


-- ============================================
-- 3. Calculate initial user_tag_affinity from backfilled data
-- ============================================

-- Aggregate interactions to calculate affinity scores
INSERT INTO user_tag_affinity (
  user_id,
  tag_id,
  affinity_score,
  interaction_count,
  last_interaction_at,
  completion_rate,
  avg_rating
)
SELECT
  uci.user_id,
  ct.tag_id,
  -- Calculate affinity score based on interaction patterns
  LEAST(1.0, 0.3 + (COUNT(*)::NUMERIC / 20.0)) as affinity_score,
  COUNT(*) as interaction_count,
  MAX(uci.created_at) as last_interaction_at,
  -- Completion rate (all historical are 'complete')
  1.0 as completion_rate,
  -- Average rating if available
  AVG(uci.rating) FILTER (WHERE uci.rating IS NOT NULL) as avg_rating
FROM user_content_interactions uci
JOIN content_tags ct ON ct.content_id = uci.content_id
WHERE uci.source IN ('history_migration', 'feedback_migration')
GROUP BY uci.user_id, ct.tag_id
ON CONFLICT (user_id, tag_id) DO UPDATE SET
  affinity_score = LEAST(1.0, user_tag_affinity.affinity_score + 0.1),
  interaction_count = user_tag_affinity.interaction_count + EXCLUDED.interaction_count,
  last_interaction_at = GREATEST(user_tag_affinity.last_interaction_at, EXCLUDED.last_interaction_at),
  updated_at = NOW();


-- ============================================
-- 4. Create views for analytics (optional)
-- ============================================

-- View: Content popularity by tag
CREATE OR REPLACE VIEW v_content_popularity_by_tag AS
SELECT
  t.slug as tag_slug,
  t.name_ko as tag_name,
  t.tag_type,
  COUNT(DISTINCT uci.user_id) as unique_users,
  COUNT(uci.id) as total_interactions,
  AVG(uci.rating) FILTER (WHERE uci.rating IS NOT NULL) as avg_rating
FROM tags t
JOIN content_tags ct ON t.id = ct.tag_id
JOIN content_items ci ON ct.content_id = ci.id
LEFT JOIN user_content_interactions uci ON ci.id = uci.content_id
WHERE t.is_active = true
GROUP BY t.id, t.slug, t.name_ko, t.tag_type
ORDER BY total_interactions DESC;

-- View: User preference summary
CREATE OR REPLACE VIEW v_user_preferences AS
SELECT
  uta.user_id,
  array_agg(t.name_ko ORDER BY uta.affinity_score DESC) FILTER (WHERE t.tag_type = 'category') as top_categories,
  array_agg(t.name_ko ORDER BY uta.affinity_score DESC) FILTER (WHERE t.tag_type = 'theme') as top_themes,
  array_agg(t.name_ko ORDER BY uta.affinity_score DESC) FILTER (WHERE t.tag_type = 'mood') as preferred_moods,
  COUNT(DISTINCT uta.tag_id) as tag_diversity,
  AVG(uta.affinity_score) as avg_affinity
FROM user_tag_affinity uta
JOIN tags t ON uta.tag_id = t.id
GROUP BY uta.user_id;


-- ============================================
-- 5. Create function to get user recommendations
-- ============================================

CREATE OR REPLACE FUNCTION recommend_content_for_user(
  p_user_id UUID,
  p_limit INTEGER DEFAULT 5,
  p_exclude_content_ids UUID[] DEFAULT '{}'
)
RETURNS TABLE(
  content_id UUID,
  content_key TEXT,
  display_name TEXT,
  score NUMERIC,
  matching_tags TEXT[]
) AS $$
BEGIN
  RETURN QUERY
  WITH user_top_tags AS (
    -- Get user's top 15 tags by affinity
    SELECT tag_id, affinity_score
    FROM user_tag_affinity
    WHERE user_id = p_user_id
    ORDER BY affinity_score DESC
    LIMIT 15
  ),
  scored_content AS (
    -- Score each content based on matching tags
    SELECT
      ci.id,
      ci.content_key,
      ci.display_name,
      SUM(ct.relevance_score * COALESCE(utt.affinity_score, 0.2)) as total_score,
      array_agg(DISTINCT t.name_ko) FILTER (WHERE utt.tag_id IS NOT NULL) as matched_tags
    FROM content_items ci
    JOIN content_tags ct ON ci.id = ct.content_id
    JOIN tags t ON ct.tag_id = t.id
    LEFT JOIN user_top_tags utt ON ct.tag_id = utt.tag_id
    WHERE ci.is_active = true
      AND ci.content_type = 'fortune'
      AND ci.id != ALL(p_exclude_content_ids)
    GROUP BY ci.id, ci.content_key, ci.display_name
    HAVING SUM(ct.relevance_score * COALESCE(utt.affinity_score, 0.2)) > 0
  )
  SELECT
    sc.id,
    sc.content_key,
    sc.display_name,
    ROUND(sc.total_score, 3),
    sc.matched_tags
  FROM scored_content sc
  ORDER BY sc.total_score DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;


-- ============================================
-- 6. Summary statistics
-- ============================================

-- Create a summary view for monitoring
CREATE OR REPLACE VIEW v_tagging_system_stats AS
SELECT
  (SELECT COUNT(*) FROM content_items WHERE is_active = true) as active_content_count,
  (SELECT COUNT(*) FROM tags WHERE is_active = true) as active_tag_count,
  (SELECT COUNT(*) FROM content_tags) as content_tag_mappings,
  (SELECT COUNT(*) FROM user_content_interactions) as total_interactions,
  (SELECT COUNT(DISTINCT user_id) FROM user_content_interactions) as unique_users,
  (SELECT COUNT(*) FROM user_tag_affinity) as affinity_records,
  (SELECT COUNT(*) FROM user_content_interactions WHERE source = 'history_migration') as migrated_interactions;


-- ============================================
-- Comments
-- ============================================
COMMENT ON VIEW v_content_popularity_by_tag IS 'Analytics view showing content popularity grouped by tag';
COMMENT ON VIEW v_user_preferences IS 'Aggregated user preferences based on tag affinity';
COMMENT ON VIEW v_tagging_system_stats IS 'Summary statistics for tagging system monitoring';
COMMENT ON FUNCTION recommend_content_for_user IS 'Get personalized content recommendations for a user based on tag affinity';
