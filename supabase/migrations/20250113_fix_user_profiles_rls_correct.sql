-- Fix RLS policies for user_profiles table
-- This migration ensures RLS policies match the actual table structure
-- where 'id' is the primary key that references auth.users(id)

-- First, drop any existing policies
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete their own profile" ON user_profiles;

-- Create correct policies using 'id' column
CREATE POLICY "Users can view their own profile" 
  ON user_profiles 
  FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" 
  ON user_profiles 
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
  ON user_profiles 
  FOR UPDATE 
  USING (auth.uid() = id);

CREATE POLICY "Users can delete their own profile" 
  ON user_profiles 
  FOR DELETE 
  USING (auth.uid() = id);

-- Ensure RLS is enabled
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Add helpful comment to the table
COMMENT ON TABLE user_profiles IS 'User profiles table where id column directly references auth.users(id)';
COMMENT ON COLUMN user_profiles.id IS 'Primary key that matches the auth.users(id) for this user';