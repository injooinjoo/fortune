// 공망(空亡) 계산 로직
//
// 공망: 60갑자 순환에서 천간 10개가 지지 12개를 모두 채우지 못해
// 2개의 지지가 비어있는 현상.
//
// - 일주를 기준으로 계산
// - 공망에 해당하는 지지는 그 작용이 약해지거나 비어있음
// - 길신이 공망이면 효과 감소, 흉신이 공망이면 흉함이 감소
library;

import 'package:flutter/material.dart';
import '../../../../../core/design_system/tokens/ds_saju_colors.dart';

/// 순(旬) - 60갑자의 6개 구간
enum Xun {
  /// 갑자순(甲子旬): 갑자~계유
  gapJa('갑자순', '甲子旬', ['술', '해'], ['戌', '亥']),

  /// 갑술순(甲戌旬): 갑술~계미
  gapSul('갑술순', '甲戌旬', ['신', '유'], ['申', '酉']),

  /// 갑신순(甲申旬): 갑신~계사
  gapSin('갑신순', '甲申旬', ['오', '미'], ['午', '未']),

  /// 갑오순(甲午旬): 갑오~계묘
  gapO('갑오순', '甲午旬', ['진', '사'], ['辰', '巳']),

  /// 갑진순(甲辰旬): 갑진~계축
  gapJin('갑진순', '甲辰旬', ['인', '묘'], ['寅', '卯']),

  /// 갑인순(甲寅旬): 갑인~계해
  gapIn('갑인순', '甲寅旬', ['자', '축'], ['子', '丑']);

  /// 순 이름 (한글)
  final String korean;

  /// 순 이름 (한자)
  final String hanja;

  /// 공망 지지 (한글)
  final List<String> gongMangBranches;

  /// 공망 지지 (한자)
  final List<String> gongMangHanja;

  const Xun(this.korean, this.hanja, this.gongMangBranches, this.gongMangHanja);
}

/// 공망 정보
class GongMangInfo {
  /// 해당 순(旬)
  final Xun xun;

  /// 공망 지지 목록
  final List<String> gongMangBranches;

  /// 공망 지지 한자 목록
  final List<String> gongMangHanja;

  /// 사주에서 공망에 해당하는 지지들 (위치 포함)
  final Map<String, String> foundInSaju; // {위치: 지지}

  const GongMangInfo({
    required this.xun,
    required this.gongMangBranches,
    required this.gongMangHanja,
    required this.foundInSaju,
  });

  /// 공망이 있는지 확인
  bool get hasGongMang => foundInSaju.isNotEmpty;

  /// 공망 지지 문자열 (예: "술해")
  String get gongMangString => gongMangBranches.join('');

  /// 공망 한자 문자열 (예: "戌亥")
  String get gongMangHanjaString => gongMangHanja.join('');

  @override
  String toString() {
    if (hasGongMang) {
      return '${xun.korean} 공망($gongMangString) - ${foundInSaju.entries.map((e) => '${e.key}:${e.value}').join(', ')}';
    }
    return '${xun.korean} 공망($gongMangString) - 해당 없음';
  }
}

/// 공망 계산기
class GongMangCalculator {
  GongMangCalculator._();

  /// 천간 목록 (참조용)
  // ignore: unused_field
  static const List<String> _tianGan = [
    '갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'
  ];

  /// 지지 목록 (참조용)
  // ignore: unused_field
  static const List<String> _diZhi = [
    '자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'
  ];

  /// 순별 시작 천간-지지 조합
  static const Map<String, Xun> _xunMapping = {
    '갑자': Xun.gapJa, '을축': Xun.gapJa, '병인': Xun.gapJa, '정묘': Xun.gapJa, '무진': Xun.gapJa,
    '기사': Xun.gapJa, '경오': Xun.gapJa, '신미': Xun.gapJa, '임신': Xun.gapJa, '계유': Xun.gapJa,

    '갑술': Xun.gapSul, '을해': Xun.gapSul, '병자': Xun.gapSul, '정축': Xun.gapSul, '무인': Xun.gapSul,
    '기묘': Xun.gapSul, '경진': Xun.gapSul, '신사': Xun.gapSul, '임오': Xun.gapSul, '계미': Xun.gapSul,

    '갑신': Xun.gapSin, '을유': Xun.gapSin, '병술': Xun.gapSin, '정해': Xun.gapSin, '무자': Xun.gapSin,
    '기축': Xun.gapSin, '경인': Xun.gapSin, '신묘': Xun.gapSin, '임진': Xun.gapSin, '계사': Xun.gapSin,

    '갑오': Xun.gapO, '을미': Xun.gapO, '병신': Xun.gapO, '정유': Xun.gapO, '무술': Xun.gapO,
    '기해': Xun.gapO, '경자': Xun.gapO, '신축': Xun.gapO, '임인': Xun.gapO, '계묘': Xun.gapO,

    '갑진': Xun.gapJin, '을사': Xun.gapJin, '병오': Xun.gapJin, '정미': Xun.gapJin, '무신': Xun.gapJin,
    '기유': Xun.gapJin, '경술': Xun.gapJin, '신해': Xun.gapJin, '임자': Xun.gapJin, '계축': Xun.gapJin,

    '갑인': Xun.gapIn, '을묘': Xun.gapIn, '병진': Xun.gapIn, '정사': Xun.gapIn, '무오': Xun.gapIn,
    '기미': Xun.gapIn, '경신': Xun.gapIn, '신유': Xun.gapIn, '임술': Xun.gapIn, '계해': Xun.gapIn,
  };

