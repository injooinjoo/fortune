-- Fortune cache tables for storing fortunes and stories
-- This prevents unnecessary API calls and reduces costs

-- Drop existing tables if they exist (for clean migration)
DROP TABLE IF EXISTS fortune_stories CASCADE;
DROP TABLE IF EXISTS fortune_cache CASCADE;

-- Fortune cache table for storing fortune data
CREATE TABLE fortune_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fortune_type VARCHAR(50) NOT NULL,
  fortune_date DATE NOT NULL,
  fortune_data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  UNIQUE(user_id, fortune_type, fortune_date)
);

-- Fortune stories table for storing GPT-generated story segments
CREATE TABLE fortune_stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fortune_type VARCHAR(50) NOT NULL,
  story_date DATE NOT NULL,
  story_segments JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  UNIQUE(user_id, fortune_type, story_date)
);

-- Create indexes for better query performance
CREATE INDEX idx_fortune_cache_user_date ON fortune_cache(user_id, fortune_date);
CREATE INDEX idx_fortune_cache_expires ON fortune_cache(expires_at);
CREATE INDEX idx_fortune_stories_user_date ON fortune_stories(user_id, story_date);
CREATE INDEX idx_fortune_stories_expires ON fortune_stories(expires_at);

-- RLS (Row Level Security) policies
ALTER TABLE fortune_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_stories ENABLE ROW LEVEL SECURITY;

-- Users can only access their own cached fortunes
CREATE POLICY "Users can view own fortune cache" ON fortune_cache
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fortune cache" ON fortune_cache
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fortune cache" ON fortune_cache
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own fortune cache" ON fortune_cache
  FOR DELETE USING (auth.uid() = user_id);

-- Users can only access their own story segments
CREATE POLICY "Users can view own fortune stories" ON fortune_stories
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fortune stories" ON fortune_stories
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fortune stories" ON fortune_stories
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own fortune stories" ON fortune_stories
  FOR DELETE USING (auth.uid() = user_id);

-- Function to clean up expired cache entries (can be called periodically)
CREATE OR REPLACE FUNCTION clean_expired_fortune_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM fortune_cache WHERE expires_at < NOW();
  DELETE FROM fortune_stories WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;