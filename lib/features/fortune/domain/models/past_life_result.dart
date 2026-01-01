/// 전생 운세 결과 모델
///
/// 사용자의 전생 신분, 스토리, AI 초상화 정보를 담습니다.
class PastLifeResult {
  /// 고유 ID
  final String id;

  /// 전생 신분 (한글) - 왕, 기생, 선비 등
  final String pastLifeStatus;

  /// 전생 신분 (영문) - King, Gisaeng, Scholar 등
  final String pastLifeStatusEn;

  /// 전생 성별 - male, female
  final String pastLifeGender;

  /// 전생 시대 - 조선 초기, 중기, 후기
  final String pastLifeEra;

  /// 전생 이름 - 홍길동, 춘향 등
  final String pastLifeName;

  /// 전생 스토리 (300-500자)
  final String story;

  /// 스토리 요약 (1-2문장)
  final String summary;

  /// AI 초상화 이미지 URL
  final String portraitUrl;

  /// 현생과의 연결 조언
  final String advice;

  /// 전생 운세 점수 (1-100)
  final int score;

  /// 생성 시간
  final DateTime createdAt;

  /// 블러 상태 (프리미엄 미구매 시 true)
  final bool isBlurred;

  /// 블러 처리된 섹션 목록
  final List<String> blurredSections;

  const PastLifeResult({
    required this.id,
    required this.pastLifeStatus,
    required this.pastLifeStatusEn,
    required this.pastLifeGender,
    required this.pastLifeEra,
    required this.pastLifeName,
    required this.story,
    required this.summary,
    required this.portraitUrl,
    required this.advice,
    required this.score,
    required this.createdAt,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

  /// 성별 한글 표시
  String get pastLifeGenderKo => pastLifeGender == 'male' ? '남성' : '여성';

  /// 운세 타입 식별자
  String get fortuneType => 'past-life';

  /// JSON에서 생성
  factory PastLifeResult.fromJson(Map<String, dynamic> json) {
    return PastLifeResult(
      id: json['id'] ?? '',
      pastLifeStatus: json['pastLifeStatus'] ?? json['past_life_status'] ?? '',
      pastLifeStatusEn: json['pastLifeStatusEn'] ?? json['past_life_status_en'] ?? '',
      pastLifeGender: json['pastLifeGender'] ?? json['past_life_gender'] ?? 'male',
      pastLifeEra: json['pastLifeEra'] ?? json['past_life_era'] ?? '',
      pastLifeName: json['pastLifeName'] ?? json['past_life_name'] ?? '',
      story: json['story'] ?? json['story_text'] ?? '',
      summary: json['summary'] ?? json['story_summary'] ?? '',
      portraitUrl: json['portraitUrl'] ?? json['portrait_url'] ?? '',
      advice: json['advice'] ?? '',
      score: json['score'] ?? 75,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      isBlurred: json['isBlurred'] ?? false,
      blurredSections: json['blurredSections'] != null
          ? List<String>.from(json['blurredSections'])
          : [],
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
        'id': id,
        'pastLifeStatus': pastLifeStatus,
        'pastLifeStatusEn': pastLifeStatusEn,
        'pastLifeGender': pastLifeGender,
        'pastLifeEra': pastLifeEra,
        'pastLifeName': pastLifeName,
        'story': story,
        'summary': summary,
        'portraitUrl': portraitUrl,
        'advice': advice,
        'score': score,
        'createdAt': createdAt.toIso8601String(),
        'isBlurred': isBlurred,
        'blurredSections': blurredSections,
      };

  /// copyWith 메서드
  PastLifeResult copyWith({
    String? id,
    String? pastLifeStatus,
    String? pastLifeStatusEn,
    String? pastLifeGender,
    String? pastLifeEra,
    String? pastLifeName,
    String? story,
    String? summary,
    String? portraitUrl,
    String? advice,
    int? score,
    DateTime? createdAt,
    bool? isBlurred,
    List<String>? blurredSections,
  }) {
    return PastLifeResult(
      id: id ?? this.id,
      pastLifeStatus: pastLifeStatus ?? this.pastLifeStatus,
      pastLifeStatusEn: pastLifeStatusEn ?? this.pastLifeStatusEn,
      pastLifeGender: pastLifeGender ?? this.pastLifeGender,
      pastLifeEra: pastLifeEra ?? this.pastLifeEra,
      pastLifeName: pastLifeName ?? this.pastLifeName,
      story: story ?? this.story,
      summary: summary ?? this.summary,
      portraitUrl: portraitUrl ?? this.portraitUrl,
      advice: advice ?? this.advice,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      isBlurred: isBlurred ?? this.isBlurred,
      blurredSections: blurredSections ?? this.blurredSections,
    );
  }

  @override
  String toString() {
    return 'PastLifeResult(id: $id, status: $pastLifeStatus, name: $pastLifeName, era: $pastLifeEra)';
  }
}
