-- Create user_profiles table
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  name TEXT NOT NULL,
  birth_date DATE NOT NULL,
  birth_time TIME,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  mbti TEXT,
  zodiac_sign TEXT,
  relationship_status TEXT,
  phone TEXT,
  profile_image_url TEXT,
  is_premium BOOLEAN DEFAULT false,
  premium_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ DEFAULT NOW(),
  onboarding_completed BOOLEAN DEFAULT false,
  preferences JSONB DEFAULT '{}',
  UNIQUE(user_id),
  UNIQUE(email)
);

-- Create user_fortunes table
CREATE TABLE IF NOT EXISTS public.user_fortunes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  fortune_type TEXT NOT NULL,
  category TEXT NOT NULL,
  date DATE NOT NULL,
  data JSONB NOT NULL,
  overall_score INTEGER CHECK (overall_score >= 0 AND overall_score <= 100),
  ai_model TEXT,
  token_count INTEGER,
  cache_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  UNIQUE(user_id, fortune_type, date)
);

-- Create fortune_batches table
CREATE TABLE IF NOT EXISTS public.fortune_batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  batch_id TEXT UNIQUE NOT NULL,
  user_id UUID NOT NULL,
  request_type TEXT NOT NULL,
  fortune_types TEXT[] NOT NULL,
  analysis_results JSONB NOT NULL,
  token_usage JSONB,
  generated_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE
);

-- Create api_usage_logs table
CREATE TABLE IF NOT EXISTS public.api_usage_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  endpoint TEXT NOT NULL,
  method TEXT NOT NULL,
  status_code INTEGER,
  request_body JSONB,
  response_time_ms INTEGER,
  error_message TEXT,
  ip_address INET,
  user_agent TEXT,
  api_key_used TEXT,
  tokens_used INTEGER,
  cost_usd DECIMAL(10, 6),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE SET NULL
);

-- Create payment_transactions table
CREATE TABLE IF NOT EXISTS public.payment_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  transaction_id TEXT UNIQUE NOT NULL,
  payment_method TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'KRW',
  status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE
);

-- Create subscriptions table
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  plan_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('active', 'cancelled', 'expired', 'trial')),
  current_period_start TIMESTAMPTZ NOT NULL,
  current_period_end TIMESTAMPTZ NOT NULL,
  cancel_at_period_end BOOLEAN DEFAULT false,
  cancelled_at TIMESTAMPTZ,
  trial_end TIMESTAMPTZ,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  UNIQUE(user_id)
);

-- Create indexes for performance
CREATE INDEX idx_user_fortunes_user_date ON public.user_fortunes(user_id, date);
CREATE INDEX idx_user_fortunes_type ON public.user_fortunes(fortune_type);
CREATE INDEX idx_api_usage_logs_user ON public.api_usage_logs(user_id);
CREATE INDEX idx_api_usage_logs_created ON public.api_usage_logs(created_at);
CREATE INDEX idx_fortune_batches_user ON public.fortune_batches(user_id);
CREATE INDEX idx_fortune_batches_expires ON public.fortune_batches(expires_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_fortunes_updated_at BEFORE UPDATE ON public.user_fortunes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_fortunes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only see their own profile
CREATE POLICY "Users can view own profile" ON public.user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only see their own fortunes
CREATE POLICY "Users can view own fortunes" ON public.user_fortunes
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM public.user_profiles WHERE user_id = auth.uid()
    )
  );

-- Similar policies for other tables
CREATE POLICY "Users can view own batches" ON public.fortune_batches
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM public.user_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view own transactions" ON public.payment_transactions
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM public.user_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view own subscription" ON public.subscriptions
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM public.user_profiles WHERE user_id = auth.uid()
    )
  );