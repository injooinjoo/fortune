// 12운성(十二運星) 계산 로직
//
// 12운성: 일간(日干)의 오행이 각 지지에서 어떤 생명 주기 단계에 있는지 나타냄
// 장생 → 목욕 → 관대 → 건록 → 제왕 → 쇠 → 병 → 사 → 묘 → 절 → 태 → 양
library;

import 'package:flutter/material.dart';

/// 12운성 열거형
enum TwelveStage {
  /// 장생(長生) - 탄생, 시작의 기운
  jangSaeng('장생', '長生', '탄생과 시작의 기운. 새로운 일의 시작에 유리'),

  /// 목욕(沐浴) - 성장 초기, 불안정
  mokYok('목욕', '沐浴', '성장 초기로 다소 불안정. 감정 기복이 있을 수 있음'),

  /// 관대(冠帶) - 성인이 되어 옷을 갖춤
  gwanDae('관대', '冠帶', '성인으로서 준비 완료. 사회적 활동 시작'),

  /// 건록(建祿) - 전성기, 직업과 명예
  geonRok('건록', '建祿', '전성기. 직업과 명예가 확립되는 시기'),

  /// 제왕(帝旺) - 최고점, 권력과 영향력
  jeWang('제왕', '帝旺', '최고점에 도달. 권력과 영향력이 가장 강함'),

  /// 쇠(衰) - 쇠퇴의 시작
  soe('쇠', '衰', '쇠퇴가 시작됨. 보수적 태도가 필요'),

  /// 병(病) - 기운이 약해짐
  byeong('병', '病', '기운이 약해지는 시기. 건강에 주의 필요'),

  /// 사(死) - 활동의 정지
  sa('사', '死', '활동이 정지되는 시기. 내면의 성찰 필요'),

  /// 묘(墓) - 창고에 들어감
  myo('묘', '墓', '창고에 저장되는 시기. 결실을 맺고 보관'),

  /// 절(絕) - 완전한 소멸
  jeol('절', '絶', '완전한 소멸. 새로운 시작을 위한 준비'),

  /// 태(胎) - 새 생명의 잉태
  tae('태', '胎', '새 생명이 잉태됨. 새로운 가능성의 씨앗'),

  /// 양(養) - 양육과 준비
  yang('양', '養', '양육과 성장 준비. 조용히 힘을 기르는 시기');

  /// 한글명
  final String korean;

  /// 한자
  final String hanja;

  /// 의미 설명
  final String meaning;

  const TwelveStage(this.korean, this.hanja, this.meaning);

  /// 운성의 강도 (1: 최약, 5: 최강)
  int get strength {
    switch (this) {
      case TwelveStage.geonRok:
      case TwelveStage.jeWang:
        return 5; // 최강
      case TwelveStage.jangSaeng:
      case TwelveStage.gwanDae:
        return 4; // 강
      case TwelveStage.mokYok:
      case TwelveStage.soe:
      case TwelveStage.yang:
        return 3; // 중
      case TwelveStage.myo:
      case TwelveStage.byeong:
      case TwelveStage.tae:
        return 2; // 약
      case TwelveStage.sa:
      case TwelveStage.jeol:
        return 1; // 최약
    }
  }

  /// 길흉 판단
  String get fortune {
    switch (strength) {
      case 5:
        return '대길';
      case 4:
        return '길';
      case 3:
        return '평';
      case 2:
        return '약';
      case 1:
        return '흉';
      default:
        return '평';
    }
  }

