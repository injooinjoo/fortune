-- Create purchase_history table
CREATE TABLE IF NOT EXISTS public.purchase_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  purchase_token TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  amount DECIMAL(10, 2),
  currency TEXT DEFAULT 'KRW',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create token_transactions table
CREATE TABLE IF NOT EXISTS public.token_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('purchase', 'daily_claim', 'fortune_use', 'refund', 'bonus', 'subscription_start', 'subscription_cancel')),
  description TEXT,
  related_purchase_id UUID REFERENCES public.purchase_history(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_statistics table
CREATE TABLE IF NOT EXISTS public.user_statistics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  total_fortunes_viewed INTEGER DEFAULT 0,
  total_tokens_spent INTEGER DEFAULT 0,
  total_tokens_earned INTEGER DEFAULT 0,
  total_tokens_purchased INTEGER DEFAULT 0,
  daily_streak INTEGER DEFAULT 0,
  last_daily_claim_date DATE,
  longest_streak INTEGER DEFAULT 0,
  favorite_fortune_type TEXT,
  fortune_type_counts JSONB DEFAULT '{}',
  total_shared_fortunes INTEGER DEFAULT 0,
  total_saved_fortunes INTEGER DEFAULT 0,
  account_created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_achievements table
CREATE TABLE IF NOT EXISTS public.user_achievements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id TEXT NOT NULL,
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notified BOOLEAN DEFAULT FALSE,
  progress INTEGER DEFAULT 0,
  target_value INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- Create achievements_metadata table
CREATE TABLE IF NOT EXISTS public.achievements_metadata (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT,
  category TEXT NOT NULL CHECK (category IN ('fortune', 'social', 'streak', 'collection', 'special')),
  points INTEGER DEFAULT 0,
  requirement_type TEXT NOT NULL CHECK (requirement_type IN ('count', 'streak', 'unique', 'special')),
  requirement_value INTEGER,
  is_hidden BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add columns to user_profiles if they don't exist
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS total_tokens INTEGER DEFAULT 10,
ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'premium', 'trial')),
ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP WITH TIME ZONE;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_purchase_history_user_id ON public.purchase_history(user_id);
CREATE INDEX IF NOT EXISTS idx_purchase_history_created_at ON public.purchase_history(created_at);
CREATE INDEX IF NOT EXISTS idx_token_transactions_user_id ON public.token_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_token_transactions_created_at ON public.token_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_user_statistics_user_id ON public.user_statistics(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON public.user_achievements(user_id);

-- Insert default achievements
INSERT INTO public.achievements_metadata (id, name, description, icon, category, points, requirement_type, requirement_value, sort_order)
VALUES 
  -- Fortune achievements
  ('first_fortune', '첫 운세', '첫 번째 운세를 확인했습니다', '🔮', 'fortune', 10, 'count', 1, 1),
  ('fortune_explorer', '운세 탐험가', '10개의 운세를 확인했습니다', '🗺️', 'fortune', 20, 'count', 10, 2),
  ('fortune_master', '운세 마스터', '50개의 운세를 확인했습니다', '👑', 'fortune', 50, 'count', 50, 3),
  ('fortune_legend', '운세 전설', '100개의 운세를 확인했습니다', '🏆', 'fortune', 100, 'count', 100, 4),
  
  -- Streak achievements
  ('week_streak', '일주일 연속', '7일 연속으로 접속했습니다', '🔥', 'streak', 30, 'streak', 7, 10),
  ('month_streak', '한 달 연속', '30일 연속으로 접속했습니다', '💎', 'streak', 100, 'streak', 30, 11),
  ('season_streak', '시즌 마스터', '90일 연속으로 접속했습니다', '🌟', 'streak', 300, 'streak', 90, 12),
  
  -- Collection achievements
  ('fortune_collector', '운세 수집가', '10가지 다른 운세를 확인했습니다', '📚', 'collection', 40, 'unique', 10, 20),
  ('fortune_connoisseur', '운세 감정가', '20가지 다른 운세를 확인했습니다', '🎓', 'collection', 80, 'unique', 20, 21),
  
  -- Social achievements
  ('social_butterfly', '소셜 나비', '5개의 운세를 공유했습니다', '🦋', 'social', 25, 'count', 5, 30),
  ('influencer', '인플루언서', '20개의 운세를 공유했습니다', '📢', 'social', 60, 'count', 20, 31),
  
  -- Special achievements
  ('early_bird', '얼리버드', '오전 6시 이전에 운세를 확인했습니다', '🌅', 'special', 15, 'special', 1, 40),
  ('night_owl', '올빼미', '자정 이후에 운세를 확인했습니다', '🦉', 'special', 15, 'special', 1, 41)
ON CONFLICT (id) DO NOTHING;

-- Create function to update user statistics
CREATE OR REPLACE FUNCTION update_user_statistics()
RETURNS TRIGGER AS $$
BEGIN
  -- Update last_active_at
  UPDATE public.user_statistics
  SET last_active_at = NOW(),
      updated_at = NOW()
  WHERE user_id = NEW.user_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for user activity
CREATE TRIGGER update_user_activity
AFTER INSERT ON public.fortune_history
FOR EACH ROW
EXECUTE FUNCTION update_user_statistics();

-- Enable Row Level Security
ALTER TABLE public.purchase_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.token_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Purchase history policies
CREATE POLICY "Users can view their own purchase history" ON public.purchase_history
  FOR SELECT USING (auth.uid() = user_id);

-- Token transactions policies
CREATE POLICY "Users can view their own token transactions" ON public.token_transactions
  FOR SELECT USING (auth.uid() = user_id);

-- User statistics policies
CREATE POLICY "Users can view their own statistics" ON public.user_statistics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own statistics" ON public.user_statistics
  FOR UPDATE USING (auth.uid() = user_id);

-- User achievements policies
CREATE POLICY "Users can view their own achievements" ON public.user_achievements
  FOR SELECT USING (auth.uid() = user_id);

-- Achievements metadata is public
CREATE POLICY "Anyone can view achievements metadata" ON public.achievements_metadata
  FOR SELECT USING (true);