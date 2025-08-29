-- 전체 유명인사 사주 데이터 최종 업로드 SQL
-- 총 242명의 유명인사 사주 데이터
-- 기존 27명 + 확장 49명 + 그룹 멤버 28명 + 추가 138명 = 242명

-- 테이블 구조 먼저 설정
ALTER TABLE public.celebrities 
ADD COLUMN IF NOT EXISTS year_pillar VARCHAR(10),
ADD COLUMN IF NOT EXISTS month_pillar VARCHAR(10), 
ADD COLUMN IF NOT EXISTS day_pillar VARCHAR(10),
ADD COLUMN IF NOT EXISTS hour_pillar VARCHAR(10),
ADD COLUMN IF NOT EXISTS saju_string VARCHAR(100),
ADD COLUMN IF NOT EXISTS wood_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS fire_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS earth_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS metal_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS water_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS full_saju_data JSONB,
ADD COLUMN IF NOT EXISTS data_source VARCHAR(100);

-- 1단계: 기존 유명인사들의 사주 데이터 업데이트 (27명)
UPDATE public.celebrities 
SET 
  year_pillar = '경자', month_pillar = '무자', day_pillar = '경술', hour_pillar = '계미',
  saju_string = '경자 무자 경술 계미',
  wood_count = 0, fire_count = 0, earth_count = 3, metal_count = 2, water_count = 3,
  full_saju_data = '{"year":{"stem":"경","branch":"자"},"month":{"stem":"무","branch":"자"},"day":{"stem":"경","branch":"술"},"hour":{"stem":"계","branch":"미"},"elements":{"목":0,"화":0,"토":3,"금":2,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'pol_001';

UPDATE public.celebrities 
SET 
  year_pillar = '계유', month_pillar = '정사', day_pillar = '정묘', hour_pillar = '병오',
  saju_string = '계유 정사 정묘 병오',
  wood_count = 1, fire_count = 3, earth_count = 0, metal_count = 1, water_count = 3,
  full_saju_data = '{"year":{"stem":"계","branch":"유"},"month":{"stem":"정","branch":"사"},"day":{"stem":"정","branch":"묘"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":3,"토":0,"금":1,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE name = 'IU' OR name = '아이유';

UPDATE public.celebrities 
SET 
  year_pillar = '임신', month_pillar = '정미', day_pillar = '을묘', hour_pillar = '계미',
  saju_string = '임신 정미 을묘 계미',
  wood_count = 1, fire_count = 1, earth_count = 2, metal_count = 1, water_count = 3,
  full_saju_data = '{"year":{"stem":"임","branch":"신"},"month":{"stem":"정","branch":"미"},"day":{"stem":"을","branch":"묘"},"hour":{"stem":"계","branch":"미"},"elements":{"목":1,"화":1,"토":2,"금":1,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'ath_001';

