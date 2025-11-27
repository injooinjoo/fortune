-- 정치인 데이터 삽입 (100명)
-- 생성일: 2025-11-28
-- 한국 역대 대통령, 국회의원, 정당 대표 등

INSERT INTO public.celebrities (
    id, name, name_en, legal_name, category, gender,
    birth_date, mbti, blood_type, is_group_member, group_name,
    description, keywords, popularity_score, is_active
) VALUES

-- ===== 역대 대통령 =====
('politician_yoon_seokyoul', '윤석열', 'Yoon Suk-yeol', '윤석열', 'politician', 'male',
 '1960-12-18', NULL, NULL, false, NULL,
 '제20대 대통령 (2022-2025)', ARRAY['윤석열', 'Yoon Suk-yeol', '대통령'], 95, true),

('politician_moon_jaein', '문재인', 'Moon Jae-in', '문재인', 'politician', 'male',
 '1953-01-24', NULL, 'B', false, NULL,
 '제19대 대통령 (2017-2022)', ARRAY['문재인', 'Moon Jae-in', '대통령'], 90, true),

('politician_park_geunhye', '박근혜', 'Park Geun-hye', '박근혜', 'politician', 'female',
 '1952-02-02', NULL, 'B', false, NULL,
 '제18대 대통령 (2013-2017)', ARRAY['박근혜', 'Park Geun-hye', '대통령'], 85, true),

('politician_lee_myungbak', '이명박', 'Lee Myung-bak', '이명박', 'politician', 'male',
 '1941-12-19', NULL, 'B', false, NULL,
 '제17대 대통령 (2008-2013)', ARRAY['이명박', 'Lee Myung-bak', '대통령'], 80, true),

('politician_roh_moohyun', '노무현', 'Roh Moo-hyun', '노무현', 'politician', 'male',
 '1946-09-01', NULL, 'O', false, NULL,
 '제16대 대통령 (2003-2008)', ARRAY['노무현', 'Roh Moo-hyun', '대통령'], 92, true),

('politician_kim_daejung', '김대중', 'Kim Dae-jung', '김대중', 'politician', 'male',
 '1924-01-06', NULL, 'AB', false, NULL,
 '제15대 대통령, 노벨평화상', ARRAY['김대중', 'Kim Dae-jung', '대통령', '노벨평화상'], 90, true),

('politician_kim_youngsam', '김영삼', 'Kim Young-sam', '김영삼', 'politician', 'male',
 '1927-12-20', NULL, 'AB', false, NULL,
 '제14대 대통령 (1993-1998)', ARRAY['김영삼', 'Kim Young-sam', '대통령'], 80, true),

('politician_roh_taewoo', '노태우', 'Roh Tae-woo', '노태우', 'politician', 'male',
 '1932-12-04', NULL, 'AB', false, NULL,
 '제13대 대통령 (1988-1993)', ARRAY['노태우', 'Roh Tae-woo', '대통령'], 70, true),

('politician_chun_doohwan', '전두환', 'Chun Doo-hwan', '전두환', 'politician', 'male',
 '1931-01-18', NULL, 'B', false, NULL,
 '제11-12대 대통령', ARRAY['전두환', 'Chun Doo-hwan', '대통령'], 60, true),

('politician_park_junghee', '박정희', 'Park Chung-hee', '박정희', 'politician', 'male',
 '1917-11-14', NULL, 'A', false, NULL,
 '제5-9대 대통령', ARRAY['박정희', 'Park Chung-hee', '대통령'], 85, true),

('politician_lee_seungman', '이승만', 'Syngman Rhee', '이승만', 'politician', 'male',
 '1875-03-26', NULL, NULL, false, NULL,
 '초대-3대 대통령', ARRAY['이승만', 'Syngman Rhee', '대통령'], 70, true),

-- ===== 현 정치인 (여당/야당) =====
('politician_lee_jaemyung', '이재명', 'Lee Jae-myung', '이재명', 'politician', 'male',
 '1964-12-22', NULL, 'B', false, NULL,
 '제21대 대통령 (2025-현재)', ARRAY['이재명', 'Lee Jae-myung', '대통령', '더불어민주당'], 95, true),

