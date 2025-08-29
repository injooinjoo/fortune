-- 기존 유명인사 사주 데이터 업데이트 SQL
-- 총 27명의 데이터

UPDATE public.celebrities 
SET 
  year_pillar = '경자',
  month_pillar = '무자', 
  day_pillar = '경술',
  hour_pillar = '계미',
  saju_string = '경자 무자 경술 계미',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"경","branch":"자","stemHanja":"庚","branchHanja":"子","element":"금"},"month":{"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子","element":"토"},"day":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":0,"화":0,"토":3,"금":2,"수":3},"tenGods":{"year":["비견"],"month":["편인"],"hour":["상관"]},"daeunInfo":{"currentAge":65,"startAge":60,"endAge":69,"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'pol_001';
UPDATE public.celebrities 
SET 
  year_pillar = '갑진',
  month_pillar = '병자', 
  day_pillar = '을해',
  hour_pillar = '신사',
  saju_string = '갑진 병자 을해 신사',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰","element":"목"},"month":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"elementBalance":{"목":2,"화":2,"토":1,"금":1,"수":2},"tenGods":{"year":["정인"],"month":["겁재"],"hour":["편관"]},"daeunInfo":{"currentAge":61,"startAge":60,"endAge":69,"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'pol_002';
UPDATE public.celebrities 
SET 
  year_pillar = '계축',
  month_pillar = '병진', 
  day_pillar = '신해',
  hour_pillar = '계사',
  saju_string = '계축 병진 신해 계사',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑","element":"수"},"month":{"stem":"병","branch":"진","stemHanja":"丙","branchHanja":"辰","element":"화"},"day":{"stem":"신","branch":"해","stemHanja":"辛","branchHanja":"亥","element":"금"},"hour":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"elementBalance":{"목":0,"화":2,"토":2,"금":1,"수":3},"tenGods":{"year":["식신"],"month":["정재"],"hour":["식신"]},"daeunInfo":{"currentAge":52,"startAge":50,"endAge":59,"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'pol_003';
