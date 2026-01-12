/// 2026 올해의 인연 결과 모델
///
/// 미래 애인 얼굴 이미지와 만남 예측 정보를 담습니다.
class YearlyEncounterResult {
  /// 생성된 이미지 URL
  final String imageUrl;

  /// 외모 해시태그 (3개)
  final List<String> appearanceHashtags;

  /// 첫 만남 장소와 시간
  final String encounterSpot;

  /// 인연의 시그널
  final String fateSignal;

  /// 성격/특징
  final String personality;

  /// 비주얼 궁합 점수 (예: "89%")
  final String compatibilityScore;

  /// 궁합 점수 설명
  final String compatibilityDescription;

  /// 생성된 인연의 성별
  final String targetGender;

  /// 생성 시간
  final DateTime createdAt;

  /// 블러 상태 (프리미엄 미구매 시 true)
  final bool isBlurred;

  /// 블러 처리된 섹션 목록
  final List<String> blurredSections;

  const YearlyEncounterResult({
    required this.imageUrl,
    required this.appearanceHashtags,
    required this.encounterSpot,
    required this.fateSignal,
    required this.personality,
    required this.compatibilityScore,
    required this.compatibilityDescription,
    required this.targetGender,
    required this.createdAt,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

  /// 운세 타입 식별자
  String get fortuneType => 'yearlyEncounter';

  /// 성별 한글 표시
  String get targetGenderKo => targetGender == 'male' ? '남성' : '여성';

  /// 해시태그 문자열 (공백으로 구분)
  String get hashtagsString => appearanceHashtags.join(' ');

  /// JSON에서 생성
  factory YearlyEncounterResult.fromJson(Map<String, dynamic> json) {
    // appearanceHashtags 파싱
    List<String> parsedHashtags = [];
    if (json['appearanceHashtags'] != null) {
      parsedHashtags = List<String>.from(json['appearanceHashtags']);
    } else if (json['appearance_hashtags'] != null) {
      parsedHashtags = List<String>.from(json['appearance_hashtags']);
    }

    return YearlyEncounterResult(
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      appearanceHashtags: parsedHashtags,
      encounterSpot: json['encounterSpot'] ?? json['encounter_spot'] ?? '',
      fateSignal: json['fateSignal'] ?? json['fate_signal'] ?? '',
      personality: json['personality'] ?? '',
      compatibilityScore:
          json['compatibilityScore'] ?? json['compatibility_score'] ?? '85%',
      compatibilityDescription: json['compatibilityDescription'] ??
          json['compatibility_description'] ??
          '',
      targetGender: json['targetGender'] ?? json['target_gender'] ?? 'male',
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
        'imageUrl': imageUrl,
        'appearanceHashtags': appearanceHashtags,
        'encounterSpot': encounterSpot,
        'fateSignal': fateSignal,
        'personality': personality,
        'compatibilityScore': compatibilityScore,
        'compatibilityDescription': compatibilityDescription,
        'targetGender': targetGender,
        'createdAt': createdAt.toIso8601String(),
        'isBlurred': isBlurred,
        'blurredSections': blurredSections,
      };

  /// copyWith 메서드
  YearlyEncounterResult copyWith({
    String? imageUrl,
    List<String>? appearanceHashtags,
    String? encounterSpot,
    String? fateSignal,
    String? personality,
    String? compatibilityScore,
    String? compatibilityDescription,
    String? targetGender,
    DateTime? createdAt,
    bool? isBlurred,
    List<String>? blurredSections,
  }) {
    return YearlyEncounterResult(
      imageUrl: imageUrl ?? this.imageUrl,
      appearanceHashtags: appearanceHashtags ?? this.appearanceHashtags,
      encounterSpot: encounterSpot ?? this.encounterSpot,
      fateSignal: fateSignal ?? this.fateSignal,
      personality: personality ?? this.personality,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      compatibilityDescription:
          compatibilityDescription ?? this.compatibilityDescription,
      targetGender: targetGender ?? this.targetGender,
      createdAt: createdAt ?? this.createdAt,
      isBlurred: isBlurred ?? this.isBlurred,
      blurredSections: blurredSections ?? this.blurredSections,
    );
  }

  @override
  String toString() {
    return 'YearlyEncounterResult(targetGender: $targetGender, score: $compatibilityScore)';
  }
}
