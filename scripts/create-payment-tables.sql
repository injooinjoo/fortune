-- 결제 거래 추적 테이블
CREATE TABLE IF NOT EXISTS payment_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  transaction_id VARCHAR(255) UNIQUE NOT NULL, -- Stripe payment_intent_id 또는 Toss orderId
  payment_provider VARCHAR(50) NOT NULL CHECK (payment_provider IN ('stripe', 'toss')),
  payment_method VARCHAR(50), -- card, bank_transfer, etc.
  amount INTEGER NOT NULL, -- 금액 (원 단위)
  currency VARCHAR(3) NOT NULL DEFAULT 'KRW',
  status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'processing', 'succeeded', 'failed', 'canceled', 'refunded')),
  product_type VARCHAR(50) NOT NULL CHECK (product_type IN ('subscription', 'token_package', 'one_time')),
  product_id VARCHAR(100), -- 구독 플랜 ID 또는 토큰 패키지 ID
  metadata JSONB, -- 추가 데이터 (토큰 수량, 구독 기간 등)
  error_message TEXT,
  webhook_received_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_user_transactions (user_id, created_at DESC),
  INDEX idx_transaction_id (transaction_id),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at DESC)
);

-- 사용자 토큰 잔액 및 사용량 테이블
CREATE TABLE IF NOT EXISTS user_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0), -- 현재 토큰 잔액
  total_purchased INTEGER NOT NULL DEFAULT 0, -- 총 구매한 토큰
  total_used INTEGER NOT NULL DEFAULT 0, -- 총 사용한 토큰
  last_recharged_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_user_id (user_id)
);

-- 토큰 거래 내역 테이블 (토큰 증감 기록)
CREATE TABLE IF NOT EXISTS token_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('purchase', 'usage', 'refund', 'bonus', 'admin_adjustment')),
  amount INTEGER NOT NULL, -- 양수: 증가, 음수: 감소
  balance_after INTEGER NOT NULL, -- 거래 후 잔액
  fortune_type VARCHAR(100), -- 운세 사용시 어떤 운세였는지
  payment_transaction_id UUID REFERENCES payment_transactions(id) ON DELETE SET NULL, -- 구매로 인한 경우
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_user_token_transactions (user_id, created_at DESC),
  INDEX idx_transaction_type (transaction_type),
  INDEX idx_payment_transaction (payment_transaction_id)
);

-- 운세 히스토리 테이블 (생성된 모든 운세 저장)
CREATE TABLE IF NOT EXISTS fortune_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  fortune_type VARCHAR(100) NOT NULL,
  fortune_data JSONB NOT NULL, -- 전체 운세 데이터
  request_data JSONB, -- 요청시 입력 데이터 (생년월일, 이름 등)
  token_cost INTEGER NOT NULL DEFAULT 1, -- 사용된 토큰 수
  response_time INTEGER, -- 응답 시간 (ms)
  model_used VARCHAR(100), -- 사용된 AI 모델
  is_cached BOOLEAN DEFAULT FALSE, -- 캐시에서 가져온 것인지
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_user_fortune_history (user_id, created_at DESC),
  INDEX idx_fortune_type (fortune_type),
  INDEX idx_created_at (created_at DESC)
);

-- 구독 상태 테이블
CREATE TABLE IF NOT EXISTS subscription_status (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  subscription_id VARCHAR(255) UNIQUE, -- Stripe subscription_id
  plan_type VARCHAR(50) NOT NULL CHECK (plan_type IN ('free', 'basic', 'premium', 'enterprise')),
  status VARCHAR(50) NOT NULL CHECK (status IN ('active', 'canceled', 'past_due', 'unpaid', 'expired')),
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  canceled_at TIMESTAMP WITH TIME ZONE,
  monthly_token_quota INTEGER NOT NULL DEFAULT 0, -- 월간 토큰 할당량
  tokens_used_this_period INTEGER NOT NULL DEFAULT 0, -- 이번 기간 사용한 토큰
  features JSONB, -- 플랜별 기능 설정
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 인덱스
  INDEX idx_user_subscription (user_id),
  INDEX idx_subscription_id (subscription_id),
  INDEX idx_status (status),
  INDEX idx_period_end (current_period_end)
);

