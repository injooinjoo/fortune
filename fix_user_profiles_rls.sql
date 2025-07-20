-- Fix User Profiles RLS Issue
-- This script removes duplicate RLS policies and applies the correct ones

-- 1. First, check current RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'user_profiles'
ORDER BY policyname;

-- 2. Drop ALL existing policies (including duplicates)
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete their own profile" ON user_profiles;

-- 3. Verify all policies are dropped
SELECT COUNT(*) as remaining_policies 
FROM pg_policies 
WHERE tablename = 'user_profiles';

-- 4. Create correct policies using 'id' column
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

-- 5. Ensure RLS is enabled
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 6. Verify the new policies are created
SELECT 
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'user_profiles'
ORDER BY policyname;

-- 7. Test query for user profile (replace with actual user ID)
-- This should return data if profile exists and RLS is working correctly
SELECT 
    id,
    email,
    name,
    onboarding_completed
FROM user_profiles
WHERE id = '070ceecf-774f-4ee0-bb9e-059238dcf028';

-- 8. Check if the profile actually exists in the table (bypasses RLS)
-- Run this as database admin to verify data exists
SELECT 
    id,
    email,
    name,
    onboarding_completed,
    created_at
FROM user_profiles
WHERE id = '070ceecf-774f-4ee0-bb9e-059238dcf028'
ORDER BY created_at DESC;