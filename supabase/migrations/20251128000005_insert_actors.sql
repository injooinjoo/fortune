-- 배우 데이터 삽입 (100명)
-- 생성일: 2025-11-28
-- 한국 인기 배우 (남/여) 데이터

INSERT INTO public.celebrities (
    id, name, name_en, legal_name, category, gender,
    birth_date, mbti, blood_type, is_group_member, group_name,
    description, keywords, popularity_score, is_active
) VALUES

-- ===== 남자 배우 (50명) =====

-- 대표 남자배우 (베테랑)
('actor_lee_byunghun', '이병헌', 'Lee Byung-hun', '이병헌', 'actor', 'male',
 '1970-07-12', NULL, 'O', false, NULL,
 '한국 대표 배우, 할리우드 진출', ARRAY['이병헌', 'Lee Byung-hun', '할리우드'], 98, true),

('actor_song_kangho', '송강호', 'Song Kang-ho', '송강호', 'actor', 'male',
 '1967-01-17', NULL, 'A', false, NULL,
 '칸 영화제 남우주연상 수상, 기생충', ARRAY['송강호', 'Song Kang-ho', '기생충'], 98, true),

('actor_jung_woosung', '정우성', 'Jung Woo-sung', '정우성', 'actor', 'male',
 '1973-04-22', 'ENFJ', NULL, false, NULL,
 '청담부부, 유엔난민기구 친선대사', ARRAY['정우성', 'Jung Woo-sung', '아수라'], 95, true),

('actor_ha_jungwoo', '하정우', 'Ha Jung-woo', '김성훈', 'actor', 'male',
 '1978-03-11', 'ENTP', 'A', false, NULL,
 '천만 배우, 감독 겸업', ARRAY['하정우', 'Ha Jung-woo', '김성훈', '암살'], 95, true),

('actor_hwang_jungmin', '황정민', 'Hwang Jung-min', '황정민', 'actor', 'male',
 '1970-09-01', 'ISFJ', 'O', false, NULL,
 '카멜레온 배우, 연기파', ARRAY['황정민', 'Hwang Jung-min', '베테랑'], 95, true),

('actor_lee_jungjae', '이정재', 'Lee Jung-jae', '이정재', 'actor', 'male',
 '1972-12-15', 'ENFJ', 'B', false, NULL,
 '오징어 게임, 에미상 수상', ARRAY['이정재', 'Lee Jung-jae', '오징어 게임'], 97, true),

('actor_gong_yoo', '공유', 'Gong Yoo', '공지철', 'actor', 'male',
 '1979-07-10', 'INFJ', 'A', false, NULL,
 '도깨비, 부산행', ARRAY['공유', 'Gong Yoo', '공지철', '도깨비'], 96, true),

('actor_hyun_bin', '현빈', 'Hyun Bin', '김태평', 'actor', 'male',
 '1982-09-25', NULL, 'B', false, NULL,
 '사랑의 불시착, 손예진과 결혼', ARRAY['현빈', 'Hyun Bin', '김태평', '사랑의 불시착'], 96, true),

('actor_ma_dongseok', '마동석', 'Ma Dong-seok', '이동석', 'actor', 'male',
 '1972-03-01', NULL, 'O', false, NULL,
 '범죄도시, 할리우드 진출', ARRAY['마동석', 'Ma Dong-seok', '이동석', '범죄도시'], 95, true),

('actor_yoo_ahyin', '유아인', 'Yoo Ah-in', '엄홍식', 'actor', 'male',
 '1986-10-06', NULL, NULL, false, NULL,
 '사도, 베테랑', ARRAY['유아인', 'Yoo Ah-in', '엄홍식'], 80, true),

('actor_jo_seungwoo', '조승우', 'Cho Seung-woo', '조승우', 'actor', 'male',
 '1980-03-28', NULL, 'O', false, NULL,
 '뮤지컬 황제, 비밀의 숲', ARRAY['조승우', 'Cho Seung-woo', '비밀의 숲'], 92, true),

