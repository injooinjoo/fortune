import '../fortune_conditions.dart';

/// 연애운 조건 모델
///
/// 4단계 입력 데이터를 담는 조건 객체
/// - Step 1: 기본 정보 (나이, 성별, 연애 상태)
/// - Step 2: 연애 스타일 (데이팅 스타일, 가치관 중요도)
/// - Step 3: 이상형 (선호 나이대, 성격, 만남 장소, 관계 목표)
/// - Step 4: 나의 매력 (외모 자신감, 매력 포인트, 라이프스타일, 취미)
class LoveFortuneConditions extends FortuneConditions {
  // Step 1: 기본 정보
  final int age;
  final String gender;
  final String relationshipStatus;

  // Step 2: 연애 스타일
  final List<String> datingStyles;
  final Map<String, int> valueImportance;

  // Step 3: 이상형
  final Map<String, int> preferredAgeRange; // {min: 20, max: 30}
  final List<String> preferredPersonality;
  final List<String> preferredMeetingPlaces;
  final String relationshipGoal;

  // Step 4: 나의 매력
  final double appearanceConfidence;
  final List<String> charmPoints;
  final String lifestyle;
  final List<String> hobbies;

  LoveFortuneConditions({
    required this.age,
    required this.gender,
    required this.relationshipStatus,
    required this.datingStyles,
    required this.valueImportance,
    required this.preferredAgeRange,
    required this.preferredPersonality,
    required this.preferredMeetingPlaces,
    required this.relationshipGoal,
    required this.appearanceConfidence,
    required this.charmPoints,
    required this.lifestyle,
    required this.hobbies,
  });

  @override
  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'relationshipStatus': relationshipStatus,
        'datingStyles': datingStyles,
        'valueImportance': valueImportance,
        'preferredAgeRange': preferredAgeRange,
        'preferredPersonality': preferredPersonality,
        'preferredMeetingPlaces': preferredMeetingPlaces,
        'relationshipGoal': relationshipGoal,
        'appearanceConfidence': appearanceConfidence,
        'charmPoints': charmPoints,
        'lifestyle': lifestyle,
        'hobbies': hobbies,
      };

  factory LoveFortuneConditions.fromJson(Map<String, dynamic> json) {
    return LoveFortuneConditions(
      age: json['age'] as int,
      gender: json['gender'] as String,
      relationshipStatus: json['relationshipStatus'] as String,
      datingStyles: List<String>.from(json['datingStyles'] ?? []),
      valueImportance: Map<String, int>.from(json['valueImportance'] ?? {}),
      preferredAgeRange: Map<String, int>.from(json['preferredAgeRange'] ?? {'min': 20, 'max': 30}),
      preferredPersonality: List<String>.from(json['preferredPersonality'] ?? []),
      preferredMeetingPlaces: List<String>.from(json['preferredMeetingPlaces'] ?? []),
      relationshipGoal: json['relationshipGoal'] as String? ?? 'casual',
      appearanceConfidence: (json['appearanceConfidence'] as num?)?.toDouble() ?? 5.0,
      charmPoints: List<String>.from(json['charmPoints'] ?? []),
      lifestyle: json['lifestyle'] as String? ?? 'employee',
      hobbies: List<String>.from(json['hobbies'] ?? []),
    );
  }

  /// `Map<String, dynamic>`에서 생성 (기존 입력 데이터 호환)
  ///
  /// love_fortune_main_page의 _loveFortuneData를 변환할 때 사용
  factory LoveFortuneConditions.fromInputData(Map<String, dynamic> data) {
    // valueImportance의 double 값을 int로 변환
    final Map<String, int> convertedValueImportance = {};
    final rawValueImportance = data['valueImportance'] as Map<String, dynamic>? ?? {};
    rawValueImportance.forEach((key, value) {
      convertedValueImportance[key] = (value as num).round();
    });

    // preferredAgeRange 변환 (이미 int일 수도 있음)
    final rawAgeRange = data['preferredAgeRange'] as Map<String, dynamic>? ?? {'min': 20, 'max': 30};
    final Map<String, int> convertedAgeRange = {
      'min': (rawAgeRange['min'] as num).toInt(),
      'max': (rawAgeRange['max'] as num).toInt(),
    };

    return LoveFortuneConditions(
      age: data['age'] as int? ?? 25,
      gender: data['gender'] as String? ?? 'male',
      relationshipStatus: data['relationshipStatus'] as String? ?? 'single',
      datingStyles: List<String>.from(data['datingStyles'] ?? []),
      valueImportance: convertedValueImportance,
      preferredAgeRange: convertedAgeRange,
      preferredPersonality: List<String>.from(data['preferredPersonality'] ?? []),
      preferredMeetingPlaces: List<String>.from(data['preferredMeetingPlaces'] ?? []),
      relationshipGoal: data['relationshipGoal'] as String? ?? 'casual',
      appearanceConfidence: (data['appearanceConfidence'] as num?)?.toDouble() ?? 5.0,
      charmPoints: List<String>.from(data['charmPoints'] ?? []),
      lifestyle: data['lifestyle'] as String? ?? 'employee',
      hobbies: List<String>.from(data['hobbies'] ?? []),
    );
  }

  @override
  String generateHash() {
    final parts = <String>[
      'age:$age',
      'gender:$gender',
      'status:$relationshipStatus',
      'styles:${datingStyles.join(",")}',
      'values:${valueImportance.entries.map((e) => "${e.key}:${e.value}").join(",")}',
      'ageRange:${preferredAgeRange['min']}-${preferredAgeRange['max']}',
      'personality:${preferredPersonality.join(",")}',
      'places:${preferredMeetingPlaces.join(",")}',
      'goal:$relationshipGoal',
      'confidence:${appearanceConfidence.round()}',
      'charm:${charmPoints.join(",")}',
      'lifestyle:$lifestyle',
      'hobbies:${hobbies.join(",")}',
    ];
    return parts.join('|');
  }

  @override
  Map<String, dynamic> toIndexableFields() {
    return {
      'age': age,
      'gender': gender,
      'relationshipStatus': relationshipStatus,
      'datingStyles': datingStyles,
      'preferredAgeRange': preferredAgeRange,
      'preferredPersonality': preferredPersonality,
      'preferredMeetingPlaces': preferredMeetingPlaces,
      'relationshipGoal': relationshipGoal,
      'lifestyle': lifestyle,
      'hobbies': hobbies,
      // valueImportance, appearanceConfidence, charmPoints는 개인정보이므로 제외
    };
  }

  @override
  Map<String, dynamic> buildAPIPayload() {
    return {
      'age': age,
      'gender': gender,
      'relationshipStatus': relationshipStatus,
      'datingStyles': datingStyles,
      'valueImportance': valueImportance,
      'preferredAgeRange': preferredAgeRange,
      'preferredPersonality': preferredPersonality,
      'preferredMeetingPlaces': preferredMeetingPlaces,
      'relationshipGoal': relationshipGoal,
      'appearanceConfidence': appearanceConfidence,
      'charmPoints': charmPoints,
      'lifestyle': lifestyle,
      'hobbies': hobbies,
    };
  }

  @override
  String toString() {
    return 'LoveFortuneConditions(age: $age, gender: $gender, status: $relationshipStatus)';
  }
}
