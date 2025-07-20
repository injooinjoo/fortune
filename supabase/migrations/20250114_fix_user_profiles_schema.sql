-- Fix user_profiles schema issues
-- 1. Change birth_time from TIME to TEXT to support Korean time format
-- 2. Add profile_image_url as an alias for avatar_url for backward compatibility

-- First, alter the birth_time column to TEXT type
ALTER TABLE user_profiles 
ALTER COLUMN birth_time TYPE TEXT;

-- Add profile_image_url column that references avatar_url
-- This is for backward compatibility with existing code
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- Create a trigger to keep profile_image_url in sync with avatar_url
CREATE OR REPLACE FUNCTION sync_profile_image_url()
RETURNS TRIGGER AS $$
BEGIN
  -- When avatar_url is updated, update profile_image_url
  IF NEW.avatar_url IS DISTINCT FROM OLD.avatar_url THEN
    NEW.profile_image_url := NEW.avatar_url;
  END IF;
  
  -- When profile_image_url is updated, update avatar_url
  IF NEW.profile_image_url IS DISTINCT FROM OLD.profile_image_url THEN
    NEW.avatar_url := NEW.profile_image_url;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updates
CREATE TRIGGER sync_profile_image_url_trigger
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION sync_profile_image_url();

-- Create trigger for inserts to ensure both columns are in sync
CREATE OR REPLACE FUNCTION sync_profile_image_url_on_insert()
RETURNS TRIGGER AS $$
BEGIN
  -- If only avatar_url is provided, copy to profile_image_url
  IF NEW.avatar_url IS NOT NULL AND NEW.profile_image_url IS NULL THEN
    NEW.profile_image_url := NEW.avatar_url;
  -- If only profile_image_url is provided, copy to avatar_url
  ELSIF NEW.profile_image_url IS NOT NULL AND NEW.avatar_url IS NULL THEN
    NEW.avatar_url := NEW.profile_image_url;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for inserts
CREATE TRIGGER sync_profile_image_url_on_insert_trigger
BEFORE INSERT ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION sync_profile_image_url_on_insert();

-- Update existing records to sync the columns
UPDATE user_profiles 
SET profile_image_url = avatar_url 
WHERE avatar_url IS NOT NULL AND profile_image_url IS NULL;

-- Add comment to explain the columns
COMMENT ON COLUMN user_profiles.profile_image_url IS 'Alias for avatar_url, maintained for backward compatibility';
COMMENT ON COLUMN user_profiles.avatar_url IS 'User profile image URL';
COMMENT ON COLUMN user_profiles.birth_time IS 'Birth time in text format, supports Korean time periods like "축시 (01:00 - 03:00)"';