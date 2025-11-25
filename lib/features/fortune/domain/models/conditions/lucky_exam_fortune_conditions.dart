import '../fortune_conditions.dart';

/// 시험 운세 조건
class LuckyExamFortuneConditions extends FortuneConditions {
  // 기존 필드
  final String examType; // 시험 종류 (deprecated - examSubType 사용 권장)
  final DateTime examDate; // 시험 날짜
  final String? subject; // 과목
  final int preparationLevel; // 준비 수준 (1-5)
  final int anxietyLevel; // 불안 수준 (1-5)

  // 새로운 필드 (리뉴얼)
  final String examCategory; // 시험 카테고리 ("대학입시", "공무원", "자격증", "어학", "면접", "승진", "기타")
  final String? examSubType; // 세부 시험 종류 (예: "수능", "국가직9급", "토익" 등)
  final String? targetScore; // 목표 점수/등급
  final String preparationStatus; // 준비 상태 ("완벽준비", "준비중", "아직멀음")
  final String timePoint; // 시험 시점 ("preparation", "intensive", "final_week", "test_day")

  LuckyExamFortuneConditions({
    required this.examType,
    required this.examDate,
    this.subject,
    required this.preparationLevel,
    required this.anxietyLevel,
    required this.examCategory,
    this.examSubType,
    this.targetScore,
    required this.preparationStatus,
    required this.timePoint,
  });

  @override
  String generateHash() {
    final parts = <String>[
      'category:${examCategory.hashCode}',
      if (examSubType != null) 'subtype:${examSubType!.hashCode}',
      'date:${_formatDate(examDate)}',
      if (subject != null) 'subject:${subject!.hashCode}',
      'prep:$preparationLevel',
      'anxiety:$anxietyLevel',
      'status:${preparationStatus.hashCode}',
      'timepoint:${timePoint.hashCode}',
      if (targetScore != null) 'target:${targetScore!.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'exam_type': examType,
      'exam_date': examDate.toIso8601String(),
      if (subject != null) 'subject': subject,
      'preparation_level': preparationLevel,
      'anxiety_level': anxietyLevel,
      'exam_category': examCategory,
      if (examSubType != null) 'exam_sub_type': examSubType,
      if (targetScore != null) 'target_score': targetScore,
      'preparation_status': preparationStatus,
      'time_point': timePoint,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'exam_type': examType,
      'exam_date': _formatDate(examDate),
      'subject': subject,
      'preparation_level': preparationLevel,
      'exam_category': examCategory,
      'exam_sub_type': examSubType,
      'preparation_status': preparationStatus,
      'time_point': timePoint,
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'exam_type': examType,
      'exam_date': examDate.toIso8601String(),
      if (subject != null) 'subject': subject,
      'preparation_level': preparationLevel,
      'anxiety_level': anxietyLevel,
      'exam_category': examCategory,
      if (examSubType != null) 'exam_sub_type': examSubType,
      if (targetScore != null) 'target_score': targetScore,
      'preparation_status': preparationStatus,
      'time_point': timePoint,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LuckyExamFortuneConditions &&
          runtimeType == other.runtimeType &&
          examType == other.examType &&
          examDate == other.examDate &&
          subject == other.subject &&
          preparationLevel == other.preparationLevel &&
          anxietyLevel == other.anxietyLevel &&
          examCategory == other.examCategory &&
          examSubType == other.examSubType &&
          targetScore == other.targetScore &&
          preparationStatus == other.preparationStatus &&
          timePoint == other.timePoint;

  @override
  int get hashCode =>
      examType.hashCode ^
      examDate.hashCode ^
      subject.hashCode ^
      preparationLevel.hashCode ^
      anxietyLevel.hashCode ^
      examCategory.hashCode ^
      examSubType.hashCode ^
      targetScore.hashCode ^
      preparationStatus.hashCode ^
      timePoint.hashCode;

  /// 시험 카테고리별 세부 시험 종류 매핑
  static const Map<String, List<String>> examCategories = {
    '대학입시': ['수능', '수시면접', '정시면접', '대학원입시'],
    '공무원': ['국가직9급', '국가직7급', '지방직', '특정직', '교육청'],
    '자격증': ['기사/기능사', '전문가자격', '금융자격', '국제자격', '기타'],
    '어학': ['토익', '토플', '오픽', '텝스', '일본어', '중국어', 'HSK', 'JLPT'],
    '면접': ['필기면접', '기술면접', 'PT발표', '집단토론', '임원면접'],
    '승진': ['부사관', '간부', '전문직', '승진시험', '특급'],
    '기타': ['운전면허', '학교시험', '모의고사', '기타'],
  };

  /// 준비 상태 옵션
  static const List<String> preparationStatusOptions = [
    '완벽준비',
    '준비중',
    '아직멀음',
  ];

  /// 시험 시점 옵션
  static const Map<String, String> timePointLabels = {
    'preparation': '장기 준비 (30일 이상)',
    'intensive': '집중 준비 (7~30일)',
    'final_week': '마지막 주 (1~7일)',
    'test_day': '시험 당일',
  };

  /// 시험일까지 남은 일수로 timePoint 자동 계산
  static String calculateTimePoint(DateTime examDate) {
    final now = DateTime.now();
    final daysLeft = examDate.difference(now).inDays;

    if (daysLeft < 0) {
      return 'test_day'; // 시험 날짜가 지났거나 당일
    } else if (daysLeft == 0) {
      return 'test_day';
    } else if (daysLeft <= 7) {
      return 'final_week';
    } else if (daysLeft <= 30) {
      return 'intensive';
    } else {
      return 'preparation';
    }
  }

  /// timePoint의 한국어 라벨 가져오기
  static String getTimePointLabel(String timePoint) {
    return timePointLabels[timePoint] ?? '알 수 없음';
  }

  /// 시험 카테고리 목록 가져오기
  static List<String> getCategoryList() {
    return examCategories.keys.toList();
  }

  /// 특정 카테고리의 세부 시험 목록 가져오기
  static List<String> getSubTypeList(String category) {
    return examCategories[category] ?? [];
  }
}
