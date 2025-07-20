-- Run this script in your Supabase SQL Editor to apply the migrations

-- 1. Create user_saju table
-- user_saju 테이블 생성: 사용자별 사주팔자 정보 저장
CREATE TABLE IF NOT EXISTS user_saju (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- 생년월일시 정보
  birth_date DATE NOT NULL,
  birth_time TIME,
  is_lunar BOOLEAN DEFAULT false,
  timezone TEXT DEFAULT 'Asia/Seoul',
  
  -- 사주 기본 정보 (천간지지)
  year_stem VARCHAR(10) NOT NULL,        -- 년간 (갑을병정...)
  year_branch VARCHAR(10) NOT NULL,      -- 년지 (자축인묘...)
  month_stem VARCHAR(10) NOT NULL,       -- 월간
  month_branch VARCHAR(10) NOT NULL,     -- 월지
  day_stem VARCHAR(10) NOT NULL,         -- 일간
  day_branch VARCHAR(10) NOT NULL,       -- 일지
  hour_stem VARCHAR(10),                 -- 시간
  hour_branch VARCHAR(10),               -- 시지
  
  -- 한자 표기
  year_stem_hanja VARCHAR(10),          -- 甲乙丙丁...
  year_branch_hanja VARCHAR(10),        -- 子丑寅卯...
  month_stem_hanja VARCHAR(10),
  month_branch_hanja VARCHAR(10),
  day_stem_hanja VARCHAR(10),
  day_branch_hanja VARCHAR(10),
  hour_stem_hanja VARCHAR(10),
  hour_branch_hanja VARCHAR(10),
  
  -- 오행 분석
  element_balance JSONB DEFAULT '{}'::jsonb,  -- {"목": 2, "화": 1, "토": 2, "금": 2, "수": 1}
  dominant_element VARCHAR(10),               -- 주도 오행
  lacking_element VARCHAR(10),                -- 부족 오행
  
  -- 십신 (Ten Gods) 분석
  ten_gods JSONB DEFAULT '{}'::jsonb,        -- 십신 관계 분석
  
  -- 신살 정보
  spirits JSONB DEFAULT '[]'::jsonb,          -- 신살 목록
  
  -- 대운 정보
  daeun_info JSONB DEFAULT '{}'::jsonb,      -- 대운 흐름 정보
  current_daeun VARCHAR(20),                  -- 현재 대운
  
  -- AI 해석
  interpretation TEXT,                        -- GPT-4.1-nano 해석
  personality_analysis TEXT,                  -- 성격 분석
  career_guidance TEXT,                       -- 직업 조언
  relationship_advice TEXT,                   -- 인간관계 조언
  
  -- 메타데이터
  calculated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- 유니크 제약 (사용자당 하나의 사주)
  UNIQUE(user_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_saju_user_id ON user_saju(user_id);
CREATE INDEX IF NOT EXISTS idx_user_saju_birth_date ON user_saju(birth_date);

-- RLS 정책 설정
ALTER TABLE user_saju ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 사주만 조회 가능
CREATE POLICY "Users can view own saju" ON user_saju
FOR SELECT USING (auth.uid() = user_id);

-- 사용자는 자신의 사주만 수정 가능
CREATE POLICY "Users can update own saju" ON user_saju
FOR UPDATE USING (auth.uid() = user_id);

-- 사용자는 자신의 사주만 삽입 가능
CREATE POLICY "Users can insert own saju" ON user_saju
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 2. Create saju_calculation_history table
CREATE TABLE IF NOT EXISTS saju_calculation_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  calculation_type VARCHAR(50),  -- 'initial', 'recalculation', 'correction'
  request_data JSONB,
  response_data JSONB,
  tokens_used INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 이력 테이블 인덱스
CREATE INDEX IF NOT EXISTS idx_saju_history_user_id ON saju_calculation_history(user_id);
CREATE INDEX IF NOT EXISTS idx_saju_history_created_at ON saju_calculation_history(created_at);

-- 이력 테이블 RLS
ALTER TABLE saju_calculation_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own saju history" ON saju_calculation_history
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own saju history" ON saju_calculation_history
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 3. Create user_statistics table
CREATE TABLE IF NOT EXISTS user_statistics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- 운세 관련 통계
  total_fortunes_viewed INTEGER DEFAULT 0,
  favorite_fortune_type VARCHAR(50),
  last_fortune_date TIMESTAMP WITH TIME ZONE,
  
  -- 사용자 활동 통계
  login_count INTEGER DEFAULT 0,
  last_login_date TIMESTAMP WITH TIME ZONE,
  streak_days INTEGER DEFAULT 0,
  
  -- 토큰 관련
  total_tokens_earned INTEGER DEFAULT 0,
  total_tokens_spent INTEGER DEFAULT 0,
  
  -- 기타 통계
  profile_completion_percentage INTEGER DEFAULT 0,
  achievements JSONB DEFAULT '[]'::jsonb,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- 유니크 제약
  UNIQUE(user_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_statistics_user_id ON user_statistics(user_id);

-- RLS 정책 설정
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 통계만 조회 가능
CREATE POLICY "Users can view own statistics" ON user_statistics
FOR SELECT USING (auth.uid() = user_id);

-- 사용자는 자신의 통계만 수정 가능
CREATE POLICY "Users can update own statistics" ON user_statistics
FOR UPDATE USING (auth.uid() = user_id);

-- 사용자는 자신의 통계만 삽입 가능
CREATE POLICY "Users can insert own statistics" ON user_statistics
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4. Create update trigger function if not exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Add update triggers
CREATE TRIGGER update_user_saju_updated_at 
BEFORE UPDATE ON user_saju 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_statistics_updated_at 
BEFORE UPDATE ON user_statistics 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. Create helper function for Saju
CREATE OR REPLACE FUNCTION get_user_saju(p_user_id UUID)
RETURNS TABLE (
  saju_data JSONB,
  exists BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    CASE 
      WHEN us.id IS NOT NULL THEN
        jsonb_build_object(
          'id', us.id,
          'fourPillars', jsonb_build_object(
            'year', jsonb_build_object(
              'stem', us.year_stem,
              'branch', us.year_branch,
              'stemHanja', us.year_stem_hanja,
              'branchHanja', us.year_branch_hanja
            ),
            'month', jsonb_build_object(
              'stem', us.month_stem,
              'branch', us.month_branch,
              'stemHanja', us.month_stem_hanja,
              'branchHanja', us.month_branch_hanja
            ),
            'day', jsonb_build_object(
              'stem', us.day_stem,
              'branch', us.day_branch,
              'stemHanja', us.day_stem_hanja,
              'branchHanja', us.day_branch_hanja
            ),
            'hour', jsonb_build_object(
              'stem', us.hour_stem,
              'branch', us.hour_branch,
              'stemHanja', us.hour_stem_hanja,
              'branchHanja', us.hour_branch_hanja
            )
          ),
          'elementBalance', us.element_balance,
          'dominantElement', us.dominant_element,
          'lackingElement', us.lacking_element,
          'tenGods', us.ten_gods,
          'spirits', us.spirits,
          'daeunInfo', us.daeun_info,
          'currentDaeun', us.current_daeun,
          'interpretation', us.interpretation,
          'personalityAnalysis', us.personality_analysis,
          'careerGuidance', us.career_guidance,
          'relationshipAdvice', us.relationship_advice,
          'calculatedAt', us.calculated_at
        )
      ELSE NULL
    END as saju_data,
    CASE WHEN us.id IS NOT NULL THEN true ELSE false END as exists
  FROM (SELECT p_user_id as user_id) params
  LEFT JOIN user_saju us ON us.user_id = params.user_id
  WHERE params.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions to service role
GRANT ALL ON user_saju TO service_role;
GRANT ALL ON saju_calculation_history TO service_role;
GRANT ALL ON user_statistics TO service_role;