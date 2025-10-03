-- Fortune cache tables for storing fortunes and stories
-- This prevents unnecessary API calls and reduces costs

-- Fortune cache table for storing fortune data (MBTI, etc.)
CREATE TABLE IF NOT EXISTS fortune_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cache_key VARCHAR(255) NOT NULL UNIQUE,
  fortune_type VARCHAR(50) NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  result JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours') NOT NULL
);

-- Fortune stories table for storing GPT-generated story segments
CREATE TABLE IF NOT EXISTS fortune_stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fortune_type VARCHAR(50) NOT NULL,
  story_date DATE NOT NULL,
  story_segments JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours') NOT NULL,
  UNIQUE(user_id, fortune_type, story_date)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_fortune_cache_key ON fortune_cache(cache_key);
CREATE INDEX IF NOT EXISTS idx_fortune_cache_type ON fortune_cache(fortune_type);
CREATE INDEX IF NOT EXISTS idx_fortune_cache_user_id ON fortune_cache(user_id);
CREATE INDEX IF NOT EXISTS idx_fortune_cache_expires ON fortune_cache(expires_at);
CREATE INDEX IF NOT EXISTS idx_fortune_stories_user_date ON fortune_stories(user_id, story_date);
CREATE INDEX IF NOT EXISTS idx_fortune_stories_expires ON fortune_stories(expires_at);

-- RLS (Row Level Security) policies
ALTER TABLE fortune_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_stories ENABLE ROW LEVEL SECURITY;

-- fortune_cache policies - allow anonymous access for public fortunes
CREATE POLICY "Public can view fortune cache" ON fortune_cache
  FOR SELECT USING (user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY "Authenticated users can insert fortune cache" ON fortune_cache
  FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update own fortune cache" ON fortune_cache
  FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete own fortune cache" ON fortune_cache
  FOR DELETE USING (auth.uid() = user_id OR user_id IS NULL);

-- fortune_stories policies - users can only access their own stories
CREATE POLICY "Users can view own fortune stories" ON fortune_stories
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fortune stories" ON fortune_stories
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fortune stories" ON fortune_stories
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own fortune stories" ON fortune_stories
  FOR DELETE USING (auth.uid() = user_id);

-- Function to clean up expired cache entries (can be called periodically via cron)
CREATE OR REPLACE FUNCTION clean_expired_fortune_cache()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete expired fortune cache
  DELETE FROM fortune_cache WHERE expires_at < NOW();
  GET DIAGNOSTICS deleted_count = ROW_COUNT;

  -- Delete expired fortune stories
  DELETE FROM fortune_stories WHERE expires_at < NOW();
  GET DIAGNOSTICS deleted_count = deleted_count + ROW_COUNT;

  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION clean_expired_fortune_cache() TO authenticated;
GRANT EXECUTE ON FUNCTION clean_expired_fortune_cache() TO anon;
