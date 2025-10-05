-- Create fortune_history table
CREATE TABLE IF NOT EXISTS fortune_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fortune_type VARCHAR(50) NOT NULL,
  title TEXT NOT NULL,
  summary JSONB NOT NULL,
  fortune_data JSONB NOT NULL,
  score INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  metadata JSONB,
  tags TEXT[],
  view_count INTEGER DEFAULT 1 NOT NULL,
  is_shared BOOLEAN DEFAULT false NOT NULL,
  last_viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  mood VARCHAR(50),
  fortune_date DATE DEFAULT CURRENT_DATE NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_fortune_history_user_id ON fortune_history(user_id);
CREATE INDEX IF NOT EXISTS idx_fortune_history_fortune_type ON fortune_history(fortune_type);
CREATE INDEX IF NOT EXISTS idx_fortune_history_created_at ON fortune_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fortune_history_fortune_date ON fortune_history(fortune_date DESC);
CREATE INDEX IF NOT EXISTS idx_fortune_history_user_date ON fortune_history(user_id, fortune_date DESC);

-- Enable Row Level Security
ALTER TABLE fortune_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Users can only access their own fortune history
CREATE POLICY "Users can view own fortune history" ON fortune_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fortune history" ON fortune_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fortune history" ON fortune_history
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own fortune history" ON fortune_history
  FOR DELETE USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON fortune_history TO authenticated;
GRANT SELECT ON fortune_history TO anon;
