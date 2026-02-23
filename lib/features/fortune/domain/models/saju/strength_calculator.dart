// 신강/신약(身强/身弱) 점수 계산 로직
//
// 일간(日干)의 강약을 0-100 점수로 수치화
//
// 판단 기준 3가지:
// 1. 득령(得令): 월지가 일간을 생(生)하거나 같은 오행인가
// 2. 득지(得地): 년지/일지/시지가 일간을 돕는가
// 3. 득세(得勢): 천간들이 일간을 돕는가
//
// 라벨:
//   0-20: 극약(極弱)
//  21-40: 약(弱)
//  41-60: 중화(中和)
//  61-80: 강(强)
//  81-100: 극강(極强)
library;

import 'package:flutter/material.dart';

/// 신강/신약 판정 결과
class StrengthResult {
  /// 총 점수 (0-100)
  final int score;

  /// 라벨 (극약/약/중화/강/극강)
  final String label;

  /// 한자 라벨
  final String labelHanja;

  /// 득령 점수 (0-40)
  final int deukryeong;

  /// 득지 점수 (0-30)
  final int deukji;

  /// 득세 점수 (0-30)
  final int deukse;

  /// 일간 오행
  final String dayElement;

  /// 일간 음양
  final String dayYinYang;

  const StrengthResult({
    required this.score,
    required this.label,
    required this.labelHanja,
    required this.deukryeong,
    required this.deukji,
    required this.deukse,
    required this.dayElement,
    required this.dayYinYang,
  });

  /// 색상 (점수에 따라)
  Color get color {
    if (score >= 81) return const Color(0xFFE53935); // 극강 - 빨강
    if (score >= 61) return const Color(0xFFFF7043); // 강 - 주황
    if (score >= 41) return const Color(0xFF66BB6A); // 중화 - 초록
    if (score >= 21) return const Color(0xFF42A5F5); // 약 - 파랑
    return const Color(0xFF7E57C2); // 극약 - 보라
  }

  Map<String, dynamic> toMap() => {
        'score': score,
        'label': label,
        'labelHanja': labelHanja,
        'deukryeong': deukryeong,
        'deukji': deukji,
        'deukse': deukse,
        'dayElement': dayElement,
        'dayYinYang': dayYinYang,
      };
}

/// 신강/신약 계산기
class StrengthCalculator {
  StrengthCalculator._();

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

  /// 천간 음양 (짝수 인덱스 = 양)
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

  /// 상생 관계: key가 value를 생함
  /// 목→화→토→금→수→목
  static const Map<String, String> _shengMap = {
    '목': '화',
    '화': '토',
    '토': '금',
    '금': '수',
    '수': '목',
  };

  /// 오행 관계 판별
  static String _getRelation(String source, String target) {
    if (source == target) return '동'; // 같은 오행 (비화)
    if (_shengMap[target] == source) return '생'; // target이 나를 생
    if (_shengMap[source] == target) return '설'; // 내가 target을 생 (설기)
    // 상극 관계
    final keMap = {'목': '토', '토': '수', '수': '화', '화': '금', '금': '목'};
    if (keMap[target] == source) return '극'; // target이 나를 극
    return '피극'; // 내가 target을 극
  }

  /// 월지가 일간에 대해 득령인지 판별 (0-40점)
  ///
  /// - 월지 오행 == 일간 오행: 40점 (왕)
  /// - 월지가 일간을 생: 30점 (상)
  /// - 중립: 20점
  /// - 월지가 일간을 설기: 10점
  /// - 월지가 일간을 극: 5점
  static int _calcDeukryeong(String dayElement, String monthBranch) {
    final monthElement = _branchElements[monthBranch] ?? '';
    final relation = _getRelation(dayElement, monthElement);

    switch (relation) {
      case '동':
        return 40; // 같은 오행 → 왕지
      case '생':
        return 30; // 월지가 나를 생 → 상(相)
      case '설':
        return 10; // 내가 월지를 생 → 설기
      case '극':
        return 5; // 월지가 나를 극 → 사(死)
      case '피극':
        return 15; // 내가 월지를 극 → 수(囚)
      default:
        return 20;
    }
  }

  /// 년지/일지/시지의 득지 점수 (0-30점)
  ///
  /// 각 지지별 최대 10점
  static int _calcDeukji(
    String dayElement,
    String yearBranch,
    String dayBranch,
    String? hourBranch,
  ) {
    int score = 0;

    score += _branchScore(dayElement, yearBranch);
    score += _branchScore(dayElement, dayBranch);
    if (hourBranch != null && hourBranch.isNotEmpty) {
      score += _branchScore(dayElement, hourBranch);
    }

    return score.clamp(0, 30);
  }

  /// 개별 지지 점수 (0-10)
  static int _branchScore(String dayElement, String branch) {
    final branchElement = _branchElements[branch] ?? '';
    final relation = _getRelation(dayElement, branchElement);

    switch (relation) {
      case '동':
        return 10; // 같은 오행
      case '생':
        return 7; // 나를 생
      case '피극':
        return 3; // 내가 극
      case '설':
        return 2; // 내가 생 (설기)
      case '극':
        return 0; // 나를 극
      default:
        return 5;
    }
  }

