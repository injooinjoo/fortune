/// 신살(神殺) 데이터 및 계산 로직
///
/// 신살: 운의 길흉을 판단하는 특별한 기호
/// - 길신(吉神): 행운과 복을 가져오는 신살
/// - 흉신(凶神): 액운과 재앙을 암시하는 신살
/// - 중립: 양면성이 있는 신살
library;

import 'package:flutter/material.dart';
import '../../../../../core/theme/saju_colors.dart';

/// 신살 카테고리
enum SinsalCategory {
  /// 길신(吉神) - 행운
  lucky('길신', '吉神', '행운과 복을 가져오는 신살'),

  /// 흉신(凶神) - 액운
  unlucky('흉신', '凶神', '액운과 재앙을 암시하는 신살'),

  /// 중립 - 양면성
  neutral('중립', '中立', '양면성이 있는 신살');

  final String korean;
  final String hanja;
  final String description;

  const SinsalCategory(this.korean, this.hanja, this.description);

  Color getColor({bool isDark = false}) {
    return SajuColors.getSinsalColor(korean, isDark: isDark);
  }
}

/// 개별 신살 정보
class Sinsal {
  /// 신살 이름 (한글)
  final String name;

  /// 신살 이름 (한자)
  final String hanja;

  /// 카테고리
  final SinsalCategory category;

  /// 판단 기준 (dayStem: 일간 기준, yearBranch: 년지 기준 등)
  final String basis;

  /// 의미/효과
  final String meaning;

  /// 상세 설명
  final String description;

  /// 해소/활용법
  final String remedy;

  /// 해당 지지 (계산 결과)
  final String? foundIn;

  /// 위치 (년주, 월주, 일주, 시주)
  final String? position;

  const Sinsal({
    required this.name,
    required this.hanja,
    required this.category,
    required this.basis,
    required this.meaning,
    required this.description,
    required this.remedy,
    this.foundIn,
    this.position,
  });

  @override
  String toString() => '$name($hanja)';

  /// 색상 반환
  Color getColor({bool isDark = false}) {
    return category.getColor(isDark: isDark);
  }
}

/// 신살 데이터 및 계산
class SinsalData {
  SinsalData._();

  // ============================================================
  // 길신(吉神) 5종
  // ============================================================

  /// 천을귀인(天乙貴人) - 가장 강력한 길신
  /// 기준: 일간
  static const Map<String, List<String>> _cheonEulGuiin = {
    '갑': ['축', '미'],
    '을': ['자', '신'],
    '병': ['해', '유'],
    '정': ['해', '유'],
    '무': ['축', '미'],
    '기': ['자', '신'],
    '경': ['축', '미'],
    '신': ['인', '오'],
    '임': ['묘', '사'],
    '계': ['묘', '사'],
  };

  /// 문창귀인(文昌貴人) - 학문, 시험 합격
  /// 기준: 일간
  static const Map<String, String> _munChangGuiin = {
    '갑': '사', '을': '오', '병': '신', '정': '유', '무': '신',
    '기': '유', '경': '해', '신': '자', '임': '인', '계': '묘',
  };

  /// 학당귀인(學堂貴人) - 학업 성취
  /// 기준: 일간
  static const Map<String, String> _hakDangGuiin = {
    '갑': '해', '을': '인', '병': '사', '정': '신', '무': '사',
    '기': '신', '경': '해', '신': '인', '임': '신', '계': '해',
  };

  /// 월덕귀인(月德貴人) - 월간의 길한 기운
  /// 기준: 월지
  static const Map<String, String> _wolDeokGuiin = {
    // 인오술월 → 병, 신자진월 → 임, 사유축월 → 경, 해묘미월 → 갑
    '인': '병', '오': '병', '술': '병',
    '신': '임', '자': '임', '진': '임',
    '사': '경', '유': '경', '축': '경',
    '해': '갑', '묘': '갑', '미': '갑',
  };

  /// 천의성(天醫星) - 건강, 의료 행운
  /// 기준: 월지
  static const Map<String, String> _cheonUiSeong = {
    '인': '축', '묘': '인', '진': '묘', '사': '진',
    '오': '사', '미': '오', '신': '미', '유': '신',
    '술': '유', '해': '술', '자': '해', '축': '자',
  };

