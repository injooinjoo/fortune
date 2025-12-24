import 'package:freezed_annotation/freezed_annotation.dart';
import 'face_condition.dart';
import 'emotion_analysis.dart';

part 'face_reading_history_entry.freezed.dart';
part 'face_reading_history_entry.g.dart';

/// 관상 분석 히스토리 엔트리
/// 캘린더, 그래프, 비교 분석에 사용됩니다.
@freezed
class FaceReadingHistoryEntry with _$FaceReadingHistoryEntry {
  const factory FaceReadingHistoryEntry({
    required String id,
    required String userId,
    required DateTime createdAt,

    /// 분석 당시 사용자 정보
    required String gender, // 'male' | 'female'
    String? ageGroup, // '20s', '30s', etc.

    /// 썸네일 이미지 URL (선택적 - 사용자 동의 시에만)
    String? thumbnailUrl,

    /// 분석 결과 ID (상세 결과 조회용)
    required String resultId,

    /// 얼굴 컨디션 스냅샷
    required FaceCondition faceCondition,

    /// 감정 분석 스냅샷
    required EmotionAnalysis emotionAnalysis,

    /// 핵심 포인트 요약 (3가지)
    required List<PriorityInsight> priorityInsights,

    /// 종합 운세 점수 (0-100)
    required int overallFortuneScore,

    /// 카테고리별 점수
    required CategoryScores categoryScores,

    /// 메모 (사용자가 추가한)
    String? userNote,

    /// 미션 완료 여부
    @Default(false) bool missionCompleted,
  }) = _FaceReadingHistoryEntry;

  factory FaceReadingHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$FaceReadingHistoryEntryFromJson(json);
}

/// 우선순위 인사이트 (핵심 포인트 3가지)
@freezed
class PriorityInsight with _$PriorityInsight {
  const factory PriorityInsight({
    /// 인사이트 카테고리 (love, career, relationship, health, wealth)
    required String category,

    /// 카테고리 라벨 (연애운, 직업운, 인간관계, 건강, 재물)
    required String categoryLabel,

    /// 핵심 메시지 (친근한 말투)
    required String message,

    /// 점수 (0-100)
    required int score,

    /// 아이콘 이모지
    @Default('✨') String emoji,

    /// 관련 얼굴 부위 (눈, 코, 입술 등)
    String? relatedFeature,
  }) = _PriorityInsight;

  factory PriorityInsight.fromJson(Map<String, dynamic> json) =>
      _$PriorityInsightFromJson(json);
}

/// 카테고리별 점수
@freezed
class CategoryScores with _$CategoryScores {
  const factory CategoryScores({
    /// 연애운 (여성 중점)
    required int loveScore,

    /// 결혼운/배우자운 (여성 중점)
    required int marriageScore,

    /// 인간관계
    required int relationshipScore,

    /// 직업운/리더십 (남성 중점)
    required int careerScore,

    /// 재물운
    required int wealthScore,

    /// 건강운
    required int healthScore,

    /// 첫인상/면접 운
    required int impressionScore,
  }) = _CategoryScores;

  factory CategoryScores.fromJson(Map<String, dynamic> json) =>
      _$CategoryScoresFromJson(json);
}

/// 히스토리 비교 분석 결과
@freezed
class HistoryComparison with _$HistoryComparison {
  const factory HistoryComparison({
    /// 비교 대상 날짜 1
    required DateTime date1,

    /// 비교 대상 날짜 2
    required DateTime date2,

    /// 컨디션 변화
    required ConditionChange conditionChange,

    /// 감정 변화
    required EmotionChange emotionChange,

    /// 카테고리별 점수 변화
    required ScoreChanges scoreChanges,

    /// 비교 인사이트 ("지난달보다 미소가 더 자연스러워졌어요")
    required String comparisonInsight,
  }) = _HistoryComparison;

  factory HistoryComparison.fromJson(Map<String, dynamic> json) =>
      _$HistoryComparisonFromJson(json);
}

/// 컨디션 변화
@freezed
class ConditionChange with _$ConditionChange {
  const factory ConditionChange({
    required int complexionChange,
    required int puffinessChange,
    required int fatigueChange,
    required int overallChange,
    required String summary, // "전반적으로 컨디션이 좋아졌어요"
  }) = _ConditionChange;

  factory ConditionChange.fromJson(Map<String, dynamic> json) =>
      _$ConditionChangeFromJson(json);
}

/// 감정 변화
@freezed
class EmotionChange with _$EmotionChange {
  const factory EmotionChange({
    required double smileChange,
    required double tensionChange,
    required double relaxedChange,
    required String summary, // "표정이 더 밝아졌어요"
  }) = _EmotionChange;

  factory EmotionChange.fromJson(Map<String, dynamic> json) =>
      _$EmotionChangeFromJson(json);
}

/// 점수 변화
@freezed
class ScoreChanges with _$ScoreChanges {
  const factory ScoreChanges({
    required int loveChange,
    required int marriageChange,
    required int careerChange,
    required int wealthChange,
    required int healthChange,
    required int relationshipChange,
    required String summary, // "연애운이 크게 상승했어요"
  }) = _ScoreChanges;

  factory ScoreChanges.fromJson(Map<String, dynamic> json) =>
      _$ScoreChangesFromJson(json);
}

/// 히스토리 통계 (대시보드용)
@freezed
class HistoryStats with _$HistoryStats {
  const factory HistoryStats({
    /// 총 분석 횟수
    required int totalAnalysisCount,

    /// 연속 기록 일수
    required int streakDays,

    /// 최장 연속 기록 일수
    required int longestStreak,

    /// 이번 달 분석 횟수
    required int thisMonthCount,

    /// 평균 컨디션 점수
    required double averageConditionScore,

    /// 평균 미소 지수
    required double averageSmilePercentage,

    /// 가장 좋았던 날
    DateTime? bestConditionDate,

    /// 미션 완료율
    required double missionCompletionRate,
  }) = _HistoryStats;

  factory HistoryStats.fromJson(Map<String, dynamic> json) =>
      _$HistoryStatsFromJson(json);
}
