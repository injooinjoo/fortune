-- RPC functions to handle user_profiles operations with proper error handling

-- 1. Function to get user profile (bypasses potential RLS issues)
CREATE OR REPLACE FUNCTION get_user_profile(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  email TEXT,
  name TEXT,
  phone_number TEXT,
  birth_date DATE,
  gender TEXT,
  mbti_type TEXT,
  zodiac_sign TEXT,
  profile_image_url TEXT,
  preferences JSONB,
  token_balance INTEGER,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only allow users to get their own profile
  IF p_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Unauthorized: You can only access your own profile';
  END IF;
  
  RETURN QUERY
  SELECT 
    up.id,
    up.user_id,
    up.email,
    up.name,
    up.phone_number,
    up.birth_date,
    up.gender,
    up.mbti_type,
    up.zodiac_sign,
    up.profile_image_url,
    up.preferences,
    up.token_balance,
    up.created_at,
    up.updated_at
  FROM public.user_profiles up
  WHERE up.user_id = p_user_id;
END;
$$;

-- 2. Function to create or update user profile
CREATE OR REPLACE FUNCTION upsert_user_profile(
  p_user_id UUID,
  p_email TEXT,
  p_name TEXT DEFAULT NULL,
  p_profile_image_url TEXT DEFAULT NULL,
  p_token_balance INTEGER DEFAULT 100
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  email TEXT,
  name TEXT,
  profile_image_url TEXT,
  token_balance INTEGER,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only allow users to update their own profile
  IF p_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Unauthorized: You can only update your own profile';
  END IF;
  
  -- Insert or update the profile
  INSERT INTO public.user_profiles (
    user_id,
    email,
    name,
    profile_image_url,
    token_balance,
    created_at,
    updated_at
  ) VALUES (
    p_user_id,
    p_email,
    p_name,
    p_profile_image_url,
    p_token_balance,
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    email = EXCLUDED.email,
    name = COALESCE(EXCLUDED.name, user_profiles.name),
    profile_image_url = COALESCE(EXCLUDED.profile_image_url, user_profiles.profile_image_url),
    updated_at = NOW();
  
  -- Return the updated profile
  RETURN QUERY
  SELECT 
    up.id,
    up.user_id,
    up.email,
    up.name,
    up.profile_image_url,
    up.token_balance,
    up.created_at,
    up.updated_at
  FROM public.user_profiles up
  WHERE up.user_id = p_user_id;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_user_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION upsert_user_profile(UUID, TEXT, TEXT, TEXT, INTEGER) TO authenticated;

-- Test the functions (replace with actual user_id)
-- SELECT * FROM get_user_profile('070ceecf-774f-4ee0-bb9e-059238dcf028');
-- SELECT * FROM upsert_user_profile('070ceecf-774f-4ee0-bb9e-059238dcf028', 'test@example.com', 'Test User');