  // ============================================================
  // 흉신(凶神) 5종
  // ============================================================

  /// 역마살(驛馬殺) - 이동, 변화
  /// 기준: 년지 또는 일지
  static const Map<String, String> _yeokMaSal = {
    // 인오술 → 신, 해묘미 → 사, 신자진 → 인, 사유축 → 해
    '인': '신', '오': '신', '술': '신',
    '해': '사', '묘': '사', '미': '사',
    '신': '인', '자': '인', '진': '인',
    '사': '해', '유': '해', '축': '해',
  };

  /// 도화살(桃花殺) - 이성 문제
  /// 기준: 년지 또는 일지
  static const Map<String, String> _doHwaSal = {
    // 인오술 → 묘, 해묘미 → 자, 신자진 → 유, 사유축 → 오
    '인': '묘', '오': '묘', '술': '묘',
    '해': '자', '묘': '자', '미': '자',
    '신': '유', '자': '유', '진': '유',
    '사': '오', '유': '오', '축': '오',
  };

  /// 겁살(劫殺) - 도난, 손실
  /// 기준: 년지 또는 일지
  static const Map<String, String> _geopSal = {
    // 인오술 → 해, 해묘미 → 신, 신자진 → 사, 사유축 → 인
    '인': '해', '오': '해', '술': '해',
    '해': '신', '묘': '신', '미': '신',
    '신': '사', '자': '사', '진': '사',
    '사': '인', '유': '인', '축': '인',
  };

  /// 망신살(亡神殺) - 명예 손상
  /// 기준: 년지 또는 일지
  static const Map<String, String> _mangSinSal = {
    // 인오술 → 사, 해묘미 → 인, 신자진 → 해, 사유축 → 신
    '인': '사', '오': '사', '술': '사',
    '해': '인', '묘': '인', '미': '인',
    '신': '해', '자': '해', '진': '해',
    '사': '신', '유': '신', '축': '신',
  };

  /// 백호살(白虎殺) - 질병, 사고
  /// 기준: 년지
  static const Map<String, String> _baekHoSal = {
    '자': '오', '축': '미', '인': '신', '묘': '유',
    '진': '술', '사': '해', '오': '자', '미': '축',
    '신': '인', '유': '묘', '술': '진', '해': '사',
  };

  // ============================================================
  // 계산 메서드
  // ============================================================

