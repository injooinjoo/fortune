-- 토큰 사용 기록 테이블
CREATE TABLE IF NOT EXISTS public.token_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fortune_type TEXT NOT NULL,
  tokens_used INTEGER NOT NULL,
  cost DECIMAL(10, 2),
  model TEXT DEFAULT 'gpt-4',
  endpoint TEXT,
  response_time INTEGER, -- milliseconds
  error TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_token_usage_user_id ON public.token_usage(user_id);
CREATE INDEX idx_token_usage_created_at ON public.token_usage(created_at);
CREATE INDEX idx_token_usage_fortune_type ON public.token_usage(fortune_type);

-- RLS 정책
ALTER TABLE public.token_usage ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 기록만 조회 가능
CREATE POLICY "Users can view own token usage" ON public.token_usage
  FOR SELECT USING (auth.uid() = user_id);

-- 시스템은 모든 기록 추가 가능
CREATE POLICY "System can insert token usage" ON public.token_usage
  FOR INSERT WITH CHECK (true);

-- 토큰 잔액 테이블
CREATE TABLE IF NOT EXISTS public.token_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  balance INTEGER NOT NULL DEFAULT 0,
  total_purchased INTEGER NOT NULL DEFAULT 0,
  total_used INTEGER NOT NULL DEFAULT 0,
  last_purchase_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_token_balances_user_id ON public.token_balances(user_id);

-- RLS 정책
ALTER TABLE public.token_balances ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 잔액만 조회 가능
CREATE POLICY "Users can view own balance" ON public.token_balances
  FOR SELECT USING (auth.uid() = user_id);

-- 시스템은 잔액 업데이트 가능
CREATE POLICY "System can update balance" ON public.token_balances
  FOR ALL WITH CHECK (true);

-- 토큰 구매 기록 테이블
CREATE TABLE IF NOT EXISTS public.token_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tokens INTEGER NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  payment_method TEXT NOT NULL,
  payment_id TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_token_purchases_user_id ON public.token_purchases(user_id);
CREATE INDEX idx_token_purchases_status ON public.token_purchases(status);
CREATE INDEX idx_token_purchases_created_at ON public.token_purchases(created_at);

-- RLS 정책
ALTER TABLE public.token_purchases ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 구매 기록만 조회 가능
CREATE POLICY "Users can view own purchases" ON public.token_purchases
  FOR SELECT USING (auth.uid() = user_id);

-- 토큰 사용 통계 뷰
CREATE OR REPLACE VIEW public.token_usage_stats AS
SELECT 
  DATE(created_at) as date,
  fortune_type,
  COUNT(*) as request_count,
  SUM(tokens_used) as total_tokens,
  SUM(cost) as total_cost,
  AVG(response_time) as avg_response_time
FROM public.token_usage
GROUP BY DATE(created_at), fortune_type;

-- 사용자별 토큰 통계 뷰
CREATE OR REPLACE VIEW public.user_token_stats AS
SELECT 
  u.user_id,
  p.full_name,
  p.email,
  COUNT(*) as total_requests,
  SUM(u.tokens_used) as total_tokens_used,
  SUM(u.cost) as total_cost,
  MAX(u.created_at) as last_used_at
FROM public.token_usage u
JOIN public.profiles p ON u.user_id = p.id
GROUP BY u.user_id, p.full_name, p.email;

-- 토큰 잔액 업데이트 함수
CREATE OR REPLACE FUNCTION update_token_balance()
RETURNS TRIGGER AS $$
BEGIN
  -- 토큰 사용 시 잔액 업데이트
  IF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'token_usage' THEN
    UPDATE public.token_balances
    SET 
      balance = balance - NEW.tokens_used,
      total_used = total_used + NEW.tokens_used,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  
  -- 토큰 구매 완료 시 잔액 업데이트
  IF TG_OP = 'UPDATE' AND TG_TABLE_NAME = 'token_purchases' THEN
    IF OLD.status != 'completed' AND NEW.status = 'completed' THEN
      INSERT INTO public.token_balances (user_id, balance, total_purchased)
      VALUES (NEW.user_id, NEW.tokens, NEW.tokens)
      ON CONFLICT (user_id) DO UPDATE
      SET 
        balance = token_balances.balance + NEW.tokens,
        total_purchased = token_balances.total_purchased + NEW.tokens,
        last_purchase_at = NOW(),
        updated_at = NOW();
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
CREATE TRIGGER update_balance_on_usage
AFTER INSERT ON public.token_usage
FOR EACH ROW EXECUTE FUNCTION update_token_balance();

CREATE TRIGGER update_balance_on_purchase
AFTER UPDATE ON public.token_purchases
FOR EACH ROW EXECUTE FUNCTION update_token_balance();

-- 초기 토큰 부여 함수
CREATE OR REPLACE FUNCTION grant_initial_tokens()
RETURNS TRIGGER AS $$
BEGIN
  -- 신규 사용자에게 100 토큰 부여
  INSERT INTO public.token_balances (user_id, balance, total_purchased)
  VALUES (NEW.id, 100, 100);
  
  -- 토큰 구매 기록 생성
  INSERT INTO public.token_purchases (user_id, tokens, amount, payment_method, status)
  VALUES (NEW.id, 100, 0, 'signup_bonus', 'completed');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 신규 사용자 생성 시 토큰 부여
CREATE TRIGGER grant_tokens_on_signup
AFTER INSERT ON public.profiles
FOR EACH ROW EXECUTE FUNCTION grant_initial_tokens();