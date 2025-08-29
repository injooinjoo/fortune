-- 추가 유명인사 사주 데이터 삽입 SQL
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