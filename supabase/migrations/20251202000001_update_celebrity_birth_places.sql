-- 연예인 출생지(birth_place) 데이터 업데이트
-- 출생시간은 대부분 공개되지 않아 기본값 12:00 유지
-- 2025-12-02 생성

-- ==========================================
-- BTS 멤버 출생지 업데이트 (7명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 동작구' WHERE id = 'singer_bts_rm';
UPDATE public.celebrities SET birth_place = '경기도 과천시' WHERE id = 'singer_bts_jin';
UPDATE public.celebrities SET birth_place = '대구광역시 북구 태전동' WHERE id = 'singer_bts_suga';
UPDATE public.celebrities SET birth_place = '광주광역시 북구 일곡동' WHERE id = 'singer_bts_jhope';
UPDATE public.celebrities SET birth_place = '부산광역시 금정구 회동동' WHERE id = 'singer_bts_jimin';
UPDATE public.celebrities SET birth_place = '대구광역시 서구 비산동' WHERE id = 'singer_bts_v';
UPDATE public.celebrities SET birth_place = '부산광역시 북구 만덕동' WHERE id = 'singer_bts_jungkook';

-- ==========================================
-- BLACKPINK 멤버 출생지 업데이트 (4명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 군포시 산본동' WHERE id = 'singer_bp_jisoo';
UPDATE public.celebrities SET birth_place = '경기도 성남시 분당구' WHERE id = 'singer_bp_jennie';
UPDATE public.celebrities SET birth_place = '뉴질랜드 오클랜드' WHERE id = 'singer_bp_rose';
UPDATE public.celebrities SET birth_place = '태국 부리람주' WHERE id = 'singer_bp_lisa';

-- ==========================================
-- NewJeans 멤버 출생지 업데이트 (5명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '강원도 영월군' WHERE id = 'singer_nj_minji';
UPDATE public.celebrities SET birth_place = '호주 빅토리아주 멜버른' WHERE id = 'singer_nj_hanni';
UPDATE public.celebrities SET birth_place = '호주 뉴사우스웨일스주 뉴캐슬' WHERE id = 'singer_nj_danielle';
UPDATE public.celebrities SET birth_place = '서울특별시 동작구' WHERE id = 'singer_nj_haerin';
UPDATE public.celebrities SET birth_place = '인천광역시 미추홀구' WHERE id = 'singer_nj_hyein';

-- ==========================================
-- aespa 멤버 출생지 업데이트 (4명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 수원시 팔달구' WHERE id = 'singer_aespa_karina';
UPDATE public.celebrities SET birth_place = '서울특별시 (일본 도쿄 성장)' WHERE id = 'singer_aespa_giselle';
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'singer_aespa_winter';
UPDATE public.celebrities SET birth_place = '중국 헤이룽장성 하얼빈시' WHERE id = 'singer_aespa_ningning';

-- ==========================================
-- IVE 멤버 출생지 업데이트 (6명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '인천광역시 부평구' WHERE id = 'singer_ive_gaeul';
UPDATE public.celebrities SET birth_place = '대전광역시' WHERE id = 'singer_ive_yujin';
UPDATE public.celebrities SET birth_place = '일본 아이치현 나고야시' WHERE id = 'singer_ive_rei';
UPDATE public.celebrities SET birth_place = '서울특별시 용산구 이촌동' WHERE id = 'singer_ive_wonyoung';
UPDATE public.celebrities SET birth_place = '제주특별자치도 제주시 노형동' WHERE id = 'singer_ive_liz';
UPDATE public.celebrities SET birth_place = '서울특별시 서초구 반포동' WHERE id = 'singer_ive_leeseo';

-- ==========================================
-- LE SSERAFIM 멤버 출생지 업데이트 (5명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '일본 가고시마현 가고시마시' WHERE id = 'singer_lsrf_sakura';
UPDATE public.celebrities SET birth_place = '서울특별시 강남구' WHERE id = 'singer_lsrf_chaewon';
UPDATE public.celebrities SET birth_place = '대한민국 (미국 국적)' WHERE id = 'singer_lsrf_yunjin';
UPDATE public.celebrities SET birth_place = '일본 오사카부' WHERE id = 'singer_lsrf_kazuha';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_lsrf_eunchae';

-- ==========================================
-- TWICE 멤버 출생지 업데이트 (9명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_twice_nayeon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_twice_jeongyeon';
UPDATE public.celebrities SET birth_place = '일본 교토부 교타나베시' WHERE id = 'singer_twice_momo';
UPDATE public.celebrities SET birth_place = '일본 오사카부' WHERE id = 'singer_twice_sana';
UPDATE public.celebrities SET birth_place = '경기도 구리시' WHERE id = 'singer_twice_jihyo';
UPDATE public.celebrities SET birth_place = '미국 텍사스주 샌안토니오 (일본 고베 성장)' WHERE id = 'singer_twice_mina';
UPDATE public.celebrities SET birth_place = '경기도 성남시' WHERE id = 'singer_twice_dahyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_twice_chaeyoung';
UPDATE public.celebrities SET birth_place = '대만 타이난시' WHERE id = 'singer_twice_tzuyu';

-- ==========================================
-- Stray Kids 멤버 출생지 업데이트 (8명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '호주 시드니' WHERE id = 'singer_skz_bangchan';
UPDATE public.celebrities SET birth_place = '경기도 김포시' WHERE id = 'singer_skz_leeknow';
UPDATE public.celebrities SET birth_place = '경기도 용인시' WHERE id = 'singer_skz_changbin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_skz_hyunjin';
UPDATE public.celebrities SET birth_place = '인천광역시' WHERE id = 'singer_skz_han';
UPDATE public.celebrities SET birth_place = '호주 시드니' WHERE id = 'singer_skz_felix';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_skz_seungmin';
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'singer_skz_in';

-- ==========================================
-- SEVENTEEN 멤버 출생지 업데이트 (13명)
-- ==========================================
UPDATE public.celebrities SET birth_place = '대구광역시 달서구' WHERE id = 'singer_svt_scoups';
UPDATE public.celebrities SET birth_place = '서울특별시 강북구' WHERE id = 'singer_svt_jeonghan';
UPDATE public.celebrities SET birth_place = '미국 캘리포니아주 로스앤젤레스' WHERE id = 'singer_svt_joshua';
UPDATE public.celebrities SET birth_place = '중국 광둥성 선전시' WHERE id = 'singer_svt_jun';
UPDATE public.celebrities SET birth_place = '경기도 남양주시' WHERE id = 'singer_svt_hoshi';
UPDATE public.celebrities SET birth_place = '경상남도 창원시' WHERE id = 'singer_svt_wonwoo';
UPDATE public.celebrities SET birth_place = '부산광역시 수영구' WHERE id = 'singer_svt_woozi';
UPDATE public.celebrities SET birth_place = '경기도 고양시' WHERE id = 'singer_svt_dk';
UPDATE public.celebrities SET birth_place = '경기도 안양시' WHERE id = 'singer_svt_mingyu';
UPDATE public.celebrities SET birth_place = '중국 랴오닝성 안산시' WHERE id = 'singer_svt_the8';
UPDATE public.celebrities SET birth_place = '제주특별자치도 서귀포시' WHERE id = 'singer_svt_seungkwan';
UPDATE public.celebrities SET birth_place = '미국 뉴욕주 맨해튼' WHERE id = 'singer_svt_vernon';
UPDATE public.celebrities SET birth_place = '전라북도 익산시' WHERE id = 'singer_svt_dino';

-- ==========================================
-- EXO 멤버 출생지 (기존 데이터가 있다면)
-- ==========================================
-- EXO 멤버 ID가 없으면 이 섹션은 무시됨
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_exo_suho';
UPDATE public.celebrities SET birth_place = '경기도 부천시' WHERE id = 'singer_exo_baekhyun';
UPDATE public.celebrities SET birth_place = '서울특별시 은평구 역촌동' WHERE id = 'singer_exo_chanyeol';
UPDATE public.celebrities SET birth_place = '전라남도 순천시' WHERE id = 'singer_exo_kai';
UPDATE public.celebrities SET birth_place = '경기도 시흥시' WHERE id = 'singer_exo_chen';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_exo_sehun';
UPDATE public.celebrities SET birth_place = '경기도 고양시' WHERE id = 'singer_exo_do';
UPDATE public.celebrities SET birth_place = '서울특별시 구로구' WHERE id = 'singer_exo_xiumin';
UPDATE public.celebrities SET birth_place = '중국 후난성 창사시' WHERE id = 'singer_exo_lay';

-- ==========================================
-- 솔로 가수 출생지 업데이트
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_iu';
UPDATE public.celebrities SET birth_place = '전라북도 전주시' WHERE id = 'singer_taeyeon';
UPDATE public.celebrities SET birth_place = '대한민국 (이탈리아 출생)' WHERE id = 'singer_chungha';
UPDATE public.celebrities SET birth_place = '경기도 이천시' WHERE id = 'singer_sunmi';
UPDATE public.celebrities SET birth_place = '전라남도 해남군' WHERE id = 'singer_hwasa';
UPDATE public.celebrities SET birth_place = '경기도 포천시' WHERE id = 'singer_lim_young_woong';
UPDATE public.celebrities SET birth_place = '경기도 부천시' WHERE id = 'singer_baekhyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_gdragon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_zico';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_crush';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_dean';
UPDATE public.celebrities SET birth_place = '미국 워싱턴주 시애틀' WHERE id = 'singer_jay_park';
UPDATE public.celebrities SET birth_place = '대전광역시' WHERE id = 'singer_song_ga_in';
UPDATE public.celebrities SET birth_place = '충청남도 태안군' WHERE id = 'singer_young_tak';
UPDATE public.celebrities SET birth_place = '충청북도 음성군' WHERE id = 'singer_lee_chan_won';
UPDATE public.celebrities SET birth_place = '전라남도 여수시' WHERE id = 'singer_hong_jin_young';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_jang_yoon_jung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_paul_kim';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_kim_bum_soo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_naul';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_sung_si_kyung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_lee_sun_hee';
UPDATE public.celebrities SET birth_place = '대구광역시' WHERE id = 'singer_heize';
UPDATE public.celebrities SET birth_place = '경기도 화성시' WHERE id = 'singer_bol4';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_iu_akmu_suhyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'singer_akmu_chanhyuk';

-- ==========================================
-- 배우 출생지 업데이트 - 남자 배우
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 성남시' WHERE id = 'actor_lee_byunghun';
UPDATE public.celebrities SET birth_place = '경상남도 김해시' WHERE id = 'actor_song_kangho';
UPDATE public.celebrities SET birth_place = '서울특별시 동작구' WHERE id = 'actor_jung_woosung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_ha_jungwoo';
UPDATE public.celebrities SET birth_place = '경상남도 창원시 마산' WHERE id = 'actor_hwang_jungmin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_lee_jungjae';
UPDATE public.celebrities SET birth_place = '부산광역시 동래구' WHERE id = 'actor_gong_yoo';
UPDATE public.celebrities SET birth_place = '서울특별시 송파구 잠실동' WHERE id = 'actor_hyun_bin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_ma_dongseok';
UPDATE public.celebrities SET birth_place = '대구광역시' WHERE id = 'actor_yoo_ahyin';
UPDATE public.celebrities SET birth_place = '서울특별시 서초구 잠원동' WHERE id = 'actor_jo_seungwoo';
UPDATE public.celebrities SET birth_place = '서울특별시 강동구 명일동' WHERE id = 'actor_jo_insung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_yoo_haejin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_park_seojoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_lee_dohyun';
UPDATE public.celebrities SET birth_place = '경기도 군포시' WHERE id = 'actor_cha_eunwoo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_ahn_hyoseop';
UPDATE public.celebrities SET birth_place = '경기도 부천시' WHERE id = 'actor_byun_wooseok';
UPDATE public.celebrities SET birth_place = '서울특별시 강남구 일원동' WHERE id = 'actor_kim_soohyun';
UPDATE public.celebrities SET birth_place = '대전광역시 동구 세천동' WHERE id = 'actor_song_joongki';
UPDATE public.celebrities SET birth_place = '서울특별시 동작구' WHERE id = 'actor_lee_minho';
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'actor_nam_joohyuk';

-- ==========================================
-- 배우 출생지 업데이트 - 여자 배우
-- ==========================================
UPDATE public.celebrities SET birth_place = '대구광역시 수성구' WHERE id = 'actor_son_yejin';
UPDATE public.celebrities SET birth_place = '서울특별시 강남구 청담동' WHERE id = 'actor_jun_jihyun';
UPDATE public.celebrities SET birth_place = '부산광역시 연제구 (울산 성장)' WHERE id = 'actor_kim_taehee';
UPDATE public.celebrities SET birth_place = '대구광역시 달서구' WHERE id = 'actor_song_hyekyo';
UPDATE public.celebrities SET birth_place = '충청북도 청주시' WHERE id = 'actor_han_hyojoo';
UPDATE public.celebrities SET birth_place = '경기도 성남시 분당구' WHERE id = 'actor_park_shinhye';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_kim_jiwon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_iu';
UPDATE public.celebrities SET birth_place = '경기도 고양시 일산' WHERE id = 'actor_kim_goeun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_shin_minah';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_suzy';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_kim_sohyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_moon_gayoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_kim_yoojung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_park_boyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_han_sohee';
UPDATE public.celebrities SET birth_place = '서울특별시 영등포구' WHERE id = 'actor_jeon_yeobin';
UPDATE public.celebrities SET birth_place = '경기도 고양시' WHERE id = 'actor_go_yoonjung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_kim_hyeyoon';

-- ==========================================
-- 배우 출생지 업데이트 - 남자 배우 추가
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 수원시 팔달구' WHERE id = 'actor_song_kang';
UPDATE public.celebrities SET birth_place = '서울특별시 성북구 성북동' WHERE id = 'actor_kim_sunho';
UPDATE public.celebrities SET birth_place = '전라남도 완도군 소안면' WHERE id = 'actor_wi_hajun';
UPDATE public.celebrities SET birth_place = '서울특별시 동작구 대방동' WHERE id = 'actor_jung_haein';
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'actor_lee_jongseok';
UPDATE public.celebrities SET birth_place = '서울특별시 양천구 목동' WHERE id = 'actor_park_bogum';
UPDATE public.celebrities SET birth_place = '경기도 수원시 매탄동' WHERE id = 'actor_ryu_junyeol';
UPDATE public.celebrities SET birth_place = '서울특별시 (전주 성장)' WHERE id = 'actor_kim_woobin';
UPDATE public.celebrities SET birth_place = '서울특별시 노원구' WHERE id = 'actor_lee_seunggi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_seo_kangjoon';
UPDATE public.celebrities SET birth_place = '서울특별시 도봉구 쌍문동' WHERE id = 'actor_lee_dongwook';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_kim_jaewook';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_yoo_yeonseok';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_jang_dongyun';
UPDATE public.celebrities SET birth_place = '서울특별시 관악구 신림동' WHERE id = 'actor_yeo_jingoo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_hwang_inhyuk';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_kim_youngdae';
UPDATE public.celebrities SET birth_place = '서울특별시 서초구 방배동' WHERE id = 'actor_lee_jaewook';
UPDATE public.celebrities SET birth_place = '충청남도 서천군 한산면' WHERE id = 'actor_sol_kyunggu';
UPDATE public.celebrities SET birth_place = '서울특별시 종로구 이화동' WHERE id = 'actor_choi_minsik';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_jung_woo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_go_kyungpyo';
UPDATE public.celebrities SET birth_place = '경기도 남양주시' WHERE id = 'actor_lee_kwangsoo';
UPDATE public.celebrities SET birth_place = '경기도 안양시' WHERE id = 'actor_ji_changwook';
UPDATE public.celebrities SET birth_place = '부산광역시 대연동' WHERE id = 'actor_kang_haneul';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_joo_jongghyuk';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_oh_jungse';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_kim_namgil';

-- ==========================================
-- 배우 출생지 업데이트 - 여자 배우 추가
-- ==========================================
UPDATE public.celebrities SET birth_place = '부산광역시 동래구 온천동' WHERE id = 'actor_kim_hyesu';
UPDATE public.celebrities SET birth_place = '서울특별시 서대문구 북가좌동' WHERE id = 'actor_jeon_doyeon';
UPDATE public.celebrities SET birth_place = '서울특별시 송파구' WHERE id = 'actor_lee_youngae';
UPDATE public.celebrities SET birth_place = '서울특별시 중랑구 상봉동' WHERE id = 'actor_kim_taeri';
UPDATE public.celebrities SET birth_place = '서울특별시 동작구 흑석동' WHERE id = 'actor_han_jimin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_moon_geunyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_shin_sekyung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_im_yoona';
UPDATE public.celebrities SET birth_place = '서울특별시 종로구' WHERE id = 'actor_bae_doona';
UPDATE public.celebrities SET birth_place = '서울특별시 양천구' WHERE id = 'actor_gong_hyojin';
UPDATE public.celebrities SET birth_place = '인천광역시' WHERE id = 'actor_ra_miran';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_lee_jungeun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_lee_seyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_park_gyuyoung';
UPDATE public.celebrities SET birth_place = '서울특별시 송파구' WHERE id = 'actor_park_eunbin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_jang_nara';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_jung_ryeowon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_go_hyunjung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_han_gain';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_hwang_jungeum';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_nam_jihyun';
UPDATE public.celebrities SET birth_place = '서울특별시 (파주 성장)' WHERE id = 'actor_kim_dahmi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_nana';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_kim_sejeong';
UPDATE public.celebrities SET birth_place = '광주광역시' WHERE id = 'actor_hyeri';
UPDATE public.celebrities SET birth_place = '캐나다 온타리오주 윈저' WHERE id = 'actor_jung_somi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_chae_sobin';
UPDATE public.celebrities SET birth_place = '경기도 고양시' WHERE id = 'actor_lee_sung_kyung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_seo_hyunjin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_jo_boah';
UPDATE public.celebrities SET birth_place = '서울특별시 광진구' WHERE id = 'actor_shin_hyesun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_jun_jihyun2';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_jung_eunji';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'actor_lee_hyeri';

-- ==========================================
-- 정치인 출생지 업데이트 - 역대 대통령
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 성북구 돈암동' WHERE id = 'politician_yoon_seokyoul';
UPDATE public.celebrities SET birth_place = '경상남도 거제군 거제면 명진리' WHERE id = 'politician_moon_jaein';
UPDATE public.celebrities SET birth_place = '대구광역시 중구 삼덕동' WHERE id = 'politician_park_geunhye';
UPDATE public.celebrities SET birth_place = '일본 오사카부' WHERE id = 'politician_lee_myungbak';
UPDATE public.celebrities SET birth_place = '경상남도 김해시 진영읍 봉하마을' WHERE id = 'politician_roh_moohyun';
UPDATE public.celebrities SET birth_place = '전라남도 신안군 하의면 후광리' WHERE id = 'politician_kim_daejung';
UPDATE public.celebrities SET birth_place = '경상남도 거제군 장목면' WHERE id = 'politician_kim_youngsam';
UPDATE public.celebrities SET birth_place = '대구광역시 달성군' WHERE id = 'politician_roh_taewoo';
UPDATE public.celebrities SET birth_place = '경상남도 합천군 율곡면' WHERE id = 'politician_chun_doohwan';
UPDATE public.celebrities SET birth_place = '경상북도 구미시 상모동' WHERE id = 'politician_park_junghee';
UPDATE public.celebrities SET birth_place = '황해도 평산군' WHERE id = 'politician_lee_seungman';

-- ==========================================
-- 정치인 출생지 업데이트 - 현 정치인
-- ==========================================
UPDATE public.celebrities SET birth_place = '경상북도 안동군 예안면 도촌동' WHERE id = 'politician_lee_jaemyung';
UPDATE public.celebrities SET birth_place = '서울특별시 중랑구 중화동' WHERE id = 'politician_han_donghoon';
UPDATE public.celebrities SET birth_place = '부산광역시 서구 동대신동' WHERE id = 'politician_cho_guk';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_oh_sehoon';
UPDATE public.celebrities SET birth_place = '제주특별자치도 제주시' WHERE id = 'politician_won_heeryong';
UPDATE public.celebrities SET birth_place = '전라남도 영광군' WHERE id = 'politician_lee_nakyeon';
UPDATE public.celebrities SET birth_place = '충청남도 공주시' WHERE id = 'politician_jung_jinseok';
UPDATE public.celebrities SET birth_place = '부산광역시 부산진구 범천동' WHERE id = 'politician_ahn_cheolsoo';
UPDATE public.celebrities SET birth_place = '경상남도 창녕군' WHERE id = 'politician_hong_junpyo';
UPDATE public.celebrities SET birth_place = '대구광역시' WHERE id = 'politician_yoo_seungmin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_lee_junseok';
UPDATE public.celebrities SET birth_place = '울산광역시' WHERE id = 'politician_kim_gihuyn';
UPDATE public.celebrities SET birth_place = '전라북도 진안군' WHERE id = 'politician_chung_seykyun';
UPDATE public.celebrities SET birth_place = '전라남도 목포시' WHERE id = 'politician_park_jiewon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_kim_jongmin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_park_yongchin';
UPDATE public.celebrities SET birth_place = '경기도 이천시' WHERE id = 'politician_kim_dongyon';
UPDATE public.celebrities SET birth_place = '울산광역시' WHERE id = 'politician_woo_wonshik';

-- ==========================================
-- 정치인 출생지 업데이트 - 여성 정치인
-- ==========================================
UPDATE public.celebrities SET birth_place = '대전광역시' WHERE id = 'politician_chu_miae';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_na_kyungwon';
UPDATE public.celebrities SET birth_place = '경상북도 달성군' WHERE id = 'politician_sim_sangjung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_ryu_hojung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_kang_kyeonghwa';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_yoo_eunhye';
UPDATE public.celebrities SET birth_place = '광주광역시' WHERE id = 'politician_park_young_sun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_kim_hyunmee';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_jin_sunmee';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_han_junhee';
UPDATE public.celebrities SET birth_place = '서울특별시 송파구' WHERE id = 'politician_bae_hyunjin';

-- ==========================================
-- 정치인 출생지 업데이트 - 독립운동가
-- ==========================================
UPDATE public.celebrities SET birth_place = '황해도 해주 백운방 텃골' WHERE id = 'politician_kim_gu';
UPDATE public.celebrities SET birth_place = '평안남도 강서군 초리면' WHERE id = 'politician_ahn_changho';
UPDATE public.celebrities SET birth_place = '충청남도 예산군 덕산면' WHERE id = 'politician_yun_bonggil';
UPDATE public.celebrities SET birth_place = '서울특별시 용산구' WHERE id = 'politician_lee_bonchang';
UPDATE public.celebrities SET birth_place = '황해도 해주부 광석동' WHERE id = 'politician_ahn_junggeun';
UPDATE public.celebrities SET birth_place = '충청남도 천안시 병천면 용두리' WHERE id = 'politician_yu_gwansun';
UPDATE public.celebrities SET birth_place = '경상남도 밀양시' WHERE id = 'politician_kim_wonbong';
UPDATE public.celebrities SET birth_place = '충청남도 대덕군' WHERE id = 'politician_shin_chaeho';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_lee_hwanyoung';
UPDATE public.celebrities SET birth_place = '전라남도 보성군' WHERE id = 'politician_seo_jaepil';

-- ==========================================
-- 정치인 출생지 업데이트 - 기타 정치인
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_kim_jongin';
UPDATE public.celebrities SET birth_place = '충청남도' WHERE id = 'politician_choi_jaehyung';
UPDATE public.celebrities SET birth_place = '경상북도 영덕군' WHERE id = 'politician_kim_moonsu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_park_wonsoone';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_kim_taekyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_park_jumin';
UPDATE public.celebrities SET birth_place = '충청북도 충주시' WHERE id = 'politician_jung_chunrae';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'politician_jin_sung_jun';
UPDATE public.celebrities SET birth_place = '강원도 강릉시' WHERE id = 'politician_kwon_sunghee';
UPDATE public.celebrities SET birth_place = '대구광역시' WHERE id = 'politician_joo_hoyoung';
UPDATE public.celebrities SET birth_place = '경상북도 경주시' WHERE id = 'politician_choo_hyosun';
UPDATE public.celebrities SET birth_place = '전라북도 익산시' WHERE id = 'politician_kim_jinho';

-- ==========================================
-- 운동선수 출생지 업데이트 - 축구
-- ==========================================
UPDATE public.celebrities SET birth_place = '강원도 춘천시 후평동' WHERE id = 'athlete_son_heungmin';
UPDATE public.celebrities SET birth_place = '인천광역시 남동구 간석동' WHERE id = 'athlete_lee_kangin';
UPDATE public.celebrities SET birth_place = '경상남도 통영시 도천동' WHERE id = 'athlete_kim_minjae';
UPDATE public.celebrities SET birth_place = '강원도 춘천시 후평동' WHERE id = 'athlete_hwang_heechan';
UPDATE public.celebrities SET birth_place = '경기도 전주시' WHERE id = 'athlete_hwang_inbeom';
UPDATE public.celebrities SET birth_place = '전라북도 순창군' WHERE id = 'athlete_cho_gyusung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_jung_wooyoung';
UPDATE public.celebrities SET birth_place = '전라남도 완도군' WHERE id = 'athlete_kim_youngkwon';
UPDATE public.celebrities SET birth_place = '서울특별시 관악구 신림동' WHERE id = 'athlete_park_jisung';
UPDATE public.celebrities SET birth_place = '광주광역시 광산구 임곡동' WHERE id = 'athlete_ki_sungyueng';
UPDATE public.celebrities SET birth_place = '경기도 화성시' WHERE id = 'athlete_cha_bumkun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_hong_myungbo';
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'athlete_lee_youngjae';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_bae_joonho';
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'athlete_jeong_sangbin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_paik_seungho';

-- ==========================================
-- 운동선수 출생지 업데이트 - 야구
-- ==========================================
UPDATE public.celebrities SET birth_place = '인천광역시 동구' WHERE id = 'athlete_ryu_hyunjin';
UPDATE public.celebrities SET birth_place = '일본 아이치현 나고야시' WHERE id = 'athlete_lee_junghu';
UPDATE public.celebrities SET birth_place = '경기도 부천시' WHERE id = 'athlete_kim_haseong';
UPDATE public.celebrities SET birth_place = '충청남도 공주시' WHERE id = 'athlete_park_chanho';
UPDATE public.celebrities SET birth_place = '부산광역시 남구 감만동' WHERE id = 'athlete_choo_shinsoo';
UPDATE public.celebrities SET birth_place = '부산광역시 수영구' WHERE id = 'athlete_lee_daeho';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kang_jungho';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kim_gwanghyun';
UPDATE public.celebrities SET birth_place = '광주광역시 남구' WHERE id = 'athlete_yang_hyunjong';

-- ==========================================
-- 운동선수 출생지 업데이트 - 골프
-- ==========================================
UPDATE public.celebrities SET birth_place = '대전광역시 유성구 (전남 광산군 출생)' WHERE id = 'athlete_park_seri';
UPDATE public.celebrities SET birth_place = '경기도 성남시' WHERE id = 'athlete_park_inbi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_ko_jinyoung';
UPDATE public.celebrities SET birth_place = '경기도 용인시' WHERE id = 'athlete_yang_heeyoung';
UPDATE public.celebrities SET birth_place = '경상남도 창녕군' WHERE id = 'athlete_kim_seiyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_ryu_soyeon';
UPDATE public.celebrities SET birth_place = '경기도 의정부시' WHERE id = 'athlete_shin_jiyai';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_chun_ingi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kim_hyojoo';
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'athlete_lee_jeongsin';

-- ==========================================
-- 운동선수 출생지 업데이트 - 피겨 스케이팅
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 부천시 원미구 도당동' WHERE id = 'athlete_kim_yuna';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_cha_junhwan';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kim_yerim';

-- ==========================================
-- 운동선수 출생지 업데이트 - 수영
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_park_taehwan';
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'athlete_hwang_sunwoo';
UPDATE public.celebrities SET birth_place = '경기도 성남시' WHERE id = 'athlete_kim_womin';

-- ==========================================
-- 운동선수 출생지 업데이트 - 쇼트트랙
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 안양시' WHERE id = 'athlete_hwang_daeheon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_choi_minjung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_park_seunghi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kwak_yoongy';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_shim_seoksee';

-- ==========================================
-- 운동선수 출생지 업데이트 - 배드민턴
-- ==========================================
UPDATE public.celebrities SET birth_place = '전라남도 나주시 이창동' WHERE id = 'athlete_an_seyoung';
UPDATE public.celebrities SET birth_place = '전라남도 화순군' WHERE id = 'athlete_lee_yongdae';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kim_sowoon';

-- ==========================================
-- 운동선수 출생지 업데이트 - 농구
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_lee_daesong';
UPDATE public.celebrities SET birth_place = '경기도 부천시' WHERE id = 'athlete_ha_seungjin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_moon_taejong';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_seo_janghu';

-- ==========================================
-- 운동선수 출생지 업데이트 - 배구
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 안산시' WHERE id = 'athlete_kim_yeonkoung';
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'athlete_kim_heejin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_yang_hyoseon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_lee_jaeyoung';

-- ==========================================
-- 운동선수 출생지 업데이트 - 테니스
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'athlete_chung_hyeon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_lee_hyungtak';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kwon_soonwoo';

-- ==========================================
-- 운동선수 출생지 업데이트 - 유도
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_an_changrim';
UPDATE public.celebrities SET birth_place = '경기도 용인시' WHERE id = 'athlete_an_baul';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kim_jidi';

-- ==========================================
-- 운동선수 출생지 업데이트 - 태권도
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 용인시' WHERE id = 'athlete_lee_daehoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_hwang_kyungseon';

-- ==========================================
-- 운동선수 출생지 업데이트 - 양궁
-- ==========================================
UPDATE public.celebrities SET birth_place = '광주광역시 북구 문흥동' WHERE id = 'athlete_an_san';
UPDATE public.celebrities SET birth_place = '충청남도 청양군' WHERE id = 'athlete_kim_woogjin';
UPDATE public.celebrities SET birth_place = '경상남도 고성군' WHERE id = 'athlete_kim_jeydeok';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_jang_minjung';

-- ==========================================
-- 운동선수 출생지 업데이트 - 사격
-- ==========================================
UPDATE public.celebrities SET birth_place = '강원도 춘천시' WHERE id = 'athlete_jin_jongoh';
UPDATE public.celebrities SET birth_place = '충청북도 단양군' WHERE id = 'athlete_kim_yeji';

-- ==========================================
-- 운동선수 출생지 업데이트 - 역도
-- ==========================================
UPDATE public.celebrities SET birth_place = '강원도 원주시' WHERE id = 'athlete_jang_miyran';

-- ==========================================
-- 운동선수 출생지 업데이트 - 펜싱
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_park_sangnyoung';
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'athlete_kim_jiyeon';
UPDATE public.celebrities SET birth_place = '대전광역시 대덕구' WHERE id = 'athlete_oh_sanguk';

-- ==========================================
-- 운동선수 출생지 업데이트 - 스켈레톤/봅슬레이
-- ==========================================
UPDATE public.celebrities SET birth_place = '경상남도 남해군 이동면' WHERE id = 'athlete_yun_sungbin';

-- ==========================================
-- 운동선수 출생지 업데이트 - 스피드 스케이팅
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 동대문구 장안동' WHERE id = 'athlete_lee_sanghwa';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_kim_minseok';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_lee_seunghi';

-- ==========================================
-- 운동선수 출생지 업데이트 - 컬링
-- ==========================================
UPDATE public.celebrities SET birth_place = '경상북도 의성군' WHERE id = 'athlete_kim_eunjung';
UPDATE public.celebrities SET birth_place = '경상북도 의성군' WHERE id = 'athlete_kim_yeongmi';
UPDATE public.celebrities SET birth_place = '경상북도 의성군' WHERE id = 'athlete_kim_choyhi';

-- ==========================================
-- 운동선수 출생지 업데이트 - 체조
-- ==========================================
UPDATE public.celebrities SET birth_place = '전라북도 고창군 공음면' WHERE id = 'athlete_yang_haksen';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_yeo_seojeong';

-- ==========================================
-- 운동선수 출생지 업데이트 - 근대5종
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_jeon_woongyu';

-- ==========================================
-- 운동선수 출생지 업데이트 - 격투기 (UFC)
-- ==========================================
UPDATE public.celebrities SET birth_place = '전라남도 화순군' WHERE id = 'athlete_kim_donghyun';
UPDATE public.celebrities SET birth_place = '경상북도 포항시' WHERE id = 'athlete_jung_chansung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_choi_duhoo';

-- ==========================================
-- 운동선수 출생지 업데이트 - 탁구
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_roh_sunjin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_lee_sangsu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'athlete_joo_sehyuk';
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'athlete_shin_yubin';

-- ==========================================
-- 방송인 출생지 업데이트 - MC / 예능인 (남성)
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 강북구 수유동' WHERE id = 'entertainer_yoo_jaesuk';
UPDATE public.celebrities SET birth_place = '경상남도 진양군 이반성면 길성리' WHERE id = 'entertainer_kang_hodong';
UPDATE public.celebrities SET birth_place = '충청북도 제천시' WHERE id = 'entertainer_shin_dongyeop';
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'entertainer_lee_kyungkyu';
UPDATE public.celebrities SET birth_place = '전라북도 군산시' WHERE id = 'entertainer_park_myungsoo';
UPDATE public.celebrities SET birth_place = '경기도 이천시' WHERE id = 'entertainer_lee_sugeun';
UPDATE public.celebrities SET birth_place = '대전광역시 동구 천동' WHERE id = 'entertainer_kim_junho';
UPDATE public.celebrities SET birth_place = '독일' WHERE id = 'entertainer_haha';
UPDATE public.celebrities SET birth_place = '경상북도 김천시' WHERE id = 'entertainer_jung_hyungdon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_noh_hongchul';
UPDATE public.celebrities SET birth_place = '충청남도 대덕군' WHERE id = 'entertainer_jung_junha';
UPDATE public.celebrities SET birth_place = '인천광역시' WHERE id = 'entertainer_kim_gura';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_seo_janghoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_tak_jaehoon';
UPDATE public.celebrities SET birth_place = '충청남도 예산군 오가면 역탑리' WHERE id = 'entertainer_baek_jongwon';
UPDATE public.celebrities SET birth_place = '서울특별시 강서구' WHERE id = 'entertainer_jeon_hyunmoo';
UPDATE public.celebrities SET birth_place = '서울특별시 강서구 등촌동' WHERE id = 'entertainer_cho_seho';
UPDATE public.celebrities SET birth_place = '충청남도 보령시 웅천읍' WHERE id = 'entertainer_nam_heeseok';
UPDATE public.celebrities SET birth_place = '서울특별시 마포구 공덕동' WHERE id = 'entertainer_park_suhong';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_boom';
UPDATE public.celebrities SET birth_place = '충청북도 청원군 옥산면 덕촌리' WHERE id = 'entertainer_kim_sungju';
UPDATE public.celebrities SET birth_place = '서울특별시 동대문구' WHERE id = 'entertainer_kim_yongman';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_jang_sunggyu';
UPDATE public.celebrities SET birth_place = '경상남도 합천군' WHERE id = 'entertainer_kim_jongkook';
UPDATE public.celebrities SET birth_place = '서울특별시 강북구 수유동' WHERE id = 'entertainer_ji_sukjin';
UPDATE public.celebrities SET birth_place = '경기도 동두천시 생연동' WHERE id = 'entertainer_yang_sechan';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_hwang_gwanghee';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_sung_sikyung';
UPDATE public.celebrities SET birth_place = '경기도 화성시 비봉면' WHERE id = 'entertainer_ahn_jungwhan';
UPDATE public.celebrities SET birth_place = '충청남도' WHERE id = 'entertainer_jung_jongchul';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_defconn';
UPDATE public.celebrities SET birth_place = '경상북도 영주시' WHERE id = 'entertainer_kim_byungman';
UPDATE public.celebrities SET birth_place = '서울특별시 도봉구 상계동' WHERE id = 'entertainer_yoo_seyoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kim_jongmin';
UPDATE public.celebrities SET birth_place = '서울특별시 중랑구' WHERE id = 'entertainer_munyeong';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kim_daejun';
UPDATE public.celebrities SET birth_place = '전라남도 목포시' WHERE id = 'entertainer_yoo_sangmoo';
UPDATE public.celebrities SET birth_place = '광주광역시' WHERE id = 'entertainer_jo_kwon';
UPDATE public.celebrities SET birth_place = '강원도 횡성군 우천면' WHERE id = 'entertainer_kim_heechul';
UPDATE public.celebrities SET birth_place = '경기도 동두천시' WHERE id = 'entertainer_yang_sehyung';
UPDATE public.celebrities SET birth_place = '부산광역시 서구 아미동' WHERE id = 'entertainer_shin_bora';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_lee_kwangsoo';

-- ==========================================
-- 방송인 출생지 업데이트 - MC / 예능인 (여성)
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 용산구 청파동' WHERE id = 'entertainer_song_euni';
UPDATE public.celebrities SET birth_place = '부산광역시 동래구 거제동' WHERE id = 'entertainer_kim_sook';
UPDATE public.celebrities SET birth_place = '충청남도 태안군 안면도' WHERE id = 'entertainer_lee_youngja';
UPDATE public.celebrities SET birth_place = '전라남도 무안군 일로읍' WHERE id = 'entertainer_park_narae';
UPDATE public.celebrities SET birth_place = '강원도 원주시' WHERE id = 'entertainer_ahn_youngmi';
UPDATE public.celebrities SET birth_place = '전라남도 영광군 법성면 법성리' WHERE id = 'entertainer_jang_doyeon';
UPDATE public.celebrities SET birth_place = '서울특별시 송파구 잠실동' WHERE id = 'entertainer_hong_hyunhee';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_shin_ahyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_hong_jinkyung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_park_sohyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_lee_hyunyi';
UPDATE public.celebrities SET birth_place = '일본 도쿄' WHERE id = 'entertainer_sayuri';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kim_jihye';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_shin_dongyeopw';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kim_jimin';
UPDATE public.celebrities SET birth_place = '경기도 구리시' WHERE id = 'entertainer_song_jihyo';
UPDATE public.celebrities SET birth_place = '경기도 부천시' WHERE id = 'entertainer_jeon_somin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_han_hyejin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kim_sarang';
UPDATE public.celebrities SET birth_place = '서울특별시 용산구 보광동' WHERE id = 'entertainer_park_mison';

-- ==========================================
-- 방송인 출생지 업데이트 - 아나운서 출신
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_oh_sangwook';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_jun_hyunmoo2';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kim_taewoo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kang_jiyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kim_sohyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_son_bumsu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_lee_sora';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_bae_chilsu';

-- ==========================================
-- 방송인 출생지 업데이트 - 기타 방송인
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_park_junhyung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_tony_ahn';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_moon_heejun';
UPDATE public.celebrities SET birth_place = '일본 도쿄' WHERE id = 'entertainer_kangnam';
UPDATE public.celebrities SET birth_place = '호주 멜버른' WHERE id = 'entertainer_sam_hammington';
UPDATE public.celebrities SET birth_place = '이탈리아' WHERE id = 'entertainer_alberto';
UPDATE public.celebrities SET birth_place = '가나' WHERE id = 'entertainer_sam_okyere';
UPDATE public.celebrities SET birth_place = '벨기에' WHERE id = 'entertainer_julian';
UPDATE public.celebrities SET birth_place = '경상남도 거창군 위천면 강천리' WHERE id = 'entertainer_lee_bonggwon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_im_wonhee';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_ji_sangryul';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_lee_sangyoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_hwang_jaesung';
UPDATE public.celebrities SET birth_place = '경기도 화성시' WHERE id = 'entertainer_lee_yongjin';
UPDATE public.celebrities SET birth_place = '경기도 화성시' WHERE id = 'entertainer_jo_junghwan';
UPDATE public.celebrities SET birth_place = '충청남도 천안시' WHERE id = 'entertainer_lee_chanwon';
UPDATE public.celebrities SET birth_place = '경기도 포천시' WHERE id = 'entertainer_im_youngwoong';
UPDATE public.celebrities SET birth_place = '충청남도 단양군' WHERE id = 'entertainer_jang_minho';
UPDATE public.celebrities SET birth_place = '전라북도 익산시' WHERE id = 'entertainer_hong_jinyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_jang_yunjung';
UPDATE public.celebrities SET birth_place = '충청북도 청주시 흥덕구' WHERE id = 'entertainer_lee_hyori';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_song_haena';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_jang_kiha';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_yoo_heeyeol';

-- ==========================================
-- 방송인 출생지 업데이트 - 추가 인물
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_lee_jungi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_kim_eana';
UPDATE public.celebrities SET birth_place = '서울특별시 중랑구 면목동' WHERE id = 'entertainer_lee_kukjoo';
UPDATE public.celebrities SET birth_place = '강원도 인제군 인제읍 남북리' WHERE id = 'entertainer_kim_kukjin';
UPDATE public.celebrities SET birth_place = '서울특별시 영등포구 여의도' WHERE id = 'entertainer_kim_sooyong';
UPDATE public.celebrities SET birth_place = '경상남도 통영시' WHERE id = 'entertainer_huh_kyunghwan';
UPDATE public.celebrities SET birth_place = '충청남도 아산시' WHERE id = 'entertainer_jang_dongmin';
UPDATE public.celebrities SET birth_place = '충청남도 공주시' WHERE id = 'entertainer_oh_nami';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'entertainer_lee_yoonseok';
UPDATE public.celebrities SET birth_place = '서울특별시 마포구 노고산동' WHERE id = 'entertainer_lee_sangmin';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 게임/스트리머 (남성)
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_daedo';
UPDATE public.celebrities SET birth_place = '대구광역시' WHERE id = 'youtuber_doti';
UPDATE public.celebrities SET birth_place = '충청남도 서천군' WHERE id = 'youtuber_bokyem';
UPDATE public.celebrities SET birth_place = '인천광역시' WHERE id = 'streamer_woowakgood';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_pungwolryang';
UPDATE public.celebrities SET birth_place = '전라북도 전주시' WHERE id = 'youtuber_chimchakman';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_joohomin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_kimblue';
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'streamer_cheolgu';
UPDATE public.celebrities SET birth_place = '전라남도 장성군' WHERE id = 'streamer_gamst';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_handongsuk';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_hongbangjang';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_ddungenius';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_sulbbyu';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 먹방 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_tzuyang';
UPDATE public.celebrities SET birth_place = '제주특별자치도' WHERE id = 'streamer_hibap';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_mukbangddonghee';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_hongsound';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_sas_asmr';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_banzz';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 뷰티/패션 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '광주광역시' WHERE id = 'youtuber_risabae';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_pony';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_ssinnim';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_lamuqe';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_dear';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 엔터테인먼트/코미디 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_shortbox_kimwonhun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_shortbox_jojinse';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_shortbox_eomjiyoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_psick_univ';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_itaewon_class';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_dexterit';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 피트니스/건강 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_fitvely';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_kimgyeran';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_thankyou_bubu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_apink_bodyprofile';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 이세계아이돌/버튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_ine';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_jingburger';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_lilpa';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_jururu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_gosegu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_vichan';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 일상/브이로그 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '충청남도 예산군 오가면 역탑리' WHERE id = 'youtuber_baekjongwon_table';
UPDATE public.celebrities SET birth_place = '서울특별시 종로구' WHERE id = 'youtuber_sungsikyung';
UPDATE public.celebrities SET birth_place = '서울특별시 강서구' WHERE id = 'youtuber_hyunmoo_tv';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_ggongji';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_sooby';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 교육/정보 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_nadocoding';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_jocoding';
UPDATE public.celebrities SET birth_place = '강원특별자치도' WHERE id = 'youtuber_sinsa_study';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_syuka';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_sebasi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_dongabrain';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 음악/커버 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_jflamusic';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_leeraon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_raon_lee';
UPDATE public.celebrities SET birth_place = '경기도 의정부시 신곡동' WHERE id = 'youtuber_suhyun_kim';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 여행/아웃도어 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '영국 브라이튼' WHERE id = 'youtuber_korean_englishman';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_wooldandali';
UPDATE public.celebrities SET birth_place = '강원특별자치도 춘천시' WHERE id = 'youtuber_pani_bottle';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_traveller_k';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 아프리카TV BJ
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 평택시' WHERE id = 'streamer_moonwol';
UPDATE public.celebrities SET birth_place = '인천광역시' WHERE id = 'streamer_oejilhye';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_seolgi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_bjchoyoo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_ddulggul';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_oking';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_rooftop';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 치지직/숲(SOOP) 스트리머
-- ==========================================
UPDATE public.celebrities SET birth_place = '대전광역시 서구' WHERE id = 'streamer_lee_youngho';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_jaehoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_jisoo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_ddahyun';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 키즈/패밀리 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_boramtube';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_larualulu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_geniebtv';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_carrie';

-- ==========================================
-- 유튜버/스트리머 출생지 업데이트 - 기타 인기 유튜버
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_ddanzi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_workman';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_mudo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_youquiz';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_dingo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_studio_waffle';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_godingeum';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_kasper';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_motorgraph';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_ogu';
UPDATE public.celebrities SET birth_place = '전라북도 전주시' WHERE id = 'youtuber_malnyun';
UPDATE public.celebrities SET birth_place = '경기도 여주시' WHERE id = 'youtuber_kian84';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'youtuber_joo_ho_min';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'streamer_saddal';
UPDATE public.celebrities SET birth_place = '제주특별자치도' WHERE id = 'youtuber_jejudodal';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 스타크래프트 1 (테란)
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 강남구' WHERE id = 'progamer_lim_yohwan';
UPDATE public.celebrities SET birth_place = '대전광역시 서구' WHERE id = 'progamer_lee_youngho';
UPDATE public.celebrities SET birth_place = '전라북도 익산시' WHERE id = 'progamer_choi_yeonsung';
UPDATE public.celebrities SET birth_place = '경상북도 구미시' WHERE id = 'progamer_lee_yunyeol';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 스타크래프트 1 (저그)
-- ==========================================
UPDATE public.celebrities SET birth_place = '대전광역시 대덕구' WHERE id = 'progamer_hong_jinho';
UPDATE public.celebrities SET birth_place = '울산광역시' WHERE id = 'progamer_lee_jaedong';
UPDATE public.celebrities SET birth_place = '인천광역시' WHERE id = 'progamer_park_sungjun';
UPDATE public.celebrities SET birth_place = '대구광역시' WHERE id = 'progamer_ma_jaeyun';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 스타크래프트 1 (프로토스)
-- ==========================================
UPDATE public.celebrities SET birth_place = '경상북도 포항시' WHERE id = 'progamer_song_byunggu';
UPDATE public.celebrities SET birth_place = '충청남도 예산군' WHERE id = 'progamer_kim_taekyong';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_kang_minj';
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'progamer_lee_junhyuk';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 스타크래프트 2
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_joo_hoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_joo_seong_wook';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_kim_yoojin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_jung_jonghyun';
UPDATE public.celebrities SET birth_place = '부산광역시 수영구' WHERE id = 'progamer_maru';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_stats';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_rogue';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_dark';
UPDATE public.celebrities SET birth_place = '핀란드' WHERE id = 'progamer_serral';

-- ==========================================
-- 프로게이머 출생지 업데이트 - LOL T1
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 강서구' WHERE id = 'progamer_faker';
UPDATE public.celebrities SET birth_place = '광주광역시 북구' WHERE id = 'progamer_oner';
UPDATE public.celebrities SET birth_place = '인천광역시' WHERE id = 'progamer_zeus';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_gumayusi';
UPDATE public.celebrities SET birth_place = '부산광역시 영도구' WHERE id = 'progamer_keria';

-- ==========================================
-- 프로게이머 출생지 업데이트 - LOL 전 T1
-- ==========================================
UPDATE public.celebrities SET birth_place = '강원특별자치도 홍천군' WHERE id = 'progamer_bang';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_wolf';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_bengi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_marin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_impact';

-- ==========================================
-- 프로게이머 출생지 업데이트 - LOL 다른 팀
-- ==========================================
UPDATE public.celebrities SET birth_place = '경기도 시흥시' WHERE id = 'progamer_showmaker';
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'progamer_canyon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_ruler';
UPDATE public.celebrities SET birth_place = '인천광역시 서구' WHERE id = 'progamer_chovy';
UPDATE public.celebrities SET birth_place = '인천광역시' WHERE id = 'progamer_bdd';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_peanut';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_teddy';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_deft';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_lehends';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_mata';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_score';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_doran';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_viper';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_smeb';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_pray';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_gorilla';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_ambition';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_crown';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 오버워치/발로란트
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_munchkin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_zunba';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_carpe';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_fleta';
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'progamer_profit';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_gesture';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_ryujehong';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_jjonak';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_stax';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_rb';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_t3xture';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 철권/격투게임
-- ==========================================
UPDATE public.celebrities SET birth_place = '경상북도 경산시' WHERE id = 'progamer_knee';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_jdcr';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_saint';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_lowhigh';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_chanel';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 배틀그라운드
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_pio';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_esca';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_inonix';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 피파온라인
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_sean';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_rocky';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 하스스톤
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_surrender';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_flurry';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 감독/코치
-- ==========================================
UPDATE public.celebrities SET birth_place = '부산광역시' WHERE id = 'progamer_kkoma';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_cvmax';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_kim_junghyun_coach';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 신예 선수들
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_peyz';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_kiin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_pyosik';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_lucid';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_aiming';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_delight';

-- ==========================================
-- 프로게이머 출생지 업데이트 - 여성 프로게이머
-- ==========================================
UPDATE public.celebrities SET birth_place = '대전광역시' WHERE id = 'progamer_geguri';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'progamer_tossgirl';
UPDATE public.celebrities SET birth_place = '캐나다' WHERE id = 'progamer_scarlett';

-- ==========================================
-- 기업인 출생지 업데이트 - 대기업 총수
-- ==========================================
-- 삼성그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_jaeyong';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_seokhyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_seohyun';

-- 현대자동차그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_chung_euisun';

-- SK그룹
UPDATE public.celebrities SET birth_place = '경기도 수원시' WHERE id = 'business_chey_taeone';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_chey_jaewon';

-- LG그룹
UPDATE public.celebrities SET birth_place = '서울특별시 강남구' WHERE id = 'business_koo_kwangmo';

-- 롯데그룹
UPDATE public.celebrities SET birth_place = '일본 도쿄도' WHERE id = 'business_shin_donbin';

-- 신세계그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_chung_yongjin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_myunghee';

-- 한화그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_seungyeon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_dongkwan';

-- 두산그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_park_jungwon';

-- CJ그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_jaehyun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_son_kyungsik';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_mikyung';

-- 현대백화점그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_chung_jisun';

-- 한진그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_cho_wontae';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_cho_hyuna';

-- GS그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_huh_taesoo';

-- LS그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_koo_jayeol';

-- 효성그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_cho_hyunsang';

-- DL그룹
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_haewook';

-- 포스코
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_choi_jungwoo';

-- ==========================================
-- 기업인 출생지 업데이트 - IT/플랫폼 기업 창업자
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 동대문구' WHERE id = 'business_lee_haejin';
UPDATE public.celebrities SET birth_place = '전라남도 담양군' WHERE id = 'business_kim_beomsu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_beomseok';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_junho_nhn';

-- ==========================================
-- 기업인 출생지 업데이트 - 게임 기업 창업자
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_jungju';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_taekjin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_bang_junhyuk';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_jang_byungkyu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kwon_hyukbin';

-- ==========================================
-- 기업인 출생지 업데이트 - 스타트업 창업자
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_seunggun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_bongjin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_sujin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_sora';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_jaehyun_daangn';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_ahn_sungwoo';

-- ==========================================
-- 기업인 출생지 업데이트 - 엔터테인먼트 기업인
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시 종로구' WHERE id = 'business_lee_sooman';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_yang_hyunsuk';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_park_jinyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_bang_sihyuk';

-- ==========================================
-- 기업인 출생지 업데이트 - 식품/유통 기업인
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_ham_youngjun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_shin_dongwon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kwon_wonkang';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_mun_changgi';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_suh_kyungbae';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_jeon_chulsoo';

-- ==========================================
-- 기업인 출생지 업데이트 - 역대 유명 창업가 (레전드)
-- ==========================================
UPDATE public.celebrities SET birth_place = '경상남도 의령군' WHERE id = 'business_lee_byungchul';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_kunhee';
UPDATE public.celebrities SET birth_place = '강원도 통천군' WHERE id = 'business_chung_juyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_chung_mongkoo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_choi_jonggun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_choi_jonghyun';
UPDATE public.celebrities SET birth_place = '경상남도 진주시' WHERE id = 'business_koo_inhoe';
UPDATE public.celebrities SET birth_place = '울산광역시 울주군' WHERE id = 'business_shin_kyukho';
UPDATE public.celebrities SET birth_place = '함경남도 원산시' WHERE id = 'business_ham_taeho';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_chanhee';

-- ==========================================
-- 기업인 출생지 업데이트 - 금융 기업인
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_yoon_jonggyu';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_cho_yongbyoung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_junghyo';

-- ==========================================
-- 기업인 출생지 업데이트 - 기타 유명 기업인
-- ==========================================
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_shin_changje';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_park_hyunjoo';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_seo_jungjin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_chung_kisun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_yoon_hosang';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_jo_manho';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_bae_kishik';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_park_taehoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_seo_junghoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_minchul';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_dongshin';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_song_chiheung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_sangjun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_sikhwan';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_yoon_joon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_woong';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kwon_doyoon';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_jang_byungtak';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_ryu_youngjun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kang_donghwan';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_jaewung';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_park_jaeuk';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_kim_daeil';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_lee_donggun';
UPDATE public.celebrities SET birth_place = '서울특별시' WHERE id = 'business_ko_youngho';

-- ==========================================
-- 업데이트 결과 확인
-- ==========================================
DO $$
DECLARE
    updated_count INTEGER;
    total_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO updated_count FROM celebrities
    WHERE birth_place IS NOT NULL AND birth_place != '';

    SELECT COUNT(*) INTO total_count FROM celebrities;

    RAISE NOTICE 'Celebrities with birth_place: % / %', updated_count, total_count;
END $$;
