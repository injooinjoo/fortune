-- 유튜버/스트리머 100명 데이터 삽입
-- 게임, 먹방, 뷰티, 엔터테인먼트, 교육, 일상 등 다양한 분야
-- 2025년 11월 28일

INSERT INTO public.celebrities (
    id, name, name_en, legal_name, category, gender,
    birth_date, mbti, blood_type, is_group_member, group_name,
    description, keywords, popularity_score, is_active
) VALUES
-- ============================================
-- 게임/스트리머 (남성)
-- ============================================
('youtuber_daedo', '대도서관', 'BuzzBean', '나동현', 'youtuber', 'male',
 '1978-10-31', 'ENFP', NULL, false, NULL,
 '게임 스트리머, 보는 게임 문화 선구자 (故)', ARRAY['대도서관', 'BuzzBean', '게임', '스트리머'], 90, true),

('youtuber_doti', '도티', 'Doti', '나희선', 'youtuber', 'male',
 '1986-12-10', 'ENFP', NULL, false, NULL,
 '마인크래프트 유튜버, 샌드박스 네트워크', ARRAY['도티', 'Doti', '마인크래프트', '샌드박스'], 92, true),

('youtuber_bokyem', '보겸', 'Bokyem', '김보겸', 'youtuber', 'male',
 '1988-01-31', 'ESFP', NULL, false, NULL,
 '종합 유튜버, 구독자 1500만+', ARRAY['보겸', 'Bokyem', '유튜버', '일상'], 95, true),

('streamer_woowakgood', '우왁굳', 'Woowakgood', '오영택', 'streamer', 'male',
 '1987-07-24', 'INFP', NULL, false, NULL,
 '인터넷 방송인, 왁타버스 창시자', ARRAY['우왁굳', 'Woowakgood', '왁타버스', '스트리머'], 95, true),

('streamer_pungwolryang', '풍월량', 'Pungwolryang', '김영태', 'streamer', 'male',
 '1982-11-25', 'INFP', NULL, false, NULL,
 '게임 스트리머, 종합 게임', ARRAY['풍월량', 'Pungwolryang', '게임', '치지직'], 88, true),

('youtuber_chimchakman', '침착맨', 'Chimchakman', '이병건', 'youtuber', 'male',
 '1984-04-19', 'INFP', NULL, false, NULL,
 '웹툰작가 이말년, 유튜버/스트리머', ARRAY['침착맨', 'Chimchakman', '이말년', '유튜버'], 93, true),

('youtuber_joohomin', '주호민', 'Joo Ho-min', '주호민', 'youtuber', 'male',
 '1981-09-26', 'INTP', NULL, false, NULL,
 '만화가, 짬, 신과함께', ARRAY['주호민', 'Joo Ho-min', '만화가', '신과함께'], 88, true),

('youtuber_kimblue', '김블루', 'Kim Blue', NULL, 'youtuber', 'male',
 '1997-02-13', 'ENFP', NULL, false, NULL,
 '게임 유튜버, 악동 김블루', ARRAY['김블루', 'Kim Blue', '게임', '유튜버'], 88, true),

('streamer_cheolgu', '철구', 'Cheolgu', '이예준', 'streamer', 'male',
 '1985-06-18', 'ESTP', NULL, false, NULL,
 '前 프로게이머, BJ, 외질혜 남편', ARRAY['철구', 'Cheolgu', 'BJ', '스트리머'], 80, true),

('streamer_gamst', '감스트', 'Gamst', '김인직', 'streamer', 'male',
 '1984-08-27', 'ENFP', NULL, false, NULL,
 '축구 스트리머, BJ대상 6연속', ARRAY['감스트', 'Gamst', '축구', 'BJ대상'], 90, true),

('streamer_handongsuk', '한동숙', 'Han Dong-sook', '한동숙', 'streamer', 'male',
 '1982-09-17', 'ENFP', NULL, false, NULL,
 '게임 스트리머, 배틀그라운드', ARRAY['한동숙', 'Han Dong-sook', '배그', '스트리머'], 82, true),