  /// 일주로부터 해당 순(旬) 찾기
  static Xun findXun(String dayStem, String dayBranch) {
    final key = '$dayStem$dayBranch';
    return _xunMapping[key] ?? Xun.gapJa;
  }

  /// 일주로부터 공망 지지 계산
  static List<String> calculateGongMang(String dayStem, String dayBranch) {
    final xun = findXun(dayStem, dayBranch);
    return xun.gongMangBranches;
  }

  /// 특정 지지가 공망인지 확인
  static bool isGongMang(String dayStem, String dayBranch, String targetBranch) {
    final gongMangBranches = calculateGongMang(dayStem, dayBranch);
    return gongMangBranches.contains(targetBranch);
  }

  /// 사주 전체에서 공망 분석
  ///
  /// [dayStem], [dayBranch]: 일주 (공망 계산 기준)
  /// [yearBranch], [monthBranch], [hourBranch]: 나머지 지지
  static GongMangInfo analyzeGongMang({
    required String dayStem,
    required String dayBranch,
    required String yearBranch,
    required String monthBranch,
    required String hourBranch,
  }) {
    final xun = findXun(dayStem, dayBranch);
    final gongMangBranches = xun.gongMangBranches;

    // 사주에서 공망에 해당하는 지지 찾기
    final foundInSaju = <String, String>{};

    if (gongMangBranches.contains(yearBranch)) {
      foundInSaju['년주'] = yearBranch;
    }
    if (gongMangBranches.contains(monthBranch)) {
      foundInSaju['월주'] = monthBranch;
    }
    // 일주는 공망 기준이므로 제외
    if (gongMangBranches.contains(hourBranch)) {
      foundInSaju['시주'] = hourBranch;
    }

    return GongMangInfo(
      xun: xun,
      gongMangBranches: gongMangBranches,
      gongMangHanja: xun.gongMangHanja,
      foundInSaju: foundInSaju,
    );
  }

  /// 공망 해석
  static String interpretGongMang(GongMangInfo info) {
    if (!info.hasGongMang) {
      return '사주에 공망이 없습니다. 각 지지의 작용이 온전합니다.';
    }

    final buffer = StringBuffer();
    buffer.writeln('일주 기준 ${info.xun.korean}(${info.xun.hanja})입니다.');
    buffer.writeln('공망 지지: ${info.gongMangString}(${info.gongMangHanjaString})');
    buffer.writeln();

    for (final entry in info.foundInSaju.entries) {
      final position = entry.key;
      final branch = entry.value;

      switch (position) {
        case '년주':
          buffer.writeln('• 년주 $branch이(가) 공망: 조상덕이 약하거나, 유년기에 어려움이 있을 수 있습니다.');
          break;
        case '월주':
          buffer.writeln('• 월주 $branch이(가) 공망: 부모의 도움이 약하거나, 청년기에 자립이 필요합니다.');
          break;
        case '시주':
          buffer.writeln('• 시주 $branch이(가) 공망: 자녀와의 인연이 약하거나, 노년기에 독립적인 삶이 예상됩니다.');
          break;
      }
    }

    buffer.writeln();
    buffer.writeln('※ 공망은 비어있음을 의미하지만, 반드시 흉한 것은 아닙니다.');
    buffer.writeln('   오히려 공망된 흉신은 흉함이 줄어들고, 공망된 길신은 노력으로 채워갈 수 있습니다.');

    return buffer.toString();
  }

  /// 공망 색상 반환
  static Color getGongMangColor({bool isDark = false}) {
    return SajuColors.emptinessLight;
  }
}
