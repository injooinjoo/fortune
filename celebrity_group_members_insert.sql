-- 그룹 멤버 개별 사주 데이터 삽입 SQL
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
);