('streamer_hongbangjang', '홍방장', 'Hongbangjang', '홍재민', 'streamer', 'male',
 '1990-03-08', 'ENTP', NULL, false, NULL,
 'BJ, 토크/상담 방송', ARRAY['홍방장', 'Hongbangjang', 'BJ', '토크'], 78, true),

('youtuber_ddungenius', '뚱지니어스', 'DDungGenius', NULL, 'youtuber', 'male',
 '1992-05-10', 'INFP', NULL, false, NULL,
 '코딩/교육 유튜버', ARRAY['뚱지니어스', 'DDungGenius', '코딩', '교육'], 75, true),

('streamer_sulbbyu', '설레발', 'Sulbbyu', NULL, 'streamer', 'male',
 '1993-07-15', 'ENFP', NULL, false, NULL,
 '게임 스트리머', ARRAY['설레발', 'Sulbbyu', '게임', '스트리머'], 70, true),

-- ============================================
-- 먹방 유튜버
-- ============================================
('youtuber_tzuyang', '쯔양', 'Tzuyang', '박정원', 'youtuber', 'female',
 '1997-04-25', 'ISFP', NULL, false, NULL,
 '먹방 유튜버, 구독자 1200만+', ARRAY['쯔양', 'Tzuyang', '먹방', '대식가'], 97, true),

('streamer_hibap', '히밥', 'Heebab', NULL, 'streamer', 'female',
 '1991-08-10', 'ENFP', NULL, false, NULL,
 '먹방 스트리머, 대식가', ARRAY['히밥', 'Heebab', '먹방', '대식가'], 88, true),

('youtuber_mukbangddonghee', '입짧은햇님', 'Ipjjalbunhaetnim', NULL, 'youtuber', 'female',
 '1985-12-20', 'INFP', NULL, false, NULL,
 '먹방 유튜버, ASMR', ARRAY['입짧은햇님', '먹방', 'ASMR'], 85, true),

('youtuber_hongsound', '홍사운드', 'Hong Sound', NULL, 'youtuber', 'male',
 '1992-03-15', 'ENFP', NULL, false, NULL,
 '먹방 유튜버', ARRAY['홍사운드', 'Hong Sound', '먹방', '유튜버'], 82, true),

('youtuber_sas_asmr', 'SAS-ASMR', 'SAS-ASMR', NULL, 'youtuber', 'female',
 '1988-06-20', 'INFP', NULL, false, NULL,
 'ASMR 먹방 유튜버', ARRAY['SAS-ASMR', 'ASMR', '먹방'], 85, true),

('youtuber_banzz', '밴쯔', 'Banzz', '정만수', 'youtuber', 'male',
 '1988-03-23', 'ESFP', NULL, false, NULL,
 '먹방 유튜버 원조, 대식가', ARRAY['밴쯔', 'Banzz', '먹방', '대식가'], 80, true),

-- ============================================
-- 뷰티/패션 유튜버
-- ============================================
('youtuber_risabae', '이사배', 'Risabae', '이지혜', 'youtuber', 'female',
 '1988-09-13', 'INFJ', NULL, false, NULL,
 '뷰티 유튜버, 분장사', ARRAY['이사배', 'Risabae', '뷰티', '메이크업'], 92, true),

('youtuber_pony', '포니', 'PONY', '박혜민', 'youtuber', 'female',
 '1990-03-11', 'INFP', NULL, false, NULL,
 '뷰티 유튜버, 메이크업 아티스트', ARRAY['포니', 'PONY', '뷰티', '메이크업'], 90, true),

('youtuber_ssinnim', '씬님', 'Ssin', NULL, 'youtuber', 'female',
 '1987-04-05', 'ENFP', NULL, false, NULL,
 '뷰티 유튜버, 메이크업', ARRAY['씬님', 'Ssin', '뷰티', '메이크업'], 85, true),

('youtuber_lamuqe', '라뮤끄', 'Lamuqe', NULL, 'youtuber', 'female',
 '1990-07-22', 'INFP', NULL, false, NULL,
 '뷰티 유튜버', ARRAY['라뮤끄', 'Lamuqe', '뷰티', '메이크업'], 80, true),

