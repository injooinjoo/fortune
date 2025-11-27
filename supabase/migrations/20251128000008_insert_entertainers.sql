-- 방송인 100명 데이터 삽입
-- MC, 개그맨/개그우먼, 아나운서, TV 진행자, 방송 패널 등
-- 2025년 11월 28일

INSERT INTO public.celebrities (
    id, name, name_en, legal_name, category, gender,
    birth_date, mbti, blood_type, is_group_member, group_name,
    description, keywords, popularity_score, is_active
) VALUES
-- ============================================
-- MC / 예능인 (남성)
-- ============================================
('entertainer_yoo_jaesuk', '유재석', 'Yoo Jae-suk', '유재석', 'entertainer', 'male',
 '1972-08-14', 'ISFP', 'B', false, NULL,
 '국민MC, 무한도전, 런닝맨, 유퀴즈', ARRAY['유재석', 'Yoo Jae-suk', '국민MC', '예능대상'], 99, true),

('entertainer_kang_hodong', '강호동', 'Kang Ho-dong', '강호동', 'entertainer', 'male',
 '1970-06-11', 'ESFP', 'A', false, NULL,
 '前 씨름선수, 아는형님, 신서유기', ARRAY['강호동', 'Kang Ho-dong', '1박2일', '아는형님'], 97, true),

('entertainer_shin_dongyeop', '신동엽', 'Shin Dong-yup', '신동엽', 'entertainer', 'male',
 '1971-02-17', 'ENTP', 'A', false, NULL,
 '예능MC, 남자셋여자셋', ARRAY['신동엽', 'Shin Dong-yup', 'MC', '예능'], 96, true),

('entertainer_lee_kyungkyu', '이경규', 'Lee Kyung-kyu', '이경규', 'entertainer', 'male',
 '1960-08-01', 'INTJ', 'A', false, NULL,
 '레전드 개그맨, 남자의자격, 복면가왕', ARRAY['이경규', 'Lee Kyung-kyu', '복면가왕', '남자의자격'], 95, true),

('entertainer_park_myungsoo', '박명수', 'Park Myung-soo', '박명수', 'entertainer', 'male',
 '1970-08-27', 'ISTP', 'A', false, NULL,
 '무한도전, 라디오쇼, 아슬아슬공덕역', ARRAY['박명수', 'Park Myung-soo', '무한도전', '개그맨'], 94, true),

('entertainer_lee_sugeun', '이수근', 'Lee Su-geun', '이수근', 'entertainer', 'male',
 '1976-04-10', 'ENFP', 'O', false, NULL,
 '아는형님, 신서유기, 1박2일', ARRAY['이수근', 'Lee Su-geun', '아는형님', '개그맨'], 95, true),

('entertainer_kim_junho', '김준호', 'Kim Jun-ho', '김준호', 'entertainer', 'male',
 '1975-12-27', 'ESFJ', 'A', false, NULL,
 'KBS 연예대상, 개그맨 리더', ARRAY['김준호', 'Kim Jun-ho', '개그맨', '연예대상'], 92, true),

('entertainer_haha', '하하', 'Ha Ha', '하동훈', 'entertainer', 'male',
 '1979-08-20', 'ENFP', 'B', false, NULL,
 '무한도전, 런닝맨, 래퍼', ARRAY['하하', 'Ha Ha', '런닝맨', '무한도전'], 93, true),

('entertainer_jung_hyungdon', '정형돈', 'Jeong Hyeong-don', '정형돈', 'entertainer', 'male',
 '1978-03-15', 'INFJ', 'O', false, NULL,
 '무한도전, 주간아이돌, 형돈이와대준이', ARRAY['정형돈', 'Jeong Hyeong-don', '무한도전', '주간아이돌'], 88, true),

('entertainer_noh_hongchul', '노홍철', 'Noh Hong-chul', '노홍철', 'entertainer', 'male',
 '1979-03-31', 'ENFP', 'B', false, NULL,
 '무한도전, 일일호프', ARRAY['노홍철', 'Noh Hong-chul', '무한도전', '일일호프'], 86, true),

