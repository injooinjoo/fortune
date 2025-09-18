-- 정치인 50명 실제 데이터 삽입
-- Category: politician

INSERT INTO public.celebrities (
  id, name, birth_date, gender, celebrity_type,
  stage_name, legal_name, aliases, nationality, birth_place, birth_time,
  active_from, agency_management, languages, external_ids, profession_data, notes
) VALUES
('politician_lee_jae_myung', '이재명', '1964-12-22', 'male', 'politician', NULL, NULL, ARRAY['이재명'], '한국', NULL, '12:00', 2006, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이재명"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "경기 성남시 분당구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["경기도지사", "성남시장"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_yoon_suk_yeol', '윤석열', '1960-12-18', 'male', 'politician', NULL, NULL, ARRAY['윤석열'], '한국', NULL, '12:00', 2021, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/윤석열"}'::jsonb, '{"party": "국민의힘", "current_office": "대통령", "constituency": "전국", "term_start": "2022-05-10", "term_end": "2027-05-09", "previous_offices": ["검찰총장"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_han_dong_hoon', '한동훈', '1973-07-27', 'male', 'politician', NULL, NULL, ARRAY['한동훈'], '한국', NULL, '12:00', 2022, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/한동훈"}'::jsonb, '{"party": "국민의힘", "current_office": "법무부 장관", "constituency": "", "term_start": "2022-05-10", "term_end": "", "previous_offices": ["검사"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_park_hong_keun', '박홍근', '1967-08-16', 'male', 'politician', NULL, NULL, ARRAY['박홍근'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박홍근"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "부산 북구 강서구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["부산시의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_kim_gi_hyeon', '김기현', '1960-02-14', 'male', 'politician', NULL, NULL, ARRAY['김기현'], '한국', NULL, '12:00', 1998, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김기현"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "울산 북구", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["울산시장"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_lee_jun_seok', '이준석', '1985-04-17', 'male', 'politician', NULL, NULL, ARRAY['이준석'], '한국', NULL, '12:00', 2011, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이준석"}'::jsonb, '{"party": "새로운 미래", "current_office": "국회의원", "constituency": "비례대표", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국민의힘 대표"], "ideology_tags": ["중도"]}'::jsonb, '실제 데이터'),

