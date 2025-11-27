-- 기업인 100명 데이터 삽입
-- 대기업 총수, IT 창업자, 스타트업 대표, 엔터테인먼트 기업인 등

INSERT INTO public.celebrities (
    id, name, name_en, legal_name, category, gender,
    birth_date, mbti, blood_type, is_group_member, group_name,
    description, keywords, popularity_score, is_active
) VALUES

-- ============================================
-- 대기업 총수 (Chaebol Leaders)
-- ============================================

-- 삼성그룹
('business_lee_jaeyong', '이재용', 'Lee Jae-yong', '이재용', 'business_leader', 'male',
 '1968-06-23', 'ISFP', NULL, true, '삼성그룹',
 '삼성전자 회장, 삼성그룹 총수', ARRAY['이재용', 'Lee Jae-yong', '삼성', '삼성전자', '재벌'], 98, true),

('business_lee_seokhyun', '이석현', 'Lee Suk-hyun', '이석현', 'business_leader', 'male',
 '1970-01-01', NULL, NULL, true, '삼성그룹',
 '삼성물산 부회장', ARRAY['이석현', '삼성물산', '삼성'], 75, true),

('business_lee_seohyun', '이서현', 'Lee Seo-hyun', '이서현', 'business_leader', 'female',
 '1973-09-20', NULL, NULL, true, '삼성그룹',
 '삼성물산 사장, 이건희 차녀', ARRAY['이서현', '삼성물산', '삼성가', '여성기업인'], 80, true),

-- 현대자동차그룹
('business_chung_euisun', '정의선', 'Chung Eui-sun', '정의선', 'business_leader', 'male',
 '1970-10-18', NULL, NULL, true, '현대자동차그룹',
 '현대자동차그룹 회장', ARRAY['정의선', 'Chung Eui-sun', '현대차', '현대자동차', '재벌'], 96, true),

-- SK그룹
('business_chey_taeone', '최태원', 'Chey Tae-won', '최태원', 'business_leader', 'male',
 '1960-12-03', 'INTP', NULL, true, 'SK그룹',
 'SK그룹 회장, 대한상공회의소 회장', ARRAY['최태원', 'Chey Tae-won', 'SK', '대한상의'], 95, true),

('business_chey_jaewon', '최재원', 'Chey Jae-won', '최재원', 'business_leader', 'male',
 '1963-04-15', NULL, NULL, true, 'SK그룹',
 'SK수펙스 부회장', ARRAY['최재원', 'SK', 'SK수펙스'], 70, true),

-- LG그룹
('business_koo_kwangmo', '구광모', 'Koo Kwang-mo', '구광모', 'business_leader', 'male',
 '1978-05-08', NULL, NULL, true, 'LG그룹',
 'LG그룹 회장', ARRAY['구광모', 'Koo Kwang-mo', 'LG', 'LG전자', '재벌'], 92, true),

-- 롯데그룹
('business_shin_donbin', '신동빈', 'Shin Dong-bin', '신동빈', 'business_leader', 'male',
 '1955-02-14', NULL, NULL, true, '롯데그룹',
 '롯데그룹 회장', ARRAY['신동빈', 'Shin Dong-bin', '롯데', '롯데그룹'], 88, true),

-- 신세계그룹
('business_chung_yongjin', '정용진', 'Chung Yong-jin', '정용진', 'business_leader', 'male',
 '1968-09-19', 'INFJ', NULL, true, '신세계그룹',
 '신세계그룹 회장, SNS 재벌', ARRAY['정용진', 'Chung Yong-jin', '신세계', '이마트', '스타벅스'], 93, true),

('business_lee_myunghee', '이명희', 'Lee Myung-hee', '이명희', 'business_leader', 'female',
 '1943-10-15', NULL, NULL, true, '신세계그룹',
 '신세계그룹 회장, 이병철 딸', ARRAY['이명희', '신세계', '이건희 누나'], 75, true),

