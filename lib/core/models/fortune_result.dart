/// 통합 운세 결과 모델
///
/// 모든 운세 타입에 공통적으로 사용되는 표준 결과 형식
class FortuneResult {
  /// 운세 고유 ID (fortune_history 테이블의 ID)
  final String? id;

  /// 운세 타입 (예: 'tarot', 'daily', 'mbti', 'biorhythm' 등)
  final String type;

  /// 운세 제목
  final String title;

  /// 운세 요약 정보
  /// 예: {'score': 85, 'message': '좋은 하루입니다', 'emoji': '😊'}
  final Map<String, dynamic> summary;

  /// 운세 전체 데이터 (운세별로 다른 구조)
  /// 예:
  /// - 타로: {'cards': [...], 'interpretations': [...]}
  /// - 바이오리듬: {'physical': 85, 'emotional': 70, 'intellectual': 90}
  /// - MBTI: {'mbti_type': 'INFP', 'today_advice': '...', 'lucky_color': '...'}
  final Map<String, dynamic> data;

  /// 운세 점수 (0-100)
  final int? score;

  /// 생성 시간
  final DateTime? createdAt;

  /// 마지막 조회 시간
  final DateTime? lastViewedAt;

  /// 조회수
  final int? viewCount;

  /// 블러 상태 (광고 시청 전 일부 내용 숨김)
  final bool isBlurred;

  /// 블러 처리할 섹션 키 목록
  /// 예: ['advice', 'luckItems', 'warnings', 'detailedAnalysis']
  final List<String> blurredSections;

  FortuneResult({
    this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.data,
    this.score,
    this.createdAt,
    this.lastViewedAt,
    this.viewCount,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

  /// JSON으로부터 FortuneResult 생성
  factory FortuneResult.fromJson(Map<String, dynamic> json) {
    return FortuneResult(
      id: json['id'] as String?,
      type: json['fortune_type'] as String? ?? json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? '운세 결과',
      summary: json['summary'] as Map<String, dynamic>? ?? {},
      data: json['fortune_data'] as Map<String, dynamic>? ?? json['data'] as Map<String, dynamic>? ?? {},
      score: json['score'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.parse(json['last_viewed_at'] as String)
          : null,
      viewCount: json['view_count'] as int?,
      isBlurred: json['is_blurred'] as bool? ?? false,
      blurredSections: json['blurred_sections'] != null
          ? List<String>.from(json['blurred_sections'] as List)
          : [],
    );
  }

  /// FortuneResult를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fortune_type': type,
      'type': type,
      'title': title,
      'summary': summary,
      'fortune_data': data,
      'data': data,
      if (score != null) 'score': score,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt!.toIso8601String(),
      if (viewCount != null) 'view_count': viewCount,
      'is_blurred': isBlurred,
      'blurred_sections': blurredSections,
    };
  }

  /// FortuneResult 복사 (일부 필드 변경)
  FortuneResult copyWith({
    String? id,
    String? type,
    String? title,
    Map<String, dynamic>? summary,
    Map<String, dynamic>? data,
    int? score,
    DateTime? createdAt,
    DateTime? lastViewedAt,
    int? viewCount,
    bool? isBlurred,
    List<String>? blurredSections,
  }) {
    return FortuneResult(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      data: data ?? this.data,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      viewCount: viewCount ?? this.viewCount,
      isBlurred: isBlurred ?? this.isBlurred,
      blurredSections: blurredSections ?? this.blurredSections,
    );
  }

  @override
  String toString() {
    return 'FortuneResult(id: $id, type: $type, title: $title, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FortuneResult &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.score == score;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        title.hashCode ^
        score.hashCode;
  }
}
