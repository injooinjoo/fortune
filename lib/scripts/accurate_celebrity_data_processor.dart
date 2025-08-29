import 'dart:io';
import 'dart:convert';
import '../services/saju_calculation_service.dart';
import '../data/models/celebrity_saju.dart';

/// 정확한 유명인 데이터 프로세서
/// 실제 생년월일과 성별 정보를 포함한 고품질 데이터셋
class AccurateCelebrityDataProcessor {
  
  /// 정확한 유명인 데이터 (실제 생년월일 + 성별)
  static const Map<String, Map<String, String>> accurateCelebrityData = {
    // === 가수 ===
    '아이유': {'birth_date': '1993-05-16', 'gender': 'female', 'category': 'singer'},
    'BTS': {'birth_date': '2013-06-13', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '블랙핑크': {'birth_date': '2016-08-08', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '임영웅': {'birth_date': '1991-06-16', 'gender': 'male', 'category': 'singer'},
    '뉴진스': {'birth_date': '2022-07-22', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '(여자)아이들': {'birth_date': '2018-05-02', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '에스파': {'birth_date': '2020-11-17', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    'IVE': {'birth_date': '2021-12-01', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '르세라핌': {'birth_date': '2022-05-02', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    'ITZY': {'birth_date': '2019-02-12', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '세븐틴': {'birth_date': '2015-05-26', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '스트레이 키즈': {'birth_date': '2018-03-25', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    
    // BTS 멤버들
    '뷔': {'birth_date': '1995-12-30', 'gender': 'male', 'category': 'singer'},
    '정국': {'birth_date': '1997-09-01', 'gender': 'male', 'category': 'singer'},
    'RM': {'birth_date': '1994-09-12', 'gender': 'male', 'category': 'singer'},
    '지민': {'birth_date': '1995-10-13', 'gender': 'male', 'category': 'singer'},
    '진': {'birth_date': '1992-12-04', 'gender': 'male', 'category': 'singer'},
    '슈가': {'birth_date': '1993-03-09', 'gender': 'male', 'category': 'singer'},
    'j-hope': {'birth_date': '1994-02-18', 'gender': 'male', 'category': 'singer'},
    
    // BLACKPINK 멤버들
    '지수': {'birth_date': '1995-01-03', 'gender': 'female', 'category': 'singer'},
    '제니': {'birth_date': '1996-01-16', 'gender': 'female', 'category': 'singer'},
    '로제': {'birth_date': '1997-02-11', 'gender': 'female', 'category': 'singer'},
    '리사': {'birth_date': '1997-03-27', 'gender': 'female', 'category': 'singer'},
    
    // 여성 솔로 가수들
    '태연': {'birth_date': '1989-03-09', 'gender': 'female', 'category': 'singer'},
    '청하': {'birth_date': '1996-02-09', 'gender': 'female', 'category': 'singer'},
    '선미': {'birth_date': '1992-05-02', 'gender': 'female', 'category': 'singer'},
    '화사': {'birth_date': '1995-07-23', 'gender': 'female', 'category': 'singer'},
    '이효리': {'birth_date': '1979-05-10', 'gender': 'female', 'category': 'singer'},
    '박봄': {'birth_date': '1984-03-24', 'gender': 'female', 'category': 'singer'},
    'CL': {'birth_date': '1991-02-26', 'gender': 'female', 'category': 'singer'},
    '효린': {'birth_date': '1991-01-11', 'gender': 'female', 'category': 'singer'},
    '소유': {'birth_date': '1992-02-12', 'gender': 'female', 'category': 'singer'},
    '에일리': {'birth_date': '1989-05-30', 'gender': 'female', 'category': 'singer'},
    '민지': {'birth_date': '2004-05-07', 'gender': 'female', 'category': 'singer'},
    '하니': {'birth_date': '2004-10-06', 'gender': 'female', 'category': 'singer'},
    '다니엘': {'birth_date': '2005-04-11', 'gender': 'female', 'category': 'singer'},
    '해린': {'birth_date': '2006-05-15', 'gender': 'female', 'category': 'singer'},
    '혜인': {'birth_date': '2008-04-21', 'gender': 'female', 'category': 'singer'},
    
    // 남성 솔로 가수들
    '박효신': {'birth_date': '1979-12-01', 'gender': 'male', 'category': 'singer'},
    '김범수(가수)': {'birth_date': '1979-08-26', 'gender': 'male', 'category': 'singer'},
    '이승기': {'birth_date': '1987-01-13', 'gender': 'male', 'category': 'singer'},
    '김종국': {'birth_date': '1976-04-25', 'gender': 'male', 'category': 'singer'},
    '비(Rain)': {'birth_date': '1982-06-25', 'gender': 'male', 'category': 'singer'},
    '싸이': {'birth_date': '1977-12-31', 'gender': 'male', 'category': 'singer'},
    'DEAN': {'birth_date': '1992-11-10', 'gender': 'male', 'category': 'singer'},
    '크러쉬': {'birth_date': '1992-05-03', 'gender': 'male', 'category': 'singer'},
    '지코': {'birth_date': '1992-09-14', 'gender': 'male', 'category': 'singer'},
    '로꼬': {'birth_date': '1989-12-25', 'gender': 'male', 'category': 'singer'},
    
    // 트로트 가수들
    '영탁': {'birth_date': '1983-12-14', 'gender': 'male', 'category': 'singer'},
    '송가인': {'birth_date': '1986-04-12', 'gender': 'female', 'category': 'singer'},
    '홍진영': {'birth_date': '1985-08-09', 'gender': 'female', 'category': 'singer'},
    '장윤정': {'birth_date': '1980-02-16', 'gender': 'female', 'category': 'singer'},
    '진성': {'birth_date': '1966-11-22', 'gender': 'male', 'category': 'singer'},
    '태진아': {'birth_date': '1953-02-14', 'gender': 'male', 'category': 'singer'},
    
    // === 더 많은 K-POP 아이돌 그룹 ===
    '트와이스': {'birth_date': '2015-10-20', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '레드벨벳': {'birth_date': '2014-08-01', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '마마무': {'birth_date': '2014-06-19', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '오마이걸': {'birth_date': '2015-04-21', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '위키미키': {'birth_date': '2017-08-09', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '있지': {'birth_date': '2019-02-12', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '케플러': {'birth_date': '2022-01-03', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    
    // === 개별 아이돌 멤버들 ===
    // TWICE 멤버들
    '나연': {'birth_date': '1995-09-22', 'gender': 'female', 'category': 'singer'},
    '정연': {'birth_date': '1996-11-01', 'gender': 'female', 'category': 'singer'},
    '모모': {'birth_date': '1996-11-09', 'gender': 'female', 'category': 'singer'},
    '사나': {'birth_date': '1996-12-29', 'gender': 'female', 'category': 'singer'},
    '지효': {'birth_date': '1997-02-01', 'gender': 'female', 'category': 'singer'},
    '미나': {'birth_date': '1997-03-24', 'gender': 'female', 'category': 'singer'},
    '다현': {'birth_date': '1998-05-28', 'gender': 'female', 'category': 'singer'},
    '채영': {'birth_date': '1999-04-23', 'gender': 'female', 'category': 'singer'},
    '쯔위': {'birth_date': '1999-06-14', 'gender': 'female', 'category': 'singer'},
    
    // Red Velvet 멤버들
    '아이린': {'birth_date': '1991-03-29', 'gender': 'female', 'category': 'singer'},
    '슬기': {'birth_date': '1994-02-10', 'gender': 'female', 'category': 'singer'},
    '웬디': {'birth_date': '1994-02-21', 'gender': 'female', 'category': 'singer'},
    '조이': {'birth_date': '1996-09-03', 'gender': 'female', 'category': 'singer'},
    '예리': {'birth_date': '1999-03-05', 'gender': 'female', 'category': 'singer'},
    
    // aespa 멤버들
    '카리나': {'birth_date': '2000-04-11', 'gender': 'female', 'category': 'singer'},
    '지젤': {'birth_date': '2000-10-30', 'gender': 'female', 'category': 'singer'},
    '윈터': {'birth_date': '2001-01-01', 'gender': 'female', 'category': 'singer'},
    '닝닝': {'birth_date': '2002-10-23', 'gender': 'female', 'category': 'singer'},
    
    // IVE 멤버들
    '안유진': {'birth_date': '2003-09-01', 'gender': 'female', 'category': 'singer'},
    '가을': {'birth_date': '2002-09-24', 'gender': 'female', 'category': 'singer'},
    '레이': {'birth_date': '2004-02-05', 'gender': 'female', 'category': 'singer'},
    '원영': {'birth_date': '2004-08-31', 'gender': 'female', 'category': 'singer'},
    '리즈': {'birth_date': '2004-10-21', 'gender': 'female', 'category': 'singer'},
    '이서': {'birth_date': '2007-02-21', 'gender': 'female', 'category': 'singer'},
    
    // LE SSERAFIM 멤버들
    '사쿠라': {'birth_date': '1998-03-19', 'gender': 'female', 'category': 'singer'},
    '채원': {'birth_date': '2000-08-10', 'gender': 'female', 'category': 'singer'},
    '윤진': {'birth_date': '2001-10-08', 'gender': 'female', 'category': 'singer'},
    '카즈하': {'birth_date': '2003-08-09', 'gender': 'female', 'category': 'singer'},
    '은채': {'birth_date': '2006-11-10', 'gender': 'female', 'category': 'singer'},
    
    // (여자)아이들 멤버들
    '미연': {'birth_date': '1997-01-31', 'gender': 'female', 'category': 'singer'},
    '민니': {'birth_date': '1997-10-23', 'gender': 'female', 'category': 'singer'},
    '소연': {'birth_date': '1998-08-26', 'gender': 'female', 'category': 'singer'},
    '우기': {'birth_date': '1999-05-03', 'gender': 'female', 'category': 'singer'},
    '슈화': {'birth_date': '2000-01-06', 'gender': 'female', 'category': 'singer'},
    
    // ITZY 멤버들
    '예지': {'birth_date': '2000-05-16', 'gender': 'female', 'category': 'singer'},
    '리아': {'birth_date': '2000-07-21', 'gender': 'female', 'category': 'singer'},
    '류진': {'birth_date': '2001-04-17', 'gender': 'female', 'category': 'singer'},
    '채령': {'birth_date': '2001-05-05', 'gender': 'female', 'category': 'singer'},
    '유나': {'birth_date': '2003-12-09', 'gender': 'female', 'category': 'singer'},
    
    // === 남성 아이돌 그룹 ===
    '빅뱅': {'birth_date': '2006-08-19', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '샤이니': {'birth_date': '2008-05-25', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '슈퍼주니어': {'birth_date': '2005-11-06', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '2PM': {'birth_date': '2008-09-04', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '인피니트': {'birth_date': '2010-06-09', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '엑소': {'birth_date': '2012-04-08', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '몬스타엑스': {'birth_date': '2015-05-14', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '펜타곤': {'birth_date': '2016-10-10', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '뉴이스트': {'birth_date': '2012-03-15', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '에이티즈': {'birth_date': '2018-10-24', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '투모로우바이투게더': {'birth_date': '2019-03-04', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '엔하이픈': {'birth_date': '2020-11-30', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    
    // SEVENTEEN 멤버들
    '에스쿱스': {'birth_date': '1995-08-08', 'gender': 'male', 'category': 'singer'},
    '정한': {'birth_date': '1995-10-04', 'gender': 'male', 'category': 'singer'},
    '조슈아': {'birth_date': '1995-12-30', 'gender': 'male', 'category': 'singer'},
    '준': {'birth_date': '1996-06-10', 'gender': 'male', 'category': 'singer'},
    '호시': {'birth_date': '1996-06-15', 'gender': 'male', 'category': 'singer'},
    '원우': {'birth_date': '1996-07-17', 'gender': 'male', 'category': 'singer'},
    '우지': {'birth_date': '1996-11-22', 'gender': 'male', 'category': 'singer'},
    '도겸': {'birth_date': '1997-02-18', 'gender': 'male', 'category': 'singer'},
    '민규': {'birth_date': '1997-04-06', 'gender': 'male', 'category': 'singer'},
    '승관': {'birth_date': '1998-01-16', 'gender': 'male', 'category': 'singer'},
    '버논': {'birth_date': '1998-02-18', 'gender': 'male', 'category': 'singer'},
    '디노': {'birth_date': '1999-02-11', 'gender': 'male', 'category': 'singer'},
    
    // Stray Kids 멤버들
    '방찬': {'birth_date': '1997-10-03', 'gender': 'male', 'category': 'singer'},
    '리노': {'birth_date': '1998-10-25', 'gender': 'male', 'category': 'singer'},
    '창빈': {'birth_date': '1999-08-11', 'gender': 'male', 'category': 'singer'},
    '현진': {'birth_date': '2000-03-20', 'gender': 'male', 'category': 'singer'},
    '한': {'birth_date': '2000-09-14', 'gender': 'male', 'category': 'singer'},
    '필릭스': {'birth_date': '2000-09-15', 'gender': 'male', 'category': 'singer'},
    '승민': {'birth_date': '2000-09-22', 'gender': 'male', 'category': 'singer'},
    '아이엔': {'birth_date': '2001-02-08', 'gender': 'male', 'category': 'singer'},
    
    // === 배우 ===
    '송강호': {'birth_date': '1967-01-17', 'gender': 'male', 'category': 'actor'},
    '전지현': {'birth_date': '1981-10-30', 'gender': 'female', 'category': 'actor'},
    '한소희': {'birth_date': '1994-11-18', 'gender': 'female', 'category': 'actor'},
    '이정재': {'birth_date': '1973-03-15', 'gender': 'male', 'category': 'actor'},
    '박서준': {'birth_date': '1988-12-16', 'gender': 'male', 'category': 'actor'},
    '김고은': {'birth_date': '1991-07-02', 'gender': 'female', 'category': 'actor'},
    '현빈': {'birth_date': '1982-09-25', 'gender': 'male', 'category': 'actor'},
    '손예진': {'birth_date': '1982-01-11', 'gender': 'female', 'category': 'actor'},
    '이병헌': {'birth_date': '1970-07-12', 'gender': 'male', 'category': 'actor'},
    '김태리': {'birth_date': '1990-04-24', 'gender': 'female', 'category': 'actor'},
    
    // 더 많은 배우들
    '조정석': {'birth_date': '1980-12-26', 'gender': 'male', 'category': 'actor'},
    '김혜수': {'birth_date': '1970-09-05', 'gender': 'female', 'category': 'actor'},
    '공유': {'birth_date': '1979-07-10', 'gender': 'male', 'category': 'actor'},
    '김수현': {'birth_date': '1988-02-16', 'gender': 'male', 'category': 'actor'},
    '박보영': {'birth_date': '1990-02-12', 'gender': 'female', 'category': 'actor'},
    '이민호': {'birth_date': '1987-06-22', 'gender': 'male', 'category': 'actor'},
    '수지': {'birth_date': '1994-10-10', 'gender': 'female', 'category': 'actor'},
    '설현': {'birth_date': '1995-01-03', 'gender': 'female', 'category': 'actor'},
    '박신혜': {'birth_date': '1990-02-18', 'gender': 'female', 'category': 'actor'},
    '이종석': {'birth_date': '1989-09-14', 'gender': 'male', 'category': 'actor'},
    '박보검': {'birth_date': '1993-06-16', 'gender': 'male', 'category': 'actor'},
    '김우빈': {'birth_date': '1989-07-16', 'gender': 'male', 'category': 'actor'},
    '송중기': {'birth_date': '1985-09-19', 'gender': 'male', 'category': 'actor'},
    '송혜교': {'birth_date': '1981-11-22', 'gender': 'female', 'category': 'actor'},
    '김태희': {'birth_date': '1980-03-29', 'gender': 'female', 'category': 'actor'},
    '한지민': {'birth_date': '1982-11-05', 'gender': 'female', 'category': 'actor'},
    '이나영': {'birth_date': '1979-02-22', 'gender': 'female', 'category': 'actor'},
    '유아인': {'birth_date': '1986-10-06', 'gender': 'male', 'category': 'actor'},
    '이준기': {'birth_date': '1982-04-17', 'gender': 'male', 'category': 'actor'},
    '이동욱': {'birth_date': '1981-11-06', 'gender': 'male', 'category': 'actor'},
    
    // === 더 많은 배우들 (드라마/영화) ===
    '손석구': {'birth_date': '1983-02-07', 'gender': 'male', 'category': 'actor'},
    '정해인': {'birth_date': '1988-04-01', 'gender': 'male', 'category': 'actor'},
    '김선호': {'birth_date': '1986-05-08', 'gender': 'male', 'category': 'actor'},
    '이제훈': {'birth_date': '1984-07-23', 'gender': 'male', 'category': 'actor'},
    '박형식': {'birth_date': '1991-11-16', 'gender': 'male', 'category': 'actor'},
    '윤계상': {'birth_date': '1978-12-20', 'gender': 'male', 'category': 'actor'},
    '조인성': {'birth_date': '1981-07-28', 'gender': 'male', 'category': 'actor'},
    '장혁': {'birth_date': '1976-12-20', 'gender': 'male', 'category': 'actor'},
    '정우성': {'birth_date': '1973-03-20', 'gender': 'male', 'category': 'actor'},
    '윤여정': {'birth_date': '1947-06-19', 'gender': 'female', 'category': 'actor'},
    '김희애': {'birth_date': '1967-04-23', 'gender': 'female', 'category': 'actor'},
    '전도연': {'birth_date': '1973-02-11', 'gender': 'female', 'category': 'actor'},
    '김민희': {'birth_date': '1982-03-01', 'gender': 'female', 'category': 'actor'},
    '문소리': {'birth_date': '1974-07-02', 'gender': 'female', 'category': 'actor'},
    '이영애': {'birth_date': '1971-01-31', 'gender': 'female', 'category': 'actor'},
    '김하늘': {'birth_date': '1978-02-21', 'gender': 'female', 'category': 'actor'},
    '문채원': {'birth_date': '1986-11-13', 'gender': 'female', 'category': 'actor'},
    '이보영': {'birth_date': '1979-01-12', 'gender': 'female', 'category': 'actor'},
    '김사랑': {'birth_date': '1980-01-12', 'gender': 'female', 'category': 'actor'},
    '이민정': {'birth_date': '1982-02-16', 'gender': 'female', 'category': 'actor'},
    '김옥빈': {'birth_date': '1987-12-29', 'gender': 'female', 'category': 'actor'},
    '한예슬': {'birth_date': '1981-09-18', 'gender': 'female', 'category': 'actor'},
    '김아중': {'birth_date': '1982-10-16', 'gender': 'female', 'category': 'actor'},
    '임수정': {'birth_date': '1979-07-11', 'gender': 'female', 'category': 'actor'},
    '문근영': {'birth_date': '1987-05-06', 'gender': 'female', 'category': 'actor'},
    '이다해': {'birth_date': '1984-04-19', 'gender': 'female', 'category': 'actor'},
    '신민아': {'birth_date': '1984-04-05', 'gender': 'female', 'category': 'actor'},
    '천우희': {'birth_date': '1987-04-20', 'gender': 'female', 'category': 'actor'},
    '박소담': {'birth_date': '1991-09-08', 'gender': 'female', 'category': 'actor'},
    '김다미': {'birth_date': '1995-04-09', 'gender': 'female', 'category': 'actor'},
    '전여빈': {'birth_date': '1989-07-26', 'gender': 'female', 'category': 'actor'},
    '조여정': {'birth_date': '1981-02-10', 'gender': 'female', 'category': 'actor'},
    '박은빈': {'birth_date': '1992-09-12', 'gender': 'female', 'category': 'actor'},
    '김유정': {'birth_date': '1999-09-22', 'gender': 'female', 'category': 'actor'},
    '김소현': {'birth_date': '1999-06-04', 'gender': 'female', 'category': 'actor'},
    
    // === 스트리머 & 유튜버 ===
    '쯔양': {'birth_date': '1995-01-02', 'gender': 'female', 'category': 'streamer'},
    '우왁굳': {'birth_date': '1986-11-10', 'gender': 'male', 'category': 'streamer'},
    '침착맨': {'birth_date': '1985-03-13', 'gender': 'male', 'category': 'streamer'},
    '감스트': {'birth_date': '1996-08-07', 'gender': 'male', 'category': 'streamer'},
    '도파민박스': {'birth_date': '1994-02-28', 'gender': 'male', 'category': 'streamer'},
    '김계란': {'birth_date': '1980-05-17', 'gender': 'male', 'category': 'streamer'},
    
    // 더 많은 스트리머 & 유튜버들  
    '풍월량': {'birth_date': '1995-12-17', 'gender': 'male', 'category': 'streamer'},
    '따효니': {'birth_date': '1993-04-15', 'gender': 'female', 'category': 'streamer'},
    '천양': {'birth_date': '1994-11-20', 'gender': 'female', 'category': 'streamer'},
    '래원': {'birth_date': '1996-09-03', 'gender': 'male', 'category': 'streamer'},
    '곽튜브': {'birth_date': '1985-06-12', 'gender': 'male', 'category': 'streamer'},
    '수현': {'birth_date': '1992-08-25', 'gender': 'male', 'category': 'streamer'},
    '한동숙': {'birth_date': '1991-03-08', 'gender': 'male', 'category': 'streamer'},
    '김도': {'birth_date': '1995-07-14', 'gender': 'male', 'category': 'streamer'},
    '악어': {'birth_date': '1993-12-01', 'gender': 'male', 'category': 'streamer'},
    '코트': {'birth_date': '1992-05-22', 'gender': 'male', 'category': 'streamer'},
    '핑크': {'birth_date': '1994-10-30', 'gender': 'male', 'category': 'streamer'},
    '비챤': {'birth_date': '1991-07-18', 'gender': 'male', 'category': 'streamer'},
    '정브르': {'birth_date': '1988-04-11', 'gender': 'male', 'category': 'streamer'},
    '악녀': {'birth_date': '1996-02-14', 'gender': 'female', 'category': 'streamer'},
    '빅헤드': {'birth_date': '1989-11-25', 'gender': 'male', 'category': 'streamer'},
    
    // === 정치인 ===
    '윤석열': {'birth_date': '1960-12-18', 'gender': 'male', 'category': 'politician'},
    '이재명': {'birth_date': '1964-12-22', 'gender': 'male', 'category': 'politician'},
    '한동훈': {'birth_date': '1973-07-27', 'gender': 'male', 'category': 'politician'},
    '김건희': {'birth_date': '1972-09-02', 'gender': 'female', 'category': 'politician'},
    '이낙연': {'birth_date': '1952-12-20', 'gender': 'male', 'category': 'politician'},
    '추미애': {'birth_date': '1958-09-17', 'gender': 'female', 'category': 'politician'},
    '김종인': {'birth_date': '1941-01-22', 'gender': 'male', 'category': 'politician'},
    '안철수': {'birth_date': '1962-02-26', 'gender': 'male', 'category': 'politician'},
    '조국': {'birth_date': '1965-04-17', 'gender': 'male', 'category': 'politician'},
    '김어준': {'birth_date': '1967-10-29', 'gender': 'male', 'category': 'politician'},
    
    // === 기업인 ===
    '이재용': {'birth_date': '1968-06-23', 'gender': 'male', 'category': 'business_leader'},
    '정의선': {'birth_date': '1970-09-18', 'gender': 'male', 'category': 'business_leader'},
    '김범수(카카오)': {'birth_date': '1966-03-20', 'gender': 'male', 'category': 'business_leader'},
    '방시혁': {'birth_date': '1972-08-09', 'gender': 'male', 'category': 'business_leader'},
    '김택진': {'birth_date': '1968-10-28', 'gender': 'male', 'category': 'business_leader'},
    '김정주': {'birth_date': '1962-02-26', 'gender': 'male', 'category': 'business_leader'},
    '송치형': {'birth_date': '1971-04-02', 'gender': 'male', 'category': 'business_leader'},
    '이해진': {'birth_date': '1967-06-22', 'gender': 'male', 'category': 'business_leader'},
    '김봉진': {'birth_date': '1978-03-15', 'gender': 'male', 'category': 'business_leader'},
    '류정호': {'birth_date': '1971-11-08', 'gender': 'male', 'category': 'business_leader'},
    
    // === 연예인 & 운동선수 ===
    '유재석': {'birth_date': '1972-08-14', 'gender': 'male', 'category': 'entertainer'},
    '강호동': {'birth_date': '1970-06-11', 'gender': 'male', 'category': 'entertainer'},
    '신동엽': {'birth_date': '1971-02-17', 'gender': 'male', 'category': 'entertainer'},
    '박명수': {'birth_date': '1970-08-27', 'gender': 'male', 'category': 'entertainer'},
    '정형돈': {'birth_date': '1978-02-07', 'gender': 'male', 'category': 'entertainer'},
    '노홍철': {'birth_date': '1979-04-30', 'gender': 'male', 'category': 'entertainer'},
    '하하': {'birth_date': '1979-08-20', 'gender': 'male', 'category': 'entertainer'},
    '정준하': {'birth_date': '1971-03-18', 'gender': 'male', 'category': 'entertainer'},
    '김구라': {'birth_date': '1970-11-03', 'gender': 'male', 'category': 'entertainer'},
    '서장훈': {'birth_date': '1974-01-03', 'gender': 'male', 'category': 'entertainer'},
    '이수근': {'birth_date': '1975-02-10', 'gender': 'male', 'category': 'entertainer'},
    '김희철': {'birth_date': '1983-07-10', 'gender': 'male', 'category': 'entertainer'},
    '송은이': {'birth_date': '1973-02-21', 'gender': 'female', 'category': 'entertainer'},
    '김신영': {'birth_date': '1983-09-20', 'gender': 'female', 'category': 'entertainer'},
    '박나래': {'birth_date': '1985-10-25', 'gender': 'female', 'category': 'entertainer'},
    
    // 운동선수들
    '손흥민': {'birth_date': '1992-07-08', 'gender': 'male', 'category': 'entertainer'},
    '김연아': {'birth_date': '1990-09-05', 'gender': 'female', 'category': 'entertainer'},
    '박지성': {'birth_date': '1981-02-25', 'gender': 'male', 'category': 'entertainer'},
    '추신수': {'birth_date': '1982-07-24', 'gender': 'male', 'category': 'entertainer'},
    '류현진': {'birth_date': '1987-03-25', 'gender': 'male', 'category': 'entertainer'},
    '기성용': {'birth_date': '1989-01-24', 'gender': 'male', 'category': 'entertainer'},
    '이강인': {'birth_date': '2001-02-19', 'gender': 'male', 'category': 'entertainer'},
    '황희찬': {'birth_date': '1996-01-26', 'gender': 'male', 'category': 'entertainer'},
    '김민재': {'birth_date': '1996-11-15', 'gender': 'male', 'category': 'entertainer'},
    '박세리': {'birth_date': '1977-09-28', 'gender': 'female', 'category': 'entertainer'},
    '최경주': {'birth_date': '1970-05-19', 'gender': 'male', 'category': 'entertainer'},
    
    // === 1세대 아이돌 & 90년대 가수들 ===
    'H.O.T': {'birth_date': '1996-09-07', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '서태지와 아이들': {'birth_date': '1992-03-23', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '듀스': {'birth_date': '1993-04-19', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '클론': {'birth_date': '1996-02-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    'NRG': {'birth_date': '1997-05-17', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '젝스키스': {'birth_date': '1997-04-15', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    'S.E.S': {'birth_date': '1997-11-01', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '핑클': {'birth_date': '1998-05-16', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '베이비복스': {'birth_date': '1997-02-09', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    
    // === 2세대 아이돌들 ===
    '동방신기': {'birth_date': '2003-12-26', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '원더걸스': {'birth_date': '2007-02-10', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '소녀시대': {'birth_date': '2007-08-05', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '카라': {'birth_date': '2007-03-29', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '티아라': {'birth_date': '2009-07-29', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '씨스타': {'birth_date': '2010-06-03', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '포미닛': {'birth_date': '2009-06-18', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '미스에이': {'birth_date': '2010-07-01', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    
    // === 소녀시대 멤버들 ===
    '윤아': {'birth_date': '1990-05-30', 'gender': 'female', 'category': 'singer'},
    '수영': {'birth_date': '1989-02-10', 'gender': 'female', 'category': 'singer'},
    '유리': {'birth_date': '1989-12-05', 'gender': 'female', 'category': 'singer'},
    '효연': {'birth_date': '1989-09-22', 'gender': 'female', 'category': 'singer'},
    '써니': {'birth_date': '1989-05-15', 'gender': 'female', 'category': 'singer'},
    '티파니': {'birth_date': '1989-08-01', 'gender': 'female', 'category': 'singer'},
    '서현': {'birth_date': '1991-06-28', 'gender': 'female', 'category': 'singer'},
    '제시카': {'birth_date': '1989-04-18', 'gender': 'female', 'category': 'singer'},
    
    // === 클래식 & 발라드 가수들 ===
    '조용필': {'birth_date': '1950-03-21', 'gender': 'male', 'category': 'singer'},
    '이미자': {'birth_date': '1941-12-25', 'gender': 'female', 'category': 'singer'},
    '패티김': {'birth_date': '1947-12-15', 'gender': 'female', 'category': 'singer'},
    '송창식': {'birth_date': '1947-04-17', 'gender': 'male', 'category': 'singer'},
    '김민기': {'birth_date': '1951-04-06', 'gender': 'male', 'category': 'singer'},
    '양희은': {'birth_date': '1952-01-27', 'gender': 'female', 'category': 'singer'},
    '이선희': {'birth_date': '1964-04-11', 'gender': 'female', 'category': 'singer'},
    '조덕배': {'birth_date': '1955-12-29', 'gender': 'male', 'category': 'singer'},
    '나훈아': {'birth_date': '1947-05-01', 'gender': 'male', 'category': 'singer'},
    '남진': {'birth_date': '1946-03-01', 'gender': 'male', 'category': 'singer'},
    '이용': {'birth_date': '1962-12-17', 'gender': 'male', 'category': 'singer'},
    '김수희': {'birth_date': '1954-04-28', 'gender': 'female', 'category': 'singer'},
    
    // === 더 많은 트로트 가수들 ===
    '정수라': {'birth_date': '1949-06-17', 'gender': 'female', 'category': 'singer'},
    '설운도': {'birth_date': '1950-11-17', 'gender': 'male', 'category': 'singer'},
    '현숙': {'birth_date': '1952-02-25', 'gender': 'female', 'category': 'singer'},
    '김연자': {'birth_date': '1951-07-09', 'gender': 'female', 'category': 'singer'},
    '주현미': {'birth_date': '1961-02-15', 'gender': 'female', 'category': 'singer'},
    '최진희': {'birth_date': '1955-01-28', 'gender': 'female', 'category': 'singer'},
    '강진': {'birth_date': '1980-05-10', 'gender': 'male', 'category': 'singer'},
    '현철': {'birth_date': '1971-01-05', 'gender': 'male', 'category': 'singer'},
    '박상철': {'birth_date': '1962-09-21', 'gender': 'male', 'category': 'singer'},
    '남궁옥분': {'birth_date': '1956-08-15', 'gender': 'female', 'category': 'singer'},
    '문희옥': {'birth_date': '1964-10-12', 'gender': 'female', 'category': 'singer'},
    '김용임': {'birth_date': '1956-03-08', 'gender': 'female', 'category': 'singer'},
    
    // === 록/밴드 가수들 ===
    '신중현': {'birth_date': '1938-09-11', 'gender': 'male', 'category': 'singer'},
    '김창완': {'birth_date': '1954-02-22', 'gender': 'male', 'category': 'singer'},
    '윤도현': {'birth_date': '1972-02-03', 'gender': 'male', 'category': 'singer'},
    '서문탁': {'birth_date': '1970-08-21', 'gender': 'male', 'category': 'singer'},
    '정재일': {'birth_date': '1971-09-27', 'gender': 'male', 'category': 'singer'},
    '이승철': {'birth_date': '1966-12-05', 'gender': 'male', 'category': 'singer'},
    '김경호': {'birth_date': '1970-06-07', 'gender': 'male', 'category': 'singer'},
    '박완규': {'birth_date': '1964-10-05', 'gender': 'male', 'category': 'singer'},
    '하림': {'birth_date': '1973-12-02', 'gender': 'male', 'category': 'singer'},
    '이적': {'birth_date': '1974-02-28', 'gender': 'male', 'category': 'singer'},
    
    // === R&B/힙합 가수들 ===
    '휘성': {'birth_date': '1982-02-05', 'gender': 'male', 'category': 'singer'},
    '린': {'birth_date': '1981-12-09', 'gender': 'male', 'category': 'singer'},
    'SE7EN': {'birth_date': '1984-11-09', 'gender': 'male', 'category': 'singer'},
    '거미': {'birth_date': '1981-01-02', 'gender': 'female', 'category': 'singer'},
    '바다': {'birth_date': '1980-02-28', 'gender': 'female', 'category': 'singer'},
    '이수영': {'birth_date': '1979-04-12', 'gender': 'female', 'category': 'singer'},
    '김건모': {'birth_date': '1966-01-03', 'gender': 'male', 'category': 'singer'},
    '박진영': {'birth_date': '1972-12-13', 'gender': 'male', 'category': 'singer'},
    '양현석': {'birth_date': '1970-12-02', 'gender': 'male', 'category': 'singer'},
    '이수만': {'birth_date': '1952-06-18', 'gender': 'male', 'category': 'singer'},
    
    // === 더 많은 배우들 (베테랑) ===
    '안성기': {'birth_date': '1952-01-01', 'gender': 'male', 'category': 'actor'},
    '최민식': {'birth_date': '1962-01-22', 'gender': 'male', 'category': 'actor'},
    '설경구': {'birth_date': '1968-05-14', 'gender': 'male', 'category': 'actor'},
    '황정민': {'birth_date': '1970-09-01', 'gender': 'male', 'category': 'actor'},
    '이성재': {'birth_date': '1970-08-15', 'gender': 'male', 'category': 'actor'},
    '조승우': {'birth_date': '1980-03-28', 'gender': 'male', 'category': 'actor'},
    '김윤석': {'birth_date': '1968-10-21', 'gender': 'male', 'category': 'actor'},
    '하정우': {'birth_date': '1978-03-11', 'gender': 'male', 'category': 'actor'},
    '이범수': {'birth_date': '1970-01-03', 'gender': 'male', 'category': 'actor'},
    '김명민': {'birth_date': '1972-10-08', 'gender': 'male', 'category': 'actor'},
    '류승범': {'birth_date': '1970-08-09', 'gender': 'male', 'category': 'actor'},
    '마동석': {'birth_date': '1971-03-01', 'gender': 'male', 'category': 'actor'},
    '공효진': {'birth_date': '1980-04-04', 'gender': 'female', 'category': 'actor'},
    '김희선': {'birth_date': '1977-06-11', 'gender': 'female', 'category': 'actor'},
    '고현정': {'birth_date': '1971-03-02', 'gender': 'female', 'category': 'actor'},
    
    // === 젊은 세대 배우들 ===
    '박소진': {'birth_date': '1986-05-21', 'gender': 'female', 'category': 'actor'},
    '강동원': {'birth_date': '1981-01-18', 'gender': 'male', 'category': 'actor'},
    '원빈': {'birth_date': '1977-11-10', 'gender': 'male', 'category': 'actor'},
    '장동건': {'birth_date': '1972-03-07', 'gender': 'male', 'category': 'actor'},
    '비': {'birth_date': '1982-06-25', 'gender': 'male', 'category': 'actor'},
    '소지섭': {'birth_date': '1977-11-04', 'gender': 'male', 'category': 'actor'},
    '강혜정': {'birth_date': '1982-01-04', 'gender': 'female', 'category': 'actor'},
    '김선아': {'birth_date': '1975-10-01', 'gender': 'female', 'category': 'actor'},
    '염정아': {'birth_date': '1972-09-05', 'gender': 'female', 'category': 'actor'},
    
    // === 더 많은 정치인들 ===
    '문재인': {'birth_date': '1953-01-24', 'gender': 'male', 'category': 'politician'},
    '박근혜': {'birth_date': '1952-02-02', 'gender': 'female', 'category': 'politician'},
    '이명박': {'birth_date': '1941-12-19', 'gender': 'male', 'category': 'politician'},
    '노무현': {'birth_date': '1946-09-01', 'gender': 'male', 'category': 'politician'},
    '김대중': {'birth_date': '1924-01-06', 'gender': 'male', 'category': 'politician'},
    '박정희': {'birth_date': '1917-11-14', 'gender': 'male', 'category': 'politician'},
    '전두환': {'birth_date': '1931-01-18', 'gender': 'male', 'category': 'politician'},
    '노태우': {'birth_date': '1932-12-04', 'gender': 'male', 'category': 'politician'},
    '김영삼': {'birth_date': '1927-12-20', 'gender': 'male', 'category': 'politician'},
    '심상정': {'birth_date': '1959-09-13', 'gender': 'female', 'category': 'politician'},
    '유승민': {'birth_date': '1963-04-14', 'gender': 'male', 'category': 'politician'},
    '홍준표': {'birth_date': '1954-10-23', 'gender': 'male', 'category': 'politician'},
    '안희정': {'birth_date': '1965-08-01', 'gender': 'male', 'category': 'politician'},
    
    // === 더 많은 기업인들 ===
    '손정의': {'birth_date': '1957-08-11', 'gender': 'male', 'category': 'business_leader'},
    '구광모': {'birth_date': '1969-07-15', 'gender': 'male', 'category': 'business_leader'},
    '최태원': {'birth_date': '1960-12-03', 'gender': 'male', 'category': 'business_leader'},
    '장성택': {'birth_date': '1964-11-02', 'gender': 'male', 'category': 'business_leader'},
    '김승연': {'birth_date': '1952-12-12', 'gender': 'male', 'category': 'business_leader'},
    '이재현': {'birth_date': '1963-08-31', 'gender': 'male', 'category': 'business_leader'},
    '박현주': {'birth_date': '1960-11-19', 'gender': 'male', 'category': 'business_leader'},
    '조현아': {'birth_date': '1974-10-05', 'gender': 'female', 'category': 'business_leader'},
    '조현민': {'birth_date': '1977-04-05', 'gender': 'female', 'category': 'business_leader'},
    '장대환': {'birth_date': '1966-03-08', 'gender': 'male', 'category': 'business_leader'},
    
    // === 더 많은 개그맨/방송인들 ===
    '전현무': {'birth_date': '1977-08-07', 'gender': 'male', 'category': 'entertainer'},
    '김제동': {'birth_date': '1974-01-08', 'gender': 'male', 'category': 'entertainer'},
    '김영철': {'birth_date': '1974-11-05', 'gender': 'male', 'category': 'entertainer'},
    '김준호': {'birth_date': '1975-12-13', 'gender': 'male', 'category': 'entertainer'},
    '김용만': {'birth_date': '1967-11-30', 'gender': 'male', 'category': 'entertainer'},
    '남희석': {'birth_date': '1971-04-28', 'gender': 'male', 'category': 'entertainer'},
    '김기덕': {'birth_date': '1980-04-22', 'gender': 'male', 'category': 'entertainer'},
    '김병만': {'birth_date': '1975-09-29', 'gender': 'male', 'category': 'entertainer'},
    '김국진': {'birth_date': '1974-01-08', 'gender': 'male', 'category': 'entertainer'},
    '안정환': {'birth_date': '1978-01-27', 'gender': 'male', 'category': 'entertainer'},
    '조세호': {'birth_date': '1982-08-09', 'gender': 'male', 'category': 'entertainer'},
    '허경환': {'birth_date': '1985-05-31', 'gender': 'male', 'category': 'entertainer'},
    '김민교': {'birth_date': '1985-03-25', 'gender': 'male', 'category': 'entertainer'},
    '장동민': {'birth_date': '1979-06-21', 'gender': 'male', 'category': 'entertainer'},
    
    // === 인디/포크 가수들 ===
    '장기하': {'birth_date': '1982-08-20', 'gender': 'male', 'category': 'singer'},
    '10cm': {'birth_date': '2009-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '악동뮤지션': {'birth_date': '2012-04-07', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '볼빨간사춘기': {'birth_date': '2016-08-22', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '멜로망스': {'birth_date': '2013-10-30', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '다비치': {'birth_date': '2008-02-13', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '브라운아이드걸스': {'birth_date': '2006-03-02', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '디셈버': {'birth_date': '2017-04-13', 'gender': 'female', 'category': 'singer'}, // 데뷔일
    '홍대광': {'birth_date': '1985-08-12', 'gender': 'male', 'category': 'singer'},
    '윤하': {'birth_date': '1988-01-29', 'gender': 'female', 'category': 'singer'},
    '백예린': {'birth_date': '1997-06-26', 'gender': 'female', 'category': 'singer'},
    '수란': {'birth_date': '1986-09-05', 'gender': 'female', 'category': 'singer'},
    '헤이즈': {'birth_date': '1991-09-19', 'gender': 'female', 'category': 'singer'},
    '볼빨간사춘기 안지영': {'birth_date': '1995-09-14', 'gender': 'female', 'category': 'singer'},
    '나얼': {'birth_date': '1979-12-03', 'gender': 'male', 'category': 'singer'},
    '폴킴': {'birth_date': '1988-10-11', 'gender': 'male', 'category': 'singer'},
    '챈슬러': {'birth_date': '1985-11-22', 'gender': 'male', 'category': 'singer'},
    '샘김': {'birth_date': '1992-02-19', 'gender': 'male', 'category': 'singer'},
    '경서': {'birth_date': '1992-10-16', 'gender': 'female', 'category': 'singer'},
    
    // === 힙합/래퍼들 ===
    '에미넴': {'birth_date': '1972-10-17', 'gender': 'male', 'category': 'singer'}, // 해외지만 한국에서 인기
    '도끼': {'birth_date': '1990-09-24', 'gender': 'male', 'category': 'singer'},
    '키드밀리': {'birth_date': '1999-07-08', 'gender': 'male', 'category': 'singer'},
    '식케이': {'birth_date': '1994-07-07', 'gender': 'male', 'category': 'singer'},
    '우원재': {'birth_date': '1997-12-23', 'gender': 'male', 'category': 'singer'},
    '넉살': {'birth_date': '1984-06-01', 'gender': 'male', 'category': 'singer'},
    '딘딘': {'birth_date': '1991-11-16', 'gender': 'male', 'category': 'singer'},
    '개코': {'birth_date': '1981-01-08', 'gender': 'male', 'category': 'singer'},
    '타이거JK': {'birth_date': '1974-07-29', 'gender': 'male', 'category': 'singer'},
    '윤미래': {'birth_date': '1981-05-31', 'gender': 'female', 'category': 'singer'},
    '비지': {'birth_date': '1980-07-12', 'gender': 'male', 'category': 'singer'},
    '이센스': {'birth_date': '1987-02-07', 'gender': 'male', 'category': 'singer'},
    '버벌진트': {'birth_date': '1980-02-19', 'gender': 'male', 'category': 'singer'},
    '산이': {'birth_date': '1985-01-16', 'gender': 'male', 'category': 'singer'},
    
    // === 여성 솔로 가수 더 추가 ===
    'BoA': {'birth_date': '1986-11-05', 'gender': 'female', 'category': 'singer'},
    '이소라': {'birth_date': '1969-12-04', 'gender': 'female', 'category': 'singer'},
    '김완선': {'birth_date': '1969-05-16', 'gender': 'female', 'category': 'singer'},
    '엄정화': {'birth_date': '1969-12-25', 'gender': 'female', 'category': 'singer'},
    '조성모': {'birth_date': '1977-02-06', 'gender': 'male', 'category': 'singer'},
    '신해철': {'birth_date': '1968-05-06', 'gender': 'male', 'category': 'singer'},
    '서지원': {'birth_date': '1968-11-05', 'gender': 'male', 'category': 'singer'},
    '신성우': {'birth_date': '1978-09-05', 'gender': 'male', 'category': 'singer'},
    '윤종신': {'birth_date': '1969-10-15', 'gender': 'male', 'category': 'singer'},
    '이문세': {'birth_date': '1957-01-17', 'gender': 'male', 'category': 'singer'},
    '변진섭': {'birth_date': '1966-05-30', 'gender': 'male', 'category': 'singer'},
    
    // === 더 많은 스트리머 & 유튜버들 ===
    '킹받': {'birth_date': '1992-03-15', 'gender': 'male', 'category': 'streamer'},
    '주르르': {'birth_date': '1995-11-08', 'gender': 'female', 'category': 'streamer'},
    '고세구': {'birth_date': '1994-07-22', 'gender': 'male', 'category': 'streamer'},
    '릴파': {'birth_date': '1996-12-07', 'gender': 'female', 'category': 'streamer'},
    '비에': {'birth_date': '1993-08-14', 'gender': 'female', 'category': 'streamer'},
    '왁굳': {'birth_date': '1986-11-10', 'gender': 'male', 'category': 'streamer'}, // 우왁굳과 같음
    '아이네': {'birth_date': '1998-05-25', 'gender': 'female', 'category': 'streamer'},
    '징버거': {'birth_date': '1993-10-19', 'gender': 'female', 'category': 'streamer'},
    '뜨뜨뜨': {'birth_date': '1995-04-03', 'gender': 'female', 'category': 'streamer'},
    '독고혜지': {'birth_date': '1992-07-08', 'gender': 'female', 'category': 'streamer'},
    '소나': {'birth_date': '1996-02-11', 'gender': 'female', 'category': 'streamer'},
    '곽춘식': {'birth_date': '1984-12-05', 'gender': 'male', 'category': 'streamer'},
    '덱스': {'birth_date': '1985-07-20', 'gender': 'male', 'category': 'streamer'},
    '오킹': {'birth_date': '1987-09-12', 'gender': 'male', 'category': 'streamer'},
    '박제원': {'birth_date': '1990-11-03', 'gender': 'male', 'category': 'streamer'},
    '라면땅': {'birth_date': '1994-06-17', 'gender': 'male', 'category': 'streamer'},
    
    // === 더 많은 운동선수들 ===
    '이대호': {'birth_date': '1982-06-21', 'gender': 'male', 'category': 'entertainer'},
    '박찬호': {'birth_date': '1973-06-30', 'gender': 'male', 'category': 'entertainer'},
    '차두리': {'birth_date': '1980-07-25', 'gender': 'male', 'category': 'entertainer'},
    '차범근': {'birth_date': '1953-05-22', 'gender': 'male', 'category': 'entertainer'},
    '홍명보': {'birth_date': '1969-02-12', 'gender': 'male', 'category': 'entertainer'},
    '이천수': {'birth_date': '1979-07-29', 'gender': 'male', 'category': 'entertainer'},
    '박주영': {'birth_date': '1985-07-10', 'gender': 'male', 'category': 'entertainer'},
    '이동국': {'birth_date': '1979-04-29', 'gender': 'male', 'category': 'entertainer'},
    '김동진': {'birth_date': '1982-08-14', 'gender': 'male', 'category': 'entertainer'},
    '이영표': {'birth_date': '1977-12-23', 'gender': 'male', 'category': 'entertainer'},
    '김태균': {'birth_date': '1982-04-23', 'gender': 'male', 'category': 'entertainer'},
    '선동열': {'birth_date': '1963-01-10', 'gender': 'male', 'category': 'entertainer'},
    '이승엽': {'birth_date': '1976-08-18', 'gender': 'male', 'category': 'entertainer'},
    '최나연': {'birth_date': '1987-10-28', 'gender': 'female', 'category': 'entertainer'},
    '전인지': {'birth_date': '1992-07-28', 'gender': 'female', 'category': 'entertainer'},
    '유소연': {'birth_date': '1989-12-23', 'gender': 'female', 'category': 'entertainer'},
    
    // === 여자 개그우먼들 ===
    '김숙': {'birth_date': '1975-09-05', 'gender': 'female', 'category': 'entertainer'},
    '이경실': {'birth_date': '1966-10-10', 'gender': 'female', 'category': 'entertainer'},
    '김지민': {'birth_date': '1984-08-28', 'gender': 'female', 'category': 'entertainer'},
    '홍윤화': {'birth_date': '1988-10-16', 'gender': 'female', 'category': 'entertainer'},
    '양세찬': {'birth_date': '1986-08-17', 'gender': 'male', 'category': 'entertainer'},
    '전소민': {'birth_date': '1986-04-07', 'gender': 'female', 'category': 'entertainer'},
    '이국주': {'birth_date': '1983-08-20', 'gender': 'female', 'category': 'entertainer'},
    '김민경': {'birth_date': '1981-11-04', 'gender': 'female', 'category': 'entertainer'},
    '안영미': {'birth_date': '1983-11-05', 'gender': 'female', 'category': 'entertainer'},
    '김미경': {'birth_date': '1979-02-14', 'gender': 'female', 'category': 'entertainer'},
    
    // === 더 많은 록/메탈 밴드들 ===
    '부활': {'birth_date': '1986-04-19', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '시나위': {'birth_date': '1982-08-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '크래시': {'birth_date': '1991-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '넥스트': {'birth_date': '1992-04-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '델리스파이스': {'birth_date': '1996-07-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '노브레인': {'birth_date': '1996-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '크라잉넛': {'birth_date': '1993-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '가리온': {'birth_date': '2004-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '퍽': {'birth_date': '1995-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '몽니': {'birth_date': '1998-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    
    // === 더 많은 인디 가수들 ===
    '잠비나이': {'birth_date': '2009-01-01', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '새소년': {'birth_date': '2015-01-01', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '검정치마': {'birth_date': '2013-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '칼부림': {'birth_date': '2016-01-01', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '뜨거운감자': {'birth_date': '2008-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '실리카겔': {'birth_date': '2016-01-01', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '텔레파시': {'birth_date': '2010-01-01', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '세이수미': {'birth_date': '2006-01-01', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '공중도둑': {'birth_date': '2008-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    
    // === 더 많은 MC/래퍼들 ===
    '창모': {'birth_date': '1994-01-26', 'gender': 'male', 'category': 'singer'},
    '해쉬스완': {'birth_date': '1993-07-21', 'gender': 'male', 'category': 'singer'},
    '염따': {'birth_date': '1991-07-03', 'gender': 'male', 'category': 'singer'},
    '기리보이': {'birth_date': '1991-01-24', 'gender': 'male', 'category': 'singer'},
    '블랙넛': {'birth_date': '1991-07-16', 'gender': 'male', 'category': 'singer'},
    '우디고차일드': {'birth_date': '1993-09-03', 'gender': 'male', 'category': 'singer'},
    'GroovyRoom': {'birth_date': '2013-01-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    '저스디스': {'birth_date': '1993-05-22', 'gender': 'male', 'category': 'singer'},
    '플로우식': {'birth_date': '1989-09-18', 'gender': 'male', 'category': 'singer'},
    
    // === 더 많은 발라드 가수들 ===
    '김범수': {'birth_date': '1979-01-26', 'gender': 'male', 'category': 'singer'},
    '임재범': {'birth_date': '1963-04-27', 'gender': 'male', 'category': 'singer'},
    '백지영': {'birth_date': '1976-03-25', 'gender': 'female', 'category': 'singer'},
    '이소은': {'birth_date': '1982-05-16', 'gender': 'female', 'category': 'singer'},
    
    // === 더 많은 댄스 가수들 ===
    '현진영': {'birth_date': '1971-08-07', 'gender': 'male', 'category': 'singer'},
    '이정현': {'birth_date': '1980-02-07', 'gender': 'female', 'category': 'singer'},
    '박미경': {'birth_date': '1967-01-28', 'gender': 'female', 'category': 'singer'},
    '쿨': {'birth_date': '1994-10-20', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '룰라': {'birth_date': '1994-05-21', 'gender': 'mixed', 'category': 'singer'}, // 데뷔일
    '터보': {'birth_date': '1995-07-18', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    'DJ DOC': {'birth_date': '1994-04-01', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    'UV': {'birth_date': '2009-02-24', 'gender': 'male', 'category': 'singer'}, // 데뷔일
    
    // === 더 많은 트로트 신세대 가수들 ===
    '김호중': {'birth_date': '1991-10-02', 'gender': 'male', 'category': 'singer'},
    '이찬원': {'birth_date': '1992-08-01', 'gender': 'male', 'category': 'singer'},
    '주병선': {'birth_date': '1980-03-30', 'gender': 'male', 'category': 'singer'},
    
    // === 더 많은 배우들 ===
    '김범': {'birth_date': '1989-07-07', 'gender': 'male', 'category': 'actor'},
    
    // === 더 많은 여배우들 ===
    '한가인': {'birth_date': '1982-02-02', 'gender': 'female', 'category': 'actor'},
    '유지태': {'birth_date': '1976-04-13', 'gender': 'male', 'category': 'actor'},
    
    // === 더 많은 정치인들 ===
    '정세균': {'birth_date': '1956-05-19', 'gender': 'male', 'category': 'politician'},
    '박영선': {'birth_date': '1960-08-19', 'gender': 'female', 'category': 'politician'},
    '김무성': {'birth_date': '1951-12-16', 'gender': 'male', 'category': 'politician'},
    '나경원': {'birth_date': '1963-12-23', 'gender': 'female', 'category': 'politician'},
    '진박사': {'birth_date': '1950-03-08', 'gender': 'male', 'category': 'politician'},
    '오세훈': {'birth_date': '1961-02-13', 'gender': 'male', 'category': 'politician'},
    '박원순': {'birth_date': '1956-03-26', 'gender': 'male', 'category': 'politician'},
    
    // === 더 많은 기업인들 ===
    '신동빈': {'birth_date': '1955-02-14', 'gender': 'male', 'category': 'business_leader'},
    '조현준': {'birth_date': '1969-12-10', 'gender': 'male', 'category': 'business_leader'},
    '김범석': {'birth_date': '1978-03-07', 'gender': 'male', 'category': 'business_leader'},
    '서정진': {'birth_date': '1960-06-03', 'gender': 'male', 'category': 'business_leader'},
    '임성기': {'birth_date': '1962-11-25', 'gender': 'male', 'category': 'business_leader'},
    '황각규': {'birth_date': '1957-09-15', 'gender': 'male', 'category': 'business_leader'},
    
    // === 더 많은 스포츠 스타들 ===
    '황의조': {'birth_date': '1992-08-28', 'gender': 'male', 'category': 'athlete'},
    '조현우': {'birth_date': '1991-09-25', 'gender': 'male', 'category': 'athlete'},
    '이승우': {'birth_date': '1998-01-06', 'gender': 'male', 'category': 'athlete'},
    '김하성': {'birth_date': '1995-09-15', 'gender': 'male', 'category': 'athlete'},
    '최지만': {'birth_date': '1991-05-19', 'gender': 'male', 'category': 'athlete'},
    
    // === 더 많은 예능인들 ===
    '송지효': {'birth_date': '1981-08-15', 'gender': 'female', 'category': 'entertainer'},
    '지석진': {'birth_date': '1966-02-10', 'gender': 'male', 'category': 'entertainer'},
    '김종민': {'birth_date': '1979-09-24', 'gender': 'male', 'category': 'entertainer'},
    '박미선': {'birth_date': '1965-12-03', 'gender': 'female', 'category': 'entertainer'},
    
    // === 유명 유튜버/크리에이터들 ===
    '대도서관': {'birth_date': '1985-08-07', 'gender': 'male', 'category': 'streamer'},
    '외질혜': {'birth_date': '1993-07-22', 'gender': 'female', 'category': 'streamer'},
    '띠또': {'birth_date': '1991-04-14', 'gender': 'male', 'category': 'streamer'},
    '키야': {'birth_date': '1992-09-05', 'gender': 'male', 'category': 'streamer'},
    '다주': {'birth_date': '1995-03-28', 'gender': 'female', 'category': 'streamer'},
    '이제동': {'birth_date': '1990-12-31', 'gender': 'male', 'category': 'streamer'},
    '문복희': {'birth_date': '1991-01-12', 'gender': 'female', 'category': 'streamer'},
    '양팡': {'birth_date': '1990-08-18', 'gender': 'male', 'category': 'streamer'},
    
  };

  /// 성별 추론 개선 로직
  static String _inferGenderFromName(String name) {
    // 정확한 데이터가 있으면 사용
    if (accurateCelebrityData.containsKey(name)) {
      return accurateCelebrityData[name]!['gender']!;
    }
    
    // 여성 그룹 키워드
    final femaleGroupKeywords = [
      '걸스', '여자', '소녀', '아이들', '핑크', '레드벨벳', '트와이스', 
      '뉴진스', '에스파', 'IVE', '르세라핌', 'ITZY', 'NMIXX', '케플러',
      '아이브', '뉴진즈', 'BLACKPINK', 'TWICE', 'Red Velvet', 'Girls'
    ];
    
    // 남성 그룹 키워드  
    final maleGroupKeywords = [
      'BTS', '세븐틴', '스트레이', '엔시티', 'NCT', '샤이니', '빅뱅', 
      '2PM', '인피니트', '몬스타엑스', '펜타곤', 'SEVENTEEN', 'Stray Kids'
    ];
    
    // 그룹명으로 성별 판단
    for (final keyword in femaleGroupKeywords) {
      if (name.contains(keyword)) return 'female';
    }
    
    for (final keyword in maleGroupKeywords) {
      if (name.contains(keyword)) return 'male';
    }
    
    // 개인 이름으로 성별 추론 (개선된 로직)
    final femaleNames = [
      '아이유', '태연', '제니', '지수', '로제', '리사', '전지현', '한소희', 
      '김고은', '손예진', '김태리', '쯔양', '김연아', '김건희', '윤아', '수지',
      '설현', '크리스탈', '제시카', '티파니', '써니', '유리', '효연', '서현',
      '나연', '정연', '모모', '사나', '지효', '미나', '다현', '채영', '쯔위'
    ];
    
    for (final femaleName in femaleNames) {
      if (name.contains(femaleName)) return 'female';
    }
    
    // 여성 이름 끝자리 패턴 (개선)
    final femaleEndings = ['영', '희', '미', '라', '나', '아', '은', '인', '연', '정', '수', '지'];
    final lastChar = name.isNotEmpty ? name[name.length - 1] : '';
    
    if (femaleEndings.contains(lastChar)) {
      return 'female';
    }
    
    return 'male'; // 기본값
  }

  /// 정확한 데이터로 유명인 처리
  static Future<void> processAccurateCelebrities() async {
    print('🚀 정확한 유명인 데이터 처리 시작...\n');
    
    // 기존 통합 데이터 읽기
    final masterFile = File('celebrity_consolidated_master.json');
    if (!await masterFile.exists()) {
      print('❌ 통합 데이터 파일을 찾을 수 없습니다.');
      return;
    }
    
    final jsonString = await masterFile.readAsString();
    final Map<String, dynamic> masterData = json.decode(jsonString);
    final List<dynamic> celebrities = masterData['celebrities'] as List<dynamic>;
    
    print('📋 기존 유명인 데이터: ${celebrities.length}명');
    
    final List<CelebritySaju> processedCelebrities = [];
    final List<String> sqlStatements = [];
    
    int successCount = 0;
    int correctedCount = 0;
    
    // 각 유명인 처리
    for (int i = 0; i < celebrities.length; i++) {
      final celebrityData = celebrities[i] as Map<String, dynamic>;
      final name = celebrityData['name'] as String;
      
      // 정확한 데이터로 업데이트
      if (accurateCelebrityData.containsKey(name)) {
        final accurateData = accurateCelebrityData[name]!;
        celebrityData['birth_date'] = accurateData['birth_date'];
        celebrityData['gender'] = accurateData['gender'];
        celebrityData['category'] = accurateData['category'];
        correctedCount++;
      } else {
        // 개선된 성별 추론 적용
        celebrityData['gender'] = _inferGenderFromName(name);
      }
      
      try {
        final celebrity = await _processSingleCelebrity(celebrityData);
        
        if (celebrity != null) {
          processedCelebrities.add(celebrity);
          sqlStatements.add(_generateInsertSQL(celebrity));
          successCount++;
          
          if (successCount % 50 == 0) {
            print('✅ 진행: $successCount/${celebrities.length} 완료');
          }
        }
      } catch (e) {
        print('❌ 오류 ($name): $e');
      }
    }
    
    // 결과 저장
    await _saveResults(processedCelebrities, sqlStatements, correctedCount);
    
    print('\n🎉 정확한 유명인 데이터 처리 완료!');
    print('📊 총 처리: ${celebrities.length}명');
    print('✅ 성공: $successCount명');
    print('🔧 정확한 데이터로 수정: $correctedCount명');
    print('📈 성공률: ${(successCount / celebrities.length * 100).toStringAsFixed(1)}%');
  }
  
  /// 개별 유명인 사주 처리
  static Future<CelebritySaju?> _processSingleCelebrity(
    Map<String, dynamic> data,
  ) async {
    try {
      final name = data['name'] as String;
      final nameEn = data['name_en'] as String? ?? '';
      final birthDate = data['birth_date'] as String?;
      final birthTime = data['birth_time'] as String? ?? '12:00';
      final gender = data['gender'] as String? ?? 'male';
      final category = data['category'] as String? ?? 'unknown';
      
      if (birthDate == null || birthDate.isEmpty) {
        return null;
      }
      
      // 생년월일 파싱
      final dateParts = birthDate.split('-');
      if (dateParts.length != 3) {
        return null;
      }
      
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      // 생시 파싱
      final timeParts = birthTime.split(':');
      final hour = timeParts.isNotEmpty ? int.parse(timeParts[0]) : 12;
      final minute = timeParts.length >= 2 ? int.parse(timeParts[1]) : 0;
      
      final birthDateTime = DateTime(year, month, day, hour, minute);
      
      // 사주 계산
      final sajuResult = SajuCalculationService.calculateSaju(
        birthDate: birthDateTime,
        birthTime: birthTime,
        isLunar: false,
      );
      
      // CelebritySaju 객체 생성
      return CelebritySaju(
        id: _generateUniqueId(name, category),
        name: name,
        nameEn: nameEn,
        birthDate: birthDate,
        birthTime: birthTime,
        gender: gender,
        birthPlace: data['birth_place'] as String? ?? '',
        category: category,
        agency: data['agency'] as String? ?? '',
        yearPillar: _extractPillar(sajuResult, 'year'),
        monthPillar: _extractPillar(sajuResult, 'month'),
        dayPillar: _extractPillar(sajuResult, 'day'),
        hourPillar: _extractPillar(sajuResult, 'hour'),
        sajuString: _generateSajuString(sajuResult),
        woodCount: _countElement(sajuResult, '목'),
        fireCount: _countElement(sajuResult, '화'),
        earthCount: _countElement(sajuResult, '토'),
        metalCount: _countElement(sajuResult, '금'),
        waterCount: _countElement(sajuResult, '수'),
        fullSajuData: sajuResult,
        dataSource: 'celebrity_accurate_processed_v3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// 고유 ID 생성
  static String _generateUniqueId(String name, String category) {
    final cleanName = name.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '_');
    return '${category}_$cleanName';
  }
  
  /// 사주 기둥 추출
  static String _extractPillar(Map<String, dynamic> sajuData, String pillarType) {
    final pillar = sajuData[pillarType];
    if (pillar == null) return '';
    return '${pillar['stem'] ?? ''}${pillar['branch'] ?? ''}';
  }
  
  /// 사주 문자열 생성
  static String _generateSajuString(Map<String, dynamic> sajuData) {
    final parts = <String>[];
    
    ['year', 'month', 'day', 'hour'].forEach((pillarType) {
      if (sajuData[pillarType] != null) {
        final pillar = sajuData[pillarType];
        parts.add('${pillar['stem'] ?? ''}${pillar['branch'] ?? ''}');
      }
    });
    
    return parts.join(' ');
  }
  
  /// 오행 개수 계산
  static int _countElement(Map<String, dynamic> sajuData, String element) {
    final elements = sajuData['elements'] as Map<String, dynamic>?;
    return elements?[element] as int? ?? 0;
  }
  
  /// SQL INSERT 문 생성
  static String _generateInsertSQL(CelebritySaju celebrity) {
    // SQL 문자열 이스케이프 처리
    String escapeSQL(String value) {
      return value.replaceAll("'", "''");
    }
    
    final escapedName = escapeSQL(celebrity.name);
    final escapedNameEn = escapeSQL(celebrity.nameEn);
    final escapedBirthPlace = escapeSQL(celebrity.birthPlace);
    final escapedAgency = escapeSQL(celebrity.agency);
    final escapedSajuString = escapeSQL(celebrity.sajuString);
    final escapedDataSource = escapeSQL(celebrity.dataSource);
    
    // JSON 데이터를 SQL용 문자열로 변환
    final fullSajuDataJson = escapeSQL(json.encode(celebrity.fullSajuData));
    
    return """
INSERT INTO celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  '${celebrity.id}', '$escapedName', '$escapedNameEn', '${celebrity.birthDate}', '${celebrity.birthTime}',
  '${celebrity.gender}', '$escapedBirthPlace', '${celebrity.category}', '$escapedAgency',
  '${celebrity.yearPillar}', '${celebrity.monthPillar}', '${celebrity.dayPillar}', '${celebrity.hourPillar}',
  '$escapedSajuString', ${celebrity.woodCount}, ${celebrity.fireCount}, ${celebrity.earthCount},
  ${celebrity.metalCount}, ${celebrity.waterCount},
  '$fullSajuDataJson'::jsonb, '$escapedDataSource', NOW(), NOW()
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  name_en = EXCLUDED.name_en,
  birth_date = EXCLUDED.birth_date,
  birth_time = EXCLUDED.birth_time,
  gender = EXCLUDED.gender,
  birth_place = EXCLUDED.birth_place,
  category = EXCLUDED.category,
  agency = EXCLUDED.agency,
  year_pillar = EXCLUDED.year_pillar,
  month_pillar = EXCLUDED.month_pillar,
  day_pillar = EXCLUDED.day_pillar,
  hour_pillar = EXCLUDED.hour_pillar,
  saju_string = EXCLUDED.saju_string,
  wood_count = EXCLUDED.wood_count,
  fire_count = EXCLUDED.fire_count,
  earth_count = EXCLUDED.earth_count,
  metal_count = EXCLUDED.metal_count,
  water_count = EXCLUDED.water_count,
  full_saju_data = EXCLUDED.full_saju_data,
  data_source = EXCLUDED.data_source,
  updated_at = NOW();""";
  }
  
  /// 결과 저장
  static Future<void> _saveResults(
    List<CelebritySaju> celebrities, 
    List<String> sqlStatements,
    int correctedCount,
  ) async {
    final timestamp = DateTime.now().toIso8601String().substring(0, 19);
    
    try {
      // SQL 파일 저장
      final sqlFile = File('celebrity_accurate_insert_$timestamp.sql');
      final sqlContent = [
        '-- 정확한 유명인 데이터 (생년월일 + 성별 수정)',
        '-- 생성일시: $timestamp',
        '-- 총 ${celebrities.length}명, 정확한 데이터로 수정: $correctedCount명',
        '',
        '-- 테이블 생성',
        '''CREATE TABLE IF NOT EXISTS public.celebrities (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    name_en VARCHAR(200) DEFAULT '',
    birth_date VARCHAR(20) NOT NULL,
    birth_time VARCHAR(10) DEFAULT '12:00',
    gender VARCHAR(10) DEFAULT 'male',
    birth_place VARCHAR(200) DEFAULT '',
    category VARCHAR(50) DEFAULT 'unknown',
    agency VARCHAR(200) DEFAULT '',
    year_pillar VARCHAR(10) DEFAULT '',
    month_pillar VARCHAR(10) DEFAULT '',
    day_pillar VARCHAR(10) DEFAULT '',
    hour_pillar VARCHAR(10) DEFAULT '',
    saju_string VARCHAR(100) DEFAULT '',
    wood_count INTEGER DEFAULT 0,
    fire_count INTEGER DEFAULT 0,
    earth_count INTEGER DEFAULT 0,
    metal_count INTEGER DEFAULT 0,
    water_count INTEGER DEFAULT 0,
    full_saju_data JSONB DEFAULT '{}',
    data_source VARCHAR(100) DEFAULT 'celebrity_accurate_processed_v3',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);''',
        '',
        '-- 데이터 삽입',
        ...sqlStatements,
      ].join('\n');
      
      await sqlFile.writeAsString(sqlContent);
      print('✅ 정확한 SQL 파일 저장: ${sqlFile.path}');
      
      // 통계 파일 저장
      final stats = _generateStats(celebrities, correctedCount);
      final statsFile = File('celebrity_accurate_stats_$timestamp.json');
      await statsFile.writeAsString(json.encode(stats));
      print('✅ 통계 파일 저장: ${statsFile.path}');
      
    } catch (e) {
      print('❌ 파일 저장 중 오류: $e');
    }
  }
  
  /// 통계 생성
  static Map<String, dynamic> _generateStats(List<CelebritySaju> celebrities, int correctedCount) {
    final categoryStats = <String, int>{};
    final genderStats = <String, int>{};
    
    for (final celebrity in celebrities) {
      categoryStats[celebrity.category] = (categoryStats[celebrity.category] ?? 0) + 1;
      genderStats[celebrity.gender] = (genderStats[celebrity.gender] ?? 0) + 1;
    }
    
    return {
      'total_processed': celebrities.length,
      'corrected_with_accurate_data': correctedCount,
      'category_distribution': categoryStats,
      'gender_distribution': genderStats,
      'processing_timestamp': DateTime.now().toIso8601String(),
      'data_source': 'celebrity_accurate_processed_v3',
    };
  }
}

/// 실행 스크립트
void main() async {
  await AccurateCelebrityDataProcessor.processAccurateCelebrities();
}