-- 사용자 프로필 테이블 생성
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  name TEXT NOT NULL,
  avatar_url TEXT,
  birth_date DATE,
  birth_time TIME,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  mbti TEXT CHECK (length(mbti) = 4),
  blood_type TEXT CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
  zodiac_sign TEXT,
  chinese_zodiac TEXT,
  job TEXT,
  location TEXT,
  subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'premium', 'enterprise')),
  fortune_count INTEGER DEFAULT 0,
  favorite_fortune_types JSONB DEFAULT '[]'::jsonb,
  onboarding_completed BOOLEAN DEFAULT false,
  privacy_settings JSONB DEFAULT '{
    "show_profile": true,
    "share_fortune": false,
    "email_notifications": true
  }'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_subscription_status ON user_profiles(subscription_status);
CREATE INDEX IF NOT EXISTS idx_user_profiles_onboarding_completed ON user_profiles(onboarding_completed);

-- RLS 정책 설정
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 프로필만 조회/수정 가능
CREATE POLICY "Users can view own profile" ON user_profiles
FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
FOR INSERT WITH CHECK (auth.uid() = id);

-- 프로필 업데이트 트리거
CREATE TRIGGER update_user_profiles_updated_at 
BEFORE UPDATE ON user_profiles 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 새 사용자 등록 시 자동으로 프로필 생성하는 함수
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', '사용자')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 새 사용자 등록 트리거
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 게스트 사용자를 위한 임시 프로필 테이블
CREATE TABLE IF NOT EXISTS guest_profiles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  birth_date DATE,
  birth_time TIME,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  mbti TEXT CHECK (length(mbti) = 4),
  blood_type TEXT CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
  zodiac_sign TEXT,
  chinese_zodiac TEXT,
  job TEXT,
  location TEXT,
  session_data JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP + INTERVAL '7 days')
);

-- 게스트 프로필 인덱스
CREATE INDEX IF NOT EXISTS idx_guest_profiles_expires_at ON guest_profiles(expires_at);

-- 만료된 게스트 프로필 자동 삭제 함수
CREATE OR REPLACE FUNCTION cleanup_expired_guest_profiles()
RETURNS VOID AS $$
BEGIN
  DELETE FROM guest_profiles WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- 매일 자정에 만료된 게스트 프로필 삭제 (pg_cron 필요)
-- SELECT cron.schedule('cleanup-guest-profiles', '0 0 * * *', 'SELECT cleanup_expired_guest_profiles();'); 