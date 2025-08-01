-- Create personality fortune cache table
CREATE TABLE IF NOT EXISTS personality_fortune_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  cache_key TEXT UNIQUE NOT NULL,
  fortune_type TEXT NOT NULL DEFAULT 'personality',
  personality_data JSONB NOT NULL, -- stores MBTI, blood type, traits
  fortune_data JSONB NOT NULL,
  compatibility_scores JSONB, -- stores compatibility with different types
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX idx_personality_fortune_cache_user ON personality_fortune_cache(user_id);
CREATE INDEX idx_personality_fortune_cache_key ON personality_fortune_cache(cache_key);
CREATE INDEX idx_personality_fortune_cache_expires ON personality_fortune_cache(expires_at);
CREATE INDEX idx_personality_fortune_cache_mbti ON personality_fortune_cache((personality_data->>'mbti'));
CREATE INDEX idx_personality_fortune_cache_blood ON personality_fortune_cache((personality_data->>'bloodType'));

-- Create user personality profiles table
CREATE TABLE IF NOT EXISTS user_personality_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  mbti_type TEXT CHECK (mbti_type ~ '^[EI][SN][TF][JP]$'),
  blood_type TEXT CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
  personality_traits JSONB DEFAULT '{}'::jsonb, -- stores custom traits
  dominant_traits TEXT[], -- array of dominant personality traits
  personality_description TEXT,
  last_analysis_date DATE,
  analysis_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for user personality profiles
CREATE INDEX idx_user_personality_profiles_user ON user_personality_profiles(user_id);
CREATE INDEX idx_user_personality_profiles_mbti ON user_personality_profiles(mbti_type);
CREATE INDEX idx_user_personality_profiles_blood ON user_personality_profiles(blood_type);

-- Create personality compatibility matrix table
CREATE TABLE IF NOT EXISTS personality_compatibility_matrix (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type1_category TEXT NOT NULL, -- 'mbti' or 'blood'
  type1_value TEXT NOT NULL,
  type2_category TEXT NOT NULL,
  type2_value TEXT NOT NULL,
  compatibility_score DECIMAL(3,2) CHECK (compatibility_score >= 0 AND compatibility_score <= 1),
  relationship_type TEXT CHECK (relationship_type IN ('romantic', 'friendship', 'business', 'general')),
  description TEXT,
  advice TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(type1_category, type1_value, type2_category, type2_value, relationship_type)
);

-- Create indexes for compatibility matrix
CREATE INDEX idx_compatibility_matrix_type1 ON personality_compatibility_matrix(type1_category, type1_value);
CREATE INDEX idx_compatibility_matrix_type2 ON personality_compatibility_matrix(type2_category, type2_value);
CREATE INDEX idx_compatibility_matrix_relationship ON personality_compatibility_matrix(relationship_type);

