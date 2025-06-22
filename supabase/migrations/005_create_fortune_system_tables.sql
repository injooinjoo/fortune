-- 운세 시스템 핵심 테이블 생성
-- 작성일: 2024-12-19
-- 설명: 4그룹 운세 시스템을 위한 데이터베이스 스키마

-- 1. fortunes 테이블 (운세 데이터 저장)
CREATE TABLE IF NOT EXISTS fortunes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  fortune_type TEXT NOT NULL, -- 'LIFE_PROFILE', 'DAILY_COMPREHENSIVE', 'INTERACTIVE'
  fortune_category TEXT, -- 'saju', 'daily', 'tarot' 등
  data JSONB NOT NULL, -- 운세 결과 데이터
  input_hash TEXT, -- 사용자 입력값 해시 (그룹 3용)
  expires_at TIMESTAMP WITH TIME ZONE, -- 데이터 만료 시간
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. user_profiles 테이블 (사용자 개인화 정보)
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  birth_date DATE NOT NULL,
  birth_time TEXT, -- '자시', '축시' 등
  gender TEXT, -- '남성', '여성', '선택 안함'
  mbti TEXT, -- 'ENFP', 'INTJ' 등
  zodiac_sign TEXT, -- '양자리', '황소자리' 등
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. fortune_history 테이블 (운세 조회 기록)
CREATE TABLE IF NOT EXISTS fortune_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  fortune_type TEXT NOT NULL,
  fortune_category TEXT NOT NULL,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_snapshot JSONB -- 조회 시점의 운세 데이터 스냅샷
);

-- 4. 인덱스 최적화
CREATE INDEX IF NOT EXISTS idx_fortunes_user_type_expires 
ON fortunes(user_id, fortune_type, expires_at);

CREATE INDEX IF NOT EXISTS idx_fortunes_category 
ON fortunes(fortune_category);

CREATE INDEX IF NOT EXISTS idx_fortune_history_user_viewed 
ON fortune_history(user_id, viewed_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_profiles_birth_mbti 
ON user_profiles(birth_date, mbti);

-- 5. RLS (Row Level Security) 정책 설정
ALTER TABLE fortunes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE fortune_history ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 데이터만 접근 가능
CREATE POLICY "Users can view own fortunes" ON fortunes
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fortunes" ON fortunes
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fortunes" ON fortunes
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own profile" ON user_profiles
FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own history" ON fortune_history
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own history" ON fortune_history
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. 트리거 함수 (updated_at 자동 갱신)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 트리거 생성
CREATE TRIGGER update_fortunes_updated_at BEFORE UPDATE ON fortunes
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. 만료된 데이터 자동 삭제 함수
CREATE OR REPLACE FUNCTION cleanup_expired_fortunes()
RETURNS void AS $$
BEGIN
    DELETE FROM fortunes 
    WHERE expires_at IS NOT NULL 
    AND expires_at < NOW();
    
    RAISE NOTICE 'Cleaned up expired fortunes';
END;
$$ LANGUAGE plpgsql;

-- 8. 초기 데이터 (운세 카테고리 매핑)
CREATE TABLE IF NOT EXISTS fortune_category_groups (
  category TEXT PRIMARY KEY,
  group_type TEXT NOT NULL,
  description TEXT,
  expires_hours INTEGER -- NULL이면 영구 저장
);

INSERT INTO fortune_category_groups (category, group_type, description, expires_hours) VALUES
-- 그룹 1: 평생 고정 정보 (만료 없음)
('saju', 'LIFE_PROFILE', '기본 사주', NULL),
('traditional-saju', 'LIFE_PROFILE', '전통 사주', NULL),
('tojeong', 'LIFE_PROFILE', '토정비결', NULL),
('past-life', 'LIFE_PROFILE', '전생', NULL),
('personality', 'LIFE_PROFILE', '타고난 성격', NULL),
('destiny', 'LIFE_PROFILE', '운명의 수레바퀴', NULL),
('salpuli', 'LIFE_PROFILE', '살풀이', NULL),
('five-blessings', 'LIFE_PROFILE', '오복', NULL),
('talent', 'LIFE_PROFILE', '타고난 재능', NULL),

-- 그룹 2: 일일 정보 (24시간 만료)
('daily', 'DAILY_COMPREHENSIVE', '오늘의 총운', 24),
('tomorrow', 'DAILY_COMPREHENSIVE', '내일의 운세', 24),
('hourly', 'DAILY_COMPREHENSIVE', '시간대별 운세', 24),
('wealth', 'DAILY_COMPREHENSIVE', '재물운', 24),
('love', 'DAILY_COMPREHENSIVE', '애정운', 24),
('career', 'DAILY_COMPREHENSIVE', '직업운', 24),
('lucky-number', 'DAILY_COMPREHENSIVE', '행운의 숫자', 24),
('lucky-color', 'DAILY_COMPREHENSIVE', '행운의 색상', 24),
('lucky-food', 'DAILY_COMPREHENSIVE', '행운의 음식', 24),
('biorhythm', 'DAILY_COMPREHENSIVE', '바이오리듬', 24),
('zodiac-animal', 'DAILY_COMPREHENSIVE', '띠별 운세', 24),
('mbti', 'DAILY_COMPREHENSIVE', 'MBTI 운세', 24),

-- 그룹 3: 실시간 상호작용 (1주일 만료)
('dream-interpretation', 'INTERACTIVE', '꿈 해몽', 168),
('tarot', 'INTERACTIVE', '타로점', 168),
('compatibility', 'INTERACTIVE', '궁합', 168),
('worry-bead', 'INTERACTIVE', '고민 구슬', 168)

ON CONFLICT (category) DO NOTHING; 