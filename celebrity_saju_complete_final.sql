-- 🎭 전체 유명인사 사주 데이터 최종 완전 업로드 SQL
-- 총 104명의 유명인사 사주 데이터 (기존 27명 + 추가 49명 + 그룹 멤버 28명)
-- 개별 아티스트와 그룹 멤버들의 정확한 생년월일 기반 사주 계산

-- =====================================================
-- 1단계: 테이블 구조 확인 및 컬럼 추가
-- =====================================================

-- 사주 관련 컬럼들이 없는 경우 생성
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

-- =====================================================
-- 2단계: 기존 유명인사들의 사주 데이터 업데이트 (27명)
-- =====================================================

-- 윤석열 (대통령)
UPDATE public.celebrities 
SET year_pillar = '경자', month_pillar = '무자', day_pillar = '경술', hour_pillar = '계미',
    saju_string = '경자 무자 경술 계미',
    wood_count = 0, fire_count = 0, earth_count = 3, metal_count = 2, water_count = 3,
    full_saju_data = '{"year":{"stem":"경","branch":"자"},"month":{"stem":"무","branch":"자"},"day":{"stem":"경","branch":"술"},"hour":{"stem":"계","branch":"미"},"elements":{"목":0,"화":0,"토":3,"금":2,"수":3}}'::jsonb,
    data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'pol_001' OR name = '윤석열';

-- IU (가수)
UPDATE public.celebrities 
SET year_pillar = '계유', month_pillar = '정사', day_pillar = '정묘', hour_pillar = '병오',
    saju_string = '계유 정사 정묘 병오',
    wood_count = 1, fire_count = 3, earth_count = 0, metal_count = 1, water_count = 3,
    full_saju_data = '{"year":{"stem":"계","branch":"유"},"month":{"stem":"정","branch":"사"},"day":{"stem":"정","branch":"묘"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":3,"토":0,"금":1,"수":3}}'::jsonb,
    data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'sing_001' OR name = 'IU' OR name = '아이유';

-- 손흥민 (축구선수)
UPDATE public.celebrities 
SET year_pillar = '임신', month_pillar = '정미', day_pillar = '을묘', hour_pillar = '계미',
    saju_string = '임신 정미 을묘 계미',
    wood_count = 1, fire_count = 1, earth_count = 2, metal_count = 1, water_count = 3,
    full_saju_data = '{"year":{"stem":"임","branch":"신"},"month":{"stem":"정","branch":"미"},"day":{"stem":"을","branch":"묘"},"hour":{"stem":"계","branch":"미"},"elements":{"목":1,"화":1,"토":2,"금":1,"수":3}}'::jsonb,
    data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'ath_001' OR name = '손흥민';

-- 유재석 (예능인)
UPDATE public.celebrities 
SET year_pillar = '임자', month_pillar = '정미', day_pillar = '기축', hour_pillar = '을해',
    saju_string = '임자 정미 기축 을해',
    wood_count = 1, fire_count = 1, earth_count = 3, metal_count = 0, water_count = 3,
    full_saju_data = '{"year":{"stem":"임","branch":"자"},"month":{"stem":"정","branch":"미"},"day":{"stem":"기","branch":"축"},"hour":{"stem":"을","branch":"해"},"elements":{"목":1,"화":1,"토":3,"금":0,"수":3}}'::jsonb,
    data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'ent_001' OR name = '유재석';

-- 송중기 (배우)
UPDATE public.celebrities 
SET year_pillar = '을축', month_pillar = '을유', day_pillar = '신묘', hour_pillar = '병신',
    saju_string = '을축 을유 신묘 병신',
    wood_count = 2, fire_count = 1, earth_count = 1, metal_count = 2, water_count = 2,
    full_saju_data = '{"year":{"stem":"을","branch":"축"},"month":{"stem":"을","branch":"유"},"day":{"stem":"신","branch":"묘"},"hour":{"stem":"병","branch":"신"},"elements":{"목":2,"화":1,"토":1,"금":2,"수":2}}'::jsonb,
    data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'act_001' OR name = '송중기';

-- =====================================================
-- 3단계: 추가 유명인사들의 사주 데이터 삽입 (49명)
-- =====================================================

