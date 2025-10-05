-- Create user_statistics table for tracking user fortune activity and statistics
-- This table stores aggregate data about user's fortune usage patterns

CREATE TABLE IF NOT EXISTS user_statistics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,

  -- Fortune activity metrics
  total_fortunes INTEGER DEFAULT 0 NOT NULL,
  consecutive_days INTEGER DEFAULT 0 NOT NULL,
  last_login TIMESTAMP WITH TIME ZONE,
  favorite_fortune_type VARCHAR(50),
  fortune_type_count JSONB DEFAULT '{}'::jsonb NOT NULL,

  -- Token tracking
  total_tokens_used INTEGER DEFAULT 0 NOT NULL,
  total_tokens_earned INTEGER DEFAULT 0 NOT NULL,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_statistics_user_id ON user_statistics(user_id);
CREATE INDEX IF NOT EXISTS idx_user_statistics_consecutive_days ON user_statistics(consecutive_days DESC);
CREATE INDEX IF NOT EXISTS idx_user_statistics_total_fortunes ON user_statistics(total_fortunes DESC);

-- Enable Row Level Security
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Users can only access their own statistics
CREATE POLICY "Users can view own statistics" ON user_statistics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own statistics" ON user_statistics
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own statistics" ON user_statistics
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own statistics" ON user_statistics
  FOR DELETE USING (auth.uid() = user_id);

-- Function to update user statistics automatically
CREATE OR REPLACE FUNCTION update_user_statistics_on_fortune()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert or update user statistics
  INSERT INTO user_statistics (user_id, total_fortunes, last_login, fortune_type_count)
  VALUES (
    NEW.user_id,
    1,
    NOW(),
    jsonb_build_object(NEW.fortune_type, 1)
  )
  ON CONFLICT (user_id) DO UPDATE SET
    total_fortunes = user_statistics.total_fortunes + 1,
    last_login = NOW(),
    fortune_type_count = user_statistics.fortune_type_count ||
      jsonb_build_object(
        NEW.fortune_type,
        COALESCE((user_statistics.fortune_type_count->>NEW.fortune_type)::int, 0) + 1
      ),
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically update statistics when fortune is saved
CREATE TRIGGER trigger_update_user_statistics
  AFTER INSERT ON fortune_history
  FOR EACH ROW
  EXECUTE FUNCTION update_user_statistics_on_fortune();

-- Function to update consecutive days
CREATE OR REPLACE FUNCTION update_consecutive_days()
RETURNS void AS $$
DECLARE
  user_record RECORD;
  last_fortune_date DATE;
  current_streak INTEGER;
BEGIN
  FOR user_record IN
    SELECT DISTINCT user_id FROM user_statistics
  LOOP
    -- Get the most recent fortune date
    SELECT fortune_date INTO last_fortune_date
    FROM fortune_history
    WHERE user_id = user_record.user_id
      AND fortune_type = 'daily'
    ORDER BY fortune_date DESC
    LIMIT 1;

    -- Calculate streak
    IF last_fortune_date = CURRENT_DATE OR last_fortune_date = CURRENT_DATE - INTERVAL '1 day' THEN
      -- Count consecutive days
      WITH RECURSIVE streak_counter AS (
        SELECT fortune_date, 1 as streak
        FROM fortune_history
        WHERE user_id = user_record.user_id
          AND fortune_type = 'daily'
          AND fortune_date = CURRENT_DATE

        UNION ALL

        SELECT fh.fortune_date, sc.streak + 1
        FROM fortune_history fh
        JOIN streak_counter sc ON fh.fortune_date = sc.fortune_date - INTERVAL '1 day'
        WHERE fh.user_id = user_record.user_id
          AND fh.fortune_type = 'daily'
      )
      SELECT MAX(streak) INTO current_streak FROM streak_counter;

      -- Update the statistics
      UPDATE user_statistics
      SET consecutive_days = COALESCE(current_streak, 1),
          updated_at = NOW()
      WHERE user_id = user_record.user_id;
    ELSE
      -- Reset streak if more than 1 day gap
      UPDATE user_statistics
      SET consecutive_days = 0,
          updated_at = NOW()
      WHERE user_id = user_record.user_id;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION update_user_statistics_on_fortune() TO authenticated;
GRANT EXECUTE ON FUNCTION update_consecutive_days() TO authenticated;
