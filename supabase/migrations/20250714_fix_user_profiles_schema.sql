-- Fix user_profiles schema issues
-- 1. Change birth_time from TIME to TEXT to support Korean time format
-- 2. Add profile_image_url column if it doesn't exist
-- 3. Ensure consistent schema

-- First, check which table structure we're using by looking at columns
DO $$ 
BEGIN
  -- Change birth_time column type from TIME to TEXT if it exists as TIME
  IF EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'user_profiles' 
    AND column_name = 'birth_time' 
    AND data_type = 'time without time zone'
  ) THEN
    ALTER TABLE user_profiles 
    ALTER COLUMN birth_time TYPE TEXT USING birth_time::TEXT;
  END IF;

  -- Add profile_image_url column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'user_profiles' 
    AND column_name = 'profile_image_url'
  ) THEN
    -- Check if avatar_url exists and rename it
    IF EXISTS (
      SELECT 1 
      FROM information_schema.columns 
      WHERE table_name = 'user_profiles' 
      AND column_name = 'avatar_url'
    ) THEN
      ALTER TABLE user_profiles RENAME COLUMN avatar_url TO profile_image_url;
    ELSE
      -- Add new column
      ALTER TABLE user_profiles ADD COLUMN profile_image_url TEXT;
    END IF;
  END IF;

  -- Ensure other expected columns exist
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'user_profiles' 
    AND column_name = 'linked_providers'
  ) THEN
    ALTER TABLE user_profiles 
    ADD COLUMN linked_providers JSONB DEFAULT '[]'::jsonb;
  END IF;

  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'user_profiles' 
    AND column_name = 'primary_provider'
  ) THEN
    ALTER TABLE user_profiles 
    ADD COLUMN primary_provider TEXT;
  END IF;
END $$;

-- Add comments for documentation
COMMENT ON COLUMN user_profiles.birth_time IS 'Birth time in Korean traditional format (e.g., 축시, 인시) or time range';
COMMENT ON COLUMN user_profiles.profile_image_url IS 'User profile image URL from social auth or uploaded';

-- Create or replace the handle_new_user function to handle both schemas
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Try to insert with minimal required fields first
  INSERT INTO public.user_profiles (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name', 
      NEW.raw_user_meta_data->>'name',
      split_part(NEW.email, '@', 1),
      '사용자'
    )
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    name = COALESCE(user_profiles.name, EXCLUDED.name),
    updated_at = NOW();
    
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't fail the auth signup
    RAISE WARNING 'Failed to create user profile: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate trigger if needed
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();