-- 한화그룹
('business_kim_seungyeon', '김승연', 'Kim Seung-yeon', '김승연', 'business_leader', 'male',
 '1952-02-07', NULL, NULL, true, '한화그룹',
 '한화그룹 회장', ARRAY['김승연', 'Kim Seung-yeon', '한화', '한화그룹'], 82, true),

('business_kim_dongkwan', '김동관', 'Kim Dong-kwan', '김동관', 'business_leader', 'male',
 '1983-03-15', NULL, NULL, true, '한화그룹',
 '한화솔루션 대표, 김승연 장남', ARRAY['김동관', '한화솔루션', '한화', '재벌3세'], 78, true),

-- 두산그룹
('business_park_jungwon', '박정원', 'Park Jung-won', '박정원', 'business_leader', 'male',
 '1962-03-09', NULL, NULL, true, '두산그룹',
 '두산그룹 회장', ARRAY['박정원', 'Park Jung-won', '두산', '두산그룹'], 75, true),

-- CJ그룹
('business_lee_jaehyun', '이재현', 'Lee Jae-hyun', '이재현', 'business_leader', 'male',
 '1960-03-19', NULL, NULL, true, 'CJ그룹',
 'CJ그룹 회장, 이병철 장손', ARRAY['이재현', 'Lee Jae-hyun', 'CJ', 'CJ그룹'], 80, true),

('business_son_kyungsik', '손경식', 'Son Kyung-sik', '손경식', 'business_leader', 'male',
 '1939-09-15', NULL, NULL, true, 'CJ그룹',
 'CJ그룹 회장, 경총 회장', ARRAY['손경식', 'Son Kyung-sik', 'CJ', '경총'], 72, true),

('business_lee_mikyung', '이미경', 'Lee Mi-kyung', '이미경', 'business_leader', 'female',
 '1958-01-01', NULL, NULL, true, 'CJ그룹',
 'CJ ENM 부회장', ARRAY['이미경', 'CJ ENM', 'CJ', '여성기업인'], 76, true),

-- 현대백화점그룹
('business_chung_jisun', '정지선', 'Chung Ji-sun', '정지선', 'business_leader', 'male',
 '1972-10-20', NULL, NULL, true, '현대백화점그룹',
 '현대백화점그룹 회장', ARRAY['정지선', 'Chung Ji-sun', '현대백화점'], 78, true),

-- 한진그룹
('business_cho_wontae', '조원태', 'Cho Won-tae', '조원태', 'business_leader', 'male',
 '1967-01-01', NULL, NULL, true, '한진그룹',
 '한진그룹 회장, 대한항공 회장', ARRAY['조원태', 'Cho Won-tae', '한진', '대한항공'], 80, true),

('business_cho_hyuna', '조현아', 'Cho Hyun-ah', '조현아', 'business_leader', 'female',
 '1974-11-04', NULL, NULL, true, '한진그룹',
 '전 대한항공 부사장, 땅콩회항', ARRAY['조현아', '땅콩회항', '대한항공', '한진'], 72, true),

-- GS그룹
('business_huh_taesoo', '허태수', 'Huh Tae-soo', '허태수', 'business_leader', 'male',
 '1962-01-01', NULL, NULL, true, 'GS그룹',
 'GS그룹 회장', ARRAY['허태수', 'Huh Tae-soo', 'GS', 'GS칼텍스'], 75, true),

-- LS그룹
('business_koo_jayeol', '구자열', 'Koo Ja-yeol', '구자열', 'business_leader', 'male',
 '1953-01-01', NULL, NULL, true, 'LS그룹',
 'LS그룹 회장', ARRAY['구자열', 'Koo Ja-yeol', 'LS', 'LS전선'], 72, true),

