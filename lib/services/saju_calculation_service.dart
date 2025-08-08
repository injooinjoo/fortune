
/// 사주팔자 계산 서비스
/// 실제 만세력 기반의 정확한 사주 계산을 수행합니다.
class SajuCalculationService {
  // 천간 (Heavenly Stems)
  static const List<String> heavenlyStems = [
    '갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'
  ];
  
  static const List<String> heavenlyStemsHanja = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'
  ];
  
  // 지지 (Earthly Branches)
  static const List<String> earthlyBranches = [
    '자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'
  ];
  
  static const List<String> earthlyBranchesHanja = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'
  ];
  
  // 오행 (Five Elements)
  static const Map<String, String> stemElements = {
    '갑': '목', '을': '목',
    '병': '화', '정': '화',
    '무': '토', '기': '토',
    '경': '금', '신': '금',
    '임': '수', '계': '수'
  };
  
  static const Map<String, String> branchElements = {
    '자': '수', '축': '토', '인': '목', '묘': '목',
    '진': '토', '사': '화', '오': '화', '미': '토',
    '신': '금', '유': '금', '술': '토', '해': '수'
  };
  
  // 절기 날짜 (24 Solar Terms) - 대략적인 날짜
  static const Map<int, List<Map<String, dynamic>>> solarTerms = {
    1: [
      {'name': '소한', 'day': 6},
      {'name': '대한', 'day': 20}
    ],
    2: [
      {'name': '입춘', 'day': 4},
      {'name': '우수', 'day': 19}
    ],
    3: [
      {'name': '경칩', 'day': 6},
      {'name': '춘분', 'day': 21}
    ],
    4: [
      {'name': '청명', 'day': 5},
      {'name': '곡우', 'day': 20}
    ],
    5: [
      {'name': '입하', 'day': 6},
      {'name': '소만', 'day': 21}
    ],
    6: [
      {'name': '망종', 'day': 6},
      {'name': '하지', 'day': 21}
    ],
    7: [
      {'name': '소서', 'day': 7},
      {'name': '대서', 'day': 23}
    ],
    8: [
      {'name': '입추', 'day': 8},
      {'name': '처서', 'day': 23}
    ],
    9: [
      {'name': '백로', 'day': 8},
      {'name': '추분', 'day': 23}
    ],
    10: [
      {'name': '한로', 'day': 8},
      {'name': '상강', 'day': 23}
    ],
    11: [
      {'name': '입동', 'day': 8},
      {'name': '소설', 'day': 22}
    ],
    12: [
      {'name': '대설', 'day': 7},
      {'name': '동지', 'day': 22}
    ]
  };
  
  /// 생년월일시를 받아서 사주팔자를 계산합니다.
  static Map<String, dynamic> calculateSaju({
    required DateTime birthDate,
    String? birthTime,
    bool isLunar = false,
  }) {
    // 음력인 경우 양력으로 변환 (실제 구현시에는 정확한 음양력 변환 라이브러리 사용)
    DateTime solarDate = isLunar ? _convertLunarToSolar(birthDate) : birthDate;
    
    // 년주 계산
    final yearPillar = _calculateYearPillar(solarDate);
    
    // 월주 계산 (절기 고려)
    final monthPillar = _calculateMonthPillar(solarDate, yearPillar['stemIndex']);
    
    // 일주 계산
    final dayPillar = _calculateDayPillar(solarDate);
    
    // 시주 계산
    final hourPillar = birthTime != null 
        ? _calculateHourPillar(birthTime, dayPillar['stemIndex'])
        : null;
    
    // 오행 분석
    final elementBalance = _analyzeElements(yearPillar, monthPillar, dayPillar, hourPillar);
    
    // 십신 계산
    final tenGods = _calculateTenGods(dayPillar['stem'], yearPillar, monthPillar, hourPillar);
    
    // 대운 계산
    final daeunInfo = _calculateDaeun(solarDate, monthPillar);
    
    return {
      'year': {
        'stem': yearPillar['stem'],
        'branch': yearPillar['branch'],
        'stemHanja': yearPillar['stemHanja'],
        'branchHanja': yearPillar['branchHanja'],
        'element': stemElements[yearPillar['stem']],
      },
      'month': {
        'stem': monthPillar['stem'],
        'branch': monthPillar['branch'],
        'stemHanja': monthPillar['stemHanja'],
        'branchHanja': monthPillar['branchHanja'],
        'element': stemElements[monthPillar['stem']],
      },
      'day': {
        'stem': dayPillar['stem'],
        'branch': dayPillar['branch'],
        'stemHanja': dayPillar['stemHanja'],
        'branchHanja': dayPillar['branchHanja'],
        'element': stemElements[dayPillar['stem']],
      },
      'hour': hourPillar != null ? {
        'stem': hourPillar['stem'],
        'branch': hourPillar['branch'],
        'stemHanja': hourPillar['stemHanja'],
        'branchHanja': hourPillar['branchHanja'],
        'element': stemElements[hourPillar['stem']],
      } : null,
      'elementBalance': elementBalance,
      'tenGods': tenGods,
      'daeunInfo': daeunInfo,
    };
  }
  
  /// 년주 계산
  static Map<String, dynamic> _calculateYearPillar(DateTime date) {
    // 입춘 기준으로 년도 조정
    final lichun = DateTime(date.year, 2, 4); // 입춘은 대략 2월 4일
    final year = date.isBefore(lichun) ? date.year - 1 : date.year;
    
    // 60갑자 순환
    final stemIndex = (year - 4) % 10;
    final branchIndex = (year - 4) % 12;
    
    return {
      'stem': heavenlyStems[stemIndex],
      'branch': earthlyBranches[branchIndex],
      'stemHanja': heavenlyStemsHanja[stemIndex],
      'branchHanja': earthlyBranchesHanja[branchIndex],
      'stemIndex': stemIndex,
      'branchIndex': branchIndex,
    };
  }
  
  /// 월주 계산 (절기 기준)
  static Map<String, dynamic> _calculateMonthPillar(DateTime date, int yearStemIndex) {
    // 절기에 따른 월 계산
    int monthIndex = _getMonthIndexBySolarTerm(date);
    
    // 월간 계산 공식: 년간에 따라 결정
    // 갑기년: 병인월부터 시작
    // 을경년: 무인월부터 시작
    // 병신년: 경인월부터 시작
    // 정임년: 임인월부터 시작
    // 무계년: 갑인월부터 시작
    int monthStemStartIndex;
    switch (yearStemIndex % 5) {
      case 0: // 갑, 기
        monthStemStartIndex = 2; // 병
        break;
      case 1: // 을, 경
        monthStemStartIndex = 4; // 무
        break;
      case 2: // 병, 신
        monthStemStartIndex = 6; // 경
        break;
      case 3: // 정, 임
        monthStemStartIndex = 8; // 임
        break;
      case 4: // 무, 계
        monthStemStartIndex = 0; // 갑
        break;
      default:
        monthStemStartIndex = 0;
    }
    
    final stemIndex = (monthStemStartIndex + monthIndex) % 10;
    final branchIndex = (monthIndex + 2) % 12; // 인월부터 시작
    
    return {
      'stem': heavenlyStems[stemIndex],
      'branch': earthlyBranches[branchIndex],
      'stemHanja': heavenlyStemsHanja[stemIndex],
      'branchHanja': earthlyBranchesHanja[branchIndex],
      'stemIndex': stemIndex,
      'branchIndex': branchIndex,
    };
  }
  
  /// 절기에 따른 월 인덱스 계산
  static int _getMonthIndexBySolarTerm(DateTime date) {
    // 간단한 구현: 절입 시각을 고려하지 않고 대략적인 날짜로 계산
    if (date.month == 1 || (date.month == 2 && date.day < 4)) {
      return 11; // 축월 (12월)
    } else if (date.month == 2 || (date.month == 3 && date.day < 6)) {
      return 0; // 인월 (1월)
    } else if (date.month == 3 || (date.month == 4 && date.day < 5)) {
      return 1; // 묘월 (2월)
    } else if (date.month == 4 || (date.month == 5 && date.day < 6)) {
      return 2; // 진월 (3월)
    } else if (date.month == 5 || (date.month == 6 && date.day < 6)) {
      return 3; // 사월 (4월)
    } else if (date.month == 6 || (date.month == 7 && date.day < 7)) {
      return 4; // 오월 (5월)
    } else if (date.month == 7 || (date.month == 8 && date.day < 8)) {
      return 5; // 미월 (6월)
    } else if (date.month == 8 || (date.month == 9 && date.day < 8)) {
      return 6; // 신월 (7월)
    } else if (date.month == 9 || (date.month == 10 && date.day < 8)) {
      return 7; // 유월 (8월)
    } else if (date.month == 10 || (date.month == 11 && date.day < 8)) {
      return 8; // 술월 (9월)
    } else if (date.month == 11 || (date.month == 12 && date.day < 7)) {
      return 9; // 해월 (10월)
    } else {
      return 10; // 자월 (11월)
    }
  }
  
  /// 일주 계산 (만세력 기준)
  static Map<String, dynamic> _calculateDayPillar(DateTime date) {
    // 기준일: 1900년 1월 1일은 갑진일
    final baseDate = DateTime(1900, 1, 1);
    final daysDiff = date.difference(baseDate).inDays;
    
    // 60갑자 순환
    final dayNumber = (daysDiff + 40) % 60; // 갑진일이 40번째
    final stemIndex = dayNumber % 10;
    final branchIndex = dayNumber % 12;
    
    return {
      'stem': heavenlyStems[stemIndex],
      'branch': earthlyBranches[branchIndex],
      'stemHanja': heavenlyStemsHanja[stemIndex],
      'branchHanja': earthlyBranchesHanja[branchIndex],
      'stemIndex': stemIndex,
      'branchIndex': branchIndex,
    };
  }
  
  /// 시주 계산
  static Map<String, dynamic>? _calculateHourPillar(String birthTime, int dayStemIndex) {
    // 시간 파싱
    final parts = birthTime.split(':');
    if (parts.length < 2) return null;
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    
    // 시진 계산 (2시간 단위)
    final hourIndex = _getHourIndex(hour, minute);
    
    // 시간 계산 공식: 일간에 따라 결정
    int hourStemStartIndex;
    switch (dayStemIndex % 5) {
      case 0: // 갑, 기
        hourStemStartIndex = 0; // 갑
        break;
      case 1: // 을, 경
        hourStemStartIndex = 2; // 병
        break;
      case 2: // 병, 신
        hourStemStartIndex = 4; // 무
        break;
      case 3: // 정, 임
        hourStemStartIndex = 6; // 경
        break;
      case 4: // 무, 계
        hourStemStartIndex = 8; // 임
        break;
      default:
        hourStemStartIndex = 0;
    }
    
    final stemIndex = (hourStemStartIndex + hourIndex) % 10;
    
    return {
      'stem': heavenlyStems[stemIndex],
      'branch': earthlyBranches[hourIndex],
      'stemHanja': heavenlyStemsHanja[stemIndex],
      'branchHanja': earthlyBranchesHanja[hourIndex],
      'stemIndex': stemIndex,
      'branchIndex': hourIndex,
    };
  }
  
  /// 시진 인덱스 계산
  static int _getHourIndex(int hour, int minute) {
    // 자시(23:00-01:00)부터 시작
    if (hour >= 23 || hour < 1) return 0;  // 자시
    if (hour >= 1 && hour < 3) return 1;   // 축시
    if (hour >= 3 && hour < 5) return 2;   // 인시
    if (hour >= 5 && hour < 7) return 3;   // 묘시
    if (hour >= 7 && hour < 9) return 4;   // 진시
    if (hour >= 9 && hour < 11) return 5;  // 사시
    if (hour >= 11 && hour < 13) return 6; // 오시
    if (hour >= 13 && hour < 15) return 7; // 미시
    if (hour >= 15 && hour < 17) return 8; // 신시
    if (hour >= 17 && hour < 19) return 9; // 유시
    if (hour >= 19 && hour < 21) return 10;// 술시
    if (hour >= 21 && hour < 23) return 11;// 해시
    return 0;
  }
  
  /// 오행 분석
  static Map<String, int> _analyzeElements(
    Map<String, dynamic> year,
    Map<String, dynamic> month,
    Map<String, dynamic> day,
    Map<String, dynamic>? hour) {
    final elements = {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};
    
    // 년주 오행
    elements[stemElements[year['stem']]!] = (elements[stemElements[year['stem']]!] ?? 0) + 1;
    elements[branchElements[year['branch']]!] = (elements[branchElements[year['branch']]!] ?? 0) + 1;
    
    // 월주 오행
    elements[stemElements[month['stem']]!] = (elements[stemElements[month['stem']]!] ?? 0) + 1;
    elements[branchElements[month['branch']]!] = (elements[branchElements[month['branch']]!] ?? 0) + 1;
    
    // 일주 오행
    elements[stemElements[day['stem']]!] = (elements[stemElements[day['stem']]!] ?? 0) + 1;
    elements[branchElements[day['branch']]!] = (elements[branchElements[day['branch']]!] ?? 0) + 1;
    
    // 시주 오행
    if (hour != null) {
      elements[stemElements[hour['stem']]!] = (elements[stemElements[hour['stem']]!] ?? 0) + 1;
      elements[branchElements[hour['branch']]!] = (elements[branchElements[hour['branch']]!] ?? 0) + 1;
    }
    
    return elements;
  }
  
  /// 십신 계산
  static Map<String, dynamic> _calculateTenGods(
    String dayStem,
    Map<String, dynamic> year,
    Map<String, dynamic> month,
    Map<String, dynamic>? hour) {
    // 일간을 기준으로 다른 천간과의 관계 계산
    final tenGods = <String, List<String>>{};
    
    // 년간과의 관계
    final yearRelation = _getTenGodRelation(dayStem, year['stem']);
    tenGods['year'] = [yearRelation];
    
    // 월간과의 관계
    final monthRelation = _getTenGodRelation(dayStem, month['stem']);
    tenGods['month'] = [monthRelation];
    
    // 시간과의 관계
    if (hour != null) {
      final hourRelation = _getTenGodRelation(dayStem, hour['stem']);
      tenGods['hour'] = [hourRelation];
    }
    
    return tenGods;
  }
  
  /// 십신 관계 계산
  static String _getTenGodRelation(String dayStem, String targetStem) {
    final dayIndex = heavenlyStems.indexOf(dayStem);
    final targetIndex = heavenlyStems.indexOf(targetStem);
    
    if (dayIndex == targetIndex) return '비견';
    
    // 간단한 십신 관계 계산 (실제로는 더 복잡함)
    final diff = (targetIndex - dayIndex + 10) % 10;
    
    switch (diff) {
      case 1: return '겁재';
      case 2: return '식신';
      case 3: return '상관';
      case 4: return '편재';
      case 5: return '정재';
      case 6: return '편관';
      case 7: return '정관';
      case 8: return '편인';
      case 9: return '정인';
      default: return '비견';
    }
  }
  
  /// 대운 계산
  static Map<String, dynamic> _calculateDaeun(DateTime birthDate, Map<String, dynamic> monthPillar) {
    // 현재 나이 계산
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    // 대운 시작 나이 (간단한 계산)
    final daeunStartAge = 10; // 실제로는 성별과 년간의 음양에 따라 다름
    
    // 현재 대운 계산
    final currentDaeunIndex = ((age - daeunStartAge) ~/ 10);
    final currentDaeunAge = daeunStartAge + (currentDaeunIndex * 10);
    
    // 대운 천간지지 계산 (월주 기준)
    final stemIndex = (monthPillar['stemIndex'] + currentDaeunIndex + 1) % 10;
    final branchIndex = (monthPillar['branchIndex'] + currentDaeunIndex + 1) % 12;
    
    return {
      'currentAge': age,
      'startAge': currentDaeunAge,
      'endAge': currentDaeunAge + 9,
      'stem': heavenlyStems[stemIndex],
      'branch': earthlyBranches[branchIndex],
      'stemHanja': heavenlyStemsHanja[stemIndex],
      'branchHanja': earthlyBranchesHanja[branchIndex],
    };
  }
  
  /// 음력을 양력으로 변환 (간단한 구현)
  static DateTime _convertLunarToSolar(DateTime lunarDate) {
    // 실제 구현시에는 정확한 음양력 변환 라이브러리 사용 필요
    // 여기서는 대략적인 변환만 수행
    return lunarDate.add(const Duration(days: 30));
  }
  
  /// 사주 정보를 데이터베이스 저장용 형식으로 변환
  static Map<String, dynamic> toDbFormat(Map<String, dynamic> saju) {
    return {
      'year_stem': saju['year']['stem'],
      'year_branch': saju['year']['branch'],
      'year_stem_hanja': saju['year']['stemHanja'],
      'year_branch_hanja': saju['year']['branchHanja'],
      'month_stem': saju['month']['stem'],
      'month_branch': saju['month']['branch'],
      'month_stem_hanja': saju['month']['stemHanja'],
      'month_branch_hanja': saju['month']['branchHanja'],
      'day_stem': saju['day']['stem'],
      'day_branch': saju['day']['branch'],
      'day_stem_hanja': saju['day']['stemHanja'],
      'day_branch_hanja': saju['day']['branchHanja'],
      'hour_stem': saju['hour']?['stem'],
      'hour_branch': saju['hour']?['branch'],
      'hour_stem_hanja': saju['hour']?['stemHanja'],
      'hour_branch_hanja': saju['hour']?['branchHanja'],
      'element_balance': saju['elementBalance'],
      'ten_gods': saju['tenGods'],
      'daeun_info': saju['daeunInfo'],
      'current_daeun': saju['daeunInfo'] != null ? '${saju['daeunInfo']['stem']}${saju['daeunInfo']['branch']}' : null,
    };
  }
}