('politician_han_donghoon', '한동훈', 'Han Dong-hoon', '한동훈', 'politician', 'male',
 '1973-04-09', NULL, 'B', false, NULL,
 '전 국민의힘 대표, 전 법무부 장관', ARRAY['한동훈', 'Han Dong-hoon', '국민의힘'], 90, true),

('politician_cho_guk', '조국', 'Cho Kuk', '조국', 'politician', 'male',
 '1965-04-06', NULL, NULL, false, NULL,
 '조국혁신당 대표, 전 법무부 장관', ARRAY['조국', 'Cho Kuk', '조국혁신당'], 88, true),

('politician_oh_sehoon', '오세훈', 'Oh Se-hoon', '오세훈', 'politician', 'male',
 '1961-01-04', NULL, NULL, false, NULL,
 '서울특별시장', ARRAY['오세훈', 'Oh Se-hoon', '서울시장'], 85, true),

('politician_won_heeryong', '원희룡', 'Won Hee-ryong', '원희룡', 'politician', 'male',
 '1964-02-14', NULL, NULL, false, NULL,
 '전 국토교통부 장관', ARRAY['원희룡', 'Won Hee-ryong'], 80, true),

('politician_lee_nakyeon', '이낙연', 'Lee Nak-yon', '이낙연', 'politician', 'male',
 '1952-12-20', NULL, 'A', false, NULL,
 '전 국무총리, 전 더불어민주당 대표', ARRAY['이낙연', 'Lee Nak-yon', '국무총리'], 85, true),

('politician_jung_jinseok', '정진석', 'Chung Jin-suk', '정진석', 'politician', 'male',
 '1960-09-04', NULL, NULL, false, NULL,
 '국회부의장', ARRAY['정진석', 'Chung Jin-suk'], 75, true),

('politician_ahn_cheolsoo', '안철수', 'Ahn Cheol-soo', '안철수', 'politician', 'male',
 '1962-02-26', NULL, 'A', false, NULL,
 '의사 출신 정치인, 안랩 창업자', ARRAY['안철수', 'Ahn Cheol-soo', '안랩'], 80, true),

('politician_hong_junpyo', '홍준표', 'Hong Jun-pyo', '홍준표', 'politician', 'male',
 '1954-11-20', NULL, 'A', false, NULL,
 '대구광역시장, 전 자유한국당 대표', ARRAY['홍준표', 'Hong Jun-pyo', '대구시장'], 78, true),

('politician_yoo_seungmin', '유승민', 'Yoo Seung-min', '유승민', 'politician', 'male',
 '1958-08-27', NULL, NULL, false, NULL,
 '전 바른정당 대표', ARRAY['유승민', 'Yoo Seung-min'], 70, true),

('politician_lee_junseok', '이준석', 'Lee Jun-seok', '이준석', 'politician', 'male',
 '1985-07-15', NULL, 'O', false, NULL,
 '전 국민의힘 대표, 개혁신당 대표', ARRAY['이준석', 'Lee Jun-seok', '개혁신당'], 82, true),

('politician_kim_gihuyn', '김기현', 'Kim Gi-hyeon', '김기현', 'politician', 'male',
 '1959-03-05', NULL, NULL, false, NULL,
 '전 국민의힘 대표', ARRAY['김기현', 'Kim Gi-hyeon'], 72, true),

('politician_chung_seykyun', '정세균', 'Chung Sye-kyun', '정세균', 'politician', 'male',
 '1950-12-14', NULL, NULL, false, NULL,
 '전 국무총리, 전 국회의장', ARRAY['정세균', 'Chung Sye-kyun', '국무총리'], 75, true),

('politician_park_jiewon', '박지원', 'Park Jie-won', '박지원', 'politician', 'male',
 '1942-12-30', NULL, NULL, false, NULL,
 '전 국정원장', ARRAY['박지원', 'Park Jie-won', '국정원장'], 70, true),