('actor_jo_insung', '조인성', 'Jo In-sung', '조인성', 'actor', 'male',
 '1981-07-28', NULL, 'O', false, NULL,
 '그 겨울 바람이 분다, 안녕 내 사랑', ARRAY['조인성', 'Jo In-sung'], 93, true),

('actor_yoo_haejin', '유해진', 'Yoo Hae-jin', '유해진', 'actor', 'male',
 '1970-01-04', NULL, NULL, false, NULL,
 '천만 배우, 택시운전사', ARRAY['유해진', 'Yoo Hae-jin', '택시운전사'], 92, true),

-- 젊은/중견 남자배우
('actor_park_seojoon', '박서준', 'Park Seo-joon', '박용규', 'actor', 'male',
 '1988-12-16', 'INFP', 'AB', false, NULL,
 '이태원 클라쓰, 마블 출연', ARRAY['박서준', 'Park Seo-joon', '박용규', '이태원 클라쓰'], 94, true),

('actor_lee_dohyun', '이도현', 'Lee Do-hyun', '임동현', 'actor', 'male',
 '1995-04-11', NULL, 'A', false, NULL,
 '오월의 청춘, 더 글로리', ARRAY['이도현', 'Lee Do-hyun', '임동현', '더 글로리'], 93, true),

('actor_cha_eunwoo', '차은우', 'Cha Eun-woo', '이동민', 'actor', 'male',
 '1997-03-30', 'INTJ', 'B', true, 'ASTRO',
 '아스트로 멤버, 내 아이디는 강남미인', ARRAY['차은우', 'Cha Eun-woo', '이동민', '아스트로'], 95, true),

('actor_ahn_hyoseop', '안효섭', 'Ahn Hyo-seop', '안효섭', 'actor', 'male',
 '1995-04-17', NULL, 'B', false, NULL,
 '낭만닥터 김사부, 사내맞선', ARRAY['안효섭', 'Ahn Hyo-seop', '사내맞선'], 92, true),

('actor_byun_wooseok', '변우석', 'Byun Woo-seok', '변우석', 'actor', 'male',
 '1991-10-31', NULL, NULL, false, NULL,
 '선재 업고 튀어, 청춘기록', ARRAY['변우석', 'Byun Woo-seok', '선재 업고 튀어'], 94, true),

('actor_kim_soohyun', '김수현', 'Kim Soo-hyun', '김수현', 'actor', 'male',
 '1988-02-16', 'ISFJ', NULL, false, NULL,
 '별에서 온 그대, 눈물의 여왕', ARRAY['김수현', 'Kim Soo-hyun', '눈물의 여왕'], 97, true),

('actor_song_joongki', '송중기', 'Song Joong-ki', '송중기', 'actor', 'male',
 '1985-09-19', NULL, NULL, false, NULL,
 '태양의 후예, 빈센조', ARRAY['송중기', 'Song Joong-ki', '태양의 후예'], 95, true),

('actor_lee_minho', '이민호', 'Lee Min-ho', '이민호', 'actor', 'male',
 '1987-06-22', NULL, 'A', false, NULL,
 '꽃보다 남자, 더 킹', ARRAY['이민호', 'Lee Min-ho', '꽃보다 남자'], 95, true),

('actor_nam_joohyuk', '남주혁', 'Nam Joo-hyuk', '남주혁', 'actor', 'male',
 '1994-02-22', 'INFJ', 'A', false, NULL,
 '스물다섯 스물하나, 스타트업', ARRAY['남주혁', 'Nam Joo-hyuk', '스물다섯 스물하나'], 92, true),

('actor_song_kang', '송강', 'Song Kang', '송강', 'actor', 'male',
 '1994-04-23', 'INTP', 'B', false, NULL,
 '스위트홈, 나의 아저씨', ARRAY['송강', 'Song Kang', '스위트홈'], 92, true),

