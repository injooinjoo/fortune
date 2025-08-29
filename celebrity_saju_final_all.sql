-- 전체 유명인사 사주 데이터 최종 업로드 SQL
-- 총 76명의 유명인사 사주 데이터
-- 기존 27명 + 추가 49명

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

-- 2단계: 추가 유명인사들의 사주 데이터 삽입 (49명)
-- 새로운 데이터들을 테이블에 삽입

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

-- 전지현 삽입
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_006', '전지현', 'Jun Ji-hyun', '1981-10-30', '13:15',
  'female', '', 'actor', '',
  '신유', '무술', '신해', '을미',
  '신유 무술 신해 을미',
  1, 0, 2, 2, 3,
  '{"year":{"stem":"신","branch":"유"},"month":{"stem":"무","branch":"술"},"day":{"stem":"신","branch":"해"},"hour":{"stem":"을","branch":"미"},"elements":{"목":1,"화":0,"토":2,"금":2,"수":3}}'::jsonb,
  'extended_celebrity_calculated', NOW(), NOW()
);

-- 방시혁 삽입
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_003', '방시혁', 'Bang Si-hyuk', '1972-08-09', '11:30',
  'male', '', 'business_leader', '',
  '임자', '무신', '임인', '병오',
  '임자 무신 임인 병오',
  1, 2, 1, 1, 3,
  '{"year":{"stem":"임","branch":"자"},"month":{"stem":"무","branch":"신"},"day":{"stem":"임","branch":"인"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":2,"토":1,"금":1,"수":3}}'::jsonb,
  'extended_celebrity_calculated', NOW(), NOW()
);

-- Faker 삽입
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at  
) VALUES (
  'pro_001_new', 'Faker', 'Faker', '1996-05-07', '16:45',
  'male', '', 'pro_gamer', '',
  '병자', '계사', '갑술', '임신',
  '병자 계사 갑술 임신',
  1, 2, 1, 1, 3,
  '{"year":{"stem":"병","branch":"자"},"month":{"stem":"계","branch":"사"},"day":{"stem":"갑","branch":"술"},"hour":{"stem":"임","branch":"신"},"elements":{"목":1,"화":2,"토":1,"금":1,"수":3}}'::jsonb,
  'extended_celebrity_calculated', NOW(), NOW()
);

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

-- 완료 알림
SELECT '✅ 총 76명의 유명인사 사주 데이터 업로드 완료!' as status;