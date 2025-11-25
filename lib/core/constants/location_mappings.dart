/// 위치 관련 상수 및 매핑 데이터
class LocationMappings {
  LocationMappings._(); // Private constructor to prevent instantiation

  /// 영문 도시명 → 한글 도시명 매핑
  ///
  /// 주요 국내외 도시의 한글 표기를 제공합니다.
  static const Map<String, String> cityNameKorean = {
    // 대한민국
    'Seoul': '서울',
    'Busan': '부산',
    'Incheon': '인천',
    'Daegu': '대구',
    'Daejeon': '대전',
    'Gwangju': '광주',
    'Ulsan': '울산',
    'Suwon': '수원',
    'Seongnam': '성남',
    'Goyang': '고양',
    'Yongin': '용인',
    'Bucheon': '부천',
    'Ansan': '안산',
    'Cheongju': '청주',
    'Jeonju': '전주',
    'Anyang': '안양',
    'Pohang': '포항',
    'Changwon': '창원',
    'Jeju': '제주',

    // 일본
    'Tokyo': '도쿄',
    'Osaka': '오사카',
    'Kyoto': '교토',
    'Yokohama': '요코하마',
    'Nagoya': '나고야',
    'Sapporo': '삿포로',
    'Fukuoka': '후쿠오카',
    'Kobe': '고베',
    'Hiroshima': '히로시마',
    'Sendai': '센다이',

    // 중국
    'Beijing': '베이징',
    'Shanghai': '상하이',
    'Guangzhou': '광저우',
    'Shenzhen': '선전',
    'Chengdu': '청두',
    'Hangzhou': '항저우',
    'Wuhan': '우한',
    'Xian': '시안',
    'Chongqing': '충칭',
    'Tianjin': '톈진',

    // 대만
    'Taipei': '타이베이',
    'Kaohsiung': '가오슝',
    'Taichung': '타이중',

    // 홍콩/마카오
    'Hong Kong': '홍콩',
    'Macau': '마카오',

    // 동남아시아
    'Bangkok': '방콕',
    'Singapore': '싱가포르',
    'Manila': '마닐라',
    'Jakarta': '자카르타',
    'Kuala Lumpur': '쿠알라룸푸르',
    'Ho Chi Minh City': '호치민',
    'Hanoi': '하노이',
    'Phnom Penh': '프놈펜',
    'Yangon': '양곤',

    // 인도
    'New Delhi': '뉴델리',
    'Mumbai': '뭄바이',
    'Bangalore': '방갈로르',
    'Chennai': '첸나이',
    'Kolkata': '콜카타',

    // 중동
    'Dubai': '두바이',
    'Abu Dhabi': '아부다비',
    'Doha': '도하',
    'Riyadh': '리야드',
    'Tel Aviv': '텔아비브',
    'Istanbul': '이스탄불',

    // 유럽
    'London': '런던',
    'Paris': '파리',
    'Berlin': '베를린',
    'Rome': '로마',
    'Madrid': '마드리드',
    'Barcelona': '바르셀로나',
    'Amsterdam': '암스테르담',
    'Vienna': '빈',
    'Prague': '프라하',
    'Athens': '아테네',
    'Moscow': '모스크바',
    'Stockholm': '스톡홀름',
    'Copenhagen': '코펜하겐',
    'Oslo': '오슬로',
    'Helsinki': '헬싱키',
    'Warsaw': '바르샤바',
    'Budapest': '부다페스트',
    'Brussels': '브뤼셀',
    'Zurich': '취리히',
    'Geneva': '제네바',

    // 북미
    'New York': '뉴욕',
    'Los Angeles': '로스앤젤레스',
    'San Francisco': '샌프란시스코',
    'Chicago': '시카고',
    'Boston': '보스턴',
    'Seattle': '시애틀',
    'Washington': '워싱턴',
    'Miami': '마이애미',
    'Las Vegas': '라스베이거스',
    'Toronto': '토론토',
    'Vancouver': '밴쿠버',
    'Montreal': '몬트리올',
    'Mexico City': '멕시코시티',

    // 남미
    'Sao Paulo': '상파울루',
    'Rio de Janeiro': '리우데자네이루',
    'Buenos Aires': '부에노스아이레스',
    'Lima': '리마',
    'Bogota': '보고타',
    'Santiago': '산티아고',

    // 오세아니아
    'Sydney': '시드니',
    'Melbourne': '멜버른',
    'Brisbane': '브리즈번',
    'Perth': '퍼스',
    'Auckland': '오클랜드',

    // 아프리카
    'Cairo': '카이로',
    'Lagos': '라고스',
    'Johannesburg': '요하네스버그',
    'Cape Town': '케이프타운',
    'Nairobi': '나이로비',
  };