('actor_kim_sunho', '김선호', 'Kim Seon-ho', '김선호', 'actor', 'male',
 '1986-05-08', 'ISFP', 'A', false, NULL,
 '스타트업, 갯마을 차차차', ARRAY['김선호', 'Kim Seon-ho', '갯마을 차차차'], 90, true),

('actor_wi_hajun', '위하준', 'Wi Ha-jun', '위하준', 'actor', 'male',
 '1991-08-05', 'ISFJ', 'B', false, NULL,
 '오징어 게임, 경이로운 소문', ARRAY['위하준', 'Wi Ha-jun', '오징어 게임'], 92, true),

('actor_jung_haein', '정해인', 'Jung Hae-in', '정해인', 'actor', 'male',
 '1988-04-01', 'INFP', 'A', false, NULL,
 '밥 잘 사주는 예쁜 누나, D.P.', ARRAY['정해인', 'Jung Hae-in', 'D.P.'], 93, true),

('actor_lee_jongseok', '이종석', 'Lee Jong-suk', '이종석', 'actor', 'male',
 '1989-09-14', 'INFP', 'A', false, NULL,
 'W, 빅마우스', ARRAY['이종석', 'Lee Jong-suk', '빅마우스'], 93, true),

('actor_park_bogum', '박보검', 'Park Bo-gum', '박보검', 'actor', 'male',
 '1993-06-16', 'INFP', 'B', false, NULL,
 '응답하라 1988, 청춘기록', ARRAY['박보검', 'Park Bo-gum', '응답하라 1988'], 94, true),

('actor_ryu_junyeol', '류준열', 'Ryu Jun-yeol', '류준열', 'actor', 'male',
 '1986-09-25', 'INFP', 'B', false, NULL,
 '응답하라 1988, 택시운전사', ARRAY['류준열', 'Ryu Jun-yeol', '응답하라 1988'], 90, true),

('actor_kim_woobin', '김우빈', 'Kim Woo-bin', '김현중', 'actor', 'male',
 '1989-07-16', 'ISFP', 'B', false, NULL,
 '상속자들, 우리들의 블루스', ARRAY['김우빈', 'Kim Woo-bin', '김현중', '상속자들'], 92, true),

('actor_lee_seunggi', '이승기', 'Lee Seung-gi', '이승기', 'actor', 'male',
 '1987-01-13', 'ESFJ', 'B', false, NULL,
 '화유기, 마우스', ARRAY['이승기', 'Lee Seung-gi', '화유기'], 88, true),

('actor_seo_kangjoon', '서강준', 'Seo Kang-joon', '이승환', 'actor', 'male',
 '1993-10-12', 'ESFJ', 'A', false, NULL,
 '치즈 인 더 트랩, 그해 우리는', ARRAY['서강준', 'Seo Kang-joon', '이승환'], 88, true),

('actor_lee_dongwook', '이동욱', 'Lee Dong-wook', '이동욱', 'actor', 'male',
 '1981-11-06', NULL, 'AB', false, NULL,
 '도깨비, 나쁜 형사', ARRAY['이동욱', 'Lee Dong-wook', '도깨비'], 92, true),

('actor_kim_jaewook', '김재욱', 'Kim Jae-wook', '김재욱', 'actor', 'male',
 '1983-04-02', 'INFP', 'B', false, NULL,
 '커피프린스 1호점, 그녀의 사생활', ARRAY['김재욱', 'Kim Jae-wook'], 88, true),

('actor_yoo_yeonseok', '유연석', 'Yoo Yeon-seok', '안연석', 'actor', 'male',
 '1984-04-11', 'ENFP', 'A', false, NULL,
 '슬기로운 의사생활, 미스터 선샤인', ARRAY['유연석', 'Yoo Yeon-seok', '안연석'], 91, true),

