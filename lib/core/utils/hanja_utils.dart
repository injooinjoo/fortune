/// 천간지지 한자 변환 유틸리티
///
/// 사주팔자의 천간(天干)과 지지(地支)를 한자로 변환합니다.
class HanjaUtils {
  HanjaUtils._();

  /// 천간(天干) 한자 매핑 - 10개의 하늘 기운
  static const Map<String, String> _heavenlyStemHanja = {
    '갑': '甲', // 목(木)의 양
    '을': '乙', // 목(木)의 음
    '병': '丙', // 화(火)의 양
    '정': '丁', // 화(火)의 음
    '무': '戊', // 토(土)의 양
    '기': '己', // 토(土)의 음
    '경': '庚', // 금(金)의 양
    '신': '辛', // 금(金)의 음
    '임': '壬', // 수(水)의 양
    '계': '癸', // 수(水)의 음
  };

  /// 지지(地支) 한자 매핑 - 12지지
  static const Map<String, String> _earthlyBranchHanja = {
    '자': '子', // 쥐
    '축': '丑', // 소
    '인': '寅', // 호랑이
    '묘': '卯', // 토끼
    '진': '辰', // 용
    '사': '巳', // 뱀
    '오': '午', // 말
    '미': '未', // 양
    '신': '申', // 원숭이
    '유': '酉', // 닭
    '술': '戌', // 개
    '해': '亥', // 돼지
  };

  /// 천간 한글을 한자로 변환
  /// 예: '갑' → '甲'
  static String? stemToHanja(String korean) {
    return _heavenlyStemHanja[korean];
  }

  /// 지지 한글을 한자로 변환
  /// 예: '자' → '子'
  static String? branchToHanja(String korean) {
    return _earthlyBranchHanja[korean];
  }

  /// 천간지지(2글자)를 한자로 변환
  /// 예: '갑자' → '甲子'
  static String toHanja(String koreanPillar) {
    if (koreanPillar.length != 2) return '';

    final stem = koreanPillar[0]; // 천간
    final branch = koreanPillar[1]; // 지지

    final stemHanja = _heavenlyStemHanja[stem] ?? '';
    final branchHanja = _earthlyBranchHanja[branch] ?? '';

    if (stemHanja.isEmpty || branchHanja.isEmpty) return '';

    return '$stemHanja$branchHanja';
  }

  /// 한글 + 한자 병기 형식으로 변환
  /// 예: '갑자' → '갑자(甲子)'
  static String withHanja(String koreanPillar) {
    final hanja = toHanja(koreanPillar);
    if (hanja.isEmpty) return koreanPillar;
    return '$koreanPillar($hanja)';
  }

  /// 천간지지가 유효한지 확인
  static bool isValidPillar(String pillar) {
    if (pillar.length != 2) return false;
    return _heavenlyStemHanja.containsKey(pillar[0]) &&
        _earthlyBranchHanja.containsKey(pillar[1]);
  }

  /// 천간의 오행(五行) 반환
  /// 목(木), 화(火), 토(土), 금(金), 수(水)
  static String? getStemElement(String stem) {
    const elementMap = {
      '갑': '목', '을': '목', // 木
      '병': '화', '정': '화', // 火
      '무': '토', '기': '토', // 土
      '경': '금', '신': '금', // 金
      '임': '수', '계': '수', // 水
    };
    return elementMap[stem];
  }

  /// 지지의 오행(五行) 반환
  static String? getBranchElement(String branch) {
    const elementMap = {
      '인': '목', '묘': '목', // 木
      '사': '화', '오': '화', // 火
      '진': '토', '술': '토', '축': '토', '미': '토', // 土
      '신': '금', '유': '금', // 金
      '해': '수', '자': '수', // 水
    };
    return elementMap[branch];
  }

  /// 오행(五行) 한자 매핑
  static const Map<String, String> _elementHanja = {
    '목': '木',
    '화': '火',
    '토': '土',
    '금': '金',
    '수': '水',
  };

  /// 오행 한글을 한자로 변환
  /// 예: '목' → '木'
  static String? elementToHanja(String korean) {
    return _elementHanja[korean];
  }

  /// 오행을 한글(한자) 형식으로 변환
  /// 예: '목' → '목(木)', '木' → '목(木)', '목(木)' → '목(木)'
  static String formatElement(String element) {
    if (element.isEmpty) return element;

    // 이미 "한글(한자)" 형식이면 그대로 반환
    if (RegExp(r'^[목화토금수]\([木火土金水]\)$').hasMatch(element)) {
      return element;
    }

    // 한자만 있으면 한글(한자) 형식으로 변환
    const hanjaToKorean = {
      '木': '목',
      '火': '화',
      '土': '토',
      '金': '금',
      '水': '수',
    };
    if (hanjaToKorean.containsKey(element)) {
      return '${hanjaToKorean[element]}($element)';
    }

    // 한글만 있으면 한자 추가
    final hanja = _elementHanja[element];
    if (hanja != null) {
      return '$element($hanja)';
    }

    // 알 수 없는 형식이면 그대로 반환
    return element;
  }

  /// 문자열에서 오행 관련 텍스트를 "한글(한자)" 형식으로 통일
  /// 예: "목 기운" → "목(木) 기운", "木 기운" → "목(木) 기운"
  static String formatElementInText(String text) {
    var result = text;

    // 한자만 있는 경우 변환 (뒤에 공백이나 문자가 오는 경우)
    const hanjaPatterns = {
      '木': '목(木)',
      '火': '화(火)',
      '土': '토(土)',
      '金': '금(金)',
      '水': '수(水)',
    };
    for (final entry in hanjaPatterns.entries) {
      // 한자 뒤에 괄호가 없는 경우만 변환 (이미 형식화된 것 제외)
      result = result.replaceAllMapped(
        RegExp('${entry.key}(?!\\))'),
        (match) => entry.value,
      );
    }

    // 한글만 있는 경우 변환 (뒤에 괄호가 없는 경우만)
    const koreanPatterns = {
      '목': '목(木)',
      '화': '화(火)',
      '토': '토(土)',
      '금': '금(金)',
      '수': '수(水)',
    };
    for (final entry in koreanPatterns.entries) {
      // "목(" 형식이 아닌 경우만 변환
      result = result.replaceAllMapped(
        RegExp('${entry.key}(?!\\()'),
        (match) => entry.value,
      );
    }

    return result;
  }
}
