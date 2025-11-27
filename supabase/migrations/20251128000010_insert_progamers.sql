-- 프로게이머 100명 데이터 삽입
-- 스타크래프트, 리그오브레전드, 오버워치, 발로란트 등 다양한 종목
-- 2025년 11월 28일

INSERT INTO public.celebrities (
    id, name, name_en, legal_name, category, gender,
    birth_date, mbti, blood_type, is_group_member, group_name,
    description, keywords, popularity_score, is_active
) VALUES
-- ============================================
-- 스타크래프트 1 레전드 (테란)
-- ============================================
('progamer_lim_yohwan', '임요환', 'Lim Yo-hwan', '임요환', 'pro_gamer', 'male',
 '1980-09-04', 'ENFP', 'O', false, NULL,
 'BoxeR, 테란의 황제, e스포츠 상징', ARRAY['임요환', 'BoxeR', '황제', '스타크래프트'], 98, true),

('progamer_lee_youngho', '이영호', 'Lee Young-ho', '이영호', 'pro_gamer', 'male',
 '1992-07-05', 'INTJ', 'A', false, NULL,
 'FlaSh, 최종병기, 골든그랜드슬램', ARRAY['이영호', 'FlaSh', '최종병기', '스타크래프트'], 97, true),

('progamer_choi_yeonsung', '최연성', 'Choi Yeon-sung', '최연성', 'pro_gamer', 'male',
 '1983-11-05', 'INTP', 'B', false, NULL,
 'iloveoov, 테란 전략가', ARRAY['최연성', 'iloveoov', '테란', '스타크래프트'], 85, true),

('progamer_lee_yunyeol', '이윤열', 'Lee Yun-yeol', '이윤열', 'pro_gamer', 'male',
 '1984-11-20', 'ENFP', 'O', false, NULL,
 'NaDa, 테란 3대 천왕', ARRAY['이윤열', 'NaDa', '테란', '스타크래프트'], 88, true),

-- ============================================
-- 스타크래프트 1 레전드 (저그)
-- ============================================
('progamer_hong_jinho', '홍진호', 'Hong Jin-ho', '홍진호', 'pro_gamer', 'male',
 '1982-10-31', 'ENFP', 'A', false, NULL,
 'YellOw, 영원한 2인자, 방송인', ARRAY['홍진호', 'YellOw', '저그', '스타크래프트'], 92, true),

('progamer_lee_jaedong', '이제동', 'Lee Jae-dong', '이제동', 'pro_gamer', 'male',
 '1990-01-09', 'ISTJ', 'A', false, NULL,
 'Jaedong, 폭군, 저그의 황제', ARRAY['이제동', 'Jaedong', '폭군', '스타크래프트'], 95, true),

('progamer_park_sungjun', '박성준', 'Park Sung-jun', '박성준', 'pro_gamer', 'male',
 '1986-12-18', 'INFP', 'O', false, NULL,
 'July, 투신, 저그 레전드', ARRAY['박성준', 'July', '투신', '스타크래프트'], 85, true),

('progamer_ma_jaeyun', '마재윤', 'Ma Jae-yun', '마재윤', 'pro_gamer', 'male',
 '1985-11-23', 'INTP', 'A', false, NULL,
 'sAviOr, 저그 제왕 (승부조작)', ARRAY['마재윤', 'sAviOr', '저그', '스타크래프트'], 70, true),

-- ============================================
-- 스타크래프트 1 레전드 (프로토스)
-- ============================================
('progamer_song_byunggu', '송병구', 'Song Byung-gu', '송병구', 'pro_gamer', 'male',
 '1988-08-04', 'INFP', 'A', false, NULL,
 'Stork, 무결점의 총사령관', ARRAY['송병구', 'Stork', '프로토스', '스타크래프트'], 88, true),

('progamer_kim_taekyong', '김택용', 'Kim Taek-yong', '김택용', 'pro_gamer', 'male',
 '1989-11-03', 'INFP', 'O', false, NULL,
 'Bisu, 혁명가, 프로토스 레전드', ARRAY['김택용', 'Bisu', '혁명가', '스타크래프트'], 90, true),

