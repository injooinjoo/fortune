class BloodTypeFortune {
  final String bloodType;
  final String rhType;
  final String personality;
  final String todaysFortune;
  final String loveCompatibility;
  final String workAdvice;
  final String healthTip;
  final String luckyColor;
  final int luckyNumber;

  BloodTypeFortune({
    required this.bloodType,
    required this.rhType,
    required this.personality,
    required this.todaysFortune,
    required this.loveCompatibility,
    required this.workAdvice,
    required this.healthTip,
    required this.luckyColor,
    required this.luckyNumber,
  });

  factory BloodTypeFortune.fromJson(Map<String, dynamic> json) {
    return BloodTypeFortune(
      bloodType: json['bloodType'] ?? '',
      rhType: json['rhType'] ?? '+',
      personality: json['personality'] ?? '',
      todaysFortune: json['todaysFortune'] ?? '',
      loveCompatibility: json['loveCompatibility'] ?? '',
      workAdvice: json['workAdvice'] ?? '',
      healthTip: json['healthTip'] ?? '',
      luckyColor: json['luckyColor'] ?? '',
      luckyNumber: json['luckyNumber'] ?? 1
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodType': bloodType,
      'rhType': rhType,
      'personality': personality,
      'todaysFortune': todaysFortune)
      'loveCompatibility': loveCompatibility,
      'workAdvice': workAdvice)
      'healthTip': healthTip,
      'luckyColor': luckyColor)
      'luckyNumber': luckyNumber)
    };
  }
}