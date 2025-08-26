-- Insert initial celebrity data
-- Politicians
INSERT INTO public.celebrities (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords, popularity_score) VALUES
('pol_001', '윤석열', 'Yoon Suk-yeol', 'politician', 'male', '1960-12-18', '14:00', 'https://via.placeholder.com/200/3B82F6/FFFFFF?text=YSY', '대한민국 제20대 대통령', ARRAY['대통령', '정치인', '검찰총장'], 95),
('pol_002', '이재명', 'Lee Jae-myung', 'politician', 'male', '1964-12-22', '10:30', 'https://via.placeholder.com/200/EF4444/FFFFFF?text=LJM', '더불어민주당 대표', ARRAY['정치인', '경기도지사', '성남시장'], 90),
('pol_003', '한동훈', 'Han Dong-hoon', 'politician', 'male', '1973-04-15', '09:00', 'https://via.placeholder.com/200/10B981/FFFFFF?text=HDH', '국민의힘 대표', ARRAY['정치인', '법무부장관', '검사'], 85);

-- Actors
INSERT INTO public.celebrities (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords, popularity_score) VALUES
('act_001', '송중기', 'Song Joong-ki', 'actor', 'male', '1985-09-19', '15:30', 'https://via.placeholder.com/200/9B59B6/FFFFFF?text=SJK', '대한민국의 배우', ARRAY['배우', '태양의후예', '승리호'], 92),
('act_002', '손예진', 'Son Ye-jin', 'actor', 'female', '1982-01-11', '11:20', 'https://via.placeholder.com/200/E91E63/FFFFFF?text=SYJ', '대한민국의 배우', ARRAY['배우', '사랑의불시착', '경성크리처'], 90),
('act_003', '박서준', 'Park Seo-joon', 'actor', 'male', '1988-12-16', '14:45', 'https://via.placeholder.com/200/3F51B5/FFFFFF?text=PSJ', '대한민국의 배우', ARRAY['배우', '이태원클라쓰', '기생충'], 88),
('act_004', '김태희', 'Kim Tae-hee', 'actor', 'female', '1980-03-29', '09:15', 'https://via.placeholder.com/200/FF9800/FFFFFF?text=KTH', '대한민국의 배우', ARRAY['배우', '천국의계단', '하이바이마마'], 85),
('act_005', '현빈', 'Hyun Bin', 'actor', 'male', '1982-09-25', '16:00', 'https://via.placeholder.com/200/4CAF50/FFFFFF?text=HB', '대한민국의 배우', ARRAY['배우', '사랑의불시착', '시크릿가든'], 87);

-- Singers
INSERT INTO public.celebrities (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords, popularity_score) VALUES
('sing_001', 'IU', 'IU', 'singer', 'female', '1993-05-16', '12:30', 'https://via.placeholder.com/200/E91E63/FFFFFF?text=IU', '대한민국의 가수, 배우', ARRAY['가수', 'IU', '아이유', '호텔델루나'], 98),
('sing_002', 'G-Dragon', 'G-Dragon', 'singer', 'male', '1988-08-18', '13:45', 'https://via.placeholder.com/200/FF5722/FFFFFF?text=GD', 'BIGBANG 멤버, 래퍼', ARRAY['가수', '래퍼', 'BIGBANG', '지드래곤'], 95),
('sing_003', '태연', 'Taeyeon', 'singer', 'female', '1989-03-09', '10:15', 'https://via.placeholder.com/200/9C27B0/FFFFFF?text=TY', '소녀시대 멤버, 솔로가수', ARRAY['가수', '소녀시대', '태연', '솔로'], 93),
('sing_004', 'BTS', 'BTS', 'singer', 'male', '2013-06-13', '00:00', 'https://via.placeholder.com/200/673AB7/FFFFFF?text=BTS', '대한민국의 7인조 보이그룹', ARRAY['가수', 'BTS', '방탄소년단', '아이돌'], 100),
('sing_005', 'NewJeans', 'NewJeans', 'singer', 'female', '2022-07-22', '00:00', 'https://via.placeholder.com/200/E91E63/FFFFFF?text=NJ', '대한민국의 5인조 걸그룹', ARRAY['가수', 'NewJeans', '뉴진스', '아이돌'], 96);