('youtuber_dear', '디어언니', 'Dear Sisters', NULL, 'youtuber', 'female',
 '1991-11-08', 'ENFP', NULL, false, NULL,
 '뷰티/패션 유튜버', ARRAY['디어언니', 'Dear Sisters', '뷰티', '패션'], 78, true),

-- ============================================
-- 엔터테인먼트/코미디 유튜버
-- ============================================
('youtuber_shortbox_kimwonhun', '김원훈', 'Kim Won-hun', '김원훈', 'youtuber', 'male',
 '1990-06-25', 'ENFP', NULL, true, '숏박스',
 '숏박스, KBS 30기 개그맨', ARRAY['김원훈', '숏박스', '개그맨', '유튜버'], 88, true),

('youtuber_shortbox_jojinse', '조진세', 'Jo Jin-se', '조진세', 'youtuber', 'male',
 '1992-04-17', 'ENFP', NULL, true, '숏박스',
 '숏박스, KBS 31기 개그맨', ARRAY['조진세', '숏박스', '개그맨', '유튜버'], 88, true),

('youtuber_shortbox_eomjiyoon', '엄지윤', 'Eom Ji-yoon', '엄지윤', 'youtuber', 'female',
 '1997-08-03', 'ENFP', NULL, true, '숏박스',
 '숏박스, KBS 32기 개그우먼', ARRAY['엄지윤', '숏박스', '개그우먼', '유튜버'], 90, true),

('youtuber_psick_univ', '피식대학', 'Psick Univ', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '코미디 유튜버, 김민수', ARRAY['피식대학', '피대', '코미디', '김민수'], 90, true),

('youtuber_itaewon_class', '이태원클라쓰', 'Itaewon Class', NULL, 'youtuber', 'male',
 '1989-05-12', 'ENFP', NULL, false, NULL,
 '코미디/일상 유튜버', ARRAY['이태원클라쓰', '유튜버', '코미디'], 75, true),

('youtuber_dexterit', '덱스터랩', 'DexterLab', '김정현', 'youtuber', 'male',
 '1990-08-27', 'ENTP', NULL, false, NULL,
 '과학/실험 유튜버', ARRAY['덱스터랩', 'DexterLab', '과학', '실험'], 80, true),

-- ============================================
-- 피트니스/건강 유튜버
-- ============================================
('youtuber_fitvely', '핏블리', 'Fitvely', '문석기', 'youtuber', 'male',
 '1991-03-15', 'ENFJ', NULL, false, NULL,
 '헬스 유튜버, 트레이너', ARRAY['핏블리', 'Fitvely', '헬스', '트레이너'], 85, true),

('youtuber_kimgyeran', '김계란', 'Kim Gyeran', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '피트니스 유튜버, UDT 출신', ARRAY['김계란', 'Kim Gyeran', '헬스', 'UDT'], 85, true),

('youtuber_thankyou_bubu', '땡큐부부', 'Thankyou Bubu', NULL, 'youtuber', 'female',
 '1987-09-10', 'ENFP', NULL, false, NULL,
 '홈트레이닝 유튜버', ARRAY['땡큐부부', '홈트', '운동', '다이어트'], 82, true),

('youtuber_apink_bodyprofile', '애플힙', 'Apple Hip', NULL, 'youtuber', 'female',
 '1992-01-28', 'ENFP', NULL, false, NULL,
 '피트니스 유튜버', ARRAY['애플힙', '피트니스', '운동', '헬스'], 78, true),

-- ============================================
-- 이세계아이돌/버튜버
-- ============================================
('youtuber_ine', '아이네', 'INE', NULL, 'youtuber', 'female',
 '1994-02-27', NULL, 'B', true, '이세계아이돌',
 '이세계아이돌, 버튜버', ARRAY['아이네', 'INE', '이세계아이돌', '왁타버스'], 90, true),

('youtuber_jingburger', '징버거', 'Jingburger', NULL, 'youtuber', 'female',
 '1995-05-15', NULL, 'B', true, '이세계아이돌',
 '이세계아이돌, 버튜버', ARRAY['징버거', 'Jingburger', '이세계아이돌', '왁타버스'], 88, true),