('entertainer_jung_junha', '정준하', 'Jeong Jun-ha', '정준하', 'entertainer', 'male',
 '1971-03-18', 'ENFP', 'A', false, NULL,
 '무한도전, 맛있는녀석들', ARRAY['정준하', 'Jeong Jun-ha', '무한도전', '맛있는녀석들'], 87, true),

('entertainer_kim_gura', '김구라', 'Kim Gu-ra', '김현동', 'entertainer', 'male',
 '1970-10-03', 'ESTJ', 'O', false, NULL,
 '라디오스타, 동상이몽, 독설가', ARRAY['김구라', 'Kim Gu-ra', '라디오스타', '독설가'], 90, true),

('entertainer_seo_janghoon', '서장훈', 'Seo Jang-hoon', '서장훈', 'entertainer', 'male',
 '1974-06-03', 'ISTJ', 'A', false, NULL,
 '前 농구선수, 아는형님, 동상이몽', ARRAY['서장훈', 'Seo Jang-hoon', '아는형님', '농구'], 93, true),

('entertainer_tak_jaehoon', '탁재훈', 'Tak Jae-hoon', '배성우', 'entertainer', 'male',
 '1968-07-24', 'INFP', 'A', false, NULL,
 '신서유기, 사랑의콜센터', ARRAY['탁재훈', 'Tak Jae-hoon', '신서유기', '사랑의콜센터'], 88, true),

('entertainer_baek_jongwon', '백종원', 'Baek Jong-won', '백종원', 'entertainer', 'male',
 '1966-09-04', 'ENTJ', 'A', false, NULL,
 '요식업 사업가, 흑백요리사, 골목식당', ARRAY['백종원', 'Baek Jong-won', '골목식당', '흑백요리사'], 97, true),

('entertainer_jeon_hyunmoo', '전현무', 'Jeon Hyun-moo', '전현무', 'entertainer', 'male',
 '1977-11-07', 'ENTP', 'B', false, NULL,
 '前 KBS 아나운서, 나혼자산다, I AM', ARRAY['전현무', 'Jeon Hyun-moo', '나혼자산다', '아나운서'], 93, true),

('entertainer_cho_seho', '조세호', 'Cho Se-ho', '조세호', 'entertainer', 'male',
 '1982-08-09', 'ENFP', 'B', false, NULL,
 '유퀴즈, 개그맨, 양배추', ARRAY['조세호', 'Cho Se-ho', '유퀴즈', '개그맨'], 90, true),

('entertainer_nam_heeseok', '남희석', 'Nam Hee-seok', '남희석', 'entertainer', 'male',
 '1971-07-06', 'ENFJ', 'A', false, NULL,
 '전국노래자랑 MC, 오락의신', ARRAY['남희석', 'Nam Hee-seok', '전국노래자랑', 'MC'], 85, true),

('entertainer_park_suhong', '박수홍', 'Park Su-hong', '박수홍', 'entertainer', 'male',
 '1970-10-27', 'ISFJ', 'A', false, NULL,
 '희극인, 미운우리새끼', ARRAY['박수홍', 'Park Su-hong', '개그맨', '미운우리새끼'], 82, true),

('entertainer_boom', '붐', 'Boom', '이민호', 'entertainer', 'male',
 '1982-05-10', 'ESFP', 'O', false, NULL,
 'MC, 라디오DJ, 정글의법칙', ARRAY['붐', 'Boom', 'MC', '라디오'], 88, true),

('entertainer_kim_sungju', '김성주', 'Kim Sung-joo', '김성주', 'entertainer', 'male',
 '1972-10-10', 'ESFJ', 'B', false, NULL,
 '前 MBC 아나운서, 뭉쳐야찬다', ARRAY['김성주', 'Kim Sung-joo', '아나운서', 'MC'], 86, true),

('entertainer_kim_yongman', '김용만', 'Kim Yong-man', '김용만', 'entertainer', 'male',
 '1967-11-30', 'INFJ', 'A', false, NULL,
 '개그맨, 세바퀴, 뭉쳐야뜬다', ARRAY['김용만', 'Kim Yong-man', '개그맨', '세바퀴'], 84, true),

