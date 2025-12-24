import 'package:freezed_annotation/freezed_annotation.dart';

part 'emotion_analysis.freezed.dart';
part 'emotion_analysis.g.dart';

/// 감정 인식 분석 모델
/// 표정에서 감지된 감정 비율을 나타냅니다.
@freezed
class EmotionAnalysis with _$EmotionAnalysis {
  const factory EmotionAnalysis({
    /// 미소 지수 (0-100%)
    required double smilePercentage,

    /// 긴장 지수 (0-100%)
    required double tensionPercentage,

    /// 무표정 지수 (0-100%)
    required double neutralPercentage,

    /// 편안함 지수 (0-100%)
    required double relaxedPercentage,

    /// 주요 감정 상태 (smile, tension, neutral, relaxed)
    required String dominantEmotion,

    /// 감정 상태 설명 (친근한 말투)
    required String emotionDescription,

    /// 인상 분석 - 다른 사람에게 어떻게 보이는지
    required ImpressionAnalysis impressionAnalysis,
  }) = _EmotionAnalysis;

  factory EmotionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$EmotionAnalysisFromJson(json);
}

/// 인상 분석 - 다른 사람에게 어떻게 보이는지
@freezed
class ImpressionAnalysis with _$ImpressionAnalysis {
  const factory ImpressionAnalysis({
    /// 첫인상 키워드 (["따뜻한", "신뢰가 가는", "차분한"])
    required List<String> firstImpressionKeywords,

    /// 관계에서의 인상 ("친구들에게 편안한 분위기를 주는 편이에요")
    required String relationshipImpression,

    /// 직장/학교에서의 인상 ("면접관에게 진지한 인상을 줄 수 있어요")
    required String professionalImpression,

    /// 연애에서의 인상 (여성용: 배우자운, 연애운 관련)
    String? romanticImpression,

    /// 인상 개선 팁
    @Default([]) List<String> improvementSuggestions,

    /// 신뢰감 점수 (0-100)
    @Default(50) int trustScore,

    /// 친근감 점수 (0-100)
    @Default(50) int approachabilityScore,

    /// 카리스마 점수 (0-100)
    @Default(50) int charismaScore,

    /// 종합 인상 코멘트
    String? overallImpression,
  }) = _ImpressionAnalysis;

  factory ImpressionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ImpressionAnalysisFromJson(json);
}

/// 감정 변화 추이 (히스토리용)
@freezed
class EmotionTrend with _$EmotionTrend {
  const factory EmotionTrend({
    /// 최근 7일간 평균 미소 지수
    required double weeklySmileAverage,

    /// 이전 주 대비 미소 변화
    required double smileChange,

    /// 가장 많이 나타난 감정 상태
    required String dominantWeeklyEmotion,

    /// 감정 트렌드 인사이트
    required String emotionInsight,

    /// 일별 감정 데이터
    @Default([]) List<DailyEmotion> dailyEmotions,
  }) = _EmotionTrend;

  factory EmotionTrend.fromJson(Map<String, dynamic> json) =>
      _$EmotionTrendFromJson(json);
}

/// 일별 감정 데이터
@freezed
class DailyEmotion with _$DailyEmotion {
  const factory DailyEmotion({
    required DateTime date,
    required double smilePercentage,
    required double tensionPercentage,
    required double neutralPercentage,
    required double relaxedPercentage,
    required String dominantEmotion,
  }) = _DailyEmotion;

  factory DailyEmotion.fromJson(Map<String, dynamic> json) =>
      _$DailyEmotionFromJson(json);
}