  /// 전체 지역명에서 구/시 이름 추출
  ///
  /// 예시:
  /// - "서울 강남구" → "강남구"
  /// - "경기 성남시" → "성남시"
  /// - "부산 해운대구" → "해운대구"
  /// - "도쿄" → "도쿄" (그대로 반환)
  static String extractDistrict(String fullName) {
    if (fullName.isEmpty) return fullName;

    // 서울/부산/대구/인천/광주/대전/울산 + 구/군
    if (fullName.startsWith('서울')) {
      return fullName.replaceFirst('서울 ', '').replaceFirst('서울', '');
    }
    if (fullName.startsWith('부산')) {
      return fullName.replaceFirst('부산 ', '').replaceFirst('부산', '');
    }
    if (fullName.startsWith('대구')) {
      return fullName.replaceFirst('대구 ', '').replaceFirst('대구', '');
    }
    if (fullName.startsWith('인천')) {
      return fullName.replaceFirst('인천 ', '').replaceFirst('인천', '');
    }
    if (fullName.startsWith('광주')) {
      return fullName.replaceFirst('광주 ', '').replaceFirst('광주', '');
    }
    if (fullName.startsWith('대전')) {
      return fullName.replaceFirst('대전 ', '').replaceFirst('대전', '');
    }
    if (fullName.startsWith('울산')) {
      return fullName.replaceFirst('울산 ', '').replaceFirst('울산', '');
    }

    // 경기/강원/충청/전라/경상 + 시/군
    if (fullName.contains(' ')) {
      final parts = fullName.split(' ');
      // 마지막 부분 반환 (예: "경기 성남시" → "성남시")
      return parts.last;
    }

    // 공백 없으면 그대로 반환
    return fullName;
  }

  /// 영문 도시명을 한글로 변환
  ///
  /// 매핑이 없으면 원본 반환
  static String toKorean(String englishName) {
    return cityNameKorean[englishName] ?? englishName;
  }

  /// 한글 도시명을 영문으로 변환 (역매핑)
  ///
  /// 매핑이 없으면 원본 반환
  static String toEnglish(String koreanName) {
    for (final entry in cityNameKorean.entries) {
      if (entry.value == koreanName) {
        return entry.key;
      }
    }
    return koreanName;
  }

  /// 도시명이 매핑에 존재하는지 확인
  static bool hasMapping(String cityName) {
    return cityNameKorean.containsKey(cityName) ||
        cityNameKorean.containsValue(cityName);
  }

  /// 지역명 정규화 (양쪽 공백 제거, 중복 공백 제거)
  static String normalize(String locationName) {
    return locationName.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 지역명이 한국인지 확인
  static bool isKoreanLocation(String locationName) {
    final koreanCities = [
      '서울',
      '부산',
      '인천',
      '대구',
      '대전',
      '광주',
      '울산',
      '경기',
      '강원',
      '충청',
      '충남',
      '충북',
      '전라',
      '전남',
      '전북',
      '경상',
      '경남',
      '경북',
      '제주',
    ];

    return koreanCities.any((city) => locationName.contains(city));
  }
}
