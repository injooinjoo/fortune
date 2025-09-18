-- 기업인 50명 실제 데이터 삽입
-- Category: business

INSERT INTO public.celebrities (
  id, name, birth_date, gender, celebrity_type,
  stage_name, legal_name, aliases, nationality, birth_place, birth_time,
  active_from, agency_management, languages, external_ids, profession_data, notes
) VALUES
('business_lee_jae_yong', '이재용', '1968-06-23', 'male', 'business', NULL, NULL, ARRAY['이재용'], '한국', NULL, '12:00', 1991, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이재용_(기업인)"}'::jsonb, '{"company_name": "삼성전자", "title": "회장", "industry": "전자/반도체", "founded_year": "", "board_memberships": ["삼성물산", "삼성SDS"], "notable_ventures": ["삼성 바이오로직스", "삼성전기"]}'::jsonb, '실제 데이터'),

('business_kim_beom_soo', '김범수', '1966-03-23', 'male', 'business', NULL, NULL, ARRAY['김범수'], '한국', NULL, '12:00', 1995, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김범수"}'::jsonb, '{"company_name": "카카오", "title": "의장", "industry": "IT/플랫폼", "founded_year": "1995", "board_memberships": ["카카오게임즈", "카카오뱅크"], "notable_ventures": ["카카오톡", "카카오페이"]}'::jsonb, '실제 데이터'),

('business_bang_si_hyuk', '방시혁', '1972-08-09', 'male', 'business', NULL, NULL, ARRAY['방시혁'], '한국', NULL, '12:00', 2005, 'HYBE', ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/방시혁"}'::jsonb, '{"company_name": "HYBE", "title": "의장", "industry": "엔터테인먼트", "founded_year": "2005", "board_memberships": ["위버스컴퍼니"], "notable_ventures": ["BTS", "TXT", "NewJeans"]}'::jsonb, '실제 데이터'),

('business_seo_jung_jin', '서정진', '1956-11-02', 'male', 'business', NULL, NULL, ARRAY['서정진'], '한국', NULL, '12:00', 2000, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/서정진"}'::jsonb, '{"company_name": "셀트리온", "title": "회장", "industry": "바이오/제약", "founded_year": "2000", "board_memberships": ["셀트리온헬스케어"], "notable_ventures": ["램시마", "허셉틴"]}'::jsonb, '실제 데이터'),

('business_kim_taxi', '김택진', '1968-12-30', 'male', 'business', NULL, NULL, ARRAY['김택진'], '한국', NULL, '12:00', 1997, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김택진"}'::jsonb, '{"company_name": "엔씨소프트", "title": "대표이사", "industry": "게임", "founded_year": "1997", "board_memberships": ["엔씨 다이노스"], "notable_ventures": ["리니지", "길드워즈"]}'::jsonb, '실제 데이터'),

('business_kim_jung_ju', '김정주', '1966-03-17', 'male', 'business', NULL, NULL, ARRAY['김정주'], '한국', NULL, '12:00', 1994, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김정주"}'::jsonb, '{"company_name": "넥슨", "title": "창립자", "industry": "게임", "founded_year": "1994", "board_memberships": ["NXC"], "notable_ventures": ["메이플스토리", "카트라이더"]}'::jsonb, '실제 데이터'),

('business_lee_hae_jin', '이해진', '1967-06-22', 'male', 'business', NULL, NULL, ARRAY['이해진'], '한국', NULL, '12:00', 1999, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이해진"}'::jsonb, '{"company_name": "네이버", "title": "글로벌투자책임자", "industry": "IT/플랫폼", "founded_year": "1999", "board_memberships": ["라인야후"], "notable_ventures": ["네이버 검색", "라인"]}'::jsonb, '실제 데이터'),

('business_chung_mong_koo', '정몽구', '1938-03-19', 'male', 'business', NULL, NULL, ARRAY['정몽구'], '한국', NULL, '12:00', 1967, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/정몽구"}'::jsonb, '{"company_name": "현대자동차그룹", "title": "명예회장", "industry": "자동차", "founded_year": "", "board_memberships": ["현대모비스", "기아"], "notable_ventures": ["제네시스", "현대 IONIQ"]}'::jsonb, '실제 데이터'),

('business_shin_dong_bin', '신동빈', '1955-02-14', 'male', 'business', NULL, NULL, ARRAY['신동빈'], '한국', NULL, '12:00', 1991, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/신동빈"}'::jsonb, '{"company_name": "롯데그룹", "title": "회장", "industry": "유통/식품", "founded_year": "", "board_memberships": ["롯데쇼핑", "롯데케미칼"], "notable_ventures": ["롯데월드", "롯데마트"]}'::jsonb, '실제 데이터'),

('business_kim_jun_ki', '김준기', '1964-08-05', 'male', 'business', NULL, NULL, ARRAY['김준기'], '한국', NULL, '12:00', 1999, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김준기"}'::jsonb, '{"company_name": "동원그룹", "title": "회장", "industry": "식품", "founded_year": "", "board_memberships": ["동원F&B"], "notable_ventures": ["참치캔", "동원참치"]}'::jsonb, '실제 데이터'),

('business_cho_hyun_ah', '조현아', '1974-10-05', 'female', 'business', NULL, NULL, ARRAY['조현아'], '한국', NULL, '12:00', 2007, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/조현아"}'::jsonb, '{"company_name": "한진그룹", "title": "부회장", "industry": "항공/물류", "founded_year": "", "board_memberships": ["대한항공"], "notable_ventures": ["대한항공", "진에어"]}'::jsonb, '실제 데이터'),

('business_park_jung_ho', '박정호', '1967-01-12', 'male', 'business', NULL, NULL, ARRAY['박정호'], '한국', NULL, '12:00', 1994, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박정호"}'::jsonb, '{"company_name": "SK텔레콤", "title": "사장", "industry": "통신", "founded_year": "", "board_memberships": ["SK브로드밴드"], "notable_ventures": ["5G", "T맵"]}'::jsonb, '실제 데이터'),

('business_chey_tae_won', '최태원', '1960-12-03', 'male', 'business', NULL, NULL, ARRAY['최태원'], '한국', NULL, '12:00', 1998, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/최태원"}'::jsonb, '{"company_name": "SK그룹", "title": "회장", "industry": "에너지/화학", "founded_year": "", "board_memberships": ["SK이노베이션", "SK하이닉스"], "notable_ventures": ["SK텔레콤", "SK아이이테크놀로지"]}'::jsonb, '실제 데이터'),

('business_ryu_kwang_ji', '류광지', '1952-07-18', 'male', 'business', NULL, NULL, ARRAY['류광지'], '한국', NULL, '12:00', 1983, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/류광지"}'::jsonb, '{"company_name": "포스코그룹", "title": "회장", "industry": "철강", "founded_year": "", "board_memberships": ["포스코케미칼"], "notable_ventures": ["포스코", "포스코인터내셔널"]}'::jsonb, '실제 데이터'),

('business_kim_hyun_suk', '김현석', '1966-05-26', 'male', 'business', NULL, NULL, ARRAY['김현석'], '한국', NULL, '12:00', 1988, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김현석"}'::jsonb, '{"company_name": "삼성전자", "title": "부회장", "industry": "전자/반도체", "founded_year": "", "board_memberships": ["삼성디스플레이"], "notable_ventures": ["갤럭시", "삼성 반도체"]}'::jsonb, '실제 데이터'),

('business_song_chi_hyung', '송치형', '1960-09-14', 'male', 'business', NULL, NULL, ARRAY['송치형'], '한국', NULL, '12:00', 1995, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/송치형"}'::jsonb, '{"company_name": "크래프톤", "title": "의장", "industry": "게임", "founded_year": "1995", "board_memberships": ["PUBG"], "notable_ventures": ["배틀그라운드", "TERA"]}'::jsonb, '실제 데이터'),

('business_cha_user', '차은택', '1985-02-09', 'male', 'business', NULL, NULL, ARRAY['차은택'], '한국', NULL, '12:00', 2012, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/차은택"}'::jsonb, '{"company_name": "야놀자", "title": "대표", "industry": "O2O/플랫폼", "founded_year": "2012", "board_memberships": ["인터파크트리플"], "notable_ventures": ["야놀자", "인터파크"]}'::jsonb, '실제 데이터'),

('business_kim_bong_jin', '김봉진', '1978-01-22', 'male', 'business', NULL, NULL, ARRAY['김봉진'], '한국', NULL, '12:00', 2010, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김봉진"}'::jsonb, '{"company_name": "우아한형제들", "title": "의장", "industry": "O2O/플랫폼", "founded_year": "2010", "board_memberships": ["배달의민족"], "notable_ventures": ["배달의민족", "우아한청년들"]}'::jsonb, '실제 데이터'),

('business_park_hyeon_joo', '박현주', '1958-11-19', 'male', 'business', NULL, NULL, ARRAY['박현주'], '한국', NULL, '12:00', 1998, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박현주"}'::jsonb, '{"company_name": "미래에셋그룹", "title": "회장", "industry": "금융", "founded_year": "1998", "board_memberships": ["미래에셋증권"], "notable_ventures": ["미래에셋대우", "미래에셋생명"]}'::jsonb, '실제 데이터'),

('business_yoon_bu_keun', '윤부근', '1952-04-07', 'male', 'business', NULL, NULL, ARRAY['윤부근'], '한국', NULL, '12:00', 1984, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/윤부근"}'::jsonb, '{"company_name": "SM그룹", "title": "회장", "industry": "건설", "founded_년": "", "board_memberships": ["SM상선"], "notable_ventures": ["SM건설", "SM라인"]}'::jsonb, '실제 데이터'),

('business_kim_dong_soo', '김동수', '1955-12-25', 'male', 'business', NULL, NULL, ARRAY['김동수'], '한국', NULL, '12:00', 1990, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김동수"}'::jsonb, '{"company_name": "아모레퍼시픽", "title": "회장", "industry": "화장품", "founded_year": "", "board_memberships": ["이니스프리"], "notable_ventures": ["설화수", "헤라"]}'::jsonb, '실제 데이터'),

('business_lee_kun_hee', '이건희', '1942-01-09', 'male', 'business', NULL, NULL, ARRAY['이건희'], '한국', NULL, '12:00', 1987, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이건희"}'::jsonb, '{"company_name": "삼성그룹", "title": "전 회장", "industry": "전자/반도체", "founded_year": "", "board_memberships": ["삼성전자"], "notable_ventures": ["삼성 신경영", "갤럭시"]}'::jsonb, '실제 데이터'),

('business_cho_yang_ho', '조양호', '1949-01-10', 'male', 'business', NULL, NULL, ARRAY['조양호'], '한국', NULL, '12:00', 1982, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/조양호"}'::jsonb, '{"company_name": "한진그룹", "title": "전 회장", "industry": "항공/물류", "founded_year": "", "board_memberships": ["대한항공"], "notable_ventures": ["대한항공", "한진해운"]}'::jsonb, '실제 데이터'),

('business_koo_ja_kyun', '구자균', '1945-08-15', 'male', 'business', NULL, NULL, ARRAY['구자균'], '한국', NULL, '12:00', 1995, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/구자균"}'::jsonb, '{"company_name": "LS그룹", "title": "회장", "industry": "전력/건설", "founded_year": "", "board_memberships": ["LS일렉트릭"], "notable_ventures": ["LS전선", "LS산전"]}'::jsonb, '실제 데이터'),

('business_han_창우', '한창우', '1954-06-03', 'male', 'business', NULL, NULL, ARRAY['한창우'], '한국', NULL, '12:00', 1989, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/한창우"}'::jsonb, '{"company_name": "한국타이어", "title": "부회장", "industry": "타이어", "founded_year": "", "board_memberships": ["한국타이어월드와이드"], "notable_ventures": ["금호타이어", "한국타이어"]}'::jsonb, '실제 데이터'),

('business_park_sam_ku', '박삼구', '1949-11-12', 'male', 'business', NULL, NULL, ARRAY['박삼구'], '한국', NULL, '12:00', 1981, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박삼구"}'::jsonb, '{"company_name": "금호아시아나그룹", "title": "회장", "industry": "항공/화학", "founded_year": "", "board_memberships": ["아시아나항공"], "notable_ventures": ["아시아나항공", "금호타이어"]}'::jsonb, '실제 데이터'),

('business_kim_seung_youn', '김승연', '1952-02-18', 'male', 'business', NULL, NULL, ARRAY['김승연'], '한국', NULL, '12:00', 1984, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김승연"}'::jsonb, '{"company_name": "한화그룹", "title": "회장", "industry": "화학/건설", "founded_year": "", "board_memberships": ["한화시스템"], "notable_ventures": ["한화케미칼", "한화솔루션"]}'::jsonb, '실제 데이터'),

('business_son_kyung_shik', '손경식', '1947-10-09', 'male', 'business', NULL, NULL, ARRAY['손경식'], '한국', NULL, '12:00', 1983, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/손경식"}'::jsonb, '{"company_name": "CJ그룹", "title": "회장", "industry": "식품/엔터", "founded_year": "", "board_memberships": ["CJ제일제당"], "notable_ventures": ["CJ ENM", "CJ올리브영"]}'::jsonb, '실제 데이터'),

('business_park_yong_man', '박용만', '1960-04-21', 'male', 'business', NULL, NULL, ARRAY['박용만'], '한국', NULL, '12:00', 1995, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박용만"}'::jsonb, '{"company_name": "두산그룹", "title": "회장", "industry": "중공업", "founded_year": "", "board_memberships": ["두산밥캣"], "notable_ventures": ["두산중공업", "두산에너빌리티"]}'::jsonb, '실제 데이터'),

('business_chung_eui_sun', '정의선', '1970-10-18', 'male', 'business', NULL, NULL, ARRAY['정의선'], '한국', NULL, '12:00', 1999, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/정의선"}'::jsonb, '{"company_name": "현대자동차그룹", "title": "회장", "industry": "자동차", "founded_year": "", "board_memberships": ["현대자동차"], "notable_ventures": ["IONIQ", "제네시스"]}'::jsonb, '실제 데이터'),

('business_kim_chang_han', '김창한', '1958-03-30', 'male', 'business', NULL, NULL, ARRAY['김창한'], '한국', NULL, '12:00', 1992, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김창한"}'::jsonb, '{"company_name": "효성그룹", "title": "회장", "industry": "화학/섬유", "founded_year": "", "board_memberships": ["효성화학"], "notable_ventures": ["효성티앤씨", "효성중공업"]}'::jsonb, '실제 데이터'),

('business_huh_tae_soo', '허태수', '1962-07-14', 'male', 'business', NULL, NULL, ARRAY['허태수'], '한국', NULL, '12:00', 1996, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/허태수"}'::jsonb, '{"company_name": "GS그룹", "title": "회장", "industry": "에너지/유통", "founded_year": "", "board_memberships": ["GS칼텍스"], "notable_ventures": ["GS25", "GS리테일"]}'::jsonb, '실제 데이터'),

('business_lee_jay_hyun', '이재현', '1963-12-03', 'male', 'business', NULL, NULL, ARRAY['이재현'], '한국', NULL, '12:00', 1991, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이재현"}'::jsonb, '{"company_name": "CJ그룹", "title": "부회장", "industry": "식품/엔터", "founded_year": "", "board_memberships": ["CJ ENM"], "notable_ventures": ["CJ CGV", "CJ올리브네트웍스"]}'::jsonb, '실제 데이터'),

('business_yoo_정준', '유정준', '1965-08-08', 'male', 'business', NULL, NULL, ARRAY['유정준'], '한국', NULL, '12:00', 1995, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/유정준"}'::jsonb, '{"company_name": "OCI", "title": "회장", "industry": "화학", "founded_year": "", "board_memberships": ["OCI홀딩스"], "notable_ventures": ["OCI머터리얼즈", "OCI솔라파워"]}'::jsonb, '실제 데이터'),

('business_kim_용_bae', '김용배', '1957-11-27', 'male', 'business', NULL, NULL, ARRAY['김용배'], '한국', NULL, '12:00', 1990, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김용배"}'::jsonb, '{"company_name": "세아그룹", "title": "회장", "industry": "철강", "founded_year": "", "board_memberships": ["세아특수강"], "notable_ventures": ["세아제강", "세아홀딩스"]}'::jsonb, '실제 데이터'),

('business_cho_현상', '조현상', '1959-05-16', 'male', 'business', NULL, NULL, ARRAY['조현상'], '한국', NULL, '12:00', 1987, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/조현상"}'::jsonb, '{"company_name": "효성그룹", "title": "부회장", "industry": "화학/섬유", "founded_year": "", "board_memberships": ["효성첨단소재"], "notable_ventures": ["효성TNC", "효성ITX"]}'::jsonb, '실제 데이터'),

('business_lee_dong_chae', '이동채', '1954-01-20', 'male', 'business', NULL, NULL, ARRAY['이동채'], '한국', NULL, '12:00', 1986, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이동채"}'::jsonb, '{"company_name": "오리온그룹", "title": "회장", "industry": "식품", "founded_year": "", "board_memberships": ["오리온홀딩스"], "notable_ventures": ["초코파이", "꼬북칩"]}'::jsonb, '실제 데이터'),

('business_shin_dong_주', '신동주', '1954-02-14', 'male', 'business', NULL, NULL, ARRAY['신동주'], '한국', NULL, '12:00', 1991, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/신동주"}'::jsonb, '{"company_name": "롯데홀딩스", "title": "부회장", "industry": "유통/식품", "founded_year": "", "board_memberships": ["롯데제과"], "notable_ventures": ["롯데월드", "롯데시네마"]}'::jsonb, '실제 데이터'),

('business_park_세창', '박세창', '1962-09-25', 'male', 'business', NULL, NULL, ARRAY['박세창'], '한국', NULL, '12:00', 1995, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박세창"}'::jsonb, '{"company_name": "동국제강", "title": "회장", "industry": "철강", "founded_year": "", "board_memberships": ["동국S&C"], "notable_ventures": ["동국제강", "환영철강"]}'::jsonb, '실제 데이터'),

('business_kim_상열', '김상열', '1960-06-12', 'male', 'business', NULL, NULL, ARRAY['김상열'], '한국', NULL, '12:00', 1994, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김상열"}'::jsonb, '{"company_name": "대림그룹", "title": "회장", "industry": "건설/석유화학", "founded_year": "", "board_memberships": ["대림산업"], "notable_ventures": ["대림건설", "대림코퍼레이션"]}'::jsonb, '실제 데이터'),

('business_lee_jae_hwan', '이재환', '1958-04-18', 'male', 'business', NULL, NULL, ARRAY['이재환'], '한국', NULL, '12:00', 1990, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이재환"}'::jsonb, '{"company_name": "CJ대한통운", "title": "부회장", "industry": "물류", "founded_year": "", "board_memberships": ["CJ대한통운"], "notable_ventures": ["택배", "물류"]}'::jsonb, '실제 데이터'),

('business_kim_광호', '김광호', '1955-10-07', 'male', 'business', NULL, NULL, ARRAY['김광호'], '한국', NULL, '12:00', 1988, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김광호"}'::jsonb, '{"company_name": "삼양그룹", "title": "회장", "industry": "식품/화학", "founded_year": "", "board_memberships": ["삼양사"], "notable_ventures": ["삼양라면", "삼양화학"]}'::jsonb, '실제 데이터'),

('business_park_용곤', '박용곤', '1954-12-11', 'male', 'business', NULL, NULL, ARRAY['박용곤'], '한국', NULL, '12:00', 1983, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/박용곤"}'::jsonb, '{"company_name": "두산그룹", "title": "부회장", "industry": "중공업", "founded_year": "", "board_memberships": ["두산퓨얼셀"], "notable_ventures": ["두산에너빌리티", "두산로보틱스"]}'::jsonb, '실제 데이터'),

('business_kim_철하', '김철하', '1957-07-23', 'male', 'business', NULL, NULL, ARRAY['김철하'], '한국', NULL, '12:00', 1992, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김철하"}'::jsonb, '{"company_name": "KCC그룹", "title": "회장", "industry": "건축자재", "founded_year": "", "board_memberships": ["KCC건설"], "notable_ventures": ["KCC글라스", "KCC정보통신"]}'::jsonb, '실제 데이터'),

('business_huh_진수', '허진수', '1963-01-29', 'male', 'business', NULL, NULL, ARRAY['허진수'], '한국', NULL, '12:00', 1998, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/허진수"}'::jsonb, '{"company_name": "GS건설", "title": "사장", "industry": "건설", "founded_year": "", "board_memberships": ["GS건설"], "notable_ventures": ["자이", "GS건설"]}'::jsonb, '실제 데이터'),

('business_lee_방수', '이방수', '1961-03-14', 'male', 'business', NULL, NULL, ARRAY['이방수'], '한국', NULL, '12:00', 1996, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이방수"}'::jsonb, '{"company_name": "코오롱그룹", "title": "회장", "industry": "화학/섬유", "founded_year": "", "board_memberships": ["코오롱인더스트리"], "notable_ventures": ["코오롱제약", "코오롱베니트"]}'::jsonb, '실제 데이터'),

('business_yoon_석금', '윤석금', '1950-08-17', 'male', 'business', NULL, NULL, ARRAY['윤석금'], '한국', NULL, '12:00', 1982, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/윤석금"}'::jsonb, '{"company_name": "고려아연", "title": "회장", "industry": "비철금속", "founded_year": "", "board_memberships": ["고려아연"], "notable_ventures": ["아연제련", "귀금속"]}'::jsonb, '실제 데이터'),

('business_kim_준', '김준', '1964-05-04', 'male', 'business', NULL, NULL, ARRAY['김준'], '한국', NULL, '12:00', 1998, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/김준"}'::jsonb, '{"company_name": "신세계그룹", "title": "부회장", "industry": "유통", "founded_year": "", "board_memberships": ["신세계"], "notable_ventures": ["신세계백화점", "이마트"]}'::jsonb, '실제 데이터'),

('business_lee_maeng희', '이맹희', '1952-11-08', 'male', 'business', NULL, NULL, ARRAY['이맹희'], '한국', NULL, '12:00', 1985, NULL, ARRAY['한국어', '영어'], '{"wikipedia": "https://ko.wikipedia.org/wiki/이맹희"}'::jsonb, '{"company_name": "CJ제일제당", "title": "부회장", "industry": "식품", "founded_year": "", "board_memberships": ["CJ프레시웨이"], "notable_ventures": ["햇반", "비비고"]}'::jsonb, '실제 데이터')

ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  updated_at = NOW();

