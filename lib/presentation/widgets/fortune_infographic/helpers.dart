import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// Helper methods for fortune infographic widgets
class FortuneInfographicHelpers {
  FortuneInfographicHelpers._();

  /// Get score grade based on score value
  static String getScoreGrade(int score) {
    if (score >= 90) return 'S';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    return 'D';
  }

  /// Get keyword color based on weight (ChatGPT 스타일)
  static Color getKeywordColor(double weight) {
    if (weight >= 0.8) return DSColors.success; // 대대길
    if (weight >= 0.6) return DSColors.info; // 대길
    if (weight >= 0.4) return DSColors.accentSecondary; // 길
    if (weight >= 0.2) return DSColors.warning; // 평
    return DSColors.error; // 소흉
  }

  /// Get lucky item color based on type (ChatGPT 스타일)
  static Color getLuckyItemColor(String type) {
    switch (type.toLowerCase()) {
      case 'color':
      case '색상':
        return DSColors.accentSecondary;
      case 'food':
      case '음식':
        return DSColors.warning;
      case 'item':
      case '아이템':
        return DSColors.info;
      case 'number':
      case '숫자':
        return DSColors.success;
      case 'direction':
      case '방향':
        return DSColors.info;
      case 'place':
      case '장소':
        return DSColors.accentSecondary;
      default:
        return DSColors.warning;
    }
  }

  /// Get lucky item icon based on type
  static IconData getLuckyItemIcon(String type) {
    switch (type.toLowerCase()) {
      case 'color':
      case '색상':
        return Icons.palette;
      case 'food':
      case '음식':
        return Icons.restaurant;
      case 'item':
      case '아이템':
        return Icons.stars;
      case 'number':
      case '숫자':
        return Icons.numbers;
      default:
        return Icons.auto_awesome;
    }
  }

  /// Get category score color
  static Color getCategoryScoreColor(int score, bool isDarkMode) {
    if (score >= 80) {
      return DSColors.success;
    } else if (score >= 60) {
      return DSColors.accentDark;
    } else if (score >= 40) {
      return DSColors.warning;
    } else {
      return DSColors.error;
    }
  }

  /// Get default category title
  static String getDefaultCategoryTitle(String key) {
    switch (key) {
      case 'love':
        return '연애운';
      case 'money':
        return '금전운';
      case 'work':
      case 'career':
        return '직장운';
      case 'study':
        return '학업운';
      case 'health':
        return '건강운';
      default:
        return key.toUpperCase();
    }
  }

  /// Get default category short description
  static String getDefaultCategoryShort(String key, int score) {
    switch (key) {
      case 'love':
        return score >= 70
            ? '순조로운 연애운'
            : score >= 50
                ? '평범한 연애운'
                : '조심스러운 연애운';
      case 'money':
        return score >= 70
            ? '안정적인 금전운'
            : score >= 50
                ? '보통의 금전운'
                : '신중한 소비 필요';
      case 'work':
      case 'career':
        return score >= 70
            ? '발전하는 직장운'
            : score >= 50
                ? '평범한 직장운'
                : '주의가 필요한 시기';
      case 'study':
        return score >= 70
            ? '향상되는 학업운'
            : score >= 50
                ? '평범한 학업운'
                : '집중력 관리 필요';
      case 'health':
        return score >= 70
            ? '건강한 컨디션'
            : score >= 50
                ? '보통의 건강상태'
                : '건강 관리 필요';
      default:
        return score >= 70
            ? '좋은 운세'
            : score >= 50
                ? '보통 운세'
                : '주의 필요';
    }
  }

  /// Get default fortune summary
  static String getDefaultFortuneSummary(
      String? zodiacAnimal, String? zodiacSign, String? mbti) {
    final elements = <String>[];

    if (zodiacAnimal != null) {
      elements.add('$zodiacAnimal띠');
    }
    if (zodiacSign != null) {
      elements.add(zodiacSign);
    }
    if (mbti != null) {
      elements.add(mbti);
    }

    final profile = elements.isNotEmpty ? '${elements.join(', ')}의 ' : '';

    return '$profile오늘의 운세를 종합적으로 분석한 결과, 전반적으로 균형 잡힌 하루가 될 것으로 예상됩니다. 새로운 기회와 도전이 함께 찾아올 수 있으니 긍정적인 마음가짐을 유지하세요.';
  }
}
