// 대운(大運) / 연운(年運) / 월운(月運) 계산 로직
//
// 대운: 월주를 기준으로 10년 단위 운세 흐름
// - 양남음녀(陽男陰女)는 순행, 음남양녀(陰男陽女)는 역행
// - 대운 시작 나이 = (생일 → 절입일 거리) ÷ 3
// - 월주에서 60갑자 순서대로 진행
//
// 연운: 올해의 년주 (60갑자 기반)
// 월운: 이달의 월주 (년간 + 월지 기반)
library;

/// 대운 정보
class DaeunInfo {
  /// 대운 순서 (1~8)
  final int order;

  /// 시작 나이 (한국 나이)
  final int startAge;

  /// 끝 나이
  final int endAge;

  /// 천간 (한글)
  final String stem;

  /// 지지 (한글)
  final String branch;

  /// 천간 (한자)
  final String stemHanja;

  /// 지지 (한자)
  final String branchHanja;

  /// 오행
  final String element;

  const DaeunInfo({
    required this.order,
    required this.startAge,
    required this.endAge,
    required this.stem,
    required this.branch,
    required this.stemHanja,
    required this.branchHanja,
    required this.element,
  });

  /// Map 변환 (위젯에서 사용)
  Map<String, dynamic> toMap() => {
        'order': order,
        'startAge': startAge,
        'endAge': endAge,
        'stem': stem,
        'branch': branch,
        'stemHanja': stemHanja,
        'branchHanja': branchHanja,
        'element': element,
      };
}

/// 연운/월운 정보
class YeonWolunInfo {
  /// 천간 (한글)
  final String stem;

  /// 지지 (한글)
  final String branch;

  /// 천간 (한자)
  final String stemHanja;

  /// 지지 (한자)
  final String branchHanja;

  /// 오행 (천간 기준)
  final String element;

  /// 년도 또는 월
  final int year;

  /// 월 (월운인 경우)
  final int? month;

  const YeonWolunInfo({
    required this.stem,
    required this.branch,
    required this.stemHanja,
    required this.branchHanja,
    required this.element,
    required this.year,
    this.month,
  });

  Map<String, dynamic> toMap() => {
        'stem': stem,
        'branch': branch,
        'stemHanja': stemHanja,
        'branchHanja': branchHanja,
        'element': element,
        'year': year,
        if (month != null) 'month': month,
      };
}

/// 대운/연운/월운 계산기
class DaeunCalculator {
  DaeunCalculator._();

  // ─── 기본 상수 ───

  /// 천간 (10개)
  static const List<String> tianGan = [
    '갑',
    '을',
    '병',
    '정',
    '무',
    '기',
    '경',
    '신',
    '임',
    '계'
  ];

  /// 지지 (12개)
  static const List<String> diZhi = [
    '자',
    '축',
    '인',
    '묘',
    '진',
    '사',
    '오',
    '미',
    '신',
    '유',
    '술',
    '해'
  ];

  /// 천간 한자
  static const Map<String, String> stemHanjaMap = {
    '갑': '甲',
    '을': '乙',
    '병': '丙',
    '정': '丁',
    '무': '戊',
    '기': '己',
    '경': '庚',
    '신': '辛',
    '임': '壬',
    '계': '癸',
  };

  /// 지지 한자
  static const Map<String, String> branchHanjaMap = {
    '자': '子',
    '축': '丑',
    '인': '寅',
    '묘': '卯',
    '진': '辰',
    '사': '巳',
    '오': '午',
    '미': '未',
    '신': '申',
    '유': '酉',
    '술': '戌',
    '해': '亥',
  };

  /// 천간 오행
  static const Map<String, String> stemElements = {
    '갑': '목',
    '을': '목',
    '병': '화',
    '정': '화',
    '무': '토',
    '기': '토',
    '경': '금',
    '신': '금',
    '임': '수',
    '계': '수',
  };

  /// 지지 오행
  static const Map<String, String> branchElements = {
    '자': '수',
    '축': '토',
    '인': '목',
    '묘': '목',
    '진': '토',
    '사': '화',
    '오': '화',
    '미': '토',
    '신': '금',
    '유': '금',
    '술': '토',
    '해': '수',
  };

  // ─── 60갑자 ───

  /// 60갑자 전체 목록 (인덱스 0-59)
  static List<List<String>> get sixtyJiazi {
    final result = <List<String>>[];
    for (int i = 0; i < 60; i++) {
      result.add([tianGan[i % 10], diZhi[i % 12]]);
    }
    return result;
  }

