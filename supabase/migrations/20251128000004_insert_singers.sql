-- 가수 데이터 삽입 (솔로 + 아이돌 멤버 개별)
-- 총 100명: 아이돌 멤버 70명 + 솔로 가수 30명

-- ==========================================
-- BTS 멤버 (7명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_bts_rm', 'RM', 'RM', '김남준', 'singer', 'male', '1994-09-12', 'ENTP', 'A', true, 'BTS', 'BTS 리더, 메인래퍼', ARRAY['BTS', 'RM', '김남준', '방탄소년단', '래퍼'], 98, true),
('singer_bts_jin', '진', 'Jin', '김석진', 'singer', 'male', '1992-12-04', 'INTP', 'O', true, 'BTS', 'BTS 서브보컬, 비주얼', ARRAY['BTS', '진', '김석진', '방탄소년단'], 97, true),
('singer_bts_suga', '슈가', 'SUGA', '민윤기', 'singer', 'male', '1993-03-09', 'ISTP', 'O', true, 'BTS', 'BTS 리드래퍼', ARRAY['BTS', '슈가', '민윤기', '방탄소년단', 'Agust D'], 97, true),
('singer_bts_jhope', '제이홉', 'J-Hope', '정호석', 'singer', 'male', '1994-02-18', 'INFJ', 'A', true, 'BTS', 'BTS 메인댄서, 서브래퍼', ARRAY['BTS', '제이홉', '정호석', '방탄소년단'], 96, true),
('singer_bts_jimin', '지민', 'Jimin', '박지민', 'singer', 'male', '1995-10-13', 'ESTP', 'A', true, 'BTS', 'BTS 메인댄서, 리드보컬', ARRAY['BTS', '지민', '박지민', '방탄소년단'], 98, true),
('singer_bts_v', '뷔', 'V', '김태형', 'singer', 'male', '1995-12-30', 'INFP', 'AB', true, 'BTS', 'BTS 서브보컬', ARRAY['BTS', '뷔', '김태형', '방탄소년단', '태태'], 98, true),
('singer_bts_jungkook', '정국', 'Jungkook', '전정국', 'singer', 'male', '1997-09-01', 'INTP', 'A', true, 'BTS', 'BTS 메인보컬, 센터, 막내', ARRAY['BTS', '정국', '전정국', '방탄소년단', '황금막내'], 99, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- BLACKPINK 멤버 (4명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_bp_jisoo', '지수', 'Jisoo', '김지수', 'singer', 'female', '1995-01-03', 'ISTP', 'A', true, 'BLACKPINK', 'BLACKPINK 리드보컬, 비주얼', ARRAY['BLACKPINK', '지수', '김지수', '블랙핑크'], 96, true),
('singer_bp_jennie', '제니', 'Jennie', '김제니', 'singer', 'female', '1996-01-16', 'INFJ', 'B', true, 'BLACKPINK', 'BLACKPINK 메인래퍼, 리드보컬', ARRAY['BLACKPINK', '제니', '김제니', '블랙핑크', 'SOLO'], 98, true),
('singer_bp_rose', '로제', 'Rosé', '박채영', 'singer', 'female', '1997-02-11', 'ENFP', 'B', true, 'BLACKPINK', 'BLACKPINK 메인보컬, 리드댄서', ARRAY['BLACKPINK', '로제', '박채영', '블랙핑크', 'On The Ground'], 97, true),
('singer_bp_lisa', '리사', 'Lisa', 'Lalisa Manobal', 'singer', 'female', '1997-03-27', 'ISFP', 'O', true, 'BLACKPINK', 'BLACKPINK 메인댄서, 리드래퍼, 막내', ARRAY['BLACKPINK', '리사', '라리사', '블랙핑크', 'LALISA'], 98, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- NewJeans 멤버 (5명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_nj_minji', '민지', 'Minji', '김민지', 'singer', 'female', '2004-05-07', 'ESTJ', 'A', true, 'NewJeans', 'NewJeans 리더', ARRAY['NewJeans', '민지', '김민지', '뉴진스'], 95, true),
('singer_nj_hanni', '하니', 'Hanni', 'Pham Ngoc Han', 'singer', 'female', '2004-10-06', 'INFP', 'O', true, 'NewJeans', 'NewJeans 서브보컬', ARRAY['NewJeans', '하니', '팜응옥한', '뉴진스'], 96, true),
('singer_nj_danielle', '다니엘', 'Danielle', '모지혜', 'singer', 'female', '2005-04-11', NULL, 'AB', true, 'NewJeans', 'NewJeans 서브보컬', ARRAY['NewJeans', '다니엘', '모지혜', '뉴진스'], 95, true),
('singer_nj_haerin', '해린', 'Haerin', '강해린', 'singer', 'female', '2006-05-15', NULL, 'B', true, 'NewJeans', 'NewJeans 메인댄서', ARRAY['NewJeans', '해린', '강해린', '뉴진스'], 94, true),
('singer_nj_hyein', '혜인', 'Hyein', '이혜인', 'singer', 'female', '2008-04-21', NULL, NULL, true, 'NewJeans', 'NewJeans 막내', ARRAY['NewJeans', '혜인', '이혜인', '뉴진스'], 93, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- aespa 멤버 (4명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_aespa_karina', '카리나', 'Karina', '유지민', 'singer', 'female', '2000-04-11', 'ENFP', 'B', true, 'aespa', 'aespa 리더, 메인댄서', ARRAY['aespa', '카리나', '유지민', '에스파'], 96, true),
('singer_aespa_giselle', '지젤', 'Giselle', '우치나가 에리', 'singer', 'female', '2000-10-30', 'ENFP', 'O', true, 'aespa', 'aespa 메인래퍼', ARRAY['aespa', '지젤', '우치나가에리', '에스파'], 92, true),
('singer_aespa_winter', '윈터', 'Winter', '김민정', 'singer', 'female', '2001-01-01', 'INFJ', 'A', true, 'aespa', 'aespa 메인보컬', ARRAY['aespa', '윈터', '김민정', '에스파'], 95, true),
('singer_aespa_ningning', '닝닝', 'NingNing', '닝이줘', 'singer', 'female', '2002-10-23', 'INFP', 'B', true, 'aespa', 'aespa 메인보컬, 막내', ARRAY['aespa', '닝닝', '닝이줘', '에스파'], 93, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- IVE 멤버 (6명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_ive_gaeul', '가을', 'Gaeul', '김가을', 'singer', 'female', '2002-09-24', 'ISTJ', 'B', true, 'IVE', 'IVE 래퍼', ARRAY['IVE', '가을', '김가을', '아이브'], 90, true),
('singer_ive_yujin', '안유진', 'Ahn Yujin', '안유진', 'singer', 'female', '2003-09-01', 'ISTP', NULL, true, 'IVE', 'IVE 리더, 메인보컬', ARRAY['IVE', '안유진', '아이브', '아이즈원'], 95, true),
('singer_ive_rei', '레이', 'Rei', '나오이 레이', 'singer', 'female', '2004-02-03', NULL, 'A', true, 'IVE', 'IVE 서브보컬', ARRAY['IVE', '레이', '나오이레이', '아이브'], 91, true),
('singer_ive_wonyoung', '장원영', 'Jang Wonyoung', '장원영', 'singer', 'female', '2004-08-31', NULL, 'O', true, 'IVE', 'IVE 센터, 보컬', ARRAY['IVE', '장원영', '아이브', '아이즈원'], 97, true),
('singer_ive_liz', '리즈', 'Liz', '김지원', 'singer', 'female', '2004-11-21', NULL, 'AB', true, 'IVE', 'IVE 메인보컬', ARRAY['IVE', '리즈', '김지원', '아이브'], 90, true),
('singer_ive_leeseo', '이서', 'Leeseo', '이현서', 'singer', 'female', '2007-02-21', NULL, 'O', true, 'IVE', 'IVE 막내', ARRAY['IVE', '이서', '이현서', '아이브'], 90, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- LE SSERAFIM 멤버 (5명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_lsrf_sakura', '사쿠라', 'Sakura', '미야와키 사쿠라', 'singer', 'female', '1998-03-19', 'INTP', 'A', true, 'LE SSERAFIM', 'LE SSERAFIM 보컬', ARRAY['LE SSERAFIM', '사쿠라', '미야와키사쿠라', '르세라핌'], 94, true),
('singer_lsrf_chaewon', '김채원', 'Kim Chaewon', '김채원', 'singer', 'female', '2000-08-01', NULL, 'B', true, 'LE SSERAFIM', 'LE SSERAFIM 리더, 보컬', ARRAY['LE SSERAFIM', '김채원', '르세라핌', '아이즈원'], 94, true),
('singer_lsrf_yunjin', '허윤진', 'Huh Yunjin', '허윤진', 'singer', 'female', '2001-10-08', NULL, 'B', true, 'LE SSERAFIM', 'LE SSERAFIM 보컬', ARRAY['LE SSERAFIM', '허윤진', '르세라핌'], 92, true),
('singer_lsrf_kazuha', '카즈하', 'Kazuha', '나카무라 카즈하', 'singer', 'female', '2003-08-09', NULL, 'A', true, 'LE SSERAFIM', 'LE SSERAFIM 댄서', ARRAY['LE SSERAFIM', '카즈하', '르세라핌'], 93, true),
('singer_lsrf_eunchae', '홍은채', 'Hong Eunchae', '홍은채', 'singer', 'female', '2006-11-10', NULL, 'A', true, 'LE SSERAFIM', 'LE SSERAFIM 막내', ARRAY['LE SSERAFIM', '홍은채', '르세라핌'], 91, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- TWICE 멤버 (9명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_twice_nayeon', '나연', 'Nayeon', '임나연', 'singer', 'female', '1995-09-22', 'ISTP', 'A', true, 'TWICE', 'TWICE 리드보컬, 센터', ARRAY['TWICE', '나연', '임나연', '트와이스'], 95, true),
('singer_twice_jeongyeon', '정연', 'Jeongyeon', '유정연', 'singer', 'female', '1996-11-01', 'ESFJ', 'O', true, 'TWICE', 'TWICE 리드보컬', ARRAY['TWICE', '정연', '유정연', '트와이스'], 92, true),
('singer_twice_momo', '모모', 'Momo', '히라이 모모', 'singer', 'female', '1996-11-09', 'INTP', 'A', true, 'TWICE', 'TWICE 메인댄서', ARRAY['TWICE', '모모', '히라이모모', '트와이스'], 93, true),
('singer_twice_sana', '사나', 'Sana', '미나토자키 사나', 'singer', 'female', '1996-12-29', 'ENFP', 'B', true, 'TWICE', 'TWICE 서브보컬', ARRAY['TWICE', '사나', '미나토자키사나', '트와이스'], 94, true),
('singer_twice_jihyo', '지효', 'Jihyo', '박지효', 'singer', 'female', '1997-02-01', 'ESTP', 'O', true, 'TWICE', 'TWICE 리더, 메인보컬', ARRAY['TWICE', '지효', '박지효', '트와이스'], 93, true),
('singer_twice_mina', '미나', 'Mina', '묘이 미나', 'singer', 'female', '1997-03-24', 'ISTP', 'A', true, 'TWICE', 'TWICE 메인댄서', ARRAY['TWICE', '미나', '묘이미나', '트와이스'], 93, true),
('singer_twice_dahyun', '다현', 'Dahyun', '김다현', 'singer', 'female', '1998-05-28', 'ISFJ', 'O', true, 'TWICE', 'TWICE 리드래퍼', ARRAY['TWICE', '다현', '김다현', '트와이스'], 93, true),
('singer_twice_chaeyoung', '채영', 'Chaeyoung', '손채영', 'singer', 'female', '1999-04-23', 'INFP', 'B', true, 'TWICE', 'TWICE 메인래퍼', ARRAY['TWICE', '채영', '손채영', '트와이스'], 92, true),
('singer_twice_tzuyu', '쯔위', 'Tzuyu', '저우쯔위', 'singer', 'female', '1999-06-14', 'ISFP', 'A', true, 'TWICE', 'TWICE 서브보컬, 비주얼, 막내', ARRAY['TWICE', '쯔위', '저우쯔위', '트와이스'], 94, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- Stray Kids 멤버 (8명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_skz_bangchan', '방찬', 'Bang Chan', '크리스토퍼 방', 'singer', 'male', '1997-10-03', 'ENFJ', 'O', true, 'Stray Kids', 'Stray Kids 리더, 프로듀서', ARRAY['Stray Kids', '방찬', '스트레이키즈', '3RACHA'], 94, true),
('singer_skz_leeknow', '리노', 'Lee Know', '이민호', 'singer', 'male', '1998-10-25', 'ISFP', 'O', true, 'Stray Kids', 'Stray Kids 메인댄서', ARRAY['Stray Kids', '리노', '이민호', '스트레이키즈'], 93, true),
('singer_skz_changbin', '창빈', 'Changbin', '서창빈', 'singer', 'male', '1999-08-11', 'ESTP', 'O', true, 'Stray Kids', 'Stray Kids 메인래퍼', ARRAY['Stray Kids', '창빈', '서창빈', '스트레이키즈', '3RACHA'], 92, true),
('singer_skz_hyunjin', '현진', 'Hyunjin', '황현진', 'singer', 'male', '2000-03-20', 'ESTP', 'B', true, 'Stray Kids', 'Stray Kids 메인댄서, 비주얼', ARRAY['Stray Kids', '현진', '황현진', '스트레이키즈'], 95, true),
('singer_skz_han', '한', 'Han', '한지성', 'singer', 'male', '2000-09-14', 'ISTP', 'B', true, 'Stray Kids', 'Stray Kids 메인래퍼', ARRAY['Stray Kids', '한', '한지성', '스트레이키즈', '3RACHA'], 93, true),
('singer_skz_felix', '필릭스', 'Felix', '이용복', 'singer', 'male', '2000-09-15', 'ENFJ', 'AB', true, 'Stray Kids', 'Stray Kids 리드댄서, 리드래퍼', ARRAY['Stray Kids', '필릭스', '이용복', '스트레이키즈'], 94, true),
('singer_skz_seungmin', '승민', 'Seungmin', '김승민', 'singer', 'male', '2000-09-22', 'ISFJ', 'A', true, 'Stray Kids', 'Stray Kids 리드보컬', ARRAY['Stray Kids', '승민', '김승민', '스트레이키즈'], 91, true),
('singer_skz_in', '아이엔', 'I.N', '양정인', 'singer', 'male', '2001-02-08', 'INFJ', 'A', true, 'Stray Kids', 'Stray Kids 보컬, 막내', ARRAY['Stray Kids', '아이엔', '양정인', '스트레이키즈'], 91, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- SEVENTEEN 멤버 (13명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
('singer_svt_scoups', '에스쿱스', 'S.Coups', '최승철', 'singer', 'male', '1995-08-08', 'ISTP', 'AB', true, 'SEVENTEEN', 'SEVENTEEN 리더, 힙합팀 리더', ARRAY['SEVENTEEN', '에스쿱스', '최승철', '세븐틴'], 93, true),
('singer_svt_jeonghan', '정한', 'Jeonghan', '윤정한', 'singer', 'male', '1995-10-04', 'INFP', 'AB', true, 'SEVENTEEN', 'SEVENTEEN 리드보컬', ARRAY['SEVENTEEN', '정한', '윤정한', '세븐틴'], 94, true),
('singer_svt_joshua', '조슈아', 'Joshua', '홍지수', 'singer', 'male', '1995-12-30', 'ENFJ', 'A', true, 'SEVENTEEN', 'SEVENTEEN 리드보컬', ARRAY['SEVENTEEN', '조슈아', '홍지수', '세븐틴'], 93, true),
('singer_svt_jun', '준', 'Jun', '문준휘', 'singer', 'male', '1996-06-10', 'ESFP', 'B', true, 'SEVENTEEN', 'SEVENTEEN 리드댄서', ARRAY['SEVENTEEN', '준', '문준휘', '세븐틴'], 91, true),
('singer_svt_hoshi', '호시', 'Hoshi', '권순영', 'singer', 'male', '1996-06-15', 'INFP', 'B', true, 'SEVENTEEN', 'SEVENTEEN 퍼포먼스팀 리더, 메인댄서', ARRAY['SEVENTEEN', '호시', '권순영', '세븐틴'], 94, true),
('singer_svt_wonwoo', '원우', 'Wonwoo', '전원우', 'singer', 'male', '1996-07-17', 'INFP', 'A', true, 'SEVENTEEN', 'SEVENTEEN 리드래퍼', ARRAY['SEVENTEEN', '원우', '전원우', '세븐틴'], 93, true),
('singer_svt_woozi', '우지', 'Woozi', '이지훈', 'singer', 'male', '1996-11-22', 'INFJ', 'A', true, 'SEVENTEEN', 'SEVENTEEN 보컬팀 리더, 프로듀서', ARRAY['SEVENTEEN', '우지', '이지훈', '세븐틴'], 93, true),
('singer_svt_dk', '도겸', 'DK', '이석민', 'singer', 'male', '1997-02-18', 'ESFJ', 'A', true, 'SEVENTEEN', 'SEVENTEEN 메인보컬', ARRAY['SEVENTEEN', '도겸', '이석민', '세븐틴'], 92, true),
('singer_svt_mingyu', '민규', 'Mingyu', '김민규', 'singer', 'male', '1997-04-06', 'ENFP', 'B', true, 'SEVENTEEN', 'SEVENTEEN 리드래퍼, 비주얼', ARRAY['SEVENTEEN', '민규', '김민규', '세븐틴'], 95, true),
('singer_svt_the8', '디에잇', 'THE8', '서명호', 'singer', 'male', '1997-11-07', 'INFP', 'O', true, 'SEVENTEEN', 'SEVENTEEN 리드댄서', ARRAY['SEVENTEEN', '디에잇', '서명호', '세븐틴'], 91, true),
('singer_svt_seungkwan', '승관', 'Seungkwan', '부승관', 'singer', 'male', '1998-01-16', 'ENFP', 'B', true, 'SEVENTEEN', 'SEVENTEEN 메인보컬', ARRAY['SEVENTEEN', '승관', '부승관', '세븐틴'], 93, true),
('singer_svt_vernon', '버논', 'Vernon', '최한솔', 'singer', 'male', '1998-02-18', 'INFP', 'A', true, 'SEVENTEEN', 'SEVENTEEN 서브래퍼', ARRAY['SEVENTEEN', '버논', '최한솔', '세븐틴'], 92, true),
('singer_svt_dino', '디노', 'Dino', '이찬', 'singer', 'male', '1999-02-11', 'INTP', 'A', true, 'SEVENTEEN', 'SEVENTEEN 메인댄서, 막내', ARRAY['SEVENTEEN', '디노', '이찬', '세븐틴'], 91, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- ==========================================
-- 솔로 가수 (30명)
-- ==========================================
INSERT INTO public.celebrities (id, name, name_en, legal_name, category, gender, birth_date, mbti, blood_type, is_group_member, group_name, description, keywords, popularity_score, is_active)
VALUES
-- 여성 솔로
('singer_iu', '아이유', 'IU', '이지은', 'singer', 'female', '1993-05-16', 'INFP', 'A', false, NULL, '솔로 가수, 배우', ARRAY['아이유', 'IU', '이지은', '팔레트', '밤편지'], 99, true),
('singer_taeyeon', '태연', 'Taeyeon', '김태연', 'singer', 'female', '1989-03-09', 'ISFJ', 'O', false, NULL, '소녀시대 리더, 솔로 가수', ARRAY['태연', 'Taeyeon', '김태연', '소녀시대', '솔로'], 96, true),
('singer_chungha', '청하', 'Chungha', '김청하', 'singer', 'female', '1996-02-09', 'ENFP', 'A', false, NULL, '솔로 가수, 댄서', ARRAY['청하', 'Chungha', '김청하', 'Gotta Go'], 92, true),
('singer_sunmi', '선미', 'Sunmi', '이선미', 'singer', 'female', '1992-05-02', 'INFP', 'B', false, NULL, '솔로 가수, 원더걸스 출신', ARRAY['선미', 'Sunmi', '이선미', '가시나'], 91, true),
('singer_hwasa', '화사', 'Hwasa', '안혜진', 'singer', 'female', '1995-07-23', 'ENFP', 'AB', false, NULL, '마마무 멤버, 솔로 가수', ARRAY['화사', 'Hwasa', '안혜진', '마마무'], 93, true),
('singer_bibi', '비비', 'BIBI', '김형서', 'singer', 'female', '1998-09-27', NULL, NULL, false, NULL, '솔로 가수, R&B', ARRAY['비비', 'BIBI', '김형서', '밤양갱'], 90, true),

-- 남성 솔로
('singer_lim_young_woong', '임영웅', 'Lim Young Woong', '임영웅', 'singer', 'male', '1991-06-16', 'ISFJ', 'O', false, NULL, '트로트 가수, 미스터트롯 우승', ARRAY['임영웅', '트로트', '미스터트롯', '별빛같은나의사랑아'], 98, true),
('singer_baekhyun', '백현', 'Baekhyun', '변백현', 'singer', 'male', '1992-05-06', 'ISFP', 'O', false, NULL, 'EXO 멤버, 솔로 가수', ARRAY['백현', 'Baekhyun', '변백현', 'EXO', 'Candy'], 95, true),
('singer_gdragon', '지드래곤', 'G-Dragon', '권지용', 'singer', 'male', '1988-08-18', 'INFP', 'A', false, NULL, 'BIGBANG 리더, 솔로 아티스트', ARRAY['지드래곤', 'G-Dragon', '권지용', '빅뱅'], 96, true),
('singer_zico', '지코', 'Zico', '우지호', 'singer', 'male', '1992-09-14', 'INTP', 'O', false, NULL, '래퍼, 프로듀서, Block B 출신', ARRAY['지코', 'Zico', '우지호', '아무노래'], 92, true),
('singer_crush', '크러쉬', 'Crush', '신효섭', 'singer', 'male', '1992-05-03', 'INFP', 'O', false, NULL, 'R&B 가수', ARRAY['크러쉬', 'Crush', '신효섭', 'Beautiful'], 90, true),
('singer_dean', '딘', 'DEAN', '권혁', 'singer', 'male', '1992-11-10', 'INFP', NULL, false, NULL, 'R&B 싱어송라이터', ARRAY['딘', 'DEAN', '권혁', 'instagram'], 88, true),
('singer_jay_park', '박재범', 'Jay Park', '박재범', 'singer', 'male', '1987-04-25', 'ENFP', 'B', false, NULL, '래퍼, AOMG 대표', ARRAY['박재범', 'Jay Park', 'AOMG', 'MOMMAE'], 90, true),
('singer_loco', '로꼬', 'Loco', '권혁우', 'singer', 'male', '1989-12-25', 'INFP', 'A', false, NULL, '래퍼, AOMG', ARRAY['로꼬', 'Loco', '권혁우', 'AOMG'], 85, true),
('singer_simon_d', '사이먼 도미닉', 'Simon Dominic', '정기석', 'singer', 'male', '1984-03-09', NULL, 'A', false, NULL, '래퍼, AOMG', ARRAY['사이먼도미닉', 'Simon Dominic', '정기석'], 86, true),

-- 트로트 & 발라드
('singer_song_ga_in', '송가인', 'Song Ga-in', '송가인', 'singer', 'female', '1986-06-23', NULL, NULL, false, NULL, '트로트 가수, 미스트롯 우승', ARRAY['송가인', '트로트', '미스트롯'], 92, true),
('singer_young_tak', '영탁', 'Young Tak', '조영탁', 'singer', 'male', '1984-03-24', NULL, NULL, false, NULL, '트로트 가수, 미스터트롯', ARRAY['영탁', '트로트', '미스터트롯'], 88, true),
('singer_lee_chan_won', '이찬원', 'Lee Chan-won', '이찬원', 'singer', 'male', '1997-06-11', NULL, NULL, false, NULL, '트로트 가수, 미스터트롯', ARRAY['이찬원', '트로트', '미스터트롯'], 90, true),
('singer_hong_jin_young', '홍진영', 'Hong Jin-young', '홍진영', 'singer', 'female', '1985-08-09', NULL, 'B', false, NULL, '트로트 가수', ARRAY['홍진영', '트로트', '사랑의배터리'], 87, true),
('singer_jang_yoon_jung', '장윤정', 'Jang Yoon-jung', '장윤정', 'singer', 'female', '1980-02-16', NULL, 'O', false, NULL, '트로트 가수', ARRAY['장윤정', '트로트', '어머나'], 86, true),

-- 발라드/R&B
('singer_paul_kim', '폴킴', 'Paul Kim', '김현우', 'singer', 'male', '1988-04-20', NULL, NULL, false, NULL, '발라드 가수', ARRAY['폴킴', 'Paul Kim', '김현우', '모든날모든순간'], 89, true),
('singer_kim_bum_soo', '김범수', 'Kim Bum-soo', '김범수', 'singer', 'male', '1979-01-26', NULL, 'O', false, NULL, '발라드 가수', ARRAY['김범수', '발라드', '보고싶다'], 87, true),
('singer_naul', '나얼', 'Naul', '유나얼', 'singer', 'male', '1978-09-25', NULL, 'A', false, NULL, '브라운아이드소울 멤버, R&B', ARRAY['나얼', 'Naul', '브라운아이드소울', '기억의빈자리'], 86, true),
('singer_sung_si_kyung', '성시경', 'Sung Si-kyung', '성시경', 'singer', 'male', '1979-04-17', NULL, 'A', false, NULL, '발라드 가수', ARRAY['성시경', '발라드', '두사람', '거리에서'], 88, true),
('singer_lee_sun_hee', '이선희', 'Lee Sun-hee', '이선희', 'singer', 'female', '1964-03-06', NULL, 'O', false, NULL, '가수, 국민가수', ARRAY['이선희', '발라드', '인연'], 85, true),

-- 힙합/인디
('singer_heize', '헤이즈', 'Heize', '장다혜', 'singer', 'female', '1991-08-09', 'INFP', 'A', false, NULL, '싱어송라이터, 래퍼', ARRAY['헤이즈', 'Heize', '장다혜', '비도오고그래서'], 90, true),
('singer_bol4', '볼빨간사춘기', 'BOL4', '안지영', 'singer', 'female', '1995-09-06', NULL, 'AB', false, NULL, '싱어송라이터', ARRAY['볼빨간사춘기', 'BOL4', '안지영', '나만봄'], 88, true),
('singer_iu_akmu_suhyun', '이수현', 'Lee Suhyun', '이수현', 'singer', 'female', '1999-05-04', 'ENFP', 'A', false, NULL, '악동뮤지션 멤버', ARRAY['이수현', 'AKMU', '악동뮤지션', '어떻게이별까지사랑하겠어'], 89, true),
('singer_akmu_chanhyuk', '이찬혁', 'Lee Chanhyuk', '이찬혁', 'singer', 'male', '1996-09-12', 'ENTP', 'O', false, NULL, '악동뮤지션 멤버, 프로듀서', ARRAY['이찬혁', 'AKMU', '악동뮤지션'], 89, true)
ON CONFLICT (id) DO UPDATE SET
  mbti = EXCLUDED.mbti, blood_type = EXCLUDED.blood_type, is_group_member = EXCLUDED.is_group_member, group_name = EXCLUDED.group_name, updated_at = NOW();

-- 삽입 결과 확인
DO $$
DECLARE
    singer_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO singer_count FROM celebrities WHERE category = 'singer' AND is_active = true;
    RAISE NOTICE 'Total active singers: %', singer_count;
END $$;
