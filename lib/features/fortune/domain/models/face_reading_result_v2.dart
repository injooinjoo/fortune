import 'package:freezed_annotation/freezed_annotation.dart';
import 'face_condition.dart';
import 'emotion_analysis.dart';

part 'face_reading_result_v2.freezed.dart';
part 'face_reading_result_v2.g.dart';

/// 우선순위 인사이트 (핵심 포인트 3가지)
@freezed
class PriorityInsight with _$PriorityInsight {
  const factory PriorityInsight({
    /// 인사이트 제목
    required String title,

    /// 인사이트 설명 (친근한 말투)
    required String description,

    /// 우선순위 (1: 최고, 2, 3)
    required int priority,

    /// 카테고리 (wealth, love, career, health, relationship, personality, first_impression, beauty)
    required String category,

    /// 점수 (선택적)
    int? score,

    /// 관련 부위 또는 궁
    String? relatedFeature,
  }) = _PriorityInsight;

  factory PriorityInsight.fromJson(Map<String, dynamic> json) =>
      _$PriorityInsightFromJson(json);
}

/// 관상 분석 결과 V2 - 확장 모델
/// 성별/연령 기반 분기, 신규 분석 요소, 말투 전환을 지원합니다.
@freezed
class FaceReadingResultV2 with _$FaceReadingResultV2 {
  const factory FaceReadingResultV2({
    required String id,
    required String userId,
    required DateTime createdAt,

    // === 사용자 정보 ===
    required String gender, // 'male' | 'female'
    String? ageGroup, // '20s', '30s', etc.

    // === 핵심 요약 (기본 노출) ===
    /// 핵심 포인트 3가지 (성별에 따라 다른 내용)
    @Default([]) List<PriorityInsight> priorityInsights,

    /// 종합 운세 점수 (0-100)
    required int overallScore,

    /// 한줄 요약 (친근한 말투)
    required String summaryMessage,

    /// 총평 (전체 운세 설명)
    @Default('') String overallFortune,

    /// 얼굴형 (타원형, 둥근형 등)
    @Default('') String faceType,

    // === 신규 분석 요소 ===
    /// 오늘의 얼굴 컨디션 (혈색, 붓기, 피로도)
    FaceCondition? faceCondition,

    /// 감정 인식 분석 (미소, 긴장, 무표정 %)
    EmotionAnalysis? emotionAnalysis,

    // === 전통 관상 분석 (접히는 섹션) ===
    /// 명궁 분석 (미간 → 명궁으로 순서 변경)
    MyeonggungAnalysis? myeonggungAnalysis,

    /// 미간 분석
    MiganAnalysis? miganAnalysis,

    /// 오관 분석 (요약형)
    SimplifiedOgwan? simplifiedOgwan,

    /// 십이궁 분석 (요약형)
    SimplifiedSibigung? simplifiedSibigung,

    /// 닮은꼴 연예인 목록
    @Default([]) List<CelebrityMatch> celebrityMatches,

    // === 성별 특화 콘텐츠 ===
    /// 여성 전용: 스타일 추천
    MakeupStyleRecommendations? makeupRecommendations,

    /// 여성 전용: 매력 포인트 강조
    LuckyFeatureEnhancement? luckyFeatureEnhancement,

    /// 남성 전용: 리더십/직업 적합도
    LeadershipAnalysis? leadershipAnalysis,

    // === Apple Watch 데이터 ===
    WatchFaceReadingData? watchData,

    // === 공유용 데이터 ===
    ShareableContent? shareableContent,
  }) = _FaceReadingResultV2;

  factory FaceReadingResultV2.fromJson(Map<String, dynamic> json) =>
      _$FaceReadingResultV2FromJson(json);
}

/// 닮은꼴 연예인 매칭
@freezed
class CelebrityMatch with _$CelebrityMatch {
  const factory CelebrityMatch({
    /// 연예인 이름
    required String name,

    /// 유사도 점수 (0-100)
    required int matchScore,

    /// 이미지 URL (선택적)
    String? imageUrl,

    /// 닮은 특징 설명
    String? matchDescription,

    /// 공통 특징들
    @Default([]) List<String> commonTraits,
  }) = _CelebrityMatch;

  factory CelebrityMatch.fromJson(Map<String, dynamic> json) =>
      _$CelebrityMatchFromJson(json);
}

/// 명궁 분석
@freezed
class MyeonggungAnalysis with _$MyeonggungAnalysis {
  const factory MyeonggungAnalysis({
    /// 명궁 상태 설명 (친근한 말투)
    required String description,

    /// 인생 전반 운세
    required String lifeFortuneMessage,

    /// 점수 (0-100)
    required int score,

    /// 한줄 요약 (접힌 상태에서 표시)
    @Default('') String summary,

    /// 상세 분석 (펼쳤을 때 표시)
    String? detailedAnalysis,

    /// 운명 특성 태그
    @Default([]) List<String> destinyTraits,

    /// 강점
    @Default([]) List<String> strengths,

    /// 약점/주의점
    @Default([]) List<String> weaknesses,

    /// 운을 높이는 조언
    String? advice,

    /// 개선 팁
    @Default([]) List<String> improvementTips,
  }) = _MyeonggungAnalysis;

