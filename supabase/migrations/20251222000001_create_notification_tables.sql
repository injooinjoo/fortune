-- Push Notification System Tables
-- Created: 2025-12-22
-- Purpose: Store notification logs, user preferences, FCM tokens for personalized push notifications

-- =====================================================
-- 1. FCM Tokens Table
-- =====================================================
CREATE TABLE IF NOT EXISTS fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  token TEXT NOT NULL,
  platform VARCHAR(10) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  device_info JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CONSTRAINT unique_user_token UNIQUE (user_id, token)
);

-- Index for efficient lookups
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user ON fcm_tokens(user_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_platform ON fcm_tokens(platform) WHERE is_active = TRUE;

-- RLS Policies
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own FCM tokens"
  ON fcm_tokens
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role can manage all FCM tokens"
  ON fcm_tokens
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- 2. User Notification Preferences Table
-- =====================================================
CREATE TABLE IF NOT EXISTS user_notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,

  -- Channel toggles
  enabled BOOLEAN DEFAULT TRUE,
  daily_fortune BOOLEAN DEFAULT TRUE,
  token_alert BOOLEAN DEFAULT TRUE,
  promotion BOOLEAN DEFAULT TRUE,

  -- Time preferences
  preferred_hour INTEGER CHECK (preferred_hour >= 0 AND preferred_hour <= 23),
  quiet_hours_start TIME DEFAULT '22:00',
  quiet_hours_end TIME DEFAULT '07:00',
  timezone VARCHAR(50) DEFAULT 'Asia/Seoul',

  -- ML-optimized fields
  optimal_send_hour INTEGER CHECK (optimal_send_hour >= 0 AND optimal_send_hour <= 23),
  engagement_score DECIMAL(3,2) DEFAULT 0.5 CHECK (engagement_score >= 0 AND engagement_score <= 1),

  -- Frequency preferences
  max_notifications_per_day INTEGER DEFAULT 3 CHECK (max_notifications_per_day >= 1 AND max_notifications_per_day <= 10),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE user_notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own notification preferences"
  ON user_notification_preferences
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role can manage all notification preferences"
  ON user_notification_preferences
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- 3. Notification Logs Table
-- =====================================================
CREATE TABLE IF NOT EXISTS notification_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  notification_type VARCHAR(50) NOT NULL,
  channel VARCHAR(50) NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  payload JSONB DEFAULT '{}',

  -- Timestamps
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  delivered_at TIMESTAMP WITH TIME ZONE,
  opened_at TIMESTAMP WITH TIME ZONE,
  action_taken BOOLEAN DEFAULT FALSE,

  -- A/B Testing
  ab_test_id VARCHAR(50),
  ab_variant_id VARCHAR(50),

  -- Analytics
  fortune_score INTEGER,
  personalization_score DECIMAL(3,2),

  -- Deduplication constraint (one notification type per user per day)
  CONSTRAINT unique_user_notification_day
    UNIQUE (user_id, notification_type, (sent_at::date))
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_notification_logs_user_date ON notification_logs(user_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_logs_type ON notification_logs(notification_type, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_logs_ab ON notification_logs(ab_test_id, ab_variant_id)
  WHERE ab_test_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_notification_logs_opened ON notification_logs(notification_type, opened_at)
  WHERE opened_at IS NOT NULL;

-- RLS Policies
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notification logs"
  ON notification_logs
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage all notification logs"
  ON notification_logs
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- 4. A/B Test Results Table
-- =====================================================
CREATE TABLE IF NOT EXISTS notification_ab_tests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  test_id VARCHAR(50) NOT NULL,
  variant_id VARCHAR(50) NOT NULL,
  notification_type VARCHAR(50) NOT NULL,

  -- Metrics
  sent_count INTEGER DEFAULT 0,
  delivered_count INTEGER DEFAULT 0,
  opened_count INTEGER DEFAULT 0,
  action_count INTEGER DEFAULT 0,

  -- Retention metrics
  retention_d1_count INTEGER DEFAULT 0,
  retention_d7_count INTEGER DEFAULT 0,

  date DATE NOT NULL,

  CONSTRAINT unique_test_variant_date UNIQUE (test_id, variant_id, date)
);

-- Index for analytics
CREATE INDEX IF NOT EXISTS idx_notification_ab_tests_date ON notification_ab_tests(test_id, date DESC);

-- RLS Policies
ALTER TABLE notification_ab_tests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role can manage A/B tests"
  ON notification_ab_tests
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- 5. Helper Functions
-- =====================================================

-- Function to get users eligible for notification at specific hour
CREATE OR REPLACE FUNCTION get_notification_eligible_users(
  p_notification_type VARCHAR(50),
  p_hour INTEGER
)
RETURNS TABLE (
  user_id UUID,
  fcm_token TEXT,
  platform VARCHAR(10),
  preferred_hour INTEGER,
  timezone VARCHAR(50)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    unp.user_id,
    ft.token,
    ft.platform,
    COALESCE(unp.preferred_hour, unp.optimal_send_hour, 7) as preferred_hour,
    unp.timezone
  FROM user_notification_preferences unp
  JOIN fcm_tokens ft ON ft.user_id = unp.user_id AND ft.is_active = TRUE
  WHERE unp.enabled = TRUE
    AND (
      (p_notification_type = 'daily_fortune' AND unp.daily_fortune = TRUE) OR
      (p_notification_type = 'token_alert' AND unp.token_alert = TRUE) OR
      (p_notification_type = 'promotion' AND unp.promotion = TRUE)
    )
    AND (
      COALESCE(unp.preferred_hour, unp.optimal_send_hour, 7) = p_hour
    )
    AND NOT EXISTS (
      SELECT 1 FROM notification_logs nl
      WHERE nl.user_id = unp.user_id
        AND nl.notification_type = p_notification_type
        AND nl.sent_at::date = CURRENT_DATE
    );
END;
$$;

-- Function to log notification open
CREATE OR REPLACE FUNCTION log_notification_open(
  p_notification_id UUID,
  p_opened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE notification_logs
  SET
    opened_at = p_opened_at,
    action_taken = TRUE
  WHERE id = p_notification_id
    AND opened_at IS NULL;
END;
$$;

-- Function to calculate user engagement score
CREATE OR REPLACE FUNCTION calculate_engagement_score(p_user_id UUID)
RETURNS DECIMAL(3,2)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total_sent INTEGER;
  v_total_opened INTEGER;
  v_score DECIMAL(3,2);
BEGIN
  SELECT
    COUNT(*),
    COUNT(opened_at)
  INTO v_total_sent, v_total_opened
  FROM notification_logs
  WHERE user_id = p_user_id
    AND sent_at > NOW() - INTERVAL '30 days';

  IF v_total_sent = 0 THEN
    RETURN 0.5; -- Default score for new users
  END IF;

  v_score := LEAST(1.0, GREATEST(0.0, v_total_opened::DECIMAL / v_total_sent));

  -- Update user's engagement score
  UPDATE user_notification_preferences
  SET engagement_score = v_score,
      updated_at = NOW()
  WHERE user_id = p_user_id;

  RETURN v_score;
END;
$$;

-- =====================================================
-- 6. Triggers for updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_fcm_tokens_updated_at
  BEFORE UPDATE ON fcm_tokens
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_notification_preferences_updated_at
  BEFORE UPDATE ON user_notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 7. Comments for Documentation
-- =====================================================

COMMENT ON TABLE fcm_tokens IS 'Stores FCM tokens for each user device';
COMMENT ON TABLE user_notification_preferences IS 'User preferences for push notifications including timing and channel toggles';
COMMENT ON TABLE notification_logs IS 'Log of all sent notifications with delivery and open tracking';
COMMENT ON TABLE notification_ab_tests IS 'Aggregated A/B test results for notification experiments';

COMMENT ON FUNCTION get_notification_eligible_users IS 'Returns users eligible for a specific notification type at a given hour';
COMMENT ON FUNCTION log_notification_open IS 'Records when a user opens a notification';
COMMENT ON FUNCTION calculate_engagement_score IS 'Calculates 30-day engagement score for a user';
