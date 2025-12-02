-- ============================================================================
-- 사주팔자 시스템 테이블 생성
-- 09-saju-terminology.md 문서 기반 완전한 스키마
-- ============================================================================

-- 1. 사용자 사주 기본 테이블
CREATE TABLE IF NOT EXISTS user_saju (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 생년월일시 정보
  birth_date DATE NOT NULL,
  birth_time TIME,
  birth_time_type TEXT, -- '자시', '축시' 등 시간대 유형
  is_lunar BOOLEAN DEFAULT false,
  timezone TEXT DEFAULT 'Asia/Seoul',

  -- ============================================================================
  -- 사주팔자 (四柱八字) - 4개의 기둥, 8개의 글자
  -- ============================================================================

  -- 년주 (年柱)
  year_cheongan TEXT NOT NULL, -- 년 천간 (갑, 을, 병, 정, 무, 기, 경, 신, 임, 계)
  year_jiji TEXT NOT NULL,     -- 년 지지 (자, 축, 인, 묘, 진, 사, 오, 미, 신, 유, 술, 해)

  -- 월주 (月柱)
  month_cheongan TEXT NOT NULL,
  month_jiji TEXT NOT NULL,

  -- 일주 (日柱) - 일간은 '나'를 의미
  day_cheongan TEXT NOT NULL,  -- 일간 (日干) = 나
  day_jiji TEXT NOT NULL,

  -- 시주 (時柱)
  hour_cheongan TEXT,
  hour_jiji TEXT,

  -- ============================================================================
  -- 오행 균형 (五行 Balance)
  -- ============================================================================
  element_wood INTEGER DEFAULT 0,   -- 목 (木)
  element_fire INTEGER DEFAULT 0,   -- 화 (火)
  element_earth INTEGER DEFAULT 0,  -- 토 (土)
  element_metal INTEGER DEFAULT 0,  -- 금 (金)
  element_water INTEGER DEFAULT 0,  -- 수 (水)
  weak_element TEXT,                -- 부족한 오행
  strong_element TEXT,              -- 강한 오행
  enhancement_method TEXT,          -- 오행 보충 방법

  -- ============================================================================
  -- 십신 (十神) - 일간 기준 관계
  -- ============================================================================
  tenshin_year JSONB,  -- {"cheongan": "편관", "jiji": "정재", "jijanggan": [...]}
  tenshin_month JSONB,
  tenshin_day JSONB,   -- 일지만 (일간은 나)
  tenshin_hour JSONB,

  -- ============================================================================
  -- 지장간 (支藏干) - 지지 속 숨은 천간
  -- ============================================================================
  jijanggan_year JSONB,  -- [{"stem": "기", "type": "main", "ratio": 60}, ...]
  jijanggan_month JSONB,
  jijanggan_day JSONB,
  jijanggan_hour JSONB,

  -- ============================================================================
  -- 12운성 (十二運星) - 생명 주기 12단계
  -- ============================================================================
  twelve_stages JSONB,  -- {"year": "장생", "month": "건록", "day": "제왕", "hour": "쇠"}

  -- ============================================================================
  -- 대운 (大運) - 10년 주기 운세
  -- ============================================================================
  daewoon_direction TEXT,      -- 순행/역행
  daewoon_start_age INTEGER,   -- 대운 시작 나이
  daewoon_list JSONB,          -- [{age: 3, cheongan: "갑", jiji: "인", element: "목"}, ...]
  current_daewoon JSONB,       -- 현재 대운 정보

  -- ============================================================================
  -- 합충형파해 (合沖刑破害) - 관계 분석
  -- ============================================================================
  relations JSONB,  -- {
                    --   "cheongan_hap": ["갑기합토"],      -- 천간합
                    --   "jiji_yukhap": ["자축합토"],       -- 지지육합
                    --   "jiji_samhap": ["인오술화국"],     -- 지지삼합
                    --   "jiji_banghap": ["인묘진목"],      -- 지지방합
                    --   "chung": ["자오충"],               -- 충
                    --   "hyung": ["인사신형"],             -- 형
                    --   "pa": [],                         -- 파
                    --   "hae": []                         -- 해
                    -- }

  -- ============================================================================
  -- 신살 (神殺) - 길신/흉신
  -- ============================================================================
  sinsal_gilsin JSONB,   -- 길신: ["천을귀인", "문창귀인", "학당귀인", "월덕귀인", "천의성"]
  sinsal_hyungsin JSONB, -- 흉신: ["역마살", "도화살", "겁살", "망신살", "백호살"]

  -- ============================================================================
  -- 공망 (空亡) - 빈 자리
  -- ============================================================================
  gongmang JSONB,  -- ["술", "해"] - 일주 기준 공망 지지

  -- ============================================================================
  -- 납음오행 (納音五行) - 60갑자 배당 오행
  -- ============================================================================
  napeum_year TEXT,   -- 예: "해중금"
  napeum_month TEXT,
  napeum_day TEXT,
  napeum_hour TEXT,

  -- ============================================================================
  -- LLM 분석 결과
  -- ============================================================================
  personality_traits TEXT,    -- 성격 분석
  fortune_summary TEXT,       -- 전체 운세 요약
  career_fortune TEXT,        -- 직업운
  wealth_fortune TEXT,        -- 재물운
  love_fortune TEXT,          -- 애정운
  health_fortune TEXT,        -- 건강운
  yearly_forecast TEXT,       -- 연간 운세
  life_advice TEXT,           -- 인생 조언
  gpt_analysis JSONB,         -- 전체 GPT 분석 결과

  -- ============================================================================
  -- 메타데이터
  -- ============================================================================
  calculation_version TEXT DEFAULT 'v2.0',  -- 계산 알고리즘 버전
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- 유니크 제약조건
  CONSTRAINT unique_user_saju UNIQUE(user_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_saju_user_id ON user_saju(user_id);
CREATE INDEX IF NOT EXISTS idx_user_saju_birth_date ON user_saju(birth_date);
CREATE INDEX IF NOT EXISTS idx_user_saju_day_cheongan ON user_saju(day_cheongan);

-- RLS (Row Level Security) 활성화
ALTER TABLE user_saju ENABLE ROW LEVEL SECURITY;

-- 사용자 본인 데이터만 조회 가능
CREATE POLICY "Users can view own saju"
  ON user_saju FOR SELECT
  USING (auth.uid() = user_id);

-- 사용자 본인 데이터만 삽입 가능
CREATE POLICY "Users can insert own saju"
  ON user_saju FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 사용자 본인 데이터만 업데이트 가능
CREATE POLICY "Users can update own saju"
  ON user_saju FOR UPDATE
  USING (auth.uid() = user_id);

-- 서비스 역할은 모든 작업 가능
CREATE POLICY "Service role has full access"
  ON user_saju FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- updated_at 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_user_saju_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_saju_updated_at
  BEFORE UPDATE ON user_saju
  FOR EACH ROW
  EXECUTE FUNCTION update_user_saju_updated_at();

-- ============================================================================
-- user_profiles 테이블에 saju_calculated 컬럼 추가 (없는 경우)
-- ============================================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'saju_calculated'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN saju_calculated BOOLEAN DEFAULT false;
  END IF;
END
$$;

-- ============================================================================
-- 기존 fortune_stories 캐시 삭제 (사주 데이터 없이 생성된 것들)
-- ============================================================================
-- DELETE FROM fortune_stories WHERE story_segments::text LIKE '%분석 중%';

COMMENT ON TABLE user_saju IS '사용자 사주팔자 분석 데이터 - 09-saju-terminology.md 기반 완전한 스키마';