('progamer_kang_minj', '강민', 'Kang Min', '강민', 'pro_gamer', 'male',
 '1985-06-10', 'INTP', 'A', false, NULL,
 'Nal_rA, 드라군 장인', ARRAY['강민', 'Nal_rA', '드라군', '스타크래프트'], 78, true),

('progamer_lee_junhyuk', '허영무', 'Heo Young-moo', '허영무', 'pro_gamer', 'male',
 '1982-12-15', 'INFP', 'B', false, NULL,
 'JangBi, 프로토스 장인', ARRAY['허영무', 'JangBi', '프로토스', '스타크래프트'], 80, true),

-- ============================================
-- 스타크래프트 2 선수들
-- ============================================
('progamer_joo_hoon', '주훈', 'Joo Hoon', '주훈', 'pro_gamer', 'male',
 '1994-06-13', 'INTP', 'A', false, NULL,
 'Hoon, 스타2 테란', ARRAY['주훈', 'Hoon', '테란', '스타크래프트2'], 72, true),

('progamer_joo_seong_wook', '조성주', 'Jo Sung-ju', '조성주', 'pro_gamer', 'male',
 '1990-08-08', 'INFP', 'A', false, NULL,
 'Classic, 프로토스', ARRAY['조성주', 'Classic', '프로토스', '스타크래프트2'], 78, true),

('progamer_kim_yoojin', '김유진', 'Kim Yoo-jin', '김유진', 'pro_gamer', 'male',
 '1992-05-25', 'INTP', 'B', false, NULL,
 'sOs, 스타2 프로토스', ARRAY['김유진', 'sOs', '프로토스', '스타크래프트2'], 82, true),

('progamer_jung_jonghyun', '정종현', 'Jung Jong-hyun', '정종현', 'pro_gamer', 'male',
 '1992-11-27', 'INFP', 'A', false, NULL,
 'MVP, 스타2 테란', ARRAY['정종현', 'MVP', '테란', '스타크래프트2'], 80, true),

('progamer_maru', '조성주', 'Cho Seong-ju', '조성주', 'pro_gamer', 'male',
 '1997-02-04', 'INTP', 'A', false, NULL,
 'Maru, 스타2 테란 최강자', ARRAY['조성주', 'Maru', '테란', '스타크래프트2'], 90, true),

('progamer_stats', '김대엽', 'Kim Dae-yeob', '김대엽', 'pro_gamer', 'male',
 '1990-01-01', 'INFP', 'A', false, NULL,
 'Stats, 스타2 프로토스', ARRAY['김대엽', 'Stats', '프로토스', '스타크래프트2'], 80, true),

('progamer_rogue', '이병렬', 'Lee Byung-ryul', '이병렬', 'pro_gamer', 'male',
 '1998-02-17', 'INTP', 'A', false, NULL,
 'Rogue, 스타2 저그', ARRAY['이병렬', 'Rogue', '저그', '스타크래프트2'], 85, true),

('progamer_dark', '박령우', 'Park Ryung-woo', '박령우', 'pro_gamer', 'male',
 '1993-05-07', 'INFP', 'B', false, NULL,
 'Dark, 스타2 저그', ARRAY['박령우', 'Dark', '저그', '스타크래프트2'], 85, true),

('progamer_serral', '요우나 소탈라', 'Joona Sotala', 'Joona Sotala', 'pro_gamer', 'male',
 '1998-08-01', 'INTP', NULL, false, NULL,
 'Serral, 핀란드 저그, 외국인 최강', ARRAY['Serral', '저그', '핀란드', '스타크래프트2'], 90, true),

-- ============================================
-- 리그오브레전드 - T1
-- ============================================
('progamer_faker', '페이커', 'Faker', '이상혁', 'pro_gamer', 'male',
 '1996-05-07', 'INTP', 'A', true, 'T1',
 '롤 갓, 월드 챔피언십 4회 우승', ARRAY['페이커', 'Faker', '이상혁', 'T1', 'LOL'], 99, true),