-- 효성그룹
('business_cho_hyunsang', '조현상', 'Cho Hyun-sang', '조현상', 'business_leader', 'male',
 '1973-03-15', NULL, NULL, true, '효성그룹',
 'HS효성 부회장', ARRAY['조현상', 'Cho Hyun-sang', '효성', 'HS효성'], 70, true),

-- DL그룹
('business_lee_haewook', '이해욱', 'Lee Hae-wook', '이해욱', 'business_leader', 'male',
 '1968-02-14', NULL, NULL, true, 'DL그룹',
 'DL그룹 회장', ARRAY['이해욱', 'Lee Hae-wook', 'DL', '대림'], 72, true),

-- 포스코
('business_choi_jungwoo', '최정우', 'Choi Jung-woo', '최정우', 'business_leader', 'male',
 '1957-04-10', NULL, NULL, true, '포스코',
 '포스코 전 회장', ARRAY['최정우', 'Choi Jung-woo', '포스코', 'POSCO'], 75, true),

-- ============================================
-- IT/플랫폼 기업 창업자
-- ============================================

-- 네이버
('business_lee_haejin', '이해진', 'Lee Hae-jin', '이해진', 'business_leader', 'male',
 '1967-06-22', NULL, NULL, true, '네이버',
 '네이버 창업자, 이사회 의장', ARRAY['이해진', 'Lee Hae-jin', '네이버', 'NAVER', 'IT창업'], 95, true),

-- 카카오
('business_kim_beomsu', '김범수', 'Kim Bum-soo', '김범수', 'business_leader', 'male',
 '1966-03-08', NULL, NULL, true, '카카오',
 '카카오 창업자', ARRAY['김범수', 'Kim Bum-soo', '카카오', '카카오톡', 'IT창업'], 94, true),

-- 쿠팡
('business_kim_beomseok', '김범석', 'Kim Bom-seok', '김범석', 'business_leader', 'male',
 '1978-10-07', NULL, NULL, true, '쿠팡',
 '쿠팡 창업자, 의장', ARRAY['김범석', 'Kim Bom-seok', '쿠팡', 'Coupang', 'e커머스'], 92, true),

-- NHN
('business_lee_junho_nhn', '이준호', 'Lee Jun-ho', '이준호', 'business_leader', 'male',
 '1964-01-01', NULL, NULL, true, 'NHN',
 'NHN 회장', ARRAY['이준호', 'Lee Jun-ho', 'NHN', '페이코'], 78, true),

-- ============================================
-- 게임 기업 창업자
-- ============================================

-- 넥슨
('business_kim_jungju', '김정주', 'Kim Jung-ju', '김정주', 'business_leader', 'male',
 '1968-02-22', NULL, NULL, false, NULL,
 '넥슨 창업자 (故人)', ARRAY['김정주', 'Kim Jung-ju', '넥슨', 'Nexon', '게임'], 88, true),

-- 엔씨소프트
('business_kim_taekjin', '김택진', 'Kim Taek-jin', '김택진', 'business_leader', 'male',
 '1967-01-01', NULL, NULL, true, '엔씨소프트',
 '엔씨소프트 대표, 리니지', ARRAY['김택진', 'Kim Taek-jin', '엔씨소프트', 'NC소프트', '리니지'], 85, true),

-- 넷마블
('business_bang_junhyuk', '방준혁', 'Bang Jun-hyuk', '방준혁', 'business_leader', 'male',
 '1969-01-01', NULL, NULL, true, '넷마블',
 '넷마블 의장', ARRAY['방준혁', 'Bang Jun-hyuk', '넷마블', 'Netmarble', '게임'], 80, true),

-- 크래프톤
('business_jang_byungkyu', '장병규', 'Jang Byung-gyu', '장병규', 'business_leader', 'male',
 '1975-01-01', NULL, NULL, true, '크래프톤',
 '크래프톤 이사회 의장, 배틀그라운드', ARRAY['장병규', 'Jang Byung-gyu', '크래프톤', '배틀그라운드', 'PUBG'], 82, true),

