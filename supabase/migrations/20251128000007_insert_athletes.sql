-- 운동선수 데이터 삽입 (100명)
-- 생성일: 2025-11-28
-- 한국 스포츠 스타 (축구, 야구, 농구, 골프, 피겨, 수영, 배드민턴 등)

INSERT INTO public.celebrities (
    id, name, name_en, legal_name, category, gender,
    birth_date, mbti, blood_type, is_group_member, group_name,
    description, keywords, popularity_score, is_active
) VALUES

-- ===== 축구 =====
('athlete_son_heungmin', '손흥민', 'Son Heung-min', '손흥민', 'athlete', 'male',
 '1992-07-08', 'ESFJ', 'A', false, NULL,
 '토트넘 홋스퍼, 대한민국 국가대표 캡틴', ARRAY['손흥민', 'Son Heung-min', '토트넘', '축구'], 98, true),

('athlete_lee_kangin', '이강인', 'Lee Kang-in', '이강인', 'athlete', 'male',
 '2001-02-19', 'ESTJ', 'A', false, NULL,
 'PSG, 대한민국 국가대표', ARRAY['이강인', 'Lee Kang-in', 'PSG', '축구'], 95, true),

('athlete_kim_minjae', '김민재', 'Kim Min-jae', '김민재', 'athlete', 'male',
 '1996-11-15', 'ISTJ', NULL, false, NULL,
 '바이에른 뮌헨, 수비수', ARRAY['김민재', 'Kim Min-jae', '바이에른', '축구'], 94, true),

('athlete_hwang_heechan', '황희찬', 'Hwang Hee-chan', '황희찬', 'athlete', 'male',
 '1996-01-26', 'ENFJ', NULL, false, NULL,
 '울버햄튼, 공격수', ARRAY['황희찬', 'Hwang Hee-chan', '울버햄튼', '축구'], 92, true),

('athlete_hwang_inbeom', '황인범', 'Hwang In-beom', '황인범', 'athlete', 'male',
 '1996-09-20', NULL, 'A', false, NULL,
 '페예노르트, 미드필더', ARRAY['황인범', 'Hwang In-beom', '축구'], 85, true),

('athlete_cho_gyusung', '조규성', 'Cho Gue-sung', '조규성', 'athlete', 'male',
 '1998-01-25', NULL, NULL, false, NULL,
 '미드틸란, 공격수', ARRAY['조규성', 'Cho Gue-sung', '축구'], 88, true),

('athlete_jung_wooyoung', '정우영', 'Jung Woo-young', '정우영', 'athlete', 'male',
 '1989-12-14', NULL, 'A', false, NULL,
 '알 사드, 미드필더', ARRAY['정우영', 'Jung Woo-young', '축구'], 82, true),

('athlete_kim_youngkwon', '김영권', 'Kim Young-gwon', '김영권', 'athlete', 'male',
 '1990-02-27', NULL, 'A', false, NULL,
 '울산 현대, 수비수', ARRAY['김영권', 'Kim Young-gwon', '축구'], 80, true),

('athlete_park_jisung', '박지성', 'Park Ji-sung', '박지성', 'athlete', 'male',
 '1981-02-25', NULL, 'O', false, NULL,
 '전 맨체스터 유나이티드, 레전드', ARRAY['박지성', 'Park Ji-sung', '맨유', '축구'], 95, true),

('athlete_ki_sungyueng', '기성용', 'Ki Sung-yueng', '기성용', 'athlete', 'male',
 '1989-01-24', NULL, 'O', false, NULL,
 '전 국가대표, 미드필더', ARRAY['기성용', 'Ki Sung-yueng', '축구'], 82, true),

('athlete_cha_bumkun', '차범근', 'Cha Bum-kun', '차범근', 'athlete', 'male',
 '1953-05-22', NULL, 'O', false, NULL,
 '한국 축구 레전드, 분데스리가', ARRAY['차범근', 'Cha Bum-kun', '축구', '레전드'], 90, true),

('athlete_hong_myungbo', '홍명보', 'Hong Myung-bo', '홍명보', 'athlete', 'male',
 '1969-02-12', NULL, 'B', false, NULL,
 '전 국가대표 주장, 현 감독', ARRAY['홍명보', 'Hong Myung-bo', '축구', '감독'], 85, true),