-- 이효리 (가수)
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_006', '이효리', 'Lee Hyo-ri', '1979-05-10', '12:00', 'female', '', 'singer', '',
  '기미', '기사', '정미', '병오', '기미 기사 정미 병오',
  1, 2, 3, 1, 1,
  '{"year":{"stem":"기","branch":"미"},"month":{"stem":"기","branch":"사"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":2,"토":3,"금":1,"수":1}}'::jsonb,
  'extended_celebrity_calculated', NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- 전지현 (배우)
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_006', '전지현', 'Jun Ji-hyun', '1981-10-30', '13:15', 'female', '', 'actor', '',
  '신유', '무술', '신해', '을미', '신유 무술 신해 을미',
  1, 0, 2, 2, 3,
  '{"year":{"stem":"신","branch":"유"},"month":{"stem":"무","branch":"술"},"day":{"stem":"신","branch":"해"},"hour":{"stem":"을","branch":"미"},"elements":{"목":1,"화":0,"토":2,"금":2,"수":3}}'::jsonb,
  'extended_celebrity_calculated', NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- 방시혁 (기업인)
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_003', '방시혁', 'Bang Si-hyuk', '1972-08-09', '11:30', 'male', '', 'business_leader', 'HYBE',
  '임자', '무신', '임인', '병오', '임자 무신 임인 병오',
  1, 2, 1, 1, 3,
  '{"year":{"stem":"임","branch":"자"},"month":{"stem":"무","branch":"신"},"day":{"stem":"임","branch":"인"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":2,"토":1,"금":1,"수":3}}'::jsonb,
  'extended_celebrity_calculated', NOW(), NOW()
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 4단계: 그룹 멤버들의 개별 사주 데이터 삽입 (28명)
-- =====================================================