('actor_jang_dongyun', '장동윤', 'Jang Dong-yoon', '장동윤', 'actor', 'male',
 '1992-06-12', 'INTP', 'AB', false, NULL,
 '조선로코 녹두전, 오월의 청춘', ARRAY['장동윤', 'Jang Dong-yoon'], 85, true),

('actor_yeo_jingoo', '여진구', 'Yeo Jin-goo', '여진구', 'actor', 'male',
 '1997-08-13', 'INFP', 'O', false, NULL,
 '호텔 델루나, 괴물', ARRAY['여진구', 'Yeo Jin-goo', '호텔 델루나'], 90, true),

('actor_hwang_inhyuk', '황인엽', 'Hwang In-yeop', '황인엽', 'actor', 'male',
 '1991-01-19', 'ISFP', 'B', false, NULL,
 '여신강림, 사운드 오브 매직', ARRAY['황인엽', 'Hwang In-yeop', '여신강림'], 89, true),

('actor_kim_youngdae', '김영대', 'Kim Young-dae', '김영대', 'actor', 'male',
 '1996-03-19', NULL, 'A', false, NULL,
 '펜트하우스, 슈팅스타', ARRAY['김영대', 'Kim Young-dae', '펜트하우스'], 87, true),

('actor_lee_jaewook', '이재욱', 'Lee Jae-wook', '이재욱', 'actor', 'male',
 '1998-05-10', 'INFJ', 'B', false, NULL,
 '환혼, 이상한 변호사 우영우', ARRAY['이재욱', 'Lee Jae-wook', '환혼'], 90, true),

-- 베테랑/중견 남자배우 추가
('actor_sol_kyunggu', '설경구', 'Sol Kyung-gu', '설경구', 'actor', 'male',
 '1968-05-14', NULL, 'A', false, NULL,
 '박하사탕, 실미도', ARRAY['설경구', 'Sol Kyung-gu', '박하사탕'], 90, true),

('actor_choi_minsik', '최민식', 'Choi Min-sik', '최민식', 'actor', 'male',
 '1962-04-27', NULL, 'A', false, NULL,
 '올드보이, 명량', ARRAY['최민식', 'Choi Min-sik', '올드보이'], 95, true),

('actor_jung_woo', '정우', 'Jung Woo', '정상우', 'actor', 'male',
 '1976-02-05', 'INFP', 'B', false, NULL,
 '응답하라 1994, 최악의 악', ARRAY['정우', 'Jung Woo', '정상우'], 88, true),

('actor_go_kyungpyo', '고경표', 'Go Kyung-pyo', '고경표', 'actor', 'male',
 '1990-06-11', 'ESFP', 'A', false, NULL,
 '응답하라 1988, 사랑의 이해', ARRAY['고경표', 'Go Kyung-pyo'], 88, true),

('actor_lee_kwangsoo', '이광수', 'Lee Kwang-soo', '이광수', 'actor', 'male',
 '1985-07-14', 'INFP', 'A', false, NULL,
 '런닝맨, 굿 캐스팅', ARRAY['이광수', 'Lee Kwang-soo', '런닝맨'], 88, true),

('actor_ji_changwook', '지창욱', 'Ji Chang-wook', '지창욱', 'actor', 'male',
 '1987-07-05', NULL, 'AB', false, NULL,
 '힐러, 도시의 남자', ARRAY['지창욱', 'Ji Chang-wook', '힐러'], 93, true),

('actor_kang_haneul', '강하늘', 'Kang Ha-neul', '김하늘', 'actor', 'male',
 '1990-02-21', 'ENFJ', 'O', false, NULL,
 '미녀공심이, 갬블러', ARRAY['강하늘', 'Kang Ha-neul', '김하늘'], 91, true),

('actor_joo_jongghyuk', '주종혁', 'Joo Jong-hyuk', '주종혁', 'actor', 'male',
 '1991-10-30', 'ESTJ', 'B', false, NULL,
 '이상한 변호사 우영우, 빅마우스', ARRAY['주종혁', 'Joo Jong-hyuk', '우영우'], 85, true),