-- ===== 야구 =====
('athlete_ryu_hyunjin', '류현진', 'Ryu Hyun-jin', '류현진', 'athlete', 'male',
 '1987-03-25', NULL, 'O', false, NULL,
 '한화 이글스, 전 MLB 투수', ARRAY['류현진', 'Ryu Hyun-jin', '야구', 'LA 다저스'], 95, true),

('athlete_lee_junghu', '이정후', 'Lee Jung-hoo', '이정후', 'athlete', 'male',
 '1998-08-20', NULL, NULL, false, NULL,
 'SF 자이언츠, 외야수', ARRAY['이정후', 'Lee Jung-hoo', '야구', 'MLB'], 92, true),

('athlete_kim_haseong', '김하성', 'Kim Ha-seong', '김하성', 'athlete', 'male',
 '1995-10-17', NULL, 'A', false, NULL,
 'SD 파드리스, 유격수', ARRAY['김하성', 'Kim Ha-seong', '야구', 'MLB'], 90, true),

('athlete_park_chanho', '박찬호', 'Park Chan-ho', '박찬호', 'athlete', 'male',
 '1973-06-29', NULL, 'B', false, NULL,
 '전 LA 다저스, 한국 MLB 개척자', ARRAY['박찬호', 'Park Chan-ho', '야구', '레전드'], 90, true),

('athlete_choo_shinsoo', '추신수', 'Choo Shin-soo', '추신수', 'athlete', 'male',
 '1982-07-13', NULL, 'O', false, NULL,
 '전 MLB, SSG 랜더스', ARRAY['추신수', 'Choo Shin-soo', '야구'], 88, true),

('athlete_lee_daeho', '이대호', 'Lee Dae-ho', '이대호', 'athlete', 'male',
 '1982-06-21', NULL, 'B', false, NULL,
 '전 롯데 자이언츠, 일본 연수', ARRAY['이대호', 'Lee Dae-ho', '야구'], 85, true),

('athlete_kang_jungho', '강정호', 'Kang Jung-ho', '강정호', 'athlete', 'male',
 '1987-04-05', NULL, 'O', false, NULL,
 '전 피츠버그 파이리츠', ARRAY['강정호', 'Kang Jung-ho', '야구'], 75, true),

('athlete_kim_gwanghyun', '김광현', 'Kim Kwang-hyun', '김광현', 'athlete', 'male',
 '1988-07-22', NULL, NULL, false, NULL,
 'SSG 랜더스, 투수', ARRAY['김광현', 'Kim Kwang-hyun', '야구'], 82, true),

('athlete_yang_hyunjong', '양현종', 'Yang Hyun-jong', '양현종', 'athlete', 'male',
 '1988-03-01', NULL, 'O', false, NULL,
 'KIA 타이거즈, 투수', ARRAY['양현종', 'Yang Hyun-jong', '야구'], 85, true),

-- ===== 골프 =====
('athlete_park_seri', '박세리', 'Pak Se-ri', '박세리', 'athlete', 'female',
 '1977-09-28', NULL, 'A', false, NULL,
 'LPGA 명예의 전당, 한국 골프 선구자', ARRAY['박세리', 'Pak Se-ri', '골프', '레전드'], 95, true),

('athlete_park_inbi', '박인비', 'Park In-bee', '박인비', 'athlete', 'female',
 '1988-07-12', NULL, 'A', false, NULL,
 'LPGA 메이저 7승, 올림픽 금메달', ARRAY['박인비', 'Park In-bee', '골프'], 93, true),

('athlete_ko_jinyoung', '고진영', 'Ko Jin-young', '고진영', 'athlete', 'female',
 '1995-07-07', NULL, NULL, false, NULL,
 'LPGA 세계랭킹 1위', ARRAY['고진영', 'Ko Jin-young', '골프'], 92, true),

('athlete_yang_heeyoung', '양희영', 'Yang Hee-young', '양희영', 'athlete', 'female',
 '1989-07-28', NULL, NULL, false, NULL,
 'LPGA 메이저 우승', ARRAY['양희영', 'Yang Hee-young', '골프'], 88, true),

('athlete_kim_seiyoung', '김세영', 'Kim Sei-young', '김세영', 'athlete', 'female',
 '1993-03-21', NULL, NULL, false, NULL,
 'LPGA 다승왕', ARRAY['김세영', 'Kim Sei-young', '골프'], 87, true),

