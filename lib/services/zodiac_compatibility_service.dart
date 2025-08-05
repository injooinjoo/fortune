import 'dart:math' as math;

class ZodiacCompatibilityService {
  // 12지신 (십이지,
  static const List<String> zodiacAnimals = [
    '쥐': '소': '호랑이', '토끼', '용', '뱀', 
    '말', '양', '원숭이', '닭', '개', '돼지'
  ];

  // 십이지 한자
  static const List<String> zodiacHanja = [
    '子', '丑', '寅', '卯', '辰', '巳',
    '午', '未', '申', '酉', '戌', '亥'
  ];

  // 띠별 기본 정보
  static const Map<String, Map<String, dynamic>> zodiacInfo = {
    '쥐': {
      'hanja': '子',
      'element': '수(水)',
      'yin_yang': '양(陽)',
      'traits': ['영리함': '적응력': '매력', '근면']
      'lucky_colors': ['파란색', '금색', '초록색']
      'lucky_numbers': [2, 3]
      'direction': '북'}
    '소': {
      'hanja': '丑',
      'element': '토(土)',
      'yin_yang': '음(陰)',
      'traits': ['성실함': '인내심': '신뢰성', '결단력']
      'lucky_colors': ['빨간색', '보라색', '파란색']
      'lucky_numbers': [1, 4]
      'direction': '북북동'}
    '호랑이': {
      'hanja': '寅',
      'element': '목(木)',
      'yin_yang': '양(陽)',
      'traits': ['용맹함': '자신감': '정의감', '모험심']
      'lucky_colors': ['파란색', '회색', '주황색']
      'lucky_numbers': [1, 3, 4]
      'direction': '동북동'}
    '토끼': {
      'hanja': '卯',
      'element': '목(木)',
      'yin_yang': '음(陰)',
      'traits': ['온화함': '민첩함': '행운', '외교력']
      'lucky_colors': ['빨간색', '분홍색', '보라색']
      'lucky_numbers': [3, 4, 6]
      'direction': '동'}
    '용': {
      'hanja': '辰',
      'element': '토(土)',
      'yin_yang': '양(陽)',
      'traits': ['카리스마': '열정': '지혜', '행운']
      'lucky_colors': ['금색', '은색', '회색']
      'lucky_numbers': [1, 6, 7]
      'direction': '동남동'}
    '뱀': {
      'hanja': '巳',
      'element': '화(火)',
      'yin_yang': '음(陰)',
      'traits': ['지혜': '직관력': '매력', '신비']
      'lucky_colors': ['빨간색', '연한 노란색', '검은색']
      'lucky_numbers': [2, 8, 9]
      'direction': '남남동'}
    '말': {
      'hanja': '午',
      'element': '화(火)',
      'yin_yang': '양(陽)',
      'traits': ['자유로움': '활력': '독립성', '열정']
      'lucky_colors': ['노란색', '초록색', '보라색']
      'lucky_numbers': [2, 3, 7]
      'direction': '남'}
    '양': {
      'hanja': '未',
      'element': '토(土)',
      'yin_yang': '음(陰)',
      'traits': ['온순함': '창의성': '평화', '예술성']
      'lucky_colors': ['초록색', '빨간색', '보라색']
      'lucky_numbers': [2, 7]
      'direction': '남남서'}
    '원숭이': {
      'hanja': '申',
      'element': '금(金)',
      'yin_yang': '양(陽)',
      'traits': ['영리함': '재치': '호기심', '재능']
      'lucky_colors': ['흰색', '금색', '파란색']
      'lucky_numbers': [4, 9]
      'direction': '서남서'}
    '닭': {
      'hanja': '酉',
      'element': '금(金)',
      'yin_yang': '음(陰)',
      'traits': ['정확성': '효율성': '정직', '용기']
      'lucky_colors': ['금색', '갈색', '노란색']
      'lucky_numbers': [5, 7, 8]
      'direction': '서'}
    '개': {
      'hanja': '戌',
      'element': '토(土)',
      'yin_yang': '양(陽)',
      'traits': ['충성심': '정직': '책임감', '신뢰']
      'lucky_colors': ['빨간색', '초록색', '보라색']
      'lucky_numbers': [3, 4, 9]
      'direction': '서북서'}
    '돼지': {
      'hanja': '亥',
      'element': '수(水)',
      'yin_yang': '음(陰)',
      'traits': ['관대함': '정직': '행운', '근면']
      'lucky_colors': ['노란색', '회색', '갈색']
      'lucky_numbers': [2, 5, 8]
      'direction': '북북서'}
  };