  /// 천간+지지 → 60갑자 인덱스 (0-59)
  static int getSixtyIndex(String stem, String branch) {
    final stemIdx = tianGan.indexOf(stem);
    final branchIdx = diZhi.indexOf(branch);
    if (stemIdx < 0 || branchIdx < 0) return 0;

    // 60갑자에서 찾기
    for (int i = 0; i < 60; i++) {
      if (i % 10 == stemIdx && i % 12 == branchIdx) return i;
    }
    return 0;
  }

  // ─── 대운 방향 판별 ───

  /// 양간 여부 (갑병무경임 = 양, 을정기신계 = 음)
  static bool isYangStem(String stem) {
    final idx = tianGan.indexOf(stem);
    return idx >= 0 && idx % 2 == 0;
  }

  /// 대운 순행/역행 결정
  ///
  /// - 양남(陽男): 순행 (+1)
  /// - 음여(陰女): 순행 (+1)
  /// - 음남(陰男): 역행 (-1)
  /// - 양여(陽女): 역행 (-1)
  ///
  /// [yearStem]: 년간
  /// [isMale]: 남자 여부
  /// 반환: 순행이면 true
  static bool isForward(String yearStem, bool isMale) {
    final isYang = isYangStem(yearStem);
    // 양남음녀 = 순행, 음남양녀 = 역행
    return (isYang && isMale) || (!isYang && !isMale);
  }

  // ─── 절기 테이블 ───

  /// 24절기 중 월의 시작을 정하는 12절기
  /// 각 월의 절입일 (양력 기준 근사값)
  ///
  /// 월지: 인(1월/입춘) → 묘(2월/경칩) → ... → 축(12월/소한)
  /// 참고: 절기 시각은 매년 미세하게 다르지만,
  ///       대운 시작 나이 계산에는 일 단위 근사로 충분
  static const List<Map<String, dynamic>> _jeolgiTable = [
    {'month': 1, 'name': '입춘', 'hanja': '立春', 'branch': '인', 'day': 4},
    {'month': 2, 'name': '경칩', 'hanja': '驚蟄', 'branch': '묘', 'day': 6},
    {'month': 3, 'name': '청명', 'hanja': '清明', 'branch': '진', 'day': 5},
    {'month': 4, 'name': '입하', 'hanja': '立夏', 'branch': '사', 'day': 6},
    {'month': 5, 'name': '망종', 'hanja': '芒種', 'branch': '오', 'day': 6},
    {'month': 6, 'name': '소서', 'hanja': '小暑', 'branch': '미', 'day': 7},
    {'month': 7, 'name': '입추', 'hanja': '立秋', 'branch': '신', 'day': 8},
    {'month': 8, 'name': '백로', 'hanja': '白露', 'branch': '유', 'day': 8},
    {'month': 9, 'name': '한로', 'hanja': '寒露', 'branch': '술', 'day': 8},
    {'month': 10, 'name': '입동', 'hanja': '立冬', 'branch': '해', 'day': 7},
    {'month': 11, 'name': '대설', 'hanja': '大雪', 'branch': '자', 'day': 7},
    {'month': 12, 'name': '소한', 'hanja': '小寒', 'branch': '축', 'day': 6},
  ];

  /// 해당 년도의 절입일(양력) 근사 계산
  ///
  /// 정밀한 절기 시각은 천문학적 계산이 필요하지만,
  /// 대운 시작 나이 계산에는 ±1일 오차가 허용되므로 근사값 사용
  static DateTime _getJeolipDate(int year, int solarMonth) {
    final entry = _jeolgiTable.firstWhere(
      (e) => e['month'] == solarMonth,
      orElse: () => _jeolgiTable[0],
    );
    return DateTime(year, solarMonth, entry['day'] as int);
  }

  // ─── 대운 시작 나이 계산 ───

  /// 대운 시작 나이 계산
  ///
  /// 생일부터 다음(또는 이전) 절입일까지의 일수 ÷ 3 = 대운 시작 나이
  /// - 순행: 다음 절입일까지
  /// - 역행: 이전 절입일까지
  ///
  /// [birthDate]: 양력 생년월일
  /// [yearStem]: 년간 (양/음 판별용)
  /// [isMale]: 남자 여부
  static int calculateStartAge(
    DateTime birthDate,
    String yearStem,
    bool isMale,
  ) {
    final forward = isForward(yearStem, isMale);

    if (forward) {
      // 순행: 생일 → 다음 절입일
      final nextJeolip = _getNextJeolipDate(birthDate);
      final daysDiff = nextJeolip.difference(birthDate).inDays.abs();
      return (daysDiff / 3).round().clamp(1, 10);
    } else {
      // 역행: 생일 → 이전 절입일
      final prevJeolip = _getPrevJeolipDate(birthDate);
      final daysDiff = birthDate.difference(prevJeolip).inDays.abs();
      return (daysDiff / 3).round().clamp(1, 10);
    }
  }