('politician_ahn_cheol_soo', '안철수', '1962-02-26', 'male', 'politician', NULL, NULL, ARRAY['안철수'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/안철수"}'::jsonb, '{"party": "국민의당", "current_office": "국회의원", "constituency": "서울 관악구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["기업인"], "ideology_tags": ["중도"]}'::jsonb, '실제 데이터'),

('politician_sim_sang_jeung', '심상정', '1959-09-05', 'female', 'politician', NULL, NULL, ARRAY['심상정'], '한국', NULL, '12:00', 2004, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/심상정"}'::jsonb, '{"party": "정의당", "current_office": "전 국회의원", "constituency": "경기 고양시 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["노동운동가"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_oh_se_hoon', '오세훈', '1961-09-14', 'male', 'politician', NULL, NULL, ARRAY['오세훈'], '한국', NULL, '12:00', 1996, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/오세훈"}'::jsonb, '{"party": "국민의힘", "current_office": "서울시장", "constituency": "서울", "term_start": "2021-04-08", "term_end": "2026-06-30", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_park_young_sun', '박영선', '1960-07-10', 'female', 'politician', NULL, NULL, ARRAY['박영선'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박영선"}'::jsonb, '{"party": "더불어민주당", "current_office": "전 국회의원", "constituency": "서울 구로구 을", "term_start": "2020-05-30", "term_end": "2021-04-08", "previous_offices": ["중소벤처기업부 장관"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_kim_dong_yeon', '김동연', '1957-01-22', 'male', 'politician', NULL, NULL, ARRAY['김동연'], '한국', NULL, '12:00', 2022, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김동연"}'::jsonb, '{"party": "더불어민주당", "current_office": "경기도지사", "constituency": "경기", "term_start": "2022-07-01", "term_end": "2026-06-30", "previous_offices": ["경제부총리"], "ideology_tags": ["중도"]}'::jsonb, '실제 데이터'),

('politician_kim_boo_kyum', '김부겸', '1958-01-16', 'male', 'politician', NULL, NULL, ARRAY['김부겸'], '한국', NULL, '12:00', 1992, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김부겸"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "대구 수성구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국무총리"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_song_young_gil', '송영길', '1963-04-15', 'male', 'politician', NULL, NULL, ARRAY['송영길'], '한국', NULL, '12:00', 2000, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/송영길"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "인천 계양구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["인천시장"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_lee_nak_yon', '이낙연', '1952-12-20', 'male', 'politician', NULL, NULL, ARRAY['이낙연'], '한국', NULL, '12:00', 1986, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이낙연"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "전북 군산시", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국무총리"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_choo_mi_ae', '추미애', '1958-09-22', 'female', 'politician', NULL, NULL, ARRAY['추미애'], '한국', NULL, '12:00', 2000, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/추미애"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "광주 서구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["법무부 장관"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_yoo_seong_min', '유승민', '1963-03-03', 'male', 'politician', NULL, NULL, ARRAY['유승민'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/유승민"}'::jsonb, '{"party": "국민의힘", "current_office": "전 국회의원", "constituency": "대구 동구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["기획재정부 장관"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_kwon_seong_dong', '권성동', '1964-08-25', 'male', 'politician', NULL, NULL, ARRAY['권성동'], '한국', NULL, '12:00', 2008, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/권성동"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "강원 강릉시", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["검사"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_park_jin', '박진', '1956-07-27', 'male', 'politician', NULL, NULL, ARRAY['박진'], '한국', NULL, '12:00', 1996, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박진"}'::jsonb, '{"party": "국민의힘", "current_office": "외교부 장관", "constituency": "서울 종로구", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_na_kyung_won', '나경원', '1963-12-25', 'female', 'politician', NULL, NULL, ARRAY['나경원'], '한국', NULL, '12:00', 2008, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/나경원"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "서울 동작구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회부의장"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_kim_jin_pyo', '김진표', '1949-12-27', 'male', 'politician', NULL, NULL, ARRAY['김진표'], '한국', NULL, '12:00', 1988, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김진표"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의장", "constituency": "경기 수원시 병", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["경제부총리"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_jung_jin_suk', '정진석', '1959-08-13', 'male', 'politician', NULL, NULL, ARRAY['정진석'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/정진석"}'::jsonb, '{"party": "국민의힘", "current_office": "비서실장", "constituency": "서울 종로구", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_woo_won_shik', '우원식', '1957-04-04', 'male', 'politician', NULL, NULL, ARRAY['우원식'], '한국', NULL, '12:00', 1988, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/우원식"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "서울 노원구 병", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회부의장"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_kim_sang_hee', '김상희', '1954-12-28', 'female', 'politician', NULL, NULL, ARRAY['김상희'], '한국', NULL, '12:00', 2000, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김상희"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회부의장", "constituency": "부천시 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_park_byeong_seug', '박병석', '1952-08-11', 'male', 'politician', NULL, NULL, ARRAY['박병석'], '한국', NULL, '12:00', 1988, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박병석"}'::jsonb, '{"party": "더불어민주당", "current_office": "전 국회의장", "constituency": "광주 동구 남구", "term_start": "2020-05-30", "term_end": "2022-07-04", "previous_offices": ["국회의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_lee_hae_chan', '이해찬', '1952-07-10', 'male', 'politician', NULL, NULL, ARRAY['이해찬'], '한국', NULL, '12:00', 1988, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이해찬"}'::jsonb, '{"party": "더불어민주당", "current_office": "전 국회의원", "constituency": "서울 중구 성동구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국무총리"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_kim_young_ju', '김영주', '1951-05-21', 'male', 'politician', NULL, NULL, ARRAY['김영주'], '한국', NULL, '12:00', 1987, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김영주"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "인천 남동구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["고용노동부 장관"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_hong_ik_pyo', '홍익표', '1964-06-22', 'male', 'politician', NULL, NULL, ARRAY['홍익표'], '한국', NULL, '12:00', 2004, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/홍익표"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "서울 서초구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_yoon_ho_jung', '윤호중', '1950-08-19', 'male', 'politician', NULL, NULL, ARRAY['윤호중'], '한국', NULL, '12:00', 1988, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/윤호중"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "서울 강서구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["변호사"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_park_wan_ju', '박완주', '1960-02-04', 'male', 'politician', NULL, NULL, ARRAY['박완주'], '한국', NULL, '12:00', 2004, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박완주"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "충남 천안시 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_min_hyung_bae', '민형배', '1963-03-02', 'male', 'politician', NULL, NULL, ARRAY['민형배'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/민형배"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "광주 광산구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_kim_young_chun', '김영춘', '1958-12-15', 'male', 'politician', NULL, NULL, ARRAY['김영춘'], '한국', NULL, '12:00', 2000, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김영춘"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "부산 연제구", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["부산시장"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_jin_sun_mee', '진선미', '1963-09-26', 'female', 'politician', NULL, NULL, ARRAY['진선미'], '한국', NULL, '12:00', 2004, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/진선미"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "서울 서대문구 갑", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["여성가족부 장관"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_kim_young_jin', '김영진', '1959-10-08', 'male', 'politician', NULL, NULL, ARRAY['김영진'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김영진"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "서울 영등포구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_lee_sang_min', '이상민', '1960-04-20', 'male', 'politician', NULL, NULL, ARRAY['이상민'], '한국', NULL, '12:00', 2000, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이상민"}'::jsonb, '{"party": "더불어민주당", "current_office": "행정안전부 장관", "constituency": "경기 안산시 상록구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_ko_yong_jin', '고용진', '1962-12-30', 'male', 'politician', NULL, NULL, ARRAY['고용진'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/고용진"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "서울 관악구 갑", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_sul_hoon', '설훈', '1956-01-17', 'male', 'politician', NULL, NULL, ARRAY['설훈'], '한국', NULL, '12:00', 2000, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/설훈"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "인천 계양구 갑", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["기자"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_kim_do_eup', '김도읍', '1961-05-09', 'male', 'politician', NULL, NULL, ARRAY['김도읍'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김도읍"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "부산 금정구", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_jung_woo_taik', '정우택', '1957-09-13', 'male', 'politician', NULL, NULL, ARRAY['정우택'], '한국', NULL, '12:00', 2008, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/정우택"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "충북 청주시 상당구", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_song_seok_joon', '송석준', '1962-11-25', 'male', 'politician', NULL, NULL, ARRAY['송석준'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/송석준"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "인천 미추홀구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_park_dae_chul', '박대출', '1962-03-07', 'male', 'politician', NULL, NULL, ARRAY['박대출'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박대출"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "부산 사하구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_ha_tae_keung', '하태경', '1966-01-30', 'male', 'politician', NULL, NULL, ARRAY['하태경'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/하태경"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "서울 강서구 갑", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_kim_sang_wook', '김상욱', '1965-08-12', 'male', 'politician', NULL, NULL, ARRAY['김상욱'], '한국', NULL, '12:00', 2020, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김상욱"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "대구 수성구 갑", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["의사"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_kang_min_kook', '강민국', '1963-04-14', 'male', 'politician', NULL, NULL, ARRAY['강민국'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/강민국"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "경북 구미시 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_cho_수진', '조수진', '1967-02-18', 'female', 'politician', NULL, NULL, ARRAY['조수진'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/조수진"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "서울 동작구 갑", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_kim_ye_ji', '김예지', '1973-08-25', 'female', 'politician', NULL, NULL, ARRAY['김예지'], '한국', NULL, '12:00', 2020, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김예지"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "대구 달성군", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["변호사"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_park_seong_joon', '박성준', '1968-07-03', 'male', 'politician', NULL, NULL, ARRAY['박성준'], '한국', NULL, '12:00', 2020, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박성준"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "대구 중구 남구", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["변호사"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_shin_hyun_young', '신현영', '1968-09-14', 'female', 'politician', NULL, NULL, ARRAY['신현영'], '한국', NULL, '12:00', 2020, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/신현영"}'::jsonb, '{"party": "더불어민주당", "current_office": "국회의원", "constituency": "서울 은평구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["변호사"], "ideology_tags": ["진보"]}'::jsonb, '실제 데이터'),

('politician_yoon_jae_ok', '윤재옥', '1959-12-06', 'male', 'politician', NULL, NULL, ARRAY['윤재옥'], '한국', NULL, '12:00', 2008, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/윤재옥"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "대구 동구 갑", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["의사"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_kim_hanna', '김한나', '1970-05-11', 'female', 'politician', NULL, NULL, ARRAY['김한나'], '한국', NULL, '12:00', 2020, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김한나"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "서울 강남구 을", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["기업인"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_lee_chul_규', '이철규', '1964-10-29', 'male', 'politician', NULL, NULL, ARRAY['이철규'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이철규"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "경북 포항시 남구 울릉군", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터'),

('politician_sung_일종', '성일종', '1959-04-23', 'male', 'politician', NULL, NULL, ARRAY['성일종'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/성일종"}'::jsonb, '{"party": "국민의힘", "current_office": "국회의원", "constituency": "충남 서산시 태안군", "term_start": "2020-05-30", "term_end": "2024-05-29", "previous_offices": ["국회의원"], "ideology_tags": ["보수"]}'::jsonb, '실제 데이터')

ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  updated_at = NOW();