('athlete_ryu_soyeon', '유소연', 'Ryu So-yeon', '유소연', 'athlete', 'female',
 '1990-12-22', NULL, 'O', false, NULL,
 'LPGA 메이저 2승', ARRAY['유소연', 'Ryu So-yeon', '골프'], 85, true),

('athlete_shin_jiyai', '신지애', 'Shin Ji-yai', '신지애', 'athlete', 'female',
 '1988-04-28', NULL, 'O', false, NULL,
 'LPGA, JLPGA 활동', ARRAY['신지애', 'Shin Ji-yai', '골프'], 82, true),

('athlete_chun_ingi', '전인지', 'Chun In-gee', '전인지', 'athlete', 'female',
 '1994-09-15', NULL, NULL, false, NULL,
 'LPGA 메이저 우승', ARRAY['전인지', 'Chun In-gee', '골프'], 86, true),

('athlete_kim_hyojoo', '김효주', 'Kim Hyo-joo', '김효주', 'athlete', 'female',
 '1995-12-23', NULL, 'B', false, NULL,
 'LPGA 메이저 우승', ARRAY['김효주', 'Kim Hyo-joo', '골프'], 85, true),

('athlete_lee_jeongsin', '이정은6', 'Lee Jeong-eun', '이정은', 'athlete', 'female',
 '1996-08-14', NULL, NULL, false, NULL,
 'LPGA US여자오픈 우승', ARRAY['이정은6', 'Lee Jeong-eun', '골프'], 84, true),

-- ===== 피겨 스케이팅 =====
('athlete_kim_yuna', '김연아', 'Kim Yu-na', '김연아', 'athlete', 'female',
 '1990-09-05', 'ESFJ', 'O', false, NULL,
 '피겨 여왕, 올림픽 금메달', ARRAY['김연아', 'Kim Yu-na', '피겨', '올림픽'], 98, true),

('athlete_cha_junhwan', '차준환', 'Cha Jun-hwan', '차준환', 'athlete', 'male',
 '2001-10-21', 'ENTJ', 'O', false, NULL,
 '피겨 스케이팅, 세계선수권 메달', ARRAY['차준환', 'Cha Jun-hwan', '피겨'], 88, true),

('athlete_kim_yerim', '김예림', 'Kim Ye-lim', '김예림', 'athlete', 'female',
 '2003-02-23', NULL, NULL, false, NULL,
 '피겨 스케이팅', ARRAY['김예림', 'Kim Ye-lim', '피겨'], 80, true),

-- ===== 수영 =====
('athlete_park_taehwan', '박태환', 'Park Tae-hwan', '박태환', 'athlete', 'male',
 '1989-09-27', NULL, 'O', false, NULL,
 '올림픽 수영 금메달', ARRAY['박태환', 'Park Tae-hwan', '수영', '올림픽'], 92, true),

('athlete_hwang_sunwoo', '황선우', 'Hwang Sun-woo', '황선우', 'athlete', 'male',
 '2003-05-21', NULL, NULL, false, NULL,
 '자유형 세계기록', ARRAY['황선우', 'Hwang Sun-woo', '수영'], 88, true),

('athlete_kim_womin', '김우민', 'Kim Woo-min', '김우민', 'athlete', 'male',
 '1999-08-22', NULL, NULL, false, NULL,
 '자유형 국가대표', ARRAY['김우민', 'Kim Woo-min', '수영'], 82, true),

-- ===== 쇼트트랙 =====
('athlete_hwang_daeheon', '황대헌', 'Hwang Dae-heon', '황대헌', 'athlete', 'male',
 '1999-03-15', NULL, NULL, false, NULL,
 '베이징 올림픽 금메달', ARRAY['황대헌', 'Hwang Dae-heon', '쇼트트랙', '올림픽'], 90, true),

('athlete_choi_minjung', '최민정', 'Choi Min-jeong', '최민정', 'athlete', 'female',
 '1998-01-09', NULL, 'A', false, NULL,
 '쇼트트랙 여왕, 올림픽 금메달', ARRAY['최민정', 'Choi Min-jeong', '쇼트트랙', '올림픽'], 92, true),

('athlete_park_seunghi', '박승희', 'Park Seung-hi', '박승희', 'athlete', 'female',
 '1992-02-27', NULL, NULL, false, NULL,
 '소치 올림픽 금메달', ARRAY['박승희', 'Park Seung-hi', '쇼트트랙'], 82, true),