  factory MyeonggungAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MyeonggungAnalysisFromJson(json);
}

/// 미간 분석
@freezed
class MiganAnalysis with _$MiganAnalysis {
  const factory MiganAnalysis({
    /// 미간 상태 설명 (친근한 말투)
    required String description,

    /// 관련 운세 메시지
    required String fortuneMessage,

    /// 점수 (0-100)
    required int score,

    /// 한줄 요약 (접힌 상태에서 표시)
    @Default('') String summary,

    /// 상세 분석 (펼쳤을 때 표시)
    String? detailedAnalysis,

    /// 적성 분야 목록
    @Default([]) List<String> careerAptitudes,

    /// 추천 분야
    @Default([]) List<String> recommendedFields,

    /// 성취 스타일 설명
    String? achievementStyle,

    /// 주의사항
    @Default([]) List<String> cautions,

    /// 조언
    String? advice,
  }) = _MiganAnalysis;

  factory MiganAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MiganAnalysisFromJson(json);
}

/// 요약형 오관 분석
@freezed
class SimplifiedOgwan with _$SimplifiedOgwan {
  const factory SimplifiedOgwan({
    /// 오관 항목들
    required List<SimplifiedOgwanItem> items,

    /// 종합 요약 (친근한 말투)
    required String summary,

    /// 가장 좋은 부위
    required String bestFeature,

    /// 주의가 필요한 부위
    String? cautionFeature,
  }) = _SimplifiedOgwan;

  factory SimplifiedOgwan.fromJson(Map<String, dynamic> json) =>
      _$SimplifiedOgwanFromJson(json);
}

/// 오관 개별 항목
@freezed
class SimplifiedOgwanItem with _$SimplifiedOgwanItem {
  const factory SimplifiedOgwanItem({
    /// 부위 이름 (눈, 코, 입, 귀, 눈썹)
    required String featureName,

    /// 부위 ID (eyes, nose, mouth, ears, eyebrows)
    required String featureId,

    /// 관련 운세 카테고리 (인간관계, 재물운, 결혼운 등)
    required String fortuneCategory,

    /// 한줄 요약 (친근한 말투)
    required String summary,

    /// 점수 (0-100)
    required int score,

    /// 상세 분석 (펼쳤을 때)
    String? detailedAnalysis,

    /// 이모지
    @Default('') String emoji,
  }) = _SimplifiedOgwanItem;

  factory SimplifiedOgwanItem.fromJson(Map<String, dynamic> json) =>
      _$SimplifiedOgwanItemFromJson(json);
}

/// 요약형 십이궁 분석
@freezed
class SimplifiedSibigung with _$SimplifiedSibigung {
  const factory SimplifiedSibigung({
    /// 십이궁 항목들
    required List<SimplifiedSibigungItem> items,

    /// 종합 요약 (친근한 말투)
    required String summary,

    /// 가장 강한 궁
    required String strongestPalace,

    /// 주의가 필요한 궁
    String? cautionPalace,
  }) = _SimplifiedSibigung;

  factory SimplifiedSibigung.fromJson(Map<String, dynamic> json) =>
      _$SimplifiedSibigungFromJson(json);
}

/// 십이궁 개별 항목
@freezed
class SimplifiedSibigungItem with _$SimplifiedSibigungItem {
  const factory SimplifiedSibigungItem({
    /// 궁 이름 (명궁, 재백궁, 형제궁 등)
    required String palaceName,

    /// 궁 ID
    required String palaceId,

    /// 관련 분야 (인생 전반, 재물, 형제 관계 등)
    required String relatedArea,

    /// 한줄 요약 (친근한 말투)
    required String summary,

    /// 점수 (0-100)
    required int score,

    /// 상세 분석 (펼쳤을 때)
    String? detailedAnalysis,

    /// 이모지
    @Default('') String emoji,
  }) = _SimplifiedSibigungItem;

  factory SimplifiedSibigungItem.fromJson(Map<String, dynamic> json) =>
      _$SimplifiedSibigungItemFromJson(json);
}

/// 메이크업 스타일 추천 (여성 전용)
@freezed
class MakeupStyleRecommendations with _$MakeupStyleRecommendations {
  const factory MakeupStyleRecommendations({
    /// 가장 매력적인 부위
    required String mostAttractiveFeature,

    /// 매력 부위 강조 팁
    required String enhancementTip,

    /// 추천 메이크업 스타일
    required List<MakeupStyle> recommendedStyles,

    /// 행운 색상 (메이크업용)
    required LuckyColorForMakeup luckyColor,

    /// 피해야 할 스타일
    String? styleToAvoid,
  }) = _MakeupStyleRecommendations;

  factory MakeupStyleRecommendations.fromJson(Map<String, dynamic> json) =>
      _$MakeupStyleRecommendationsFromJson(json);
}

