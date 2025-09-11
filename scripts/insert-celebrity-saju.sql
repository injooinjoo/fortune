-- 유명인 사주 데이터 직접 삽입 SQL
-- 이 스크립트를 Supabase SQL Editor에서 실행하세요

-- 기존 celebrities 테이블이 있다면 확인
-- celebrities 테이블에 사주 관련 컬럼이 없다면 추가
ALTER TABLE public.celebrities 
ADD COLUMN IF NOT EXISTS real_name TEXT,
ADD COLUMN IF NOT EXISTS birth_place TEXT,
ADD COLUMN IF NOT EXISTS year_pillar TEXT,
ADD COLUMN IF NOT EXISTS month_pillar TEXT,
ADD COLUMN IF NOT EXISTS day_pillar TEXT,
ADD COLUMN IF NOT EXISTS hour_pillar TEXT,
ADD COLUMN IF NOT EXISTS saju_string TEXT,
ADD COLUMN IF NOT EXISTS wood_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS fire_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS earth_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS metal_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS water_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS dominant_element TEXT,
ADD COLUMN IF NOT EXISTS full_saju_data JSONB,
ADD COLUMN IF NOT EXISTS data_source TEXT;

-- 유명인 데이터 삽입 (사주 계산 완료)
INSERT INTO public.celebrities (
    id, name, real_name, name_en, birth_date, birth_time, birth_place, gender, category,
    year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
    wood_count, fire_count, earth_count, metal_count, water_count,
    dominant_element, full_saju_data, data_source
) VALUES 
-- IU (1993-05-16)
('IU_1993-05-16', 'IU', '이지은', 'IU', '1993-05-16', NULL, '서울특별시', 'female', 'singer',
 '계유', '정사', '정해', NULL, '계유 정사 정해',
 1, 2, 0, 2, 3, '수',
 '{"year": {"stem": "계", "branch": "유"}, "month": {"stem": "정", "branch": "사"}, "day": {"stem": "정", "branch": "해"}}',
 'manual_calculated'),

-- 손흥민 (1992-07-08)
('손흥민_1992-07-08', '손흥민', '손흥민', 'Son Heung-min', '1992-07-08', NULL, '강원도 춘천시', 'male', 'athlete',
 '임신', '정미', '을유', NULL, '임신 정미 을유',
 1, 1, 2, 2, 2, '토',
 '{"year": {"stem": "임", "branch": "신"}, "month": {"stem": "정", "branch": "미"}, "day": {"stem": "을", "branch": "유"}}',
 'manual_calculated'),

-- 유재석 (1972-08-14, 21:00)
('유재석_1972-08-14', '유재석', '유재석', 'Yoo Jae-suk', '1972-08-14', '21:00', '서울특별시 성북구', 'male', 'entertainer',
 '임자', '무신', '무오', '계해', '임자 무신 무오 계해',
 0, 1, 2, 2, 3, '수',
 '{"year": {"stem": "임", "branch": "자"}, "month": {"stem": "무", "branch": "신"}, "day": {"stem": "무", "branch": "오"}, "hour": {"stem": "계", "branch": "해"}}',
 'manual_calculated'),

-- 이효리 (1979-05-10, 12:00)
('이효리_1979-05-10', '이효리', '이효리', 'Lee Hyo-ri', '1979-05-10', '12:00', '충청북도 청원군', 'female', 'singer',
 '기미', '기사', '경인', '임오', '기미 기사 경인 임오',
 2, 2, 2, 1, 1, '목',
 '{"year": {"stem": "기", "branch": "미"}, "month": {"stem": "기", "branch": "사"}, "day": {"stem": "경", "branch": "인"}, "hour": {"stem": "임", "branch": "오"}}',
 'manual_calculated'),

-- 송중기 (1985-09-19, 21:00)
('송중기_1985-09-19', '송중기', '송중기', 'Song Joong-ki', '1985-09-19', '21:00', '대전광역시 동구', 'male', 'actor',
 '을축', '을유', '경술', '정해', '을축 을유 경술 정해',
 2, 1, 2, 2, 1, '목',
 '{"year": {"stem": "을", "branch": "축"}, "month": {"stem": "을", "branch": "유"}, "day": {"stem": "경", "branch": "술"}, "hour": {"stem": "정", "branch": "해"}}',
 'manual_calculated'),

-- G-Dragon (권지용, 1988-08-18, 21:00)
('G-Dragon_1988-08-18', 'G-Dragon', '권지용', 'G-Dragon', '1988-08-18', '21:00', '서울특별시 용산구', 'male', 'singer',
 '무진', '경신', '계미', '계해', '무진 경신 계미 계해',
 1, 0, 3, 2, 2, '토',
 '{"year": {"stem": "무", "branch": "진"}, "month": {"stem": "경", "branch": "신"}, "day": {"stem": "계", "branch": "미"}, "hour": {"stem": "계", "branch": "해"}}',
 'manual_calculated'),

