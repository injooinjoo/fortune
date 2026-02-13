import 'package:equatable/equatable.dart';

class FortuneHistory extends Equatable {
  final String id;
  final String userId;
  final String fortuneType;
  final String title;
  final Map<String, dynamic> summary;
  final DateTime createdAt;

  // 새로 추가되는 필드들 (옵셔널)
  final Map<String, dynamic>? metadata; // 사용자 입력 정보, 설정값 등
  final Map<String, dynamic>? detailedResult; // 상세 운세 결과
  final List<String>? tags; // 운세 관련 태그들
  final int? viewCount; // 조회수
  final bool? isShared; // 공유 여부
  final DateTime? lastViewedAt; // 마지막 조회 시간
  final String? mood; // 당시 기분/상태
  final String? actualResult; // 실제 결과 (사용자가 나중에 기록)

  const FortuneHistory({
    required this.id,
    required this.userId,
    required this.fortuneType,
    required this.title,
    required this.summary,
    required this.createdAt,
    this.metadata,
    this.detailedResult,
    this.tags,
    this.viewCount,
    this.isShared,
    this.lastViewedAt,
    this.mood,
    this.actualResult,
  });

  factory FortuneHistory.fromJson(Map<String, dynamic> json) {
    return FortuneHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fortuneType: json['fortune_type'] as String,
      title: json['title'] as String,
      summary: json['summary'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      detailedResult: json['fortune_data'] as Map<String, dynamic>? ??
          json['detailed_result'] as Map<String, dynamic>?,
      tags: (json['tags'] as List?)?.cast<String>(),
      viewCount: json['view_count'] as int?,
      isShared: json['is_shared'] as bool?,
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.parse(json['last_viewed_at'] as String)
          : null,
      mood: json['mood'] as String?,
      actualResult: json['actual_result'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fortune_type': fortuneType,
      'title': title,
      'summary': summary,
      'created_at': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
      if (detailedResult != null) 'detailed_result': detailedResult,
      if (tags != null) 'tags': tags,
      if (viewCount != null) 'view_count': viewCount,
      if (isShared != null) 'is_shared': isShared,
      if (lastViewedAt != null)
        'last_viewed_at': lastViewedAt!.toIso8601String(),
      if (mood != null) 'mood': mood,
      if (actualResult != null) 'actual_result': actualResult,
    };
  }

  // copyWith 메소드 추가 (업데이트 시 유용)
  FortuneHistory copyWith({
    String? id,
    String? userId,
    String? fortuneType,
    String? title,
    Map<String, dynamic>? summary,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? detailedResult,
    List<String>? tags,
    int? viewCount,
    bool? isShared,
    DateTime? lastViewedAt,
    String? mood,
    String? actualResult,
  }) {
    return FortuneHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fortuneType: fortuneType ?? this.fortuneType,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      detailedResult: detailedResult ?? this.detailedResult,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      isShared: isShared ?? this.isShared,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      mood: mood ?? this.mood,
      actualResult: actualResult ?? this.actualResult,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fortuneType,
        title,
        summary,
        createdAt,
        metadata,
        detailedResult,
        tags,
        viewCount,
        isShared,
        lastViewedAt,
        mood,
        actualResult,
      ];
}
