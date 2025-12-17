-- 다른 사람 프로필 테이블 (가족/친구 운세 조회용)
-- 2025-12-17: 2.1.4 다른 사람 등록 기능

CREATE TABLE IF NOT EXISTS secondary_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  birth_date TEXT NOT NULL,           -- "1990-01-15" 형식
  birth_time TEXT,                    -- "14:30" 형식 (선택)
  gender TEXT NOT NULL,               -- "male" | "female"
  is_lunar BOOLEAN DEFAULT FALSE,     -- 음력 여부
  relationship TEXT,                  -- "family" | "friend" | "other"
  avatar_index INT DEFAULT 0,         -- 아바타 이미지 인덱스
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_secondary_profiles_owner ON secondary_profiles(owner_id);

-- RLS 활성화
ALTER TABLE secondary_profiles ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 본인 프로필만 조회
CREATE POLICY "Users can view own secondary profiles"
  ON secondary_profiles FOR SELECT
  USING (auth.uid() = owner_id);

-- RLS 정책: 본인 프로필만 추가
CREATE POLICY "Users can insert own secondary profiles"
  ON secondary_profiles FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- RLS 정책: 본인 프로필만 수정
CREATE POLICY "Users can update own secondary profiles"
  ON secondary_profiles FOR UPDATE
  USING (auth.uid() = owner_id);

-- RLS 정책: 본인 프로필만 삭제
CREATE POLICY "Users can delete own secondary profiles"
  ON secondary_profiles FOR DELETE
  USING (auth.uid() = owner_id);

-- 최대 5개 제한 함수
CREATE OR REPLACE FUNCTION check_secondary_profile_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM secondary_profiles WHERE owner_id = NEW.owner_id) >= 5 THEN
    RAISE EXCEPTION 'Maximum 5 secondary profiles allowed per user';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 트리거: 프로필 추가 시 개수 제한 확인
DROP TRIGGER IF EXISTS enforce_secondary_profile_limit ON secondary_profiles;
CREATE TRIGGER enforce_secondary_profile_limit
  BEFORE INSERT ON secondary_profiles
  FOR EACH ROW EXECUTE FUNCTION check_secondary_profile_limit();

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_secondary_profile_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_secondary_profile_updated_at ON secondary_profiles;
CREATE TRIGGER set_secondary_profile_updated_at
  BEFORE UPDATE ON secondary_profiles
  FOR EACH ROW EXECUTE FUNCTION update_secondary_profile_updated_at();

-- 코멘트
COMMENT ON TABLE secondary_profiles IS '다른 사람 프로필 (가족/친구) - 운세 조회용';
COMMENT ON COLUMN secondary_profiles.owner_id IS '소유자 (auth.users.id)';
COMMENT ON COLUMN secondary_profiles.birth_date IS '생년월일 (YYYY-MM-DD 형식)';
COMMENT ON COLUMN secondary_profiles.birth_time IS '태어난 시간 (HH:MM 형식, 선택)';
COMMENT ON COLUMN secondary_profiles.is_lunar IS '음력 여부';
COMMENT ON COLUMN secondary_profiles.relationship IS '관계 (family/friend/other)';