-- Create personality traits reference table
CREATE TABLE IF NOT EXISTS personality_traits_reference (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trait_code TEXT UNIQUE NOT NULL,
  trait_name TEXT NOT NULL,
  trait_category TEXT NOT NULL, -- 'big5', 'mbti_dimension', 'custom'
  description TEXT,
  positive_aspects TEXT[],
  negative_aspects TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert common personality traits
INSERT INTO personality_traits_reference (trait_code, trait_name, trait_category, description, positive_aspects, negative_aspects) VALUES
  ('openness', 'Openness', 'big5', 'Openness to experience', ARRAY['Creative', 'Curious', 'Open-minded'], ARRAY['Unpredictable', 'Unfocused']),
  ('conscientiousness', 'Conscientiousness', 'big5', 'Self-discipline and achievement', ARRAY['Organized', 'Reliable', 'Hardworking'], ARRAY['Rigid', 'Perfectionist']),
  ('extraversion', 'Extraversion', 'big5', 'Sociability and assertiveness', ARRAY['Energetic', 'Sociable', 'Confident'], ARRAY['Attention-seeking', 'Overwhelming']),
  ('agreeableness', 'Agreeableness', 'big5', 'Cooperation and trust', ARRAY['Kind', 'Cooperative', 'Trusting'], ARRAY['Naive', 'Conflict-avoidant']),
  ('neuroticism', 'Neuroticism', 'big5', 'Emotional stability', ARRAY['Sensitive', 'Emotionally aware'], ARRAY['Anxious', 'Moody'])
ON CONFLICT (trait_code) DO NOTHING;

-- Insert MBTI compatibility data
INSERT INTO personality_compatibility_matrix (type1_category, type1_value, type2_category, type2_value, compatibility_score, relationship_type, description, advice) VALUES
  -- MBTI Romantic Compatibility (sample data)
  ('mbti', 'INTJ', 'mbti', 'ENFP', 0.90, 'romantic', 'Excellent balance of logic and emotion', 'Appreciate each other''s differences and communicate openly'),
  ('mbti', 'INTJ', 'mbti', 'ENTP', 0.85, 'romantic', 'Intellectual connection with mutual respect', 'Focus on shared goals while respecting independence'),
  ('mbti', 'ENFP', 'mbti', 'INTJ', 0.90, 'romantic', 'Complementary strengths create balance', 'Be patient with different communication styles'),
  ('mbti', 'ISTJ', 'mbti', 'ESFP', 0.75, 'romantic', 'Opposites can attract with effort', 'Find common ground in shared values'),
  
  -- Blood Type Compatibility (sample data)
  ('blood', 'A', 'blood', 'A', 0.85, 'general', 'Similar temperaments, good understanding', 'May need to encourage more spontaneity'),
  ('blood', 'A', 'blood', 'O', 0.80, 'general', 'Complementary personalities', 'Balance structure with flexibility'),
  ('blood', 'B', 'blood', 'AB', 0.90, 'general', 'Creative and understanding match', 'Encourage each other''s unique perspectives'),
  ('blood', 'O', 'blood', 'O', 0.75, 'general', 'Strong personalities may clash', 'Practice patience and compromise')
ON CONFLICT (type1_category, type1_value, type2_category, type2_value, relationship_type) DO NOTHING;

-- Enable RLS
ALTER TABLE personality_fortune_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_personality_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE personality_compatibility_matrix ENABLE ROW LEVEL SECURITY;
ALTER TABLE personality_traits_reference ENABLE ROW LEVEL SECURITY;

-- RLS Policies for personality_fortune_cache
CREATE POLICY "Users can read their own personality fortune cache" ON personality_fortune_cache
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert their own personality fortune cache" ON personality_fortune_cache
  FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update their own personality fortune cache" ON personality_fortune_cache
  FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete their own personality fortune cache" ON personality_fortune_cache
  FOR DELETE USING (auth.uid() = user_id OR user_id IS NULL);

-- RLS Policies for user_personality_profiles
CREATE POLICY "Users can read their own personality profile" ON user_personality_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own personality profile" ON user_personality_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own personality profile" ON user_personality_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own personality profile" ON user_personality_profiles
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for personality_compatibility_matrix (read-only for all authenticated users)
CREATE POLICY "All users can read compatibility matrix" ON personality_compatibility_matrix
  FOR SELECT USING (true);

-- RLS Policies for personality_traits_reference (read-only for all authenticated users)
CREATE POLICY "All users can read personality traits" ON personality_traits_reference
  FOR SELECT USING (true);

-- Create trigger for updated_at
CREATE TRIGGER update_personality_fortune_cache_updated_at
  BEFORE UPDATE ON personality_fortune_cache
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_personality_profiles_updated_at
  BEFORE UPDATE ON user_personality_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_personality_compatibility_matrix_updated_at
  BEFORE UPDATE ON personality_compatibility_matrix
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate personality compatibility
CREATE OR REPLACE FUNCTION calculate_personality_compatibility(
  p_user_mbti TEXT,
  p_user_blood TEXT,
  p_target_mbti TEXT,
  p_target_blood TEXT,
  p_relationship_type TEXT DEFAULT 'general'
)
RETURNS TABLE (
  overall_score DECIMAL(3,2),
  mbti_score DECIMAL(3,2),
  blood_score DECIMAL(3,2),
  advice TEXT
) AS $$
DECLARE
  v_mbti_score DECIMAL(3,2);
  v_blood_score DECIMAL(3,2);
  v_mbti_advice TEXT;
  v_blood_advice TEXT;
BEGIN
  -- Get MBTI compatibility
  SELECT compatibility_score, description INTO v_mbti_score, v_mbti_advice
  FROM personality_compatibility_matrix
  WHERE type1_category = 'mbti' AND type1_value = p_user_mbti
    AND type2_category = 'mbti' AND type2_value = p_target_mbti
    AND relationship_type = p_relationship_type
  LIMIT 1;
  
  -- If not found, try reverse
  IF v_mbti_score IS NULL THEN
    SELECT compatibility_score, description INTO v_mbti_score, v_mbti_advice
    FROM personality_compatibility_matrix
    WHERE type1_category = 'mbti' AND type1_value = p_target_mbti
      AND type2_category = 'mbti' AND type2_value = p_user_mbti
      AND relationship_type = p_relationship_type
    LIMIT 1;
  END IF;
  
  -- Default MBTI score if not found
  IF v_mbti_score IS NULL THEN
    v_mbti_score := 0.50;
    v_mbti_advice := 'No specific data available, average compatibility';
  END IF;
  
  -- Get blood type compatibility
  SELECT compatibility_score INTO v_blood_score
  FROM personality_compatibility_matrix
  WHERE type1_category = 'blood' AND type1_value = p_user_blood
    AND type2_category = 'blood' AND type2_value = p_target_blood
    AND relationship_type = p_relationship_type
  LIMIT 1;
  
  -- If not found, try reverse
  IF v_blood_score IS NULL THEN
    SELECT compatibility_score INTO v_blood_score
    FROM personality_compatibility_matrix
    WHERE type1_category = 'blood' AND type1_value = p_target_blood
      AND type2_category = 'blood' AND type2_value = p_user_blood
      AND relationship_type = p_relationship_type
    LIMIT 1;
  END IF;
  
  -- Default blood score if not found
  IF v_blood_score IS NULL THEN
    v_blood_score := 0.50;
  END IF;
  
  -- Calculate overall score (weighted average: MBTI 70%, Blood 30%)
  RETURN QUERY
  SELECT 
    (v_mbti_score * 0.7 + v_blood_score * 0.3)::DECIMAL(3,2) as overall_score,
    v_mbti_score as mbti_score,
    v_blood_score as blood_score,
    v_mbti_advice as advice;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired personality cache
CREATE OR REPLACE FUNCTION cleanup_expired_personality_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM personality_fortune_cache 
  WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT SELECT ON personality_fortune_cache TO authenticated;
GRANT INSERT, UPDATE, DELETE ON personality_fortune_cache TO authenticated;
GRANT SELECT ON user_personality_profiles TO authenticated;
GRANT INSERT, UPDATE, DELETE ON user_personality_profiles TO authenticated;
GRANT SELECT ON personality_compatibility_matrix TO authenticated;
GRANT SELECT ON personality_traits_reference TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_personality_compatibility TO authenticated;