import 'package:flutter/material.dart';

/// MBTI 4차원 운세 데이터 모델
///
/// E/I, N/S, T/F, J/P 각 차원별 운세 정보를 담습니다.
class MbtiDimensionFortune {
  /// 차원 코드 ("E", "I", "N", "S", "T", "F", "J", "P")
  final String dimension;

  /// 차원 타이틀 (예: "외향형 에너지")
  final String title;

  /// 운세 텍스트 (50자 이내)
  final String fortune;

  /// 조언 (30자 이내)
  final String tip;

  /// 점수 (0-100)
  final int score;

  /// 경고 메시지 (30-50자) - 위기감/긴장감 유발
  final String? warning;

  const MbtiDimensionFortune({
    required this.dimension,
    required this.title,
    required this.fortune,
    required this.tip,
    required this.score,
    this.warning,
  });

  factory MbtiDimensionFortune.fromJson(Map<String, dynamic> json) {
    final dimension = json['dimension'] as String? ?? '';
    return MbtiDimensionFortune(
      dimension: dimension,
      title: json['title'] as String? ?? '',
      fortune: json['fortune'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 70,
      warning: json['warning'] as String? ?? defaultWarnings[dimension],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dimension': dimension,
      'title': title,
      'fortune': fortune,
      'tip': tip,
      'score': score,
      if (warning != null) 'warning': warning,
    };
  }

  /// 차원별 경고 아이콘 반환
  String get warningIcon => dimensionWarningIcons[dimension] ?? '⚠️';

  /// 차원별 색상 반환
  Color get color => dimensionColors[dimension] ?? const Color(0xFF6B7280);

  /// 차원별 아이콘 반환
  String get icon => dimensionIcons[dimension] ?? '✨';

  /// 차원별 그라데이션 반환
  List<Color> get gradient {
    final baseColor = color;
    return [
      baseColor,
      baseColor.withValues(alpha: 0.7),
    ];
  }

  @override
  String toString() {
    return 'MbtiDimensionFortune(dimension: $dimension, title: $title, score: $score)';
  }
}

/// 차원별 색상 매핑
const Map<String, Color> dimensionColors = {
  'E': Color(0xFFFF6B6B), // 레드 - 외향
  'I': Color(0xFF4ECDC4), // 틸 - 내향
  'N': Color(0xFF9B59B6), // 퍼플 - 직관
  'S': Color(0xFF3498DB), // 블루 - 감각
  'T': Color(0xFF2ECC71), // 그린 - 사고
  'F': Color(0xFFE91E63), // 핑크 - 감정
  'J': Color(0xFFFF9800), // 오렌지 - 판단
  'P': Color(0xFF00BCD4), // 시안 - 인식
};

/// 차원별 아이콘 매핑
const Map<String, String> dimensionIcons = {
  'E': '🔋', // 외향형 에너지
  'I': '🔋', // 내향형 에너지
  'N': '🔮', // 직관의 영역
  'S': '👁️', // 감각의 영역
  'T': '🧠', // 사고의 힘
  'F': '💜', // 감정의 흐름
  'J': '📋', // 계획의 날
  'P': '🌊', // 유연의 날
};

/// 차원별 타이틀 매핑
const Map<String, String> dimensionTitles = {
  'E': '외향형 에너지',
  'I': '내향형 에너지',
  'N': '직관의 영역',
  'S': '감각의 영역',
  'T': '사고의 힘',
  'F': '감정의 흐름',
  'J': '계획의 날',
  'P': '유연의 날',
};

/// 차원별 경고 아이콘 매핑
const Map<String, String> dimensionWarningIcons = {
  'E': '⚡', // 충동적 행동 주의
  'I': '🔒', // 고립 주의
  'N': '🌫️', // 현실 회피 주의
  'S': '🔍', // 세부 집착 주의
  'T': '❄️', // 감정 무시 주의
  'F': '🌊', // 감정 휩쓸림 주의
  'J': '⏰', // 기회 놓침 주의
  'P': '🎲', // 즉흥 후회 주의
};

/// 차원별 기본 경고 메시지
const Map<String, String> defaultWarnings = {
  'E': '즉흥적인 약속이 중요한 일정과 충돌할 수 있어요',
  'I': '혼자만의 시간에 빠져 중요한 기회를 놓칠 수 있어요',
  'N': '가능성에만 몰두하면 현실적 준비를 놓칠 수 있어요',
  'S': '세부사항에만 집착하면 큰 흐름을 놓칠 수 있어요',
  'T': '논리만 앞세우다 중요한 사람의 마음을 잃을 수 있어요',
  'F': '감정에 휩쓸리면 객관적 판단을 놓칠 수 있어요',
  'J': '분석적으로 고민만 하다가는 큰 기회를 놓칠 수 있어요',
  'P': '즉흥적인 결정이 나중에 후회로 돌아올 수 있어요',
};

/// API 응답에서 dimensions 배열 파싱
List<MbtiDimensionFortune> parseDimensions(List<dynamic>? dimensionsJson) {
  if (dimensionsJson == null) return [];
  return dimensionsJson
      .map((json) => MbtiDimensionFortune.fromJson(json as Map<String, dynamic>))
      .toList();
}