('entertainer_jang_sunggyu', '장성규', 'Jang Sung-kyu', '장성규', 'entertainer', 'male',
 '1983-04-21', 'ISFP', 'A', false, NULL,
 '前 JTBC 아나운서, 워크맨', ARRAY['장성규', 'Jang Sung-kyu', '워크맨', '아나운서'], 90, true),

('entertainer_kim_jongkook', '김종국', 'Kim Jong-kook', '김종국', 'entertainer', 'male',
 '1976-04-25', 'ISFP', 'AB', false, NULL,
 '가수 겸 방송인, 런닝맨, 미운우리새끼', ARRAY['김종국', 'Kim Jong-kook', '런닝맨', '터보'], 95, true),

('entertainer_ji_sukjin', '지석진', 'Ji Suk-jin', '지석진', 'entertainer', 'male',
 '1966-02-10', 'ESFP', 'A', false, NULL,
 '런닝맨, 개그맨', ARRAY['지석진', 'Ji Suk-jin', '런닝맨', '개그맨'], 88, true),

('entertainer_yang_sechan', '양세찬', 'Yang Se-chan', '양세찬', 'entertainer', 'male',
 '1986-12-08', 'ISFP', 'B', false, NULL,
 '런닝맨, 개그맨, 양세형 동생', ARRAY['양세찬', 'Yang Se-chan', '런닝맨', '개그맨'], 86, true),

('entertainer_hwang_gwanghee', '황광희', 'Hwang Kwang-hee', '황광희', 'entertainer', 'male',
 '1988-08-25', 'ESFJ', 'A', false, NULL,
 '前 제국의아이들, 무한도전', ARRAY['황광희', 'Hwang Kwang-hee', '무한도전', '제국의아이들'], 85, true),

('entertainer_sung_sikyung', '성시경', 'Sung Si-kyung', '성시경', 'entertainer', 'male',
 '1979-04-17', 'INFP', 'O', false, NULL,
 '가수 겸 방송인, 먹방유튜버', ARRAY['성시경', 'Sung Si-kyung', '가수', '먹방'], 92, true),

('entertainer_ahn_jungwhan', '안정환', 'Ahn Jung-hwan', '안정환', 'entertainer', 'male',
 '1976-01-27', 'ESFP', 'B', false, NULL,
 '前 축구선수, 방송인', ARRAY['안정환', 'Ahn Jung-hwan', '축구', '방송인'], 88, true),

('entertainer_jung_jongchul', '정종철', 'Jeong Jong-chul', '정종철', 'entertainer', 'male',
 '1977-07-06', 'ENFP', 'A', false, NULL,
 '개그맨, 개콘, 웃찾사', ARRAY['정종철', 'Jeong Jong-chul', '개그맨', '개콘'], 78, true),

('entertainer_defconn', '데프콘', 'Defconn', '유대준', 'entertainer', 'male',
 '1977-01-06', 'ENFP', 'A', false, NULL,
 '래퍼 겸 방송인, 주간아이돌', ARRAY['데프콘', 'Defconn', '주간아이돌', '래퍼'], 80, true),

('entertainer_kim_byungman', '김병만', 'Kim Byung-man', '김병만', 'entertainer', 'male',
 '1975-07-19', 'INFP', 'B', false, NULL,
 '개그맨, 정글의법칙, 달인', ARRAY['김병만', 'Kim Byung-man', '정글의법칙', '달인'], 88, true),

('entertainer_yoo_seyoon', '유세윤', 'Yoo Se-yoon', '유세윤', 'entertainer', 'male',
 '1978-03-24', 'ENTP', 'A', false, NULL,
 '개그맨, 유산슬', ARRAY['유세윤', 'Yoo Se-yoon', '개그맨', '유산슬'], 85, true),

('entertainer_kim_jongmin', '김종민', 'Kim Jong-min', '김종민', 'entertainer', 'male',
 '1979-11-07', 'ENFP', 'A', false, NULL,
 'KOYOTE, 1박2일, 천재아이돌', ARRAY['김종민', 'Kim Jong-min', '1박2일', 'KOYOTE'], 90, true),

('entertainer_munyeong', '문세윤', 'Moon Se-yoon', '문세윤', 'entertainer', 'male',
 '1983-05-05', 'ENFJ', 'A', false, NULL,
 '개그맨, 맛있는녀석들', ARRAY['문세윤', 'Moon Se-yoon', '맛있는녀석들', '개그맨'], 85, true),