('youtuber_lilpa', '릴파', 'Lilpa', NULL, 'youtuber', 'female',
 '1996-03-08', NULL, 'O', true, '이세계아이돌',
 '이세계아이돌, 버튜버', ARRAY['릴파', 'Lilpa', '이세계아이돌', '왁타버스'], 90, true),

('youtuber_jururu', '주르르', 'Jururu', NULL, 'youtuber', 'female',
 '1997-08-21', NULL, 'O', true, '이세계아이돌',
 '이세계아이돌, 버튜버', ARRAY['주르르', 'Jururu', '이세계아이돌', '왁타버스'], 88, true),

('youtuber_gosegu', '고세구', 'Gosegu', NULL, 'youtuber', 'female',
 '1998-06-30', NULL, 'B', true, '이세계아이돌',
 '이세계아이돌, 버튜버', ARRAY['고세구', 'Gosegu', '이세계아이돌', '왁타버스'], 92, true),

('youtuber_vichan', '비챤', 'Viichan', NULL, 'youtuber', 'female',
 '2000-12-05', NULL, 'B', true, '이세계아이돌',
 '이세계아이돌, 버튜버, 막내', ARRAY['비챤', 'Viichan', '이세계아이돌', '왁타버스'], 88, true),

-- ============================================
-- 일상/브이로그 유튜버
-- ============================================
('youtuber_baekjongwon_table', '백종원의요리비책', 'Baek Jong-won Cuisine', '백종원', 'youtuber', 'male',
 '1966-09-04', 'ENTJ', 'A', false, NULL,
 '요리 유튜버, 백종원', ARRAY['백종원', '요리비책', '요리', '유튜버'], 95, true),

('youtuber_sungsikyung', '먹킴성시경', 'Sung Si-kyung Mukbang', '성시경', 'youtuber', 'male',
 '1979-04-17', 'INFP', 'O', false, NULL,
 '먹방/요리 유튜버', ARRAY['성시경', '먹킴', '먹방', '요리'], 88, true),

('youtuber_hyunmoo_tv', '전현무TV', 'Hyunmoo TV', '전현무', 'youtuber', 'male',
 '1977-11-07', 'ENTP', 'B', false, NULL,
 '일상/토크 유튜버', ARRAY['전현무', '전현무TV', '일상', '토크'], 82, true),

('youtuber_ggongji', '꽁지', 'Ggongji', NULL, 'youtuber', 'female',
 '1995-09-03', 'ENFP', NULL, false, NULL,
 '일상/먹방 유튜버', ARRAY['꽁지', 'Ggongji', '일상', '먹방'], 78, true),

('youtuber_sooby', '수비', 'Sooby', NULL, 'youtuber', 'female',
 '1992-04-22', 'ENFP', NULL, false, NULL,
 '브이로그/여행 유튜버', ARRAY['수비', 'Sooby', '브이로그', '여행'], 75, true),

-- ============================================
-- 교육/정보 유튜버
-- ============================================
('youtuber_nadocoding', '나도코딩', 'Nadocoding', NULL, 'youtuber', 'male',
 '1988-11-20', 'INTP', NULL, false, NULL,
 '코딩 교육 유튜버', ARRAY['나도코딩', 'Nadocoding', '코딩', '교육'], 85, true),

('youtuber_jocoding', '조코딩', 'Jo Coding', '조동근', 'youtuber', 'male',
 '1991-07-08', 'INTP', NULL, false, NULL,
 '코딩/IT 교육 유튜버', ARRAY['조코딩', 'Jo Coding', '코딩', 'IT'], 88, true),

('youtuber_sinsa_study', '신사임당', 'Sinsaimdang', NULL, 'youtuber', 'female',
 '1985-03-25', 'INTJ', NULL, false, NULL,
 '재테크/경제 유튜버', ARRAY['신사임당', 'Sinsaimdang', '재테크', '경제'], 85, true),