  /// 천간의 득세 점수 (0-30점)
  ///
  /// 년간/월간/시간 각각 최대 10점
  static int _calcDeukse(
    String dayStem,
    String yearStem,
    String monthStem,
    String? hourStem,
  ) {
    final dayElement = _stemElements[dayStem] ?? '';
    int score = 0;

    score += _stemScore(dayElement, yearStem);
    score += _stemScore(dayElement, monthStem);
    if (hourStem != null && hourStem.isNotEmpty) {
      score += _stemScore(dayElement, hourStem);
    }

    return score.clamp(0, 30);
  }

  /// 개별 천간 점수 (0-10)
  static int _stemScore(String dayElement, String stem) {
    final stemElement = _stemElements[stem] ?? '';
    final relation = _getRelation(dayElement, stemElement);

    switch (relation) {
      case '동':
        return 10; // 같은 오행
      case '생':
        return 7; // 나를 생
      case '피극':
        return 3; // 내가 극
      case '설':
        return 2; // 내가 생 (설기)
      case '극':
        return 0; // 나를 극
      default:
        return 5;
    }
  }

  /// 종합 신강/신약 점수 계산
  ///
  /// [dayStem]: 일간
  /// [yearStem]: 년간
  /// [monthStem]: 월간
  /// [hourStem]: 시간 (없으면 null)
  /// [yearBranch]: 년지
  /// [monthBranch]: 월지
  /// [dayBranch]: 일지
  /// [hourBranch]: 시지 (없으면 null)
  static StrengthResult calculate({
    required String dayStem,
    required String yearStem,
    required String monthStem,
    String? hourStem,
    required String yearBranch,
    required String monthBranch,
    required String dayBranch,
    String? hourBranch,
  }) {
    final dayElement = _stemElements[dayStem] ?? '';
    final dayIdx = _tianGan.indexOf(dayStem);
    final dayYinYang = (dayIdx >= 0 && dayIdx % 2 == 0) ? '양' : '음';

    // 3대 요소 계산
    final deukryeong = _calcDeukryeong(dayElement, monthBranch);
    final deukji = _calcDeukji(dayElement, yearBranch, dayBranch, hourBranch);
    final deukse = _calcDeukse(dayStem, yearStem, monthStem, hourStem);

    // 총점 (0-100)
    final totalScore = (deukryeong + deukji + deukse).clamp(0, 100);

    // 라벨 결정
    final (label, labelHanja) = _getLabel(totalScore);

    return StrengthResult(
      score: totalScore,
      label: label,
      labelHanja: labelHanja,
      deukryeong: deukryeong,
      deukji: deukji,
      deukse: deukse,
      dayElement: dayElement,
      dayYinYang: dayYinYang,
    );
  }

  /// 점수 → 라벨
  static (String, String) _getLabel(int score) {
    if (score >= 81) return ('극강', '極强');
    if (score >= 61) return ('강', '强');
    if (score >= 41) return ('중화', '中和');
    if (score >= 21) return ('약', '弱');
    return ('극약', '極弱');
  }

  /// sajuData Map에서 신강/신약 계산 (편의 메서드)
  ///
  /// sajuData 구조:
  /// ```
  /// {
  ///   'year': {'cheongan': {'char': '갑'}, 'jiji': {'char': '자'}},
  ///   'month': {'cheongan': {'char': '을'}, 'jiji': {'char': '축'}},
  ///   'day': {'cheongan': {'char': '병'}, 'jiji': {'char': '인'}},
  ///   'hour': {'cheongan': {'char': '정'}, 'jiji': {'char': '묘'}},
  /// }
  /// ```
  static StrengthResult? calculateFromSajuData(Map<String, dynamic> sajuData) {
    try {
      // myungsik 형식
      final myungsik = sajuData['myungsik'] as Map<String, dynamic>?;
      if (myungsik != null) {
        return calculate(
          dayStem: myungsik['daySky'] as String? ?? '',
          yearStem: myungsik['yearSky'] as String? ?? '',
          monthStem: myungsik['monthSky'] as String? ?? '',
          hourStem: myungsik['hourSky'] as String?,
          yearBranch: myungsik['yearEarth'] as String? ?? '',
          monthBranch: myungsik['monthEarth'] as String? ?? '',
          dayBranch: myungsik['dayEarth'] as String? ?? '',
          hourBranch: myungsik['hourEarth'] as String?,
        );
      }

      // 중첩 형식 (cheongan/jiji)
      String? extractPillarChar(String pillar, String type) {
        final pillarData = sajuData[pillar] as Map<String, dynamic>?;
        if (pillarData == null) return null;
        final sub = pillarData[type] as Map<String, dynamic>?;
        return sub?['char'] as String?;
      }

      final dayStem = extractPillarChar('day', 'cheongan');
      if (dayStem == null || dayStem.isEmpty) return null;

      return calculate(
        dayStem: dayStem,
        yearStem: extractPillarChar('year', 'cheongan') ?? '',
        monthStem: extractPillarChar('month', 'cheongan') ?? '',
        hourStem: extractPillarChar('hour', 'cheongan'),
        yearBranch: extractPillarChar('year', 'jiji') ?? '',
        monthBranch: extractPillarChar('month', 'jiji') ?? '',
        dayBranch: extractPillarChar('day', 'jiji') ?? '',
        hourBranch: extractPillarChar('hour', 'jiji'),
      );
    } catch (_) {
      return null;
    }
  }
}