  /// 천을귀인 확인
  static Sinsal? checkCheonEulGuiin(String dayStem, String targetBranch, String position) {
    final branches = _cheonEulGuiin[dayStem];
    if (branches != null && branches.contains(targetBranch)) {
      return Sinsal(
        name: '천을귀인',
        hanja: '天乙貴人',
        category: SinsalCategory.lucky,
        basis: 'dayStem',
        meaning: '귀인의 도움, 위기 탈출',
        description: '가장 강력한 길신입니다. 어려운 상황에서 귀인의 도움을 받아 위기를 극복합니다.',
        remedy: '감사의 마음을 갖고 베푸는 삶을 살면 더욱 좋습니다.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 문창귀인 확인
  static Sinsal? checkMunChangGuiin(String dayStem, String targetBranch, String position) {
    if (_munChangGuiin[dayStem] == targetBranch) {
      return Sinsal(
        name: '문창귀인',
        hanja: '文昌貴人',
        category: SinsalCategory.lucky,
        basis: 'dayStem',
        meaning: '학문, 시험 합격',
        description: '학업과 시험에 유리한 길신입니다. 문서 관련 일에 행운이 따릅니다.',
        remedy: '꾸준한 학습과 자기계발로 능력을 발휘하세요.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 학당귀인 확인
  static Sinsal? checkHakDangGuiin(String dayStem, String targetBranch, String position) {
    if (_hakDangGuiin[dayStem] == targetBranch) {
      return Sinsal(
        name: '학당귀인',
        hanja: '學堂貴人',
        category: SinsalCategory.lucky,
        basis: 'dayStem',
        meaning: '학업 성취',
        description: '학문에 재능이 있고 배움을 통해 성장합니다.',
        remedy: '평생 학습자의 자세로 지식을 쌓으세요.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 월덕귀인 확인
  static Sinsal? checkWolDeokGuiin(String monthBranch, String targetStem, String position) {
    if (_wolDeokGuiin[monthBranch] == targetStem) {
      return Sinsal(
        name: '월덕귀인',
        hanja: '月德貴人',
        category: SinsalCategory.lucky,
        basis: 'monthBranch',
        meaning: '월간의 길한 기운',
        description: '해당 월에 덕을 쌓으면 복이 옵니다.',
        remedy: '베풀고 나누는 삶을 실천하세요.',
        foundIn: targetStem,
        position: position,
      );
    }
    return null;
  }

  /// 천의성 확인
  static Sinsal? checkCheonUiSeong(String monthBranch, String targetBranch, String position) {
    if (_cheonUiSeong[monthBranch] == targetBranch) {
      return Sinsal(
        name: '천의성',
        hanja: '天醫星',
        category: SinsalCategory.lucky,
        basis: 'monthBranch',
        meaning: '건강, 의료 행운',
        description: '건강 관련 직업이나 의료 분야에 재능이 있습니다.',
        remedy: '건강 관리에 관심을 갖고, 타인의 건강을 돕는 일에 적합합니다.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 역마살 확인
  static Sinsal? checkYeokMaSal(String baseBranch, String targetBranch, String position) {
    if (_yeokMaSal[baseBranch] == targetBranch) {
      return Sinsal(
        name: '역마살',
        hanja: '驛馬殺',
        category: SinsalCategory.unlucky,
        basis: 'yearBranch/dayBranch',
        meaning: '이동, 변화, 불안정',
        description: '잦은 이동과 변화가 있습니다. 한 곳에 정착하기 어려울 수 있습니다.',
        remedy: '이동이 많은 직업(무역, 여행, 영업 등)으로 활용하면 길하게 바뀝니다.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 도화살 확인
  static Sinsal? checkDoHwaSal(String baseBranch, String targetBranch, String position) {
    if (_doHwaSal[baseBranch] == targetBranch) {
      return Sinsal(
        name: '도화살',
        hanja: '桃花殺',
        category: SinsalCategory.neutral, // 양면성
        basis: 'yearBranch/dayBranch',
        meaning: '이성에게 인기, 예술성',
        description: '매력이 있고 이성에게 인기가 많습니다. 예술적 재능도 있습니다.',
        remedy: '이성 관계에서 절제가 필요합니다. 예술 분야로 승화시키면 좋습니다.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 겁살 확인
  static Sinsal? checkGeopSal(String baseBranch, String targetBranch, String position) {
    if (_geopSal[baseBranch] == targetBranch) {
      return Sinsal(
        name: '겁살',
        hanja: '劫殺',
        category: SinsalCategory.unlucky,
        basis: 'yearBranch/dayBranch',
        meaning: '도난, 손실, 액운',
        description: '재물 손실이나 도난을 주의해야 합니다.',
        remedy: '보안에 신경 쓰고, 투기성 투자를 피하세요.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 망신살 확인
  static Sinsal? checkMangSinSal(String baseBranch, String targetBranch, String position) {
    if (_mangSinSal[baseBranch] == targetBranch) {
      return Sinsal(
        name: '망신살',
        hanja: '亡神殺',
        category: SinsalCategory.unlucky,
        basis: 'yearBranch/dayBranch',
        meaning: '명예 손상, 신용 하락',
        description: '체면이나 명예가 손상될 수 있습니다.',
        remedy: '언행을 조심하고, 겸손한 태도를 유지하세요.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 백호살 확인
  static Sinsal? checkBaekHoSal(String yearBranch, String targetBranch, String position) {
    if (_baekHoSal[yearBranch] == targetBranch) {
      return Sinsal(
        name: '백호살',
        hanja: '白虎殺',
        category: SinsalCategory.unlucky,
        basis: 'yearBranch',
        meaning: '질병, 사고, 혈광',
        description: '건강이나 안전에 주의가 필요합니다.',
        remedy: '건강 검진을 정기적으로 받고, 안전에 유의하세요.',
        foundIn: targetBranch,
        position: position,
      );
    }
    return null;
  }

  /// 사주 전체 신살 분석
  ///
  /// [dayStem]: 일간
  /// [yearBranch], [monthBranch], [dayBranch], [hourBranch]: 지지
  /// [yearStem], [monthStem], [hourStem]: 천간 (월덕귀인용)
  static List<Sinsal> analyzeAllSinsal({
    required String dayStem,
    required String yearStem,
    required String monthStem,
    required String hourStem,
    required String yearBranch,
    required String monthBranch,
    required String dayBranch,
    required String hourBranch,
  }) {
    final results = <Sinsal>[];
    final branches = {
      '년주': yearBranch,
      '월주': monthBranch,
      '일주': dayBranch,
      '시주': hourBranch,
    };
    final stems = {
      '년주': yearStem,
      '월주': monthStem,
      '시주': hourStem,
    };

    // 길신 검사 (일간 기준)
    for (final entry in branches.entries) {
      final pos = entry.key;
      final branch = entry.value;

      // 천을귀인
      final cheonEul = checkCheonEulGuiin(dayStem, branch, pos);
      if (cheonEul != null) results.add(cheonEul);

      // 문창귀인
      final munChang = checkMunChangGuiin(dayStem, branch, pos);
      if (munChang != null) results.add(munChang);

      // 학당귀인
      final hakDang = checkHakDangGuiin(dayStem, branch, pos);
      if (hakDang != null) results.add(hakDang);
    }

    // 월덕귀인 (월지 기준 → 천간에서 찾음)
    for (final entry in stems.entries) {
      final pos = entry.key;
      final stem = entry.value;
      final wolDeok = checkWolDeokGuiin(monthBranch, stem, pos);
      if (wolDeok != null) results.add(wolDeok);
    }

    // 천의성 (월지 기준)
    for (final entry in branches.entries) {
      final pos = entry.key;
      final branch = entry.value;
      final cheonUi = checkCheonUiSeong(monthBranch, branch, pos);
      if (cheonUi != null) results.add(cheonUi);
    }

    // 흉신 검사 (년지/일지 기준)
    final baseBranches = [yearBranch, dayBranch];
    for (final baseBranch in baseBranches) {
      for (final entry in branches.entries) {
        final pos = entry.key;
        final targetBranch = entry.value;

        // 역마살
        final yeokMa = checkYeokMaSal(baseBranch, targetBranch, pos);
        if (yeokMa != null && !results.any((s) => s.name == '역마살' && s.foundIn == targetBranch)) {
          results.add(yeokMa);
        }

        // 도화살
        final doHwa = checkDoHwaSal(baseBranch, targetBranch, pos);
        if (doHwa != null && !results.any((s) => s.name == '도화살' && s.foundIn == targetBranch)) {
          results.add(doHwa);
        }

        // 겁살
        final geop = checkGeopSal(baseBranch, targetBranch, pos);
        if (geop != null && !results.any((s) => s.name == '겁살' && s.foundIn == targetBranch)) {
          results.add(geop);
        }

        // 망신살
        final mangSin = checkMangSinSal(baseBranch, targetBranch, pos);
        if (mangSin != null && !results.any((s) => s.name == '망신살' && s.foundIn == targetBranch)) {
          results.add(mangSin);
        }
      }
    }

    // 백호살 (년지 기준)
    for (final entry in branches.entries) {
      final pos = entry.key;
      final branch = entry.value;
      final baekHo = checkBaekHoSal(yearBranch, branch, pos);
      if (baekHo != null) results.add(baekHo);
    }

    return results;
  }

  /// 카테고리별 필터링
  static List<Sinsal> filterByCategory(List<Sinsal> sinsals, SinsalCategory category) {
    return sinsals.where((s) => s.category == category).toList();
  }

  /// 길신만 필터링
  static List<Sinsal> filterLucky(List<Sinsal> sinsals) {
    return filterByCategory(sinsals, SinsalCategory.lucky);
  }

  /// 흉신만 필터링
  static List<Sinsal> filterUnlucky(List<Sinsal> sinsals) {
    return filterByCategory(sinsals, SinsalCategory.unlucky);
  }
}