('entertainer_kim_daejun', '김대희', 'Kim Dae-hee', '김대희', 'entertainer', 'male',
 '1975-08-01', 'ENFJ', 'O', false, NULL,
 '개그맨, 코미디빅리그', ARRAY['김대희', 'Kim Dae-hee', '개그맨', '코미디빅리그'], 80, true),

('entertainer_yoo_sangmoo', '유상무', 'Yoo Sang-moo', '유상무', 'entertainer', 'male',
 '1974-07-08', 'ENFP', 'A', false, NULL,
 '개그맨, 개콘, 라면먹고갈래요', ARRAY['유상무', 'Yoo Sang-moo', '개그맨', '개콘'], 75, true),

('entertainer_jo_kwon', '조권', 'Jo Kwon', '조권', 'entertainer', 'male',
 '1989-08-28', 'ENFP', 'O', false, NULL,
 '前 2AM, 방송인, 뮤지컬배우', ARRAY['조권', 'Jo Kwon', '2AM', '방송인'], 80, true),

('entertainer_kim_heechul', '김희철', 'Kim Hee-chul', '김희철', 'entertainer', 'male',
 '1983-07-10', 'ESFP', 'AB', false, NULL,
 '슈퍼주니어, 아는형님', ARRAY['김희철', 'Kim Hee-chul', '슈퍼주니어', '아는형님'], 92, true),

('entertainer_yang_sehyung', '양세형', 'Yang Se-hyung', '양세형', 'entertainer', 'male',
 '1983-01-10', 'ENFP', 'B', false, NULL,
 '개그맨, 양세찬 형, MBC 라디오', ARRAY['양세형', 'Yang Se-hyung', '개그맨', '라디오'], 82, true),

('entertainer_shin_bora', '신봉선', 'Shin Bong-sun', '신봉선', 'entertainer', 'female',
 '1975-11-12', 'INFP', 'A', false, NULL,
 '개그우먼, 개콘', ARRAY['신봉선', 'Shin Bong-sun', '개그우먼', '개콘'], 78, true),

('entertainer_lee_kwangsoo', '이광수', 'Lee Kwang-soo', '이광수', 'entertainer', 'male',
 '1985-07-14', 'ISFP', 'A', false, NULL,
 '배우 겸 예능인, 런닝맨', ARRAY['이광수', 'Lee Kwang-soo', '런닝맨', '배우'], 93, true),

-- ============================================
-- MC / 예능인 (여성)
-- ============================================
('entertainer_song_euni', '송은이', 'Song Eun-i', '송은이', 'entertainer', 'female',
 '1973-02-06', 'ENFP', 'O', false, NULL,
 '개그우먼, 비밀보장, 대화의희열', ARRAY['송은이', 'Song Eun-i', '개그우먼', '비밀보장'], 88, true),

('entertainer_kim_sook', '김숙', 'Kim Sook', '김숙', 'entertainer', 'female',
 '1975-07-06', 'ESFP', 'A', false, NULL,
 '개그우먼, 비밀보장, 언니한땀언니', ARRAY['김숙', 'Kim Sook', '개그우먼', '비밀보장'], 90, true),

('entertainer_lee_youngja', '이영자', 'Lee Young-ja', '이영자', 'entertainer', 'female',
 '1967-12-19', 'ENFP', 'O', false, NULL,
 '개그우먼, 전참시, 먹방여왕', ARRAY['이영자', 'Lee Young-ja', '개그우먼', '전참시'], 92, true),

('entertainer_park_narae', '박나래', 'Park Na-rae', '박나래', 'entertainer', 'female',
 '1985-10-25', 'ESFP', 'B', false, NULL,
 '개그우먼, 나혼자산다, 노래방', ARRAY['박나래', 'Park Na-rae', '나혼자산다', '개그우먼'], 93, true),

('entertainer_ahn_youngmi', '안영미', 'Ahn Young-mi', '안영미', 'entertainer', 'female',
 '1983-11-05', 'ESTP', 'O', false, NULL,
 '개그우먼, SNL코리아', ARRAY['안영미', 'Ahn Young-mi', '개그우먼', 'SNL'], 85, true),