UPDATE public.celebrities 
SET 
  year_pillar = '을축',
  month_pillar = '을유', 
  day_pillar = '신묘',
  hour_pillar = '병신',
  saju_string = '을축 을유 신묘 병신',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"month":{"stem":"을","branch":"유","stemHanja":"乙","branchHanja":"酉","element":"목"},"day":{"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯","element":"금"},"hour":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"elementBalance":{"목":3,"화":1,"토":1,"금":3,"수":0},"tenGods":{"year":["편재"],"month":["편재"],"hour":["정재"]},"daeunInfo":{"currentAge":40,"startAge":40,"endAge":49,"stem":"기","branch":"축","stemHanja":"己","branchHanja":"丑"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'act_001';
UPDATE public.celebrities 
SET 
  year_pillar = '신유',
  month_pillar = '신축', 
  day_pillar = '갑자',
  hour_pillar = '경오',
  saju_string = '신유 신축 갑자 경오',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"day":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":1,"토":1,"금":4,"수":1},"tenGods":{"year":["정관"],"month":["정관"],"hour":["편관"]},"daeunInfo":{"currentAge":43,"startAge":40,"endAge":49,"stem":"을","branch":"사","stemHanja":"乙","branchHanja":"巳"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'act_002';
UPDATE public.celebrities 
SET 
  year_pillar = '무진',
  month_pillar = '갑자', 
  day_pillar = '을해',
  hour_pillar = '계미',
  saju_string = '무진 갑자 을해 계미',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":2,"화":0,"토":3,"금":0,"수":3},"tenGods":{"year":["상관"],"month":["정인"],"hour":["편인"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'act_003';
UPDATE public.celebrities 
SET 
  year_pillar = '경신',
  month_pillar = '기묘', 
  day_pillar = '신미',
  hour_pillar = '계사',
  saju_string = '경신 기묘 신미 계사',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"month":{"stem":"기","branch":"묘","stemHanja":"己","branchHanja":"卯","element":"토"},"day":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"hour":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"elementBalance":{"목":1,"화":1,"토":2,"금":3,"수":1},"tenGods":{"year":["정인"],"month":["편인"],"hour":["식신"]},"daeunInfo":{"currentAge":45,"startAge":40,"endAge":49,"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'act_004';
UPDATE public.celebrities 
SET 
  year_pillar = '임술',
  month_pillar = '기유', 
  day_pillar = '신사',
  hour_pillar = '병신',
  saju_string = '임술 기유 신사 병신',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"임","branch":"술","stemHanja":"壬","branchHanja":"戌","element":"수"},"month":{"stem":"기","branch":"유","stemHanja":"己","branchHanja":"酉","element":"토"},"day":{"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳","element":"금"},"hour":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"elementBalance":{"목":0,"화":2,"토":2,"금":3,"수":1},"tenGods":{"year":["겁재"],"month":["편인"],"hour":["정재"]},"daeunInfo":{"currentAge":43,"startAge":40,"endAge":49,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'act_005';
UPDATE public.celebrities 
SET 
  year_pillar = '계유',
  month_pillar = '정사', 
  day_pillar = '정묘',
  hour_pillar = '병오',
  saju_string = '계유 정사 정묘 병오',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"계","branch":"유","stemHanja":"癸","branchHanja":"酉","element":"수"},"month":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":1,"화":5,"토":0,"금":1,"수":1},"tenGods":{"year":["편관"],"month":["비견"],"hour":["정인"]},"daeunInfo":{"currentAge":32,"startAge":30,"endAge":39,"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'sing_001';
UPDATE public.celebrities 
SET 
  year_pillar = '무진',
  month_pillar = '경신', 
  day_pillar = '을해',
  hour_pillar = '계미',
  saju_string = '무진 경신 을해 계미',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"무","branch":"진","stemHanja":"戊","branchHanja":"辰","element":"토"},"month":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"day":{"stem":"을","branch":"해","stemHanja":"乙","branchHanja":"亥","element":"목"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":1,"화":0,"토":3,"금":2,"수":2},"tenGods":{"year":["상관"],"month":["정재"],"hour":["편인"]},"daeunInfo":{"currentAge":37,"startAge":30,"endAge":39,"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'sing_002';
UPDATE public.celebrities 
SET 
  year_pillar = '기사',
  month_pillar = '정묘', 
  day_pillar = '무술',
  hour_pillar = '정사',
  saju_string = '기사 정묘 무술 정사',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"day":{"stem":"무","branch":"술","stemHanja":"戊","branchHanja":"戌","element":"토"},"hour":{"stem":"정","branch":"사","stemHanja":"丁","branchHanja":"巳","element":"화"},"elementBalance":{"목":1,"화":4,"토":3,"금":0,"수":0},"tenGods":{"year":["겁재"],"month":["정인"],"hour":["정인"]},"daeunInfo":{"currentAge":36,"startAge":30,"endAge":39,"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'sing_003';
UPDATE public.celebrities 
SET 
  year_pillar = '계사',
  month_pillar = '무오', 
  day_pillar = '경진',
  hour_pillar = '병자',
  saju_string = '계사 무오 경진 병자',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"month":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"day":{"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰","element":"금"},"hour":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"elementBalance":{"목":0,"화":3,"토":2,"금":1,"수":2},"tenGods":{"year":["상관"],"month":["편인"],"hour":["편관"]},"daeunInfo":{"currentAge":12,"startAge":10,"endAge":19,"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'sing_004';
UPDATE public.celebrities 
SET 
  year_pillar = '임인',
  month_pillar = '정미', 
  day_pillar = '병오',
  hour_pillar = '무자',
  saju_string = '임인 정미 병오 무자',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"임","branch":"인","stemHanja":"壬","branchHanja":"寅","element":"수"},"month":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"day":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"hour":{"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子","element":"토"},"elementBalance":{"목":1,"화":3,"토":2,"금":0,"수":2},"tenGods":{"year":["편관"],"month":["겁재"],"hour":["식신"]},"daeunInfo":{"currentAge":3,"startAge":10,"endAge":19,"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'sing_005';
UPDATE public.celebrities 
SET 
  year_pillar = '임신',
  month_pillar = '정미', 
  day_pillar = '을묘',
  hour_pillar = '계미',
  saju_string = '임신 정미 을묘 계미',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"month":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"day":{"stem":"을","branch":"묘","stemHanja":"乙","branchHanja":"卯","element":"목"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":2,"화":1,"토":2,"금":1,"수":2},"tenGods":{"year":["정관"],"month":["식신"],"hour":["편인"]},"daeunInfo":{"currentAge":33,"startAge":30,"endAge":39,"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'ath_001';
UPDATE public.celebrities 
SET 
  year_pillar = '경오',
  month_pillar = '갑신', 
  day_pillar = '계묘',
  hour_pillar = '무오',
  saju_string = '경오 갑신 계묘 무오',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"month":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"day":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"hour":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"elementBalance":{"목":2,"화":2,"토":1,"금":2,"수":1},"tenGods":{"year":["정관"],"month":["겁재"],"hour":["정재"]},"daeunInfo":{"currentAge":35,"startAge":30,"endAge":39,"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'ath_002';
UPDATE public.celebrities 
SET 
  year_pillar = '신유',
  month_pillar = '경인', 
  day_pillar = '갑진',
  hour_pillar = '임신',
  saju_string = '신유 경인 갑진 임신',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"신","branch":"유","stemHanja":"辛","branchHanja":"酉","element":"금"},"month":{"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅","element":"금"},"day":{"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰","element":"목"},"hour":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"elementBalance":{"목":2,"화":0,"토":1,"금":4,"수":1},"tenGods":{"year":["정관"],"month":["편관"],"hour":["편인"]},"daeunInfo":{"currentAge":44,"startAge":40,"endAge":49,"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'ath_003';
UPDATE public.celebrities 
SET 
  year_pillar = '정묘',
  month_pillar = '계묘', 
  day_pillar = '계묘',
  hour_pillar = '기미',
  saju_string = '정묘 계묘 계묘 기미',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"month":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"day":{"stem":"계","branch":"묘","stemHanja":"癸","branchHanja":"卯","element":"수"},"hour":{"stem":"기","branch":"미","stemHanja":"己","branchHanja":"未","element":"토"},"elementBalance":{"목":3,"화":1,"토":2,"금":0,"수":2},"tenGods":{"year":["편재"],"month":["비견"],"hour":["편관"]},"daeunInfo":{"currentAge":38,"startAge":30,"endAge":39,"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'ath_004';
UPDATE public.celebrities 
SET 
  year_pillar = '임자',
  month_pillar = '무신', 
  day_pillar = '정미',
  hour_pillar = '무신',
  saju_string = '임자 무신 정미 무신',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"임","branch":"자","stemHanja":"壬","branchHanja":"子","element":"수"},"month":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"day":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"hour":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"elementBalance":{"목":0,"화":1,"토":3,"금":2,"수":2},"tenGods":{"year":["정재"],"month":["겁재"],"hour":["겁재"]},"daeunInfo":{"currentAge":53,"startAge":50,"endAge":59,"stem":"계","branch":"축","stemHanja":"癸","branchHanja":"丑"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'ent_001';
UPDATE public.celebrities 
SET 
  year_pillar = '경술',
  month_pillar = '임오', 
  day_pillar = '임진',
  hour_pillar = '병오',
  saju_string = '경술 임오 임진 병오',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"month":{"stem":"임","branch":"오","stemHanja":"壬","branchHanja":"午","element":"수"},"day":{"stem":"임","branch":"진","stemHanja":"壬","branchHanja":"辰","element":"수"},"hour":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"elementBalance":{"목":0,"화":3,"토":2,"금":1,"수":2},"tenGods":{"year":["편인"],"month":["비견"],"hour":["편재"]},"daeunInfo":{"currentAge":55,"startAge":50,"endAge":59,"stem":"정","branch":"해","stemHanja":"丁","branchHanja":"亥"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'ent_002';
UPDATE public.celebrities 
SET 
  year_pillar = '을축',
  month_pillar = '병술', 
  day_pillar = '정묘',
  hour_pillar = '정미',
  saju_string = '을축 병술 정묘 정미',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"을","branch":"축","stemHanja":"乙","branchHanja":"丑","element":"목"},"month":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"day":{"stem":"정","branch":"묘","stemHanja":"丁","branchHanja":"卯","element":"화"},"hour":{"stem":"정","branch":"미","stemHanja":"丁","branchHanja":"未","element":"화"},"elementBalance":{"목":2,"화":3,"토":3,"금":0,"수":0},"tenGods":{"year":["편인"],"month":["정인"],"hour":["비견"]},"daeunInfo":{"currentAge":40,"startAge":40,"endAge":49,"stem":"경","branch":"인","stemHanja":"庚","branchHanja":"寅"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'ent_003';
UPDATE public.celebrities 
SET 
  year_pillar = '신미',
  month_pillar = '신축', 
  day_pillar = '병오',
  hour_pillar = '갑오',
  saju_string = '신미 신축 병오 갑오',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"신","branch":"미","stemHanja":"辛","branchHanja":"未","element":"금"},"month":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"day":{"stem":"병","branch":"오","stemHanja":"丙","branchHanja":"午","element":"화"},"hour":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"elementBalance":{"목":1,"화":3,"토":2,"금":2,"수":0},"tenGods":{"year":["정재"],"month":["정재"],"hour":["편인"]},"daeunInfo":{"currentAge":33,"startAge":30,"endAge":39,"stem":"갑","branch":"진","stemHanja":"甲","branchHanja":"辰"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'you_001';
UPDATE public.celebrities 
SET 
  year_pillar = '기사',
  month_pillar = '정축', 
  day_pillar = '병신',
  hour_pillar = '병신',
  saju_string = '기사 정축 병신 병신',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"기","branch":"사","stemHanja":"己","branchHanja":"巳","element":"토"},"month":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"day":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"hour":{"stem":"병","branch":"신","stemHanja":"丙","branchHanja":"申","element":"화"},"elementBalance":{"목":0,"화":4,"토":2,"금":2,"수":0},"tenGods":{"year":["상관"],"month":["겁재"],"hour":["비견"]},"daeunInfo":{"currentAge":35,"startAge":30,"endAge":39,"stem":"경","branch":"진","stemHanja":"庚","branchHanja":"辰"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'you_002';
UPDATE public.celebrities 
SET 
  year_pillar = '갑자',
  month_pillar = '정축', 
  day_pillar = '경오',
  hour_pillar = '병술',
  saju_string = '갑자 정축 경오 병술',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"갑","branch":"자","stemHanja":"甲","branchHanja":"子","element":"목"},"month":{"stem":"정","branch":"축","stemHanja":"丁","branchHanja":"丑","element":"화"},"day":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"hour":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"elementBalance":{"목":1,"화":3,"토":2,"금":1,"수":1},"tenGods":{"year":["편재"],"month":["정관"],"hour":["편관"]},"daeunInfo":{"currentAge":40,"startAge":40,"endAge":49,"stem":"신","branch":"사","stemHanja":"辛","branchHanja":"巳"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'str_001';
UPDATE public.celebrities 
SET 
  year_pillar = '병자',
  month_pillar = '계사', 
  day_pillar = '갑술',
  hour_pillar = '임신',
  saju_string = '병자 계사 갑술 임신',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"병","branch":"자","stemHanja":"丙","branchHanja":"子","element":"화"},"month":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"day":{"stem":"갑","branch":"술","stemHanja":"甲","branchHanja":"戌","element":"목"},"hour":{"stem":"임","branch":"신","stemHanja":"壬","branchHanja":"申","element":"수"},"elementBalance":{"목":1,"화":2,"토":1,"금":1,"수":3},"tenGods":{"year":["식신"],"month":["정인"],"hour":["편인"]},"daeunInfo":{"currentAge":29,"startAge":20,"endAge":29,"stem":"을","branch":"미","stemHanja":"乙","branchHanja":"未"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'pro_001';
UPDATE public.celebrities 
SET 
  year_pillar = '경신',
  month_pillar = '갑신', 
  day_pillar = '경술',
  hour_pillar = '계미',
  saju_string = '경신 갑신 경술 계미',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"경","branch":"신","stemHanja":"庚","branchHanja":"申","element":"금"},"month":{"stem":"갑","branch":"신","stemHanja":"甲","branchHanja":"申","element":"목"},"day":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"hour":{"stem":"계","branch":"미","stemHanja":"癸","branchHanja":"未","element":"수"},"elementBalance":{"목":1,"화":0,"토":2,"금":4,"수":1},"tenGods":{"year":["비견"],"month":["편재"],"hour":["상관"]},"daeunInfo":{"currentAge":45,"startAge":40,"endAge":49,"stem":"무","branch":"자","stemHanja":"戊","branchHanja":"子"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'pro_002';
UPDATE public.celebrities 
SET 
  year_pillar = '무신',
  month_pillar = '무오', 
  day_pillar = '갑오',
  hour_pillar = '경오',
  saju_string = '무신 무오 갑오 경오',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"무","branch":"신","stemHanja":"戊","branchHanja":"申","element":"토"},"month":{"stem":"무","branch":"오","stemHanja":"戊","branchHanja":"午","element":"토"},"day":{"stem":"갑","branch":"오","stemHanja":"甲","branchHanja":"午","element":"목"},"hour":{"stem":"경","branch":"오","stemHanja":"庚","branchHanja":"午","element":"금"},"elementBalance":{"목":1,"화":3,"토":2,"금":2,"수":0},"tenGods":{"year":["편재"],"month":["편재"],"hour":["편관"]},"daeunInfo":{"currentAge":57,"startAge":50,"endAge":59,"stem":"계","branch":"해","stemHanja":"癸","branchHanja":"亥"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'bus_001';
UPDATE public.celebrities 
SET 
  year_pillar = '경술',
  month_pillar = '병술', 
  day_pillar = '신축',
  hour_pillar = '계사',
  saju_string = '경술 병술 신축 계사',
  wood_count = 0,
  fire_count = 0,
  earth_count = 0,
  metal_count = 0,
  water_count = 0,
  full_saju_data = '{"year":{"stem":"경","branch":"술","stemHanja":"庚","branchHanja":"戌","element":"금"},"month":{"stem":"병","branch":"술","stemHanja":"丙","branchHanja":"戌","element":"화"},"day":{"stem":"신","branch":"축","stemHanja":"辛","branchHanja":"丑","element":"금"},"hour":{"stem":"계","branch":"사","stemHanja":"癸","branchHanja":"巳","element":"수"},"elementBalance":{"목":0,"화":2,"토":3,"금":2,"수":1},"tenGods":{"year":["정인"],"month":["정재"],"hour":["식신"]},"daeunInfo":{"currentAge":55,"startAge":50,"endAge":59,"stem":"신","branch":"묘","stemHanja":"辛","branchHanja":"卯"}}'::jsonb,
  data_source = 'existing_celebrity_calculated',
  updated_at = NOW()
WHERE id = 'bus_002';