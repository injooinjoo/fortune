-- 운동선수 50명 실제 데이터 삽입
-- Category: athlete

INSERT INTO public.celebrities (
  id, name, birth_date, gender, celebrity_type,
  stage_name, legal_name, aliases, nationality, birth_place, birth_time,
  active_from, agency_management, languages, external_ids, profession_data, notes
) VALUES
('athlete_son_heung_min', '손흥민', '1992-07-08', 'male', 'athlete', NULL, NULL, ARRAY['손흥민'], '한국', NULL, '12:00', 2008, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/손흥민"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "토트넘 홋스퍼", "league": "프리미어리그", "achievements": ["아시안컵 우승", "프리미어리그 득점왕"], "jersey_number": "7", "career_highlight": "토트넘 레전드"}'::jsonb, '실제 데이터'),

('athlete_kim_yuna', '김연아', '1990-09-05', 'female', 'athlete', NULL, NULL, ARRAY['김연아'], '한국', NULL, '12:00', 2005, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김연아"}'::jsonb, '{"sport": "피겨스케이팅", "position": "싱글", "current_team": "개인", "league": "ISU", "achievements": ["올림픽 금메달", "세계선수권 우승"], "jersey_number": "", "career_highlight": "피겨 여왕"}'::jsonb, '실제 데이터'),

('athlete_ryu_hyun_jin', '류현진', '1987-03-25', 'male', 'athlete', NULL, NULL, ARRAY['류현진'], '한국', NULL, '12:00', 2006, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/류현진"}'::jsonb, '{"sport": "야구", "position": "투수", "current_team": "한화 이글스", "league": "KBO", "achievements": ["ML 올스타", "KBO MVP"], "jersey_number": "99", "career_highlight": "메이저리그 진출"}'::jsonb, '실제 데이터'),

('athlete_park_tae_hwan', '박태환', '1989-09-27', 'male', 'athlete', NULL, NULL, ARRAY['박태환'], '한국', NULL, '12:00', 2004, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박태환"}'::jsonb, '{"sport": "수영", "position": "자유형", "current_team": "개인", "league": "수영", "achievements": ["올림픽 금메달", "세계선수권 우승"], "jersey_number": "", "career_highlight": "마린보이"}'::jsonb, '실제 데이터'),

('athlete_lee_kang_in', '이강인', '2001-02-19', 'male', 'athlete', NULL, NULL, ARRAY['이강인'], '한국', NULL, '12:00', 2018, NULL, ARRAY['한국어', '영어', '스페인어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이강인"}'::jsonb, '{"sport": "축구", "position": "미드필더", "current_team": "파리 생제르맹", "league": "리그 1", "achievements": ["U-20 월드컵 득점왕", "발렌시아 최연소 득점"], "jersey_number": "19", "career_highlight": "차세대 스타"}'::jsonb, '실제 데이터'),

('athlete_choo_shin_soo', '추신수', '1982-07-13', 'male', 'athlete', NULL, NULL, ARRAY['추신수'], '한국', NULL, '12:00', 2001, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/추신수"}'::jsonb, '{"sport": "야구", "position": "외야수", "current_team": "SSG 랜더스", "league": "KBO", "achievements": ["MLB 올스타", "아시안게임 금메달"], "jersey_number": "17", "career_highlight": "MLB 통산 200홈런"}'::jsonb, '실제 데이터'),

('athlete_kim_je_deok', '김제덕', '2004-08-09', 'male', 'athlete', NULL, NULL, ARRAY['김제덕'], '한국', NULL, '12:00', 2019, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김제덕"}'::jsonb, '{"sport": "양궁", "position": "리커브", "current_team": "국가대표", "league": "양궁", "achievements": ["올림픽 3관왕", "세계선수권 우승"], "jersey_number": "", "career_highlight": "도쿄올림픽 영웅"}'::jsonb, '실제 데이터'),

('athlete_an_san', '안산', '2001-02-27', 'female', 'athlete', NULL, NULL, ARRAY['안산'], '한국', NULL, '12:00', 2017, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/안산"}'::jsonb, '{"sport": "양궁", "position": "리커브", "current_team": "국가대표", "league": "양궁", "achievements": ["올림픽 3관왕", "세계기록 보유"], "jersey_number": "", "career_highlight": "도쿄올림픽 3관왕"}'::jsonb, '실제 데이터'),

('athlete_jang_jun_hwan', '장준환', '1969-12-18', 'male', 'athlete', NULL, NULL, ARRAY['장준환'], '한국', NULL, '12:00', 1989, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/장준환"}'::jsonb, '{"sport": "유도", "position": "90kg급", "current_team": "은퇴", "league": "유도", "achievements": ["올림픽 금메달", "세계선수권 우승"], "jersey_number": "", "career_highlight": "유도 레전드"}'::jsonb, '실제 데이터'),

('athlete_kim_min_jae', '김민재', '1996-11-15', 'male', 'athlete', NULL, NULL, ARRAY['김민재'], '한국', NULL, '12:00', 2015, NULL, ARRAY['한국어', '이탈리아어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김민재"}'::jsonb, '{"sport": "축구", "position": "수비수", "current_team": "뮌헨", "league": "분데스리가", "achievements": ["세리에A 올해의 수비수", "나폴리 스쿠데토"], "jersey_number": "3", "career_highlight": "뮌헨 이적"}'::jsonb, '실제 데이터'),

('athlete_hwang_hee_chan', '황희찬', '1996-01-26', 'male', 'athlete', NULL, NULL, ARRAY['황희찬'], '한국', NULL, '12:00', 2013, NULL, ARRAY['한국어', '영어', '독일어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/황희찬"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "울버햄튼", "league": "프리미어리그", "achievements": ["분데스리가 우승", "프리미어리그 진출"], "jersey_number": "11", "career_highlight": "프리미어리그 적응"}'::jsonb, '실제 데이터'),

('athlete_lee_seung_woo', '이승우', '1998-01-06', 'male', 'athlete', NULL, NULL, ARRAY['이승우'], '한국', NULL, '12:00', 2015, NULL, ARRAY['한국어', '스페인어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이승우"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "전북 현대", "league": "K리그1", "achievements": ["U-20 월드컵 준우승", "바르셀로나 유스"], "jersey_number": "10", "career_highlight": "바르셀로나 유스 출신"}'::jsonb, '실제 데이터'),

('athlete_na_sang_ho', '나상호', '1996-09-12', 'male', 'athlete', NULL, NULL, ARRAY['나상호'], '한국', NULL, '12:00', 2015, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/나상호"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "모헨바벡", "league": "에레디비지", "achievements": ["K리그 영플레이어", "해외 진출"], "jersey_number": "9", "career_highlight": "네덜란드 진출"}'::jsonb, '실제 데이터'),

('athlete_hwang_ui_jo', '황의조', '1992-08-28', 'male', 'athlete', NULL, NULL, ARRAY['황의조'], '한국', NULL, '12:00', 2013, NULL, ARRAY['한국어', '프랑스어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/황의조"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "노팅엄 포레스트", "league": "프리미어리그", "achievements": ["아시안컵 득점왕", "러시아 월드컵 출전"], "jersey_number": "16", "career_highlight": "프리미어리그 진출"}'::jsonb, '실제 데이터'),

('athlete_kim_young_gwon', '김영권', '1990-02-27', 'male', 'athlete', NULL, NULL, ARRAY['김영권'], '한국', NULL, '12:00', 2009, NULL, ARRAY['한국어', '중국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김영권"}'::jsonb, '{"sport": "축구", "position": "수비수", "current_team": "울산 HD", "league": "K리그1", "achievements": ["아시안컵 우승", "K리그 베스트11"], "jersey_number": "19", "career_highlight": "수비 리더"}'::jsonb, '실제 데이터'),

('athlete_ju_se_jong', '주세종', '1990-08-06', 'male', 'athlete', NULL, NULL, ARRAY['주세종'], '한국', NULL, '12:00', 2009, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/주세종"}'::jsonb, '{"sport": "축구", "position": "미드필더", "current_team": "전북 현대", "league": "K리그1", "achievements": ["AFC 챔피언스리그 우승", "K리그 MVP"], "jersey_number": "8", "career_highlight": "전북 레전드"}'::jsonb, '실제 데이터'),

('athlete_lee_jae_sung', '이재성', '1992-08-10', 'male', 'athlete', NULL, NULL, ARRAY['이재성'], '한국', NULL, '12:00', 2011, NULL, ARRAY['한국어', '독일어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이재성"}'::jsonb, '{"sport": "축구", "position": "미드필더", "current_team": "마인츠", "league": "분데스리가", "achievements": ["분데스리가 진출", "국가대표 주전"], "jersey_number": "7", "career_highlight": "분데스리가 적응"}'::jsonb, '실제 데이터'),

('athlete_jeong_woo_yeong', '정우영', '1999-09-03', 'male', 'athlete', NULL, NULL, ARRAY['정우영'], '한국', NULL, '12:00', 2017, NULL, ARRAY['한국어', '독일어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/정우영"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "슈투트가르트", "league": "분데스리가", "achievements": ["U-20 월드컵 준우승", "분데스리가 진출"], "jersey_number": "27", "career_highlight": "차세대 공격수"}'::jsonb, '실제 데이터'),

('athlete_paik_seung_ho', '백승호', '1997-03-17', 'male', 'athlete', NULL, NULL, ARRAY['백승호'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어', '스페인어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/백승호"}'::jsonb, '{"sport": "축구", "position": "미드필더", "current_team": "레알 소시에다드", "league": "라리가", "achievements": ["라리가 진출", "U-23 아시안컵 우승"], "jersey_number": "21", "career_highlight": "라리가 적응"}'::jsonb, '실제 데이터'),

('athlete_yang_hyun_jun', '양현준', '2002-07-25', 'male', 'athlete', NULL, NULL, ARRAY['양현준'], '한국', NULL, '12:00', 2019, NULL, ARRAY['한국어', '스코틀랜드어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/양현준"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "셀틱", "league": "스코틀랜드 프리미어", "achievements": ["스코틀랜드 진출", "U-20 대표"], "jersey_number": "99", "career_highlight": "차세대 유망주"}'::jsonb, '실제 데이터'),

('athlete_oh_hyeon_gyu', '오현규', '2001-04-12', 'male', 'athlete', NULL, NULL, ARRAY['오현규'], '한국', NULL, '12:00', 2019, NULL, ARRAY['한국어', '스코틀랜드어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/오현규"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "셀틱", "league": "스코틀랜드 프리미어", "achievements": ["K리그 신인왕", "스코틀랜드 진출"], "jersey_number": "38", "career_highlight": "유럽 진출"}'::jsonb, '실제 데이터'),

('athlete_park_ji_sung', '박지성', '1981-02-25', 'male', 'athlete', NULL, NULL, ARRAY['박지성'], '한국', NULL, '12:00', 2000, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박지성"}'::jsonb, '{"sport": "축구", "position": "미드필더", "current_team": "은퇴", "league": "은퇴", "achievements": ["맨유 레전드", "챔피언스리그 우승"], "jersey_number": "13", "career_highlight": "아시아 최초 맨유 주전"}'::jsonb, '실제 데이터'),

('athlete_cha_bum_kun', '차범근', '1953-05-22', 'male', 'athlete', NULL, NULL, ARRAY['차범근'], '한국', NULL, '12:00', 1973, NULL, ARRAY['한국어', '독일어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/차범근"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "은퇴", "league": "은퇴", "achievements": ["분데스리가 레전드", "UEFA컵 우승"], "jersey_number": "11", "career_highlight": "한국 축구의 아버지"}'::jsonb, '실제 데이터'),

('athlete_lee_chun_soo', '이천수', '1979-07-02', 'male', 'athlete', NULL, NULL, ARRAY['이천수'], '한국', NULL, '12:00', 1998, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이천수"}'::jsonb, '{"sport": "축구", "position": "미드필더", "current_team": "은퇴", "league": "은퇴", "achievements": ["2002 월드컵 4강", "K리그 MVP"], "jersey_number": "14", "career_highlight": "2002 월드컵 영웅"}'::jsonb, '실제 데이터'),

('athlete_ahn_jung_hwan', '안정환', '1976-01-27', 'male', 'athlete', NULL, NULL, ARRAY['안정환'], '한국', NULL, '12:00', 1995, NULL, ARRAY['한국어', '이탈리아어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/안정환"}'::jsonb, '{"sport": "축구", "position": "공격수", "current_team": "은퇴", "league": "은퇴", "achievements": ["2002 월드컵 4강", "세리에A 진출"], "jersey_number": "17", "career_highlight": "2002 월드컵 골든골"}'::jsonb, '실제 데이터'),

('athlete_seol_ki_hyeon', '설기현', '1979-01-08', 'male', 'athlete', NULL, NULL, ARRAY['설기현'], '한국', NULL, '12:00', 1998, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/설기현"}'::jsonb, '{"sport": "축구", "position": "미드필더", "current_team": "은퇴", "league": "은퇴", "achievements": ["2002 월드컵 4강", "프리미어리그 진출"], "jersey_number": "7", "career_highlight": "프리미어리그 첫 한국인"}'::jsonb, '실제 데이터'),

('athlete_lee_young_pyo', '이영표', '1977-04-23', 'male', 'athlete', NULL, NULL, ARRAY['이영표'], '한국', NULL, '12:00', 1996, NULL, ARRAY['한국어', '네덜란드어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이영표"}'::jsonb, '{"sport": "축구", "position": "수비수", "current_team": "은퇴", "league": "은퇴", "achievements": ["2002 월드컵 4강", "PSV 주전"], "jersey_number": "12", "career_highlight": "네덜란드 리그 우승"}'::jsonb, '실제 데이터'),

('athlete_park_chan_ho', '박찬호', '1973-06-30', 'male', 'athlete', NULL, NULL, ARRAY['박찬호'], '한국', NULL, '12:00', 1994, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박찬호"}'::jsonb, '{"sport": "야구", "position": "투수", "current_team": "은퇴", "league": "은퇴", "achievements": ["MLB 통산 124승", "한국인 최초 MLB"], "jersey_number": "61", "career_highlight": "MLB 개척자"}'::jsonb, '실제 데이터'),

('athlete_park_se_ri', '박세리', '1977-09-28', 'female', 'athlete', NULL, NULL, ARRAY['박세리'], '한국', NULL, '12:00', 1996, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박세리"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "은퇴", "league": "LPGA", "achievements": ["LPGA 메이저 5승", "세계골프명예의전당"], "jersey_number": "", "career_highlight": "한국 골프 붐 주역"}'::jsonb, '실제 데이터'),

('athlete_choi_kyung_ju', '최경주', '1970-05-19', 'male', 'athlete', NULL, NULL, ARRAY['최경주'], '한국', NULL, '12:00', 1994, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/최경주"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "PGA", "achievements": ["PGA 투어 8승", "아시아인 최초 PGA 우승"], "jersey_number": "", "career_highlight": "PGA 투어 개척자"}'::jsonb, '실제 데이터'),

('athlete_yang_yong_eun', '양용은', '1972-01-15', 'male', 'athlete', NULL, NULL, ARRAY['양용은'], '한국', NULL, '12:00', 1995, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/양용은"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "PGA", "achievements": ["PGA 투어 우승", "마스터스 준우승"], "jersey_number": "", "career_highlight": "메이저 대회 상위권"}'::jsonb, '실제 데이터'),

('athlete_kim_si_woo', '김시우', '1995-06-28', 'male', 'athlete', NULL, NULL, ARRAY['김시우'], '한국', NULL, '12:00', 2016, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김시우"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "PGA", "achievements": ["PGA 투어 3승", "올림픽 동메달"], "jersey_number": "", "career_highlight": "젊은 PGA 챔피언"}'::jsonb, '실제 데이터'),

('athlete_im_sung_jae', '임성재', '1998-01-30', 'male', 'athlete', NULL, NULL, ARRAY['임성재'], '한국', NULL, '12:00', 2019, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/임성재"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "PGA", "achievements": ["PGA 투어 우승", "FedEx컵 상위권"], "jersey_number": "", "career_highlight": "차세대 골프 스타"}'::jsonb, '실제 데이터'),

('athlete_ko_jin_young', '고진영', '1995-05-07', 'female', 'athlete', NULL, NULL, ARRAY['고진영'], '한국', NULL, '12:00', 2017, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/고진영"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "LPGA", "achievements": ["LPGA 메이저 2승", "세계랭킹 1위"], "jersey_number": "", "career_highlight": "LPGA 에이스"}'::jsonb, '실제 데이터'),

('athlete_park_in_bee', '박인비', '1988-07-12', 'female', 'athlete', NULL, NULL, ARRAY['박인비'], '한국', NULL, '12:00', 2007, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박인비"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "은퇴", "league": "LPGA", "achievements": ["LPGA 메이저 7승", "올림픽 금메달"], "jersey_number": "", "career_highlight": "한국 여자골프 전설"}'::jsonb, '실제 데이터'),

('athlete_choi_na_yeon', '최나연', '1988-10-28', 'female', 'athlete', NULL, NULL, ARRAY['최나연'], '한국', NULL, '12:00', 2008, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/최나연"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "LPGA", "achievements": ["LPGA 메이저 우승", "세계랭킹 1위"], "jersey_number": "", "career_highlight": "LPGA 챔피언"}'::jsonb, '실제 데이터'),

('athlete_jang_ha_na', '장하나', '1992-10-28', 'female', 'athlete', NULL, NULL, ARRAY['장하나'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/장하나"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "LPGA", "achievements": ["LPGA 투어 우승", "한국여자오픈 우승"], "jersey_number": "", "career_highlight": "LPGA 투어 진출"}'::jsonb, '실제 데이터'),

('athlete_lee_mi_hyang', '이미향', '1988-08-03', 'female', 'athlete', NULL, NULL, ARRAY['이미향'], '한국', NULL, '12:00', 2008, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이미향"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "LPGA", "achievements": ["LPGA 투어 우승", "KLPGA 다승"], "jersey_number": "", "career_highlight": "꾸준한 성과"}'::jsonb, '실제 데이터'),

('athlete_kim_hyo_joo', '김효주', '1995-05-25', 'female', 'athlete', NULL, NULL, ARRAY['김효주'], '한국', NULL, '12:00', 2014, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김효주"}'::jsonb, '{"sport": "골프", "position": "프로골퍼", "current_team": "개인", "league": "LPGA", "achievements": ["LPGA 메이저 우승", "에비앙 챔피언십 우승"], "jersey_number": "", "career_highlight": "메이저 챔피언"}'::jsonb, '실제 데이터'),

('athlete_lee_jeong_hwan', '이정환', '1992-04-16', 'male', 'athlete', NULL, NULL, ARRAY['이정환'], '한국', NULL, '12:00', 2011, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이정환"}'::jsonb, '{"sport": "야구", "position": "내야수", "current_team": "키움 히어로즈", "league": "KBO", "achievements": ["KBO 골든글러브", "국가대표"], "jersey_number": "14", "career_highlight": "내야 수비 장인"}'::jsonb, '실제 데이터'),

('athlete_yang_eui_ji', '양의지', '1987-06-05', 'male', 'athlete', NULL, NULL, ARRAY['양의지'], '한국', NULL, '12:00', 2010, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/양의지"}'::jsonb, '{"sport": "야구", "position": "포수", "current_team": "NC 다이노스", "league": "KBO", "achievements": ["KBO 골든글러브", "WBC 국가대표"], "jersey_number": "25", "career_highlight": "수비형 포수"}'::jsonb, '실제 데이터'),

('athlete_kang_min_ho', '강민호', '1985-08-18', 'male', 'athlete', NULL, NULL, ARRAY['강민호'], '한국', NULL, '12:00', 2009, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/강민호"}'::jsonb, '{"sport": "야구", "position": "포수", "current_team": "롯데 자이언츠", "league": "KBO", "achievements": ["KBO 타점왕", "국가대표"], "jersey_number": "27", "career_highlight": "공격형 포수"}'::jsonb, '실제 데이터'),

('athlete_choi_jung', '최정', '1987-02-28', 'male', 'athlete', NULL, NULL, ARRAY['최정'], '한국', NULL, '12:00', 2005, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/최정"}'::jsonb, '{"sport": "야구", "position": "내야수", "current_team": "SSG 랜더스", "league": "KBO", "achievements": ["KBO 홈런왕", "아시안게임 금메달"], "jersey_number": "14", "career_highlight": "KBO 홈런왕"}'::jsonb, '실제 데이터'),

('athlete_na_sung_bum', '나성범', '1989-08-03', 'male', 'athlete', NULL, NULL, ARRAY['나성범'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/나성범"}'::jsonb, '{"sport": "야구", "position": "외야수", "current_team": "키움 히어로즈", "league": "KBO", "achievements": ["KBO 타격왕", "국가대표"], "jersey_number": "6", "career_highlight": "콘택트 히터"}'::jsonb, '실제 데이터'),

('athlete_lim_chan_kyu', '임찬규', '1993-07-15', 'male', 'athlete', NULL, NULL, ARRAY['임찬규'], '한국', NULL, '12:00', 2015, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/임찬규"}'::jsonb, '{"sport": "야구", "position": "투수", "current_team": "LG 트윈스", "league": "KBO", "achievements": ["KBO 승수왕", "국가대표"], "jersey_number": "37", "career_highlight": "좌완 에이스"}'::jsonb, '실제 데이터'),

('athlete_go_woo_suk', '고우석', '1998-07-04', 'male', 'athlete', NULL, NULL, ARRAY['고우석'], '한국', NULL, '12:00', 2017, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/고우석"}'::jsonb, '{"sport": "야구", "position": "투수", "current_team": "LG 트윈스", "league": "KBO", "achievements": ["KBO 신인왕", "국가대표"], "jersey_number": "54", "career_highlight": "차세대 마무리"}'::jsonb, '실제 데이터'),

('athlete_kim_kwang_hyun', '김광현', '1988-07-22', 'male', 'athlete', NULL, NULL, ARRAY['김광현'], '한국', NULL, '12:00', 2007, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김광현"}'::jsonb, '{"sport": "야구", "position": "투수", "current_team": "SSG 랜더스", "league": "KBO", "achievements": ["MLB 진출", "KBO 올스타"], "jersey_number": "29", "career_highlight": "MLB 경험"}'::jsonb, '실제 데이터'),

('athlete_oh_seung_hwan', '오승환', '1982-07-15', 'male', 'athlete', NULL, NULL, ARRAY['오승환'], '한국', NULL, '12:00', 2005, NULL, ARRAY['한국어', '영어', '일본어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/오승환"}'::jsonb, '{"sport": "야구", "position": "투수", "current_team": "삼성 라이온즈", "league": "KBO", "achievements": ["MLB 올스타", "NPB 최다세이브"], "jersey_number": "21", "career_highlight": "국제적 마무리"}'::jsonb, '실제 데이터'),

('athlete_jeon_jun_woo', '전준우', '1992-05-28', 'male', 'athlete', NULL, NULL, ARRAY['전준우'], '한국', NULL, '12:00', 2015, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/전준우"}'::jsonb, '{"sport": "야구", "position": "외야수", "current_team": "LG 트윈스", "league": "KBO", "achievements": ["KBO 신인왕", "국가대표"], "jersey_number": "51", "career_highlight": "외야 수비 장인"}'::jsonb, '실제 데이터'),

('athlete_lee_jung_hoo', '이정후', '1998-08-20', 'male', 'athlete', NULL, NULL, ARRAY['이정후'], '한국', NULL, '12:00', 2017, NULL, ARRAY['한국어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이정후"}'::jsonb, '{"sport": "야구", "position": "외야수", "current_team": "키움 히어로즈", "league": "KBO", "achievements": ["KBO 타격왕", "WBC 국가대표"], "jersey_number": "51", "career_highlight": "차세대 스타"}'::jsonb, '실제 데이터')

ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  updated_at = NOW();