('entertainer_jang_doyeon', '장도연', 'Jang Do-yeon', '장도연', 'entertainer', 'female',
 '1985-05-28', 'ENFP', 'A', false, NULL,
 '개그우먼, 코미디빅리그', ARRAY['장도연', 'Jang Do-yeon', '개그우먼', '코미디빅리그'], 88, true),

('entertainer_hong_hyunhee', '홍현희', 'Hong Hyun-hee', '홍현희', 'entertainer', 'female',
 '1986-04-10', 'ESFP', 'O', false, NULL,
 '개그우먼, 이사배, 제이쓴 아내', ARRAY['홍현희', 'Hong Hyun-hee', '개그우먼', '이사배'], 85, true),

('entertainer_shin_ahyoung', '신아영', 'Shin Ah-young', '신아영', 'entertainer', 'female',
 '1989-05-13', 'ENFP', 'A', false, NULL,
 '前 YTN 아나운서, 출장십오야', ARRAY['신아영', 'Shin Ah-young', '아나운서', '출장십오야'], 82, true),

('entertainer_hong_jinkyung', '홍진경', 'Hong Jin-kyung', '홍진경', 'entertainer', 'female',
 '1977-12-23', 'ENFP', 'O', false, NULL,
 '모델 겸 방송인, 유튜버', ARRAY['홍진경', 'Hong Jin-kyung', '모델', '유튜버'], 86, true),

('entertainer_park_sohyun', '박소현', 'Park So-hyun', '박소현', 'entertainer', 'female',
 '1971-02-11', 'INFP', 'A', false, NULL,
 '배우 겸 방송인, 러브게임', ARRAY['박소현', 'Park So-hyun', '라디오', '러브게임'], 80, true),

('entertainer_lee_hyunyi', '이현이', 'Lee Hyun-yi', '이현이', 'entertainer', 'female',
 '1983-07-28', 'ENFP', 'B', false, NULL,
 '모델 겸 방송인', ARRAY['이현이', 'Lee Hyun-yi', '모델', '방송인'], 82, true),

('entertainer_sayuri', '사유리', 'Sayuri', '후지타 사유리', 'entertainer', 'female',
 '1979-10-13', 'ENFP', 'A', false, NULL,
 '일본 출신 방송인, 미녀들의수다', ARRAY['사유리', 'Sayuri', '방송인', '미녀들의수다'], 80, true),

('entertainer_kim_jihye', '김지혜', 'Kim Ji-hye', '김지혜', 'entertainer', 'female',
 '1983-06-30', 'ESFP', 'A', false, NULL,
 '개그우먼, 박준형 아내', ARRAY['김지혜', 'Kim Ji-hye', '개그우먼', '박준형'], 78, true),

('entertainer_shin_dongyeopw', '신동미', 'Shin Dong-mi', '신동미', 'entertainer', 'female',
 '1980-02-23', 'ENFJ', 'O', false, NULL,
 '개그우먼, 코미디빅리그', ARRAY['신동미', 'Shin Dong-mi', '개그우먼', '코미디빅리그'], 75, true),

('entertainer_kim_jimin', '김지민', 'Kim Ji-min', '김지민', 'entertainer', 'female',
 '1986-03-17', 'ENFP', 'B', false, NULL,
 '개그우먼, 김준호 연인', ARRAY['김지민', 'Kim Ji-min', '개그우먼', '김준호'], 80, true),

('entertainer_song_jihyo', '송지효', 'Song Ji-hyo', '천성임', 'entertainer', 'female',
 '1981-08-15', 'ISFP', 'AB', false, NULL,
 '배우 겸 예능인, 런닝맨', ARRAY['송지효', 'Song Ji-hyo', '런닝맨', '배우'], 92, true),

('entertainer_jeon_somin', '전소민', 'Jeon So-min', '전소민', 'entertainer', 'female',
 '1986-07-06', 'ENFP', 'A', false, NULL,
 '배우 겸 예능인, 런닝맨', ARRAY['전소민', 'Jeon So-min', '런닝맨', '배우'], 85, true),