('athlete_kwak_yoongy', '곽윤기', 'Kwak Yoon-gy', '곽윤기', 'athlete', 'male',
 '1989-04-26', NULL, 'O', false, NULL,
 '쇼트트랙, 국가대표', ARRAY['곽윤기', 'Kwak Yoon-gy', '쇼트트랙'], 85, true),

('athlete_shim_seoksee', '심석희', 'Shim Suk-hee', '심석희', 'athlete', 'female',
 '1997-01-03', NULL, NULL, false, NULL,
 '올림픽 쇼트트랙 금메달', ARRAY['심석희', 'Shim Suk-hee', '쇼트트랙'], 80, true),

-- ===== 배드민턴 =====
('athlete_an_seyoung', '안세영', 'An Se-young', '안세영', 'athlete', 'female',
 '2002-02-05', NULL, NULL, false, NULL,
 '배드민턴 세계랭킹 1위', ARRAY['안세영', 'An Se-young', '배드민턴'], 92, true),

('athlete_lee_yongdae', '이용대', 'Lee Yong-dae', '이용대', 'athlete', 'male',
 '1988-09-11', NULL, 'O', false, NULL,
 '배드민턴 레전드, 올림픽 금메달', ARRAY['이용대', 'Lee Yong-dae', '배드민턴'], 88, true),

('athlete_kim_sowoon', '김소영', 'Kim So-yeong', '김소영', 'athlete', 'female',
 '1993-03-08', NULL, NULL, false, NULL,
 '배드민턴 복식', ARRAY['김소영', 'Kim So-yeong', '배드민턴'], 78, true),

-- ===== 농구 =====
('athlete_lee_daesong', '이대성', 'Lee Dae-sung', '이대성', 'athlete', 'male',
 '1994-01-01', NULL, NULL, false, NULL,
 'KBL 농구선수', ARRAY['이대성', 'Lee Dae-sung', '농구'], 75, true),

('athlete_ha_seungjin', '하승진', 'Ha Seung-jin', '하승진', 'athlete', 'male',
 '1985-08-04', NULL, 'A', false, NULL,
 '전 NBA, KBL 레전드', ARRAY['하승진', 'Ha Seung-jin', '농구', 'NBA'], 85, true),

('athlete_moon_taejong', '문태종', 'Moon Tae-jong', '문태종', 'athlete', 'male',
 '1987-06-11', NULL, NULL, false, NULL,
 'KBL 농구선수', ARRAY['문태종', 'Moon Tae-jong', '농구'], 72, true),

('athlete_seo_janghu', '서장훈', 'Seo Jang-hoon', '서장훈', 'athlete', 'male',
 '1974-09-03', NULL, 'O', false, NULL,
 '전 농구선수, 방송인', ARRAY['서장훈', 'Seo Jang-hoon', '농구', '방송인'], 90, true),

-- ===== 배구 =====
('athlete_kim_yeonkoung', '김연경', 'Kim Yeon-koung', '김연경', 'athlete', 'female',
 '1988-02-26', 'ISFP', 'B', false, NULL,
 '배구 여제, 세계적 선수', ARRAY['김연경', 'Kim Yeon-koung', '배구'], 95, true),

('athlete_kim_heejin', '김희진', 'Kim Hee-jin', '김희진', 'athlete', 'female',
 '1990-10-15', NULL, NULL, false, NULL,
 '배구 국가대표', ARRAY['김희진', 'Kim Hee-jin', '배구'], 82, true),

('athlete_yang_hyoseon', '양효진', 'Yang Hyo-jin', '양효진', 'athlete', 'female',
 '1995-01-22', NULL, NULL, false, NULL,
 '배구 국가대표', ARRAY['양효진', 'Yang Hyo-jin', '배구'], 80, true),

('athlete_lee_jaeyoung', '이재영', 'Lee Jae-yeong', '이재영', 'athlete', 'female',
 '1996-09-15', NULL, NULL, false, NULL,
 '배구선수', ARRAY['이재영', 'Lee Jae-yeong', '배구'], 75, true),

-- ===== 테니스 =====
('athlete_chung_hyeon', '정현', 'Chung Hyeon', '정현', 'athlete', 'male',
 '1996-05-19', NULL, 'A', false, NULL,
 '테니스, 호주오픈 4강', ARRAY['정현', 'Chung Hyeon', '테니스'], 85, true),

