// 일진(日辰) 계산 로직
//
// 일진: 특정 날짜의 일주(日柱) - 천간+지지 조합
// - 기준일로부터 경과 일수를 60으로 나눈 나머지로 계산
// - 기준일: 2000년 1월 7일 = 갑자일 (60갑자 인덱스 0)
//
// 활용:
// - 오늘의 일진 표시
// - 일간과의 상성 비교
// - 길일/흉일 판별
library;

/// 일진 정보
class IljinInfo {
  /// 천간 (한글)
  final String stem;

  /// 지지 (한글)
  final String branch;

  /// 천간 (한자)
  final String stemHanja;

  /// 지지 (한자)
  final String branchHanja;

  /// 천간 오행
  final String stemElement;

  /// 지지 오행
  final String branchElement;

  /// 지지 띠 동물
  final String animal;

  /// 날짜
  final DateTime date;

  /// 60갑자 인덱스 (0-59)
  final int sixtyIndex;

  const IljinInfo({
    required this.stem,
    required this.branch,
    required this.stemHanja,
    required this.branchHanja,
    required this.stemElement,
    required this.branchElement,
    required this.animal,
    required this.date,
    required this.sixtyIndex,
  });

  /// 일주 문자열 (한글)
  String get dayPillar => '$stem$branch';

  /// 일주 문자열 (한자)
  String get dayPillarHanja => '$stemHanja$branchHanja';

  Map<String, dynamic> toMap() => {
        'stem': stem,
        'branch': branch,
        'stemHanja': stemHanja,
        'branchHanja': branchHanja,
        'stemElement': stemElement,
        'branchElement': branchElement,
        'animal': animal,
        'date': date.toIso8601String(),
        'sixtyIndex': sixtyIndex,
        'dayPillar': dayPillar,
        'dayPillarHanja': dayPillarHanja,
      };
}

/// 일간 상성 결과
class IljinCompatibility {
  /// 관계 유형 (비견, 겁재, 식신, 상관, 편재, 정재, 편관, 정관, 편인, 정인)
  final String relationship;

  /// 길흉 (길, 평, 흉)
  final String fortune;

  /// 한줄 설명
  final String description;

  const IljinCompatibility({
    required this.relationship,
    required this.fortune,
    required this.description,
  });
}

/// 일진 계산기
class IljinCalculator {
  IljinCalculator._();