('entertainer_han_hyejin', '한혜진', 'Han Hye-jin', '한혜진', 'entertainer', 'female',
 '1983-10-27', 'INFJ', 'A', false, NULL,
 '모델 겸 방송인, 전지적참견시점', ARRAY['한혜진', 'Han Hye-jin', '모델', '방송인'], 86, true),

('entertainer_kim_sarang', '김새론', 'Kim Sae-rom', '이선경', 'entertainer', 'female',
 '1983-11-01', 'ENFP', 'A', false, NULL,
 '배우 겸 방송인', ARRAY['김새롬', 'Kim Sae-rom', '배우', '방송인'], 78, true),

('entertainer_park_mison', '박미선', 'Park Mi-sun', '박미선', 'entertainer', 'female',
 '1967-09-22', 'ESFP', 'A', false, NULL,
 '개그우먼, 이봉원 아내', ARRAY['박미선', 'Park Mi-sun', '개그우먼', '이봉원'], 82, true),

-- ============================================
-- 아나운서 출신 방송인
-- ============================================
('entertainer_oh_sangwook', '오상욱', 'Oh Sang-jin', '오상진', 'entertainer', 'male',
 '1977-11-15', 'ENFJ', 'A', false, NULL,
 '前 MBC 아나운서, 김소영 남편', ARRAY['오상진', 'Oh Sang-jin', '아나운서', 'MBC'], 80, true),

('entertainer_jun_hyunmoo2', '도경완', 'Do Kyung-wan', '도경완', 'entertainer', 'male',
 '1982-04-15', 'INFP', 'A', false, NULL,
 'KBS 아나운서, 장윤정 남편', ARRAY['도경완', 'Do Kyung-wan', '아나운서', '장윤정'], 78, true),

('entertainer_kim_taewoo', '김태균', 'Kim Tae-gyun', '김태균', 'entertainer', 'male',
 '1971-04-08', 'ENFP', 'O', false, NULL,
 '개그맨, 붐빰 스튜디오', ARRAY['김태균', 'Kim Tae-gyun', '개그맨', '붐빰스튜디오'], 75, true),

('entertainer_kang_jiyoung', '강지영', 'Kang Ji-young', '강지영', 'entertainer', 'female',
 '1985-06-03', 'ENFP', 'A', false, NULL,
 '前 JTBC 아나운서', ARRAY['강지영', 'Kang Ji-young', '아나운서', 'JTBC'], 78, true),

('entertainer_kim_sohyun', '김소현', 'Kim So-hyun', '김소현', 'entertainer', 'female',
 '1979-03-01', 'ENFJ', 'A', false, NULL,
 '前 SBS 아나운서, 손범수 아내', ARRAY['김소현', 'Kim So-hyun', '아나운서', 'SBS'], 76, true),

('entertainer_son_bumsu', '손범수', 'Son Bum-soo', '손범수', 'entertainer', 'male',
 '1967-08-07', 'ENFJ', 'B', false, NULL,
 '前 MBC 아나운서, MC', ARRAY['손범수', 'Son Bum-soo', '아나운서', 'MC'], 78, true),

('entertainer_lee_sora', '이소라', 'Lee So-ra', '이소라', 'entertainer', 'female',
 '1974-05-10', 'INFP', 'O', false, NULL,
 '라디오DJ, 이소라의 가요광장', ARRAY['이소라', 'Lee So-ra', '라디오', 'DJ'], 72, true),

('entertainer_bae_chilsu', '배철수', 'Bae Chul-soo', '배철수', 'entertainer', 'male',
 '1953-05-01', 'INTP', 'A', false, NULL,
 '前 송골매, 배철수의음악캠프', ARRAY['배철수', 'Bae Chul-soo', '라디오', '음악캠프'], 85, true),

-- ============================================
-- 기타 방송인 / 패널
-- ============================================
('entertainer_park_junhyung', '박준형', 'Park Joon-hyung', '박준형', 'entertainer', 'male',
 '1969-03-03', 'ENFP', 'B', false, NULL,
 'god, 방송인, 1세대 아이돌', ARRAY['박준형', 'Park Joon-hyung', 'god', '방송인'], 85, true),