('athlete_lee_hyungtak', '이형택', 'Lee Hyung-taik', '이형택', 'athlete', 'male',
 '1976-01-03', NULL, 'O', false, NULL,
 '테니스 레전드', ARRAY['이형택', 'Lee Hyung-taik', '테니스'], 80, true),

('athlete_kwon_soonwoo', '권순우', 'Kwon Soon-woo', '권순우', 'athlete', 'male',
 '1997-11-02', NULL, NULL, false, NULL,
 'ATP 투어 활동', ARRAY['권순우', 'Kwon Soon-woo', '테니스'], 78, true),

-- ===== 유도 =====
('athlete_an_changrim', '안창림', 'An Chang-rim', '안창림', 'athlete', 'male',
 '1994-05-22', NULL, NULL, false, NULL,
 '유도 올림픽 동메달', ARRAY['안창림', 'An Chang-rim', '유도', '올림픽'], 82, true),

('athlete_an_baul', '안바울', 'An Ba-ul', '안바울', 'athlete', 'male',
 '1994-01-25', NULL, NULL, false, NULL,
 '유도 올림픽 은메달', ARRAY['안바울', 'An Ba-ul', '유도'], 80, true),

('athlete_kim_jidi', '김지디', 'Kim Ji-ddi', '김지디', 'athlete', 'female',
 '1995-02-14', NULL, NULL, false, NULL,
 '유도 국가대표', ARRAY['김지디', 'Kim Ji-ddi', '유도'], 75, true),

-- ===== 태권도 =====
('athlete_lee_daehoon', '이대훈', 'Lee Dae-hoon', '이대훈', 'athlete', 'male',
 '1992-02-01', NULL, 'B', false, NULL,
 '태권도 올림픽 메달', ARRAY['이대훈', 'Lee Dae-hoon', '태권도', '올림픽'], 85, true),

('athlete_hwang_kyungseon', '황경선', 'Hwang Kyung-seon', '황경선', 'athlete', 'female',
 '1986-05-25', NULL, NULL, false, NULL,
 '태권도 올림픽 금메달', ARRAY['황경선', 'Hwang Kyung-seon', '태권도'], 82, true),

-- ===== 양궁 =====
('athlete_an_san', '안산', 'An San', '안산', 'athlete', 'female',
 '2001-02-27', NULL, NULL, false, NULL,
 '도쿄 올림픽 3관왕', ARRAY['안산', 'An San', '양궁', '올림픽'], 92, true),

('athlete_kim_woogjin', '김우진', 'Kim Woo-jin', '김우진', 'athlete', 'male',
 '1992-06-20', NULL, NULL, false, NULL,
 '양궁 올림픽 금메달', ARRAY['김우진', 'Kim Woo-jin', '양궁', '올림픽'], 88, true),

('athlete_kim_jeydeok', '김제덕', 'Kim Je-deok', '김제덕', 'athlete', 'male',
 '2002-09-27', NULL, NULL, false, NULL,
 '양궁 올림픽 금메달', ARRAY['김제덕', 'Kim Je-deok', '양궁', '올림픽'], 88, true),

('athlete_jang_minjung', '장민희', 'Jang Min-hee', '장민희', 'athlete', 'female',
 '1999-10-22', NULL, NULL, false, NULL,
 '양궁 국가대표', ARRAY['장민희', 'Jang Min-hee', '양궁'], 82, true),

-- ===== 사격 =====
('athlete_jin_jongoh', '진종오', 'Jin Jong-oh', '진종오', 'athlete', 'male',
 '1979-09-24', NULL, 'O', false, NULL,
 '사격 올림픽 4관왕', ARRAY['진종오', 'Jin Jong-oh', '사격', '올림픽'], 90, true),

('athlete_kim_yeji', '김예지', 'Kim Ye-ji', '김예지', 'athlete', 'female',
 '1993-03-06', NULL, NULL, false, NULL,
 '사격 세계기록, 파리 올림픽 은메달', ARRAY['김예지', 'Kim Ye-ji', '사격', '올림픽'], 92, true),