('actor_oh_jungse', '오정세', 'Oh Jung-se', '오정세', 'actor', 'male',
 '1977-02-16', 'ENFP', 'A', false, NULL,
 '사이코지만 괜찮아, 슬기로운 감빵생활', ARRAY['오정세', 'Oh Jung-se'], 87, true),

('actor_kim_namgil', '김남길', 'Kim Nam-gil', '김남길', 'actor', 'male',
 '1981-03-13', NULL, 'O', false, NULL,
 '빛나는 것은', ARRAY['김남길', 'Kim Nam-gil'], 90, true),

-- ===== 여자 배우 (50명) =====

-- 대표 여자배우 (베테랑)
('actor_jeon_jihyun', '전지현', 'Jun Ji-hyun', '왕지현', 'actor', 'female',
 '1981-10-30', NULL, 'A', false, NULL,
 '엽기적인 그녀, 별에서 온 그대', ARRAY['전지현', 'Jun Ji-hyun', '왕지현', '별에서 온 그대'], 97, true),

('actor_son_yejin', '손예진', 'Son Ye-jin', '손예진', 'actor', 'female',
 '1982-01-11', NULL, 'A', false, NULL,
 '클래식, 사랑의 불시착', ARRAY['손예진', 'Son Ye-jin', '사랑의 불시착'], 96, true),

('actor_kim_hyesu', '김혜수', 'Kim Hye-soo', '김혜수', 'actor', 'female',
 '1970-09-05', NULL, 'A', false, NULL,
 '타짜, 시그널', ARRAY['김혜수', 'Kim Hye-soo', '시그널'], 95, true),

('actor_jeon_doyeon', '전도연', 'Jeon Do-yeon', '전도연', 'actor', 'female',
 '1973-02-11', NULL, 'O', false, NULL,
 '밀양, 칸 영화제 여우주연상', ARRAY['전도연', 'Jeon Do-yeon', '밀양'], 95, true),

('actor_lee_youngae', '이영애', 'Lee Young-ae', '이영애', 'actor', 'female',
 '1971-01-31', 'ISFP', 'AB', false, NULL,
 '대장금, 친절한 금자씨', ARRAY['이영애', 'Lee Young-ae', '대장금'], 94, true),

('actor_song_hyekyo', '송혜교', 'Song Hye-kyo', '송혜교', 'actor', 'female',
 '1981-11-22', 'INFJ', NULL, false, NULL,
 '풀하우스, 더 글로리', ARRAY['송혜교', 'Song Hye-kyo', '더 글로리'], 95, true),

('actor_kim_taeri', '김태리', 'Kim Tae-ri', '김태리', 'actor', 'female',
 '1990-04-24', NULL, 'B', false, NULL,
 '아가씨, 스물다섯 스물하나', ARRAY['김태리', 'Kim Tae-ri', '스물다섯 스물하나'], 94, true),

('actor_han_jimin', '한지민', 'Han Ji-min', '한지민', 'actor', 'female',
 '1982-11-05', 'INFP', NULL, false, NULL,
 '이산, 밥 잘 사주는 예쁜 누나', ARRAY['한지민', 'Han Ji-min'], 93, true),

-- 젊은/중견 여자배우
('actor_kim_goeun', '김고은', 'Kim Go-eun', '김고은', 'actor', 'female',
 '1991-07-02', 'ENFP', 'B', false, NULL,
 '도깨비, 유미의 세포들', ARRAY['김고은', 'Kim Go-eun', '도깨비'], 94, true),

('actor_suzy', '수지', 'Suzy', '배수지', 'actor', 'female',
 '1994-10-10', 'INFJ', 'AB', false, NULL,
 '건축학개론, 배가본드', ARRAY['수지', 'Suzy', '배수지', '건축학개론'], 94, true),

