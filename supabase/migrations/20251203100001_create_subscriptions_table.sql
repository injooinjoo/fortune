-- ============================================================================
-- 구독 시스템 테이블 생성
-- Flutter InAppPurchase 연동을 위한 구독 관리 스키마
-- ============================================================================

-- 기존 테이블 삭제 후 재생성 (개발 단계에서만 사용)
DROP TABLE IF EXISTS subscription_events CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;

-- 1. subscriptions 테이블 (구독 정보)
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 구독 정보
  product_id TEXT NOT NULL,                       -- 'com.beyond.fortune.subscription.monthly' | 'com.beyond.fortune.subscription.yearly'
  platform TEXT NOT NULL,                          -- 'ios' | 'android' | 'web'
  purchase_id TEXT,                                -- 스토어 거래 ID (transactionId / orderId)

  -- 상태 및 기간
  status TEXT NOT NULL DEFAULT 'active',           -- 'active' | 'expired' | 'cancelled' | 'pending'
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,                 -- 만료 시점 (핵심!)

  -- 메타데이터
  receipt_data JSONB,                              -- 원본 영수증 데이터 (검증용)
  auto_renewing BOOLEAN DEFAULT true,              -- 자동 갱신 여부
  cancel_reason TEXT,                              -- 취소 사유 (있는 경우)

  -- 타임스탬프
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. subscription_events 테이블 (감사 로그)
CREATE TABLE subscription_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,

  -- 이벤트 정보
  event_type TEXT NOT NULL,                        -- 'activated', 'renewed', 'expired', 'cancelled', 'refunded', 'verified'
  product_id TEXT,
  platform TEXT,
  purchase_id TEXT,

  -- 상세 정보
  metadata JSONB,                                  -- 추가 이벤트 데이터
  ip_address TEXT,                                 -- 요청 IP (보안용)

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 인덱스 생성
-- ============================================================================

-- subscriptions 인덱스
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_expires_at ON subscriptions(expires_at);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_product_id ON subscriptions(product_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_status ON subscriptions(user_id, status);

-- subscription_events 인덱스
CREATE INDEX IF NOT EXISTS idx_subscription_events_user_id ON subscription_events(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_events_subscription_id ON subscription_events(subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscription_events_event_type ON subscription_events(event_type);
CREATE INDEX IF NOT EXISTS idx_subscription_events_created_at ON subscription_events(created_at DESC);

-- ============================================================================
-- RLS (Row Level Security) 정책
-- ============================================================================

-- subscriptions RLS 활성화
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- 사용자 본인 구독만 조회 가능
CREATE POLICY "Users can view own subscriptions"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Service role은 모든 작업 가능
CREATE POLICY "Service role has full access to subscriptions"
  ON subscriptions FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- subscription_events RLS 활성화
ALTER TABLE subscription_events ENABLE ROW LEVEL SECURITY;

-- 사용자 본인 이벤트만 조회 가능
CREATE POLICY "Users can view own subscription events"
  ON subscription_events FOR SELECT
  USING (auth.uid() = user_id);

-- Service role은 모든 작업 가능
CREATE POLICY "Service role has full access to subscription events"
  ON subscription_events FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- ============================================================================
-- 트리거: updated_at 자동 갱신
-- ============================================================================

CREATE OR REPLACE FUNCTION update_subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_subscriptions_updated_at();

-- ============================================================================
-- 헬퍼 함수: 활성 구독 확인
-- ============================================================================

CREATE OR REPLACE FUNCTION is_subscription_active(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM subscriptions
    WHERE user_id = p_user_id
      AND status = 'active'
      AND expires_at > NOW()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 헬퍼 함수: 구독 만료 처리 (CRON에서 호출 가능)
-- ============================================================================

CREATE OR REPLACE FUNCTION expire_old_subscriptions()
RETURNS INTEGER AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE subscriptions
  SET status = 'expired', updated_at = NOW()
  WHERE status = 'active'
    AND expires_at <= NOW();

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 코멘트
-- ============================================================================

COMMENT ON TABLE subscriptions IS '사용자 구독 정보 - InAppPurchase 연동';
COMMENT ON TABLE subscription_events IS '구독 이벤트 감사 로그';
COMMENT ON FUNCTION is_subscription_active IS '사용자의 활성 구독 여부 확인';
COMMENT ON FUNCTION expire_old_subscriptions IS '만료된 구독 상태 업데이트 (CRON 호출용)';