('youtuber_syuka', '슈카', 'Syuka', NULL, 'youtuber', 'male',
 '1983-06-10', 'INTP', NULL, false, NULL,
 '경제/시사 유튜버', ARRAY['슈카', 'Syuka', '경제', '시사'], 90, true),

('youtuber_sebasi', '세바시', 'Sebasi', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '강연/교육 유튜버', ARRAY['세바시', 'Sebasi', '강연', '교육'], 85, true),

('youtuber_dongabrain', '동아사이언스', 'Donga Science', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '과학/교육 유튜버', ARRAY['동아사이언스', '과학', '교육'], 80, true),

-- ============================================
-- 음악/커버 유튜버
-- ============================================
('youtuber_jflamusic', 'J.Fla', 'J.Fla', '김정화', 'youtuber', 'female',
 '1988-08-25', 'INFP', NULL, false, NULL,
 '커버 음악 유튜버', ARRAY['J.Fla', '커버', '음악', '유튜버'], 92, true),

('youtuber_leeraon', '이라온', 'Lee Ra-on', '이라온', 'youtuber', 'female',
 '1992-01-15', 'ENFP', NULL, false, NULL,
 '음악/커버 유튜버', ARRAY['이라온', 'Lee Ra-on', '음악', '커버'], 80, true),

('youtuber_raon_lee', '레온리', 'Raon Lee', NULL, 'youtuber', 'female',
 '1991-05-08', 'ENFP', NULL, false, NULL,
 '애니송 커버 유튜버', ARRAY['레온리', 'Raon Lee', '애니송', '커버'], 85, true),

('youtuber_suhyun_kim', '악동뮤지션 수현', 'Akmu Suhyun', '이수현', 'youtuber', 'female',
 '1999-05-04', 'ENFP', NULL, false, NULL,
 '악동뮤지션, 개인 유튜버', ARRAY['수현', '악동뮤지션', '유튜버'], 88, true),

-- ============================================
-- 여행/아웃도어 유튜버
-- ============================================
('youtuber_korean_englishman', '영국남자', 'Korean Englishman', 'Josh Carrott', 'youtuber', 'male',
 '1991-10-04', 'ENFP', NULL, false, NULL,
 '한국문화/먹방 유튜버 (영국인)', ARRAY['영국남자', 'Korean Englishman', '한국문화', '먹방'], 92, true),

('youtuber_wooldandali', '달리', 'Dali', NULL, 'youtuber', 'female',
 '1993-07-20', 'ENFP', NULL, false, NULL,
 '여행 유튜버', ARRAY['달리', 'Dali', '여행', '유튜버'], 78, true),

('youtuber_pani_bottle', '파니보틀', 'Pani Bottle', '박재영', 'youtuber', 'male',
 '1990-12-03', 'ENFP', NULL, false, NULL,
 '여행 유튜버, 세계여행', ARRAY['파니보틀', 'Pani Bottle', '여행', '세계여행'], 85, true),

('youtuber_traveller_k', '빠니보틀친구', 'Traveller K', NULL, 'youtuber', 'male',
 '1989-08-15', 'ENFP', NULL, false, NULL,
 '여행 유튜버', ARRAY['여행유튜버', '여행', '세계여행'], 75, true),

-- ============================================
-- 아프리카TV BJ
-- ============================================
('streamer_moonwol', '문월', 'Moonwol', '이예슬', 'streamer', 'female',
 '1994-10-15', 'ENFP', NULL, false, NULL,
 'BJ, 술먹방/토크', ARRAY['문월', 'Moonwol', 'BJ', '술먹방'], 82, true),

('streamer_oejilhye', '외질혜', 'Oejilhye', '김민영', 'streamer', 'female',
 '1989-04-03', 'ENFP', NULL, false, NULL,
 'BJ, 철구 아내', ARRAY['외질혜', 'Oejilhye', 'BJ', '철구'], 78, true),

('streamer_seolgi', '슬기', 'Seolgi', NULL, 'streamer', 'female',
 '1995-02-10', 'ENFP', NULL, false, NULL,
 'BJ, 게임 스트리머', ARRAY['슬기', 'Seolgi', 'BJ', '게임'], 75, true),