-- 토큰 패키지 정의 테이블
CREATE TABLE IF NOT EXISTS token_packages (
  id VARCHAR(100) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  tokens INTEGER NOT NULL,
  price INTEGER NOT NULL, -- 원 단위
  bonus_tokens INTEGER DEFAULT 0, -- 보너스 토큰
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 기본 토큰 패키지 데이터 삽입
INSERT INTO token_packages (id, name, description, tokens, price, bonus_tokens) VALUES
  ('token_pack_10', '10 토큰 패키지', '가벼운 사용자를 위한 소량 패키지', 10, 5000, 0),
  ('token_pack_30', '30 토큰 패키지', '일반 사용자를 위한 표준 패키지', 30, 12000, 3),
  ('token_pack_50', '50 토큰 패키지', '자주 사용하는 분들을 위한 패키지', 50, 18000, 5),
  ('token_pack_100', '100 토큰 패키지', '헤비 유저를 위한 대용량 패키지', 100, 30000, 15)
ON CONFLICT (id) DO NOTHING;

-- RLS (Row Level Security) 활성화
ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE token_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_status ENABLE ROW LEVEL SECURITY;

-- RLS 정책 설정
-- payment_transactions: 사용자는 자신의 거래만 조회
CREATE POLICY "Users can view own payment transactions" ON payment_transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage payment transactions" ON payment_transactions
  FOR ALL USING (auth.role() = 'service_role');

-- user_tokens: 사용자는 자신의 토큰 잔액만 조회
CREATE POLICY "Users can view own token balance" ON user_tokens
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage user tokens" ON user_tokens
  FOR ALL USING (auth.role() = 'service_role');

-- token_transactions: 사용자는 자신의 토큰 거래만 조회
CREATE POLICY "Users can view own token transactions" ON token_transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage token transactions" ON token_transactions
  FOR ALL USING (auth.role() = 'service_role');

-- fortune_history: 사용자는 자신의 운세 히스토리만 조회
CREATE POLICY "Users can view own fortune history" ON fortune_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage fortune history" ON fortune_history
  FOR ALL USING (auth.role() = 'service_role');

-- subscription_status: 사용자는 자신의 구독 상태만 조회
CREATE POLICY "Users can view own subscription status" ON subscription_status
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage subscription status" ON subscription_status
  FOR ALL USING (auth.role() = 'service_role');

-- 트리거: payment_transactions 업데이트시 updated_at 자동 갱신
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_payment_transactions_updated_at 
  BEFORE UPDATE ON payment_transactions 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_tokens_updated_at 
  BEFORE UPDATE ON user_tokens 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_status_updated_at 
  BEFORE UPDATE ON subscription_status 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_token_packages_updated_at 
  BEFORE UPDATE ON token_packages 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 유용한 뷰: 사용자 결제 요약
CREATE OR REPLACE VIEW user_payment_summary AS
SELECT 
  u.id as user_id,
  u.email,
  COALESCE(ut.balance, 0) as token_balance,
  COALESCE(ss.plan_type, 'free') as subscription_plan,
  COALESCE(ss.status, 'inactive') as subscription_status,
  COUNT(DISTINCT pt.id) as total_payments,
  COALESCE(SUM(CASE WHEN pt.status = 'succeeded' THEN pt.amount ELSE 0 END), 0) as total_spent,
  MAX(pt.created_at) as last_payment_date
FROM auth.users u
LEFT JOIN user_tokens ut ON u.id = ut.user_id
LEFT JOIN subscription_status ss ON u.id = ss.user_id
LEFT JOIN payment_transactions pt ON u.id = pt.user_id
GROUP BY u.id, u.email, ut.balance, ss.plan_type, ss.status;

-- 월별 수익 집계 뷰
CREATE OR REPLACE VIEW monthly_revenue AS
SELECT 
  DATE_TRUNC('month', created_at) as month,
  payment_provider,
  product_type,
  COUNT(*) as transaction_count,
  SUM(CASE WHEN status = 'succeeded' THEN amount ELSE 0 END) as revenue,
  SUM(CASE WHEN status = 'refunded' THEN amount ELSE 0 END) as refunds
FROM payment_transactions
GROUP BY DATE_TRUNC('month', created_at), payment_provider, product_type
ORDER BY month DESC;