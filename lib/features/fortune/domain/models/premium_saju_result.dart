import 'package:freezed_annotation/freezed_annotation.dart';

part 'premium_saju_result.freezed.dart';
part 'premium_saju_result.g.dart';

/// 챕터 생성 상태
enum ChapterStatus {
  pending,
  generating,
  completed,
  error,
}

/// 섹션 타입 (콘텐츠 생성 방식)
enum SectionType {
  template, // 템플릿 기반
  llm, // LLM 생성
  hybrid, // 하이브리드
}

/// 프리미엄 사주 결과 - 메인 모델
@freezed
class PremiumSajuResult with _$PremiumSajuResult {
  const factory PremiumSajuResult({
    required String id,
    required String userId,
    required DateTime createdAt,

    // 생년월일시 정보
    required DateTime birthDateTime,
    @Default(false) bool isLunar,
    required String gender, // 'male' | 'female'

    // 사주 기초 데이터 (계산된 값)
    required SajuPillars pillars,
    required ElementDistribution elements,
    required FormatAnalysis formatAnalysis,
    required YongshinAnalysis yongshinAnalysis,

    // 콘텐츠 챕터
    @Default([]) List<PremiumChapter> chapters,

    // 구매 정보
    required PurchaseInfo purchaseInfo,

    // 상태
    required GenerationStatus generationStatus,
    @Default(null) ReadingProgress? readingProgress,
    @Default([]) List<Bookmark> bookmarks,
  }) = _PremiumSajuResult;

  factory PremiumSajuResult.fromJson(Map<String, dynamic> json) =>
      _$PremiumSajuResultFromJson(json);
}

/// 사주 사주 (四柱) - 년월일시
@freezed
class SajuPillars with _$SajuPillars {
  const factory SajuPillars({
    required Pillar yearPillar, // 년주
    required Pillar monthPillar, // 월주
    required Pillar dayPillar, // 일주
    required Pillar hourPillar, // 시주
  }) = _SajuPillars;

  factory SajuPillars.fromJson(Map<String, dynamic> json) =>
      _$SajuPillarsFromJson(json);
}

/// 개별 주 (기둥)
@freezed
class Pillar with _$Pillar {
  const factory Pillar({
    required String heavenlyStem, // 천간 (갑을병정...)
    required String earthlyBranch, // 지지 (자축인묘...)
    required String element, // 오행 (목화토금수)
    required String yinYang, // 음양
    String? hiddenStems, // 지장간
  }) = _Pillar;

  factory Pillar.fromJson(Map<String, dynamic> json) => _$PillarFromJson(json);
}

/// 오행 분포
@freezed
class ElementDistribution with _$ElementDistribution {
  const factory ElementDistribution({
    required int wood, // 목
    required int fire, // 화
    required int earth, // 토
    required int metal, // 금
    required int water, // 수
    required String dominant, // 가장 강한 오행
    required String lacking, // 부족한 오행
  }) = _ElementDistribution;

  factory ElementDistribution.fromJson(Map<String, dynamic> json) =>
      _$ElementDistributionFromJson(json);
}

/// 격국 분석
@freezed
class FormatAnalysis with _$FormatAnalysis {
  const factory FormatAnalysis({
    required String format, // 격국명 (정재격, 편재격 등)
    required String formatType, // 정격/종격/잡격
    required String strength, // 신강/신약
    required String description, // 격국 설명
  }) = _FormatAnalysis;

  factory FormatAnalysis.fromJson(Map<String, dynamic> json) =>
      _$FormatAnalysisFromJson(json);
}

/// 용신 분석
@freezed
class YongshinAnalysis with _$YongshinAnalysis {
  const factory YongshinAnalysis({
    required String yongshin, // 용신 (필요한 오행)
    required String heeshin, // 희신 (도움되는 오행)
    required String gishin, // 기신 (해로운 오행)
    required String chousin, // 구신 (나쁜 오행)
    required String method, // 판단 방법 (억부법, 조후법 등)
    required String description, // 용신 설명
  }) = _YongshinAnalysis;