/// 메이크업 스타일
@freezed
class MakeupStyle with _$MakeupStyle {
  const factory MakeupStyle({
    /// 스타일 이름 (청순, 시크, 내추럴 등)
    required String styleName,

    /// 스타일 설명
    required String description,

    /// 어울리는 상황
    required String suitableOccasion,

    /// 이모지
    @Default('💄') String emoji,
  }) = _MakeupStyle;

  factory MakeupStyle.fromJson(Map<String, dynamic> json) =>
      _$MakeupStyleFromJson(json);
}

/// 메이크업용 행운 색상
@freezed
class LuckyColorForMakeup with _$LuckyColorForMakeup {
  const factory LuckyColorForMakeup({
    /// 색상 이름 (한국어)
    required String colorName,

    /// 색상 코드
    required String colorCode,

    /// 적용 부위 (립, 아이섀도우, 블러셔)
    required String applicationArea,

    /// 이유 설명
    required String reason,
  }) = _LuckyColorForMakeup;

  factory LuckyColorForMakeup.fromJson(Map<String, dynamic> json) =>
      _$LuckyColorForMakeupFromJson(json);
}

/// 매력 포인트 강조 (여성 전용)
@freezed
class LuckyFeatureEnhancement with _$LuckyFeatureEnhancement {
  const factory LuckyFeatureEnhancement({
    /// 가장 매력적인 부위
    required String featureName,

    /// 매력 포인트 설명
    required String description,

    /// 강조 방법
    @Default([]) List<String> enhancementMethods,

    /// 관련 운세 (이 부위로 인해 좋아지는 운)
    required String relatedFortune,
  }) = _LuckyFeatureEnhancement;

  factory LuckyFeatureEnhancement.fromJson(Map<String, dynamic> json) =>
      _$LuckyFeatureEnhancementFromJson(json);
}

/// 리더십 분석 (남성 전용)
@freezed
class LeadershipAnalysis with _$LeadershipAnalysis {
  const factory LeadershipAnalysis({
    /// 리더십 스타일 (카리스마형, 민주적, 섬김형 등)
    required String leadershipStyle,

    /// 리더십 점수 (0-100)
    required int leadershipScore,

    /// 적합한 직업군
    required List<String> suitableCareers,

    /// 리더십 강점
    required String strength,

    /// 개선 포인트
    String? improvementPoint,

    /// 비즈니스 운세
    required String businessFortune,
  }) = _LeadershipAnalysis;

  factory LeadershipAnalysis.fromJson(Map<String, dynamic> json) =>
      _$LeadershipAnalysisFromJson(json);
}

/// Apple Watch용 데이터
@freezed
class WatchFaceReadingData with _$WatchFaceReadingData {
  const factory WatchFaceReadingData({
    /// 오늘의 행운 방향
    required String luckyDirection,

    /// 행운 색상
    required WatchLuckyColor luckyColor,

    /// 행운 시간대
    required List<String> luckyTimePeriods,

    /// 일일 리마인더 메시지 ("지금 1분만 숨을 고르세요")
    required String dailyReminderMessage,

    /// 간단한 오늘의 운세
    required String briefFortune,

    /// 컨디션 점수
    required int conditionScore,

    /// 미소 지수
    required int smileScore,
  }) = _WatchFaceReadingData;

  factory WatchFaceReadingData.fromJson(Map<String, dynamic> json) =>
      _$WatchFaceReadingDataFromJson(json);
}

/// Watch용 행운 색상
@freezed
class WatchLuckyColor with _$WatchLuckyColor {
  const factory WatchLuckyColor({
    required String colorName,
    required String colorCode,
  }) = _WatchLuckyColor;

  factory WatchLuckyColor.fromJson(Map<String, dynamic> json) =>
      _$WatchLuckyColorFromJson(json);
}

/// 공유용 콘텐츠
@freezed
class ShareableContent with _$ShareableContent {
  const factory ShareableContent({
    /// 공유 제목 ("오늘의 얼굴 운세")
    required String title,

    /// 감성 문구
    required String emotionalQuote,

    /// 하이라이트 포인트 (3가지)
    required List<String> highlights,

    /// 공유 이미지 URL (생성된)
    String? shareImageUrl,

    /// Instagram 스토리용 데이터
    InstagramShareData? instagramData,
  }) = _ShareableContent;

  factory ShareableContent.fromJson(Map<String, dynamic> json) =>
      _$ShareableContentFromJson(json);
}

/// Instagram 공유용 데이터
@freezed
class InstagramShareData with _$InstagramShareData {
  const factory InstagramShareData({
    /// 배경 색상 그라데이션
    required List<String> backgroundGradient,

    /// 메인 텍스트
    required String mainText,

    /// 서브 텍스트
    required String subText,

    /// 해시태그 추천
    required List<String> suggestedHashtags,
  }) = _InstagramShareData;

  factory InstagramShareData.fromJson(Map<String, dynamic> json) =>
      _$InstagramShareDataFromJson(json);
}