('progamer_oner', '오너', 'Oner', '문현준', 'pro_gamer', 'male',
 '2002-12-24', 'ENFP', 'A', true, 'T1',
 'T1 정글러, 월드 챔피언', ARRAY['오너', 'Oner', '문현준', 'T1', 'LOL'], 92, true),

('progamer_zeus', '제우스', 'Zeus', '최우제', 'pro_gamer', 'male',
 '2004-01-31', 'ENFP', 'O', true, 'T1',
 'T1 탑라이너, 월드 챔피언', ARRAY['제우스', 'Zeus', '최우제', 'T1', 'LOL'], 90, true),

('progamer_gumayusi', '구마유시', 'Gumayusi', '이민형', 'pro_gamer', 'male',
 '2002-02-06', 'ENFP', 'A', true, 'T1',
 'T1 원딜, 월드 챔피언', ARRAY['구마유시', 'Gumayusi', '이민형', 'T1', 'LOL'], 92, true),

('progamer_keria', '케리아', 'Keria', '류민석', 'pro_gamer', 'male',
 '2002-10-14', 'ENFP', 'B', true, 'T1',
 'T1 서포터, 월드 챔피언', ARRAY['케리아', 'Keria', '류민석', 'T1', 'LOL'], 93, true),

-- ============================================
-- 리그오브레전드 - 전 T1
-- ============================================
('progamer_bang', '뱅', 'Bang', '배준식', 'pro_gamer', 'male',
 '1996-05-18', 'INFP', 'A', false, NULL,
 '前 T1 원딜, 월드 챔피언 2회', ARRAY['뱅', 'Bang', '배준식', 'T1', 'LOL'], 88, true),

('progamer_wolf', '울프', 'Wolf', '이재완', 'pro_gamer', 'male',
 '1996-09-09', 'ENFP', 'O', false, NULL,
 '前 T1 서포터, 월드 챔피언 2회', ARRAY['울프', 'Wolf', '이재완', 'T1', 'LOL'], 82, true),

('progamer_bengi', '벵기', 'Bengi', '배성웅', 'pro_gamer', 'male',
 '1994-03-25', 'INFP', 'A', false, NULL,
 '前 T1 정글러, 월드 챔피언 3회', ARRAY['벵기', 'Bengi', '배성웅', 'T1', 'LOL'], 88, true),

('progamer_marin', '마린', 'MaRin', '장경환', 'pro_gamer', 'male',
 '1991-02-13', 'INTP', 'A', false, NULL,
 '前 T1 탑라이너, 월드 챔피언', ARRAY['마린', 'MaRin', '장경환', 'T1', 'LOL'], 85, true),

('progamer_impact', '임팩트', 'Impact', '정언영', 'pro_gamer', 'male',
 '1995-04-25', 'INFP', 'O', false, NULL,
 '前 T1 탑라이너, NA LCS 활동', ARRAY['임팩트', 'Impact', '정언영', 'LOL'], 82, true),

-- ============================================
-- 리그오브레전드 - 다른 팀
-- ============================================
('progamer_showmaker', '쇼메이커', 'ShowMaker', '허수', 'pro_gamer', 'male',
 '2000-07-22', 'INTP', 'A', true, 'Dplus KIA',
 'DK 미드라이너, 월드 챔피언', ARRAY['쇼메이커', 'ShowMaker', '허수', 'DK', 'LOL'], 95, true),

('progamer_canyon', '캐니언', 'Canyon', '김건부', 'pro_gamer', 'male',
 '2001-06-18', 'INTP', 'A', true, 'Dplus KIA',
 'DK 정글러, 월드 챔피언', ARRAY['캐니언', 'Canyon', '김건부', 'DK', 'LOL'], 93, true),