-- 스마일게이트
('business_kwon_hyukbin', '권혁빈', 'Kwon Hyuk-bin', '권혁빈', 'business_leader', 'male',
 '1973-01-01', NULL, NULL, true, '스마일게이트',
 '스마일게이트 창업자, 크로스파이어', ARRAY['권혁빈', 'Kwon Hyuk-bin', '스마일게이트', '크로스파이어'], 78, true),

-- ============================================
-- 스타트업 창업자
-- ============================================

-- 토스
('business_lee_seunggun', '이승건', 'Lee Seung-gun', '이승건', 'business_leader', 'male',
 '1983-01-01', NULL, NULL, true, '토스',
 '토스 창업자, 비바리퍼블리카 대표', ARRAY['이승건', 'Lee Seung-gun', '토스', 'Toss', '핀테크'], 88, true),

-- 배달의민족
('business_kim_bongjin', '김봉진', 'Kim Bong-jin', '김봉진', 'business_leader', 'male',
 '1976-10-10', NULL, NULL, true, '우아한형제들',
 '배달의민족 창업자', ARRAY['김봉진', 'Kim Bong-jin', '배달의민족', '배민', '우아한형제들'], 90, true),

-- 야놀자
('business_lee_sujin', '이수진', 'Lee Su-jin', '이수진', 'business_leader', 'male',
 '1978-01-01', NULL, NULL, true, '야놀자',
 '야놀자 창업자', ARRAY['이수진', 'Lee Su-jin', '야놀자', '숙박', '스타트업'], 82, true),

-- 마켓컬리
('business_kim_sora', '김슬아', 'Kim Sla', '김슬아', 'business_leader', 'female',
 '1983-01-01', NULL, NULL, true, '컬리',
 '마켓컬리 창업자, 컬리 대표', ARRAY['김슬아', 'Kim Sla', '마켓컬리', '컬리', '새벽배송'], 78, true),

-- 당근마켓
('business_kim_jaehyun_daangn', '김재현', 'Kim Jae-hyun', '김재현', 'business_leader', 'male',
 '1984-01-01', NULL, NULL, true, '당근마켓',
 '당근마켓 창업자', ARRAY['김재현', '당근마켓', '당근', '중고거래'], 80, true),

-- 직방
('business_ahn_sungwoo', '안성우', 'Ahn Sung-woo', '안성우', 'business_leader', 'male',
 '1981-01-01', NULL, NULL, true, '직방',
 '직방 창업자', ARRAY['안성우', '직방', '부동산', '프롭테크'], 72, true),

-- ============================================
-- 엔터테인먼트 기업인
-- ============================================

-- SM엔터테인먼트
('business_lee_sooman', '이수만', 'Lee Soo-man', '이수만', 'business_leader', 'male',
 '1952-06-18', NULL, NULL, false, NULL,
 'SM엔터테인먼트 창립자, K-POP 선구자', ARRAY['이수만', 'Lee Soo-man', 'SM', 'SM엔터', 'K-POP'], 92, true),

-- YG엔터테인먼트
('business_yang_hyunsuk', '양현석', 'Yang Hyun-suk', '양현석', 'business_leader', 'male',
 '1970-01-09', NULL, NULL, false, NULL,
 'YG엔터테인먼트 창립자', ARRAY['양현석', 'Yang Hyun-suk', 'YG', 'YG엔터', '빅뱅'], 85, true),

-- JYP엔터테인먼트
('business_park_jinyoung', '박진영', 'Park Jin-young', '박진영', 'business_leader', 'male',
 '1971-12-13', NULL, NULL, false, NULL,
 'JYP엔터테인먼트 창립자, 가수', ARRAY['박진영', 'Park Jin-young', 'JYP', 'JYP엔터', 'K-POP'], 92, true),