  /// 천간 (10개)
  static const List<String> _tianGan = [
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
  static const List<String> _diZhi = [
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
  static const Map<String, String> _stemHanjaMap = {
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
  static const Map<String, String> _branchHanjaMap = {
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
  static const Map<String, String> _stemElements = {
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
  static const Map<String, String> _branchElements = {
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

  /// 지지 띠 동물
  static const Map<String, String> _branchAnimals = {
    '자': '쥐',
    '축': '소',
    '인': '호랑이',
    '묘': '토끼',
    '진': '용',
    '사': '뱀',
    '오': '말',
    '미': '양',
    '신': '원숭이',
    '유': '닭',
    '술': '개',
    '해': '돼지',
  };

  /// 기준일: 2000년 1월 7일 = 갑자일 (60갑자 인덱스 0)
  static final DateTime _referenceDate = DateTime(2000, 1, 7);
  static const int _referenceIndex = 0; // 갑자

  /// 특정 날짜의 일진 계산
  ///
  /// [date]: 계산할 날짜
  static IljinInfo calculate(DateTime date) {
    // 기준일로부터의 경과 일수
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedRef =
        DateTime(_referenceDate.year, _referenceDate.month, _referenceDate.day);
    final daysDiff = normalizedDate.difference(normalizedRef).inDays;

    // 60갑자 인덱스
    int sixtyIdx = (_referenceIndex + daysDiff) % 60;
    if (sixtyIdx < 0) sixtyIdx += 60;

    final stemIdx = sixtyIdx % 10;
    final branchIdx = sixtyIdx % 12;

    final stem = _tianGan[stemIdx];
    final branch = _diZhi[branchIdx];

    return IljinInfo(
      stem: stem,
      branch: branch,
      stemHanja: _stemHanjaMap[stem] ?? '',
      branchHanja: _branchHanjaMap[branch] ?? '',
      stemElement: _stemElements[stem] ?? '',
      branchElement: _branchElements[branch] ?? '',
      animal: _branchAnimals[branch] ?? '',
      date: normalizedDate,
      sixtyIndex: sixtyIdx,
    );
  }

  /// 오늘의 일진
  static IljinInfo get today => calculate(DateTime.now());

  /// 일간과 오늘 일진의 상성 비교
  ///
  /// [myDayStem]: 나의 일간 (사주의 일주 천간)
  /// [todayIljin]: 오늘의 일진 (기본: 오늘)
  static IljinCompatibility checkCompatibility(
    String myDayStem, [
    IljinInfo? todayIljin,
  ]) {
    final iljin = todayIljin ?? today;

    final myElement = _stemElements[myDayStem] ?? '';
    final todayElement = _stemElements[iljin.stem] ?? '';

    if (myElement.isEmpty || todayElement.isEmpty) {
      return const IljinCompatibility(
        relationship: '알 수 없음',
        fortune: '평',
        description: '일간 정보가 부족합니다.',
      );
    }

    // 십성 관계 계산
    final myIdx = _tianGan.indexOf(myDayStem);
    final todayIdx = _tianGan.indexOf(iljin.stem);
    final isMyYang = myIdx % 2 == 0;
    final isTodayYang = todayIdx % 2 == 0;
    final isSamePolarity = isMyYang == isTodayYang;

    return _determineRelationship(myElement, todayElement, isSamePolarity);
  }

  /// 오행 관계 → 십성 + 길흉 판별
  static IljinCompatibility _determineRelationship(
    String myElement,
    String targetElement,
    bool isSamePolarity,
  ) {
    // 오행 관계: 나 → 대상
    final relation = _getElementRelation(myElement, targetElement);

    switch (relation) {
      case '비화': // 같은 오행
        return IljinCompatibility(
          relationship: isSamePolarity ? '비견' : '겁재',
          fortune: '평',
          description: isSamePolarity
              ? '같은 기운의 날. 자신감을 가지되 독선을 경계.'
              : '경쟁의 기운. 재물 지출에 주의.',
        );
      case '생': // 내가 생하는 오행
        return IljinCompatibility(
          relationship: isSamePolarity ? '식신' : '상관',
          fortune: isSamePolarity ? '길' : '평',
          description: isSamePolarity
              ? '표현력이 풍부한 날. 창작과 소통에 유리.'
              : '감정 표현이 과해질 수 있음. 말조심 필요.',
        );
      case '극': // 내가 극하는 오행
        return IljinCompatibility(
          relationship: isSamePolarity ? '편재' : '정재',
          fortune: '길',
          description: isSamePolarity
              ? '재물운이 좋은 날. 투자와 사업에 유리.'
              : '안정적 수입의 날. 저축과 관리에 적합.',
        );
      case '피극': // 나를 극하는 오행
        return IljinCompatibility(
          relationship: isSamePolarity ? '편관' : '정관',
          fortune: isSamePolarity ? '흉' : '평',
          description: isSamePolarity
              ? '압박과 시련의 날. 무리한 행동 자제.'
              : '규칙과 질서의 날. 공적인 일에 유리.',
        );
      case '피생': // 나를 생하는 오행
        return IljinCompatibility(
          relationship: isSamePolarity ? '편인' : '정인',
          fortune: '길',
          description: isSamePolarity
              ? '영감과 직감의 날. 학습과 연구에 좋음.'
              : '도움과 지원의 날. 어른의 조언이 유효.',
        );
      default:
        return const IljinCompatibility(
          relationship: '중립',
          fortune: '평',
          description: '평온한 하루가 예상됩니다.',
        );
    }
  }

  /// 오행 상생상극 관계 판별
  ///
  /// 상생: 목→화→토→금→수→목
  /// 상극: 목→토→수→화→금→목
  static String _getElementRelation(String my, String target) {
    if (my == target) return '비화';

    const shengCycle = ['목', '화', '토', '금', '수']; // 상생 순서
    final myIdx = shengCycle.indexOf(my);
    final targetIdx = shengCycle.indexOf(target);

    if (myIdx < 0 || targetIdx < 0) return '비화';

    // 상생 관계
    if ((myIdx + 1) % 5 == targetIdx) return '생'; // 내가 생
    if ((targetIdx + 1) % 5 == myIdx) return '피생'; // 나를 생

    // 상극 관계 (2칸 차이)
    if ((myIdx + 2) % 5 == targetIdx) return '극'; // 내가 극
    if ((targetIdx + 2) % 5 == myIdx) return '피극'; // 나를 극

    return '비화';
  }

  /// 특정 기간의 일진 리스트 생성
  static List<IljinInfo> getRange(DateTime start, DateTime end) {
    final List<IljinInfo> result = [];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      result.add(calculate(current));
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  /// 이번 주 일진 (월~일)
  static List<IljinInfo> get thisWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return getRange(monday, sunday);
  }
}