-- ===== 역도 =====
('athlete_jang_miyran', '장미란', 'Jang Mi-ran', '장미란', 'athlete', 'female',
 '1983-10-09', NULL, 'O', false, NULL,
 '역도 올림픽 금메달, 세계기록', ARRAY['장미란', 'Jang Mi-ran', '역도', '올림픽'], 88, true),

-- ===== 펜싱 =====
('athlete_park_sangnyoung', '박상영', 'Park Sang-young', '박상영', 'athlete', 'male',
 '1995-06-06', NULL, NULL, false, NULL,
 '펜싱 에페 올림픽 금메달', ARRAY['박상영', 'Park Sang-young', '펜싱', '올림픽'], 85, true),

('athlete_kim_jiyeon', '김지연', 'Kim Ji-yeon', '김지연', 'athlete', 'female',
 '1988-02-05', NULL, 'A', false, NULL,
 '펜싱 사브르 올림픽 금메달', ARRAY['김지연', 'Kim Ji-yeon', '펜싱', '올림픽'], 85, true),

('athlete_oh_sanguk', '오상욱', 'Oh Sang-uk', '오상욱', 'athlete', 'male',
 '1996-08-29', NULL, NULL, false, NULL,
 '펜싱 사브르 세계랭킹 1위', ARRAY['오상욱', 'Oh Sang-uk', '펜싱'], 88, true),

-- ===== 스켈레톤/봅슬레이 =====
('athlete_yun_sungbin', '윤성빈', 'Yun Sung-bin', '윤성빈', 'athlete', 'male',
 '1994-05-23', NULL, NULL, false, NULL,
 '스켈레톤 올림픽 금메달', ARRAY['윤성빈', 'Yun Sung-bin', '스켈레톤', '올림픽'], 88, true),

-- ===== 스피드 스케이팅 =====
('athlete_lee_sanghwa', '이상화', 'Lee Sang-hwa', '이상화', 'athlete', 'female',
 '1989-02-25', NULL, 'O', false, NULL,
 '스피드 스케이팅 올림픽 2연패', ARRAY['이상화', 'Lee Sang-hwa', '스피드스케이팅', '올림픽'], 92, true),

('athlete_kim_minseok', '김민석', 'Kim Min-seok', '김민석', 'athlete', 'male',
 '1999-09-12', NULL, NULL, false, NULL,
 '스피드 스케이팅 올림픽 동메달', ARRAY['김민석', 'Kim Min-seok', '스피드스케이팅'], 82, true),

('athlete_lee_seunghi', '이승훈', 'Lee Seung-hoon', '이승훈', 'athlete', 'male',
 '1988-03-06', NULL, 'O', false, NULL,
 '스피드 스케이팅 올림픽 금메달', ARRAY['이승훈', 'Lee Seung-hoon', '스피드스케이팅', '올림픽'], 88, true),

-- ===== 컬링 =====
('athlete_kim_eunjung', '김은정', 'Kim Eun-jung', '김은정', 'athlete', 'female',
 '1990-11-29', NULL, NULL, false, NULL,
 '컬링 팀킴, 올림픽 은메달', ARRAY['김은정', 'Kim Eun-jung', '컬링', '팀킴'], 85, true),

('athlete_kim_yeongmi', '김영미', 'Kim Yeong-mi', '김영미', 'athlete', 'female',
 '1990-02-15', NULL, NULL, false, NULL,
 '컬링 팀킴', ARRAY['김영미', 'Kim Yeong-mi', '컬링'], 82, true),

('athlete_kim_choyhi', '김초희', 'Kim Cho-hee', '김초희', 'athlete', 'female',
 '1997-05-20', NULL, NULL, false, NULL,
 '컬링 국가대표', ARRAY['김초희', 'Kim Cho-hee', '컬링'], 78, true),

-- ===== 체조 =====
('athlete_yang_haksen', '양학선', 'Yang Hak-seon', '양학선', 'athlete', 'male',
 '1992-12-05', NULL, 'A', false, NULL,
 '체조 도마 올림픽 금메달', ARRAY['양학선', 'Yang Hak-seon', '체조', '올림픽'], 85, true),

('athlete_yeo_seojeong', '여서정', 'Yeo Seo-jeong', '여서정', 'athlete', 'female',
 '2002-02-20', NULL, NULL, false, NULL,
 '체조 도마 올림픽 동메달', ARRAY['여서정', 'Yeo Seo-jeong', '체조', '올림픽'], 82, true),

