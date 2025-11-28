/// Helper functions for love fortune input page
class LoveFortuneInputHelpers {
  /// 성별 텍스트 변환
  static String getGenderText(String gender) {
    return gender == 'male' ? '남성' : '여성';
  }

  /// 연애 상태 텍스트 변환
  static String getRelationshipStatusText(String status) {
    switch (status) {
      case 'single':
        return '싱글';
      case 'dating':
        return '연애중';
      case 'breakup':
        return '이별 후';
      case 'crush':
        return '짝사랑';
      default:
        return status;
    }
  }

  /// 연애 스타일 텍스트 변환
  static String getDatingStyleText(String style) {
    switch (style) {
      case 'active':
        return '적극적';
      case 'passive':
        return '소극적';
      case 'emotional':
        return '감성적';
      case 'logical':
        return '이성적';
      case 'independent':
        return '독립적';
      case 'dependent':
        return '의존적';
      case 'serious':
        return '진지한';
      case 'casual':
        return '가벼운';
      default:
        return style;
    }
  }

  /// 라이프스타일 텍스트 변환
  static String getLifestyleText(String lifestyle) {
    switch (lifestyle) {
      case 'employee':
        return '직장인';
      case 'student':
        return '학생';
      case 'freelancer':
        return '프리랜서';
      case 'business':
        return '사업가';
      default:
        return lifestyle;
    }
  }

  /// 평균 중요도 계산
  static double getAverageImportance(Map<String, double> valueImportance) {
    if (valueImportance.isEmpty) return 0.0;
    return valueImportance.values.reduce((a, b) => a + b) / valueImportance.length;
  }
}
