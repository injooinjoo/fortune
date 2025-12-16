import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// 궁합 페이지 유틸리티 함수
class CompatibilityUtils {
  /// 점수에 따른 색상 반환
  static Color getScoreColor(double score) {
    if (score >= 0.9) return DSColors.success; // 매우 좋음 - 초록
    if (score >= 0.8) return const Color(0xFF3B82F6); // 좋음 - 파랑
    if (score >= 0.7) return DSColors.warning; // 보통 - 노랑
    if (score >= 0.6) return DSColors.error; // 나쁨 - 빨강
    return DSColors.textSecondary; // 매우 나쁨 - 회색
  }

  /// 점수에 따른 텍스트 반환
  static String getScoreText(double score) {
    if (score >= 0.9) return '매우 좋음';
    if (score >= 0.8) return '좋음';
    if (score >= 0.7) return '보통';
    if (score >= 0.6) return '나쁨';
    return '매우 나쁨';
  }
}
