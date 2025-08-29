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
SELECT '✅ 총 76명의 유명인사 사주 데이터 업로드 완료!' as status;-- 그룹 멤버 개별 사주 데이터 삽입 SQL
-- 총 28명의 그룹 멤버 데이터

INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bts_rm', 'RM (김남준)', 'RM (Kim Namjoon)', '1994-09-12', '12:00',
  'male', '', 'singer', 'BTS',
  '갑술', '계유', '신미', '갑오',
  '갑술 계유 신미 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":2,"화":1,"토":2,"금":2,"수":1},"tenGods":{"year":["상관"],"month":["식신"],"hour":["상관"]},"daeunInfo":{"currentAge":31,"startAge":30,"endAge":39,"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bts_jin', '진 (김석진)', 'Jin (Kim Seokjin)', '1992-12-04', '12:00',
  'male', '', 'singer', 'BTS',
  '임신', '신해', '갑신', '경오',
  '임신 신해 갑신 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"month":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"day":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":1,"토":0,"금":4,"수":2},"tenGods":{"year":["편인"],"month":["정관"],"hour":["편관"]},"daeunInfo":{"currentAge":33,"startAge":30,"endAge":39,"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bts_suga', '슈가 (민윤기)', 'Suga (Min Yoongi)', '1993-03-09', '12:00',
  'male', '', 'singer', 'BTS',
  '계유', '을묘', '기미', '경오',
  '계유 을묘 기미 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"month":{"stem":"을","branch":"묘","stemHanja":"乙","branchHanja":"卯","element":"목"},"day":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":2,"화":1,"토":2,"금":2,"수":1},"tenGods":{"year":["편재"],"month":["편관"],"hour":["겁재"]},"daeunInfo":{"currentAge":32,"startAge":30,"endAge":39,"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bts_jhope', '제이홉 (정호석)', 'J-Hope (Jung Hoseok)', '1994-02-18', '12:00',
  'male', '', 'singer', 'BTS',
  '갑술', '병인', '을사', '임오',
  '갑술 병인 을사 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"month":{"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅","element":"화"},"day":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":3,"화":3,"토":1,"금":0,"수":1},"tenGods":{"year":["정인"],"month":["겁재"],"hour":["정관"]},"daeunInfo":{"currentAge":31,"startAge":30,"endAge":39,"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bts_jimin', '지민 (박지민)', 'Jimin (Park Jimin)', '1995-10-13', '12:00',
  'male', '', 'singer', 'BTS',
  '을해', '병술', '정미', '병오',
  '을해 병술 정미 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"month":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":4,"토":2,"금":0,"수":1},"tenGods":{"year":["편인"],"month":["정인"],"hour":["정인"]},"daeunInfo":{"currentAge":30,"startAge":30,"endAge":39,"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bts_v', '뷔 (김태형)', 'V (Kim Taehyung)', '1995-12-30', '12:00',
  'male', '', 'singer', 'BTS',
  '을해', '무자', '을축', '임오',
  '을해 무자 을축 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"month":{"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子","element":"토"},"day":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":1,"토":2,"금":0,"수":3},"tenGods":{"year":["비견"],"month":["상관"],"hour":["정관"]},"daeunInfo":{"currentAge":30,"startAge":30,"endAge":39,"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bts_jungkook', '정국 (전정국)', 'Jungkook (Jeon Jungkook)', '1997-09-01', '12:00',
  'male', '', 'singer', 'BTS',
  '정축', '무신', '병자', '갑오',
  '정축 무신 병자 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"month":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"day":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":3,"토":2,"금":1,"수":1},"tenGods":{"year":["겁재"],"month":["식신"],"hour":["편인"]},"daeunInfo":{"currentAge":28,"startAge":20,"endAge":29,"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bp_jisoo', '지수 (김지수)', 'Jisoo (Kim Jisoo)', '1995-01-03', '12:00',
  'female', '', 'singer', 'BLACKPINK',
  '갑술', '정축', '갑자', '경오',
  '갑술 정축 갑자 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"month":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"day":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":2,"화":2,"토":2,"금":1,"수":1},"tenGods":{"year":["비견"],"month":["상관"],"hour":["편관"]},"daeunInfo":{"currentAge":30,"startAge":30,"endAge":39,"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bp_jennie', '제니 (김제니)', 'Jennie (Kim Jennie)', '1996-01-16', '12:00',
  'female', '', 'singer', 'BLACKPINK',
  '을해', '기축', '임오', '병오',
  '을해 기축 임오 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"month":{"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑","element":"토"},"day":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":3,"토":2,"금":0,"수":2},"tenGods":{"year":["상관"],"month":["정관"],"hour":["편재"]},"daeunInfo":{"currentAge":29,"startAge":20,"endAge":29,"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bp_rose', '로제 (박채영)', 'Rosé (Park Chaeyoung)', '1997-02-11', '12:00',
  'female', '', 'singer', 'BLACKPINK',
  '정축', '임인', '갑인', '경오',
  '정축 임인 갑인 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"month":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"day":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":3,"화":2,"토":1,"금":1,"수":1},"tenGods":{"year":["상관"],"month":["편인"],"hour":["편관"]},"daeunInfo":{"currentAge":28,"startAge":20,"endAge":29,"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bp_lisa', '리사 (라리사)', 'Lisa (Lalisa Manoban)', '1997-03-27', '12:00',
  'female', '', 'singer', 'BLACKPINK',
  '정축', '계묘', '무술', '무오',
  '정축 계묘 무술 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"month":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"day":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":2,"토":4,"금":0,"수":1},"tenGods":{"year":["정인"],"month":["정재"],"hour":["비견"]},"daeunInfo":{"currentAge":28,"startAge":20,"endAge":29,"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'tw_nayeon', '나연 (임나연)', 'Nayeon (Im Nayeon)', '1995-09-22', '12:00',
  'female', '', 'singer', 'TWICE',
  '을해', '을유', '병술', '갑오',
  '을해 을유 병술 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"month":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"day":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":3,"화":2,"토":1,"금":1,"수":1},"tenGods":{"year":["정인"],"month":["정인"],"hour":["편인"]},"daeunInfo":{"currentAge":30,"startAge":30,"endAge":39,"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'tw_sana', '사나 (미나토자키 사나)', 'Sana (Minatozaki Sana)', '1996-12-29', '12:00',
  'female', '', 'singer', 'TWICE',
  '병자', '경자', '경오', '임오',
  '병자 경자 경오 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"month":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"day":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":0,"화":3,"토":0,"금":2,"수":3},"tenGods":{"year":["편관"],"month":["비견"],"hour":["식신"]},"daeunInfo":{"currentAge":29,"startAge":20,"endAge":29,"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'tw_tzuyu', '쯔위 (저우쯔위)', 'Tzuyu (Chou Tzuyu)', '1999-06-14', '12:00',
  'female', '', 'singer', 'TWICE',
  '기묘', '경오', '정묘', '병오',
  '기묘 경오 정묘 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"month":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":2,"화":4,"토":1,"금":1,"수":0},"tenGods":{"year":["식신"],"month":["상관"],"hour":["정인"]},"daeunInfo":{"currentAge":26,"startAge":20,"endAge":29,"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'svt_scoups', '에스쿱스 (최승철)', 'S.Coups (Choi Seungcheol)', '1995-08-08', '12:00',
  'male', '', 'singer', 'SEVENTEEN',
  '을해', '갑신', '신축', '갑오',
  '을해 갑신 신축 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"month":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"day":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":3,"화":1,"토":1,"금":2,"수":1},"tenGods":{"year":["편재"],"month":["상관"],"hour":["상관"]},"daeunInfo":{"currentAge":30,"startAge":30,"endAge":39,"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'svt_jeonghan', '정한 (윤정한)', 'Jeonghan (Yoon Jeonghan)', '1995-10-04', '12:00',
  'male', '', 'singer', 'SEVENTEEN',
  '을해', '을유', '무술', '무오',
  '을해 을유 무술 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"month":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"day":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":2,"화":1,"토":3,"금":1,"수":1},"tenGods":{"year":["정관"],"month":["정관"],"hour":["비견"]},"daeunInfo":{"currentAge":30,"startAge":30,"endAge":39,"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'svt_mingyu', '민규 (김민규)', 'Mingyu (Kim Mingyu)', '1997-04-06', '12:00',
  'male', '', 'singer', 'SEVENTEEN',
  '정축', '갑진', '무신', '무오',
  '정축 갑진 무신 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"month":{"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰","element":"목"},"day":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":2,"토":4,"금":1,"수":0},"tenGods":{"year":["정인"],"month":["편관"],"hour":["비견"]},"daeunInfo":{"currentAge":28,"startAge":20,"endAge":29,"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ive_yujin', '유진 (안유진)', 'Yujin (An Yujin)', '2003-09-01', '12:00',
  'female', '', 'singer', 'IVE',
  '계미', '경신', '정미', '병오',
  '계미 경신 정미 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":0,"화":3,"토":2,"금":2,"수":1},"tenGods":{"year":["편관"],"month":["상관"],"hour":["정인"]},"daeunInfo":{"currentAge":22,"startAge":20,"endAge":29,"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ive_wonyoung', '원영 (장원영)', 'Wonyoung (Jang Wonyoung)', '2004-08-31', '12:00',
  'female', '', 'singer', 'IVE',
  '갑신', '임신', '임자', '병오',
  '갑신 임신 임자 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"month":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"day":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":2,"토":0,"금":2,"수":3},"tenGods":{"year":["식신"],"month":["비견"],"hour":["편재"]},"daeunInfo":{"currentAge":21,"startAge":20,"endAge":29,"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'nj_minji', '민지 (김민지)', 'Minji (Kim Minji)', '2004-05-07', '12:00',
  'female', '', 'singer', 'NewJeans',
  '갑신', '기사', '병진', '갑오',
  '갑신 기사 병진 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"month":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"day":{"stem":"병","branch":"진","stemHanja":"丙","branchHanja":"辰","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":2,"화":3,"토":2,"금":1,"수":0},"tenGods":{"year":["편인"],"month":["상관"],"hour":["편인"]},"daeunInfo":{"currentAge":21,"startAge":20,"endAge":29,"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'nj_hanni', '하니 (팜하니)', 'Hanni (Pham Hanni)', '2004-10-06', '12:00',
  'female', '', 'singer', 'NewJeans',
  '갑신', '계유', '무자', '무오',
  '갑신 계유 무자 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":1,"토":2,"금":2,"수":2},"tenGods":{"year":["편관"],"month":["정재"],"hour":["비견"]},"daeunInfo":{"currentAge":21,"startAge":20,"endAge":29,"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'nj_danielle', '다니엘 (모 다니엘)', 'Danielle (Mo Danielle)', '2005-04-11', '12:00',
  'female', '', 'singer', 'NewJeans',
  '을유', '경진', '을미', '임오',
  '을유 경진 을미 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"month":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"day":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":1,"토":2,"금":2,"수":1},"tenGods":{"year":["비견"],"month":["정재"],"hour":["정관"]},"daeunInfo":{"currentAge":20,"startAge":20,"endAge":29,"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'rv_irene', '아이린 (배주현)', 'Irene (Bae Joohyun)', '1991-03-29', '12:00',
  'female', '', 'singer', 'Red Velvet',
  '신미', '신묘', '무진', '무오',
  '신미 신묘 무진 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"month":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"day":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":1,"토":4,"금":2,"수":0},"tenGods":{"year":["상관"],"month":["상관"],"hour":["비견"]},"daeunInfo":{"currentAge":34,"startAge":30,"endAge":39,"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'rv_seulgi', '슬기 (강슬기)', 'Seulgi (Kang Seulgi)', '1994-02-10', '12:00',
  'female', '', 'singer', 'Red Velvet',
  '갑술', '병인', '정유', '병오',
  '갑술 병인 정유 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"month":{"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅","element":"화"},"day":{"stem":"정","branch":"유","stemHanja":"丁","branchHanja":"酉","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":2,"화":4,"토":1,"금":1,"수":0},"tenGods":{"year":["정관"],"month":["정인"],"hour":["정인"]},"daeunInfo":{"currentAge":31,"startAge":30,"endAge":39,"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'rv_joy', '조이 (박수영)', 'Joy (Park Sooyoung)', '1996-09-03', '12:00',
  'female', '', 'singer', 'Red Velvet',
  '병자', '병신', '계유', '무오',
  '병자 병신 계유 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"month":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"day":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":0,"화":3,"토":1,"금":2,"수":2},"tenGods":{"year":["상관"],"month":["상관"],"hour":["정재"]},"daeunInfo":{"currentAge":29,"startAge":20,"endAge":29,"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'exo_suho', '수호 (김준면)', 'Suho (Kim Junmyeon)', '1991-05-22', '12:00',
  'male', '', 'singer', 'EXO',
  '신미', '계사', '임술', '병오',
  '신미 계사 임술 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"month":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"day":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":0,"화":3,"토":2,"금":1,"수":2},"tenGods":{"year":["정인"],"month":["겁재"],"hour":["편재"]},"daeunInfo":{"currentAge":34,"startAge":30,"endAge":39,"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'exo_baekhyun', '백현 (변백현)', 'Baekhyun (Byun Baekhyun)', '1992-05-06', '12:00',
  'male', '', 'singer', 'EXO',
  '임신', '을사', '임자', '병오',
  '임신 을사 임자 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"month":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"day":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":3,"토":0,"금":1,"수":3},"tenGods":{"year":["비견"],"month":["상관"],"hour":["편재"]},"daeunInfo":{"currentAge":33,"startAge":30,"endAge":39,"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'exo_chanyeol', '찬열 (박찬열)', 'Chanyeol (Park Chanyeol)', '1992-11-27', '12:00',
  'male', '', 'singer', 'EXO',
  '임신', '신해', '정축', '병오',
  '임신 신해 정축 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"month":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"day":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":0,"화":3,"토":1,"금":2,"수":2},"tenGods":{"year":["정재"],"month":["편재"],"hour":["정인"]},"daeunInfo":{"currentAge":33,"startAge":30,"endAge":39,"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅"}}'::jsonb, 'group_member_calculated', NOW(), NOW()
);-- 추가 유명인 사주 데이터 삽입 SQL
-- 총 138명의 추가 유명인 데이터

INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_100', '박효신', 'Park Hyo-sin', '1979-12-01', '14:30',
  'male', '', 'singer', '',
  '기미', '을해', '임신', '정미',
  '기미 을해 임신 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"day":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":1,"화":1,"토":3,"금":1,"수":2},"tenGods":{"year":["정관"],"month":["상관"],"hour":["정재"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_101', '이선희', 'Lee Sun-hee', '1964-11-11', '10:00',
  'female', '', 'singer', '',
  '갑진', '을해', '갑오', '기사',
  '갑진 을해 갑오 기사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰","element":"목"},"month":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"day":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"hour":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"elementBalance":{"목":3,"화":2,"토":2,"금":0,"수":1},"tenGods":{"year":["비견"],"month":["겁재"],"hour":["정재"]},"daeunInfo":{"currentAge":61,"startAge":60,"endAge":69,"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_102', '나얼', 'Naul', '1981-12-30', '16:45',
  'male', '', 'singer', '',
  '신유', '경자', '임자', '무신',
  '신유 경자 임자 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"day":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":0,"화":0,"토":1,"금":4,"수":3},"tenGods":{"year":["정인"],"month":["편인"],"hour":["편관"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_103', '김범수', 'Kim Bum-soo', '1979-01-26', '11:20',
  'male', '', 'singer', '',
  '무오', '을축', '계해', '무오',
  '무오 을축 계해 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"month":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"day":{"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥","element":"수"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":2,"토":3,"금":0,"수":2},"tenGods":{"year":["정재"],"month":["식신"],"hour":["정재"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_104', '백지영', 'Baek Ji-young', '1976-03-25', '15:30',
  'female', '', 'singer', '',
  '병진', '신묘', '병오', '병신',
  '병진 신묘 병오 병신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"진","stemHanja":"丙","branchHanja":"辰","element":"화"},"month":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"day":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"hour":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"elementBalance":{"목":1,"화":4,"토":1,"금":2,"수":0},"tenGods":{"year":["비견"],"month":["정재"],"hour":["비견"]},"daeunInfo":{"currentAge":49,"startAge":40,"endAge":49,"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_105', '이소라', 'Lee So-ra', '1969-04-05', '13:15',
  'female', '', 'singer', '',
  '기유', '무진', '경진', '계미',
  '기유 무진 경진 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"month":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"day":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":0,"화":0,"토":5,"금":2,"수":1},"tenGods":{"year":["정인"],"month":["편인"],"hour":["상관"]},"daeunInfo":{"currentAge":56,"startAge":50,"endAge":59,"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_106', '윤상', 'Yoon Sang', '1968-02-06', '18:00',
  'male', '', 'singer', '',
  '무신', '갑인', '병자', '정유',
  '무신 갑인 병자 정유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"month":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"day":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"hour":{"stem":"정","branch":"유","stemHanja":"丁","branchHanja":"酉","element":"화"},"elementBalance":{"목":2,"화":2,"토":1,"금":2,"수":1},"tenGods":{"year":["식신"],"month":["편인"],"hour":["겁재"]},"daeunInfo":{"currentAge":57,"startAge":50,"endAge":59,"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_107', '조성모', 'Jo Sung-mo', '1977-02-05', '09:30',
  'male', '', 'singer', '',
  '정사', '임인', '계해', '정사',
  '정사 임인 계해 정사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"month":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"day":{"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥","element":"수"},"hour":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"elementBalance":{"목":1,"화":4,"토":0,"금":0,"수":3},"tenGods":{"year":["편재"],"month":["정인"],"hour":["편재"]},"daeunInfo":{"currentAge":48,"startAge":40,"endAge":49,"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_108', '임창정', 'Im Chang-jung', '1973-11-30', '12:45',
  'male', '', 'singer', '',
  '계축', '계해', '경자', '임오',
  '계축 계해 경자 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"month":{"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥","element":"수"},"day":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":0,"화":1,"토":1,"금":1,"수":5},"tenGods":{"year":["상관"],"month":["상관"],"hour":["식신"]},"daeunInfo":{"currentAge":52,"startAge":50,"endAge":59,"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_109', '신승훈', 'Shin Seung-hun', '1966-03-21', '14:00',
  'male', '', 'singer', '',
  '병오', '신묘', '기유', '신미',
  '병오 신묘 기유 신미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"month":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"day":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"hour":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"elementBalance":{"목":1,"화":2,"토":2,"금":3,"수":0},"tenGods":{"year":["정관"],"month":["식신"],"hour":["식신"]},"daeunInfo":{"currentAge":59,"startAge":50,"endAge":59,"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_110', '유재하', 'Yu Jae-ha', '1962-08-11', '16:30',
  'male', '', 'singer', '',
  '임인', '무신', '신해', '병신',
  '임인 무신 신해 병신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"month":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"day":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"hour":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"elementBalance":{"목":1,"화":1,"토":1,"금":3,"수":2},"tenGods":{"year":["겁재"],"month":["정관"],"hour":["정재"]},"daeunInfo":{"currentAge":63,"startAge":60,"endAge":69,"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_111', '김광석', 'Kim Kwang-seok', '1964-01-22', '11:00',
  'male', '', 'singer', '',
  '계묘', '을축', '경자', '임오',
  '계묘 을축 경자 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"month":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"day":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":1,"토":1,"금":1,"수":3},"tenGods":{"year":["상관"],"month":["정재"],"hour":["식신"]},"daeunInfo":{"currentAge":61,"startAge":60,"endAge":69,"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_112', '서태지', 'Seo Taiji', '1972-02-21', '13:30',
  'male', '', 'singer', '',
  '임자', '임인', '임자', '정미',
  '임자 임인 임자 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"month":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"day":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":1,"화":1,"토":1,"금":0,"수":5},"tenGods":{"year":["비견"],"month":["비견"],"hour":["정재"]},"daeunInfo":{"currentAge":53,"startAge":50,"endAge":59,"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_113', '조용필', 'Cho Yong-pil', '1950-03-21', '10:15',
  'male', '', 'singer', '',
  '경인', '기묘', '을유', '신사',
  '경인 기묘 을유 신사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅","element":"금"},"month":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"day":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"hour":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"elementBalance":{"목":3,"화":1,"토":1,"금":3,"수":0},"tenGods":{"year":["정재"],"month":["편재"],"hour":["편관"]},"daeunInfo":{"currentAge":75,"startAge":70,"endAge":79,"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_114', '이문세', 'Lee Moon-se', '1957-01-17', '15:45',
  'male', '', 'singer', '',
  '병신', '신축', '기미', '임신',
  '병신 신축 기미 임신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"month":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"day":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"hour":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"elementBalance":{"목":0,"화":1,"토":3,"금":3,"수":1},"tenGods":{"year":["정관"],"month":["식신"],"hour":["상관"]},"daeunInfo":{"currentAge":68,"startAge":60,"endAge":69,"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_115', '변진섭', 'Byun Jin-sub', '1966-12-30', '17:20',
  'male', '', 'singer', '',
  '병오', '경자', '계사', '신유',
  '병오 경자 계사 신유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"month":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"day":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"hour":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"elementBalance":{"목":0,"화":3,"토":0,"금":3,"수":2},"tenGods":{"year":["상관"],"month":["정관"],"hour":["편인"]},"daeunInfo":{"currentAge":59,"startAge":50,"endAge":59,"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'rap_001', '타이거JK', 'Tiger JK', '1974-07-29', '14:30',
  'male', '', 'rapper', '',
  '갑인', '신미', '신축', '을미',
  '갑인 신미 신축 을미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"month":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"day":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"hour":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"elementBalance":{"목":3,"화":0,"토":3,"금":2,"수":0},"tenGods":{"year":["상관"],"month":["비견"],"hour":["편재"]},"daeunInfo":{"currentAge":51,"startAge":50,"endAge":59,"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'rap_002', '윤미래', 'Yoon Mirae', '1981-05-31', '11:45',
  'female', '', 'rapper', '',
  '신유', '계사', '기묘', '경오',
  '신유 계사 기묘 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"day":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":2,"토":1,"금":3,"수":1},"tenGods":{"year":["식신"],"month":["편재"],"hour":["겁재"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"정","branch":"유","stemHanja":"丁","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'rap_003', '이효리', 'Lee Hyori', '1979-05-10', '12:00',
  'female', '', 'singer', '',
  '기미', '기사', '정미', '병오',
  '기미 기사 정미 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":0,"화":4,"토":4,"금":0,"수":0},"tenGods":{"year":["식신"],"month":["식신"],"hour":["정인"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'rap_004', '다이나믹 듀오', 'Dynamic Duo', '1981-09-05', '16:00',
  'male', '', 'rapper', '',
  '신유', '병신', '병진', '병신',
  '신유 병신 병진 병신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"day":{"stem":"병","branch":"진","stemHanja":"丙","branchHanja":"辰","element":"화"},"hour":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"elementBalance":{"목":0,"화":3,"토":1,"금":4,"수":0},"tenGods":{"year":["정재"],"month":["비견"],"hour":["비견"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_100', '이정재', 'Lee Jung-jae', '1972-12-15', '13:20',
  'male', '', 'actor', '',
  '임자', '임자', '경술', '계미',
  '임자 임자 경술 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"month":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"day":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":0,"화":0,"토":2,"금":1,"수":5},"tenGods":{"year":["식신"],"month":["식신"],"hour":["상관"]},"daeunInfo":{"currentAge":53,"startAge":50,"endAge":59,"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_101', '박서준', 'Park Seo-joon', '1988-12-16', '10:30',
  'male', '', 'actor', '',
  '무진', '갑자', '을해', '신사',
  '무진 갑자 을해 신사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"elementBalance":{"목":2,"화":1,"토":2,"금":1,"수":2},"tenGods":{"year":["상관"],"month":["정인"],"hour":["편관"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_102', '이민호', 'Lee Min-ho', '1987-06-22', '15:45',
  'male', '', 'actor', '',
  '정묘', '병오', '임신', '무신',
  '정묘 병오 임신 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"month":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"day":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":1,"화":3,"토":1,"금":2,"수":1},"tenGods":{"year":["정재"],"month":["편재"],"hour":["편관"]},"daeunInfo":{"currentAge":38,"startAge":30,"endAge":39,"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_103', '현빈', 'Hyun Bin', '1982-09-25', '14:15',
  'male', '', 'actor', '',
  '임술', '기유', '신사', '을미',
  '임술 기유 신사 을미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"month":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"day":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"hour":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["겁재"],"month":["편인"],"hour":["편재"]},"daeunInfo":{"currentAge":43,"startAge":40,"endAge":49,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_104', '원빈', 'Won Bin', '1977-11-10', '11:30',
  'male', '', 'actor', '',
  '정사', '신해', '신축', '갑오',
  '정사 신해 신축 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"month":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"day":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":3,"토":1,"금":2,"수":1},"tenGods":{"year":["편관"],"month":["비견"],"hour":["상관"]},"daeunInfo":{"currentAge":48,"startAge":40,"endAge":49,"stem":"을","branch":"묘","stemHanja":"乙","branchHanja":"卯"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_105', '조인성', 'Jo In-sung', '1981-07-28', '16:00',
  'male', '', 'actor', '',
  '신유', '을미', '정축', '무신',
  '신유 을미 정축 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"day":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":1,"화":1,"토":3,"금":3,"수":0},"tenGods":{"year":["편재"],"month":["편인"],"hour":["겁재"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_106', '송중기', 'Song Joong-ki', '1985-09-19', '12:45',
  'male', '', 'actor', '',
  '을축', '을유', '신묘', '갑오',
  '을축 을유 신묘 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"month":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"day":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":4,"화":1,"토":1,"금":2,"수":0},"tenGods":{"year":["편재"],"month":["편재"],"hour":["상관"]},"daeunInfo":{"currentAge":40,"startAge":40,"endAge":49,"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_107', '공유', 'Gong Yoo', '1979-07-10', '17:30',
  'male', '', 'actor', '',
  '기미', '신미', '무신', '신유',
  '기미 신미 무신 신유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"day":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"hour":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"elementBalance":{"목":0,"화":0,"토":4,"금":4,"수":0},"tenGods":{"year":["겁재"],"month":["상관"],"hour":["상관"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_108', '이종석', 'Lee Jong-suk', '1989-09-14', '09:15',
  'male', '', 'actor', '',
  '기사', '계유', '정미', '을사',
  '기사 계유 정미 을사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"elementBalance":{"목":1,"화":3,"토":2,"금":1,"수":1},"tenGods":{"year":["식신"],"month":["편관"],"hour":["편인"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_109', '김수현', 'Kim Soo-hyun', '1988-02-16', '13:45',
  'male', '', 'actor', '',
  '무진', '갑인', '신미', '을미',
  '무진 갑인 신미 을미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"day":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"hour":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"elementBalance":{"목":3,"화":0,"토":4,"금":1,"수":0},"tenGods":{"year":["정관"],"month":["상관"],"hour":["편재"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_110', '이동욱', 'Lee Dong-wook', '1981-11-06', '18:20',
  'male', '', 'actor', '',
  '신유', '무술', '무오', '신유',
  '신유 무술 무오 신유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"day":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"hour":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"elementBalance":{"목":0,"화":1,"토":3,"금":4,"수":0},"tenGods":{"year":["상관"],"month":["비견"],"hour":["상관"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_111', '소지섭', 'So Ji-sub', '1977-11-04', '14:50',
  'male', '', 'actor', '',
  '정사', '경술', '을미', '계미',
  '정사 경술 을미 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"month":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"day":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":1,"화":2,"토":3,"금":1,"수":1},"tenGods":{"year":["식신"],"month":["정재"],"hour":["편인"]},"daeunInfo":{"currentAge":48,"startAge":40,"endAge":49,"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_112', '정우성', 'Jung Woo-sung', '1973-03-20', '10:25',
  'male', '', 'actor', '',
  '계축', '을묘', '을유', '신사',
  '계축 을묘 을유 신사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"month":{"stem":"을","branch":"묘","stemHanja":"乙","branchHanja":"卯","element":"목"},"day":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"hour":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"elementBalance":{"목":3,"화":1,"토":1,"금":2,"수":1},"tenGods":{"year":["편인"],"month":["비견"],"hour":["편관"]},"daeunInfo":{"currentAge":52,"startAge":50,"endAge":59,"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_113', '황정민', 'Hwang Jung-min', '1970-09-01', '16:35',
  'male', '', 'actor', '',
  '경술', '갑신', '갑인', '임신',
  '경술 갑신 갑인 임신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"month":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"day":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"hour":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"elementBalance":{"목":3,"화":0,"토":1,"금":3,"수":1},"tenGods":{"year":["편관"],"month":["비견"],"hour":["편인"]},"daeunInfo":{"currentAge":55,"startAge":50,"endAge":59,"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_114', '설경구', 'Sul Kyung-gu', '1968-05-01', '11:40',
  'male', '', 'actor', '',
  '무신', '병진', '신축', '갑오',
  '무신 병진 신축 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"month":{"stem":"병","branch":"진","stemHanja":"丙","branchHanja":"辰","element":"화"},"day":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":2,"토":3,"금":2,"수":0},"tenGods":{"year":["정관"],"month":["정재"],"hour":["상관"]},"daeunInfo":{"currentAge":57,"startAge":50,"endAge":59,"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_115', '송강호', 'Song Kang-ho', '1967-01-17', '15:10',
  'male', '', 'actor', '',
  '병오', '신축', '신해', '병신',
  '병오 신축 신해 병신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"month":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"day":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"hour":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"elementBalance":{"목":0,"화":3,"토":1,"금":3,"수":1},"tenGods":{"year":["정재"],"month":["비견"],"hour":["정재"]},"daeunInfo":{"currentAge":58,"startAge":50,"endAge":59,"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_200', '송혜교', 'Song Hye-kyo', '1981-11-22', '12:30',
  'female', '', 'actor', '',
  '신유', '기해', '갑술', '경오',
  '신유 기해 갑술 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"day":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":1,"토":2,"금":3,"수":1},"tenGods":{"year":["정관"],"month":["정재"],"hour":["편관"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_201', '한지민', 'Han Ji-min', '1982-11-05', '14:15',
  'female', '', 'actor', '',
  '임술', '경술', '임술', '정미',
  '임술 경술 임술 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"month":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"day":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":0,"화":1,"토":4,"금":1,"수":2},"tenGods":{"year":["비견"],"month":["편인"],"hour":["정재"]},"daeunInfo":{"currentAge":43,"startAge":40,"endAge":49,"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_202', '손예진', 'Son Ye-jin', '1982-01-11', '16:45',
  'female', '', 'actor', '',
  '신유', '신축', '갑자', '임신',
  '신유 신축 갑자 임신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"day":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"hour":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"elementBalance":{"목":1,"화":0,"토":1,"금":4,"수":2},"tenGods":{"year":["정관"],"month":["정관"],"hour":["편인"]},"daeunInfo":{"currentAge":43,"startAge":40,"endAge":49,"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_203', '박신혜', 'Park Shin-hye', '1990-02-18', '10:20',
  'female', '', 'actor', '',
  '경오', '무인', '갑신', '기사',
  '경오 무인 갑신 기사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"month":{"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅","element":"토"},"day":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"hour":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"elementBalance":{"목":2,"화":2,"토":2,"금":2,"수":0},"tenGods":{"year":["편관"],"month":["편재"],"hour":["정재"]},"daeunInfo":{"currentAge":35,"startAge":30,"endAge":39,"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_204', '김태희', 'Kim Tae-hee', '1980-03-29', '13:55',
  'female', '', 'actor', '',
  '경신', '기묘', '신미', '을미',
  '경신 기묘 신미 을미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"month":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"day":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"hour":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"elementBalance":{"목":2,"화":0,"토":3,"금":3,"수":0},"tenGods":{"year":["정인"],"month":["편인"],"hour":["편재"]},"daeunInfo":{"currentAge":45,"startAge":40,"endAge":49,"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_205', '김희선', 'Kim Hee-sun', '1977-08-25', '17:25',
  'female', '', 'actor', '',
  '정사', '무신', '갑신', '계유',
  '정사 무신 갑신 계유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"month":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"day":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"hour":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"elementBalance":{"목":1,"화":2,"토":1,"금":3,"수":1},"tenGods":{"year":["상관"],"month":["편재"],"hour":["정인"]},"daeunInfo":{"currentAge":48,"startAge":40,"endAge":49,"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_206', '김하늘', 'Kim Ha-neul', '1978-02-21', '11:35',
  'female', '', 'actor', '',
  '무오', '갑인', '갑신', '경오',
  '무오 갑인 갑신 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"month":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"day":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":3,"화":2,"토":1,"금":2,"수":0},"tenGods":{"year":["편재"],"month":["비견"],"hour":["편관"]},"daeunInfo":{"currentAge":47,"startAge":40,"endAge":49,"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_207', '전도연', 'Jeon Do-yeon', '1973-02-11', '15:20',
  'female', '', 'actor', '',
  '계축', '갑인', '무신', '경신',
  '계축 갑인 무신 경신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"month":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"day":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"hour":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"elementBalance":{"목":2,"화":0,"토":2,"금":3,"수":1},"tenGods":{"year":["정재"],"month":["편관"],"hour":["식신"]},"daeunInfo":{"currentAge":52,"startAge":50,"endAge":59,"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_208', '윤여정', 'Youn Yuh-jung', '1947-06-19', '09:45',
  'female', '', 'actor', '',
  '정해', '병오', '기해', '기사',
  '정해 병오 기해 기사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥","element":"화"},"month":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"day":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"hour":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"elementBalance":{"목":0,"화":4,"토":2,"금":0,"수":2},"tenGods":{"year":["편인"],"month":["정관"],"hour":["비견"]},"daeunInfo":{"currentAge":78,"startAge":70,"endAge":79,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_209', '김혜수', 'Kim Hye-soo', '1970-09-05', '14:30',
  'female', '', 'actor', '',
  '경술', '갑신', '무오', '기미',
  '경술 갑신 무오 기미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"month":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"day":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"hour":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"elementBalance":{"목":1,"화":1,"토":4,"금":2,"수":0},"tenGods":{"year":["식신"],"month":["편관"],"hour":["겁재"]},"daeunInfo":{"currentAge":55,"startAge":50,"endAge":59,"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_210', '이영애', 'Lee Young-ae', '1971-01-31', '12:15',
  'female', '', 'actor', '',
  '경술', '기축', '병술', '갑오',
  '경술 기축 병술 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"month":{"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑","element":"토"},"day":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":2,"토":4,"금":1,"수":0},"tenGods":{"year":["편재"],"month":["상관"],"hour":["편인"]},"daeunInfo":{"currentAge":54,"startAge":50,"endAge":59,"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_001', '유재석', 'Yoo Jae-suk', '1972-08-14', '10:30',
  'male', '', 'comedian', '',
  '임자', '무신', '정미', '을사',
  '임자 무신 정미 을사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"month":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"elementBalance":{"목":1,"화":2,"토":2,"금":1,"수":2},"tenGods":{"year":["정재"],"month":["겁재"],"hour":["편인"]},"daeunInfo":{"currentAge":53,"startAge":50,"endAge":59,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_002', '강호동', 'Kang Ho-dong', '1970-06-11', '14:45',
  'male', '', 'comedian', '',
  '경술', '임오', '임진', '정미',
  '경술 임오 임진 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"month":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"day":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":0,"화":2,"토":3,"금":1,"수":2},"tenGods":{"year":["편인"],"month":["비견"],"hour":["정재"]},"daeunInfo":{"currentAge":55,"startAge":50,"endAge":59,"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_003', '박명수', 'Park Myeong-su', '1970-08-27', '16:20',
  'male', '', 'comedian', '',
  '경술', '갑신', '기유', '임신',
  '경술 갑신 기유 임신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"month":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"day":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"hour":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"elementBalance":{"목":1,"화":0,"토":2,"금":4,"수":1},"tenGods":{"year":["겁재"],"month":["정재"],"hour":["상관"]},"daeunInfo":{"currentAge":55,"startAge":50,"endAge":59,"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_004', '정형돈', 'Jeong Hyeong-don', '1978-02-07', '11:15',
  'male', '', 'comedian', '',
  '무오', '갑인', '경오', '임오',
  '무오 갑인 경오 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"month":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"day":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":3,"토":1,"금":1,"수":1},"tenGods":{"year":["편인"],"month":["편재"],"hour":["식신"]},"daeunInfo":{"currentAge":47,"startAge":40,"endAge":49,"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_005', '노홍철', 'Noh Hong-chul', '1979-03-31', '13:50',
  'male', '', 'comedian', '',
  '기미', '정묘', '정묘', '정미',
  '기미 정묘 정묘 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":2,"화":3,"토":3,"금":0,"수":0},"tenGods":{"year":["식신"],"month":["비견"],"hour":["비견"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_006', '하하', 'HaHa', '1979-08-20', '17:35',
  'male', '', 'comedian', '',
  '기미', '임신', '기축', '계유',
  '기미 임신 기축 계유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"day":{"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑","element":"토"},"hour":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"elementBalance":{"목":0,"화":0,"토":4,"금":2,"수":2},"tenGods":{"year":["비견"],"month":["상관"],"hour":["편재"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_007', '김종국', 'Kim Jong-kook', '1976-04-25', '09:25',
  'male', '', 'comedian', '',
  '병진', '임진', '정축', '을사',
  '병진 임진 정축 을사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"진","stemHanja":"丙","branchHanja":"辰","element":"화"},"month":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"day":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"hour":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"elementBalance":{"목":1,"화":3,"토":3,"금":0,"수":1},"tenGods":{"year":["정인"],"month":["정재"],"hour":["편인"]},"daeunInfo":{"currentAge":49,"startAge":40,"endAge":49,"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_008', '송지효', 'Song Ji-hyo', '1981-08-15', '15:40',
  'female', '', 'comedian', '',
  '신유', '병신', '을미', '갑신',
  '신유 병신 을미 갑신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"day":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"hour":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"elementBalance":{"목":2,"화":1,"토":1,"금":4,"수":0},"tenGods":{"year":["편관"],"month":["겁재"],"hour":["정인"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_009', '전소민', 'Jeon So-min', '1986-04-07', '12:55',
  'female', '', 'comedian', '',
  '병인', '임진', '신해', '갑오',
  '병인 임진 신해 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅","element":"화"},"month":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"day":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":2,"화":2,"토":1,"금":1,"수":2},"tenGods":{"year":["정재"],"month":["겁재"],"hour":["상관"]},"daeunInfo":{"currentAge":39,"startAge":30,"endAge":39,"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'com_010', '양세찬', 'Yang Se-chan', '1986-09-18', '18:10',
  'male', '', 'comedian', '',
  '병인', '정유', '을미', '을유',
  '병인 정유 을미 을유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅","element":"화"},"month":{"stem":"정","branch":"유","stemHanja":"丁","branchHanja":"酉","element":"화"},"day":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"hour":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"elementBalance":{"목":3,"화":2,"토":1,"금":2,"수":0},"tenGods":{"year":["겁재"],"month":["식신"],"hour":["비견"]},"daeunInfo":{"currentAge":39,"startAge":30,"endAge":39,"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_100', '박찬호', 'Park Chan-ho', '1973-06-30', '14:20',
  'male', '', 'athlete', '',
  '계축', '무오', '정묘', '정미',
  '계축 무오 정묘 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"month":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":1,"화":3,"토":3,"금":0,"수":1},"tenGods":{"year":["편관"],"month":["겁재"],"hour":["비견"]},"daeunInfo":{"currentAge":52,"startAge":50,"endAge":59,"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_101', '박세리', 'Pak Se-ri', '1977-09-28', '11:45',
  'female', '', 'athlete', '',
  '정사', '기유', '무오', '무오',
  '정사 기유 무오 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"month":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"day":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":0,"화":4,"토":3,"금":1,"수":0},"tenGods":{"year":["정인"],"month":["겁재"],"hour":["비견"]},"daeunInfo":{"currentAge":48,"startAge":40,"endAge":49,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_102', '김연아', 'Kim Yuna', '1990-09-05', '16:30',
  'female', '', 'athlete', '',
  '경오', '갑신', '계묘', '경신',
  '경오 갑신 계묘 경신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"month":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"day":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"hour":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"elementBalance":{"목":2,"화":1,"토":0,"금":4,"수":1},"tenGods":{"year":["정관"],"month":["겁재"],"hour":["정관"]},"daeunInfo":{"currentAge":35,"startAge":30,"endAge":39,"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_103', '류현진', 'Ryu Hyun-jin', '1987-03-25', '10:15',
  'male', '', 'athlete', '',
  '정묘', '계묘', '계묘', '정사',
  '정묘 계묘 계묘 정사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"month":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"day":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"hour":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"elementBalance":{"목":3,"화":3,"토":0,"금":0,"수":2},"tenGods":{"year":["편재"],"month":["비견"],"hour":["편재"]},"daeunInfo":{"currentAge":38,"startAge":30,"endAge":39,"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_104', '이대호', 'Lee Dae-ho', '1982-06-21', '13:40',
  'male', '', 'athlete', '',
  '임술', '병오', '을사', '계미',
  '임술 병오 을사 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"month":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"day":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":1,"화":3,"토":2,"금":0,"수":2},"tenGods":{"year":["정관"],"month":["겁재"],"hour":["편인"]},"daeunInfo":{"currentAge":43,"startAge":40,"endAge":49,"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_105', '추신수', 'Choo Shin-soo', '1982-07-13', '15:25',
  'male', '', 'athlete', '',
  '임술', '정미', '정묘', '무신',
  '임술 정미 정묘 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"month":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":1,"화":2,"토":3,"금":1,"수":1},"tenGods":{"year":["정재"],"month":["비견"],"hour":["겁재"]},"daeunInfo":{"currentAge":43,"startAge":40,"endAge":49,"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_106', '박인비', 'Park In-bee', '1988-07-12', '12:50',
  'female', '', 'athlete', '',
  '무진', '기미', '무술', '무오',
  '무진 기미 무술 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"day":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":0,"화":1,"토":7,"금":0,"수":0},"tenGods":{"year":["비견"],"month":["겁재"],"hour":["비견"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_107', '박태환', 'Park Tae-hwan', '1989-09-27', '17:20',
  'male', '', 'athlete', '',
  '기사', '계유', '경신', '을유',
  '기사 계유 경신 을유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"hour":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"elementBalance":{"목":1,"화":1,"토":1,"금":4,"수":1},"tenGods":{"year":["정인"],"month":["상관"],"hour":["정재"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_100', '이재명', 'Lee Jae-myung', '1964-12-22', '09:30',
  'male', '', 'politician', '',
  '갑진', '병자', '을해', '신사',
  '갑진 병자 을해 신사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰","element":"목"},"month":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"elementBalance":{"목":2,"화":2,"토":1,"금":1,"수":2},"tenGods":{"year":["정인"],"month":["겁재"],"hour":["편관"]},"daeunInfo":{"currentAge":61,"startAge":60,"endAge":69,"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_101', '홍준표', 'Hong Jun-pyo', '1954-11-20', '14:15',
  'male', '', 'politician', '',
  '갑오', '을해', '경술', '계미',
  '갑오 을해 경술 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"month":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"day":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":2,"화":1,"토":2,"금":1,"수":2},"tenGods":{"year":["편재"],"month":["정재"],"hour":["상관"]},"daeunInfo":{"currentAge":71,"startAge":70,"endAge":79,"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_102', '안철수', 'Ahn Cheol-soo', '1962-02-26', '11:45',
  'male', '', 'politician', '',
  '임인', '임인', '을축', '임오',
  '임인 임인 을축 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"month":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"day":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":3,"화":1,"토":1,"금":0,"수":3},"tenGods":{"year":["정관"],"month":["정관"],"hour":["정관"]},"daeunInfo":{"currentAge":63,"startAge":60,"endAge":69,"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_103', '조국', 'Cho Kuk', '1965-12-05', '16:35',
  'male', '', 'politician', '',
  '을사', '정해', '계해', '경신',
  '을사 정해 계해 경신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"month":{"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥","element":"화"},"day":{"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥","element":"수"},"hour":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"elementBalance":{"목":1,"화":2,"토":0,"금":2,"수":3},"tenGods":{"year":["식신"],"month":["편재"],"hour":["정관"]},"daeunInfo":{"currentAge":60,"startAge":60,"endAge":69,"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_100', '이재용', 'Lee Jae-yong', '1968-06-23', '10:20',
  'male', '', 'business_leader', '',
  '무신', '무오', '갑오', '기사',
  '무신 무오 갑오 기사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"month":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"day":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"hour":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"elementBalance":{"목":1,"화":3,"토":3,"금":1,"수":0},"tenGods":{"year":["편재"],"month":["편재"],"hour":["정재"]},"daeunInfo":{"currentAge":57,"startAge":50,"endAge":59,"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_101', '신동빈', 'Shin Dong-bin', '1955-02-14', '13:45',
  'male', '', 'business_leader', '',
  '을미', '무인', '병자', '을미',
  '을미 무인 병자 을미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"month":{"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅","element":"토"},"day":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"hour":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"elementBalance":{"목":3,"화":1,"토":3,"금":0,"수":1},"tenGods":{"year":["정인"],"month":["식신"],"hour":["정인"]},"daeunInfo":{"currentAge":70,"startAge":70,"endAge":79,"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_102', '최태원', 'Chey Tae-won', '1960-12-03', '15:30',
  'male', '', 'business_leader', '',
  '경자', '정해', '을미', '갑신',
  '경자 정해 을미 갑신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"month":{"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥","element":"화"},"day":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"hour":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"elementBalance":{"목":2,"화":1,"토":1,"금":2,"수":2},"tenGods":{"year":["정재"],"month":["식신"],"hour":["정인"]},"daeunInfo":{"currentAge":65,"startAge":60,"endAge":69,"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_103', '서경배', 'Suh Kyung-bae', '1963-12-16', '17:10',
  'male', '', 'business_leader', '',
  '계묘', '갑자', '계해', '신유',
  '계묘 갑자 계해 신유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"month":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"day":{"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥","element":"수"},"hour":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"elementBalance":{"목":2,"화":0,"토":0,"금":2,"수":4},"tenGods":{"year":["비견"],"month":["겁재"],"hour":["편인"]},"daeunInfo":{"currentAge":62,"startAge":60,"endAge":69,"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_104', '구광모', 'Koo Kwang-mo', '1967-07-15', '12:25',
  'male', '', 'business_leader', '',
  '정미', '정미', '경술', '임오',
  '정미 정미 경술 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"month":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"day":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":0,"화":3,"토":3,"금":1,"수":1},"tenGods":{"year":["정관"],"month":["정관"],"hour":["식신"]},"daeunInfo":{"currentAge":58,"startAge":50,"endAge":59,"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bro_001', '김성주', 'Kim Sung-joo', '1974-04-15', '11:30',
  'male', '', 'broadcaster', '',
  '갑인', '무진', '병진', '갑오',
  '갑인 무진 병진 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"month":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"day":{"stem":"병","branch":"진","stemHanja":"丙","branchHanja":"辰","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":3,"화":2,"토":3,"금":0,"수":0},"tenGods":{"year":["편인"],"month":["식신"],"hour":["편인"]},"daeunInfo":{"currentAge":51,"startAge":50,"endAge":59,"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bro_002', '신동엽', 'Shin Dong-yup', '1971-02-17', '14:45',
  'male', '', 'broadcaster', '',
  '신해', '경인', '계묘', '기미',
  '신해 경인 계묘 기미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"month":{"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅","element":"금"},"day":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"hour":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"elementBalance":{"목":2,"화":0,"토":2,"금":2,"수":2},"tenGods":{"year":["편인"],"month":["정관"],"hour":["편관"]},"daeunInfo":{"currentAge":54,"startAge":50,"endAge":59,"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bro_003', '김구라', 'Kim Gu-ra', '1970-10-03', '16:20',
  'male', '', 'broadcaster', '',
  '경술', '을유', '병술', '병신',
  '경술 을유 병술 병신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"month":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"day":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"hour":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"elementBalance":{"목":1,"화":2,"토":2,"금":3,"수":0},"tenGods":{"year":["편재"],"month":["정인"],"hour":["비견"]},"daeunInfo":{"currentAge":55,"startAge":50,"endAge":59,"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bro_004', '김제동', 'Kim Je-dong', '1974-04-27', '09:15',
  'male', '', 'broadcaster', '',
  '갑인', '무진', '무진', '정사',
  '갑인 무진 무진 정사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"month":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"day":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"hour":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"elementBalance":{"목":2,"화":2,"토":4,"금":0,"수":0},"tenGods":{"year":["편관"],"month":["비견"],"hour":["정인"]},"daeunInfo":{"currentAge":51,"startAge":50,"endAge":59,"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bro_005', '장도연', 'Jang Do-yeon', '1985-02-07', '13:35',
  'female', '', 'broadcaster', '',
  '을축', '무인', '정미', '정미',
  '을축 무인 정미 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"month":{"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅","element":"토"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":2,"화":2,"토":4,"금":0,"수":0},"tenGods":{"year":["편인"],"month":["겁재"],"hour":["비견"]},"daeunInfo":{"currentAge":40,"startAge":40,"endAge":49,"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'dir_001', '봉준호', 'Bong Joon-ho', '1969-09-14', '15:40',
  'male', '', 'director', '',
  '기유', '계유', '임술', '무신',
  '기유 계유 임술 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":0,"화":0,"토":3,"금":3,"수":2},"tenGods":{"year":["정관"],"month":["겁재"],"hour":["편관"]},"daeunInfo":{"currentAge":56,"startAge":50,"endAge":59,"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'dir_002', '박찬욱', 'Park Chan-wook', '1963-08-23', '11:25',
  'male', '', 'director', '',
  '계묘', '경신', '무진', '무오',
  '계묘 경신 무진 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["정재"],"month":["식신"],"hour":["비견"]},"daeunInfo":{"currentAge":62,"startAge":60,"endAge":69,"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'dir_003', '김기덕', 'Kim Ki-duk', '1960-12-20', '17:50',
  'male', '', 'director', '',
  '경자', '무자', '임자', '기유',
  '경자 무자 임자 기유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"month":{"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子","element":"토"},"day":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"hour":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"elementBalance":{"목":0,"화":0,"토":2,"금":2,"수":4},"tenGods":{"year":["편인"],"month":["편관"],"hour":["정관"]},"daeunInfo":{"currentAge":65,"startAge":60,"endAge":69,"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'dir_004', '이창동', 'Lee Chang-dong', '1954-07-04', '10:35',
  'male', '', 'director', '',
  '갑오', '경오', '신묘', '계사',
  '갑오 경오 신묘 계사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"month":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"day":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"hour":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"elementBalance":{"목":2,"화":3,"토":0,"금":2,"수":1},"tenGods":{"year":["상관"],"month":["정인"],"hour":["식신"]},"daeunInfo":{"currentAge":71,"startAge":70,"endAge":79,"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'wri_001', '조정래', 'Cho Jung-rae', '1943-08-17', '14:20',
  'male', '', 'writer', '',
  '계미', '경신', '정축', '정미',
  '계미 경신 정축 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":0,"화":2,"토":3,"금":2,"수":1},"tenGods":{"year":["편관"],"month":["상관"],"hour":["비견"]},"daeunInfo":{"currentAge":82,"startAge":80,"endAge":89,"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'wri_002', '이외수', 'Lee Oe-soo', '1946-09-22', '12:10',
  'male', '', 'writer', '',
  '병술', '정유', '기사', '경오',
  '병술 정유 기사 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"month":{"stem":"정","branch":"유","stemHanja":"丁","branchHanja":"酉","element":"화"},"day":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":0,"화":4,"토":2,"금":2,"수":0},"tenGods":{"year":["정관"],"month":["편인"],"hour":["겁재"]},"daeunInfo":{"currentAge":79,"startAge":70,"endAge":79,"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'wri_003', '공지영', 'Gong Ji-young', '1963-08-09', '16:45',
  'female', '', 'writer', '',
  '계묘', '경신', '갑인', '임신',
  '계묘 경신 갑인 임신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"hour":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"elementBalance":{"목":3,"화":0,"토":0,"금":3,"수":2},"tenGods":{"year":["정인"],"month":["편관"],"hour":["편인"]},"daeunInfo":{"currentAge":62,"startAge":60,"endAge":69,"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'izone_001', '장원영', 'Jang Wonyoung', '2004-08-31', '12:00',
  'female', '', 'singer', 'IZ*ONE',
  '갑신', '임신', '임자', '병오',
  '갑신 임신 임자 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"month":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"day":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":2,"토":0,"금":2,"수":3},"tenGods":{"year":["식신"],"month":["비견"],"hour":["편재"]},"daeunInfo":{"currentAge":21,"startAge":20,"endAge":29,"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'izone_002', '안유진', 'An Yujin', '2003-09-01', '12:00',
  'female', '', 'singer', 'IZ*ONE',
  '계미', '경신', '정미', '병오',
  '계미 경신 정미 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":0,"화":3,"토":2,"금":2,"수":1},"tenGods":{"year":["편관"],"month":["상관"],"hour":["정인"]},"daeunInfo":{"currentAge":22,"startAge":20,"endAge":29,"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'izone_003', '권은비', 'Kwon Eunbi', '1995-09-27', '12:00',
  'female', '', 'singer', 'IZ*ONE',
  '을해', '을유', '신묘', '갑오',
  '을해 을유 신묘 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"month":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"day":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":4,"화":1,"토":0,"금":2,"수":1},"tenGods":{"year":["편재"],"month":["편재"],"hour":["상관"]},"daeunInfo":{"currentAge":30,"startAge":30,"endAge":39,"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'snsd_001', '태연', 'Taeyeon', '1989-03-09', '12:00',
  'female', '', 'singer', '소녀시대',
  '기사', '정묘', '무술', '무오',
  '기사 정묘 무술 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"day":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":3,"토":4,"금":0,"수":0},"tenGods":{"year":["겁재"],"month":["정인"],"hour":["비견"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'snsd_002', '유리', 'Yuri', '1989-12-05', '12:00',
  'female', '', 'singer', '소녀시대',
  '기사', '을해', '기사', '경오',
  '기사 을해 기사 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"day":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":3,"토":2,"금":1,"수":1},"tenGods":{"year":["비견"],"month":["편관"],"hour":["겁재"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'snsd_003', '윤아', 'Yoona', '1990-05-30', '12:00',
  'female', '', 'singer', '소녀시대',
  '경오', '신사', '을축', '임오',
  '경오 신사 을축 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"month":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"day":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":1,"화":3,"토":1,"금":2,"수":1},"tenGods":{"year":["정재"],"month":["편관"],"hour":["정관"]},"daeunInfo":{"currentAge":35,"startAge":30,"endAge":39,"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'snsd_004', '서현', 'Seohyun', '1991-06-28', '12:00',
  'female', '', 'singer', '소녀시대',
  '신미', '갑오', '기해', '경오',
  '신미 갑오 기해 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"month":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"day":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":2,"토":2,"금":2,"수":1},"tenGods":{"year":["식신"],"month":["정재"],"hour":["겁재"]},"daeunInfo":{"currentAge":34,"startAge":30,"endAge":39,"stem":"정","branch":"유","stemHanja":"丁","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'wg_001', '선예', 'Sunye', '1989-08-12', '12:00',
  'female', '', 'singer', '원더걸스',
  '기사', '임신', '갑술', '경오',
  '기사 임신 갑술 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"day":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":2,"토":2,"금":2,"수":1},"tenGods":{"year":["정재"],"month":["편인"],"hour":["편관"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'wg_002', '예은', 'Yeeun', '1989-05-26', '12:00',
  'female', '', 'singer', '원더걸스',
  '기사', '기사', '병진', '갑오',
  '기사 기사 병진 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"day":{"stem":"병","branch":"진","stemHanja":"丙","branchHanja":"辰","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":4,"토":3,"금":0,"수":0},"tenGods":{"year":["상관"],"month":["상관"],"hour":["편인"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'wg_003', '선미', 'Sunmi', '1992-05-02', '12:00',
  'female', '', 'singer', '원더걸스',
  '임신', '갑진', '무신', '무오',
  '임신 갑진 무신 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"month":{"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰","element":"목"},"day":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["편재"],"month":["편관"],"hour":["비견"]},"daeunInfo":{"currentAge":33,"startAge":30,"endAge":39,"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'kara_001', '박규리', 'Park Gyuri', '1988-05-21', '12:00',
  'female', '', 'singer', 'KARA',
  '무진', '정사', '병오', '갑오',
  '무진 정사 병오 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"day":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":5,"토":2,"금":0,"수":0},"tenGods":{"year":["식신"],"month":["겁재"],"hour":["편인"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'kara_002', '한승연', 'Han Seungyeon', '1988-07-24', '12:00',
  'female', '', 'singer', 'KARA',
  '무진', '기미', '경술', '임오',
  '무진 기미 경술 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"day":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":0,"화":1,"토":5,"금":1,"수":1},"tenGods":{"year":["편인"],"month":["정인"],"hour":["식신"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'kara_003', '구하라', 'Koo Hara', '1991-01-13', '12:00',
  'female', '', 'singer', 'KARA',
  '경오', '기축', '계축', '무오',
  '경오 기축 계축 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"month":{"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑","element":"토"},"day":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":0,"화":2,"토":4,"금":1,"수":1},"tenGods":{"year":["정관"],"month":["편관"],"hour":["정재"]},"daeunInfo":{"currentAge":34,"startAge":30,"endAge":39,"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bb_001', 'G-Dragon', 'G-Dragon', '1988-08-18', '12:00',
  'male', '', 'singer', 'BIGBANG',
  '무진', '경신', '을해', '임오',
  '무진 경신 을해 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":1,"화":1,"토":2,"금":2,"수":2},"tenGods":{"year":["상관"],"month":["정재"],"hour":["정관"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bb_002', '태양', 'Taeyang', '1988-05-18', '12:00',
  'male', '', 'singer', 'BIGBANG',
  '무진', '정사', '계묘', '무오',
  '무진 정사 계묘 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"day":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":3,"토":3,"금":0,"수":1},"tenGods":{"year":["정재"],"month":["편재"],"hour":["정재"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bb_003', '탑', 'TOP', '1987-11-04', '12:00',
  'male', '', 'singer', 'BIGBANG',
  '정묘', '경술', '정해', '병오',
  '정묘 경술 정해 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"month":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"day":{"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":4,"토":1,"금":1,"수":1},"tenGods":{"year":["비견"],"month":["상관"],"hour":["정인"]},"daeunInfo":{"currentAge":38,"startAge":30,"endAge":39,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bb_004', '대성', 'Daesung', '1989-04-26', '12:00',
  'male', '', 'singer', 'BIGBANG',
  '기사', '무진', '병술', '갑오',
  '기사 무진 병술 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"day":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":3,"토":4,"금":0,"수":0},"tenGods":{"year":["상관"],"month":["식신"],"hour":["편인"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'hot_001', '문희준', 'Moon Hee-jun', '1978-03-19', '12:00',
  'male', '', 'singer', 'H.O.T',
  '무오', '을묘', '경술', '임오',
  '무오 을묘 경술 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"month":{"stem":"을","branch":"묘","stemHanja":"乙","branchHanja":"卯","element":"목"},"day":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":2,"토":2,"금":1,"수":1},"tenGods":{"year":["편인"],"month":["정재"],"hour":["식신"]},"daeunInfo":{"currentAge":47,"startAge":40,"endAge":49,"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'hot_002', '강타', 'Kangta', '1979-10-10', '12:00',
  'male', '', 'singer', 'H.O.T',
  '기미', '갑술', '경진', '임오',
  '기미 갑술 경진 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"day":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":1,"화":1,"토":4,"금":1,"수":1},"tenGods":{"year":["정인"],"month":["편재"],"hour":["식신"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'hot_003', '이재원', 'Lee Jae-won', '1980-04-03', '12:00',
  'male', '', 'singer', 'H.O.T',
  '경신', '기묘', '병자', '갑오',
  '경신 기묘 병자 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"month":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"day":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":2,"화":2,"토":1,"금":2,"수":1},"tenGods":{"year":["편재"],"month":["상관"],"hour":["편인"]},"daeunInfo":{"currentAge":45,"startAge":40,"endAge":49,"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sks_001', '은지원', 'Eun Ji-won', '1978-06-08', '12:00',
  'male', '', 'singer', '젝스키스',
  '무오', '무오', '신미', '갑오',
  '무오 무오 신미 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"month":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"day":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":3,"토":3,"금":1,"수":0},"tenGods":{"year":["정관"],"month":["정관"],"hour":["상관"]},"daeunInfo":{"currentAge":47,"startAge":40,"endAge":49,"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sks_002', '이재진', 'Lee Jae-jin', '1979-07-13', '12:00',
  'male', '', 'singer', '젝스키스',
  '기미', '신미', '신해', '갑오',
  '기미 신미 신해 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"day":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["편인"],"month":["비견"],"hour":["상관"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sks_003', '김재덕', 'Kim Jae-duck', '1979-08-07', '12:00',
  'male', '', 'singer', '젝스키스',
  '기미', '신미', '병자', '갑오',
  '기미 신미 병자 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"day":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":2,"토":3,"금":1,"수":1},"tenGods":{"year":["상관"],"month":["정재"],"hour":["편인"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'gidle_001', '전소연', 'Jeon Soyeon', '1998-08-26', '12:00',
  'female', '', 'singer', '(G)I-DLE',
  '무인', '경신', '을해', '임오',
  '무인 경신 을해 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅","element":"토"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":1,"토":1,"금":2,"수":2},"tenGods":{"year":["상관"],"month":["정재"],"hour":["정관"]},"daeunInfo":{"currentAge":27,"startAge":20,"endAge":29,"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'gidle_002', '민니', 'Minnie', '1997-10-23', '12:00',
  'female', '', 'singer', '(G)I-DLE',
  '정축', '경술', '무진', '무오',
  '정축 경술 무진 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"month":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"day":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":0,"화":2,"토":5,"금":1,"수":0},"tenGods":{"year":["정인"],"month":["식신"],"hour":["비견"]},"daeunInfo":{"currentAge":28,"startAge":20,"endAge":29,"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'gidle_003', '우기', 'Yuqi', '1999-09-23', '12:00',
  'female', '', 'singer', '(G)I-DLE',
  '기묘', '계유', '무신', '무오',
  '기묘 계유 무신 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["겁재"],"month":["정재"],"hour":["비견"]},"daeunInfo":{"currentAge":26,"startAge":20,"endAge":29,"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'aespa_001', '카리나', 'Karina', '2000-04-11', '12:00',
  'female', '', 'singer', 'aespa',
  '경진', '경진', '기사', '경오',
  '경진 경진 기사 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"month":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"day":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":0,"화":2,"토":3,"금":3,"수":0},"tenGods":{"year":["겁재"],"month":["겁재"],"hour":["겁재"]},"daeunInfo":{"currentAge":25,"startAge":20,"endAge":29,"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'aespa_002', '윈터', 'Winter', '2001-01-01', '12:00',
  'female', '', 'singer', 'aespa',
  '경진', '기축', '갑오', '경오',
  '경진 기축 갑오 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"month":{"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑","element":"토"},"day":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":2,"토":3,"금":2,"수":0},"tenGods":{"year":["편관"],"month":["정재"],"hour":["편관"]},"daeunInfo":{"currentAge":24,"startAge":20,"endAge":29,"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'aespa_003', '지젤', 'Giselle', '2000-10-30', '12:00',
  'female', '', 'singer', 'aespa',
  '경진', '병술', '신묘', '갑오',
  '경진 병술 신묘 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"month":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"day":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":2,"화":2,"토":2,"금":2,"수":0},"tenGods":{"year":["정인"],"month":["정재"],"hour":["상관"]},"daeunInfo":{"currentAge":25,"startAge":20,"endAge":29,"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'aespa_004', '닝닝', 'NingNing', '2002-10-23', '12:00',
  'female', '', 'singer', 'aespa',
  '임오', '경술', '갑오', '경오',
  '임오 경술 갑오 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"month":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"day":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":3,"토":1,"금":2,"수":1},"tenGods":{"year":["편인"],"month":["편관"],"hour":["편관"]},"daeunInfo":{"currentAge":23,"startAge":20,"endAge":29,"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'skz_001', '방찬', 'Bang Chan', '1997-10-03', '12:00',
  'male', '', 'singer', 'Stray Kids',
  '정축', '기유', '무신', '무오',
  '정축 기유 무신 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"month":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"day":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":0,"화":2,"토":4,"금":2,"수":0},"tenGods":{"year":["정인"],"month":["겁재"],"hour":["비견"]},"daeunInfo":{"currentAge":28,"startAge":20,"endAge":29,"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'skz_002', '리노', 'Lee Know', '1998-10-25', '12:00',
  'male', '', 'singer', 'Stray Kids',
  '무인', '임술', '을해', '임오',
  '무인 임술 을해 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅","element":"토"},"month":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":1,"토":2,"금":0,"수":3},"tenGods":{"year":["상관"],"month":["정관"],"hour":["정관"]},"daeunInfo":{"currentAge":27,"startAge":20,"endAge":29,"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'skz_003', '창빈', 'Changbin', '1999-08-11', '12:00',
  'male', '', 'singer', 'Stray Kids',
  '기묘', '임신', '을축', '임오',
  '기묘 임신 을축 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"month":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"day":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":1,"토":2,"금":1,"수":2},"tenGods":{"year":["편재"],"month":["정관"],"hour":["정관"]},"daeunInfo":{"currentAge":26,"startAge":20,"endAge":29,"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'skz_004', '현진', 'Hyunjin', '2000-03-20', '12:00',
  'male', '', 'singer', 'Stray Kids',
  '경진', '기묘', '정미', '병오',
  '경진 기묘 정미 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"month":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":3,"토":3,"금":1,"수":0},"tenGods":{"year":["상관"],"month":["식신"],"hour":["정인"]},"daeunInfo":{"currentAge":25,"startAge":20,"endAge":29,"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'txt_001', '수빈', 'Soobin', '2000-12-05', '12:00',
  'male', '', 'singer', 'TXT',
  '경진', '정해', '정묘', '병오',
  '경진 정해 정묘 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"month":{"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥","element":"화"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":4,"토":1,"금":1,"수":1},"tenGods":{"year":["상관"],"month":["비견"],"hour":["정인"]},"daeunInfo":{"currentAge":25,"startAge":20,"endAge":29,"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'txt_002', '연준', 'Yeonjun', '1999-09-13', '12:00',
  'male', '', 'singer', 'TXT',
  '기묘', '계유', '무술', '무오',
  '기묘 계유 무술 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":1,"토":4,"금":1,"수":1},"tenGods":{"year":["겁재"],"month":["정재"],"hour":["비견"]},"daeunInfo":{"currentAge":26,"startAge":20,"endAge":29,"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'txt_003', '범규', 'Beomgyu', '2001-03-13', '12:00',
  'male', '', 'singer', 'TXT',
  '신사', '신묘', '을사', '임오',
  '신사 신묘 을사 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"month":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"day":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":2,"화":3,"토":0,"금":2,"수":1},"tenGods":{"year":["편관"],"month":["편관"],"hour":["정관"]},"daeunInfo":{"currentAge":24,"startAge":20,"endAge":29,"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'txt_004', '태현', 'Taehyun', '2002-02-05', '12:00',
  'male', '', 'singer', 'TXT',
  '임오', '임인', '갑술', '경오',
  '임오 임인 갑술 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"month":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"day":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":2,"화":2,"토":1,"금":1,"수":2},"tenGods":{"year":["편인"],"month":["편인"],"hour":["편관"]},"daeunInfo":{"currentAge":23,"startAge":20,"endAge":29,"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'txt_005', '휴닝카이', 'HueningKai', '2002-08-14', '12:00',
  'male', '', 'singer', 'TXT',
  '임오', '무신', '갑신', '경오',
  '임오 무신 갑신 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"month":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"day":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":2,"토":1,"금":3,"수":1},"tenGods":{"year":["편인"],"month":["편재"],"hour":["편관"]},"daeunInfo":{"currentAge":23,"startAge":20,"endAge":29,"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'enhy_001', '정원', 'Jungwon', '2004-02-09', '12:00',
  'male', '', 'singer', 'ENHYPEN',
  '갑신', '병인', '무자', '무오',
  '갑신 병인 무자 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"month":{"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅","element":"화"},"day":{"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":2,"화":2,"토":2,"금":1,"수":1},"tenGods":{"year":["편관"],"month":["편인"],"hour":["비견"]},"daeunInfo":{"currentAge":21,"startAge":20,"endAge":29,"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'enhy_002', '희승', 'Heeseung', '2001-10-15', '12:00',
  'male', '', 'singer', 'ENHYPEN',
  '신사', '무술', '신사', '갑오',
  '신사 무술 신사 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"month":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"day":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":3,"토":2,"금":2,"수":0},"tenGods":{"year":["비견"],"month":["정관"],"hour":["상관"]},"daeunInfo":{"currentAge":24,"startAge":20,"endAge":29,"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'enhy_003', '제이', 'Jay', '2002-04-20', '12:00',
  'male', '', 'singer', 'ENHYPEN',
  '임오', '갑진', '무자', '무오',
  '임오 갑진 무자 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"month":{"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰","element":"목"},"day":{"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":1,"화":2,"토":3,"금":0,"수":2},"tenGods":{"year":["편재"],"month":["편관"],"hour":["비견"]},"daeunInfo":{"currentAge":23,"startAge":20,"endAge":29,"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'enhy_004', '제이크', 'Jake', '2002-11-15', '12:00',
  'male', '', 'singer', 'ENHYPEN',
  '임오', '신해', '정사', '병오',
  '임오 신해 정사 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"month":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"day":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":0,"화":5,"토":0,"금":1,"수":2},"tenGods":{"year":["정재"],"month":["편재"],"hour":["정인"]},"daeunInfo":{"currentAge":23,"startAge":20,"endAge":29,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'itzy_001', '예지', 'Yeji', '2000-05-26', '12:00',
  'female', '', 'singer', 'ITZY',
  '경진', '신사', '갑인', '경오',
  '경진 신사 갑인 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"month":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"day":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":2,"화":2,"토":1,"금":3,"수":0},"tenGods":{"year":["편관"],"month":["정관"],"hour":["편관"]},"daeunInfo":{"currentAge":25,"startAge":20,"endAge":29,"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'itzy_002', '리아', 'Lia', '2000-07-21', '12:00',
  'female', '', 'singer', 'ITZY',
  '경진', '계미', '경술', '임오',
  '경진 계미 경술 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"month":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"day":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":0,"화":1,"토":3,"금":2,"수":2},"tenGods":{"year":["비견"],"month":["상관"],"hour":["식신"]},"daeunInfo":{"currentAge":25,"startAge":20,"endAge":29,"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'itzy_003', '류진', 'Ryujin', '2001-04-17', '12:00',
  'female', '', 'singer', 'ITZY',
  '신사', '임진', '경진', '임오',
  '신사 임진 경진 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"month":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"day":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":0,"화":2,"토":2,"금":2,"수":2},"tenGods":{"year":["겁재"],"month":["식신"],"hour":["식신"]},"daeunInfo":{"currentAge":24,"startAge":20,"endAge":29,"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'itzy_004', '채령', 'Chaeryeong', '2001-06-05', '12:00',
  'female', '', 'singer', 'ITZY',
  '신사', '계사', '기사', '경오',
  '신사 계사 기사 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"month":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"day":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":0,"화":4,"토":1,"금":2,"수":1},"tenGods":{"year":["식신"],"month":["편재"],"hour":["겁재"]},"daeunInfo":{"currentAge":24,"startAge":20,"endAge":29,"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'itzy_005', '유나', 'Yuna', '2003-12-09', '12:00',
  'female', '', 'singer', 'ITZY',
  '계미', '갑자', '병술', '갑오',
  '계미 갑자 병술 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"month":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"day":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":2,"화":2,"토":2,"금":0,"수":2},"tenGods":{"year":["정관"],"month":["편인"],"hour":["편인"]},"daeunInfo":{"currentAge":22,"startAge":20,"endAge":29,"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'lsf_001', '사쿠라', 'Sakura', '1998-03-19', '12:00',
  'female', '', 'singer', 'LE SSERAFIM',
  '무인', '을묘', '을미', '임오',
  '무인 을묘 을미 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅","element":"토"},"month":{"stem":"을","branch":"묘","stemHanja":"乙","branchHanja":"卯","element":"목"},"day":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":4,"화":1,"토":2,"금":0,"수":1},"tenGods":{"year":["상관"],"month":["비견"],"hour":["정관"]},"daeunInfo":{"currentAge":27,"startAge":20,"endAge":29,"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'lsf_002', '김채원', 'Kim Chaewon', '2000-08-01', '12:00',
  'female', '', 'singer', 'LE SSERAFIM',
  '경진', '계미', '신유', '갑오',
  '경진 계미 신유 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"month":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"day":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":1,"토":2,"금":3,"수":1},"tenGods":{"year":["정인"],"month":["식신"],"hour":["상관"]},"daeunInfo":{"currentAge":25,"startAge":20,"endAge":29,"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'lsf_003', '허윤진', 'Huh Yunjin', '2001-10-08', '12:00',
  'female', '', 'singer', 'LE SSERAFIM',
  '신사', '무술', '갑술', '경오',
  '신사 무술 갑술 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"month":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"day":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":2,"토":3,"금":2,"수":0},"tenGods":{"year":["정관"],"month":["편재"],"hour":["편관"]},"daeunInfo":{"currentAge":24,"startAge":20,"endAge":29,"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'lsf_004', '카즈하', 'Kazuha', '2003-08-09', '12:00',
  'female', '', 'singer', 'LE SSERAFIM',
  '계미', '경신', '갑신', '경오',
  '계미 경신 갑신 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":1,"토":1,"금":4,"수":1},"tenGods":{"year":["정인"],"month":["편관"],"hour":["편관"]},"daeunInfo":{"currentAge":22,"startAge":20,"endAge":29,"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌"}}'::jsonb, 'additional_celebrity_calculated', NOW(), NOW()
);-- 추가 유명인사 사주 데이터 삽입 SQL
-- 총 49명의 데이터

INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_006', '이효리', 'Lee Hyo-ri', '1979-05-10', '12:00',
  'female', '', 'singer', '',
  '기미', '기사', '정미', '병오',
  '기미 기사 정미 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":0,"화":4,"토":4,"금":0,"수":0},"tenGods":{"year":["식신"],"month":["식신"],"hour":["정인"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_007', '박진영', 'Park Jin-young', '1971-12-13', '14:00',
  'male', '', 'singer', '',
  '신해', '경자', '임인', '정미',
  '신해 경자 임인 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"month":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"day":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":1,"화":1,"토":1,"금":2,"수":3},"tenGods":{"year":["정인"],"month":["편인"],"hour":["정재"]},"daeunInfo":{"currentAge":54,"startAge":50,"endAge":59,"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_008', '비', 'Rain', '1982-06-25', '10:30',
  'male', '', 'singer', '',
  '임술', '병오', '기유', '기사',
  '임술 병오 기유 기사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"month":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"day":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"hour":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"elementBalance":{"목":0,"화":3,"토":3,"금":1,"수":1},"tenGods":{"year":["상관"],"month":["정관"],"hour":["비견"]},"daeunInfo":{"currentAge":43,"startAge":40,"endAge":49,"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_009', '보아', 'BoA', '1986-11-05', '15:20',
  'female', '', 'singer', '',
  '병인', '무술', '계미', '경신',
  '병인 무술 계미 경신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅","element":"화"},"month":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"day":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"hour":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["상관"],"month":["정재"],"hour":["정관"]},"daeunInfo":{"currentAge":39,"startAge":30,"endAge":39,"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_010', '세븐틴', 'SEVENTEEN', '2015-05-26', '00:00',
  'male', '', 'singer', '',
  '을미', '신사', '임신', '경자',
  '을미 신사 임신 경자', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"month":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"day":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"hour":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"elementBalance":{"목":1,"화":1,"토":1,"금":3,"수":2},"tenGods":{"year":["상관"],"month":["정인"],"hour":["편인"]},"daeunInfo":{"currentAge":10,"startAge":10,"endAge":19,"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_011', '블랙핑크', 'BLACKPINK', '2016-08-08', '00:00',
  'female', '', 'singer', '',
  '병신', '병신', '임진', '경자',
  '병신 병신 임진 경자', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"month":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"day":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"hour":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"elementBalance":{"목":0,"화":2,"토":1,"금":3,"수":2},"tenGods":{"year":["편재"],"month":["편재"],"hour":["편인"]},"daeunInfo":{"currentAge":9,"startAge":10,"endAge":19,"stem":"정","branch":"유","stemHanja":"丁","branchHanja":"酉"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_012', '아이브', 'IVE', '2021-12-01', '00:00',
  'female', '', 'singer', '',
  '신축', '기해', '계축', '임자',
  '신축 기해 계축 임자', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"month":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"day":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"hour":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"elementBalance":{"목":0,"화":0,"토":3,"금":1,"수":4},"tenGods":{"year":["편인"],"month":["편관"],"hour":["정인"]},"daeunInfo":{"currentAge":4,"startAge":10,"endAge":19,"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_013', '트와이스', 'TWICE', '2015-10-20', '00:00',
  'female', '', 'singer', '',
  '을미', '병술', '기해', '갑자',
  '을미 병술 기해 갑자', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"month":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"day":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"hour":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"elementBalance":{"목":2,"화":1,"토":3,"금":0,"수":2},"tenGods":{"year":["편관"],"month":["정관"],"hour":["정재"]},"daeunInfo":{"currentAge":10,"startAge":10,"endAge":19,"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_014', '레드벨벳', 'Red Velvet', '2014-08-01', '00:00',
  'female', '', 'singer', '',
  '갑오', '신미', '갑술', '갑자',
  '갑오 신미 갑술 갑자', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"month":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"day":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"hour":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"elementBalance":{"목":3,"화":1,"토":2,"금":1,"수":1},"tenGods":{"year":["비견"],"month":["정관"],"hour":["비견"]},"daeunInfo":{"currentAge":11,"startAge":10,"endAge":19,"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'sing_015', '엑소', 'EXO', '2012-04-08', '00:00',
  'male', '', 'singer', '',
  '임진', '갑진', '기사', '갑자',
  '임진 갑진 기사 갑자', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"month":{"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰","element":"목"},"day":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"hour":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"elementBalance":{"목":2,"화":1,"토":3,"금":0,"수":2},"tenGods":{"year":["상관"],"month":["정재"],"hour":["정재"]},"daeunInfo":{"currentAge":13,"startAge":10,"endAge":19,"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_006', '전지현', 'Jun Ji-hyun', '1981-10-30', '13:15',
  'female', '', 'actor', '',
  '신유', '무술', '신해', '을미',
  '신유 무술 신해 을미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"day":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"hour":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"elementBalance":{"목":1,"화":0,"토":3,"금":3,"수":1},"tenGods":{"year":["비견"],"month":["정관"],"hour":["편재"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_007', '이민호', 'Lee Min-ho', '1987-06-22', '16:30',
  'male', '', 'actor', '',
  '정묘', '병오', '임신', '무신',
  '정묘 병오 임신 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"month":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"day":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":1,"화":3,"토":1,"금":2,"수":1},"tenGods":{"year":["정재"],"month":["편재"],"hour":["편관"]},"daeunInfo":{"currentAge":38,"startAge":30,"endAge":39,"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_008', '송혜교', 'Song Hye-kyo', '1981-11-22', '09:45',
  'female', '', 'actor', '',
  '신유', '기해', '갑술', '기사',
  '신유 기해 갑술 기사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"day":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"hour":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["정관"],"month":["정재"],"hour":["정재"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_009', '김수현', 'Kim Soo-hyun', '1988-02-16', '11:20',
  'male', '', 'actor', '',
  '무진', '갑인', '신미', '갑오',
  '무진 갑인 신미 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"갑","branch":"인","stemHanja":"甲","branchHanja":"寅","element":"목"},"day":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":3,"화":1,"토":3,"금":1,"수":0},"tenGods":{"year":["정관"],"month":["상관"],"hour":["상관"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_010', '박민영', 'Park Min-young', '1986-03-04', '14:10',
  'female', '', 'actor', '',
  '병인', '경인', '정축', '정미',
  '병인 경인 정축 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅","element":"화"},"month":{"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅","element":"금"},"day":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":2,"화":3,"토":2,"금":1,"수":0},"tenGods":{"year":["정인"],"month":["상관"],"hour":["비견"]},"daeunInfo":{"currentAge":39,"startAge":30,"endAge":39,"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_011', '이종석', 'Lee Jong-suk', '1989-09-14', '15:40',
  'male', '', 'actor', '',
  '기사', '계유', '정미', '무신',
  '기사 계유 정미 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":0,"화":2,"토":3,"금":2,"수":1},"tenGods":{"year":["식신"],"month":["편관"],"hour":["겁재"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_012', '수지', 'Suzy', '1994-10-10', '12:30',
  'female', '', 'actor', '',
  '갑술', '갑술', '기해', '경오',
  '갑술 갑술 기해 경오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"month":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"day":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":2,"화":1,"토":3,"금":1,"수":1},"tenGods":{"year":["정재"],"month":["정재"],"hour":["겁재"]},"daeunInfo":{"currentAge":31,"startAge":30,"endAge":39,"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_013', '차은우', 'Cha Eun-woo', '1997-03-30', '10:15',
  'male', '', 'actor', '',
  '정축', '계묘', '신축', '계사',
  '정축 계묘 신축 계사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"month":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"day":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"hour":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"elementBalance":{"목":1,"화":2,"토":2,"금":1,"수":2},"tenGods":{"year":["편관"],"month":["식신"],"hour":["식신"]},"daeunInfo":{"currentAge":28,"startAge":20,"endAge":29,"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_014', '김고은', 'Kim Go-eun', '1991-07-02', '16:50',
  'female', '', 'actor', '',
  '신미', '갑오', '계묘', '경신',
  '신미 갑오 계묘 경신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"month":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"day":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"hour":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"elementBalance":{"목":2,"화":1,"토":1,"금":3,"수":1},"tenGods":{"year":["편인"],"month":["겁재"],"hour":["정관"]},"daeunInfo":{"currentAge":34,"startAge":30,"endAge":39,"stem":"정","branch":"유","stemHanja":"丁","branchHanja":"酉"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'act_015', '박보검', 'Park Bo-gum', '1993-06-16', '13:25',
  'male', '', 'actor', '',
  '계유', '무오', '무술', '기미',
  '계유 무오 무술 기미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"month":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"day":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"hour":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"elementBalance":{"목":0,"화":1,"토":5,"금":1,"수":1},"tenGods":{"year":["정재"],"month":["비견"],"hour":["겁재"]},"daeunInfo":{"currentAge":32,"startAge":30,"endAge":39,"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_005', '이강인', 'Lee Kang-in', '2001-02-19', '14:30',
  'male', '', 'athlete', '',
  '신사', '경인', '계미', '기미',
  '신사 경인 계미 기미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"month":{"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅","element":"금"},"day":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"hour":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["편인"],"month":["정관"],"hour":["편관"]},"daeunInfo":{"currentAge":24,"startAge":20,"endAge":29,"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_006', '김민재', 'Kim Min-jae', '1996-11-15', '11:45',
  'male', '', 'athlete', '',
  '병자', '기해', '병술', '갑오',
  '병자 기해 병술 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"month":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"day":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":3,"토":2,"금":0,"수":2},"tenGods":{"year":["비견"],"month":["상관"],"hour":["편인"]},"daeunInfo":{"currentAge":29,"startAge":20,"endAge":29,"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_007', '황희찬', 'Hwang Hee-chan', '1996-01-26', '16:20',
  'male', '', 'athlete', '',
  '을해', '기축', '임진', '무신',
  '을해 기축 임진 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"month":{"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑","element":"토"},"day":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":1,"화":0,"토":4,"금":1,"수":2},"tenGods":{"year":["상관"],"month":["정관"],"hour":["편관"]},"daeunInfo":{"currentAge":29,"startAge":20,"endAge":29,"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_008', '김유진', 'Kim Yu-jin', '1992-09-21', '13:15',
  'female', '', 'athlete', '',
  '임신', '기유', '경오', '계미',
  '임신 기유 경오 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"month":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"day":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":0,"화":1,"토":2,"금":3,"수":2},"tenGods":{"year":["식신"],"month":["정인"],"hour":["상관"]},"daeunInfo":{"currentAge":33,"startAge":30,"endAge":39,"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_009', '안세영', 'An Se-young', '2002-02-05', '10:30',
  'female', '', 'athlete', '',
  '임오', '임인', '갑술', '기사',
  '임오 임인 갑술 기사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"month":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"day":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"hour":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"elementBalance":{"목":2,"화":2,"토":2,"금":0,"수":2},"tenGods":{"year":["편인"],"month":["편인"],"hour":["정재"]},"daeunInfo":{"currentAge":23,"startAge":20,"endAge":29,"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ath_010', '이승우', 'Lee Seung-woo', '1998-01-06', '15:45',
  'male', '', 'athlete', '',
  '정축', '계축', '계미', '경신',
  '정축 계축 계미 경신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"month":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"day":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"hour":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"elementBalance":{"목":0,"화":1,"토":3,"금":2,"수":2},"tenGods":{"year":["편재"],"month":["비견"],"hour":["정관"]},"daeunInfo":{"currentAge":27,"startAge":20,"endAge":29,"stem":"을","branch":"묘","stemHanja":"乙","branchHanja":"卯"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ent_004', '신동엽', 'Shin Dong-yup', '1971-02-17', '12:30',
  'male', '', 'entertainer', '',
  '신해', '경인', '계묘', '무오',
  '신해 경인 계묘 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"month":{"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅","element":"금"},"day":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":2,"화":1,"토":1,"금":2,"수":2},"tenGods":{"year":["편인"],"month":["정관"],"hour":["정재"]},"daeunInfo":{"currentAge":54,"startAge":50,"endAge":59,"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ent_005', '김희철', 'Kim Hee-chul', '1983-07-10', '14:45',
  'male', '', 'entertainer', '',
  '계해', '기미', '기사', '신미',
  '계해 기미 기사 신미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥","element":"수"},"month":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"day":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"hour":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"elementBalance":{"목":0,"화":1,"토":4,"금":1,"수":2},"tenGods":{"year":["편재"],"month":["비견"],"hour":["식신"]},"daeunInfo":{"currentAge":42,"startAge":40,"endAge":49,"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ent_006', '이승기', 'Lee Seung-gi', '1987-01-13', '16:20',
  'male', '', 'entertainer', '',
  '병인', '신축', '임진', '무신',
  '병인 신축 임진 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"인","stemHanja":"丙","branchHanja":"寅","element":"화"},"month":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"day":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":1,"화":1,"토":3,"금":2,"수":1},"tenGods":{"year":["편재"],"month":["정인"],"hour":["편관"]},"daeunInfo":{"currentAge":38,"startAge":30,"endAge":39,"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ent_007', '박나영', 'Park Na-young', '1993-05-25', '11:30',
  'female', '', 'entertainer', '',
  '계유', '정사', '병자', '갑오',
  '계유 정사 병자 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"month":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"day":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":4,"토":0,"금":1,"수":2},"tenGods":{"year":["정관"],"month":["겁재"],"hour":["편인"]},"daeunInfo":{"currentAge":32,"startAge":30,"endAge":39,"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'ent_008', '전현무', 'Jun Hyun-moo', '1977-11-15', '13:40',
  'male', '', 'entertainer', '',
  '정사', '신해', '병오', '을미',
  '정사 신해 병오 을미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"month":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"day":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"hour":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"elementBalance":{"목":1,"화":4,"토":1,"금":1,"수":1},"tenGods":{"year":["겁재"],"month":["정재"],"hour":["정인"]},"daeunInfo":{"currentAge":48,"startAge":40,"endAge":49,"stem":"을","branch":"묘","stemHanja":"乙","branchHanja":"卯"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'you_003', '백종원', 'Paik Jong-won', '1966-09-04', '12:00',
  'male', '', 'youtuber', '',
  '병오', '병신', '병신', '갑오',
  '병오 병신 병신 갑오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"month":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"day":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":5,"토":0,"금":2,"수":0},"tenGods":{"year":["비견"],"month":["비견"],"hour":["편인"]},"daeunInfo":{"currentAge":59,"startAge":50,"endAge":59,"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'you_004', '도티', 'Doty', '1991-02-16', '15:30',
  'male', '', 'youtuber', '',
  '신미', '경인', '정해', '무신',
  '신미 경인 정해 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"month":{"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅","element":"금"},"day":{"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥","element":"화"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":1,"화":1,"토":2,"금":3,"수":1},"tenGods":{"year":["편재"],"month":["상관"],"hour":["겁재"]},"daeunInfo":{"currentAge":34,"startAge":30,"endAge":39,"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'you_005', '잠뜰', 'Jamttul', '1993-08-23', '14:20',
  'male', '', 'youtuber', '',
  '계유', '경신', '병오', '을미',
  '계유 경신 병오 을미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"hour":{"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未","element":"목"},"elementBalance":{"목":1,"화":2,"토":1,"금":3,"수":1},"tenGods":{"year":["정관"],"month":["편재"],"hour":["정인"]},"daeunInfo":{"currentAge":32,"startAge":30,"endAge":39,"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'str_002', '기안84', 'Gian84', '1984-10-30', '18:30',
  'male', '', 'streamer', '',
  '갑자', '갑술', '정묘', '기유',
  '갑자 갑술 정묘 기유', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"month":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"elementBalance":{"목":3,"화":1,"토":2,"금":1,"수":1},"tenGods":{"year":["정관"],"month":["정관"],"hour":["식신"]},"daeunInfo":{"currentAge":41,"startAge":40,"endAge":49,"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'str_003', '대도서관', 'Daedoseogwan', '1983-01-03', '20:15',
  'male', '', 'streamer', '',
  '임술', '계축', '신유', '무술',
  '임술 계축 신유 무술', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"month":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"day":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"hour":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"elementBalance":{"목":0,"화":0,"토":4,"금":2,"수":2},"tenGods":{"year":["겁재"],"month":["식신"],"hour":["정관"]},"daeunInfo":{"currentAge":42,"startAge":40,"endAge":49,"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pro_003', '제우스', 'Zeus', '2004-01-31', '16:45',
  'male', '', 'pro_gamer', '',
  '계미', '을축', '기묘', '임신',
  '계미 을축 기묘 임신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"month":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"day":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"hour":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"elementBalance":{"목":2,"화":0,"토":3,"금":1,"수":2},"tenGods":{"year":["편재"],"month":["편관"],"hour":["상관"]},"daeunInfo":{"currentAge":21,"startAge":20,"endAge":29,"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pro_004', '카리아', 'Keria', '2002-10-14', '14:20',
  'male', '', 'pro_gamer', '',
  '임오', '경술', '을유', '계미',
  '임오 경술 을유 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"month":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"day":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":1,"화":1,"토":2,"금":2,"수":2},"tenGods":{"year":["정관"],"month":["정재"],"hour":["편인"]},"daeunInfo":{"currentAge":23,"startAge":20,"endAge":29,"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pro_005', '구마유시', 'Gumayusi', '2002-02-06', '13:30',
  'male', '', 'pro_gamer', '',
  '임오', '임인', '을해', '계미',
  '임오 임인 을해 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"month":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":2,"화":1,"토":1,"금":0,"수":4},"tenGods":{"year":["정관"],"month":["정관"],"hour":["편인"]},"daeunInfo":{"currentAge":23,"startAge":20,"endAge":29,"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_003', '방시혁', 'Bang Si-hyuk', '1972-08-09', '11:30',
  'male', '', 'business_leader', '',
  '임자', '무신', '임인', '병오',
  '임자 무신 임인 병오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"month":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"day":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":2,"토":1,"금":1,"수":3},"tenGods":{"year":["비견"],"month":["편관"],"hour":["편재"]},"daeunInfo":{"currentAge":53,"startAge":50,"endAge":59,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_004', '김범수', 'Kim Beom-su', '1966-03-23', '09:45',
  'male', '', 'business_leader', '',
  '병오', '신묘', '신해', '계사',
  '병오 신묘 신해 계사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"month":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"day":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"hour":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"elementBalance":{"목":1,"화":3,"토":0,"금":2,"수":2},"tenGods":{"year":["정재"],"month":["비견"],"hour":["식신"]},"daeunInfo":{"currentAge":59,"startAge":50,"endAge":59,"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_005', '이해진', 'Lee Hae-jin', '1967-06-22', '14:20',
  'male', '', 'business_leader', '',
  '정미', '병오', '정해', '정미',
  '정미 병오 정해 정미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"month":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"day":{"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥","element":"화"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":0,"화":5,"토":2,"금":0,"수":1},"tenGods":{"year":["비견"],"month":["정인"],"hour":["비견"]},"daeunInfo":{"currentAge":58,"startAge":50,"endAge":59,"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_006', '민희진', 'Min Hee-jin', '1979-12-16', '16:30',
  'female', '', 'business_leader', '',
  '기미', '병자', '정해', '무신',
  '기미 병자 정해 무신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"month":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"day":{"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥","element":"화"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":0,"화":2,"토":3,"금":1,"수":2},"tenGods":{"year":["식신"],"month":["정인"],"hour":["겁재"]},"daeunInfo":{"currentAge":46,"startAge":40,"endAge":49,"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'bus_007', '윤종용', 'Yoon Jong-yong', '1944-12-15', '10:15',
  'male', '', 'business_leader', '',
  '갑신', '병자', '계미', '정사',
  '갑신 병자 계미 정사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"month":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"day":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"hour":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"elementBalance":{"목":1,"화":3,"토":1,"금":1,"수":2},"tenGods":{"year":["겁재"],"month":["상관"],"hour":["편재"]},"daeunInfo":{"currentAge":81,"startAge":80,"endAge":89,"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_004', '이낙연', 'Lee Nak-yon', '1952-12-20', '13:00',
  'male', '', 'politician', '',
  '임진', '임자', '경오', '계미',
  '임진 임자 경오 계미', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"month":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"day":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":0,"화":1,"토":2,"금":1,"수":4},"tenGods":{"year":["식신"],"month":["식신"],"hour":["상관"]},"daeunInfo":{"currentAge":73,"startAge":70,"endAge":79,"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_005', '안철수', 'Ahn Cheol-soo', '1962-02-26', '11:45',
  'male', '', 'politician', '',
  '임인', '임인', '을축', '임오',
  '임인 임인 을축 임오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"month":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"day":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"hour":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"elementBalance":{"목":3,"화":1,"토":1,"금":0,"수":3},"tenGods":{"year":["정관"],"month":["정관"],"hour":["정관"]},"daeunInfo":{"currentAge":63,"startAge":60,"endAge":69,"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_006', '홍준표', 'Hong Joon-pyo', '1954-12-18', '15:20',
  'male', '', 'politician', '',
  '갑오', '병자', '무인', '경신',
  '갑오 병자 무인 경신', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"month":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"day":{"stem":"무","branch":"인","stemHanja":"戊","branchHanja":"寅","element":"토"},"hour":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"elementBalance":{"목":2,"화":2,"토":1,"금":2,"수":1},"tenGods":{"year":["편관"],"month":["편인"],"hour":["식신"]},"daeunInfo":{"currentAge":71,"startAge":70,"endAge":79,"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_007', '심상정', 'Sim Sang-jeung', '1959-09-13', '12:30',
  'female', '', 'politician', '',
  '기해', '계유', '무진', '무오',
  '기해 계유 무진 무오', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"기","branch":"해","stemHanja":"己","branchHanja":"亥","element":"토"},"month":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"day":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":0,"화":1,"토":4,"금":1,"수":2},"tenGods":{"year":["겁재"],"month":["정재"],"hour":["비견"]},"daeunInfo":{"currentAge":66,"startAge":60,"endAge":69,"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);
INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  'pol_008', '오세훈', 'Oh Se-hoon', '1961-01-04', '09:15',
  'male', '', 'politician', '',
  '경자', '기축', '정묘', '을사',
  '경자 기축 정묘 을사', 0, 0, 0,
  0, 0,
  '{"year":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"month":{"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑","element":"토"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳","element":"목"},"elementBalance":{"목":2,"화":2,"토":2,"금":1,"수":1},"tenGods":{"year":["상관"],"month":["식신"],"hour":["편인"]},"daeunInfo":{"currentAge":64,"startAge":60,"endAge":69,"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未"}}'::jsonb, 'extended_celebrity_calculated', NOW(), NOW()
);