-- HYBE
('business_bang_sihyuk', '방시혁', 'Bang Si-hyuk', '방시혁', 'business_leader', 'male',
 '1972-08-09', NULL, NULL, true, 'HYBE',
 'HYBE 창립자, 방탄소년단 프로듀서', ARRAY['방시혁', 'Bang Si-hyuk', 'HYBE', '하이브', 'BTS'], 95, true),

-- ============================================
-- 식품/유통 기업인
-- ============================================

-- 오뚜기
('business_ham_youngjun', '함영준', 'Ham Young-jun', '함영준', 'business_leader', 'male',
 '1959-03-02', 'INTJ', NULL, true, '오뚜기',
 '오뚜기 회장, 갓뚜기', ARRAY['함영준', 'Ham Young-jun', '오뚜기', '갓뚜기', '식품'], 88, true),

-- 농심
('business_shin_dongwon', '신동원', 'Shin Dong-won', '신동원', 'business_leader', 'male',
 '1954-01-01', NULL, NULL, true, '농심',
 '농심 회장', ARRAY['신동원', 'Shin Dong-won', '농심', '라면', '신라면'], 78, true),

-- 교촌치킨
('business_kwon_wonkang', '권원강', 'Kwon Won-kang', '권원강', 'business_leader', 'male',
 '1951-08-15', NULL, NULL, true, '교촌에프앤비',
 '교촌치킨 창업자', ARRAY['권원강', 'Kwon Won-kang', '교촌치킨', '교촌', '치킨'], 75, true),

-- 이디야
('business_mun_changgi', '문창기', 'Moon Chang-gi', '문창기', 'business_leader', 'male',
 '1962-01-01', NULL, NULL, true, '이디야',
 '이디야커피 대표', ARRAY['문창기', 'Moon Chang-gi', '이디야', '커피', '프랜차이즈'], 72, true),

-- 아모레퍼시픽
('business_suh_kyungbae', '서경배', 'Suh Kyung-bae', '서경배', 'business_leader', 'male',
 '1963-01-14', NULL, NULL, true, '아모레퍼시픽',
 '아모레퍼시픽 회장', ARRAY['서경배', 'Suh Kyung-bae', '아모레퍼시픽', '화장품', '설화수'], 82, true),

-- 빙그레
('business_jeon_chulsoo', '전철수', 'Jeon Chul-soo', '전철수', 'business_leader', 'male',
 '1965-01-01', NULL, NULL, true, '빙그레',
 '빙그레 회장', ARRAY['전철수', '빙그레', '바나나맛우유', '식품'], 68, true),

-- ============================================
-- 역대 유명 창업가 (레전드)
-- ============================================

-- 삼성 창업주
('business_lee_byungchul', '이병철', 'Lee Byung-chull', '이병철', 'business_leader', 'male',
 '1910-02-12', NULL, NULL, false, NULL,
 '삼성그룹 창업자 (故人)', ARRAY['이병철', 'Lee Byung-chull', '삼성', '삼성창업', '호암'], 90, true),

-- 삼성 2대
('business_lee_kunhee', '이건희', 'Lee Kun-hee', '이건희', 'business_leader', 'male',
 '1942-01-09', NULL, NULL, true, '삼성그룹',
 '삼성그룹 전 회장 (故人)', ARRAY['이건희', 'Lee Kun-hee', '삼성', '삼성전자'], 92, true),

-- 현대 창업주
('business_chung_juyoung', '정주영', 'Chung Ju-yung', '정주영', 'business_leader', 'male',
 '1915-11-25', NULL, NULL, false, NULL,
 '현대그룹 창업자 (故人)', ARRAY['정주영', 'Chung Ju-yung', '현대', '현대그룹', '아산'], 92, true),

-- 현대 2대
('business_chung_mongkoo', '정몽구', 'Chung Mong-koo', '정몽구', 'business_leader', 'male',
 '1938-03-19', NULL, NULL, true, '현대자동차그룹',
 '현대자동차그룹 명예회장', ARRAY['정몽구', 'Chung Mong-koo', '현대차', '현대자동차'], 85, true),

