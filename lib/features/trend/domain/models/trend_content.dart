import 'package:freezed_annotation/freezed_annotation.dart';

part 'trend_content.freezed.dart';
part 'trend_content.g.dart';

/// 트렌드 콘텐츠 타입 열거형
enum TrendContentType {
  @JsonValue('psychology_test')
  psychologyTest,
  @JsonValue('ideal_worldcup')
  idealWorldcup,
  @JsonValue('balance_game')
  balanceGame,
}

/// 트렌드 카테고리 열거형
enum TrendCategory {
  @JsonValue('love')
  love,
  @JsonValue('personality')
  personality,
  @JsonValue('lifestyle')
  lifestyle,
  @JsonValue('entertainment')
  entertainment,
  @JsonValue('food')
  food,
  @JsonValue('animal')
  animal,
  @JsonValue('work')
  work,
}

extension TrendContentTypeExtension on TrendContentType {
  String get displayName {
    switch (this) {
      case TrendContentType.psychologyTest:
        return '심리테스트';
      case TrendContentType.idealWorldcup:
        return '이상형 월드컵';
      case TrendContentType.balanceGame:
        return '밸런스 게임';
    }
  }

  String get emoji {
    switch (this) {
      case TrendContentType.psychologyTest:
        return '🧠';
      case TrendContentType.idealWorldcup:
        return '🏆';
      case TrendContentType.balanceGame:
        return '⚖️';
    }
  }
}

extension TrendCategoryExtension on TrendCategory {
  String get displayName {
    switch (this) {
      case TrendCategory.love:
        return '연애';
      case TrendCategory.personality:
        return '성격';
      case TrendCategory.lifestyle:
        return '라이프';
      case TrendCategory.entertainment:
        return '엔터';
      case TrendCategory.food:
        return '음식';
      case TrendCategory.animal:
        return '동물';
      case TrendCategory.work:
        return '직장';
    }
  }

  String get emoji {
    switch (this) {
      case TrendCategory.love:
        return '💕';
      case TrendCategory.personality:
        return '🧠';
      case TrendCategory.lifestyle:
        return '🌟';
      case TrendCategory.entertainment:
        return '🎬';
      case TrendCategory.food:
        return '🍔';
      case TrendCategory.animal:
        return '🐾';
      case TrendCategory.work:
        return '💼';
    }
  }
}

/// 트렌드 콘텐츠 공통 모델
@freezed
class TrendContent with _$TrendContent {
  const factory TrendContent({
    required String id,
    required TrendContentType type,
    required String title,
    String? subtitle,
    String? thumbnailUrl,
    required TrendCategory category,
    @Default(0) int viewCount,
    @Default(0) int participantCount,
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    @Default(true) bool isActive,
    @Default(false) bool isPremium,
    @Default(0) int tokenCost,
    DateTime? startDate,
    DateTime? endDate,
    @Default(0) int sortOrder,
    @Default({}) Map<String, dynamic> metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TrendContent;

  factory TrendContent.fromJson(Map<String, dynamic> json) =>
      _$TrendContentFromJson(json);
}

/// 트렌드 콘텐츠 목록 응답
@freezed
class TrendContentListResponse with _$TrendContentListResponse {
  const factory TrendContentListResponse({
    required List<TrendContent> contents,
    @Default(0) int totalCount,
    @Default(false) bool hasMore,
  }) = _TrendContentListResponse;

  factory TrendContentListResponse.fromJson(Map<String, dynamic> json) =>
      _$TrendContentListResponseFromJson(json);
}