  factory YongshinAnalysis.fromJson(Map<String, dynamic> json) =>
      _$YongshinAnalysisFromJson(json);
}

/// 프리미엄 챕터
@freezed
class PremiumChapter with _$PremiumChapter {
  const factory PremiumChapter({
    required String id,
    required int partNumber, // 1-6
    required int chapterNumber, // 1.1, 1.2 등의 소수점 아래
    required String title,
    @Default('') String emoji,
    required ChapterStatus status,
    @Default([]) List<PremiumSection> sections,
    @Default(0) int estimatedPages,
    @Default(0) int actualWordCount,
    DateTime? generatedAt,
    String? errorMessage,
  }) = _PremiumChapter;

  factory PremiumChapter.fromJson(Map<String, dynamic> json) =>
      _$PremiumChapterFromJson(json);
}

/// 프리미엄 섹션
@freezed
class PremiumSection with _$PremiumSection {
  const factory PremiumSection({
    required String id,
    required String title,
    required SectionType type,
    @Default('') String content, // 마크다운 콘텐츠
    @Default([]) List<String> subsectionTitles,
    @Default(false) bool isGenerated,
    DateTime? generatedAt,
  }) = _PremiumSection;

  factory PremiumSection.fromJson(Map<String, dynamic> json) =>
      _$PremiumSectionFromJson(json);
}

/// 생성 상태
@freezed
class GenerationStatus with _$GenerationStatus {
  const factory GenerationStatus({
    required int totalChapters,
    @Default(0) int completedChapters,
    @Default(0) int currentChapterIndex,
    @Default(false) bool isComplete,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
  }) = _GenerationStatus;

  factory GenerationStatus.fromJson(Map<String, dynamic> json) =>
      _$GenerationStatusFromJson(json);
}

/// 읽기 진행도
@freezed
class ReadingProgress with _$ReadingProgress {
  const factory ReadingProgress({
    @Default(0) int currentChapter,
    @Default(0) int currentSection,
    @Default(0.0) double scrollPosition,
    @Default(0) int totalReadingTimeSeconds,
    required DateTime lastReadAt,
  }) = _ReadingProgress;

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      _$ReadingProgressFromJson(json);
}

/// 북마크
@freezed
class Bookmark with _$Bookmark {
  const factory Bookmark({
    required String id,
    required int chapterIndex,
    required int sectionIndex,
    required String title,
    required DateTime createdAt,
    String? note,
  }) = _Bookmark;

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
}

/// 구매 정보
@freezed
class PurchaseInfo with _$PurchaseInfo {
  const factory PurchaseInfo({
    required String transactionId,
    required String productId,
    required double price,
    @Default('KRW') String currency,
    required DateTime purchasedAt,
    @Default(true) bool isLifetimeOwnership,
  }) = _PurchaseInfo;

  factory PurchaseInfo.fromJson(Map<String, dynamic> json) =>
      _$PurchaseInfoFromJson(json);
}

/// 대운 정보 (10년 주기)
@freezed
class GrandLuck with _$GrandLuck {
  const factory GrandLuck({
    required int order, // 1~8대운
    required int startAge, // 시작 나이
    required int endAge, // 끝 나이
    required String heavenlyStem, // 대운 천간
    required String earthlyBranch, // 대운 지지
    required String element, // 오행
    required String summary, // 대운 요약
    required String detailedAnalysis, // 상세 분석
    @Default([]) List<String> keyEvents, // 주요 이벤트
    @Default({}) Map<String, int> fortuneScores, // 운세 점수 (재물, 애정 등)
  }) = _GrandLuck;

  factory GrandLuck.fromJson(Map<String, dynamic> json) =>
      _$GrandLuckFromJson(json);
}

/// 신살 정보
@freezed
class ShinSal with _$ShinSal {
  const factory ShinSal({
    required String name, // 신살명 (천을귀인, 문창귀인 등)
    required String type, // 길신/흉신
    required String position, // 위치 (년주, 월주 등)
    required String description, // 설명
    required String effect, // 효과
  }) = _ShinSal;

  factory ShinSal.fromJson(Map<String, dynamic> json) =>
      _$ShinSalFromJson(json);
}