('progamer_ruler', '룰러', 'Ruler', '박재혁', 'pro_gamer', 'male',
 '1998-12-29', 'INFP', 'A', true, 'GenG',
 'GenG 원딜, 월드 챔피언', ARRAY['룰러', 'Ruler', '박재혁', 'GenG', 'LOL'], 92, true),

('progamer_chovy', '초비', 'Chovy', '정지훈', 'pro_gamer', 'male',
 '2000-03-03', 'INTP', 'A', true, 'GenG',
 'GenG 미드라이너', ARRAY['초비', 'Chovy', '정지훈', 'GenG', 'LOL'], 93, true),

('progamer_bdd', '비디디', 'Bdd', '곽보성', 'pro_gamer', 'male',
 '1999-03-01', 'INFP', 'B', true, 'KT',
 'KT 미드라이너', ARRAY['비디디', 'Bdd', '곽보성', 'KT', 'LOL'], 88, true),

('progamer_peanut', '피넛', 'Peanut', '한왕호', 'pro_gamer', 'male',
 '1998-02-03', 'ENFP', 'O', false, NULL,
 '前 HLE 정글러, 은퇴', ARRAY['피넛', 'Peanut', '한왕호', 'LOL'], 90, true),

('progamer_teddy', '테디', 'Teddy', '박진성', 'pro_gamer', 'male',
 '1998-06-12', 'INFP', 'A', false, NULL,
 '前 T1 원딜', ARRAY['테디', 'Teddy', '박진성', 'LOL'], 85, true),

('progamer_deft', '데프트', 'Deft', '김혁규', 'pro_gamer', 'male',
 '1996-10-23', 'INFP', 'A', false, NULL,
 '前 DRX 원딜, 월드 챔피언', ARRAY['데프트', 'Deft', '김혁규', 'LOL'], 92, true),

('progamer_lehends', '레헨즈', 'Lehends', '손시우', 'pro_gamer', 'male',
 '1997-05-25', 'INFP', 'A', true, 'GenG',
 'GenG 서포터', ARRAY['레헨즈', 'Lehends', '손시우', 'GenG', 'LOL'], 85, true),

('progamer_mata', '마타', 'Mata', '조세형', 'pro_gamer', 'male',
 '1994-08-27', 'INTP', 'A', false, NULL,
 '前 삼성 서포터, 월드 챔피언', ARRAY['마타', 'Mata', '조세형', 'LOL'], 88, true),

('progamer_score', '스코어', 'Score', '고동빈', 'pro_gamer', 'male',
 '1994-01-12', 'INFP', 'A', false, NULL,
 '前 KT 정글러, LCK MVP', ARRAY['스코어', 'Score', '고동빈', 'KT', 'LOL'], 85, true),

('progamer_doran', '도란', 'Doran', '최현준', 'pro_gamer', 'male',
 '1999-06-05', 'ENFP', 'A', true, 'HLE',
 'HLE 탑라이너', ARRAY['도란', 'Doran', '최현준', 'HLE', 'LOL'], 85, true),

('progamer_viper', '바이퍼', 'Viper', '박도현', 'pro_gamer', 'male',
 '2000-03-12', 'INFP', 'A', true, 'HLE',
 'HLE 원딜', ARRAY['바이퍼', 'Viper', '박도현', 'HLE', 'LOL'], 90, true),

('progamer_smeb', '스맵', 'Smeb', '송경호', 'pro_gamer', 'male',
 '1994-10-21', 'INFP', 'A', false, NULL,
 '前 KT 탑라이너, 최고의 탑', ARRAY['스맵', 'Smeb', '송경호', 'LOL'], 88, true),

('progamer_pray', '프레이', 'PraY', '김종인', 'pro_gamer', 'male',
 '1994-08-24', 'INFP', 'O', false, NULL,
 '前 ROX/KZ 원딜', ARRAY['프레이', 'PraY', '김종인', 'LOL'], 85, true),

('progamer_gorilla', '고릴라', 'GorillA', '강범현', 'pro_gamer', 'male',
 '1994-05-26', 'ENFP', 'A', false, NULL,
 '前 ROX/KZ 서포터', ARRAY['고릴라', 'GorillA', '강범현', 'LOL'], 82, true),

