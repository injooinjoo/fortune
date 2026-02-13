// 2026 올해의 인연 결과 모델
//
// 미래 애인 얼굴 이미지와 만남 예측 정보를 담습니다.
class YearlyEncounterResult {
  /// 생성된 이미지 URL
  final String imageUrl;

  /// 외모 해시태그 (3개)
  final List<String> appearanceHashtags;

  /// 첫 만남 장소 제목 (짧은 버전)
  final String encounterSpotTitle;

  /// 첫 만남 장소 스토리 (상세 버전)
  final String encounterSpotStory;

  /// 인연의 시그널 제목 (짧은 버전)
  final String fateSignalTitle;

  /// 인연의 시그널 스토리 (상세 버전)
  final String fateSignalStory;

  /// 성격/특징 제목 (짧은 버전)
  final String personalityTitle;

  /// 성격/특징 스토리 (상세 버전)
  final String personalityStory;

  /// 비주얼 궁합 점수 (예: "89%")
  final String compatibilityScore;

  /// 궁합 점수 설명
  final String compatibilityDescription;

  /// 생성된 인연의 성별
  final String targetGender;

  /// 생성 시간
  final DateTime createdAt;

  const YearlyEncounterResult({
    required this.imageUrl,
    required this.appearanceHashtags,
    required this.encounterSpotTitle,
    required this.encounterSpotStory,
    required this.fateSignalTitle,
    required this.fateSignalStory,
    required this.personalityTitle,
    required this.personalityStory,
    required this.compatibilityScore,
    required this.compatibilityDescription,
    required this.targetGender,
    required this.createdAt,
  });

  /// 운세 타입 식별자
  String get fortuneType => 'yearlyEncounter';

  /// 성별 한글 표시
  String get targetGenderKo => targetGender == 'male' ? '남성' : '여성';

  /// 해시태그 문자열 (공백으로 구분)
  String get hashtagsString => appearanceHashtags.join(' ');

  /// 하위호환: 기존 encounterSpot 필드 (스토리 반환)
  String get encounterSpot => encounterSpotStory;

  /// 하위호환: 기존 fateSignal 필드 (스토리 반환)
  String get fateSignal => fateSignalStory;

  /// 하위호환: 기존 personality 필드 (스토리 반환)
  String get personality => personalityStory;

  /// JSON에서 생성
  factory YearlyEncounterResult.fromJson(Map<String, dynamic> json) {
    // appearanceHashtags 파싱
    List<String> parsedHashtags = [];
    if (json['appearanceHashtags'] != null) {
      parsedHashtags = List<String>.from(json['appearanceHashtags']);
    } else if (json['appearance_hashtags'] != null) {
      parsedHashtags = List<String>.from(json['appearance_hashtags']);
    }

    // 새 필드 또는 하위호환 필드 파싱
    final encounterSpotTitle =
        json['encounterSpotTitle'] ?? json['encounter_spot_title'] ?? '첫 만남';
    final encounterSpotStory = json['encounterSpotStory'] ??
        json['encounter_spot_story'] ??
        json['encounterSpot'] ??
        json['encounter_spot'] ??
        '';

    final fateSignalTitle =
        json['fateSignalTitle'] ?? json['fate_signal_title'] ?? '인연의 시그널';
    final fateSignalStory = json['fateSignalStory'] ??
        json['fate_signal_story'] ??
        json['fateSignal'] ??
        json['fate_signal'] ??
        '';

    final personalityTitle =
        json['personalityTitle'] ?? json['personality_title'] ?? '성격/특징';
    final personalityStory = json['personalityStory'] ??
        json['personality_story'] ??
        json['personality'] ??
        '';

    return YearlyEncounterResult(
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      appearanceHashtags: parsedHashtags,
      encounterSpotTitle: encounterSpotTitle,
      encounterSpotStory: encounterSpotStory,
      fateSignalTitle: fateSignalTitle,
      fateSignalStory: fateSignalStory,
      personalityTitle: personalityTitle,
      personalityStory: personalityStory,
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
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'appearanceHashtags': appearanceHashtags,
        'encounterSpotTitle': encounterSpotTitle,
        'encounterSpotStory': encounterSpotStory,
        'fateSignalTitle': fateSignalTitle,
        'fateSignalStory': fateSignalStory,
        'personalityTitle': personalityTitle,
        'personalityStory': personalityStory,
        'compatibilityScore': compatibilityScore,
        'compatibilityDescription': compatibilityDescription,
        'targetGender': targetGender,
        'createdAt': createdAt.toIso8601String(),
      };

  /// copyWith 메서드
  YearlyEncounterResult copyWith({
    String? imageUrl,
    List<String>? appearanceHashtags,
    String? encounterSpotTitle,
    String? encounterSpotStory,
    String? fateSignalTitle,
    String? fateSignalStory,
    String? personalityTitle,
    String? personalityStory,
    String? compatibilityScore,
    String? compatibilityDescription,
    String? targetGender,
    DateTime? createdAt,
  }) {
    return YearlyEncounterResult(
      imageUrl: imageUrl ?? this.imageUrl,
      appearanceHashtags: appearanceHashtags ?? this.appearanceHashtags,
      encounterSpotTitle: encounterSpotTitle ?? this.encounterSpotTitle,
      encounterSpotStory: encounterSpotStory ?? this.encounterSpotStory,
      fateSignalTitle: fateSignalTitle ?? this.fateSignalTitle,
      fateSignalStory: fateSignalStory ?? this.fateSignalStory,
      personalityTitle: personalityTitle ?? this.personalityTitle,
      personalityStory: personalityStory ?? this.personalityStory,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      compatibilityDescription:
          compatibilityDescription ?? this.compatibilityDescription,
      targetGender: targetGender ?? this.targetGender,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'YearlyEncounterResult(targetGender: $targetGender, score: $compatibilityScore)';
  }
}
