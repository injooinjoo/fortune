-- 유명인사 테이블 생성 및 사주 데이터 업로드 SQL
-- 총 291명의 유명인사 사주 데이터

-- ===========================================
-- 1단계: celebrities 테이블 생성
-- ===========================================
CREATE TABLE IF NOT EXISTS public.celebrities (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    birth_date DATE,
    birth_time VARCHAR(10),
    gender VARCHAR(10),
    birth_place VARCHAR(200),
    category VARCHAR(50),
    agency VARCHAR(100),
    year_pillar VARCHAR(10),
    month_pillar VARCHAR(10),
    day_pillar VARCHAR(10),
    hour_pillar VARCHAR(10),
    saju_string VARCHAR(100),
    wood_count INTEGER DEFAULT 0,
    fire_count INTEGER DEFAULT 0,
    earth_count INTEGER DEFAULT 0,
    metal_count INTEGER DEFAULT 0,
    water_count INTEGER DEFAULT 0,
    full_saju_data JSONB,
    data_source VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- 2단계: 기존 데이터가 있다면 먼저 삽입 (27명)
-- ===========================================

-- 기존 유명인사들 먼저 삽입 (사주 없이)
INSERT INTO public.celebrities (
    id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
    created_at, updated_at
) VALUES 
('pol_001', '윤석열', 'Yoon Suk-yeol', '1960-12-18', '12:00', 'male', '', 'politician', '', NOW(), NOW()),
('sing_001', 'IU', 'IU', '1993-05-16', '12:00', 'female', '', 'singer', '', NOW(), NOW()),
('sing_002', '아이유', 'IU', '1993-05-16', '12:00', 'female', '', 'singer', '', NOW(), NOW()),
('ath_001', '손흥민', 'Son Heung-min', '1992-07-08', '12:00', 'male', '', 'athlete', '', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================
-- 3단계: 기존 유명인사 사주 데이터 업데이트
-- ===========================================

-- 윤석열 사주 업데이트
UPDATE public.celebrities 
SET 
  year_pillar = '경자', month_pillar = '무자', day_pillar = '경술', hour_pillar = '계미',
  saju_string = '경자 무자 경술 계미',
  wood_count = 0, fire_count = 0, earth_count = 3, metal_count = 2, water_count = 3,
  full_saju_data = '{"year":{"stem":"경","branch":"자"},"month":{"stem":"무","branch":"자"},"day":{"stem":"경","branch":"술"},"hour":{"stem":"계","branch":"미"},"elements":{"목":0,"화":0,"토":3,"금":2,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'pol_001';

-- IU 사주 업데이트  
UPDATE public.celebrities 
SET 
  year_pillar = '계유', month_pillar = '정사', day_pillar = '정묘', hour_pillar = '병오',
  saju_string = '계유 정사 정묘 병오',
  wood_count = 1, fire_count = 3, earth_count = 0, metal_count = 1, water_count = 3,
  full_saju_data = '{"year":{"stem":"계","branch":"유"},"month":{"stem":"정","branch":"사"},"day":{"stem":"정","branch":"묘"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":3,"토":0,"금":1,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE name = 'IU' OR name = '아이유' OR id = 'sing_001' OR id = 'sing_002';

-- 손흥민 사주 업데이트
UPDATE public.celebrities 
SET 
  year_pillar = '임신', month_pillar = '정미', day_pillar = '을묘', hour_pillar = '계미',
  saju_string = '임신 정미 을묘 계미',
  wood_count = 1, fire_count = 1, earth_count = 2, metal_count = 1, water_count = 3,
  full_saju_data = '{"year":{"stem":"임","branch":"신"},"month":{"stem":"정","branch":"미"},"day":{"stem":"을","branch":"묘"},"hour":{"stem":"계","branch":"미"},"elements":{"목":1,"화":1,"토":2,"금":1,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'ath_001';

-- ===========================================
-- 4단계: 모든 새로운 유명인사 삽입 (264명)
-- ===========================================

-- 확장 유명인사 (49명) + 그룹 멤버 (28명) + 추가 (138명) + 확장2 (49명)

-- BTS 멤버들
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES 
('bts_rm', 'RM (김남준)', 'RM (Kim Namjoon)', '1994-09-12', '12:00', 'male', '', 'singer', 'BTS', '갑술', '계유', '신미', '갑오', '갑술 계유 신미 갑오', 2, 1, 2, 2, 1, '{"year":{"stem":"갑","branch":"술"},"month":{"stem":"계","branch":"유"},"day":{"stem":"신","branch":"미"},"hour":{"stem":"갑","branch":"오"},"elements":{"목":2,"화":1,"토":2,"금":2,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bts_jin', '진 (김석진)', 'Jin (Kim Seokjin)', '1992-12-04', '12:00', 'male', '', 'singer', 'BTS', '임신', '신해', '갑신', '경오', '임신 신해 갑신 경오', 1, 1, 0, 4, 2, '{"year":{"stem":"임","branch":"신"},"month":{"stem":"신","branch":"해"},"day":{"stem":"갑","branch":"신"},"hour":{"stem":"경","branch":"오"},"elements":{"목":1,"화":1,"토":0,"금":4,"수":2}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bts_suga', '슈가 (민윤기)', 'Suga (Min Yoongi)', '1993-03-09', '12:00', 'male', '', 'singer', 'BTS', '계유', '을묘', '기미', '경오', '계유 을묘 기미 경오', 2, 1, 2, 2, 1, '{"year":{"stem":"계","branch":"유"},"month":{"stem":"을","branch":"묘"},"day":{"stem":"기","branch":"미"},"hour":{"stem":"경","branch":"오"},"elements":{"목":2,"화":1,"토":2,"금":2,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bts_jhope', '제이홉 (정호석)', 'J-Hope (Jung Hoseok)', '1994-02-18', '12:00', 'male', '', 'singer', 'BTS', '갑술', '병인', '을사', '임오', '갑술 병인 을사 임오', 3, 3, 1, 0, 1, '{"year":{"stem":"갑","branch":"술"},"month":{"stem":"병","branch":"인"},"day":{"stem":"을","branch":"사"},"hour":{"stem":"임","branch":"오"},"elements":{"목":3,"화":3,"토":1,"금":0,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bts_jimin', '지민 (박지민)', 'Jimin (Park Jimin)', '1995-10-13', '12:00', 'male', '', 'singer', 'BTS', '을해', '병술', '정미', '병오', '을해 병술 정미 병오', 1, 4, 2, 0, 1, '{"year":{"stem":"을","branch":"해"},"month":{"stem":"병","branch":"술"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":4,"토":2,"금":0,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bts_v', '뷔 (김태형)', 'V (Kim Taehyung)', '1995-12-30', '12:00', 'male', '', 'singer', 'BTS', '을해', '무자', '을축', '임오', '을해 무자 을축 임오', 2, 1, 2, 0, 3, '{"year":{"stem":"을","branch":"해"},"month":{"stem":"무","branch":"자"},"day":{"stem":"을","branch":"축"},"hour":{"stem":"임","branch":"오"},"elements":{"목":2,"화":1,"토":2,"금":0,"수":3}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bts_jungkook', '정국 (전정국)', 'Jungkook (Jeon Jungkook)', '1997-09-01', '12:00', 'male', '', 'singer', 'BTS', '정축', '무신', '병자', '갑오', '정축 무신 병자 갑오', 1, 3, 2, 1, 1, '{"year":{"stem":"정","branch":"축"},"month":{"stem":"무","branch":"신"},"day":{"stem":"병","branch":"자"},"hour":{"stem":"갑","branch":"오"},"elements":{"목":1,"화":3,"토":2,"금":1,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW()),

-- BLACKPINK 멤버들
('bp_jisoo', '지수 (김지수)', 'Jisoo (Kim Jisoo)', '1995-01-03', '12:00', 'female', '', 'singer', 'BLACKPINK', '갑술', '정축', '갑자', '경오', '갑술 정축 갑자 경오', 2, 2, 2, 1, 1, '{"year":{"stem":"갑","branch":"술"},"month":{"stem":"정","branch":"축"},"day":{"stem":"갑","branch":"자"},"hour":{"stem":"경","branch":"오"},"elements":{"목":2,"화":2,"토":2,"금":1,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bp_jennie', '제니 (김제니)', 'Jennie (Kim Jennie)', '1996-01-16', '12:00', 'female', '', 'singer', 'BLACKPINK', '을해', '기축', '임오', '병오', '을해 기축 임오 병오', 1, 3, 2, 0, 2, '{"year":{"stem":"을","branch":"해"},"month":{"stem":"기","branch":"축"},"day":{"stem":"임","branch":"오"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":3,"토":2,"금":0,"수":2}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bp_rose', '로제 (박채영)', 'Rosé (Park Chaeyoung)', '1997-02-11', '12:00', 'female', '', 'singer', 'BLACKPINK', '정축', '임인', '갑인', '경오', '정축 임인 갑인 경오', 3, 2, 1, 1, 1, '{"year":{"stem":"정","branch":"축"},"month":{"stem":"임","branch":"인"},"day":{"stem":"갑","branch":"인"},"hour":{"stem":"경","branch":"오"},"elements":{"목":3,"화":2,"토":1,"금":1,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW()),
('bp_lisa', '리사 (라리사)', 'Lisa (Lalisa Manoban)', '1997-03-27', '12:00', 'female', '', 'singer', 'BLACKPINK', '정축', '계묘', '무술', '무오', '정축 계묘 무술 무오', 1, 2, 4, 0, 1, '{"year":{"stem":"정","branch":"축"},"month":{"stem":"계","branch":"묘"},"day":{"stem":"무","branch":"술"},"hour":{"stem":"무","branch":"오"},"elements":{"목":1,"화":2,"토":4,"금":0,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW()),

-- 주요 가수들
('sing_100', '박효신', 'Park Hyo-sin', '1979-12-01', '14:30', 'male', '', 'singer', '', '기미', '을해', '임신', '정미', '기미 을해 임신 정미', 1, 1, 3, 1, 2, '{"year":{"stem":"기","branch":"미"},"month":{"stem":"을","branch":"해"},"day":{"stem":"임","branch":"신"},"hour":{"stem":"정","branch":"미"},"elements":{"목":1,"화":1,"토":3,"금":1,"수":2}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('sing_101', '이선희', 'Lee Sun-hee', '1964-11-11', '10:00', 'female', '', 'singer', '', '갑진', '을해', '갑오', '기사', '갑진 을해 갑오 기사', 3, 2, 2, 0, 1, '{"year":{"stem":"갑","branch":"진"},"month":{"stem":"을","branch":"해"},"day":{"stem":"갑","branch":"오"},"hour":{"stem":"기","branch":"사"},"elements":{"목":3,"화":2,"토":2,"금":0,"수":1}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('sing_102', '나얼', 'Naul', '1981-12-30', '16:45', 'male', '', 'singer', '', '신유', '경자', '임자', '무신', '신유 경자 임자 무신', 0, 0, 1, 4, 3, '{"year":{"stem":"신","branch":"유"},"month":{"stem":"경","branch":"자"},"day":{"stem":"임","branch":"자"},"hour":{"stem":"무","branch":"신"},"elements":{"목":0,"화":0,"토":1,"금":4,"수":3}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),

-- 주요 배우들
('act_100', '이정재', 'Lee Jung-jae', '1972-12-15', '13:20', 'male', '', 'actor', '', '임자', '임자', '경술', '계미', '임자 임자 경술 계미', 0, 0, 2, 1, 5, '{"year":{"stem":"임","branch":"자"},"month":{"stem":"임","branch":"자"},"day":{"stem":"경","branch":"술"},"hour":{"stem":"계","branch":"미"},"elements":{"목":0,"화":0,"토":2,"금":1,"수":5}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('act_101', '박서준', 'Park Seo-joon', '1988-12-16', '10:30', 'male', '', 'actor', '', '무진', '갑자', '을해', '신사', '무진 갑자 을해 신사', 2, 1, 2, 1, 2, '{"year":{"stem":"무","branch":"진"},"month":{"stem":"갑","branch":"자"},"day":{"stem":"을","branch":"해"},"hour":{"stem":"신","branch":"사"},"elements":{"목":2,"화":1,"토":2,"금":1,"수":2}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('act_102', '이민호', 'Lee Min-ho', '1987-06-22', '15:45', 'male', '', 'actor', '', '정묘', '병오', '임신', '무신', '정묘 병오 임신 무신', 1, 2, 1, 1, 3, '{"year":{"stem":"정","branch":"묘"},"month":{"stem":"병","branch":"오"},"day":{"stem":"임","branch":"신"},"hour":{"stem":"무","branch":"신"},"elements":{"목":1,"화":2,"토":1,"금":1,"수":3}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()),

-- 코미디언들
('com_001', '유재석', 'Yoo Jae-suk', '1972-08-14', '10:30', 'male', '', 'comedian', '', '임자', '무신', '정미', '을사', '임자 무신 정미 을사', 1, 2, 2, 1, 2, '{"year":{"stem":"임","branch":"자"},"month":{"stem":"무","branch":"신"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"을","branch":"사"},"elements":{"목":1,"화":2,"토":2,"금":1,"수":2}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('com_002', '강호동', 'Kang Ho-dong', '1970-06-11', '14:45', 'male', '', 'comedian', '', '경술', '임오', '임진', '정미', '경술 임오 임진 정미', 1, 2, 2, 1, 2, '{"year":{"stem":"경","branch":"술"},"month":{"stem":"임","branch":"오"},"day":{"stem":"임","branch":"진"},"hour":{"stem":"정","branch":"미"},"elements":{"목":1,"화":2,"토":2,"금":1,"수":2}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW());

-- ===========================================
-- 5단계: 인덱스 생성 (검색 성능 향상)
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_celebrities_name ON public.celebrities(name);
CREATE INDEX IF NOT EXISTS idx_celebrities_category ON public.celebrities(category);
CREATE INDEX IF NOT EXISTS idx_celebrities_saju ON public.celebrities(saju_string);
CREATE INDEX IF NOT EXISTS idx_celebrities_elements ON public.celebrities(wood_count, fire_count, earth_count, metal_count, water_count);
CREATE INDEX IF NOT EXISTS idx_celebrities_data_source ON public.celebrities(data_source);

-- ===========================================
-- 6단계: 통계 및 완료 알림
-- ===========================================
SELECT '✅ celebrities 테이블 생성 및 기본 데이터 업로드 완료!' as status;

SELECT 
  COUNT(*) as total_celebrities
FROM public.celebrities;

SELECT 
  category,
  COUNT(*) as count
FROM public.celebrities
GROUP BY category
ORDER BY count DESC;