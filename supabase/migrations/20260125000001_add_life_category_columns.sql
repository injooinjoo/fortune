-- =====================================================
-- Add Life Category Columns to User Profiles
-- Life Consulting Pivot - Phase 1
-- 인생 컨설팅 대분류 및 세부 고민 저장
-- =====================================================

-- Add primary_life_category column
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS primary_life_category TEXT
CHECK (primary_life_category IS NULL OR primary_life_category IN (
  'love_relationship',
  'money_finance',
  'career_study',
  'health_wellness'
));

-- Add sub_concern column
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS sub_concern TEXT;

-- =====================================================
-- Index for Life Category queries
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_user_profiles_life_category
  ON user_profiles(primary_life_category)
  WHERE primary_life_category IS NOT NULL;

-- =====================================================
-- Comments
-- =====================================================
COMMENT ON COLUMN user_profiles.primary_life_category IS '인생 컨설팅 대분류: love_relationship, money_finance, career_study, health_wellness';
COMMENT ON COLUMN user_profiles.sub_concern IS '세부 고민 ID (예: currently_dating, job_change, physical_health 등)';