-- Athletes
INSERT INTO public.celebrities (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords, popularity_score) VALUES
('ath_001', '손흥민', 'Son Heung-min', 'athlete', 'male', '1992-07-08', '14:30', 'https://via.placeholder.com/200/4CAF50/FFFFFF?text=SHM', '대한민국의 축구선수', ARRAY['축구', '토트넘', '손흥민', '프리미어리그'], 97),
('ath_002', '김연아', 'Kim Yuna', 'athlete', 'female', '1990-09-05', '11:45', 'https://via.placeholder.com/200/03A9F4/FFFFFF?text=KYA', '대한민국의 전 피겨스케이팅 선수', ARRAY['피겨스케이팅', '김연아', '올림픽', '금메달'], 94),
('ath_003', '박지성', 'Park Ji-sung', 'athlete', 'male', '1981-02-25', '16:20', 'https://via.placeholder.com/200/FF5722/FFFFFF?text=PJS', '대한민국의 전 축구선수', ARRAY['축구', '맨유', '박지성', '레전드'], 90),
('ath_004', '류현진', 'Ryu Hyun-jin', 'athlete', 'male', '1987-03-25', '13:15', 'https://via.placeholder.com/200/795548/FFFFFF?text=RHJ', '대한민국의 야구선수', ARRAY['야구', 'MLB', '류현진', '투수'], 88);

-- Entertainers
INSERT INTO public.celebrities (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords, popularity_score) VALUES
('ent_001', '유재석', 'Yoo Jae-suk', 'entertainer', 'male', '1972-08-14', '15:00', 'https://via.placeholder.com/200/FF9800/FFFFFF?text=YJS', '대한민국의 방송인, 개그맨', ARRAY['방송인', '개그맨', '런닝맨', '국민MC'], 98),
('ent_002', '강호동', 'Kang Ho-dong', 'entertainer', 'male', '1970-06-11', '12:30', 'https://via.placeholder.com/200/FF5722/FFFFFF?text=KHD', '대한민국의 방송인, 개그맨', ARRAY['방송인', '개그맨', '신서유기', '1박2일'], 92),
('ent_003', '박나래', 'Park Na-rae', 'entertainer', 'female', '1985-10-25', '14:45', 'https://via.placeholder.com/200/E91E63/FFFFFF?text=PNR', '대한민국의 방송인, 개그맨', ARRAY['방송인', '개그맨', '코미디빅리그', '나혼자산다'], 89);

-- YouTubers/Streamers  
INSERT INTO public.celebrities (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords, popularity_score) VALUES
('you_001', '쯔양', 'Tzuyang', 'youtuber', 'female', '1992-01-01', '12:00', 'https://via.placeholder.com/200/FF5722/FFFFFF?text=TZ', '대한민국의 먹방 유튜버', ARRAY['유튜버', '먹방', '쯔양', '푸드'], 91),
('you_002', '침착맨', 'ChimChakMan', 'youtuber', 'male', '1990-01-01', '15:30', 'https://via.placeholder.com/200/607D8B/FFFFFF?text=CCM', '대한민국의 유튜버, 스트리머', ARRAY['유튜버', '스트리머', '침착맨', '게임'], 87),
('str_001', '풍월량', 'Poongwolryang', 'streamer', 'male', '1985-01-01', '20:00', 'https://via.placeholder.com/200/9C27B0/FFFFFF?text=PWR', '대한민국의 스트리머', ARRAY['스트리머', '풍월량', 'BJ', '아프리카TV'], 85);

-- Pro Gamers
INSERT INTO public.celebrities (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords, popularity_score) VALUES
('pro_001', 'Faker', 'Faker', 'pro_gamer', 'male', '1996-05-07', '16:45', 'https://via.placeholder.com/200/FFD700/FFFFFF?text=F', 'T1 소속 리그 오브 레전드 프로게이머', ARRAY['프로게이머', 'Faker', 'T1', 'LoL'], 96),
('pro_002', '임요환', 'Lim Yo-hwan', 'pro_gamer', 'male', '1980-09-04', '14:20', 'https://via.placeholder.com/200/8BC34A/FFFFFF?text=LYH', '대한민국의 전 프로게이머', ARRAY['프로게이머', '임요환', '슬레이어스', '스타크래프트'], 89);

-- Business Leaders
INSERT INTO public.celebrities (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords, popularity_score) VALUES
('bus_001', '이재용', 'Lee Jae-yong', 'business_leader', 'male', '1968-06-23', '11:30', 'https://via.placeholder.com/200/2196F3/FFFFFF?text=LJY', '삼성전자 회장', ARRAY['기업인', '삼성', '이재용', '회장'], 88),
('bus_002', '정의선', 'Chung Euisun', 'business_leader', 'male', '1970-10-18', '09:45', 'https://via.placeholder.com/200/795548/FFFFFF?text=JES', '현대자동차그룹 회장', ARRAY['기업인', '현대', '정의선', '자동차'], 82);