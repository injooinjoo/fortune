-- Script to manually apply social auth migration
-- Run this in Supabase SQL Editor

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
  primary_provider = au.raw_app_meta_data->>'provider',
  linked_providers = jsonb_build_array(au.raw_app_meta_data->>'provider')
FROM auth.users au
WHERE up.id = au.id
  AND up.primary_provider IS NULL
  AND au.raw_app_meta_data->>'provider' IS NOT NULL;

-- Verify the migration
SELECT 
  COUNT(*) as total_profiles,
  COUNT(primary_provider) as profiles_with_provider,
  COUNT(linked_providers) as profiles_with_linked_providers
FROM user_profiles;