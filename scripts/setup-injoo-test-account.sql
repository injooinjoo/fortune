-- Setup injooinjoo@gmail.com as test account
-- Run this in Supabase SQL Editor

-- First check if the columns exist
DO $$ 
BEGIN
    -- Add columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_profiles' 
                   AND column_name = 'is_test_account') THEN
        ALTER TABLE public.user_profiles
        ADD COLUMN is_test_account BOOLEAN DEFAULT FALSE;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_profiles' 
                   AND column_name = 'test_account_features') THEN
        ALTER TABLE public.user_profiles
        ADD COLUMN test_account_features JSONB DEFAULT '{}'::jsonb;
    END IF;
END $$;

-- Update injooinjoo@gmail.com to be a test account
UPDATE public.user_profiles
SET 
  is_test_account = TRUE,
  test_account_features = jsonb_build_object(
    'unlimited_tokens', true,
    'premium_enabled', false,  -- Start with premium off
    'can_toggle_premium', true,
    'created_at', now()
  )
WHERE email = 'injooinjoo@gmail.com';

-- Verify the update
SELECT id, email, is_test_account, test_account_features
FROM public.user_profiles
WHERE email = 'injooinjoo@gmail.com';