('actor_han_sohee', '한소희', 'Han So-hee', '이소희', 'actor', 'female',
 '1994-11-18', 'INFP', NULL, false, NULL,
 '부부의 세계, 마이네임', ARRAY['한소희', 'Han So-hee', '이소희'], 93, true),

('actor_shin_mina', '신민아', 'Shin Min-a', '양민아', 'actor', 'female',
 '1984-04-05', 'INTP', 'O', false, NULL,
 '내 여자친구는 구미호, 갯마을 차차차', ARRAY['신민아', 'Shin Min-a', '양민아'], 92, true),

('actor_moon_geunyoung', '문근영', 'Moon Geun-young', '문근영', 'actor', 'female',
 '1987-05-06', NULL, 'B', false, NULL,
 '가을동화, 국민여동생', ARRAY['문근영', 'Moon Geun-young', '가을동화'], 88, true),

('actor_park_boyoung', '박보영', 'Park Bo-young', '박보영', 'actor', 'female',
 '1990-02-12', 'ISFP', NULL, false, NULL,
 '힘쎈여자 도봉순, 오 나의 귀신님', ARRAY['박보영', 'Park Bo-young', '힘쎈여자 도봉순'], 93, true),

('actor_park_shinhye', '박신혜', 'Park Shin-hye', '박신혜', 'actor', 'female',
 '1990-02-18', 'INFJ', NULL, false, NULL,
 '상속자들, 피노키오', ARRAY['박신혜', 'Park Shin-hye', '상속자들'], 93, true),

('actor_kim_jiwon', '김지원', 'Kim Ji-won', '김지원', 'actor', 'female',
 '1992-10-19', 'INFP', 'A', false, NULL,
 '태양의 후예, 눈물의 여왕', ARRAY['김지원', 'Kim Ji-won', '눈물의 여왕'], 94, true),

('actor_shin_sekyung', '신세경', 'Shin Se-kyung', '신세경', 'actor', 'female',
 '1990-07-29', 'ENFJ', 'B', false, NULL,
 '하백의 신부, 런 온', ARRAY['신세경', 'Shin Se-kyung'], 90, true),

('actor_im_yoona', '임윤아', 'Im Yoon-ah', '임윤아', 'actor', 'female',
 '1990-05-30', 'ISFP', 'B', true, '소녀시대',
 '소녀시대 멤버, 킹더랜드', ARRAY['임윤아', 'Im Yoon-ah', '윤아', '소녀시대'], 94, true),

('actor_han_hyojoo', '한효주', 'Han Hyo-joo', '한효주', 'actor', 'female',
 '1987-02-22', NULL, 'A', false, NULL,
 '해적, 화려한 휴가', ARRAY['한효주', 'Han Hyo-joo', '해적'], 92, true),

('actor_bae_doona', '배두나', 'Bae Doo-na', '배두나', 'actor', 'female',
 '1979-10-11', 'INFP', 'O', false, NULL,
 '센스8, 비밀의 숲', ARRAY['배두나', 'Bae Doo-na', '센스8'], 92, true),

('actor_gong_hyojin', '공효진', 'Gong Hyo-jin', '공효진', 'actor', 'female',
 '1980-04-04', 'ENFP', 'A', false, NULL,
 '파스타, 주군의 태양', ARRAY['공효진', 'Gong Hyo-jin', '파스타'], 93, true),

('actor_ra_miran', '라미란', 'Ra Mi-ran', '라미란', 'actor', 'female',
 '1975-03-06', 'ENTP', NULL, false, NULL,
 '응답하라 1988, 시민덕희', ARRAY['라미란', 'Ra Mi-ran', '응답하라 1988'], 90, true),

('actor_lee_jungeun', '이정은', 'Lee Jung-eun', '이정은', 'actor', 'female',
 '1970-01-23', NULL, NULL, false, NULL,
 '기생충, 동백꽃 필 무렵', ARRAY['이정은', 'Lee Jung-eun', '기생충'], 90, true),