('progamer_ambition', '앰비션', 'Ambition', '강찬용', 'pro_gamer', 'male',
 '1992-03-30', 'INFP', 'A', false, NULL,
 '前 삼성 정글러, 월드 챔피언', ARRAY['앰비션', 'Ambition', '강찬용', 'LOL'], 85, true),

('progamer_crown', '크라운', 'Crown', '이민호', 'pro_gamer', 'male',
 '1995-03-24', 'INFP', 'A', false, NULL,
 '前 삼성 미드, 월드 챔피언', ARRAY['크라운', 'Crown', '이민호', 'LOL'], 82, true),

-- ============================================
-- 오버워치 / 발로란트
-- ============================================
('progamer_munchkin', '먼치킨', 'Munchkin', '변상범', 'pro_gamer', 'male',
 '1998-03-27', 'ENFP', NULL, true, 'GenG',
 '발로란트 프로, 前 오버워치', ARRAY['먼치킨', 'Munchkin', '발로란트', 'GenG'], 82, true),

('progamer_zunba', '준바', 'Zunba', '김준혁', 'pro_gamer', 'male',
 '1997-03-25', 'INFP', NULL, false, NULL,
 '前 오버워치, 발로란트 프로', ARRAY['준바', 'Zunba', '오버워치', '발로란트'], 78, true),

('progamer_carpe', '카르페', 'Carpe', '이재혁', 'pro_gamer', 'male',
 '1998-06-14', 'INFP', NULL, false, NULL,
 '오버워치 DPS, 필라델피아 퓨전', ARRAY['카르페', 'Carpe', '오버워치'], 85, true),

('progamer_fleta', '플레타', 'Fleta', '김병선', 'pro_gamer', 'male',
 '1998-03-06', 'INFP', NULL, false, NULL,
 '오버워치 DPS, 서울 다이너스티', ARRAY['플레타', 'Fleta', '오버워치', '서울'], 88, true),

('progamer_profit', '프로핏', 'Profit', '박준영', 'pro_gamer', 'male',
 '1998-01-30', 'ENFP', NULL, false, NULL,
 '오버워치 DPS, 월드컵 우승', ARRAY['프로핏', 'Profit', '오버워치'], 85, true),

('progamer_gesture', '제스처', 'Gesture', '홍재희', 'pro_gamer', 'male',
 '1998-08-24', 'INFP', NULL, false, NULL,
 '오버워치 탱커, 서울 다이너스티', ARRAY['제스처', 'Gesture', '오버워치'], 82, true),

('progamer_ryujehong', '류제홍', 'Ryujehong', '류제홍', 'pro_gamer', 'male',
 '1994-11-26', 'INFP', NULL, false, NULL,
 '오버워치 서포터, 아나 신', ARRAY['류제홍', 'Ryujehong', '오버워치', '아나'], 85, true),

('progamer_jjonak', '조나', 'JJoNak', '방성현', 'pro_gamer', 'male',
 '1998-02-08', 'INTP', NULL, false, NULL,
 '오버워치 서포터, MVP', ARRAY['조나', 'JJoNak', '오버워치', 'MVP'], 88, true),

('progamer_stax', '스택스', 'Stax', '김구택', 'pro_gamer', 'male',
 '1999-08-15', 'ENFP', NULL, true, 'DRX',
 '발로란트 프로, DRX', ARRAY['스택스', 'Stax', '발로란트', 'DRX'], 85, true),

('progamer_rb', '알비', 'Rb', '구예림', 'pro_gamer', 'male',
 '2002-09-20', 'INFP', NULL, true, 'DRX',
 '발로란트 프로, DRX', ARRAY['알비', 'Rb', '발로란트', 'DRX'], 82, true),

