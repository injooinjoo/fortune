-- ============================================================================
-- Celebrity Saju (사주팔자) Pre-calculated Table
-- 연예인별 사전계산된 사주 정보를 저장하는 테이블
-- ============================================================================

-- ============================================================================
-- 1. celebrity_saju 테이블 생성
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.celebrity_saju (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  celebrity_id TEXT NOT NULL REFERENCES public.celebrities(id) ON DELETE CASCADE,

  -- ============================================================================
  -- 기본 출생 정보
  -- ============================================================================
  birth_date DATE NOT NULL,
  birth_time TIME,                              -- 실제 출생 시간
  birth_time_type TEXT,                         -- '자시', '축시', '인시' 등 시주 구분
  birth_place TEXT,                             -- 출생지
  is_lunar BOOLEAN DEFAULT false,               -- 음력/양력 구분
  timezone TEXT DEFAULT 'Asia/Seoul',           -- 시간대

  -- ============================================================================
  -- 사주 4주 8자 (Four Pillars, Eight Characters)
  -- ============================================================================
  -- 년주 (Year Pillar)
  year_cheongan TEXT NOT NULL,                  -- 년간 (天干) - 갑을병정무기경신임계
  year_jiji TEXT NOT NULL,                      -- 년지 (地支) - 자축인묘진사오미신유술해

  -- 월주 (Month Pillar)
  month_cheongan TEXT NOT NULL,                 -- 월간
  month_jiji TEXT NOT NULL,                     -- 월지

  -- 일주 (Day Pillar) - 가장 중요, 본인의 본질
  day_cheongan TEXT NOT NULL,                   -- 일간 (나의 본질, 일주의 천간)
  day_jiji TEXT NOT NULL,                       -- 일지

  -- 시주 (Hour Pillar) - 출생시간 필요
  hour_cheongan TEXT,                           -- 시간 (출생시간 모르면 NULL)
  hour_jiji TEXT,                               -- 시지

  -- ============================================================================
  -- 오행 분포 (Five Elements Distribution)
  -- ============================================================================
  element_wood INTEGER DEFAULT 0,               -- 목(木) 개수
  element_fire INTEGER DEFAULT 0,               -- 화(火) 개수
  element_earth INTEGER DEFAULT 0,              -- 토(土) 개수
  element_metal INTEGER DEFAULT 0,              -- 금(金) 개수
  element_water INTEGER DEFAULT 0,              -- 수(水) 개수

  weak_element TEXT,                            -- 부족한 오행
  strong_element TEXT,                          -- 강한 오행
  dominant_element TEXT,                        -- 주도 오행

  -- ============================================================================
  -- 십신 (Ten Gods) - JSONB
  -- ============================================================================
  -- 구조: { "year": {"cheongan": "비견", "jiji": "정관"}, "month": {...}, "day": {...}, "hour": {...} }
  tenshin JSONB,

  -- ============================================================================
  -- 지장간 (Hidden Stems in Earthly Branches) - JSONB
  -- ============================================================================
  -- 구조: { "year": ["여기", "중기", "정기"], "month": [...], "day": [...], "hour": [...] }
  jijanggan JSONB,

  -- ============================================================================
  -- 12운성 (Twelve Life Stages) - JSONB
  -- ============================================================================
  -- 구조: { "year": "제왕", "month": "건록", "day": "장생", "hour": "목욕" }
  twelve_stages JSONB,

  -- ============================================================================
  -- 합충형파해 (Relations between Pillars) - JSONB
  -- ============================================================================
  -- 구조: {
  --   "hapchung": [{"type": "삼합", "pillars": ["년지", "월지"], "element": "수"}],
  --   "chung": [{"type": "충", "pillars": ["일지", "시지"]}],
  --   "hyung": [],
  --   "pa": [],
  --   "hae": []
  -- }
  relations JSONB,

  -- ============================================================================
  -- 신살 (Spirit Killers / Auspicious Stars) - JSONB
  -- ============================================================================
  -- 길신 (Auspicious)
  sinsal_gilsin JSONB,                          -- ["천을귀인", "문창귀인", "학당귀인"]

  -- 흉신 (Inauspicious)
  sinsal_hyungsin JSONB,                        -- ["겁살", "망신살", "도화살"]

  -- ============================================================================
  -- 대운 (Major Fortune Cycles) - JSONB
  -- ============================================================================
  -- 구조: [
  --   {"age_start": 1, "age_end": 10, "cheongan": "갑", "jiji": "자", "element": "수"},
  --   {"age_start": 11, "age_end": 20, "cheongan": "을", "jiji": "축", "element": "토"},
  --   ...
  -- ]
  daewoon_list JSONB,

  -- 대운 시작 나이
  daewoon_start_age INTEGER,

  -- 대운 방향 (순행/역행)
  daewoon_direction TEXT CHECK (daewoon_direction IN ('순행', '역행')),

  -- ============================================================================
  -- 격국 (Pattern/Structure) - JSONB
  -- ============================================================================
  -- 구조: { "name": "정관격", "description": "...", "characteristics": [...] }
  gyeokguk JSONB,

  -- ============================================================================
  -- 용신/희신/기신/구신 (Favorable/Unfavorable Elements)
  -- ============================================================================
  yongsin TEXT,                                 -- 용신 (가장 필요한 오행)
  huisin TEXT,                                  -- 희신 (용신을 돕는 오행)
  gisin TEXT,                                   -- 기신 (기피해야 할 오행)
  gusin TEXT,                                   -- 구신 (원수 오행)

  -- ============================================================================
  -- AI 분석 결과 (캐시용)
  -- ============================================================================
  ai_personality_analysis TEXT,                 -- AI가 분석한 성격/특성
  ai_career_analysis TEXT,                      -- AI가 분석한 적합 직업
  ai_relationship_analysis TEXT,                -- AI가 분석한 대인관계
  ai_analysis_updated_at TIMESTAMPTZ,           -- AI 분석 갱신 시간

  -- ============================================================================
  -- 데이터 품질 관리
  -- ============================================================================
  data_accuracy TEXT DEFAULT 'date_only' CHECK (data_accuracy IN ('full', 'date_and_time', 'date_only')),
  -- full: 년월일시 모두 정확
  -- date_and_time: 년월일 + 대략적 시간 (시주 범위)
  -- date_only: 년월일만 정확 (시주 12:00 기본값 사용)

  source TEXT,                                  -- 데이터 출처 (나무위키, 위키피디아 등)
  source_url TEXT,                              -- 출처 URL
  verified_by TEXT,                             -- 검증자 (수동 검증 시)
  verified_at TIMESTAMPTZ,                      -- 검증 일시

  -- ============================================================================
  -- 시스템 필드
  -- ============================================================================
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- ============================================================================
  -- 제약조건
  -- ============================================================================
  CONSTRAINT unique_celebrity_saju UNIQUE(celebrity_id)
);

