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

  const MbtiDimensionFortune({
    required this.dimension,
    required this.title,
    required this.fortune,
    required this.tip,
    required this.score,
  });

  factory MbtiDimensionFortune.fromJson(Map<String, dynamic> json) {
    return MbtiDimensionFortune(
      dimension: json['dimension'] as String? ?? '',
      title: json['title'] as String? ?? '',
      fortune: json['fortune'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 70,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dimension': dimension,
      'title': title,
      'fortune': fortune,
      'tip': tip,
      'score': score,
    };
  }

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

/// API 응답에서 dimensions 배열 파싱
List<MbtiDimensionFortune> parseDimensions(List<dynamic>? dimensionsJson) {
  if (dimensionsJson == null) return [];
  return dimensionsJson
      .map((json) => MbtiDimensionFortune.fromJson(json as Map<String, dynamic>))
      .toList();
}
