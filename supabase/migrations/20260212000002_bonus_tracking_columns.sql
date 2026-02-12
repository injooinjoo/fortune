-- 보너스 추적 컬럼 추가
-- user_profiles 테이블에 가입 보너스, 프로필 완성 보너스, 첫 구매 보너스 추적

-- 가입 보너스 지급 여부
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS signup_bonus_granted BOOLEAN DEFAULT FALSE;

-- 프로필 완성 보너스 지급 여부
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS profile_completion_bonus_granted BOOLEAN DEFAULT FALSE;

-- 첫 구매 보너스 지급 여부
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS first_purchase_bonus_granted BOOLEAN DEFAULT FALSE;

-- 인덱스 (보너스 미지급 사용자 빠른 조회)
CREATE INDEX IF NOT EXISTS idx_user_profiles_signup_bonus
  ON user_profiles(signup_bonus_granted)
  WHERE signup_bonus_granted = FALSE;

CREATE INDEX IF NOT EXISTS idx_user_profiles_first_purchase_bonus
  ON user_profiles(first_purchase_bonus_granted)
  WHERE first_purchase_bonus_granted = FALSE;