  /// 생일 이후 가장 가까운 절입일
  static DateTime _getNextJeolipDate(DateTime birthDate) {
    // 현재 월의 절입일
    final currentMonthJeolip = _getJeolipDate(birthDate.year, birthDate.month);

    if (currentMonthJeolip.isAfter(birthDate)) {
      return currentMonthJeolip;
    }

    // 다음 월의 절입일
    if (birthDate.month == 12) {
      return _getJeolipDate(birthDate.year + 1, 1);
    }
    return _getJeolipDate(birthDate.year, birthDate.month + 1);
  }

  /// 생일 이전 가장 가까운 절입일
  static DateTime _getPrevJeolipDate(DateTime birthDate) {
    // 현재 월의 절입일
    final currentMonthJeolip = _getJeolipDate(birthDate.year, birthDate.month);

    if (currentMonthJeolip.isBefore(birthDate)) {
      return currentMonthJeolip;
    }

    // 이전 월의 절입일
    if (birthDate.month == 1) {
      return _getJeolipDate(birthDate.year - 1, 12);
    }
    return _getJeolipDate(birthDate.year, birthDate.month - 1);
  }

  // ─── 대운 생성 ───

  /// 대운 8개 생성
  ///
  /// [monthStem]: 월간 (대운의 출발점)
  /// [monthBranch]: 월지
  /// [yearStem]: 년간 (순행/역행 판별)
  /// [isMale]: 남자 여부
  /// [birthDate]: 생년월일 (시작 나이 계산)
  /// [count]: 대운 개수 (기본 8개)
  static List<DaeunInfo> calculateDaeun({
    required String monthStem,
    required String monthBranch,
    required String yearStem,
    required bool isMale,
    required DateTime birthDate,
    int count = 8,
  }) {
    final forward = isForward(yearStem, isMale);
    final startAge = calculateStartAge(birthDate, yearStem, isMale);
    final monthIndex = getSixtyIndex(monthStem, monthBranch);

    final List<DaeunInfo> result = [];

    for (int i = 0; i < count; i++) {
      // 60갑자에서 다음(순행) 또는 이전(역행) 간지 계산
      int daeunIndex;
      if (forward) {
        daeunIndex = (monthIndex + (i + 1)) % 60;
      } else {
        daeunIndex = (monthIndex - (i + 1) + 60) % 60;
      }

      final stem = tianGan[daeunIndex % 10];
      final branch = diZhi[daeunIndex % 12];
      final age = startAge + (i * 10);

      result.add(DaeunInfo(
        order: i + 1,
        startAge: age,
        endAge: age + 9,
        stem: stem,
        branch: branch,
        stemHanja: stemHanjaMap[stem] ?? '',
        branchHanja: branchHanjaMap[branch] ?? '',
        element: stemElements[stem] ?? '',
      ));
    }

    return result;
  }

  /// 현재 대운 찾기
  ///
  /// [daeunList]: 대운 리스트
  /// [koreanAge]: 한국 나이
  static DaeunInfo? findCurrentDaeun(List<DaeunInfo> daeunList, int koreanAge) {
    for (final daeun in daeunList) {
      if (koreanAge >= daeun.startAge && koreanAge <= daeun.endAge) {
        return daeun;
      }
    }
    return daeunList.isNotEmpty ? daeunList.first : null;
  }

  // ─── 연운 (年運) 계산 ───

  /// 특정 년도의 년주(年柱) 계산
  ///
  /// 년간 공식: (년도 - 4) % 10 → 천간 인덱스
  /// 년지 공식: (년도 - 4) % 12 → 지지 인덱스
  /// (기원전 2637년 = 갑자년 기준, 서기 4년 = 갑자년)
  static YeonWolunInfo calculateYeonun(int year) {
    final stemIdx = (year - 4) % 10;
    final branchIdx = (year - 4) % 12;

    // 음수 보정
    final adjustedStemIdx = stemIdx < 0 ? stemIdx + 10 : stemIdx;
    final adjustedBranchIdx = branchIdx < 0 ? branchIdx + 12 : branchIdx;

    final stem = tianGan[adjustedStemIdx];
    final branch = diZhi[adjustedBranchIdx];

    return YeonWolunInfo(
      stem: stem,
      branch: branch,
      stemHanja: stemHanjaMap[stem] ?? '',
      branchHanja: branchHanjaMap[branch] ?? '',
      element: stemElements[stem] ?? '',
      year: year,
    );
  }

  /// 올해 연운
  static YeonWolunInfo get currentYeonun =>
      calculateYeonun(DateTime.now().year);

