-- Add character DM preference flag so character message push can be selectively controlled.
-- 기존 레거시 데이터는 기본값 TRUE로 유지됩니다.
ALTER TABLE user_notification_preferences
ADD COLUMN IF NOT EXISTS character_dm BOOLEAN DEFAULT TRUE;