('streamer_bjchoyoo', '초이', 'BJ Choi', NULL, 'streamer', 'female',
 '1992-08-25', 'ENFP', NULL, false, NULL,
 'BJ, 토크/먹방', ARRAY['초이', 'BJ Choi', 'BJ', '먹방'], 72, true),

('streamer_ddulggul', '뜰꿀', 'Ddulggul', NULL, 'streamer', 'male',
 '1988-05-20', 'ENFP', NULL, false, NULL,
 'BJ, 게임 스트리머', ARRAY['뜰꿀', 'Ddulggul', 'BJ', '게임'], 72, true),

('streamer_oking', '오킹', 'O King', NULL, 'streamer', 'male',
 '1991-11-03', 'ENTP', NULL, false, NULL,
 'BJ, 게임/토크', ARRAY['오킹', 'O King', 'BJ', '게임'], 75, true),

('streamer_rooftop', '옥탑방', 'Rooftop', NULL, 'streamer', 'male',
 '1989-01-08', 'ENFP', NULL, false, NULL,
 'BJ, 버라이어티', ARRAY['옥탑방', 'Rooftop', 'BJ', '버라이어티'], 70, true),

-- ============================================
-- 치지직/숲(SOOP) 스트리머
-- ============================================
('streamer_lee_youngho', '이영호', 'Flash', '이영호', 'streamer', 'male',
 '1992-07-05', 'INTJ', NULL, false, NULL,
 '前 프로게이머 플래시, 스트리머', ARRAY['이영호', 'Flash', '스타크래프트', '프로게이머'], 85, true),

('streamer_jaehoon', '임재훈', 'Im Jae-hoon', '임재훈', 'streamer', 'male',
 '1988-02-17', 'ENFP', NULL, false, NULL,
 '스트리머, 前 프로게이머', ARRAY['임재훈', '스트리머', '프로게이머'], 75, true),

('streamer_jisoo', '서지수', 'Seo Ji-soo', '서지수', 'streamer', 'female',
 '1990-06-12', 'ENFP', NULL, false, NULL,
 '스트리머, 게임/토크', ARRAY['서지수', '스트리머', '게임'], 78, true),

('streamer_ddahyun', '김다현', 'Kim Da-hyun', '김다현', 'streamer', 'female',
 '1995-03-28', 'ENFP', NULL, false, NULL,
 '스트리머, 게임', ARRAY['김다현', '스트리머', '게임'], 75, true),

-- ============================================
-- 키즈/패밀리 유튜버
-- ============================================
('youtuber_boramtube', '보람튜브', 'Boram Tube', '이보람', 'youtuber', 'female',
 '2013-06-03', NULL, NULL, false, NULL,
 '키즈 유튜버', ARRAY['보람튜브', 'Boram Tube', '키즈', '어린이'], 92, true),

('youtuber_larualulu', '라라와 루루', 'Lara and Lulu', NULL, 'youtuber', 'female',
 NULL, NULL, NULL, false, NULL,
 '키즈 유튜버, 메타버스', ARRAY['라라와루루', '키즈', '메타버스'], 88, true),

('youtuber_geniebtv', '지니키즈', 'Genie Kids', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '키즈 교육 유튜버', ARRAY['지니키즈', 'Genie Kids', '키즈', '교육'], 85, true),

('youtuber_carrie', '캐리와장난감친구들', 'Carrie and Toys', NULL, 'youtuber', 'female',
 '1988-07-15', 'ENFP', NULL, false, NULL,
 '키즈 유튜버', ARRAY['캐리', 'Carrie', '키즈', '장난감'], 85, true),

-- ============================================
-- 기타 인기 유튜버
-- ============================================
('youtuber_ddanzi', '딴지일보', 'Ddanzi', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '시사/뉴스 유튜버', ARRAY['딴지일보', 'Ddanzi', '시사', '뉴스'], 78, true),

('youtuber_workman', '워크맨', 'Workman', '장성규', 'youtuber', 'male',
 '1983-04-21', 'ISFP', 'A', false, NULL,
 '직업체험 유튜버', ARRAY['워크맨', 'Workman', '장성규', '직업'], 92, true),

