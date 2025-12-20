import '../fortune_conditions.dart';
import '../../../presentation/widgets/event_category_selector.dart'; // EventCategory
import '../../../presentation/widgets/event_detail_input_form.dart'; // EmotionState

/// 시간별 운세 조건
///
/// 특징:
/// - 날짜는 제외 (매일 새로운 운세)
/// - period, category, emotion, question으로 조건 구분
///
/// 예시:
/// ```dart
/// final conditions = DailyFortuneConditions(
///   period: FortunePeriod.daily,
///   category: EventCategory.work,
///   emotion: EmotionState.happy,
///   question: '오늘 중요한 미팅이 있어요',
/// );
/// ```
class DailyFortuneConditions extends FortuneConditions {
  final FortunePeriod period;
  final EventCategory? category;
  final EmotionState? emotion;
  final String? question;

  DailyFortuneConditions({
    required this.period,
    this.category,
    this.emotion,
    this.question,
  });

  @override
  String generateHash() {
    // 🚀 질문 제외 → 125 조합 (5×5×5)으로 API 비용 절감
    // 기존: ∞ 조합 (질문마다 새 해시) → API 호출 무한
    // 개선: 125 조합 → 37,500회 API 후 완전 캐시 (125 × 300)
    //
    // 품질 트레이드오프: 같은 period/category/emotion이면 다른 질문도 같은 결과
    // 하지만 개인 캐시(1단계)에서 오늘 조회 여부는 여전히 체크됨
    final parts = <String>[
      'period:${period.name}',
      if (category != null) 'category:${category!.name}',
      if (emotion != null) 'emotion:${emotion!.name}',
      // 질문은 해시에서 제외 (API 비용 최적화)
      // if (question != null && question!.isNotEmpty) 'q:${question!.hashCode}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'period': period.name,
      if (category != null) 'category': category!.name,
      if (emotion != null) 'emotion': emotion!.name,
      if (question != null) 'question': question,
    };
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'period': period.name,
      if (category != null) 'category': category!.name,
      if (emotion != null) 'emotion': emotion!.name,
      // 질문은 해시만 저장 (개인정보 보호)
      if (question != null && question!.isNotEmpty) 'question_hash': question!.hashCode.toString(),
      // 날짜는 포함하지 않음 (매일 변경)
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    final now = DateTime.now();
    return {
      'fortune_type': 'daily',
      'period': period.name,
      'date': _formatDate(now),
      'day_of_week': _getDayOfWeek(now),
      'month': now.month,
      'year': now.year,
      if (category != null) 'category': category!.label,
      if (category != null) 'categoryType': category!.name,
      if (emotion != null) 'emotion': emotion!.label,
      if (emotion != null) 'emotionType': emotion!.name,
      if (question != null) 'question': question,
    };
  }

  /// 요일 이름 반환
  String _getDayOfWeek(DateTime date) {
    const weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekDays[date.weekday - 1];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyFortuneConditions &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          category == other.category &&
          emotion == other.emotion &&
          question == other.question;

  @override
  int get hashCode =>
      period.hashCode ^
      (category?.hashCode ?? 0) ^
      (emotion?.hashCode ?? 0) ^
      (question?.hashCode ?? 0);

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

/// 운세 기간 타입
enum FortunePeriod {
  /// 오늘의 운세
  daily('daily', '오늘'),

  /// 내일의 운세
  tomorrow('tomorrow', '내일'),

  /// 주간 운세
  weekly('weekly', '이번 주'),

  /// 월간 운세
  monthly('monthly', '이번 달'),

  /// 연간 운세
  yearly('yearly', '올해');

  final String name;
  final String displayName;

  const FortunePeriod(this.name, this.displayName);

  /// 이름으로 FortunePeriod 찾기
  static FortunePeriod fromName(String name) {
    return FortunePeriod.values.firstWhere(
      (period) => period.name == name,
      orElse: () => FortunePeriod.daily,
    );
  }
}