-- SK 창업주
('business_choi_jonggun', '최종건', 'Choi Jong-gun', '최종건', 'business_leader', 'male',
 '1929-08-10', NULL, NULL, false, NULL,
 'SK그룹 창업자 (故人)', ARRAY['최종건', 'Choi Jong-gun', 'SK', '선경'], 75, true),

-- SK 2대
('business_choi_jonghyun', '최종현', 'Choi Jong-hyun', '최종현', 'business_leader', 'male',
 '1936-11-19', NULL, NULL, true, 'SK그룹',
 'SK그룹 전 회장 (故人)', ARRAY['최종현', 'Choi Jong-hyun', 'SK', '선경'], 78, true),

-- LG 창업주
('business_koo_inhoe', '구인회', 'Koo In-hwoi', '구인회', 'business_leader', 'male',
 '1907-08-27', NULL, NULL, false, NULL,
 'LG그룹 창업자 (故人)', ARRAY['구인회', 'Koo In-hwoi', 'LG', '럭키금성'], 80, true),

-- 롯데 창업주
('business_shin_kyukho', '신격호', 'Shin Kyuk-ho', '신격호', 'business_leader', 'male',
 '1921-11-03', NULL, NULL, false, NULL,
 '롯데그룹 창업자 (故人)', ARRAY['신격호', 'Shin Kyuk-ho', '롯데', '롯데그룹'], 82, true),

-- 오뚜기 창업주
('business_ham_taeho', '함태호', 'Ham Tae-ho', '함태호', 'business_leader', 'male',
 '1930-06-15', NULL, NULL, false, NULL,
 '오뚜기 창업자 (故人)', ARRAY['함태호', 'Ham Tae-ho', '오뚜기', '식품'], 70, true),

-- 한글과컴퓨터 창업주
('business_lee_chanhee', '이찬희', 'Lee Chan-hee', '이찬희', 'business_leader', 'male',
 '1963-01-01', NULL, NULL, false, NULL,
 '한글과컴퓨터 공동창업자', ARRAY['이찬희', '한글과컴퓨터', '한컴', 'IT'], 65, true),

-- ============================================
-- 금융 기업인
-- ============================================

('business_yoon_jonggyu', '윤종규', 'Yoon Jong-kyu', '윤종규', 'business_leader', 'male',
 '1957-01-01', NULL, NULL, true, 'KB금융',
 'KB금융그룹 회장', ARRAY['윤종규', 'KB금융', 'KB국민은행', '금융'], 72, true),

('business_cho_yongbyoung', '조용병', 'Cho Yong-byoung', '조용병', 'business_leader', 'male',
 '1959-01-01', NULL, NULL, true, '신한금융',
 '신한금융그룹 회장', ARRAY['조용병', '신한금융', '신한은행', '금융'], 70, true),

('business_kim_junghyo', '김정태', 'Kim Jung-tae', '김정태', 'business_leader', 'male',
 '1956-01-01', NULL, NULL, true, '하나금융',
 '하나금융그룹 회장', ARRAY['김정태', '하나금융', '하나은행', '금융'], 68, true),

-- ============================================
-- 기타 유명 기업인
-- ============================================

-- 교보생명
('business_shin_changje', '신창재', 'Shin Chang-jae', '신창재', 'business_leader', 'male',
 '1952-12-15', NULL, NULL, true, '교보생명',
 '교보생명 회장', ARRAY['신창재', 'Shin Chang-jae', '교보생명', '교보문고'], 72, true),

-- 미래에셋
('business_park_hyunjoo', '박현주', 'Park Hyun-joo', '박현주', 'business_leader', 'male',
 '1958-08-05', NULL, NULL, true, '미래에셋',
 '미래에셋 회장', ARRAY['박현주', 'Park Hyun-joo', '미래에셋', '자산운용'], 78, true),