('actor_lee_seyoung', '이세영', 'Lee Se-young', '이세영', 'actor', 'female',
 '1992-12-20', 'ISFP', 'A', false, NULL,
 '역적, 낭만닥터 김사부', ARRAY['이세영', 'Lee Se-young'], 87, true),

('actor_park_gyuyoung', '박규영', 'Park Gyu-young', '박규영', 'actor', 'female',
 '1993-05-27', 'ISTJ', 'O', false, NULL,
 '악의 꽃, 달리와 감자탕', ARRAY['박규영', 'Park Gyu-young'], 86, true),

('actor_moon_gayoung', '문가영', 'Moon Ga-young', '문가영', 'actor', 'female',
 '1996-07-10', 'ENFP', 'O', false, NULL,
 '여신강림, 어쩌다 발견한 하루', ARRAY['문가영', 'Moon Ga-young', '여신강림'], 89, true),

('actor_park_eunbin', '박은빈', 'Park Eun-bin', '박은빈', 'actor', 'female',
 '1992-09-04', 'ENFP', 'O', false, NULL,
 '이상한 변호사 우영우, 나빌레라', ARRAY['박은빈', 'Park Eun-bin', '우영우'], 94, true),

('actor_jang_nara', '장나라', 'Jang Na-ra', '장나라', 'actor', 'female',
 '1981-03-18', 'ENFP', 'A', false, NULL,
 '내 여자 꼬시지 마라, 대박부동산', ARRAY['장나라', 'Jang Na-ra'], 90, true),

('actor_jung_ryeowon', '정려원', 'Jung Ryeo-won', '정려원', 'actor', 'female',
 '1981-01-21', NULL, 'O', false, NULL,
 '궁합, 마녀의 법정', ARRAY['정려원', 'Jung Ryeo-won'], 88, true),

('actor_go_hyunjung', '고현정', 'Ko Hyun-jung', '고현정', 'actor', 'female',
 '1971-03-02', NULL, 'B', false, NULL,
 '모래시계, 퀸의 꽃', ARRAY['고현정', 'Ko Hyun-jung', '모래시계'], 90, true),

('actor_han_gain', '한가인', 'Han Ga-in', '김현주', 'actor', 'female',
 '1982-02-02', 'INFP', 'O', false, NULL,
 '해를 품은 달, 황진이', ARRAY['한가인', 'Han Ga-in', '김현주'], 90, true),

('actor_hwang_jungeum', '황정음', 'Hwang Jung-eum', '황정음', 'actor', 'female',
 '1985-01-25', 'ENFP', 'A', false, NULL,
 '킬미 힐미, 그녀는 예뻤다', ARRAY['황정음', 'Hwang Jung-eum'], 88, true),

('actor_nam_jihyun', '남지현', 'Nam Ji-hyun', '남지현', 'actor', 'female',
 '1995-09-17', 'ENFP', 'B', false, NULL,
 '수상한 파트너, 365', ARRAY['남지현', 'Nam Ji-hyun'], 86, true),

('actor_kim_dahmi', '김다미', 'Kim Da-mi', '김다미', 'actor', 'female',
 '1995-04-09', 'INTJ', 'A', false, NULL,
 '마녀, 이태원 클라쓰', ARRAY['김다미', 'Kim Da-mi', '이태원 클라쓰'], 91, true),

('actor_nana', '나나', 'Nana', '임진아', 'actor', 'female',
 '1991-09-14', 'ISFP', 'A', true, 'After School',
 '애프터스쿨 멤버, 출사표', ARRAY['나나', 'Nana', '임진아', '애프터스쿨'], 88, true),

('actor_kim_sejeong', '김세정', 'Kim Se-jeong', '김세정', 'actor', 'female',
 '1996-08-28', 'ENFP', 'O', true, '구구단',
 '경이로운 소문, 사내맞선', ARRAY['김세정', 'Kim Se-jeong', '경이로운 소문'], 90, true),

