-- 임시 프로필 생성 SQL
-- Google OAuth로 로그인한 사용자의 프로필을 수동으로 생성합니다.
-- Supabase SQL Editor에서 실행하세요.

-- 1. 먼저 현재 사용자 확인
SELECT id, email, raw_user_meta_data 
FROM auth.users 
WHERE id = '070ceecf-774f-4ee0-bb9e-059238dcf028';

-- 2. user_profiles 테이블에 프로필 생성
INSERT INTO user_profiles (
  id, 
  email, 
  name,
  profile_image_url,
  primary_provider, 
  linked_providers,
  created_at,
  updated_at
) VALUES (
  '070ceecf-774f-4ee0-bb9e-059238dcf028',
  (SELECT email FROM auth.users WHERE id = '070ceecf-774f-4ee0-bb9e-059238dcf028'),
  (SELECT raw_user_meta_data->>'full_name' FROM auth.users WHERE id = '070ceecf-774f-4ee0-bb9e-059238dcf028'),
  (SELECT raw_user_meta_data->>'avatar_url' FROM auth.users WHERE id = '070ceecf-774f-4ee0-bb9e-059238dcf028'),
  'google',
  '["google"]'::jsonb,
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  name = COALESCE(EXCLUDED.name, user_profiles.name),
  profile_image_url = COALESCE(EXCLUDED.profile_image_url, user_profiles.profile_image_url),
  updated_at = NOW();

-- 3. 생성된 프로필 확인
SELECT * FROM user_profiles WHERE id = '070ceecf-774f-4ee0-bb9e-059238dcf028';

-- 참고: 위 코드가 실행된 후에도 Flutter 앱이 프로필 자동 생성 로직을 가지고 있으므로,
-- 앞으로는 Google OAuth 로그인 시 자동으로 프로필이 생성됩니다.