-- 셀트리온
('business_seo_jungjin', '서정진', 'Seo Jung-jin', '서정진', 'business_leader', 'male',
 '1957-04-13', NULL, NULL, true, '셀트리온',
 '셀트리온 회장, 바이오', ARRAY['서정진', 'Seo Jung-jin', '셀트리온', '바이오', '제약'], 85, true),

-- 현대중공업
('business_chung_kisun', '정기선', 'Chung Ki-sun', '정기선', 'business_leader', 'male',
 '1979-07-06', 'INTJ', NULL, true, 'HD현대',
 'HD현대 사장', ARRAY['정기선', 'Chung Ki-sun', 'HD현대', '현대중공업', '조선'], 75, true),

-- 카카오뱅크
('business_yoon_hosang', '윤호영', 'Yoon Ho-young', '윤호영', 'business_leader', 'male',
 '1969-01-01', NULL, NULL, true, '카카오뱅크',
 '카카오뱅크 대표', ARRAY['윤호영', '카카오뱅크', '인터넷은행', '핀테크'], 72, true),

-- 무신사
('business_jo_manho', '조만호', 'Cho Man-ho', '조만호', 'business_leader', 'male',
 '1983-01-01', NULL, NULL, true, '무신사',
 '무신사 창업자', ARRAY['조만호', '무신사', '패션', 'e커머스', '스트릿패션'], 78, true),

-- 리디
('business_bae_kishik', '배기식', 'Bae Ki-sik', '배기식', 'business_leader', 'male',
 '1980-01-01', NULL, NULL, true, '리디',
 '리디 창업자, 전자책', ARRAY['배기식', '리디', '리디북스', '전자책', '웹툰'], 68, true),

-- 왓챠
('business_park_taehoon', '박태훈', 'Park Tae-hoon', '박태훈', 'business_leader', 'male',
 '1985-01-01', NULL, NULL, true, '왓챠',
 '왓챠 창업자', ARRAY['박태훈', '왓챠', 'OTT', '스트리밍'], 65, true),

-- 지그재그 (카카오스타일)
('business_seo_junghoon', '서정훈', 'Seo Jung-hoon', '서정훈', 'business_leader', 'male',
 '1986-01-01', NULL, NULL, true, '카카오스타일',
 '지그재그 창업자', ARRAY['서정훈', '지그재그', '카카오스타일', '패션'], 68, true),

-- 야나두
('business_kim_minchul', '김민철', 'Kim Min-chul', '김민철', 'business_leader', 'male',
 '1982-01-01', NULL, NULL, true, '야나두',
 '야나두 창업자', ARRAY['김민철', '야나두', '영어교육', '에듀테크'], 62, true),

-- 센드버드
('business_kim_dongshin', '김동신', 'Kim Dong-shin', '김동신', 'business_leader', 'male',
 '1985-01-01', NULL, NULL, true, '센드버드',
 '센드버드 창업자, Y컴비네이터', ARRAY['김동신', '센드버드', '스타트업', 'Y컴비네이터'], 70, true),

-- 두나무
('business_song_chiheung', '송치형', 'Song Chi-hyung', '송치형', 'business_leader', 'male',
 '1979-01-01', NULL, NULL, true, '두나무',
 '두나무 회장, 업비트', ARRAY['송치형', '두나무', '업비트', '가상화폐', '블록체인'], 78, true),

-- 빗썸
('business_lee_sangjun', '이상준', 'Lee Sang-jun', '이상준', 'business_leader', 'male',
 '1980-01-01', NULL, NULL, true, '빗썸',
 '빗썸 전 대표', ARRAY['이상준', '빗썸', '가상화폐', '거래소'], 65, true),

-- 업비트
('business_lee_sikhwan', '이석환', 'Lee Sik-hwan', '이석환', 'business_leader', 'male',
 '1977-01-01', NULL, NULL, true, '두나무',
 '두나무 공동 창업자', ARRAY['이석환', '두나무', '업비트'], 68, true),