-- ===== 럭비 =====
('athlete_jeon_woongyu', '전웅태', 'Jeon Woong-tae', '전웅태', 'athlete', 'male',
 '1995-10-28', NULL, NULL, false, NULL,
 '근대5종 올림픽 메달', ARRAY['전웅태', 'Jeon Woong-tae', '근대5종', '올림픽'], 82, true),

-- ===== 격투기 =====
('athlete_kim_donghyun', '김동현', 'Kim Dong-hyun', '김동현', 'athlete', 'male',
 '1981-06-17', NULL, NULL, false, NULL,
 'UFC 파이터', ARRAY['김동현', 'Kim Dong-hyun', 'UFC', '격투기'], 80, true),

('athlete_jung_chansung', '정찬성', 'Jung Chan-sung', '정찬성', 'athlete', 'male',
 '1987-03-17', NULL, 'O', false, NULL,
 'UFC 코리안 좀비', ARRAY['정찬성', 'Jung Chan-sung', 'UFC', '코리안좀비'], 88, true),

('athlete_choi_duhoo', '최두호', 'Choi Doo-ho', '최두호', 'athlete', 'male',
 '1991-03-31', NULL, NULL, false, NULL,
 'UFC 파이터', ARRAY['최두호', 'Choi Doo-ho', 'UFC', '격투기'], 78, true),

-- ===== 종합 =====
('athlete_roh_sunjin', '노선영', 'Noh Seon-yeong', '노선영', 'athlete', 'female',
 '1989-06-15', NULL, NULL, false, NULL,
 '스피드 스케이팅', ARRAY['노선영', 'Noh Seon-yeong', '스피드스케이팅'], 75, true),

('athlete_lee_sangsu', '이상수', 'Lee Sang-su', '이상수', 'athlete', 'male',
 '1988-12-01', NULL, NULL, false, NULL,
 '탁구 국가대표', ARRAY['이상수', 'Lee Sang-su', '탁구'], 78, true),

('athlete_joo_sehyuk', '주세혁', 'Joo Se-hyuk', '주세혁', 'athlete', 'male',
 '1980-01-20', NULL, NULL, false, NULL,
 '탁구 레전드', ARRAY['주세혁', 'Joo Se-hyuk', '탁구'], 80, true),

('athlete_shin_yubin', '신유빈', 'Shin Yu-bin', '신유빈', 'athlete', 'female',
 '2004-07-05', NULL, NULL, false, NULL,
 '탁구 올림픽 동메달', ARRAY['신유빈', 'Shin Yu-bin', '탁구', '올림픽'], 88, true),

('athlete_lee_youngjae', '이영재', 'Lee Yeong-jae', '이영재', 'athlete', 'male',
 '2001-11-25', NULL, NULL, false, NULL,
 '축구 국가대표', ARRAY['이영재', 'Lee Yeong-jae', '축구'], 78, true),

('athlete_bae_joonho', '배준호', 'Bae Jun-ho', '배준호', 'athlete', 'male',
 '2002-03-17', NULL, NULL, false, NULL,
 '스토크 시티, 축구', ARRAY['배준호', 'Bae Jun-ho', '축구'], 80, true),

('athlete_jeong_sangbin', '정상빈', 'Jeong Sang-bin', '정상빈', 'athlete', 'male',
 '2003-07-25', NULL, NULL, false, NULL,
 '슈투트가르트, 축구', ARRAY['정상빈', 'Jeong Sang-bin', '축구'], 80, true),

('athlete_paik_seungho', '백승호', 'Paik Seung-ho', '백승호', 'athlete', 'male',
 '1997-03-17', NULL, NULL, false, NULL,
 '파사코앙스, 축구', ARRAY['백승호', 'Paik Seung-ho', '축구'], 82, true)

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
    athlete_count INTEGER;
    male_count INTEGER;
    female_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO athlete_count
    FROM celebrities
    WHERE category = 'athlete' AND is_active = true;

    SELECT COUNT(*) INTO male_count
    FROM celebrities
    WHERE category = 'athlete' AND gender = 'male' AND is_active = true;

    SELECT COUNT(*) INTO female_count
    FROM celebrities
    WHERE category = 'athlete' AND gender = 'female' AND is_active = true;

    RAISE NOTICE 'Total athletes: %, Male: %, Female: %', athlete_count, male_count, female_count;
END $$;
