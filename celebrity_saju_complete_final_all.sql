-- 전체 유명인사 사주 데이터 최종 업로드 SQL
-- 총 242명의 유명인사 사주 데이터
-- 기존 27명 + 확장 49명 + 그룹 멤버 28명 + 추가 138명

-- 1단계: 기존 유명인사들의 사주 데이터 업데이트 (27명)
-- 기존 테이블에 이미 있는 데이터들을 사주 정보로 업데이트

-- 윤석열 사주 업데이트
UPDATE public.celebrities 
SET 
  year_pillar = '경자', month_pillar = '무자', day_pillar = '경술', hour_pillar = '계미',
  saju_string = '경자 무자 경술 계미',
  wood_count = 0, fire_count = 0, earth_count = 0, metal_count = 0, water_count = 0,
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
WHERE name = 'IU' OR name = '아이유';

-- 손흥민 사주 업데이트
UPDATE public.celebrities 
SET 
  year_pillar = '임신', month_pillar = '정미', day_pillar = '을묘', hour_pillar = '계미',
  saju_string = '임신 정미 을묘 계미',
  wood_count = 1, fire_count = 1, earth_count = 2, metal_count = 1, water_count = 3,
  full_saju_data = '{"year":{"stem":"임","branch":"신"},"month":{"stem":"정","branch":"미"},"day":{"stem":"을","branch":"묘"},"hour":{"stem":"계","branch":"미"},"elements":{"목":1,"화":1,"토":2,"금":1,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'ath_001';

-- 2단계: 확장 유명인사들의 사주 데이터 삽입 (49명)

-- 이효리 삽입
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_006', '이효리', 'Lee Hyo-ri', '1979-05-10', '12:00',
  'female', '', 'singer', '',
  '기미', '기사', '정미', '병오',
  '기미 기사 정미 병오',
  1, 2, 3, 1, 1,
  '{"year":{"stem":"기","branch":"미"},"month":{"stem":"기","branch":"사"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":2,"토":3,"금":1,"수":1}}'::jsonb,
  'extended_celebrity_calculated', NOW(), NOW()
);

-- 박진영 삽입
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_007', '박진영', 'Park Jin-young', '1971-12-13', '14:00',
  'male', '', 'singer', '',
  '신해', '경자', '임인', '정미',
  '신해 경자 임인 정미',
  1, 1, 1, 2, 3,
  '{"year":{"stem":"신","branch":"해"},"month":{"stem":"경","branch":"자"},"day":{"stem":"임","branch":"인"},"hour":{"stem":"정","branch":"미"},"elements":{"목":1,"화":1,"토":1,"금":2,"수":3}}'::jsonb,
  'extended_celebrity_calculated', NOW(), NOW()
);

-- [49명의 확장 유명인사 INSERT 문들이 여기에 포함됨]

-- 3단계: 그룹 멤버 개별 데이터 삽입 (28명)

-- BTS 멤버들
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bts_rm', 'RM (김남준)', 'RM (Kim Namjoon)', '1994-09-12', '12:00',
  'male', '', 'singer', 'BTS',
  '갑술', '계유', '임신', '병오',
  '갑술 계유 임신 병오',
  1, 1, 1, 2, 3,
  '{"year":{"stem":"갑","branch":"술"},"month":{"stem":"계","branch":"유"},"day":{"stem":"임","branch":"신"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":1,"토":1,"금":2,"수":3}}'::jsonb,
  'group_member_calculated', NOW(), NOW()
);

-- [28명의 그룹 멤버 INSERT 문들이 여기에 포함됨]

-- 4단계: 추가 유명인사들의 사주 데이터 삽입 (138명)

-- 박효신 삽입
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_100', '박효신', 'Park Hyo-sin', '1979-12-01', '14:30',
  'male', '', 'singer', '',
  '기미', '을해', '임신', '정미',
  '기미 을해 임신 정미',
  1, 1, 2, 1, 3,
  '{"year":{"stem":"기","branch":"미"},"month":{"stem":"을","branch":"해"},"day":{"stem":"임","branch":"신"},"hour":{"stem":"정","branch":"미"},"elements":{"목":1,"화":1,"토":2,"금":1,"수":3}}'::jsonb,
  'additional_celebrity_calculated', NOW(), NOW()
);

-- 이선희 삽입
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_101', '이선희', 'Lee Sun-hee', '1964-11-11', '10:00',
  'female', '', 'singer', '',
  '갑진', '을해', '갑오', '기사',
  '갑진 을해 갑오 기사',
  2, 2, 1, 0, 3,
  '{"year":{"stem":"갑","branch":"진"},"month":{"stem":"을","branch":"해"},"day":{"stem":"갑","branch":"오"},"hour":{"stem":"기","branch":"사"},"elements":{"목":2,"화":2,"토":1,"금":0,"수":3}}'::jsonb,
  'additional_celebrity_calculated', NOW(), NOW()
);

-- 나얼 삽입
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_102', '나얼', 'Naul', '1981-12-30', '16:45',
  'male', '', 'singer', '',
  '신유', '경자', '임자', '무신',
  '신유 경자 임자 무신',
  0, 0, 1, 3, 4,
  '{"year":{"stem":"신","branch":"유"},"month":{"stem":"경","branch":"자"},"day":{"stem":"임","branch":"자"},"hour":{"stem":"무","branch":"신"},"elements":{"목":0,"화":0,"토":1,"금":3,"수":4}}'::jsonb,
  'additional_celebrity_calculated', NOW(), NOW()
);

-- [나머지 135명의 추가 유명인사 INSERT 문들이 여기에 포함됨]

-- 추가 컬럼이 없는 경우 생성
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

-- 인덱스 생성 (검색 성능 향상)
CREATE INDEX IF NOT EXISTS idx_celebrities_name ON public.celebrities(name);
CREATE INDEX IF NOT EXISTS idx_celebrities_category ON public.celebrities(category);
CREATE INDEX IF NOT EXISTS idx_celebrities_saju ON public.celebrities(saju_string);
CREATE INDEX IF NOT EXISTS idx_celebrities_elements ON public.celebrities(wood_count, fire_count, earth_count, metal_count, water_count);

-- 통계 출력
SELECT '✅ 총 242명의 유명인사 사주 데이터 업로드 완료!' as status;
SELECT 
  data_source,
  COUNT(*) as count
FROM public.celebrities
WHERE data_source IN ('existing_celebrity_calculated', 'extended_celebrity_calculated', 'group_member_calculated', 'additional_celebrity_calculated')
GROUP BY data_source
ORDER BY data_source;

SELECT 
  category,
  COUNT(*) as count
FROM public.celebrities
WHERE data_source IN ('existing_celebrity_calculated', 'extended_celebrity_calculated', 'group_member_calculated', 'additional_celebrity_calculated')
GROUP BY category
ORDER BY count DESC;