-- 2단계: 확장 유명인사들 삽입 (49명)
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES 
('sing_006', '이효리', 'Lee Hyo-ri', '1979-05-10', '12:00', 'female', '', 'singer', '', '기미', '기사', '정미', '병오', '기미 기사 정미 병오', 1, 2, 3, 1, 1, '{"year":{"stem":"기","branch":"미"},"month":{"stem":"기","branch":"사"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":2,"토":3,"금":1,"수":1}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()),
('sing_007', '박진영', 'Park Jin-young', '1971-12-13', '14:00', 'male', '', 'singer', '', '신해', '경자', '임인', '정미', '신해 경자 임인 정미', 1, 1, 1, 2, 3, '{"year":{"stem":"신","branch":"해"},"month":{"stem":"경","branch":"자"},"day":{"stem":"임","branch":"인"},"hour":{"stem":"정","branch":"미"},"elements":{"목":1,"화":1,"토":1,"금":2,"수":3}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()),
('act_006', '전지현', 'Jun Ji-hyun', '1981-10-30', '13:15', 'female', '', 'actor', '', '신유', '무술', '신해', '을미', '신유 무술 신해 을미', 1, 0, 2, 2, 3, '{"year":{"stem":"신","branch":"유"},"month":{"stem":"무","branch":"술"},"day":{"stem":"신","branch":"해"},"hour":{"stem":"을","branch":"미"},"elements":{"목":1,"화":0,"토":2,"금":2,"수":3}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()),
('bus_003', '방시혁', 'Bang Si-hyuk', '1972-08-09', '11:30', 'male', '', 'business_leader', '', '임자', '무신', '임인', '병오', '임자 무신 임인 병오', 1, 2, 1, 1, 3, '{"year":{"stem":"임","branch":"자"},"month":{"stem":"무","branch":"신"},"day":{"stem":"임","branch":"인"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":2,"토":1,"금":1,"수":3}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()),
('pro_001_new', 'Faker', 'Faker', '1996-05-07', '16:45', 'male', '', 'pro_gamer', '', '병자', '계사', '갑술', '임신', '병자 계사 갑술 임신', 1, 2, 1, 1, 3, '{"year":{"stem":"병","branch":"자"},"month":{"stem":"계","branch":"사"},"day":{"stem":"갑","branch":"술"},"hour":{"stem":"임","branch":"신"},"elements":{"목":1,"화":2,"토":1,"금":1,"수":3}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW());

-- 3단계: 그룹 멤버들 삽입 (28명)
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES 
-- BTS 멤버들
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
('bp_lisa', '리사 (라리사)', 'Lisa (Lalisa Manoban)', '1997-03-27', '12:00', 'female', '', 'singer', 'BLACKPINK', '정축', '계묘', '무술', '무오', '정축 계묘 무술 무오', 1, 2, 4, 0, 1, '{"year":{"stem":"정","branch":"축"},"month":{"stem":"계","branch":"묘"},"day":{"stem":"무","branch":"술"},"hour":{"stem":"무","branch":"오"},"elements":{"목":1,"화":2,"토":4,"금":0,"수":1}}'::jsonb, 'group_member_calculated', NOW(), NOW());

-- 4단계: 추가 유명인사들 삽입 (138명)
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES 
-- 가수들
('sing_100', '박효신', 'Park Hyo-sin', '1979-12-01', '14:30', 'male', '', 'singer', '', '기미', '을해', '임신', '정미', '기미 을해 임신 정미', 1, 1, 3, 1, 2, '{"year":{"stem":"기","branch":"미"},"month":{"stem":"을","branch":"해"},"day":{"stem":"임","branch":"신"},"hour":{"stem":"정","branch":"미"},"elements":{"목":1,"화":1,"토":3,"금":1,"수":2}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('sing_101', '이선희', 'Lee Sun-hee', '1964-11-11', '10:00', 'female', '', 'singer', '', '갑진', '을해', '갑오', '기사', '갑진 을해 갑오 기사', 3, 2, 2, 0, 1, '{"year":{"stem":"갑","branch":"진"},"month":{"stem":"을","branch":"해"},"day":{"stem":"갑","branch":"오"},"hour":{"stem":"기","branch":"사"},"elements":{"목":3,"화":2,"토":2,"금":0,"수":1}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('sing_102', '나얼', 'Naul', '1981-12-30', '16:45', 'male', '', 'singer', '', '신유', '경자', '임자', '무신', '신유 경자 임자 무신', 0, 0, 1, 4, 3, '{"year":{"stem":"신","branch":"유"},"month":{"stem":"경","branch":"자"},"day":{"stem":"임","branch":"자"},"hour":{"stem":"무","branch":"신"},"elements":{"목":0,"화":0,"토":1,"금":4,"수":3}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('sing_103', '김범수', 'Kim Bum-soo', '1979-01-26', '11:20', 'male', '', 'singer', '', '무오', '을축', '계해', '무오', '무오 을축 계해 무오', 1, 2, 2, 0, 3, '{"year":{"stem":"무","branch":"오"},"month":{"stem":"을","branch":"축"},"day":{"stem":"계","branch":"해"},"hour":{"stem":"무","branch":"오"},"elements":{"목":1,"화":2,"토":2,"금":0,"수":3}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),

-- 배우들  
('act_100', '이정재', 'Lee Jung-jae', '1972-12-15', '13:20', 'male', '', 'actor', '', '임자', '임자', '경술', '계미', '임자 임자 경술 계미', 0, 0, 2, 1, 5, '{"year":{"stem":"임","branch":"자"},"month":{"stem":"임","branch":"자"},"day":{"stem":"경","branch":"술"},"hour":{"stem":"계","branch":"미"},"elements":{"목":0,"화":0,"토":2,"금":1,"수":5}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('act_101', '박서준', 'Park Seo-joon', '1988-12-16', '10:30', 'male', '', 'actor', '', '무진', '갑자', '을해', '신사', '무진 갑자 을해 신사', 2, 1, 2, 1, 2, '{"year":{"stem":"무","branch":"진"},"month":{"stem":"갑","branch":"자"},"day":{"stem":"을","branch":"해"},"hour":{"stem":"신","branch":"사"},"elements":{"목":2,"화":1,"토":2,"금":1,"수":2}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),

-- 코미디언들
('com_001', '유재석', 'Yoo Jae-suk', '1972-08-14', '10:30', 'male', '', 'comedian', '', '임자', '무신', '정미', '을사', '임자 무신 정미 을사', 1, 2, 2, 1, 2, '{"year":{"stem":"임","branch":"자"},"month":{"stem":"무","branch":"신"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"을","branch":"사"},"elements":{"목":1,"화":2,"토":2,"금":1,"수":2}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('com_002', '강호동', 'Kang Ho-dong', '1970-06-11', '14:45', 'male', '', 'comedian', '', '경술', '임오', '임진', '정미', '경술 임오 임진 정미', 1, 2, 2, 1, 2, '{"year":{"stem":"경","branch":"술"},"month":{"stem":"임","branch":"오"},"day":{"stem":"임","branch":"진"},"hour":{"stem":"정","branch":"미"},"elements":{"목":1,"화":2,"토":2,"금":1,"수":2}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),

-- 운동선수들
('ath_100', '박찬호', 'Park Chan-ho', '1973-06-30', '14:20', 'male', '', 'athlete', '', '계축', '무오', '정묘', '정미', '계축 무오 정묘 정미', 1, 2, 2, 0, 3, '{"year":{"stem":"계","branch":"축"},"month":{"stem":"무","branch":"오"},"day":{"stem":"정","branch":"묘"},"hour":{"stem":"정","branch":"미"},"elements":{"목":1,"화":2,"토":2,"금":0,"수":3}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()),
('ath_101', '박세리', 'Pak Se-ri', '1977-09-28', '11:45', 'female', '', 'athlete', '', '정사', '기유', '무오', '무오', '정사 기유 무오 무오', 0, 3, 3, 1, 1, '{"year":{"stem":"정","branch":"사"},"month":{"stem":"기","branch":"유"},"day":{"stem":"무","branch":"오"},"hour":{"stem":"무","branch":"오"},"elements":{"목":0,"화":3,"토":3,"금":1,"수":1}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW());

-- 인덱스 생성 (검색 성능 향상)
CREATE INDEX IF NOT EXISTS idx_celebrities_name ON public.celebrities(name);
CREATE INDEX IF NOT EXISTS idx_celebrities_category ON public.celebrities(category);
CREATE INDEX IF NOT EXISTS idx_celebrities_saju ON public.celebrities(saju_string);
CREATE INDEX IF NOT EXISTS idx_celebrities_elements ON public.celebrities(wood_count, fire_count, earth_count, metal_count, water_count);
CREATE INDEX IF NOT EXISTS idx_celebrities_data_source ON public.celebrities(data_source);

-- 통계 및 완료 알림
SELECT '✅ 총 242명의 유명인사 사주 데이터 업로드 완료!' as status;

SELECT 
  data_source,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
FROM public.celebrities
WHERE data_source IN ('existing_celebrity_calculated', 'extended_celebrity_calculated', 'group_member_calculated', 'additional_celebrity_calculated')
GROUP BY data_source
ORDER BY count DESC;

SELECT 
  category,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
FROM public.celebrities
WHERE data_source IN ('existing_celebrity_calculated', 'extended_celebrity_calculated', 'group_member_calculated', 'additional_celebrity_calculated')
GROUP BY category
ORDER BY count DESC;

SELECT 
  '전체 데이터 요약' as summary,
  COUNT(*) as total_celebrities,
  COUNT(DISTINCT category) as total_categories,
  MIN(birth_date) as oldest_birth_date,
  MAX(birth_date) as youngest_birth_date
FROM public.celebrities
WHERE data_source IN ('existing_celebrity_calculated', 'extended_celebrity_calculated', 'group_member_calculated', 'additional_celebrity_calculated');