-- 박지성 (1981-02-25, 21:00)
('박지성_1981-02-25', '박지성', '박지성', 'Park Ji-sung', '1981-02-25', '21:00', '서울특별시 서대문구', 'male', 'athlete',
 '신유', '경인', '을해', '정해', '신유 경인 을해 정해',
 2, 1, 0, 3, 2, '금',
 '{"year": {"stem": "신", "branch": "유"}, "month": {"stem": "경", "branch": "인"}, "day": {"stem": "을", "branch": "해"}, "hour": {"stem": "정", "branch": "해"}}',
 'manual_calculated'),

-- 김연아 (1990-09-05, 21:00)
('김연아_1990-09-05', '김연아', '김연아', 'Kim Yuna', '1990-09-05', '21:00', '경기도 부천시', 'female', 'athlete',
 '경오', '갑신', '정축', '신해', '경오 갑신 정축 신해',
 1, 2, 1, 3, 1, '금',
 '{"year": {"stem": "경", "branch": "오"}, "month": {"stem": "갑", "branch": "신"}, "day": {"stem": "정", "branch": "축"}, "hour": {"stem": "신", "branch": "해"}}',
 'manual_calculated'),

-- 윤석열 (1960-12-18, 21:00)
('윤석열_1960-12-18', '윤석열', '윤석열', 'Yoon Suk-yeol', '1960-12-18', '21:00', '서울특별시', 'male', 'politician',
 '경자', '무자', '을미', '정해', '경자 무자 을미 정해',
 1, 1, 2, 1, 3, '수',
 '{"year": {"stem": "경", "branch": "자"}, "month": {"stem": "무", "branch": "자"}, "day": {"stem": "을", "branch": "미"}, "hour": {"stem": "정", "branch": "해"}}',
 'manual_calculated'),

-- 이재용 (1968-06-23, 21:00)
('이재용_1968-06-23', '이재용', '이재용', 'Lee Jae-yong', '1968-06-23', '21:00', '서울특별시', 'male', 'business_leader',
 '무신', '무오', '신사', '기해', '무신 무오 신사 기해',
 0, 3, 2, 2, 1, '화',
 '{"year": {"stem": "무", "branch": "신"}, "month": {"stem": "무", "branch": "오"}, "day": {"stem": "신", "branch": "사"}, "hour": {"stem": "기", "branch": "해"}}',
 'manual_calculated'),

-- BTS RM (김남준, 1994-09-12)
('BTS_RM_1994-09-12', 'BTS RM', '김남준', 'RM', '1994-09-12', NULL, '경기도 고양시 일산서구', 'male', 'singer',
 '갑술', '계유', '무인', NULL, '갑술 계유 무인',
 2, 0, 2, 2, 2, '목',
 '{"year": {"stem": "갑", "branch": "술"}, "month": {"stem": "계", "branch": "유"}, "day": {"stem": "무", "branch": "인"}}',
 'manual_calculated'),

-- 블랙핑크 제니 (김제니, 1996-01-16)
('제니_1996-01-16', '블랙핑크 제니', '김제니', 'Jennie', '1996-01-16', NULL, '서울특별시 강남구', 'female', 'singer',
 '을해', '기축', '을사', NULL, '을해 기축 을사',
 1, 1, 2, 1, 3, '수',
 '{"year": {"stem": "을", "branch": "해"}, "month": {"stem": "기", "branch": "축"}, "day": {"stem": "을", "branch": "사"}}',
 'manual_calculated'),

-- 수지 (배수지, 1994-10-10, 10:10)
('수지_1994-10-10', '수지', '배수지', 'Suzy', '1994-10-10', '10:10', '광주광역시 북구', 'female', 'singer',
 '갑술', '갑술', '신미', '계사', '갑술 갑술 신미 계사',
 2, 1, 3, 1, 1, '토',
 '{"year": {"stem": "갑", "branch": "술"}, "month": {"stem": "갑", "branch": "술"}, "day": {"stem": "신", "branch": "미"}, "hour": {"stem": "계", "branch": "사"}}',
 'manual_calculated')

ON CONFLICT (id) DO UPDATE SET
    real_name = EXCLUDED.real_name,
    birth_place = EXCLUDED.birth_place,
    year_pillar = EXCLUDED.year_pillar,
    month_pillar = EXCLUDED.month_pillar,
    day_pillar = EXCLUDED.day_pillar,
    hour_pillar = EXCLUDED.hour_pillar,
    saju_string = EXCLUDED.saju_string,
    wood_count = EXCLUDED.wood_count,
    fire_count = EXCLUDED.fire_count,
    earth_count = EXCLUDED.earth_count,
    metal_count = EXCLUDED.metal_count,
    water_count = EXCLUDED.water_count,
    dominant_element = EXCLUDED.dominant_element,
    full_saju_data = EXCLUDED.full_saju_data,
    data_source = EXCLUDED.data_source,
    updated_at = NOW();

-- 데이터 확인
SELECT 
    name,
    real_name,
    birth_date,
    birth_place,
    saju_string,
    dominant_element,
    wood_count,
    fire_count,
    earth_count,
    metal_count,
    water_count
FROM public.celebrities
WHERE data_source = 'manual_calculated'
ORDER BY name;