('youtuber_mudo', '무한도전', 'Infinite Challenge', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 'MBC 공식 유튜브', ARRAY['무한도전', '예능', 'MBC'], 90, true),

('youtuber_youquiz', '유퀴즈', 'You Quiz', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 'tvN 공식 유튜브', ARRAY['유퀴즈', '유재석', 'tvN'], 92, true),

('youtuber_dingo', '딩고', 'Dingo', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '디지털 콘텐츠 유튜버', ARRAY['딩고', 'Dingo', '음악', '콘텐츠'], 88, true),

('youtuber_studio_waffle', '스튜디오와플', 'Studio Waffle', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '웹예능 유튜버', ARRAY['스튜디오와플', '웹예능', '유튜브'], 85, true),

('youtuber_godingeum', '고등어', 'Godingeum', NULL, 'youtuber', 'female',
 '1993-10-05', 'ENFP', NULL, false, NULL,
 '코미디/일상 유튜버', ARRAY['고등어', 'Godingeum', '코미디', '일상'], 78, true),

('youtuber_kasper', '캐스퍼', 'Kasper', NULL, 'youtuber', 'male',
 '1990-04-18', 'ENTP', NULL, false, NULL,
 '자동차 유튜버', ARRAY['캐스퍼', 'Kasper', '자동차', '리뷰'], 82, true),

('youtuber_motorgraph', '모터그래프', 'Motorgraph', NULL, 'youtuber', 'male',
 NULL, NULL, NULL, false, NULL,
 '자동차 유튜버', ARRAY['모터그래프', '자동차', '리뷰'], 80, true),

('youtuber_ogu', '오구', 'Ogu', NULL, 'youtuber', 'male',
 '1991-08-12', 'ENFP', NULL, false, NULL,
 '일상/게임 유튜버', ARRAY['오구', 'Ogu', '일상', '게임'], 75, true),

('youtuber_malnyun', '말년', 'Malnyun', '이말년', 'youtuber', 'male',
 '1984-04-19', 'INFP', NULL, false, NULL,
 '웹툰작가, 침착맨과 동일인물', ARRAY['이말년', '웹툰', '침착맨'], 90, true),

('youtuber_kian84', '기안84', 'Kian84', '김희민', 'youtuber', 'male',
 '1984-05-15', 'INFP', 'A', false, NULL,
 '웹툰작가, 나혼자산다', ARRAY['기안84', 'Kian84', '웹툰', '나혼자산다'], 90, true),

('youtuber_joo_ho_min', '주호민TV', 'Joo Ho-min TV', '주호민', 'youtuber', 'male',
 '1981-09-26', 'INTP', NULL, false, NULL,
 '만화가, 유튜브', ARRAY['주호민TV', '주호민', '만화', '유튜버'], 85, true),

('streamer_saddal', '새달', 'Saeddal', NULL, 'streamer', 'female',
 '1992-03-15', 'ENFP', NULL, false, NULL,
 '스트리머, 토크', ARRAY['새달', 'Saeddal', '스트리머', '토크'], 75, true),

('youtuber_jejudodal', '제주도달', 'Jeju Island', NULL, 'youtuber', 'male',
 '1988-09-22', 'ENFP', NULL, false, NULL,
 '여행/제주 유튜버', ARRAY['제주도달', '제주', '여행', '유튜버'], 72, true)

ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    name_en = EXCLUDED.name_en,
    legal_name = EXCLUDED.legal_name,
    category = EXCLUDED.category,
    gender = EXCLUDED.gender,
    birth_date = EXCLUDED.birth_date,
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
    youtuber_count INTEGER;
    streamer_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO youtuber_count
    FROM celebrities
    WHERE category = 'youtuber'
    AND is_active = true;

    SELECT COUNT(*) INTO streamer_count
    FROM celebrities
    WHERE category = 'streamer'
    AND is_active = true;

    RAISE NOTICE 'Total active youtubers: %, streamers: %, combined: %',
        youtuber_count, streamer_count, youtuber_count + streamer_count;
END $$;