('entertainer_tony_ahn', '토니안', 'Tony An', '안승호', 'entertainer', 'male',
 '1978-06-07', 'ESFP', 'A', false, NULL,
 'H.O.T, 방송인', ARRAY['토니안', 'Tony An', 'H.O.T', '방송인'], 80, true),

('entertainer_moon_heejun', '문희준', 'Moon Hee-jun', '문희준', 'entertainer', 'male',
 '1978-03-14', 'ENFP', 'O', false, NULL,
 'H.O.T, 방송인, 소율 남편', ARRAY['문희준', 'Moon Hee-jun', 'H.O.T', '방송인'], 78, true),

('entertainer_kangnam', '강남', 'Kangnam', '나카마 야스히로', 'entertainer', 'male',
 '1987-03-23', 'ESFP', 'O', false, NULL,
 '前 M.I.B, 방송인, 이상화 남편', ARRAY['강남', 'Kangnam', 'M.I.B', '방송인'], 82, true),

('entertainer_sam_hammington', '샘 해밍턴', 'Sam Hammington', 'Samuel Donald Hammington', 'entertainer', 'male',
 '1977-03-31', 'ENFP', 'O', false, NULL,
 '호주 출신 방송인, 슈퍼맨이돌아왔다', ARRAY['샘해밍턴', 'Sam Hammington', '슈퍼맨', '윌리엄'], 88, true),

('entertainer_alberto', '알베르토', 'Alberto Mondi', 'Alberto Mondi', 'entertainer', 'male',
 '1984-07-17', 'ENFP', 'A', false, NULL,
 '이탈리아 출신 방송인', ARRAY['알베르토', 'Alberto Mondi', '이탈리아', '방송인'], 75, true),

('entertainer_sam_okyere', '샘 오취리', 'Sam Okyere', 'Samuel Okyere', 'entertainer', 'male',
 '1988-07-10', 'ENFP', 'O', false, NULL,
 '가나 출신 방송인', ARRAY['샘오취리', 'Sam Okyere', '가나', '방송인'], 72, true),

('entertainer_julian', '줄리안', 'Julian Quintart', 'Julian Quintart', 'entertainer', 'male',
 '1983-08-12', 'ENFP', 'B', false, NULL,
 '벨기에 출신 방송인', ARRAY['줄리안', 'Julian', '벨기에', '방송인'], 70, true),

('entertainer_lee_bonggwon', '이봉원', 'Lee Bong-won', '이봉원', 'entertainer', 'male',
 '1965-03-20', 'ENFP', 'A', false, NULL,
 '개그맨, 박미선 남편, 포차인더파크', ARRAY['이봉원', 'Lee Bong-won', '개그맨', '박미선'], 75, true),

('entertainer_im_wonhee', '임원희', 'Im Won-hee', '임원희', 'entertainer', 'male',
 '1970-07-18', 'INFP', 'A', false, NULL,
 '개그맨, 배우', ARRAY['임원희', 'Im Won-hee', '개그맨', '배우'], 78, true),

('entertainer_ji_sangryul', '지상렬', 'Ji Sang-ryul', '지상렬', 'entertainer', 'male',
 '1965-06-06', 'ENFP', 'B', false, NULL,
 '개그맨, 지상렬쇼', ARRAY['지상렬', 'Ji Sang-ryul', '개그맨', '지상렬쇼'], 72, true),

('entertainer_lee_sangyoon', '이상윤', 'Lee Sang-yoon', '이상윤', 'entertainer', 'male',
 '1981-08-15', 'ISFJ', 'A', false, NULL,
 '배우 겸 예능인, 집사부일체', ARRAY['이상윤', 'Lee Sang-yoon', '배우', '집사부일체'], 80, true),

('entertainer_hwang_jaesung', '황제성', 'Hwang Je-sung', '황제성', 'entertainer', 'male',
 '1985-12-27', 'ENFP', 'A', false, NULL,
 '개그맨, 주호민 웹툰 성우', ARRAY['황제성', 'Hwang Je-sung', '개그맨', '주호민'], 75, true),