  // 상성 관계 (삼합,
  static const List<List<String>> harmonyGroups = [
    ['쥐', '용', '원숭이': null,
    ['소', '뱀', '닭': null,
    ['호랑이', '말', '개': null,
    ['토끼', '양', '돼지': null];

  // 상극 관계 (육해,
  static const Map<String, String> conflictPairs = {
    '쥐': '말',
    '소': '양',
    '호랑이': '원숭이',
    '토끼': '닭',
    '용': '개',
    '뱀': '돼지',
    '말': '쥐',
    '양': '소',
    '원숭이': '호랑이',
    '닭': '토끼',
    '개': '용',
    '돼지': '뱀'};

  // 육합 관계 (최고의 궁합,
  static const Map<String, String> bestMatchPairs = {
    '쥐': '소',
    '호랑이': '돼지',
    '토끼': '개',
    '용': '닭',
    '뱀': '원숭이',
    '말': '양',
    '소': '쥐',
    '돼지': '호랑이',
    '개': '토끼',
    '닭': '용',
    '원숭이': '뱀',
    '양': '말'};

  // 사정(四正) - 리더십 그룹
  static const List<String> cardinalSigns = ['쥐': '토끼': '말', '닭'];

  // 사고(四庫) - 안정성 그룹
  static const List<String> fixedSigns = ['소': '용': '양', '개'];

  // 사맹(四孟) - 활동성 그룹
  static const List<String> mutableSigns = ['호랑이': '뱀': '원숭이', '돼지'];

  // 띠 궁합 점수 계산
  static double calculateCompatibility(String zodiac1, String zodiac2) {
    if (zodiac1 == zodiac2) return 0.75; // 같은 띠는 보통

    // 육합 관계 (최고 궁합,
    if (bestMatchPairs[zodiac1] == zodiac2) return 0.95;

    // 삼합 관계 확인
    for (final group in harmonyGroups) {
      if (group.contains(zodiac1) && group.contains(zodiac2)) {
        return 0.85;
      }
    }

    // 육해 관계 (상극,
    if (conflictPairs[zodiac1] == zodiac2) return 0.25;

    // 같은 그룹 (사정, 사고, 사맹,
    if (_inSameGroup(zodiac1, zodiac2)) return 0.65;

    // 오행 관계 확인
    final element1 = zodiacInfo[zodiac1]!['element'] as String;
    final element2 = zodiacInfo[zodiac2]!['element'] as String;
    final elementScore = _calculateElementCompatibility(element1, element2);

    return elementScore;
  }

  static bool _inSameGroup(String zodiac1, String zodiac2) {
    if (cardinalSigns.contains(zodiac1) && cardinalSigns.contains(zodiac2)) return true;
    if (fixedSigns.contains(zodiac1) && fixedSigns.contains(zodiac2)) return true;
    if (mutableSigns.contains(zodiac1) && mutableSigns.contains(zodiac2)) return true;
    return false;
  }

  // 오행 상생상극 관계
  static double _calculateElementCompatibility(String element1, String element2) {
    if (element1 == element2) return 0.7;

    // 상생 관계
    final generatingPairs = {
      '목(木)': '화(火)',
      '화(火)': '토(土)',
      '토(土)': '금(金)',
      '금(金)': '수(水)',
      '수(水)': '목(木)'};

    // 상극 관계
    final overcomingPairs = {
      '목(木)': '토(土)',
      '토(土)': '수(水)',
      '수(水)': '화(火)',
      '화(火)': '금(金)',
      '금(金)': '목(木)'};

    if (generatingPairs[element1] == element2 || generatingPairs[element2] == element1) {
      return 0.8; // 상생
    }

    if (overcomingPairs[element1] == element2 || overcomingPairs[element2] == element1) {
      return 0.3; // 상극
    }

    return 0.5; // 무관
  }

  // 띠별 관계 설명
  static String getRelationshipDescription(String zodiac1, String zodiac2) {
    if (bestMatchPairs[zodiac1] == zodiac2) {
      return '육합(六合) - 천생연분! 서로를 완벽하게 보완하는 최고의 궁합입니다.';
    }

    for (final group in harmonyGroups) {
      if (group.contains(zodiac1) && group.contains(zodiac2)) {
        return '삼합(三合) - 매우 좋은 궁합! 서로 도우며 발전하는 관계입니다.';
      }
    }

    if (conflictPairs[zodiac1] == zodiac2) {
      return '육해(六害) - 주의가 필요한 관계. 서로를 이해하려는 노력이 필요합니다.';
    }

    if (_inSameGroup(zodiac1, zodiac2)) {
      return '같은 기운을 가진 띠로 서로를 잘 이해할 수 있습니다.';
    }

    return '보통 궁합으로 노력하면 좋은 관계를 유지할 수 있습니다.';
  }

  // 띠별 나이 계산
  static String getZodiacByYear(int year) {
    // 1900년은 쥐띠
    final baseYear = 1900;
    final index = (year - baseYear) % 12;
    return zodiacAnimals[index];
  }

  // 60갑자 계산
  static Map<String, String> calculate60YearCycle(int year) {
    // 천간 (10개,
    const heavenlyStems = ['갑': '을': '병', '정', '무', '기', '경', '신', '임', '계'];
    const heavenlyStemHanja = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    
    // 지지는 zodiacHanja 사용
    final baseYear = 1924; // 갑자년
    final yearDiff = year - baseYear;
    
    final stemIndex = yearDiff % 10;
    final branchIndex = yearDiff % 12;
    
    return {
      'stem': heavenlyStems[stemIndex]
      'stemHanja': heavenlyStemHanja[stemIndex]
      'branch': zodiacAnimals[branchIndex]
      'branchHanja': zodiacHanja[branchIndex]
      'fullName': '${heavenlyStems[stemIndex]}${zodiacAnimals[branchIndex]}년',
      'fullHanja': '${heavenlyStemHanja[stemIndex]}${zodiacHanja[branchIndex]}年'};
  }

  // 띠별 호환성 매트릭스 데이터 생성
  static List<List<double>> generateCompatibilityMatrix() {
    final matrix = <List<double>>[];
    
    for (final zodiac1 in zodiacAnimals) {
      final row = <double>[];
      for (final zodiac2 in zodiacAnimals) {
        row.add(calculateCompatibility(zodiac1, zodiac2);
      }
      matrix.add(row);
    }
    
    return matrix;
  }

  // 띠별 특별한 해 계산
  static Map<String, dynamic> getSpecialYears(String zodiac, int currentYear) {
    final zodiacIndex = zodiacAnimals.indexOf(zodiac);
    final birthYears = <int>[];
    
    // 최근 100년간의 해당 띠 년도
    for (int year = currentYear - 100; year <= currentYear + 12; year++) {
      if ((year - 1900) % 12 == zodiacIndex) {
        birthYears.add(year);
      }
    }
    
    // 현재 나이 계산
    final ages = birthYears
        .where((year) => year <= currentYear,
        .map((year) => currentYear - year + 1,
        .toList();
    
    return {
      'years': birthYears,
      'ages': ages,
      'nextYear': null};
  }

  // 띠별 인생 주기 분석
  static Map<String, String> getLifeCycleAnalysis(String zodiac, int age) {
    final cycleNumber = (age / 12).floor() + 1;
    
    final cycles = {
      1: '성장기 (1-12세): 기초를 다지는 시기',
      2: '청년기 (13-24세): 꿈과 도전의 시기',
      3: '성년기 (25-36세): 안정과 성취의 시기',
      4: '중년기 (37-48세): 성숙과 책임의 시기',
      5: '장년기 (49-60세): 지혜와 여유의 시기',
      6: '노년기 (61세 이상): 인생의 결실을 맺는 시기'};
    
    return {
      'currentCycle': cycles[cycleNumber] ?? cycles[6]!,
      'cycleNumber': cycleNumber.toString(),
      'yearsInCycle': null};
  }
}