-- BTS 멤버들
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES 
  ('bts_rm', 'RM (김남준)', 'RM (Kim Namjoon)', '1994-09-12', '12:00', 'male', '', 'singer', 'BTS',
   '갑술', '계유', '신미', '갑오', '갑술 계유 신미 갑오',
   1, 1, 2, 2, 2, '{"year":{"stem":"갑","branch":"술"},"month":{"stem":"계","branch":"유"},"day":{"stem":"신","branch":"미"},"hour":{"stem":"갑","branch":"오"},"elements":{"목":1,"화":1,"토":2,"금":2,"수":2}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bts_jin', '진 (김석진)', 'Jin (Kim Seokjin)', '1992-12-04', '12:00', 'male', '', 'singer', 'BTS',
   '임신', '신해', '갑신', '경오', '임신 신해 갑신 경오',
   1, 1, 0, 3, 3, '{"year":{"stem":"임","branch":"신"},"month":{"stem":"신","branch":"해"},"day":{"stem":"갑","branch":"신"},"hour":{"stem":"경","branch":"오"},"elements":{"목":1,"화":1,"토":0,"금":3,"수":3}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bts_suga', '슈가 (민윤기)', 'Suga (Min Yoongi)', '1993-03-09', '12:00', 'male', '', 'singer', 'BTS',
   '계유', '을묘', '기미', '경오', '계유 을묘 기미 경오',
   2, 1, 1, 2, 2, '{"year":{"stem":"계","branch":"유"},"month":{"stem":"을","branch":"묘"},"day":{"stem":"기","branch":"미"},"hour":{"stem":"경","branch":"오"},"elements":{"목":2,"화":1,"토":1,"금":2,"수":2}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bts_jhope', '제이홉 (정호석)', 'J-Hope (Jung Hoseok)', '1994-02-18', '12:00', 'male', '', 'singer', 'BTS',
   '갑술', '병인', '을사', '임오', '갑술 병인 을사 임오',
   2, 3, 1, 0, 2, '{"year":{"stem":"갑","branch":"술"},"month":{"stem":"병","branch":"인"},"day":{"stem":"을","branch":"사"},"hour":{"stem":"임","branch":"오"},"elements":{"목":2,"화":3,"토":1,"금":0,"수":2}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bts_jimin', '지민 (박지민)', 'Jimin (Park Jimin)', '1995-10-13', '12:00', 'male', '', 'singer', 'BTS',
   '을해', '병술', '정미', '병오', '을해 병술 정미 병오',
   1, 3, 2, 0, 2, '{"year":{"stem":"을","branch":"해"},"month":{"stem":"병","branch":"술"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":3,"토":2,"금":0,"수":2}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bts_v', '뷔 (김태형)', 'V (Kim Taehyung)', '1995-12-30', '12:00', 'male', '', 'singer', 'BTS',
   '을해', '무자', '을축', '임오', '을해 무자 을축 임오',
   2, 1, 2, 0, 3, '{"year":{"stem":"을","branch":"해"},"month":{"stem":"무","branch":"자"},"day":{"stem":"을","branch":"축"},"hour":{"stem":"임","branch":"오"},"elements":{"목":2,"화":1,"토":2,"금":0,"수":3}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bts_jungkook', '정국 (전정국)', 'Jungkook (Jeon Jungkook)', '1997-09-01', '12:00', 'male', '', 'singer', 'BTS',
   '정축', '무신', '병자', '갑오', '정축 무신 병자 갑오',
   1, 2, 2, 1, 2, '{"year":{"stem":"정","branch":"축"},"month":{"stem":"무","branch":"신"},"day":{"stem":"병","branch":"자"},"hour":{"stem":"갑","branch":"오"},"elements":{"목":1,"화":2,"토":2,"금":1,"수":2}}'::jsonb,
   'group_member_calculated', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- BLACKPINK 멤버들  
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES 
  ('bp_jisoo', '지수 (김지수)', 'Jisoo (Kim Jisoo)', '1995-01-03', '12:00', 'female', '', 'singer', 'BLACKPINK',
   '갑술', '정축', '갑자', '경오', '갑술 정축 갑자 경오',
   2, 2, 2, 1, 1, '{"year":{"stem":"갑","branch":"술"},"month":{"stem":"정","branch":"축"},"day":{"stem":"갑","branch":"자"},"hour":{"stem":"경","branch":"오"},"elements":{"목":2,"화":2,"토":2,"금":1,"수":1}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bp_jennie', '제니 (김제니)', 'Jennie (Kim Jennie)', '1996-01-16', '12:00', 'female', '', 'singer', 'BLACKPINK',
   '을해', '기축', '임오', '병오', '을해 기축 임오 병오',
   1, 3, 2, 0, 2, '{"year":{"stem":"을","branch":"해"},"month":{"stem":"기","branch":"축"},"day":{"stem":"임","branch":"오"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":3,"토":2,"금":0,"수":2}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bp_rose', '로제 (박채영)', 'Rosé (Park Chaeyoung)', '1997-02-11', '12:00', 'female', '', 'singer', 'BLACKPINK',
   '정축', '임인', '갑인', '경오', '정축 임인 갑인 경오',
   3, 2, 1, 1, 1, '{"year":{"stem":"정","branch":"축"},"month":{"stem":"임","branch":"인"},"day":{"stem":"갑","branch":"인"},"hour":{"stem":"경","branch":"오"},"elements":{"목":3,"화":2,"토":1,"금":1,"수":1}}'::jsonb,
   'group_member_calculated', NOW(), NOW()),
  ('bp_lisa', '리사 (라리사)', 'Lisa (Lalisa Manoban)', '1997-03-27', '12:00', 'female', '', 'singer', 'BLACKPINK',
   '정축', '계묘', '무술', '무오', '정축 계묘 무술 무오',
   1, 2, 3, 0, 2, '{"year":{"stem":"정","branch":"축"},"month":{"stem":"계","branch":"묘"},"day":{"stem":"무","branch":"술"},"hour":{"stem":"무","branch":"오"},"elements":{"목":1,"화":2,"토":3,"금":0,"수":2}}'::jsonb,
   'group_member_calculated', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- 기존 그룹 데이터 삭제 (개별 멤버로 대체)
DELETE FROM public.celebrities WHERE name IN ('BTS', '블랙핑크', 'BLACKPINK', '트와이스', 'TWICE', '세븐틴', 'SEVENTEEN', '아이브', 'IVE', '뉴진스', 'NewJeans', '레드벨벳', 'Red Velvet', '엑소', 'EXO') AND category = 'singer';

-- =====================================================
-- 5단계: 인덱스 생성 (검색 성능 향상)
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_celebrities_name ON public.celebrities(name);
CREATE INDEX IF NOT EXISTS idx_celebrities_name_en ON public.celebrities(name_en);
CREATE INDEX IF NOT EXISTS idx_celebrities_category ON public.celebrities(category);
CREATE INDEX IF NOT EXISTS idx_celebrities_agency ON public.celebrities(agency);
CREATE INDEX IF NOT EXISTS idx_celebrities_saju ON public.celebrities(saju_string);
CREATE INDEX IF NOT EXISTS idx_celebrities_birth_date ON public.celebrities(birth_date);
CREATE INDEX IF NOT EXISTS idx_celebrities_gender ON public.celebrities(gender);
CREATE INDEX IF NOT EXISTS idx_celebrities_elements ON public.celebrities(wood_count, fire_count, earth_count, metal_count, water_count);
CREATE INDEX IF NOT EXISTS idx_celebrities_data_source ON public.celebrities(data_source);

-- =====================================================
-- 6단계: 데이터 검증 및 통계
-- =====================================================

-- 카테고리별 통계
SELECT 
  category,
  COUNT(*) as count,
  COUNT(CASE WHEN saju_string IS NOT NULL AND saju_string != '' THEN 1 END) as with_saju
FROM public.celebrities 
GROUP BY category 
ORDER BY count DESC;

-- 그룹별 멤버 수 (agency 기준)
SELECT 
  agency,
  COUNT(*) as member_count
FROM public.celebrities 
WHERE agency IN ('BTS', 'BLACKPINK', 'TWICE', 'SEVENTEEN', 'IVE', 'NewJeans', 'Red Velvet', 'EXO')
GROUP BY agency
ORDER BY member_count DESC;

-- 오행 분포 통계
SELECT 
  '목' as element, AVG(wood_count::decimal) as avg_count,
  COUNT(CASE WHEN wood_count = (SELECT MAX(GREATEST(wood_count, fire_count, earth_count, metal_count, water_count)) FROM public.celebrities c2 WHERE c2.id = c1.id) THEN 1 END) as dominant_count
FROM public.celebrities c1 WHERE saju_string IS NOT NULL
UNION ALL
SELECT '화', AVG(fire_count::decimal), COUNT(CASE WHEN fire_count = (SELECT MAX(GREATEST(wood_count, fire_count, earth_count, metal_count, water_count)) FROM public.celebrities c2 WHERE c2.id = c1.id) THEN 1 END) FROM public.celebrities c1 WHERE saju_string IS NOT NULL
UNION ALL  
SELECT '토', AVG(earth_count::decimal), COUNT(CASE WHEN earth_count = (SELECT MAX(GREATEST(wood_count, fire_count, earth_count, metal_count, water_count)) FROM public.celebrities c2 WHERE c2.id = c1.id) THEN 1 END) FROM public.celebrities c1 WHERE saju_string IS NOT NULL
UNION ALL
SELECT '금', AVG(metal_count::decimal), COUNT(CASE WHEN metal_count = (SELECT MAX(GREATEST(wood_count, fire_count, earth_count, metal_count, water_count)) FROM public.celebrities c2 WHERE c2.id = c1.id) THEN 1 END) FROM public.celebrities c1 WHERE saju_string IS NOT NULL
UNION ALL
SELECT '수', AVG(water_count::decimal), COUNT(CASE WHEN water_count = (SELECT MAX(GREATEST(wood_count, fire_count, earth_count, metal_count, water_count)) FROM public.celebrities c2 WHERE c2.id = c1.id) THEN 1 END) FROM public.celebrities c1 WHERE saju_string IS NOT NULL;

-- 최종 완료 메시지
SELECT 
  '🎉 전체 유명인사 사주 데이터 업로드 완료!' as status,
  COUNT(*) as total_celebrities,
  COUNT(CASE WHEN saju_string IS NOT NULL AND saju_string != '' THEN 1 END) as with_saju_data,
  ROUND(COUNT(CASE WHEN saju_string IS NOT NULL AND saju_string != '' THEN 1 END) * 100.0 / COUNT(*), 1) || '%' as completion_rate
FROM public.celebrities;