-- Add test account fields to user_profiles table
ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS is_test_account BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS test_account_features JSONB DEFAULT '{}'::jsonb;

-- Create index for test accounts
CREATE INDEX IF NOT EXISTS idx_user_profiles_is_test_account 
ON public.user_profiles(is_test_account) 
WHERE is_test_account = TRUE;

-- Mark injooinjoo@gmail.com as a test account
UPDATE public.user_profiles
SET 
  is_test_account = TRUE,
  test_account_features = jsonb_build_object(
    'unlimited_tokens', true,
    'premium_enabled', true,
    'can_toggle_premium', true,
    'created_at', now()
  )
WHERE email = 'injooinjoo@gmail.com';

-- Create a function to check if a user is a test account
CREATE OR REPLACE FUNCTION public.is_test_account(user_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.user_profiles 
    WHERE email = user_email 
    AND is_test_account = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a function to toggle premium for test accounts
CREATE OR REPLACE FUNCTION public.toggle_test_account_premium(user_id UUID, enabled BOOLEAN)
RETURNS JSONB AS $$
DECLARE
  current_features JSONB;
  updated_profile RECORD;
BEGIN
  -- Check if user is a test account
  IF NOT EXISTS (
    SELECT 1 
    FROM public.user_profiles 
    WHERE id = user_id 
    AND is_test_account = TRUE
  ) THEN
    RAISE EXCEPTION 'User is not a test account';
  END IF;

  -- Update the premium status
  UPDATE public.user_profiles
  SET test_account_features = 
    test_account_features || jsonb_build_object('premium_enabled', enabled, 'updated_at', now())
  WHERE id = user_id
  AND is_test_account = TRUE
  RETURNING * INTO updated_profile;

  RETURN jsonb_build_object(
    'success', true,
    'premium_enabled', enabled,
    'test_account_features', updated_profile.test_account_features
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.is_test_account(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.toggle_test_account_premium(UUID, BOOLEAN) TO authenticated;