('actor_hyeri', '혜리', 'Hyeri', '이혜리', 'actor', 'female',
 '1994-06-09', 'ENFP', 'AB', true, '걸스데이',
 '응답하라 1988, 마이 룸메이트는 구미호', ARRAY['혜리', 'Hyeri', '이혜리', '걸스데이'], 90, true),

('actor_jung_somi', '전소미', 'Jeon So-mi', '전소미', 'actor', 'female',
 '2001-03-09', 'ENFP', 'AB', false, NULL,
 '솔로 가수, 아이 오브 원더', ARRAY['전소미', 'Jeon So-mi'], 85, true),

('actor_chae_sobin', '채수빈', 'Chae Soo-bin', '채수빈', 'actor', 'female',
 '1994-07-10', 'ISFP', 'A', false, NULL,
 '여우각시별, 로봇이 아니야', ARRAY['채수빈', 'Chae Soo-bin'], 85, true),

('actor_lee_sung_kyung', '이성경', 'Lee Sung-kyung', '이성경', 'actor', 'female',
 '1990-08-10', 'ENFP', 'B', false, NULL,
 '낭만닥터 김사부, 역도요정 김복주', ARRAY['이성경', 'Lee Sung-kyung', '김복주'], 90, true),

('actor_seo_hyunjin', '서현진', 'Seo Hyun-jin', '서현진', 'actor', 'female',
 '1985-02-27', 'INFP', 'A', false, NULL,
 '또 오해영, 낭만닥터 김사부', ARRAY['서현진', 'Seo Hyun-jin', '또 오해영'], 90, true),

('actor_jo_boah', '조보아', 'Jo Bo-ah', '조보아', 'actor', 'female',
 '1991-08-22', 'ESFP', 'A', false, NULL,
 '구미호전, 만월의 전설', ARRAY['조보아', 'Jo Bo-ah'], 86, true),

('actor_shin_hyesun', '신혜선', 'Shin Hye-sun', '신혜선', 'actor', 'female',
 '1989-08-31', 'INFP', 'A', false, NULL,
 '미스터 퀸, 철인왕후', ARRAY['신혜선', 'Shin Hye-sun', '미스터 퀸'], 91, true),

('actor_jun_jihyun2', '전미도', 'Jeon Mi-do', '전미도', 'actor', 'female',
 '1982-07-01', 'ENFJ', 'O', false, NULL,
 '슬기로운 의사생활, 서른 아홉', ARRAY['전미도', 'Jeon Mi-do', '슬기로운 의사생활'], 90, true),

('actor_go_younjung', '고윤정', 'Go Youn-jung', '고윤정', 'actor', 'female',
 '1996-04-22', NULL, 'AB', false, NULL,
 '환혼, 무빙', ARRAY['고윤정', 'Go Youn-jung', '환혼'], 91, true),

('actor_jung_eunji', '정은지', 'Jung Eun-ji', '정은지', 'actor', 'female',
 '1993-08-18', 'ESFJ', 'O', true, '에이핑크',
 '응답하라 1997, 복수는 나의 것', ARRAY['정은지', 'Jung Eun-ji', '에이핑크'], 88, true),

('actor_lee_hyeri', '이하이', 'Lee Ha-yi', '이하이', 'actor', 'female',
 '1996-09-23', 'INFP', 'A', false, NULL,
 '가수 겸 배우, K2', ARRAY['이하이', 'Lee Ha-yi'], 80, true)

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
    actor_count INTEGER;
    male_count INTEGER;
    female_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO actor_count
    FROM celebrities
    WHERE category = 'actor' AND is_active = true;

    SELECT COUNT(*) INTO male_count
    FROM celebrities
    WHERE category = 'actor' AND gender = 'male' AND is_active = true;

    SELECT COUNT(*) INTO female_count
    FROM celebrities
    WHERE category = 'actor' AND gender = 'female' AND is_active = true;

    RAISE NOTICE 'Total actors: %, Male: %, Female: %', actor_count, male_count, female_count;
END $$;
