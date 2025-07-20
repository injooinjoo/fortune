-- Add social authentication columns to user_profiles table
-- These columns track which OAuth providers are linked to a user's account

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS linked_providers JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS primary_provider TEXT;

-- Add comment for documentation
COMMENT ON COLUMN user_profiles.linked_providers IS 'Array of OAuth provider names linked to this account (e.g., ["google", "apple"])';
COMMENT ON COLUMN user_profiles.primary_provider IS 'The primary OAuth provider used for authentication';

-- Add index for better query performance on primary_provider
CREATE INDEX IF NOT EXISTS idx_user_profiles_primary_provider 
ON user_profiles(primary_provider);

-- Update existing users to set their primary provider based on auth.users data
-- This ensures existing OAuth users have their provider information populated
UPDATE user_profiles up
SET 
  primary_provider = CASE 
    WHEN au.raw_app_meta_data->>'provider' IS NOT NULL THEN au.raw_app_meta_data->>'provider'
    WHEN au.app_metadata->>'provider' IS NOT NULL THEN au.app_metadata->>'provider'
    ELSE NULL
  END,
  linked_providers = CASE 
    WHEN au.raw_app_meta_data->>'provider' IS NOT NULL THEN 
      jsonb_build_array(au.raw_app_meta_data->>'provider')
    WHEN au.app_metadata->>'provider' IS NOT NULL THEN 
      jsonb_build_array(au.app_metadata->>'provider')
    ELSE '[]'::jsonb
  END
FROM auth.users au
WHERE up.id = au.id
  AND up.primary_provider IS NULL
  AND (au.raw_app_meta_data->>'provider' IS NOT NULL OR au.app_metadata->>'provider' IS NOT NULL);