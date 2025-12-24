import 'package:freezed_annotation/freezed_annotation.dart';

part 'face_condition.freezed.dart';
part 'face_condition.g.dart';

/// 얼굴 컨디션 분석 모델
/// 오늘의 안색, 혈색, 붓기, 피로도를 나타냅니다.
@freezed
class FaceCondition with _$FaceCondition {
  const factory FaceCondition({
    /// 혈색 점수 (0-100)
    required int complexionScore,

    /// 혈색 상태 설명 ("화사해요", "조금 창백해 보여요" 등)
    required String complexionDescription,

    /// 붓기 레벨 (0-100, 낮을수록 좋음)
    required int puffinessLevel,

    /// 붓기 상태 설명
    required String puffinessDescription,

    /// 피로도 레벨 (0-100, 낮을수록 좋음)
    required int fatigueLevel,

    /// 피로도 상태 설명
    required String fatigueDescription,

    /// 종합 컨디션 점수 (0-100)
    required int overallScore,

    /// 오늘의 얼굴 한줄 요약 ("오늘은 미소 지수가 조금 낮아요" 등)
    required String todaySummary,

    /// 컨디션 개선 팁
    @Default([]) List<ConditionTip> improvementTips,
  }) = _FaceCondition;

  factory FaceCondition.fromJson(Map<String, dynamic> json) =>
      _$FaceConditionFromJson(json);
}

/// 컨디션 개선 팁
@freezed
class ConditionTip with _$ConditionTip {
  const factory ConditionTip({
    /// 팁 카테고리 (hydration, rest, exercise, skincare)
    required String category,

    /// 팁 내용 (친근한 말투로)
    required String content,

    /// 아이콘 이모지
    @Default('💡') String emoji,
  }) = _ConditionTip;

  factory ConditionTip.fromJson(Map<String, dynamic> json) =>
      _$ConditionTipFromJson(json);
}

/// 컨디션 변화 추이 (히스토리용)
@freezed
class ConditionTrend with _$ConditionTrend {
  const factory ConditionTrend({
    /// 최근 7일간 평균 컨디션
    required double weeklyAverage,

    /// 이전 주 대비 변화 (-100 ~ +100)
    required double weeklyChange,

    /// 트렌드 방향 (improving, stable, declining)
    required String trendDirection,

    /// 트렌드 인사이트 ("요즘 표정이 점점 부드러워지고 있어요")
    required String trendInsight,

    /// 일별 컨디션 데이터
    @Default([]) List<DailyCondition> dailyConditions,
  }) = _ConditionTrend;

  factory ConditionTrend.fromJson(Map<String, dynamic> json) =>
      _$ConditionTrendFromJson(json);
}

/// 일별 컨디션 데이터
@freezed
class DailyCondition with _$DailyCondition {
  const factory DailyCondition({
    required DateTime date,
    required int overallScore,
    required int complexionScore,
    required int puffinessLevel,
    required int fatigueLevel,
  }) = _DailyCondition;

  factory DailyCondition.fromJson(Map<String, dynamic> json) =>
      _$DailyConditionFromJson(json);
}
