import '../constants/fortune_constants.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String birthDate;
  final String? birthTime;
  final String? birthHour;
  final String? mbti;
  final Gender gender;
  final String? zodiacSign;
  final String? chineseZodiac;
  final bool onboardingCompleted;
  final SubscriptionStatus subscriptionStatus;
  final int fortuneCount;
  final int premiumFortunesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isLunarBirthdate;
  final String? profileImageUrl;
  final List<String>? linkedProviders;
  final String? primaryProvider;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.birthDate,
    this.birthTime,
    this.birthHour,
    this.mbti,
    this.gender = Gender.other,
    this.zodiacSign,
    this.chineseZodiac,
    required this.onboardingCompleted,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.fortuneCount = 0,
    this.premiumFortunesCount = 0,
    this.createdAt,
    this.updatedAt,
    this.isLunarBirthdate,
    this.profileImageUrl,
    this.linkedProviders,
    this.primaryProvider,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'birth_hour': birthHour,
      'mbti': mbti,
      'gender': gender.value,
      'zodiac_sign': zodiacSign,
      'chinese_zodiac': chineseZodiac,
      'onboarding_completed': onboardingCompleted,
      'subscription_status': subscriptionStatus.value,
      'fortune_count': fortuneCount,
      'premium_fortunes_count': premiumFortunesCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_lunar_birthdate': isLunarBirthdate,
      'profile_image_url': profileImageUrl,
      'linked_providers': linkedProviders,
      'primary_provider': primaryProvider,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthDate: json['birth_date'] ?? '',
      birthTime: json['birth_time'],
      birthHour: json['birth_hour'],
      mbti: json['mbti'],
      gender: Gender.values.firstWhere(
        (g) => g.value == json['gender'],
        orElse: () => Gender.other,
      ),
      zodiacSign: json['zodiac_sign'],
      chineseZodiac: json['chinese_zodiac'],
      onboardingCompleted: json['onboarding_completed'] ?? false,
      subscriptionStatus: SubscriptionStatus.fromString(
        json['subscription_status'] ?? 'free',
      ),
      fortuneCount: json['fortune_count'] ?? 0,
      premiumFortunesCount: json['premium_fortunes_count'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      isLunarBirthdate: json['is_lunar_birthdate'],
      profileImageUrl: json['profile_image_url'],
      linkedProviders: json['linked_providers'] != null 
          ? List<String>.from(json['linked_providers']) 
          : null,
      primaryProvider: json['primary_provider'],
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? birthDate,
    String? birthTime,
    String? birthHour,
    String? mbti,
    Gender? gender,
    String? zodiacSign,
    String? chineseZodiac,
    bool? onboardingCompleted,
    SubscriptionStatus? subscriptionStatus,
    int? fortuneCount,
    int? premiumFortunesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLunarBirthdate,
    String? profileImageUrl,
    List<String>? linkedProviders,
    String? primaryProvider,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthHour: birthHour ?? this.birthHour,
      mbti: mbti ?? this.mbti,
      gender: gender ?? this.gender,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      chineseZodiac: chineseZodiac ?? this.chineseZodiac,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      fortuneCount: fortuneCount ?? this.fortuneCount,
      premiumFortunesCount: premiumFortunesCount ?? this.premiumFortunesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLunarBirthdate: isLunarBirthdate ?? this.isLunarBirthdate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      linkedProviders: linkedProviders ?? this.linkedProviders,
      primaryProvider: primaryProvider ?? this.primaryProvider,
    );
  }

  // Helper getter to convert birthDate string to DateTime
  DateTime? get birthDateAsDateTime {
    try {
      return DateTime.parse(birthDate);
    } catch (e) {
      return null;
    }
  }
}