('politician_kim_jongmin', '김종민', 'Kim Jong-min', '김종민', 'politician', 'male',
 '1966-01-20', NULL, NULL, false, NULL,
 '국회의원', ARRAY['김종민', 'Kim Jong-min'], 65, true),

('politician_park_yongchin', '박용진', 'Park Yong-jin', '박용진', 'politician', 'male',
 '1970-11-19', NULL, NULL, false, NULL,
 '국회의원', ARRAY['박용진', 'Park Yong-jin'], 72, true),

('politician_kim_youngho', '김영호', 'Kim Young-ho', '김영호', 'politician', 'male',
 '1963-03-15', NULL, NULL, false, NULL,
 '국회의원', ARRAY['김영호', 'Kim Young-ho'], 65, true),

('politician_kim_dongyon', '김동연', 'Kim Dong-yeon', '김동연', 'politician', 'male',
 '1957-11-05', NULL, NULL, false, NULL,
 '경기도지사', ARRAY['김동연', 'Kim Dong-yeon', '경기도지사'], 78, true),

('politician_woo_wonshik', '우원식', 'Woo Won-shik', '우원식', 'politician', 'male',
 '1958-12-13', NULL, NULL, false, NULL,
 '국회의장', ARRAY['우원식', 'Woo Won-shik', '국회의장'], 75, true),

-- ===== 여성 정치인 =====
('politician_chu_miae', '추미애', 'Choo Mi-ae', '추미애', 'politician', 'female',
 '1958-10-23', NULL, NULL, false, NULL,
 '전 법무부 장관, 전 더불어민주당 대표', ARRAY['추미애', 'Choo Mi-ae', '법무부장관'], 80, true),

('politician_na_kyungwon', '나경원', 'Na Kyung-won', '나경원', 'politician', 'female',
 '1963-12-06', NULL, 'A', false, NULL,
 '전 국회 원내대표', ARRAY['나경원', 'Na Kyung-won'], 78, true),

('politician_sim_sangjung', '심상정', 'Sim Sang-jeung', '심상정', 'politician', 'female',
 '1959-02-20', NULL, NULL, false, NULL,
 '전 정의당 대표', ARRAY['심상정', 'Sim Sang-jeung', '정의당'], 75, true),

('politician_ryu_hojung', '류호정', 'Ryu Ho-jeong', '류호정', 'politician', 'female',
 '1992-08-09', NULL, NULL, false, NULL,
 '전 정의당 국회의원', ARRAY['류호정', 'Ryu Ho-jeong', '정의당'], 70, true),

('politician_kang_kyeonghwa', '강경화', 'Kang Kyung-wha', '강경화', 'politician', 'female',
 '1955-03-07', NULL, NULL, false, NULL,
 '전 외교부 장관', ARRAY['강경화', 'Kang Kyung-wha', '외교부장관'], 75, true),

('politician_yoo_eunhye', '유은혜', 'Yoo Eun-hae', '유은혜', 'politician', 'female',
 '1967-03-14', NULL, NULL, false, NULL,
 '전 교육부 장관', ARRAY['유은혜', 'Yoo Eun-hae', '교육부장관'], 70, true),

('politician_park_young_sun', '박영선', 'Park Young-sun', '박영선', 'politician', 'female',
 '1960-01-22', NULL, 'A', false, NULL,
 '전 중소벤처기업부 장관', ARRAY['박영선', 'Park Young-sun'], 75, true),

('politician_kim_hyunmee', '김현미', 'Kim Hyun-mee', '김현미', 'politician', 'female',
 '1962-07-30', NULL, NULL, false, NULL,
 '전 국토교통부 장관', ARRAY['김현미', 'Kim Hyun-mee'], 68, true),

('politician_jin_sunmee', '진선미', 'Jin Sun-mee', '진선미', 'politician', 'female',
 '1964-06-15', NULL, NULL, false, NULL,
 '전 여성가족부 장관', ARRAY['진선미', 'Jin Sun-mee'], 65, true),