-- ============================================================================
-- 2. 인덱스 생성
-- ============================================================================

-- 기본 조회용 인덱스
CREATE INDEX IF NOT EXISTS idx_celebrity_saju_celebrity_id
  ON public.celebrity_saju(celebrity_id);

-- 일간(日干) 기준 검색 - "나와 같은 일간인 연예인 찾기"
CREATE INDEX IF NOT EXISTS idx_celebrity_saju_day_cheongan
  ON public.celebrity_saju(day_cheongan);

-- 오행 분포 검색 - "목(木)이 강한 연예인 찾기"
CREATE INDEX IF NOT EXISTS idx_celebrity_saju_dominant_element
  ON public.celebrity_saju(dominant_element);

-- 데이터 정확도별 검색
CREATE INDEX IF NOT EXISTS idx_celebrity_saju_data_accuracy
  ON public.celebrity_saju(data_accuracy);

-- 복합 인덱스: 일주 검색 - "갑자일주 연예인 찾기"
CREATE INDEX IF NOT EXISTS idx_celebrity_saju_day_pillar
  ON public.celebrity_saju(day_cheongan, day_jiji);

-- ============================================================================
-- 3. 트리거: updated_at 자동 갱신
-- ============================================================================

CREATE OR REPLACE FUNCTION update_celebrity_saju_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_celebrity_saju_updated_at
  BEFORE UPDATE ON public.celebrity_saju
  FOR EACH ROW
  EXECUTE FUNCTION update_celebrity_saju_updated_at();

-- ============================================================================
-- 4. RLS (Row Level Security) 정책
-- ============================================================================

ALTER TABLE public.celebrity_saju ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 읽기 가능 (공개 데이터)
CREATE POLICY "celebrity_saju_select_policy" ON public.celebrity_saju
  FOR SELECT
  TO authenticated, anon
  USING (true);

-- 관리자만 삽입/수정/삭제 가능
CREATE POLICY "celebrity_saju_insert_policy" ON public.celebrity_saju
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
  );

CREATE POLICY "celebrity_saju_update_policy" ON public.celebrity_saju
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
  );

CREATE POLICY "celebrity_saju_delete_policy" ON public.celebrity_saju
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
  );

-- ============================================================================
-- 5. celebrities 테이블에 사주 관련 컬럼 추가
-- ============================================================================

ALTER TABLE public.celebrities
ADD COLUMN IF NOT EXISTS birth_time_verified BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS birth_time_source TEXT,
ADD COLUMN IF NOT EXISTS is_lunar BOOLEAN DEFAULT false;

-- birth_time_verified 인덱스
CREATE INDEX IF NOT EXISTS idx_celebrities_birth_time_verified
  ON public.celebrities(birth_time_verified);

-- ============================================================================
-- 6. 뷰 생성: 연예인 + 사주 정보 조인 뷰
-- ============================================================================

