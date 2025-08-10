-- Add is_lunar column to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS is_lunar BOOLEAN DEFAULT false;

-- Add comment for clarity
COMMENT ON COLUMN user_profiles.is_lunar IS 'Whether the birth date is based on lunar calendar';