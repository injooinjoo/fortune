import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 이사운 결과 유틸리티 함수들
class MovingResultUtils {
  /// 점수에 따른 색상 반환
  static Color getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    return DSColors.warning;
  }

  /// 점수 설명 텍스트 반환
  static String getScoreDescription(int score) {
    if (score >= 90) return '최고의 이사운!';
    if (score >= 80) return '매우 좋은 이사운';
    if (score >= 70) return '좋은 이사운';
    if (score >= 60) return '양호한 이사운';
    return '보통 이사운';
  }

  /// 목적에 따른 메인 조언 반환
  static String getMainAdvice(String purpose, String bestDirection) {
    switch (purpose) {
      case '직장 때문에':
        return '출퇴근이 편리한 $bestDirection쪽이 최적입니다. 교통 접근성을 우선 고려하세요.';
      case '결혼해서':
        return '두 분의 새로운 시작에 $bestDirection쪽이 길합니다. 남향집이 화목한 가정을 만듭니다.';
      case '교육 환경':
        return '자녀의 학업운이 $bestDirection쪽에서 상승합니다. 조용하고 안전한 환경을 선택하세요.';
      case '투자 목적':
        return '$bestDirection쪽 지역의 가치 상승이 예상됩니다. 교통 개발 계획을 확인하세요.';
      default:
        return '$bestDirection쪽으로의 이사가 새로운 행운을 가져다 줄 것입니다.';
    }
  }

  /// 타이밍에 따른 색상 반환
  static Color getTimeColor(String timing) {
    if (timing.contains('D-30')) return DSColors.accent;
    if (timing.contains('D-21') || timing.contains('D-14')) return DSColors.warning;
    if (timing.contains('D-7') || timing.contains('D-3') || timing.contains('D-1')) return DSColors.error;
    return DSColors.accent;
  }

  /// 예산 카테고리별 색상 반환
  static Color getBudgetColor(String category) {
    switch (category) {
      case '이사업체': return DSColors.accent;
      case '포장재료': return DSColors.warning;
      case '청소비용': return DSColors.success;
      case '기타비용': return DSColors.accent;
      default: return DSColors.border;
    }
  }

  /// 요일 이름 반환
  static String getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }
}
