/// 지장간(支藏干) 데이터 및 계산 로직
///
/// 지장간: 각 지지(地支) 안에 숨어있는 천간(天干)
/// - 본기(本氣): 주된 기운 (60-100%)
/// - 중기(中氣): 부차적 기운 (30%)
/// - 여기(餘氣): 잔여 기운 (10%)
library;

/// 지장간 데이터 타입
enum HiddenStemType {
  /// 본기(本氣) - 주된 기운
  main('본기', '本氣', 60),

  /// 중기(中氣) - 부차적 기운
  middle('중기', '中氣', 30),

  /// 여기(餘氣) - 잔여 기운
  remnant('여기', '餘氣', 10);

  final String korean;
  final String hanja;
  final int defaultRatio;

  const HiddenStemType(this.korean, this.hanja, this.defaultRatio);
}

/// 개별 지장간 정보
class HiddenStem {
  /// 숨겨진 천간 (갑, 을, 병, ...)
  final String stem;

  /// 천간 한자 (甲, 乙, 丙, ...)
  final String stemHanja;

  /// 지장간 타입 (본기, 중기, 여기)
  final HiddenStemType type;

  /// 비율 (%)
  final int ratio;

  /// 오행
  final String wuxing;

  const HiddenStem({
    required this.stem,
    required this.stemHanja,
    required this.type,
    required this.ratio,
    required this.wuxing,
  });

  @override
  String toString() => '$stem($stemHanja) ${type.korean} $ratio%';
}

/// 지장간 데이터 및 유틸리티
class JiJangGanData {
  JiJangGanData._();

  /// 천간 → 오행 매핑
  static const Map<String, String> stemToWuxing = {
    '갑': '목', '을': '목',
    '병': '화', '정': '화',
    '무': '토', '기': '토',
    '경': '금', '신': '금',
    '임': '수', '계': '수',
  };

  /// 천간 → 한자 매핑
  static const Map<String, String> stemToHanja = {
    '갑': '甲', '을': '乙',
    '병': '丙', '정': '丁',
    '무': '戊', '기': '己',
    '경': '庚', '신': '辛',
    '임': '壬', '계': '癸',
  };

  /// 지지 → 한자 매핑
  static const Map<String, String> branchToHanja = {
    '자': '子', '축': '丑', '인': '寅', '묘': '卯',
    '진': '辰', '사': '巳', '오': '午', '미': '未',
    '신': '申', '유': '酉', '술': '戌', '해': '亥',
  };

  /// 12지지별 지장간 원시 데이터
  /// 순서: [본기, 중기, 여기] (없으면 null)
  static const Map<String, List<List<dynamic>>> _rawData = {
    '자': [['계', 100]],                              // 子: 癸(100%)
    '축': [['기', 60], ['신', 30], ['계', 10]],       // 丑: 己(60%), 辛(30%), 癸(10%)
    '인': [['갑', 60], ['병', 30], ['무', 10]],       // 寅: 甲(60%), 丙(30%), 戊(10%)
    '묘': [['을', 100]],                              // 卯: 乙(100%)
    '진': [['무', 60], ['을', 30], ['계', 10]],       // 辰: 戊(60%), 乙(30%), 癸(10%)
    '사': [['병', 60], ['무', 30], ['경', 10]],       // 巳: 丙(60%), 戊(30%), 庚(10%)
    '오': [['정', 70], ['기', 30]],                   // 午: 丁(70%), 己(30%)
    '미': [['기', 60], ['정', 30], ['을', 10]],       // 未: 己(60%), 丁(30%), 乙(10%)
    '신': [['경', 60], ['임', 30], ['무', 10]],       // 申: 庚(60%), 壬(30%), 戊(10%)
    '유': [['신', 100]],                              // 酉: 辛(100%)
    '술': [['무', 60], ['신', 30], ['정', 10]],       // 戌: 戊(60%), 辛(30%), 丁(10%)
    '해': [['임', 70], ['갑', 30]],                   // 亥: 壬(70%), 甲(30%)
  };

  /// 지지로부터 지장간 목록 반환
  static List<HiddenStem> getHiddenStems(String branch) {
    final rawList = _rawData[branch];
    if (rawList == null) return [];

    final result = <HiddenStem>[];
    for (int i = 0; i < rawList.length; i++) {
      final data = rawList[i];
      final stem = data[0] as String;
      final ratio = data[1] as int;

      HiddenStemType type;
      if (i == 0) {
        type = HiddenStemType.main;
      } else if (i == 1) {
        type = HiddenStemType.middle;
      } else {
        type = HiddenStemType.remnant;
      }

      result.add(HiddenStem(
        stem: stem,
        stemHanja: stemToHanja[stem] ?? '',
        type: type,
        ratio: ratio,
        wuxing: stemToWuxing[stem] ?? '',
      ));
    }

    return result;
  }

  /// 지지의 본기(主氣) 반환
  static String? getMainStem(String branch) {
    final stems = getHiddenStems(branch);
    return stems.isNotEmpty ? stems.first.stem : null;
  }

  /// 지지의 본기 한자 반환
  static String? getMainStemHanja(String branch) {
    final stems = getHiddenStems(branch);
    return stems.isNotEmpty ? stems.first.stemHanja : null;
  }

  /// 지장간 문자열 반환 (예: "戊庚丙")
  static String getHiddenStemsString(String branch, {bool useHanja = true}) {
    final stems = getHiddenStems(branch);
    if (useHanja) {
      return stems.map((s) => s.stemHanja).join('');
    } else {
      return stems.map((s) => s.stem).join('');
    }
  }

  /// 사주 4주의 지장간 포함 오행 분석
  /// [yearBranch], [monthBranch], [dayBranch], [hourBranch]: 년/월/일/시 지지
  /// 반환: 오행별 가중치 합계
  static Map<String, double> analyzeWuxingWithHiddenStems({
    required String yearBranch,
    required String monthBranch,
    required String dayBranch,
    required String hourBranch,
  }) {
    final result = <String, double>{
      '목': 0.0,
      '화': 0.0,
      '토': 0.0,
      '금': 0.0,
      '수': 0.0,
    };

    void addBranchStems(String branch) {
      final stems = getHiddenStems(branch);
      for (final stem in stems) {
        final wuxing = stem.wuxing;
        if (result.containsKey(wuxing)) {
          result[wuxing] = result[wuxing]! + (stem.ratio / 100.0);
        }
      }
    }

    addBranchStems(yearBranch);
    addBranchStems(monthBranch);
    addBranchStems(dayBranch);
    addBranchStems(hourBranch);

    return result;
  }

  /// 특정 지지에 특정 천간이 숨어있는지 확인
  static bool containsStem(String branch, String stem) {
    final stems = getHiddenStems(branch);
    return stems.any((s) => s.stem == stem);
  }

  /// 모든 지장간 데이터 반환 (디버그/표시용)
  static Map<String, List<HiddenStem>> getAllData() {
    final result = <String, List<HiddenStem>>{};
    for (final branch in _rawData.keys) {
      result[branch] = getHiddenStems(branch);
    }
    return result;
  }
}
