-- Add missing columns to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS saju_calculated BOOLEAN DEFAULT FALSE;

-- Add score column to fortunes table if it doesn't exist
ALTER TABLE fortunes 
ADD COLUMN IF NOT EXISTS score INTEGER DEFAULT 75;

-- Update any existing users to have saju_calculated as false initially
UPDATE user_profiles 
SET saju_calculated = FALSE 
WHERE saju_calculated IS NULL;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_saju_calculated 
ON user_profiles (saju_calculated);