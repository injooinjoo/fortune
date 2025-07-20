-- Create system_fortune_cache table for storing system-wide fortunes
CREATE TABLE IF NOT EXISTS system_fortune_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cache_key TEXT UNIQUE NOT NULL,
  fortune_type TEXT NOT NULL,
  period TEXT NOT NULL DEFAULT 'daily',
  fortune_data JSONB NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  hit_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX idx_system_fortune_cache_key ON system_fortune_cache(cache_key);
CREATE INDEX idx_system_fortune_cache_expires ON system_fortune_cache(expires_at);
CREATE INDEX idx_system_fortune_cache_type ON system_fortune_cache(fortune_type);
CREATE INDEX idx_system_fortune_cache_created ON system_fortune_cache(created_at);

-- Add comment
COMMENT ON TABLE system_fortune_cache IS 'Cache table for system-wide fortunes like zodiac, MBTI, blood type fortunes';

-- Create system_fortune_stats table for tracking generation statistics
CREATE TABLE IF NOT EXISTS system_fortune_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fortune_type TEXT NOT NULL,
  period TEXT NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  types_count INTEGER NOT NULL,
  tokens_used INTEGER DEFAULT 0,
  generation_time_ms INTEGER DEFAULT 0
);

-- Create index for stats
CREATE INDEX idx_system_fortune_stats_type ON system_fortune_stats(fortune_type);
CREATE INDEX idx_system_fortune_stats_generated ON system_fortune_stats(generated_at);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER update_system_fortune_cache_updated_at
  BEFORE UPDATE ON system_fortune_cache
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT SELECT ON system_fortune_cache TO authenticated;
GRANT SELECT ON system_fortune_stats TO authenticated;
GRANT ALL ON system_fortune_cache TO service_role;
GRANT ALL ON system_fortune_stats TO service_role;