('politician_cho_eunjung', '조은정', 'Cho Eun-jung', '조은정', 'politician', 'female',
 '1973-01-10', NULL, NULL, false, NULL,
 '국회의원', ARRAY['조은정', 'Cho Eun-jung'], 62, true),

('politician_han_junhee', '한정애', 'Han Jung-ae', '한정애', 'politician', 'female',
 '1967-04-03', NULL, NULL, false, NULL,
 '전 환경부 장관', ARRAY['한정애', 'Han Jung-ae'], 68, true),

('politician_jeon_hyebae', '전혜숙', 'Jeon Hye-sook', '전혜숙', 'politician', 'female',
 '1954-03-21', NULL, NULL, false, NULL,
 '국회의원', ARRAY['전혜숙', 'Jeon Hye-sook'], 62, true),

-- ===== 광역단체장 / 기초단체장 =====
('politician_park_heongdo', '박형준', 'Park Heung-do', '박형준', 'politician', 'male',
 '1962-01-05', NULL, NULL, false, NULL,
 '부산광역시장', ARRAY['박형준', 'Park Heung-do', '부산시장'], 72, true),

('politician_kim_yeongrok', '김영록', 'Kim Young-rok', '김영록', 'politician', 'male',
 '1960-07-20', NULL, NULL, false, NULL,
 '전라남도지사', ARRAY['김영록', 'Kim Young-rok', '전라남도지사'], 70, true),

('politician_lee_cheolwoo', '이철우', 'Lee Cheol-woo', '이철우', 'politician', 'male',
 '1956-01-24', NULL, NULL, false, NULL,
 '경상북도지사', ARRAY['이철우', 'Lee Cheol-woo', '경상북도지사'], 70, true),

('politician_kim_kyoungsu', '김경수', 'Kim Kyoung-soo', '김경수', 'politician', 'male',
 '1967-06-14', NULL, NULL, false, NULL,
 '전 경상남도지사', ARRAY['김경수', 'Kim Kyoung-soo', '경상남도지사'], 75, true),

('politician_oh_georan', '오거돈', 'Oh Geo-don', '오거돈', 'politician', 'male',
 '1951-03-21', NULL, NULL, false, NULL,
 '전 부산광역시장', ARRAY['오거돈', 'Oh Geo-don'], 55, true),

('politician_park_namchoon', '박남춘', 'Park Nam-choon', '박남춘', 'politician', 'male',
 '1965-02-20', NULL, NULL, false, NULL,
 '전 인천광역시장', ARRAY['박남춘', 'Park Nam-choon'], 68, true),

('politician_yang_seungtae', '양승태', 'Yang Sung-tae', '양승태', 'politician', 'male',
 '1951-03-03', NULL, NULL, false, NULL,
 '전 대법원장', ARRAY['양승태', 'Yang Sung-tae', '대법원장'], 60, true),

('politician_kim_myungsu', '김명수', 'Kim Myeong-su', '김명수', 'politician', 'male',
 '1959-07-25', NULL, NULL, false, NULL,
 '전 대법원장', ARRAY['김명수', 'Kim Myeong-su', '대법원장'], 65, true),

-- ===== 역사적 인물 / 독립운동가 =====
('politician_kim_gu', '김구', 'Kim Koo', '김구', 'politician', 'male',
 '1876-08-29', NULL, NULL, false, NULL,
 '독립운동가, 대한민국 임시정부 주석', ARRAY['김구', 'Kim Koo', '백범', '독립운동'], 95, true),

('politician_ahn_changho', '안창호', 'Ahn Chang-ho', '안창호', 'politician', 'male',
 '1878-11-09', NULL, NULL, false, NULL,
 '독립운동가, 도산', ARRAY['안창호', 'Ahn Chang-ho', '도산', '독립운동'], 90, true),

('politician_yun_bonggil', '윤봉길', 'Yun Bong-gil', '윤봉길', 'politician', 'male',
 '1908-06-21', NULL, NULL, false, NULL,
 '독립운동가, 의거', ARRAY['윤봉길', 'Yun Bong-gil', '독립운동'], 88, true),

