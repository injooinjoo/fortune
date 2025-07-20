-- Add phone_verified column to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE;

-- Add comment for clarity
COMMENT ON COLUMN user_profiles.phone_verified IS 'Indicates whether the user has verified their phone number';