-- 뱅크샐러드
('business_yoon_joon', '윤준', 'Yoon Joon', '윤준', 'business_leader', 'male',
 '1985-01-01', NULL, NULL, true, '뱅크샐러드',
 '뱅크샐러드 창업자', ARRAY['윤준', '뱅크샐러드', '핀테크', '자산관리'], 65, true),

-- 화해
('business_lee_woong', '이웅', 'Lee Woong', '이웅', 'business_leader', 'male',
 '1983-01-01', NULL, NULL, true, '버드뷰',
 '화해 창업자', ARRAY['이웅', '화해', '뷰티', '화장품리뷰'], 62, true),

-- 하이브리더스
('business_kwon_doyoon', '권도균', 'Kwon Do-kyun', '권도균', 'business_leader', 'male',
 '1971-01-01', NULL, NULL, false, NULL,
 '이노비즈 창업자, 스타트업 멘토', ARRAY['권도균', '이노비즈', '스타트업', '엔젤투자'], 68, true),

-- 본엔젤스
('business_jang_byungtak', '장병탁', 'Jang Byung-tak', '장병탁', 'business_leader', 'male',
 '1963-01-01', NULL, NULL, false, NULL,
 '서울대 교수, AI 연구', ARRAY['장병탁', 'AI', '인공지능', '서울대'], 65, true),

-- 우아한형제들 (딜리버리 히어로 아시아)
('business_ryu_youngjun', '류영준', 'Ryu Young-jun', '류영준', 'business_leader', 'male',
 '1975-01-01', NULL, NULL, true, '우아한형제들',
 '전 우아한형제들 대표', ARRAY['류영준', '배달의민족', '우아한형제들'], 72, true),

-- 넷플릭스코리아
('business_kang_donghwan', '강동한', 'Kang Dong-han', '강동한', 'business_leader', 'male',
 '1972-01-01', NULL, NULL, true, '넷플릭스코리아',
 '넷플릭스코리아 전 대표', ARRAY['강동한', '넷플릭스코리아', 'OTT'], 68, true),

-- 쏘카
('business_lee_jaewung', '이재웅', 'Lee Jae-woong', '이재웅', 'business_leader', 'male',
 '1968-01-01', NULL, NULL, true, '쏘카',
 '쏘카 창업자', ARRAY['이재웅', '쏘카', '카셰어링', '모빌리티'], 72, true),

-- 타다
('business_park_jaeuk', '박재욱', 'Park Jae-uk', '박재욱', 'business_leader', 'male',
 '1983-01-01', NULL, NULL, true, 'VCNC',
 '타다 창업자', ARRAY['박재욱', '타다', 'VCNC', '모빌리티'], 68, true),

-- 패스트파이브
('business_kim_daeil', '김대일', 'Kim Dae-il', '김대일', 'business_leader', 'male',
 '1984-01-01', NULL, NULL, true, '패스트파이브',
 '패스트파이브 창업자', ARRAY['김대일', '패스트파이브', '공유오피스'], 65, true),

-- 마이리얼트립
('business_lee_donggun', '이동건', 'Lee Dong-gun', '이동건', 'business_leader', 'male',
 '1984-01-01', NULL, NULL, true, '마이리얼트립',
 '마이리얼트립 창업자', ARRAY['이동건', '마이리얼트립', '여행', '플랫폼'], 68, true),

-- 클래스101
('business_ko_youngho', '고영호', 'Ko Young-ho', '고영호', 'business_leader', 'male',
 '1988-01-01', NULL, NULL, true, '클래스101',
 '클래스101 창업자', ARRAY['고영호', '클래스101', '에듀테크', '온라인강의'], 65, true)

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
    WHERE category = 'business_leader' AND is_active = true;

    RAISE NOTICE 'Total active business leaders: %', inserted_count;
END $$;