('politician_lee_bonchang', '이봉창', 'Lee Bong-chang', '이봉창', 'politician', 'male',
 '1901-08-10', NULL, NULL, false, NULL,
 '독립운동가', ARRAY['이봉창', 'Lee Bong-chang', '독립운동'], 85, true),

('politician_ahn_junggeun', '안중근', 'Ahn Jung-geun', '안중근', 'politician', 'male',
 '1879-09-02', NULL, NULL, false, NULL,
 '독립운동가, 이토 히로부미 저격', ARRAY['안중근', 'Ahn Jung-geun', '독립운동'], 95, true),

('politician_yu_gwansun', '유관순', 'Yu Gwan-sun', '유관순', 'politician', 'female',
 '1902-12-16', NULL, NULL, false, NULL,
 '독립운동가, 3.1운동', ARRAY['유관순', 'Yu Gwan-sun', '독립운동', '3.1운동'], 95, true),

('politician_kim_wonbong', '김원봉', 'Kim Won-bong', '김원봉', 'politician', 'male',
 '1898-08-13', NULL, NULL, false, NULL,
 '독립운동가, 의열단장', ARRAY['김원봉', 'Kim Won-bong', '의열단'], 80, true),

('politician_shin_chaeho', '신채호', 'Shin Chae-ho', '신채호', 'politician', 'male',
 '1880-12-08', NULL, NULL, false, NULL,
 '독립운동가, 역사학자, 단재', ARRAY['신채호', 'Shin Chae-ho', '단재', '독립운동'], 85, true),

('politician_lee_hwanyoung', '이회영', 'Lee Hoe-yeong', '이회영', 'politician', 'male',
 '1867-04-21', NULL, NULL, false, NULL,
 '독립운동가, 신흥무관학교', ARRAY['이회영', 'Lee Hoe-yeong', '독립운동'], 80, true),

('politician_seo_jaepil', '서재필', 'Seo Jae-pil', '서재필', 'politician', 'male',
 '1864-01-07', NULL, NULL, false, NULL,
 '독립협회 창립, 독립신문 창간', ARRAY['서재필', 'Seo Jae-pil', '독립협회'], 82, true),

-- ===== 기타 정치인 =====
('politician_kim_jongin', '김종인', 'Kim Chong-in', '김종인', 'politician', 'male',
 '1940-02-20', NULL, NULL, false, NULL,
 '정치 원로, 전 국민의힘 비상대책위원장', ARRAY['김종인', 'Kim Chong-in'], 75, true),

('politician_oh_sejin', '오세진', 'Oh Se-jin', '오세진', 'politician', 'male',
 '1968-05-15', NULL, NULL, false, NULL,
 '국회의원', ARRAY['오세진', 'Oh Se-jin'], 60, true),

('politician_choi_jaehyung', '최재형', 'Choi Jae-hyung', '최재형', 'politician', 'male',
 '1956-06-21', NULL, NULL, false, NULL,
 '전 감사원장', ARRAY['최재형', 'Choi Jae-hyung', '감사원장'], 70, true),

('politician_kim_moonsu', '김문수', 'Kim Moon-soo', '김문수', 'politician', 'male',
 '1951-09-25', NULL, NULL, false, NULL,
 '전 경기도지사, 고용노동부 장관', ARRAY['김문수', 'Kim Moon-soo', '경기도지사'], 72, true),

('politician_kwon_youngse', '권영세', 'Kwon Young-se', '권영세', 'politician', 'male',
 '1957-04-21', NULL, NULL, false, NULL,
 '전 통일부 장관', ARRAY['권영세', 'Kwon Young-se'], 68, true),

('politician_cho_jungrae', '조정래', 'Cho Jung-rae', '조정래', 'politician', 'male',
 '1968-01-14', NULL, NULL, false, NULL,
 '국회의원', ARRAY['조정래', 'Cho Jung-rae'], 65, true),

('politician_min_hyungjoo', '민형주', 'Min Hyung-joo', '민형주', 'politician', 'male',
 '1964-08-25', NULL, NULL, false, NULL,
 '전 국회의원', ARRAY['민형주', 'Min Hyung-joo'], 62, true),

