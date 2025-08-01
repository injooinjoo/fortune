-- Additional performance indexes for personality fortune tables

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_personality_cache_user_type_date 
ON personality_fortune_cache(user_id, fortune_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_personality_cache_personality_data_gin 
ON personality_fortune_cache USING GIN (personality_data);

-- Partial indexes for active caches only
CREATE INDEX IF NOT EXISTS idx_personality_cache_active 
ON personality_fortune_cache(cache_key, user_id) 
WHERE expires_at > NOW();

-- Index for personality profile lookups
CREATE INDEX IF NOT EXISTS idx_personality_profiles_traits_gin
ON user_personality_profiles USING GIN (personality_traits);

CREATE INDEX IF NOT EXISTS idx_personality_profiles_dominant_traits
ON user_personality_profiles USING GIN (dominant_traits);

-- Composite index for compatibility lookups
CREATE INDEX IF NOT EXISTS idx_compatibility_combined
ON personality_compatibility_matrix(
  type1_category, 
  type1_value, 
  type2_category, 
  type2_value, 
  relationship_type,
  compatibility_score DESC
);

-- Create materialized view for frequently accessed compatibility data
CREATE MATERIALIZED VIEW IF NOT EXISTS personality_compatibility_summary AS
SELECT 
  type1_category,
  type1_value,
  type2_category,
  type2_value,
  AVG(compatibility_score) as avg_score,
  COUNT(*) as relationship_count,
  array_agg(DISTINCT relationship_type) as relationship_types
FROM personality_compatibility_matrix
GROUP BY type1_category, type1_value, type2_category, type2_value;

CREATE UNIQUE INDEX idx_compatibility_summary_unique 
ON personality_compatibility_summary(type1_category, type1_value, type2_category, type2_value);

-- Create function for efficient MBTI matching
CREATE OR REPLACE FUNCTION get_mbti_matches(
  p_mbti_type TEXT,
  p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
  mbti_type TEXT,
  compatibility_score DECIMAL(3,2),
  relationship_advice TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    CASE 
      WHEN pcm.type1_value = p_mbti_type THEN pcm.type2_value
      ELSE pcm.type1_value
    END as mbti_type,
    pcm.compatibility_score,
    pcm.advice as relationship_advice
  FROM personality_compatibility_matrix pcm
  WHERE pcm.type1_category = 'mbti' 
    AND pcm.type2_category = 'mbti'
    AND pcm.relationship_type = 'romantic'
    AND (pcm.type1_value = p_mbti_type OR pcm.type2_value = p_mbti_type)
  ORDER BY pcm.compatibility_score DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- Create function for batch personality data preload
CREATE OR REPLACE FUNCTION preload_personality_data(
  p_user_id UUID
)
RETURNS TABLE (
  data_type TEXT,
  data JSONB
) AS $$
BEGIN
  -- Get user profile
  RETURN QUERY
  SELECT 
    'profile'::TEXT as data_type,
    row_to_json(upp.*)::JSONB as data
  FROM user_personality_profiles upp
  WHERE upp.user_id = p_user_id;
  
  -- Get recent fortunes
  RETURN QUERY
  SELECT 
    'recent_fortunes'::TEXT as data_type,
    jsonb_agg(
      jsonb_build_object(
        'cache_key', pfc.cache_key,
        'personality_data', pfc.personality_data,
        'created_at', pfc.created_at
      )
    ) as data
  FROM (
    SELECT * FROM personality_fortune_cache
    WHERE user_id = p_user_id
      AND expires_at > NOW()
    ORDER BY created_at DESC
    LIMIT 10
  ) pfc;
  
  -- Get compatibility data if user has MBTI
  RETURN QUERY
  SELECT 
    'compatibility'::TEXT as data_type,
    jsonb_agg(
      jsonb_build_object(
        'type', gm.mbti_type,
        'score', gm.compatibility_score,
        'advice', gm.relationship_advice
      )
    ) as data
  FROM user_personality_profiles upp
  CROSS JOIN LATERAL get_mbti_matches(upp.mbti_type, 10) gm
  WHERE upp.user_id = p_user_id
    AND upp.mbti_type IS NOT NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- Create scheduled job to refresh materialized view (run daily)
CREATE OR REPLACE FUNCTION refresh_compatibility_summary()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY personality_compatibility_summary;
END;
$$ LANGUAGE plpgsql;

-- Grant necessary permissions
GRANT SELECT ON personality_compatibility_summary TO authenticated;
GRANT EXECUTE ON FUNCTION get_mbti_matches TO authenticated;
GRANT EXECUTE ON FUNCTION preload_personality_data TO authenticated;