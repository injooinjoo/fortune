-- Update celebrities with saju data (사주 정보 업데이트)
-- 기존 데이터에 사주 컬럼들을 추가/업데이트

-- 이효리 (기미 기사 정미 병오)
UPDATE public.celebrities 
SET 
  year_pillar = '기미',
  month_pillar = '기사', 
  day_pillar = '정미',
  hour_pillar = '병오',
  saju_string = '기미 기사 정미 병오',
  wood_count = 1,
  fire_count = 2,
  earth_count = 3,
  metal_count = 1,
  water_count = 1,
  dominant_element = '토',
  full_saju_data = '{"year":{"stem":"기","branch":"미"},"month":{"stem":"기","branch":"사"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":2,"토":3,"금":1,"수":1},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = '이효리';

-- IU (계유 계해 기해 정묘)  
UPDATE public.celebrities 
SET 
  year_pillar = '계유',
  month_pillar = '계해',
  day_pillar = '기해', 
  hour_pillar = '정묘',
  saju_string = '계유 계해 기해 정묘',
  wood_count = 1,
  fire_count = 1,
  earth_count = 1,
  metal_count = 1,
  water_count = 4,
  dominant_element = '수',
  full_saju_data = '{"year":{"stem":"계","branch":"유"},"month":{"stem":"계","branch":"해"},"day":{"stem":"기","branch":"해"},"hour":{"stem":"정","branch":"묘"},"elements":{"목":1,"화":1,"토":1,"금":1,"수":4},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = 'IU';

-- 손흥민 (임신 정미 정미 신해)
UPDATE public.celebrities 
SET 
  year_pillar = '임신',
  month_pillar = '정미',
  day_pillar = '정미',
  hour_pillar = '신해',
  saju_string = '임신 정미 정미 신해',
  wood_count = 0,
  fire_count = 2,
  earth_count = 2,
  metal_count = 2,
  water_count = 2,
  dominant_element = '화',
  full_saju_data = '{"year":{"stem":"임","branch":"신"},"month":{"stem":"정","branch":"미"},"day":{"stem":"정","branch":"미"},"hour":{"stem":"신","branch":"해"},"elements":{"목":0,"화":2,"토":2,"금":2,"수":2},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated', 
  updated_at = NOW()
WHERE name = '손흥민';

-- 유재석 (임자 정미 기축 을해)
UPDATE public.celebrities 
SET 
  year_pillar = '임자',
  month_pillar = '정미',
  day_pillar = '기축',
  hour_pillar = '을해', 
  saju_string = '임자 정미 기축 을해',
  wood_count = 1,
  fire_count = 1,
  earth_count = 3,
  metal_count = 0,
  water_count = 3,
  dominant_element = '토',
  full_saju_data = '{"year":{"stem":"임","branch":"자"},"month":{"stem":"정","branch":"미"},"day":{"stem":"기","branch":"축"},"hour":{"stem":"을","branch":"해"},"elements":{"목":1,"화":1,"토":3,"금":0,"수":3},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = '유재석';

-- 송중기 (을축 정해 기사 을해)
UPDATE public.celebrities 
SET 
  year_pillar = '을축',
  month_pillar = '정해',
  day_pillar = '기사',
  hour_pillar = '을해',
  saju_string = '을축 정해 기사 을해',
  wood_count = 2,
  fire_count = 2,
  earth_count = 2,
  metal_count = 0,
  water_count = 2,
  dominant_element = '목',
  full_saju_data = '{"year":{"stem":"을","branch":"축"},"month":{"stem":"정","branch":"해"},"day":{"stem":"기","branch":"사"},"hour":{"stem":"을","branch":"해"},"elements":{"목":2,"화":2,"토":2,"금":0,"수":2},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = '송중기';

-- G-Dragon (무진 경신 기축 을해)
UPDATE public.celebrities 
SET 
  year_pillar = '무진',
  month_pillar = '경신',
  day_pillar = '기축',
  hour_pillar = '을해',
  saju_string = '무진 경신 기축 을해',
  wood_count = 1,
  fire_count = 0,
  earth_count = 4,
  metal_count = 2,
  water_count = 1,
  dominant_element = '토',
  full_saju_data = '{"year":{"stem":"무","branch":"진"},"month":{"stem":"경","branch":"신"},"day":{"stem":"기","branch":"축"},"hour":{"stem":"을","branch":"해"},"elements":{"목":1,"화":0,"토":4,"금":2,"수":1},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = 'G-Dragon';

-- 박지성 (신유 경인 을유 정해)
UPDATE public.celebrities 
SET 
  year_pillar = '신유',
  month_pillar = '경인',
  day_pillar = '을유',
  hour_pillar = '정해',
  saju_string = '신유 경인 을유 정해',
  wood_count = 2,
  fire_count = 1,
  earth_count = 0,
  metal_count = 3,
  water_count = 2,
  dominant_element = '금',
  full_saju_data = '{"year":{"stem":"신","branch":"유"},"month":{"stem":"경","branch":"인"},"day":{"stem":"을","branch":"유"},"hour":{"stem":"정","branch":"해"},"elements":{"목":2,"화":1,"토":0,"금":3,"수":2},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = '박지성';

-- 윤석열 (경자 무자 갑오 을해)
UPDATE public.celebrities 
SET 
  year_pillar = '경자',
  month_pillar = '무자',
  day_pillar = '갑오',
  hour_pillar = '을해',
  saju_string = '경자 무자 갑오 을해',
  wood_count = 2,
  fire_count = 1,
  earth_count = 1,
  metal_count = 1,
  water_count = 3,
  dominant_element = '수',
  full_saju_data = '{"year":{"stem":"경","branch":"자"},"month":{"stem":"무","branch":"자"},"day":{"stem":"갑","branch":"오"},"hour":{"stem":"을","branch":"해"},"elements":{"목":2,"화":1,"토":1,"금":1,"수":3},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = '윤석열';

-- 이재용 (무신 갑오 정묘 신해)
UPDATE public.celebrities 
SET 
  year_pillar = '무신',
  month_pillar = '갑오', 
  day_pillar = '정묘',
  hour_pillar = '신해',
  saju_string = '무신 갑오 정묘 신해',
  wood_count = 2,
  fire_count = 2,
  earth_count = 1,
  metal_count = 2,
  water_count = 1,
  dominant_element = '목',
  full_saju_data = '{"year":{"stem":"무","branch":"신"},"month":{"stem":"갑","branch":"오"},"day":{"stem":"정","branch":"묘"},"hour":{"stem":"신","branch":"해"},"elements":{"목":2,"화":2,"토":1,"금":2,"수":1},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = '이재용';

-- 김연아 (경오 을유 계사 계해)
UPDATE public.celebrities 
SET 
  year_pillar = '경오',
  month_pillar = '을유',
  day_pillar = '계사',
  hour_pillar = '계해',
  saju_string = '경오 을유 계사 계해',
  wood_count = 1,
  fire_count = 2,
  earth_count = 0,
  metal_count = 2,
  water_count = 3,
  dominant_element = '수',
  full_saju_data = '{"year":{"stem":"경","branch":"오"},"month":{"stem":"을","branch":"유"},"day":{"stem":"계","branch":"사"},"hour":{"stem":"계","branch":"해"},"elements":{"목":1,"화":2,"토":0,"금":2,"수":3},"tenGods":{},"daeunInfo":{}}'::jsonb,
  data_source = 'namuwiki_saju_calculated',
  updated_at = NOW()
WHERE name = '김연아';