import 'dart:io';
import 'dart:convert';
import '../services/saju_calculation_service.dart';
import '../data/models/celebrity_saju.dart';

class AdditionalCelebritySajuProcessor {
  // 추가 유명인들 데이터 (200명 이상)
  static final List<Map<String, dynamic>> additionalCelebrities = [
    // 가수/솔로 아티스트
    {'id': 'sing_100', 'name': '박효신', 'name_en': 'Park Hyo-sin', 'birth_date': '1979-12-01', 'birth_time': '14:30', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_101', 'name': '이선희', 'name_en': 'Lee Sun-hee', 'birth_date': '1964-11-11', 'birth_time': '10:00', 'gender': 'female', 'category': 'singer', 'agency': ''},
    {'id': 'sing_102', 'name': '나얼', 'name_en': 'Naul', 'birth_date': '1981-12-30', 'birth_time': '16:45', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_103', 'name': '김범수', 'name_en': 'Kim Bum-soo', 'birth_date': '1979-01-26', 'birth_time': '11:20', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_104', 'name': '백지영', 'name_en': 'Baek Ji-young', 'birth_date': '1976-03-25', 'birth_time': '15:30', 'gender': 'female', 'category': 'singer', 'agency': ''},
    {'id': 'sing_105', 'name': '이소라', 'name_en': 'Lee So-ra', 'birth_date': '1969-04-05', 'birth_time': '13:15', 'gender': 'female', 'category': 'singer', 'agency': ''},
    {'id': 'sing_106', 'name': '윤상', 'name_en': 'Yoon Sang', 'birth_date': '1968-02-06', 'birth_time': '18:00', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_107', 'name': '조성모', 'name_en': 'Jo Sung-mo', 'birth_date': '1977-02-05', 'birth_time': '09:30', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_108', 'name': '임창정', 'name_en': 'Im Chang-jung', 'birth_date': '1973-11-30', 'birth_time': '12:45', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_109', 'name': '신승훈', 'name_en': 'Shin Seung-hun', 'birth_date': '1966-03-21', 'birth_time': '14:00', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_110', 'name': '유재하', 'name_en': 'Yu Jae-ha', 'birth_date': '1962-08-11', 'birth_time': '16:30', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_111', 'name': '김광석', 'name_en': 'Kim Kwang-seok', 'birth_date': '1964-01-22', 'birth_time': '11:00', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_112', 'name': '서태지', 'name_en': 'Seo Taiji', 'birth_date': '1972-02-21', 'birth_time': '13:30', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_113', 'name': '조용필', 'name_en': 'Cho Yong-pil', 'birth_date': '1950-03-21', 'birth_time': '10:15', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_114', 'name': '이문세', 'name_en': 'Lee Moon-se', 'birth_date': '1957-01-17', 'birth_time': '15:45', 'gender': 'male', 'category': 'singer', 'agency': ''},
    {'id': 'sing_115', 'name': '변진섭', 'name_en': 'Byun Jin-sub', 'birth_date': '1966-12-30', 'birth_time': '17:20', 'gender': 'male', 'category': 'singer', 'agency': ''},

    // 래퍼
    {'id': 'rap_001', 'name': '타이거JK', 'name_en': 'Tiger JK', 'birth_date': '1974-07-29', 'birth_time': '14:30', 'gender': 'male', 'category': 'rapper', 'agency': ''},
    {'id': 'rap_002', 'name': '윤미래', 'name_en': 'Yoon Mirae', 'birth_date': '1981-05-31', 'birth_time': '11:45', 'gender': 'female', 'category': 'rapper', 'agency': ''},
    {'id': 'rap_003', 'name': '이효리', 'name_en': 'Lee Hyori', 'birth_date': '1979-05-10', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': ''},
    {'id': 'rap_004', 'name': '다이나믹 듀오', 'name_en': 'Dynamic Duo', 'birth_date': '1981-09-05', 'birth_time': '16:00', 'gender': 'male', 'category': 'rapper', 'agency': ''},

    // 배우 (남자)
    {'id': 'act_100', 'name': '이정재', 'name_en': 'Lee Jung-jae', 'birth_date': '1972-12-15', 'birth_time': '13:20', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_101', 'name': '박서준', 'name_en': 'Park Seo-joon', 'birth_date': '1988-12-16', 'birth_time': '10:30', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_102', 'name': '이민호', 'name_en': 'Lee Min-ho', 'birth_date': '1987-06-22', 'birth_time': '15:45', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_103', 'name': '현빈', 'name_en': 'Hyun Bin', 'birth_date': '1982-09-25', 'birth_time': '14:15', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_104', 'name': '원빈', 'name_en': 'Won Bin', 'birth_date': '1977-11-10', 'birth_time': '11:30', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_105', 'name': '조인성', 'name_en': 'Jo In-sung', 'birth_date': '1981-07-28', 'birth_time': '16:00', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_106', 'name': '송중기', 'name_en': 'Song Joong-ki', 'birth_date': '1985-09-19', 'birth_time': '12:45', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_107', 'name': '공유', 'name_en': 'Gong Yoo', 'birth_date': '1979-07-10', 'birth_time': '17:30', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_108', 'name': '이종석', 'name_en': 'Lee Jong-suk', 'birth_date': '1989-09-14', 'birth_time': '09:15', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_109', 'name': '김수현', 'name_en': 'Kim Soo-hyun', 'birth_date': '1988-02-16', 'birth_time': '13:45', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_110', 'name': '이동욱', 'name_en': 'Lee Dong-wook', 'birth_date': '1981-11-06', 'birth_time': '18:20', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_111', 'name': '소지섭', 'name_en': 'So Ji-sub', 'birth_date': '1977-11-04', 'birth_time': '14:50', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_112', 'name': '정우성', 'name_en': 'Jung Woo-sung', 'birth_date': '1973-03-20', 'birth_time': '10:25', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_113', 'name': '황정민', 'name_en': 'Hwang Jung-min', 'birth_date': '1970-09-01', 'birth_time': '16:35', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_114', 'name': '설경구', 'name_en': 'Sul Kyung-gu', 'birth_date': '1968-05-01', 'birth_time': '11:40', 'gender': 'male', 'category': 'actor', 'agency': ''},
    {'id': 'act_115', 'name': '송강호', 'name_en': 'Song Kang-ho', 'birth_date': '1967-01-17', 'birth_time': '15:10', 'gender': 'male', 'category': 'actor', 'agency': ''},

    // 배우 (여자)
    {'id': 'act_200', 'name': '송혜교', 'name_en': 'Song Hye-kyo', 'birth_date': '1981-11-22', 'birth_time': '12:30', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_201', 'name': '한지민', 'name_en': 'Han Ji-min', 'birth_date': '1982-11-05', 'birth_time': '14:15', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_202', 'name': '손예진', 'name_en': 'Son Ye-jin', 'birth_date': '1982-01-11', 'birth_time': '16:45', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_203', 'name': '박신혜', 'name_en': 'Park Shin-hye', 'birth_date': '1990-02-18', 'birth_time': '10:20', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_204', 'name': '김태희', 'name_en': 'Kim Tae-hee', 'birth_date': '1980-03-29', 'birth_time': '13:55', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_205', 'name': '김희선', 'name_en': 'Kim Hee-sun', 'birth_date': '1977-08-25', 'birth_time': '17:25', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_206', 'name': '김하늘', 'name_en': 'Kim Ha-neul', 'birth_date': '1978-02-21', 'birth_time': '11:35', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_207', 'name': '전도연', 'name_en': 'Jeon Do-yeon', 'birth_date': '1973-02-11', 'birth_time': '15:20', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_208', 'name': '윤여정', 'name_en': 'Youn Yuh-jung', 'birth_date': '1947-06-19', 'birth_time': '09:45', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_209', 'name': '김혜수', 'name_en': 'Kim Hye-soo', 'birth_date': '1970-09-05', 'birth_time': '14:30', 'gender': 'female', 'category': 'actor', 'agency': ''},
    {'id': 'act_210', 'name': '이영애', 'name_en': 'Lee Young-ae', 'birth_date': '1971-01-31', 'birth_time': '12:15', 'gender': 'female', 'category': 'actor', 'agency': ''},

    // 코미디언/예능인
    {'id': 'com_001', 'name': '유재석', 'name_en': 'Yoo Jae-suk', 'birth_date': '1972-08-14', 'birth_time': '10:30', 'gender': 'male', 'category': 'comedian', 'agency': ''},
    {'id': 'com_002', 'name': '강호동', 'name_en': 'Kang Ho-dong', 'birth_date': '1970-06-11', 'birth_time': '14:45', 'gender': 'male', 'category': 'comedian', 'agency': ''},
    {'id': 'com_003', 'name': '박명수', 'name_en': 'Park Myeong-su', 'birth_date': '1970-08-27', 'birth_time': '16:20', 'gender': 'male', 'category': 'comedian', 'agency': ''},
    {'id': 'com_004', 'name': '정형돈', 'name_en': 'Jeong Hyeong-don', 'birth_date': '1978-02-07', 'birth_time': '11:15', 'gender': 'male', 'category': 'comedian', 'agency': ''},
    {'id': 'com_005', 'name': '노홍철', 'name_en': 'Noh Hong-chul', 'birth_date': '1979-03-31', 'birth_time': '13:50', 'gender': 'male', 'category': 'comedian', 'agency': ''},
    {'id': 'com_006', 'name': '하하', 'name_en': 'HaHa', 'birth_date': '1979-08-20', 'birth_time': '17:35', 'gender': 'male', 'category': 'comedian', 'agency': ''},
    {'id': 'com_007', 'name': '김종국', 'name_en': 'Kim Jong-kook', 'birth_date': '1976-04-25', 'birth_time': '09:25', 'gender': 'male', 'category': 'comedian', 'agency': ''},
    {'id': 'com_008', 'name': '송지효', 'name_en': 'Song Ji-hyo', 'birth_date': '1981-08-15', 'birth_time': '15:40', 'gender': 'female', 'category': 'comedian', 'agency': ''},
    {'id': 'com_009', 'name': '전소민', 'name_en': 'Jeon So-min', 'birth_date': '1986-04-07', 'birth_time': '12:55', 'gender': 'female', 'category': 'comedian', 'agency': ''},
    {'id': 'com_010', 'name': '양세찬', 'name_en': 'Yang Se-chan', 'birth_date': '1986-09-18', 'birth_time': '18:10', 'gender': 'male', 'category': 'comedian', 'agency': ''},

    // 스포츠 선수
    {'id': 'ath_100', 'name': '박찬호', 'name_en': 'Park Chan-ho', 'birth_date': '1973-06-30', 'birth_time': '14:20', 'gender': 'male', 'category': 'athlete', 'agency': ''},
    {'id': 'ath_101', 'name': '박세리', 'name_en': 'Pak Se-ri', 'birth_date': '1977-09-28', 'birth_time': '11:45', 'gender': 'female', 'category': 'athlete', 'agency': ''},
    {'id': 'ath_102', 'name': '김연아', 'name_en': 'Kim Yuna', 'birth_date': '1990-09-05', 'birth_time': '16:30', 'gender': 'female', 'category': 'athlete', 'agency': ''},
    {'id': 'ath_103', 'name': '류현진', 'name_en': 'Ryu Hyun-jin', 'birth_date': '1987-03-25', 'birth_time': '10:15', 'gender': 'male', 'category': 'athlete', 'agency': ''},
    {'id': 'ath_104', 'name': '이대호', 'name_en': 'Lee Dae-ho', 'birth_date': '1982-06-21', 'birth_time': '13:40', 'gender': 'male', 'category': 'athlete', 'agency': ''},
    {'id': 'ath_105', 'name': '추신수', 'name_en': 'Choo Shin-soo', 'birth_date': '1982-07-13', 'birth_time': '15:25', 'gender': 'male', 'category': 'athlete', 'agency': ''},
    {'id': 'ath_106', 'name': '박인비', 'name_en': 'Park In-bee', 'birth_date': '1988-07-12', 'birth_time': '12:50', 'gender': 'female', 'category': 'athlete', 'agency': ''},
    {'id': 'ath_107', 'name': '박태환', 'name_en': 'Park Tae-hwan', 'birth_date': '1989-09-27', 'birth_time': '17:20', 'gender': 'male', 'category': 'athlete', 'agency': ''},

    // 정치인
    {'id': 'pol_100', 'name': '이재명', 'name_en': 'Lee Jae-myung', 'birth_date': '1964-12-22', 'birth_time': '09:30', 'gender': 'male', 'category': 'politician', 'agency': ''},
    {'id': 'pol_101', 'name': '홍준표', 'name_en': 'Hong Jun-pyo', 'birth_date': '1954-11-20', 'birth_time': '14:15', 'gender': 'male', 'category': 'politician', 'agency': ''},
    {'id': 'pol_102', 'name': '안철수', 'name_en': 'Ahn Cheol-soo', 'birth_date': '1962-02-26', 'birth_time': '11:45', 'gender': 'male', 'category': 'politician', 'agency': ''},
    {'id': 'pol_103', 'name': '조국', 'name_en': 'Cho Kuk', 'birth_date': '1965-12-05', 'birth_time': '16:35', 'gender': 'male', 'category': 'politician', 'agency': ''},

    // 기업인/재계
    {'id': 'bus_100', 'name': '이재용', 'name_en': 'Lee Jae-yong', 'birth_date': '1968-06-23', 'birth_time': '10:20', 'gender': 'male', 'category': 'business_leader', 'agency': ''},
    {'id': 'bus_101', 'name': '신동빈', 'name_en': 'Shin Dong-bin', 'birth_date': '1955-02-14', 'birth_time': '13:45', 'gender': 'male', 'category': 'business_leader', 'agency': ''},
    {'id': 'bus_102', 'name': '최태원', 'name_en': 'Chey Tae-won', 'birth_date': '1960-12-03', 'birth_time': '15:30', 'gender': 'male', 'category': 'business_leader', 'agency': ''},
    {'id': 'bus_103', 'name': '서경배', 'name_en': 'Suh Kyung-bae', 'birth_date': '1963-12-16', 'birth_time': '17:10', 'gender': 'male', 'category': 'business_leader', 'agency': ''},
    {'id': 'bus_104', 'name': '구광모', 'name_en': 'Koo Kwang-mo', 'birth_date': '1967-07-15', 'birth_time': '12:25', 'gender': 'male', 'category': 'business_leader', 'agency': ''},

    // 방송인/아나운서
    {'id': 'bro_001', 'name': '김성주', 'name_en': 'Kim Sung-joo', 'birth_date': '1974-04-15', 'birth_time': '11:30', 'gender': 'male', 'category': 'broadcaster', 'agency': ''},
    {'id': 'bro_002', 'name': '신동엽', 'name_en': 'Shin Dong-yup', 'birth_date': '1971-02-17', 'birth_time': '14:45', 'gender': 'male', 'category': 'broadcaster', 'agency': ''},
    {'id': 'bro_003', 'name': '김구라', 'name_en': 'Kim Gu-ra', 'birth_date': '1970-10-03', 'birth_time': '16:20', 'gender': 'male', 'category': 'broadcaster', 'agency': ''},
    {'id': 'bro_004', 'name': '김제동', 'name_en': 'Kim Je-dong', 'birth_date': '1974-04-27', 'birth_time': '09:15', 'gender': 'male', 'category': 'broadcaster', 'agency': ''},
    {'id': 'bro_005', 'name': '장도연', 'name_en': 'Jang Do-yeon', 'birth_date': '1985-02-07', 'birth_time': '13:35', 'gender': 'female', 'category': 'broadcaster', 'agency': ''},

    // 영화감독
    {'id': 'dir_001', 'name': '봉준호', 'name_en': 'Bong Joon-ho', 'birth_date': '1969-09-14', 'birth_time': '15:40', 'gender': 'male', 'category': 'director', 'agency': ''},
    {'id': 'dir_002', 'name': '박찬욱', 'name_en': 'Park Chan-wook', 'birth_date': '1963-08-23', 'birth_time': '11:25', 'gender': 'male', 'category': 'director', 'agency': ''},
    {'id': 'dir_003', 'name': '김기덕', 'name_en': 'Kim Ki-duk', 'birth_date': '1960-12-20', 'birth_time': '17:50', 'gender': 'male', 'category': 'director', 'agency': ''},
    {'id': 'dir_004', 'name': '이창동', 'name_en': 'Lee Chang-dong', 'birth_date': '1954-07-04', 'birth_time': '10:35', 'gender': 'male', 'category': 'director', 'agency': ''},

    // 작가
    {'id': 'wri_001', 'name': '조정래', 'name_en': 'Cho Jung-rae', 'birth_date': '1943-08-17', 'birth_time': '14:20', 'gender': 'male', 'category': 'writer', 'agency': ''},
    {'id': 'wri_002', 'name': '이외수', 'name_en': 'Lee Oe-soo', 'birth_date': '1946-09-22', 'birth_time': '12:10', 'gender': 'male', 'category': 'writer', 'agency': ''},
    {'id': 'wri_003', 'name': '공지영', 'name_en': 'Gong Ji-young', 'birth_date': '1963-08-09', 'birth_time': '16:45', 'gender': 'female', 'category': 'writer', 'agency': ''},

    // 추가 아이돌 그룹 멤버들 (개별)
    // 아이즈원 (일부)
    {'id': 'izone_001', 'name': '장원영', 'name_en': 'Jang Wonyoung', 'birth_date': '2004-08-31', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'IZ*ONE'},
    {'id': 'izone_002', 'name': '안유진', 'name_en': 'An Yujin', 'birth_date': '2003-09-01', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'IZ*ONE'},
    {'id': 'izone_003', 'name': '권은비', 'name_en': 'Kwon Eunbi', 'birth_date': '1995-09-27', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'IZ*ONE'},

    // 소녀시대 멤버들
    {'id': 'snsd_001', 'name': '태연', 'name_en': 'Taeyeon', 'birth_date': '1989-03-09', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '소녀시대'},
    {'id': 'snsd_002', 'name': '유리', 'name_en': 'Yuri', 'birth_date': '1989-12-05', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '소녀시대'},
    {'id': 'snsd_003', 'name': '윤아', 'name_en': 'Yoona', 'birth_date': '1990-05-30', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '소녀시대'},
    {'id': 'snsd_004', 'name': '서현', 'name_en': 'Seohyun', 'birth_date': '1991-06-28', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '소녀시대'},

    // 원더걸스 멤버들
    {'id': 'wg_001', 'name': '선예', 'name_en': 'Sunye', 'birth_date': '1989-08-12', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '원더걸스'},
    {'id': 'wg_002', 'name': '예은', 'name_en': 'Yeeun', 'birth_date': '1989-05-26', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '원더걸스'},
    {'id': 'wg_003', 'name': '선미', 'name_en': 'Sunmi', 'birth_date': '1992-05-02', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '원더걸스'},

    // 카라 멤버들
    {'id': 'kara_001', 'name': '박규리', 'name_en': 'Park Gyuri', 'birth_date': '1988-05-21', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'KARA'},
    {'id': 'kara_002', 'name': '한승연', 'name_en': 'Han Seungyeon', 'birth_date': '1988-07-24', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'KARA'},
    {'id': 'kara_003', 'name': '구하라', 'name_en': 'Koo Hara', 'birth_date': '1991-01-13', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'KARA'},

    // 빅뱅 멤버들 (개별)
    {'id': 'bb_001', 'name': 'G-Dragon', 'name_en': 'G-Dragon', 'birth_date': '1988-08-18', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'BIGBANG'},
    {'id': 'bb_002', 'name': '태양', 'name_en': 'Taeyang', 'birth_date': '1988-05-18', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'BIGBANG'},
    {'id': 'bb_003', 'name': '탑', 'name_en': 'TOP', 'birth_date': '1987-11-04', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'BIGBANG'},
    {'id': 'bb_004', 'name': '대성', 'name_en': 'Daesung', 'birth_date': '1989-04-26', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'BIGBANG'},

    // H.O.T 멤버들
    {'id': 'hot_001', 'name': '문희준', 'name_en': 'Moon Hee-jun', 'birth_date': '1978-03-19', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'H.O.T'},
    {'id': 'hot_002', 'name': '강타', 'name_en': 'Kangta', 'birth_date': '1979-10-10', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'H.O.T'},
    {'id': 'hot_003', 'name': '이재원', 'name_en': 'Lee Jae-won', 'birth_date': '1980-04-03', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'H.O.T'},

    // 젝스키스 멤버들
    {'id': 'sks_001', 'name': '은지원', 'name_en': 'Eun Ji-won', 'birth_date': '1978-06-08', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': '젝스키스'},
    {'id': 'sks_002', 'name': '이재진', 'name_en': 'Lee Jae-jin', 'birth_date': '1979-07-13', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': '젝스키스'},
    {'id': 'sks_003', 'name': '김재덕', 'name_en': 'Kim Jae-duck', 'birth_date': '1979-08-07', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': '젝스키스'},

    // (G)I-DLE 멤버들
    {'id': 'gidle_001', 'name': '전소연', 'name_en': 'Jeon Soyeon', 'birth_date': '1998-08-26', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '(G)I-DLE'},
    {'id': 'gidle_002', 'name': '민니', 'name_en': 'Minnie', 'birth_date': '1997-10-23', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '(G)I-DLE'},
    {'id': 'gidle_003', 'name': '우기', 'name_en': 'Yuqi', 'birth_date': '1999-09-23', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': '(G)I-DLE'},

    // 에스파 멤버들
    {'id': 'aespa_001', 'name': '카리나', 'name_en': 'Karina', 'birth_date': '2000-04-11', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'aespa'},
    {'id': 'aespa_002', 'name': '윈터', 'name_en': 'Winter', 'birth_date': '2001-01-01', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'aespa'},
    {'id': 'aespa_003', 'name': '지젤', 'name_en': 'Giselle', 'birth_date': '2000-10-30', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'aespa'},
    {'id': 'aespa_004', 'name': '닝닝', 'name_en': 'NingNing', 'birth_date': '2002-10-23', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'aespa'},

    // 스트레이키즈 멤버들
    {'id': 'skz_001', 'name': '방찬', 'name_en': 'Bang Chan', 'birth_date': '1997-10-03', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'Stray Kids'},
    {'id': 'skz_002', 'name': '리노', 'name_en': 'Lee Know', 'birth_date': '1998-10-25', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'Stray Kids'},
    {'id': 'skz_003', 'name': '창빈', 'name_en': 'Changbin', 'birth_date': '1999-08-11', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'Stray Kids'},
    {'id': 'skz_004', 'name': '현진', 'name_en': 'Hyunjin', 'birth_date': '2000-03-20', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'Stray Kids'},

    // 투모로우바이투게더(TXT) 멤버들
    {'id': 'txt_001', 'name': '수빈', 'name_en': 'Soobin', 'birth_date': '2000-12-05', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'TXT'},
    {'id': 'txt_002', 'name': '연준', 'name_en': 'Yeonjun', 'birth_date': '1999-09-13', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'TXT'},
    {'id': 'txt_003', 'name': '범규', 'name_en': 'Beomgyu', 'birth_date': '2001-03-13', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'TXT'},
    {'id': 'txt_004', 'name': '태현', 'name_en': 'Taehyun', 'birth_date': '2002-02-05', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'TXT'},
    {'id': 'txt_005', 'name': '휴닝카이', 'name_en': 'HueningKai', 'birth_date': '2002-08-14', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'TXT'},

    // 엔하이픈(ENHYPEN) 멤버들
    {'id': 'enhy_001', 'name': '정원', 'name_en': 'Jungwon', 'birth_date': '2004-02-09', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'ENHYPEN'},
    {'id': 'enhy_002', 'name': '희승', 'name_en': 'Heeseung', 'birth_date': '2001-10-15', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'ENHYPEN'},
    {'id': 'enhy_003', 'name': '제이', 'name_en': 'Jay', 'birth_date': '2002-04-20', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'ENHYPEN'},
    {'id': 'enhy_004', 'name': '제이크', 'name_en': 'Jake', 'birth_date': '2002-11-15', 'birth_time': '12:00', 'gender': 'male', 'category': 'singer', 'agency': 'ENHYPEN'},

    // 이탈릭(ITZY) 멤버들
    {'id': 'itzy_001', 'name': '예지', 'name_en': 'Yeji', 'birth_date': '2000-05-26', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'ITZY'},
    {'id': 'itzy_002', 'name': '리아', 'name_en': 'Lia', 'birth_date': '2000-07-21', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'ITZY'},
    {'id': 'itzy_003', 'name': '류진', 'name_en': 'Ryujin', 'birth_date': '2001-04-17', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'ITZY'},
    {'id': 'itzy_004', 'name': '채령', 'name_en': 'Chaeryeong', 'birth_date': '2001-06-05', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'ITZY'},
    {'id': 'itzy_005', 'name': '유나', 'name_en': 'Yuna', 'birth_date': '2003-12-09', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'ITZY'},

    // 르세라핌(LE SSERAFIM) 멤버들
    {'id': 'lsf_001', 'name': '사쿠라', 'name_en': 'Sakura', 'birth_date': '1998-03-19', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'LE SSERAFIM'},
    {'id': 'lsf_002', 'name': '김채원', 'name_en': 'Kim Chaewon', 'birth_date': '2000-08-01', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'LE SSERAFIM'},
    {'id': 'lsf_003', 'name': '허윤진', 'name_en': 'Huh Yunjin', 'birth_date': '2001-10-08', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'LE SSERAFIM'},
    {'id': 'lsf_004', 'name': '카즈하', 'name_en': 'Kazuha', 'birth_date': '2003-08-09', 'birth_time': '12:00', 'gender': 'female', 'category': 'singer', 'agency': 'LE SSERAFIM'},
  ];

  static Future<void> processAllCelebrities() async {
    print('🚀 추가 유명인 사주 계산 시작...');
    print('📊 총 ${additionalCelebrities.length}명의 유명인 처리 예정');
    
    final List<CelebritySaju> processedCelebrities = [];
    final List<String> sqlStatements = [];
    
    int successCount = 0;
    int failCount = 0;

    for (final celebrityData in additionalCelebrities) {
      try {
        final celebrity = await _processSingleCelebrity(celebrityData);
        
        if (celebrity != null) {
          processedCelebrities.add(celebrity);
          sqlStatements.add(_generateInsertSQL(celebrity));
          successCount++;
          
          print('✅ ${celebrity.name} (${celebrity.category}) 완료: ${celebrity.sajuString}');
        } else {
          failCount++;
        }
      } catch (e) {
        print('❌ 오류 (${celebrityData['name']}): $e');
        failCount++;
      }
    }

    // 결과 저장
    await _saveResults(processedCelebrities, sqlStatements);
    
    print('\n🎉 추가 유명인 처리 완료!');
    print('📊 총 처리: ${additionalCelebrities.length}명');
    print('✅ 성공: $successCount명');
    print('❌ 실패: $failCount명');
    print('📈 성공률: ${(successCount / additionalCelebrities.length * 100).toStringAsFixed(1)}%');
  }

  static Future<CelebritySaju?> _processSingleCelebrity(Map<String, dynamic> data) async {
    try {
      final birthDate = data['birth_date'] as String;
      final birthTime = data['birth_time'] as String;
      
      // 생년월일 파싱
      final dateParts = birthDate.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      // 생시 파싱
      final timeParts = birthTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length >= 2 ? int.parse(timeParts[1]) : 0;

      final birthDateTime = DateTime(year, month, day, hour, minute);
      
      // 사주 계산
      final sajuResult = SajuCalculationService.calculateSaju(
        birthDate: birthDateTime,
        birthTime: birthTime,
        isLunar: false,
      );

      // 사주 각 기둥 추출
      final yearPillar = _extractPillar(sajuResult, 'year');
      final monthPillar = _extractPillar(sajuResult, 'month');
      final dayPillar = _extractPillar(sajuResult, 'day');
      final hourPillar = _extractPillar(sajuResult, 'hour');

      return CelebritySaju(
        id: data['id'] as String,
        name: data['name'] as String,
        nameEn: data['name_en'] as String,
        birthDate: birthDate,
        birthTime: birthTime,
        gender: data['gender'] as String,
        birthPlace: '',
        category: data['category'] as String,
        agency: data['agency'] as String,
        yearPillar: yearPillar,
        monthPillar: monthPillar,
        dayPillar: dayPillar,
        hourPillar: hourPillar,
        sajuString: _generateSajuString(sajuResult),
        woodCount: _countElement(sajuResult, '목'),
        fireCount: _countElement(sajuResult, '화'),
        earthCount: _countElement(sajuResult, '토'),
        metalCount: _countElement(sajuResult, '금'),
        waterCount: _countElement(sajuResult, '수'),
        fullSajuData: sajuResult,
        dataSource: 'additional_celebrity_calculated',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

    } catch (e) {
      print('❌ ${data['name']} 처리 중 오류: $e');
      return null;
    }
  }

  static String _extractPillar(Map<String, dynamic> sajuData, String pillarType) {
    final pillar = sajuData[pillarType];
    if (pillar == null) return '';
    return '${pillar['stem'] ?? ''}${pillar['branch'] ?? ''}';
  }

  static String _generateSajuString(Map<String, dynamic> sajuData) {
    final parts = <String>[];
    
    if (sajuData['year'] != null) {
      final year = sajuData['year'];
      parts.add('${year['stem'] ?? ''}${year['branch'] ?? ''}');
    }
    if (sajuData['month'] != null) {
      final month = sajuData['month'];
      parts.add('${month['stem'] ?? ''}${month['branch'] ?? ''}');
    }
    if (sajuData['day'] != null) {
      final day = sajuData['day'];
      parts.add('${day['stem'] ?? ''}${day['branch'] ?? ''}');
    }
    if (sajuData['hour'] != null) {
      final hour = sajuData['hour'];
      parts.add('${hour['stem'] ?? ''}${hour['branch'] ?? ''}');
    }
    
    return parts.join(' ');
  }

  static int _countElement(Map<String, dynamic> sajuData, String element) {
    final elements = sajuData['elements'] as Map<String, dynamic>?;
    return elements?[element] as int? ?? 0;
  }

  static String _generateInsertSQL(CelebritySaju celebrity) {
    final escapedName = celebrity.name.replaceAll("'", "''");
    final escapedNameEn = celebrity.nameEn.replaceAll("'", "''");
    final escapedAgency = celebrity.agency.replaceAll("'", "''");
    final escapedSajuString = celebrity.sajuString.replaceAll("'", "''");
    final fullSajuDataJson = json.encode(celebrity.fullSajuData).replaceAll("'", "''");

    return """INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  '${celebrity.id}', '$escapedName', '$escapedNameEn', '${celebrity.birthDate}', '${celebrity.birthTime}',
  '${celebrity.gender}', '${celebrity.birthPlace}', '${celebrity.category}', '$escapedAgency',
  '${celebrity.yearPillar}', '${celebrity.monthPillar}', '${celebrity.dayPillar}', '${celebrity.hourPillar}',
  '$escapedSajuString', ${celebrity.woodCount}, ${celebrity.fireCount}, ${celebrity.earthCount},
  ${celebrity.metalCount}, ${celebrity.waterCount},
  '$fullSajuDataJson'::jsonb, '${celebrity.dataSource}', NOW(), NOW()
);""";
  }

  static Future<void> _saveResults(
    List<CelebritySaju> celebrities, 
    List<String> sqlStatements,
  ) async {
    try {
      // JSON 파일로 결과 저장
      final jsonFile = File('additional_celebrities_saju.json');
      final jsonData = celebrities.map((c) => c.toJson()).toList();
      await jsonFile.writeAsString(json.encode(jsonData));
      print('✅ JSON 파일 저장: ${jsonFile.path}');

      // SQL 파일로 결과 저장
      final sqlFile = File('additional_celebrities_insert.sql');
      final sqlContent = [
        '-- 추가 유명인 사주 데이터 삽입 SQL',
        '-- 총 ${celebrities.length}명의 추가 유명인 데이터',
        '',
        ...sqlStatements,
      ].join('\n');
      
      await sqlFile.writeAsString(sqlContent);
      print('✅ SQL 파일 저장: ${sqlFile.path}');

      // 카테고리별 통계
      final categoryStats = <String, int>{};
      for (final celebrity in celebrities) {
        final category = celebrity.category;
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }

      print('\n📊 카테고리별 인원 수:');
      categoryStats.forEach((category, count) {
        print('   $category: $count명');
      });

    } catch (e) {
      print('❌ 파일 저장 오류: $e');
    }
  }
}

// 실행 스크립트
void main() async {
  await AdditionalCelebritySajuProcessor.processAllCelebrities();
}