('politician_lee_wonwook', '이원욱', 'Lee Won-wook', '이원욱', 'politician', 'male',
 '1967-03-25', NULL, NULL, false, NULL,
 '국회의원', ARRAY['이원욱', 'Lee Won-wook'], 65, true),

('politician_kim_taeho', '김태호', 'Kim Tae-ho', '김태호', 'politician', 'male',
 '1955-03-20', NULL, NULL, false, NULL,
 '전 경상남도지사', ARRAY['김태호', 'Kim Tae-ho'], 65, true),

('politician_kim_hanGil', '김한길', 'Kim Han-gil', '김한길', 'politician', 'male',
 '1954-06-08', NULL, NULL, false, NULL,
 '전 민주당 대표', ARRAY['김한길', 'Kim Han-gil'], 65, true),

('politician_park_wonsoone', '박원순', 'Park Won-soon', '박원순', 'politician', 'male',
 '1956-03-26', NULL, NULL, false, NULL,
 '전 서울특별시장', ARRAY['박원순', 'Park Won-soon', '서울시장'], 75, true),

('politician_yoon_iho', '윤이호', 'Yoon Ee-ho', '윤이호', 'politician', 'male',
 '1964-11-20', NULL, NULL, false, NULL,
 '국회의원', ARRAY['윤이호', 'Yoon Ee-ho'], 58, true),

('politician_kim_taekyun', '김태년', 'Kim Tae-nyeon', '김태년', 'politician', 'male',
 '1959-01-22', NULL, 'O', false, NULL,
 '전 더불어민주당 원내대표', ARRAY['김태년', 'Kim Tae-nyeon'], 70, true),

('politician_park_jumin', '박주민', 'Park Joo-min', '박주민', 'politician', 'male',
 '1973-11-30', NULL, NULL, false, NULL,
 '국회의원', ARRAY['박주민', 'Park Joo-min'], 72, true),

('politician_jung_chunrae', '정청래', 'Jeong Cheong-rae', '정청래', 'politician', 'male',
 '1961-10-05', NULL, NULL, false, NULL,
 '국회의원', ARRAY['정청래', 'Jeong Cheong-rae'], 70, true),

('politician_kim_eui_kyum', '김의겸', 'Kim Eui-kyum', '김의겸', 'politician', 'male',
 '1965-07-10', NULL, NULL, false, NULL,
 '국회의원, 전 청와대 대변인', ARRAY['김의겸', 'Kim Eui-kyum'], 68, true),

('politician_yoo_gihmoon', '유기홍', 'Yoo Gi-hong', '유기홍', 'politician', 'male',
 '1956-09-15', NULL, NULL, false, NULL,
 '국회의원', ARRAY['유기홍', 'Yoo Gi-hong'], 65, true),

('politician_lee_sangheon', '이상헌', 'Lee Sang-heon', '이상헌', 'politician', 'male',
 '1958-04-18', NULL, NULL, false, NULL,
 '국회의원', ARRAY['이상헌', 'Lee Sang-heon'], 62, true),

('politician_jin_sung_jun', '진성준', 'Jin Sung-jun', '진성준', 'politician', 'male',
 '1964-12-05', NULL, NULL, false, NULL,
 '더불어민주당 원내대표', ARRAY['진성준', 'Jin Sung-jun'], 72, true),

('politician_kwon_sunghee', '권성동', 'Kwon Sung-dong', '권성동', 'politician', 'male',
 '1960-11-15', NULL, NULL, false, NULL,
 '전 국민의힘 원내대표', ARRAY['권성동', 'Kwon Sung-dong'], 70, true),

('politician_joo_hoyoung', '주호영', 'Joo Ho-young', '주호영', 'politician', 'male',
 '1957-11-27', NULL, NULL, false, NULL,
 '전 국민의힘 원내대표', ARRAY['주호영', 'Joo Ho-young'], 72, true),