CREATE OR REPLACE VIEW public.celebrity_with_saju AS
SELECT
  c.id,
  c.name,
  c.name_en,
  c.category,
  c.subcategory,
  c.birth_date,
  c.birth_time,
  c.birth_place,
  c.gender,
  c.popularity_score,
  c.image_url,
  c.is_lunar,
  c.birth_time_verified,
  c.birth_time_source,
  -- 사주 정보
  s.year_cheongan,
  s.year_jiji,
  s.month_cheongan,
  s.month_jiji,
  s.day_cheongan,
  s.day_jiji,
  s.hour_cheongan,
  s.hour_jiji,
  -- 오행
  s.element_wood,
  s.element_fire,
  s.element_earth,
  s.element_metal,
  s.element_water,
  s.dominant_element,
  s.weak_element,
  -- 분석 결과
  s.tenshin,
  s.twelve_stages,
  s.relations,
  s.sinsal_gilsin,
  s.sinsal_hyungsin,
  s.gyeokguk,
  s.yongsin,
  s.daewoon_list,
  s.data_accuracy,
  s.source AS saju_source
FROM public.celebrities c
LEFT JOIN public.celebrity_saju s ON c.id = s.celebrity_id;

-- ============================================================================
-- 7. 함수: 같은 일간(日干) 연예인 검색
-- ============================================================================

CREATE OR REPLACE FUNCTION find_celebrities_by_day_cheongan(p_day_cheongan TEXT)
RETURNS TABLE (
  celebrity_id TEXT,
  name TEXT,
  category TEXT,
  day_cheongan TEXT,
  day_jiji TEXT,
  popularity_score INTEGER,
  image_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.name,
    c.category,
    s.day_cheongan,
    s.day_jiji,
    c.popularity_score,
    c.image_url
  FROM public.celebrities c
  JOIN public.celebrity_saju s ON c.id = s.celebrity_id
  WHERE s.day_cheongan = p_day_cheongan
  ORDER BY c.popularity_score DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 8. 함수: 같은 일주(日柱) 연예인 검색
-- ============================================================================

CREATE OR REPLACE FUNCTION find_celebrities_by_day_pillar(
  p_day_cheongan TEXT,
  p_day_jiji TEXT
)
RETURNS TABLE (
  celebrity_id TEXT,
  name TEXT,
  category TEXT,
  day_cheongan TEXT,
  day_jiji TEXT,
  popularity_score INTEGER,
  image_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.name,
    c.category,
    s.day_cheongan,
    s.day_jiji,
    c.popularity_score,
    c.image_url
  FROM public.celebrities c
  JOIN public.celebrity_saju s ON c.id = s.celebrity_id
  WHERE s.day_cheongan = p_day_cheongan
    AND s.day_jiji = p_day_jiji
  ORDER BY c.popularity_score DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 9. 함수: 오행 분포가 비슷한 연예인 검색
-- ============================================================================

CREATE OR REPLACE FUNCTION find_celebrities_by_element_similarity(
  p_wood INTEGER,
  p_fire INTEGER,
  p_earth INTEGER,
  p_metal INTEGER,
  p_water INTEGER,
  p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
  celebrity_id TEXT,
  name TEXT,
  category TEXT,
  element_wood INTEGER,
  element_fire INTEGER,
  element_earth INTEGER,
  element_metal INTEGER,
  element_water INTEGER,
  similarity_score FLOAT,
  image_url TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.name,
    c.category,
    s.element_wood,
    s.element_fire,
    s.element_earth,
    s.element_metal,
    s.element_water,
    -- 유클리드 거리 기반 유사도 (작을수록 비슷)
    SQRT(
      POWER(s.element_wood - p_wood, 2) +
      POWER(s.element_fire - p_fire, 2) +
      POWER(s.element_earth - p_earth, 2) +
      POWER(s.element_metal - p_metal, 2) +
      POWER(s.element_water - p_water, 2)
    ) AS similarity_score,
    c.image_url
  FROM public.celebrities c
  JOIN public.celebrity_saju s ON c.id = s.celebrity_id
  ORDER BY similarity_score ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 10. 코멘트 추가
-- ============================================================================

COMMENT ON TABLE public.celebrity_saju IS '연예인 사주팔자 사전계산 테이블 - 750+ 연예인의 사주 정보';

COMMENT ON COLUMN public.celebrity_saju.day_cheongan IS '일간(日干) - 본인의 본질을 나타내는 가장 중요한 요소';
COMMENT ON COLUMN public.celebrity_saju.tenshin IS '십신 분석 결과 (비견, 겁재, 식신, 상관, 편재, 정재, 편관, 정관, 편인, 정인)';
COMMENT ON COLUMN public.celebrity_saju.twelve_stages IS '12운성 (장생, 목욕, 관대, 건록, 제왕, 쇠, 병, 사, 묘, 절, 태, 양)';
COMMENT ON COLUMN public.celebrity_saju.relations IS '합충형파해 관계 분석';
COMMENT ON COLUMN public.celebrity_saju.data_accuracy IS 'full=완전, date_and_time=시간대략, date_only=날짜만';
COMMENT ON COLUMN public.celebrity_saju.yongsin IS '용신 - 사주에서 가장 필요한 오행';

COMMENT ON FUNCTION find_celebrities_by_day_cheongan IS '같은 일간(日干)을 가진 연예인 검색';
COMMENT ON FUNCTION find_celebrities_by_day_pillar IS '같은 일주(日柱)를 가진 연예인 검색';
COMMENT ON FUNCTION find_celebrities_by_element_similarity IS '오행 분포가 비슷한 연예인 검색';