('progamer_t3xture', '텍스쳐', 'T3xture', '김나라', 'pro_gamer', 'male',
 '2001-04-08', 'ENFP', NULL, true, 'GenG',
 '발로란트 프로, GenG', ARRAY['텍스쳐', 'T3xture', '발로란트', 'GenG'], 80, true),

-- ============================================
-- 철권 / 격투 게임
-- ============================================
('progamer_knee', '무릎', 'Knee', '배재민', 'pro_gamer', 'male',
 '1990-01-26', 'INTP', NULL, false, NULL,
 '철권 월드 챔피언, 레전드', ARRAY['무릎', 'Knee', '철권', '격투게임'], 92, true),

('progamer_jdcr', 'JDCR', 'JDCR', '김현진', 'pro_gamer', 'male',
 '1990-05-18', 'INFP', NULL, false, NULL,
 '철권 프로, 레전드', ARRAY['JDCR', '철권', '격투게임'], 88, true),

('progamer_saint', '세인트', 'Saint', '조용준', 'pro_gamer', 'male',
 '1987-08-10', 'INFP', NULL, false, NULL,
 '철권 프로, 레전드', ARRAY['세인트', 'Saint', '철권', '격투게임'], 82, true),

('progamer_lowhigh', '로하이', 'LowHigh', '유충희', 'pro_gamer', 'male',
 '1996-03-22', 'INFP', NULL, false, NULL,
 '철권 프로, 세계 랭커', ARRAY['로하이', 'LowHigh', '철권', '격투게임'], 80, true),

('progamer_chanel', '샤넬', 'Chanel', '강성호', 'pro_gamer', 'male',
 '1994-11-15', 'ENFP', NULL, false, NULL,
 '철권 프로, 알리사 장인', ARRAY['샤넬', 'Chanel', '철권', '격투게임'], 78, true),

-- ============================================
-- 배틀그라운드 / 기타
-- ============================================
('progamer_pio', '피오', 'Pio', '이성훈', 'pro_gamer', 'male',
 '1997-11-05', 'ENFP', NULL, false, NULL,
 '배틀그라운드 프로, 젠지', ARRAY['피오', 'Pio', '배틀그라운드', 'GenG'], 78, true),

('progamer_esca', '에스카', 'Esca', '김인재', 'pro_gamer', 'male',
 '1995-01-18', 'ENFP', NULL, false, NULL,
 '前 오버워치, 배틀그라운드 프로', ARRAY['에스카', 'Esca', '배틀그라운드'], 75, true),

('progamer_inonix', '이노닉스', 'Inonix', '정인혁', 'pro_gamer', 'male',
 '1999-08-25', 'INFP', NULL, false, NULL,
 '배틀그라운드 프로', ARRAY['이노닉스', 'Inonix', '배틀그라운드'], 72, true),

-- ============================================
-- 피파온라인 / 스포츠 게임
-- ============================================
('progamer_sean', '션', 'Sean', '이성원', 'pro_gamer', 'male',
 '1998-05-12', 'ENFP', NULL, false, NULL,
 '피파온라인 프로', ARRAY['션', 'Sean', '피파온라인'], 75, true),

('progamer_rocky', '록키', 'Rocky', '이상혁', 'pro_gamer', 'male',
 '1997-09-28', 'INFP', NULL, false, NULL,
 '피파온라인 프로', ARRAY['록키', 'Rocky', '피파온라인'], 72, true),

-- ============================================
-- 하스스톤 / 카드게임
-- ============================================
('progamer_surrender', '서렌더', 'Surrender', '이재민', 'pro_gamer', 'male',
 '1992-04-03', 'INTP', NULL, false, NULL,
 '하스스톤 프로, 세계대회 우승', ARRAY['서렌더', 'Surrender', '하스스톤'], 80, true),

('progamer_flurry', '플러리', 'Flurry', '이동수', 'pro_gamer', 'male',
 '1995-07-18', 'INFP', NULL, false, NULL,
 '하스스톤 프로', ARRAY['플러리', 'Flurry', '하스스톤'], 75, true),