  // ─── 월운 (月運) 계산 ───

  /// 특정 년월의 월주(月柱) 계산
  ///
  /// 월간 공식 (년간에 의존):
  ///   갑/기년 → 병인월(1월) 시작
  ///   을/경년 → 무인월(1월) 시작
  ///   병/신년 → 경인월(1월) 시작
  ///   정/임년 → 임인월(1월) 시작
  ///   무/계년 → 갑인월(1월) 시작
  ///
  /// 월지: 인(1월) → 묘(2월) → ... → 축(12월)
  /// ※ 여기서 "1월"은 음력 정월(입춘~경칩)
  static YeonWolunInfo calculateWolun(int year, int solarMonth) {
    // 절기 기준 월 계산 (양력 → 절기월)
    final jeolgiMonth = _solarToJeolgiMonth(year, solarMonth);

    // 년간으로부터 월간 기둥 결정
    final yearStem = calculateYeonun(year).stem;
    final monthStemIdx = _getMonthStemIndex(yearStem, jeolgiMonth);
    final monthBranchIdx = (jeolgiMonth + 1) % 12; // 인(1월)=2, 묘(2월)=3...

    final stem = tianGan[monthStemIdx];
    final branch = diZhi[monthBranchIdx];

    return YeonWolunInfo(
      stem: stem,
      branch: branch,
      stemHanja: stemHanjaMap[stem] ?? '',
      branchHanja: branchHanjaMap[branch] ?? '',
      element: stemElements[stem] ?? '',
      year: year,
      month: solarMonth,
    );
  }

  /// 양력월 → 절기 기준 월 변환
  ///
  /// 양력 2월 4일경(입춘) 이후가 절기 1월(인월)
  /// 양력 1월 & 2월 초는 전년 12월(축월)
  static int _solarToJeolgiMonth(int year, int solarMonth) {
    final jeolipDate = _getJeolipDate(year, solarMonth);
    final now = DateTime(year, solarMonth, 15); // 월 중순 기준

    // 이번 달 절입일 이전이면 전월의 절기월
    if (now.isBefore(jeolipDate)) {
      return solarMonth == 1 ? 12 : solarMonth - 1;
    }
    return solarMonth;
  }

  /// 년간에 따른 월간 시작 인덱스
  ///
  /// 갑/기 → 병(2) 시작 → 인월 천간 = 병
  /// 을/경 → 무(4) 시작
  /// 병/신 → 경(6) 시작
  /// 정/임 → 임(8) 시작
  /// 무/계 → 갑(0) 시작
  static int _getMonthStemIndex(String yearStem, int jeolgiMonth) {
    // 년간 기준 인월(1월) 천간
    final yearStemIdx = tianGan.indexOf(yearStem);
    if (yearStemIdx < 0) return 0;

    // 년간 그룹별 인월 천간 인덱스
    // 갑기(0,5) → 병(2), 을경(1,6) → 무(4), 병신(2,7) → 경(6),
    // 정임(3,8) → 임(8), 무계(4,9) → 갑(0)
    final baseIndex = (yearStemIdx % 5) * 2 + 2;

    // 인월(1월)부터 시작하여 jeolgiMonth만큼 이동
    return (baseIndex + jeolgiMonth - 1) % 10;
  }

  /// 이번 달 월운
  static YeonWolunInfo get currentWolun {
    final now = DateTime.now();
    return calculateWolun(now.year, now.month);
  }

  // ─── 연운 리스트 (전후 5년) ───

  /// 전후 N년의 연운 리스트 생성
  static List<YeonWolunInfo> getYeonunRange({
    int? centerYear,
    int before = 2,
    int after = 5,
  }) {
    final center = centerYear ?? DateTime.now().year;
    return List.generate(
      before + after + 1,
      (i) => calculateYeonun(center - before + i),
    );
  }

  /// 올해 기준 12개월 월운 리스트
  static List<YeonWolunInfo> getWolunForYear([int? year]) {
    final targetYear = year ?? DateTime.now().year;
    return List.generate(
      12,
      (i) => calculateWolun(targetYear, i + 1),
    );
  }

  // ─── 유틸리티 ───

  /// 한국 나이 계산
  static int getKoreanAge(DateTime birthDate, [DateTime? referenceDate]) {
    final ref = referenceDate ?? DateTime.now();
    return ref.year - birthDate.year + 1;
  }

  /// 만 나이 계산
  static int getInternationalAge(DateTime birthDate,
      [DateTime? referenceDate]) {
    final ref = referenceDate ?? DateTime.now();
    int age = ref.year - birthDate.year;
    if (ref.month < birthDate.month ||
        (ref.month == birthDate.month && ref.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