('entertainer_lee_yongjin', '이용진', 'Lee Yong-jin', '이용진', 'entertainer', 'male',
 '1983-06-17', 'ENTP', 'O', false, NULL,
 '개그맨, 엉아, 장항준 닮은꼴', ARRAY['이용진', 'Lee Yong-jin', '개그맨', '엉아'], 78, true),

('entertainer_jo_junghwan', '이진호', 'Lee Jin-ho', '이진호', 'entertainer', 'male',
 '1984-07-16', 'ENFP', 'A', false, NULL,
 '개그맨, 상황극, 코미디빅리그', ARRAY['이진호', 'Lee Jin-ho', '개그맨', '코미디빅리그'], 78, true),

('entertainer_lee_chanwon', '이찬원', 'Lee Chan-won', '이찬원', 'entertainer', 'male',
 '1997-11-21', 'ENFJ', 'A', false, NULL,
 '트로트가수 겸 방송인, 미스터트롯', ARRAY['이찬원', 'Lee Chan-won', '트로트', '미스터트롯'], 90, true),

('entertainer_im_youngwoong', '임영웅', 'Lim Young-woong', '임영웅', 'entertainer', 'male',
 '1991-06-16', 'ISFP', 'O', false, NULL,
 '트로트가수 겸 방송인, 미스터트롯', ARRAY['임영웅', 'Lim Young-woong', '트로트', '미스터트롯'], 98, true),

('entertainer_jang_minho', '장민호', 'Jang Min-ho', '장민호', 'entertainer', 'male',
 '1977-04-07', 'ENFP', 'A', false, NULL,
 '트로트가수 겸 방송인, 미스터트롯', ARRAY['장민호', 'Jang Min-ho', '트로트', '미스터트롯'], 88, true),

('entertainer_hong_jinyoung', '홍진영', 'Hong Jin-young', '홍진영', 'entertainer', 'female',
 '1985-08-09', 'ESFP', 'B', false, NULL,
 '트로트가수 겸 방송인', ARRAY['홍진영', 'Hong Jin-young', '트로트', '방송인'], 85, true),

('entertainer_jang_yunjung', '장윤정', 'Jang Yun-jeong', '장윤정', 'entertainer', 'female',
 '1980-02-16', 'ESFJ', 'B', false, NULL,
 '트로트가수, 도경완 아내', ARRAY['장윤정', 'Jang Yun-jeong', '트로트', '어머나'], 90, true),

('entertainer_lee_hyori', '이효리', 'Lee Hyo-ri', '이효리', 'entertainer', 'female',
 '1979-05-10', 'ESFP', 'A', false, NULL,
 '前 핑클, 솔로가수, 방송인', ARRAY['이효리', 'Lee Hyo-ri', '핑클', '텐미닛'], 95, true),

('entertainer_song_haena', '송해나', 'Song Hae-na', '송해나', 'entertainer', 'female',
 '1992-06-17', 'ENFP', 'A', false, NULL,
 '코미디언, 코미디빅리그', ARRAY['송해나', 'Song Hae-na', '코미디언', '코미디빅리그'], 72, true),

('entertainer_jang_kiha', '장기하', 'Jang Ki-ha', '장기하', 'entertainer', 'male',
 '1982-05-20', 'INTP', 'A', false, NULL,
 '싱어송라이터 겸 방송인', ARRAY['장기하', 'Jang Ki-ha', '싱어송라이터', '방송인'], 78, true),

('entertainer_yoo_heeyeol', '유희열', 'Yoo Hee-yeol', '유희열', 'entertainer', 'male',
 '1971-04-19', 'INFP', 'A', false, NULL,
 '뮤지션 겸 MC, 스케치북', ARRAY['유희열', 'Yoo Hee-yeol', '스케치북', '안테나'], 88, true),

('entertainer_lee_jungi', '이적', 'Lee Juck', '이동준', 'entertainer', 'male',
 '1974-04-27', 'INFP', 'A', false, NULL,
 '싱어송라이터 겸 방송인', ARRAY['이적', 'Lee Juck', '싱어송라이터', '하늘을달리다'], 82, true)

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
    inserted_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO inserted_count
    FROM celebrities
    WHERE category = 'entertainer'
    AND is_active = true;

    RAISE NOTICE 'Total active entertainers: %', inserted_count;
END $$;