  /// 색상 (강도에 따라)
  Color get color {
    switch (strength) {
      case 5:
        return const Color(0xFF4CAF50); // 강한 초록 (12운성 고유 등급 색상)
      case 4:
        return const Color(0xFF8BC34A); // 연한 초록 (12운성 고유)
      case 3:
        return const Color(0xFFFFEB3B); // 노랑 (12운성 고유)
      case 2:
        return const Color(0xFFFF9800); // 주황 (12운성 고유)
      case 1:
        return const Color(0xFFF44336); // 빨강 (12운성 고유)
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

/// 12운성 계산기
class TwelveStageCalculator {
  TwelveStageCalculator._();

  /// 천간 목록
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

  /// 지지 목록
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

  /// 12운성 순서
  static const List<TwelveStage> _stages = TwelveStage.values;

  /// 일간(양간)별 장생지(長生地)
  /// 양간은 순행, 음간은 역행
  static const Map<String, String> _jangSaengJi = {
    '갑': '해', // 甲 - 亥
    '을': '오', // 乙 - 午 (역행)
    '병': '인', // 丙 - 寅
    '정': '유', // 丁 - 酉 (역행)
    '무': '인', // 戊 - 寅 (병과 동일)
    '기': '유', // 己 - 酉 (정과 동일, 역행)
    '경': '사', // 庚 - 巳
    '신': '자', // 辛 - 子 (역행)
    '임': '신', // 壬 - 申
    '계': '묘', // 癸 - 卯 (역행)
  };

  /// 일간이 양간인지 확인
  static bool _isYangGan(String stem) {
    final index = _tianGan.indexOf(stem);
    return index >= 0 && index % 2 == 0;
  }

  /// 일간과 지지로 12운성 계산
  ///
  /// [ilGan]: 일간 (갑, 을, 병, ...)
  /// [diZhi]: 지지 (자, 축, 인, ...)
  static TwelveStage calculate(String ilGan, String diZhi) {
    // 장생지 찾기
    final jangSaengZhi = _jangSaengJi[ilGan];
    if (jangSaengZhi == null) {
      return TwelveStage.jangSaeng; // 기본값
    }

    // 인덱스 계산
    final startIndex = _diZhi.indexOf(jangSaengZhi);
    final currentIndex = _diZhi.indexOf(diZhi);

    if (startIndex < 0 || currentIndex < 0) {
      return TwelveStage.jangSaeng;
    }

    // 양간은 순행, 음간은 역행
    int stageIndex;
    if (_isYangGan(ilGan)) {
      // 순행: 장생지에서 시계방향으로 진행
      stageIndex = (currentIndex - startIndex + 12) % 12;
    } else {
      // 역행: 장생지에서 반시계방향으로 진행
      stageIndex = (startIndex - currentIndex + 12) % 12;
    }

    return _stages[stageIndex];
  }

  /// 사주 4주의 12운성 계산
  ///
  /// [ilGan]: 일간
  /// [yearBranch], [monthBranch], [dayBranch], [hourBranch]: 년/월/일/시 지지
  static Map<String, TwelveStage> calculateAll({
    required String ilGan,
    required String yearBranch,
    required String monthBranch,
    required String dayBranch,
    required String hourBranch,
  }) {
    return {
      'year': calculate(ilGan, yearBranch),
      'month': calculate(ilGan, monthBranch),
      'day': calculate(ilGan, dayBranch),
      'hour': calculate(ilGan, hourBranch),
    };
  }

  /// 12운성 강도 합계 계산
  static int calculateTotalStrength({
    required String ilGan,
    required String yearBranch,
    required String monthBranch,
    required String dayBranch,
    required String hourBranch,
  }) {
    final stages = calculateAll(
      ilGan: ilGan,
      yearBranch: yearBranch,
      monthBranch: monthBranch,
      dayBranch: dayBranch,
      hourBranch: hourBranch,
    );

    return stages.values.fold(0, (sum, stage) => sum + stage.strength);
  }

  /// 일간의 신강/신약 판단
  ///
  /// 12운성 합계로 일간의 강약을 판단
  /// - 12 이상: 신강 (身强)
  /// - 8-11: 중화 (中和)
  /// - 7 이하: 신약 (身弱)
  static String judgeStrength({
    required String ilGan,
    required String yearBranch,
    required String monthBranch,
    required String dayBranch,
    required String hourBranch,
  }) {
    final total = calculateTotalStrength(
      ilGan: ilGan,
      yearBranch: yearBranch,
      monthBranch: monthBranch,
      dayBranch: dayBranch,
      hourBranch: hourBranch,
    );

    if (total >= 12) {
      return '신강';
    } else if (total >= 8) {
      return '중화';
    } else {
      return '신약';
    }
  }

  /// 12운성 표 생성 (디버그/표시용)
  /// 일간별로 12지지에 대한 12운성 매트릭스 반환
  static Map<String, Map<String, TwelveStage>> generateTable(String ilGan) {
    final result = <String, Map<String, TwelveStage>>{};

    for (final zhi in _diZhi) {
      result[zhi] = {'stage': calculate(ilGan, zhi)};
    }

    return result;
  }
}