-- ============================================
-- 감독/코치
-- ============================================
('progamer_kkoma', '코마', 'Kkoma', '정균', 'pro_gamer', 'male',
 '1986-06-13', 'INTJ', 'A', false, NULL,
 'T1 감독, 월드 챔피언 다수', ARRAY['코마', 'Kkoma', 'T1', '감독'], 90, true),

('progamer_cvmax', '씨맥', 'CvMax', '김대호', 'pro_gamer', 'male',
 '1989-11-17', 'ENTP', 'O', false, NULL,
 '前 그리핀 감독', ARRAY['씨맥', 'CvMax', '감독', 'LOL'], 78, true),

('progamer_kim_junghyun_coach', '주훈', 'Joo Hoon', '주훈', 'pro_gamer', 'male',
 '1973-03-14', 'INTJ', 'A', false, NULL,
 'SKT T1 초대 감독', ARRAY['주훈', '감독', 'SKT', '스타크래프트'], 82, true),

-- ============================================
-- 2024-2025 신예 선수들
-- ============================================
('progamer_peyz', '페이즈', 'Peyz', '김수환', 'pro_gamer', 'male',
 '2005-09-15', 'ENFP', NULL, true, 'GenG',
 'GenG 원딜, 신예', ARRAY['페이즈', 'Peyz', 'GenG', 'LOL'], 85, true),

('progamer_kiin', '기인', 'Kiin', '김기인', 'pro_gamer', 'male',
 '1999-02-11', 'INFP', 'A', true, 'KT',
 'KT 탑라이너', ARRAY['기인', 'Kiin', 'KT', 'LOL'], 88, true),

('progamer_pyosik', '표식', 'Pyosik', '홍창현', 'pro_gamer', 'male',
 '2001-03-14', 'ENFP', 'A', true, 'DRX',
 'DRX 정글러', ARRAY['표식', 'Pyosik', 'DRX', 'LOL'], 82, true),

('progamer_lucid', '루시드', 'Lucid', '최원석', 'pro_gamer', 'male',
 '2002-08-25', 'INFP', 'A', true, 'DK',
 'DK 서포터', ARRAY['루시드', 'Lucid', 'DK', 'LOL'], 80, true),

('progamer_aiming', '에이밍', 'Aiming', '김하람', 'pro_gamer', 'male',
 '2000-09-23', 'INFP', 'O', true, 'KT',
 'KT 원딜', ARRAY['에이밍', 'Aiming', 'KT', 'LOL'], 85, true),

('progamer_delight', '딜라이트', 'Delight', '유환중', 'pro_gamer', 'male',
 '2003-04-10', 'ENFP', 'A', true, 'HLE',
 'HLE 서포터', ARRAY['딜라이트', 'Delight', 'HLE', 'LOL'], 80, true),

-- ============================================
-- 여성 프로게이머
-- ============================================
('progamer_geguri', '게구리', 'Geguri', '김세연', 'pro_gamer', 'female',
 '1998-06-28', 'INFP', NULL, false, NULL,
 '오버워치 프로, 여성 최초 OWL', ARRAY['게구리', 'Geguri', '오버워치', '여성프로게이머'], 85, true),

('progamer_tossgirl', '토스걸', 'ToSsGirL', '서지수', 'pro_gamer', 'female',
 '1986-08-03', 'ENFP', NULL, false, NULL,
 '스타크래프트 여성 프로, 레전드', ARRAY['토스걸', 'ToSsGirL', '스타크래프트', '여성프로게이머'], 82, true),

('progamer_scarlett', '스칼렛', 'Scarlett', 'Sasha Hostyn', 'pro_gamer', 'female',
 '1993-12-14', 'INTP', NULL, false, NULL,
 '스타2 여성 프로, 캐나다', ARRAY['스칼렛', 'Scarlett', '스타크래프트2', '여성프로게이머'], 85, true)

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
    WHERE category = 'pro_gamer'
    AND is_active = true;

    RAISE NOTICE 'Total active pro gamers: %', inserted_count;
END $$;