('politician_choo_hyosun', '추경호', 'Choo Kyung-ho', '추경호', 'politician', 'male',
 '1961-03-14', NULL, NULL, false, NULL,
 '전 경제부총리', ARRAY['추경호', 'Choo Kyung-ho'], 75, true),

('politician_park_minsik', '박민식', 'Park Min-shik', '박민식', 'politician', 'male',
 '1966-05-20', NULL, NULL, false, NULL,
 '전 국가보훈부 장관', ARRAY['박민식', 'Park Min-shik'], 65, true),

('politician_lee_sangmin', '이상민', 'Lee Sang-min', '이상민', 'politician', 'male',
 '1958-12-01', NULL, NULL, false, NULL,
 '전 행정안전부 장관', ARRAY['이상민', 'Lee Sang-min'], 68, true),

('politician_han_kisun', '한기호', 'Han Ki-ho', '한기호', 'politician', 'male',
 '1966-02-22', NULL, NULL, false, NULL,
 '국회의원', ARRAY['한기호', 'Han Ki-ho'], 62, true),

('politician_yoon_sanghyun', '윤상현', 'Yoon Sang-hyun', '윤상현', 'politician', 'male',
 '1962-04-28', NULL, NULL, false, NULL,
 '국회의원', ARRAY['윤상현', 'Yoon Sang-hyun'], 68, true),

('politician_kim_jinho', '김진표', 'Kim Jin-pyo', '김진표', 'politician', 'male',
 '1947-07-15', NULL, 'A', false, NULL,
 '전 국회의장', ARRAY['김진표', 'Kim Jin-pyo', '국회의장'], 78, true),

('politician_cho_jungshik', '조정식', 'Cho Jung-sik', '조정식', 'politician', 'male',
 '1959-08-20', NULL, NULL, false, NULL,
 '국회의원', ARRAY['조정식', 'Cho Jung-sik'], 62, true),

('politician_lee_jaejung', '이재정', 'Lee Jae-jung', '이재정', 'politician', 'male',
 '1954-04-15', NULL, NULL, false, NULL,
 '경기도교육감', ARRAY['이재정', 'Lee Jae-jung', '교육감'], 68, true),

('politician_kim_hyungsuk', '김형석', 'Kim Hyung-suk', '김형석', 'politician', 'male',
 '1970-09-01', NULL, NULL, false, NULL,
 '국회의원', ARRAY['김형석', 'Kim Hyung-suk'], 58, true),

('politician_bae_hyunjin', '배현진', 'Bae Hyun-jin', '배현진', 'politician', 'female',
 '1984-01-28', NULL, 'A', false, NULL,
 '국회의원, 전 아나운서', ARRAY['배현진', 'Bae Hyun-jin', '아나운서'], 75, true),

('politician_yoon_heeseok', '윤희석', 'Yoon Hee-seok', '윤희석', 'politician', 'male',
 '1980-05-15', NULL, NULL, false, NULL,
 '국회의원', ARRAY['윤희석', 'Yoon Hee-seok'], 60, true)

ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    name_en = EXCLUDED.name_en,
    legal_name = EXCLUDED.legal_name,
    mbti = EXCLUDED.mbti,
    blood_type = EXCLUDED.blood_type,
    is_group_member = EXCLUDED.is_group_member,
    group_name = EXCLUDED.group_name,
    description = EXCLUDED.description,
    keywords = EXCLUDED.keywords,
    popularity_score = EXCLUDED.popularity_score,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- 삽입 결과 확인
DO $$
DECLARE
    politician_count INTEGER;
    male_count INTEGER;
    female_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO politician_count
    FROM celebrities
    WHERE category = 'politician' AND is_active = true;

    SELECT COUNT(*) INTO male_count
    FROM celebrities
    WHERE category = 'politician' AND gender = 'male' AND is_active = true;

    SELECT COUNT(*) INTO female_count
    FROM celebrities
    WHERE category = 'politician' AND gender = 'female' AND is_active = true;

    RAISE NOTICE 'Total politicians: %, Male: %, Female: %', politician_count, male_count, female_count;
END $$;
