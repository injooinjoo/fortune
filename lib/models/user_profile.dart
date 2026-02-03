import 'package:equatable/equatable.dart';
import '../constants/fortune_constants.dart';
import '../features/chat/domain/models/life_category.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime? birthDate;
  final String? birthTime;
  final String? birthHour;
  final String? mbti;
  final Gender gender;
  final String? bloodType;
  final String? zodiacSign;
  final String? chineseZodiac;
  final bool onboardingCompleted;
  final SubscriptionStatus subscriptionStatus;
  final int fortuneCount;
  final int premiumFortunesCount;
  final int tokenBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isLunarBirthdate;
  final String? profileImageUrl;
  final List<String>? linkedProviders;
  final String? primaryProvider;
  final bool isTestAccount;
  final Map<String, dynamic>? testAccountFeatures;
  final FortunePreferences? fortunePreferences;

  /// 인생 컨설팅 대분류 카테고리
  final LifeCategory? primaryLifeCategory;

  /// 세부 고민 ID
  final String? subConcern;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.birthDate,
    this.birthTime,
    this.birthHour,
    this.mbti,
    this.gender = Gender.other,
    this.bloodType,
    this.zodiacSign,
    this.chineseZodiac,
    required this.onboardingCompleted,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.fortuneCount = 0,
    this.premiumFortunesCount = 0,
    this.tokenBalance = 0,
    this.createdAt,
    this.updatedAt,
    this.isLunarBirthdate,
    this.profileImageUrl,
    this.linkedProviders,
    this.primaryProvider,
    this.isTestAccount = false,
    this.testAccountFeatures,
    this.fortunePreferences,
    this.primaryLifeCategory,
    this.subConcern,
  });

  // Alias for backward compatibility with data model
  String get userId => id;
  String? get mbtiType => mbti;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        birthDate,
        birthTime,
        birthHour,
        mbti,
        gender,
        bloodType,
        zodiacSign,
        chineseZodiac,
        onboardingCompleted,
        subscriptionStatus,
        fortuneCount,
        premiumFortunesCount,
        tokenBalance,
        createdAt,
        updatedAt,
        isLunarBirthdate,
        profileImageUrl,
        linkedProviders,
        primaryProvider,
        isTestAccount,
        testAccountFeatures,
        fortunePreferences,
        primaryLifeCategory,
        subConcern,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birth_date': birthDate?.toIso8601String(),
      'birth_time': birthTime,
      'birth_hour': birthHour,
      'mbti': mbti,
      'gender': gender.value,
      'blood_type': bloodType,
      'zodiac_sign': zodiacSign,
      'chinese_zodiac': chineseZodiac,
      'onboarding_completed': onboardingCompleted,
      'subscription_status': subscriptionStatus.value,
      'fortune_count': fortuneCount,
      'premium_fortunes_count': premiumFortunesCount,
      'token_balance': tokenBalance,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_lunar_birthdate': isLunarBirthdate,
      'profile_image_url': profileImageUrl,
      'linked_providers': linkedProviders,
      'primary_provider': primaryProvider,
      'is_test_account': isTestAccount,
      'test_account_features': testAccountFeatures,
      'fortune_preferences': fortunePreferences?.toJson(),
      'primary_life_category': primaryLifeCategory?.value,
      'sub_concern': subConcern,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Handle both 'mbti_type' and 'mbti' keys
    final mbtiValue = json['mbti'] as String? ?? json['mbti_type'] as String?;

    // Handle 'id' and 'user_id'
    final idValue = json['id'] as String? ?? json['user_id'] as String? ?? '';

    return UserProfile(
      id: idValue,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'].toString())
          : null,
      birthTime: json['birth_time'],
      birthHour: json['birth_hour'],
      mbti: mbtiValue,
      gender: json['gender'] is String
          ? Gender.values.firstWhere((g) => g.value == json['gender'],
              orElse: () => Gender.other)
          : Gender.other,
      bloodType: json['blood_type'],
      zodiacSign: json['zodiac_sign'],
      chineseZodiac: json['chinese_zodiac'],
      onboardingCompleted: json['onboarding_completed'] ?? false,
      subscriptionStatus:
          SubscriptionStatus.fromString(json['subscription_status'] ?? 'free'),
      fortuneCount: json['fortune_count'] ?? 0,
      premiumFortunesCount: json['premium_fortunes_count'] ?? 0,
      tokenBalance: json['token_balance'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      isLunarBirthdate: json['is_lunar_birthdate'],
      profileImageUrl: json['profile_image_url'],
      linkedProviders: json['linked_providers'] != null
          ? List<String>.from(json['linked_providers'])
          : null,
      primaryProvider: json['primary_provider'],
      isTestAccount: json['is_test_account'] ?? false,
      testAccountFeatures: json['test_account_features'],
      fortunePreferences: json['fortune_preferences'] != null
          ? FortunePreferences.fromJson(json['fortune_preferences'])
          : null,
      primaryLifeCategory:
          LifeCategory.fromValue(json['primary_life_category'] as String?),
      subConcern: json['sub_concern'] as String?,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? birthDate,
    String? birthTime,
    String? birthHour,
    String? mbti,
    Gender? gender,
    String? bloodType,
    String? zodiacSign,
    String? chineseZodiac,
    bool? onboardingCompleted,
    SubscriptionStatus? subscriptionStatus,
    int? fortuneCount,
    int? premiumFortunesCount,
    int? tokenBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLunarBirthdate,
    String? profileImageUrl,
    List<String>? linkedProviders,
    String? primaryProvider,
    bool? isTestAccount,
    Map<String, dynamic>? testAccountFeatures,
    FortunePreferences? fortunePreferences,
    LifeCategory? primaryLifeCategory,
    String? subConcern,
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
      bloodType: bloodType ?? this.bloodType,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      chineseZodiac: chineseZodiac ?? this.chineseZodiac,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      fortuneCount: fortuneCount ?? this.fortuneCount,
      premiumFortunesCount: premiumFortunesCount ?? this.premiumFortunesCount,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLunarBirthdate: isLunarBirthdate ?? this.isLunarBirthdate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      linkedProviders: linkedProviders ?? this.linkedProviders,
      primaryProvider: primaryProvider ?? this.primaryProvider,
      isTestAccount: isTestAccount ?? this.isTestAccount,
      testAccountFeatures: testAccountFeatures ?? this.testAccountFeatures,
      fortunePreferences: fortunePreferences ?? this.fortunePreferences,
      primaryLifeCategory: primaryLifeCategory ?? this.primaryLifeCategory,
      subConcern: subConcern ?? this.subConcern,
    );
  }

  /// 프리미엄 활성 상태 확인
  ///
  /// 주의: 실제 구독 상태는 subscriptionProvider를 통해 확인해야 합니다.
  /// 이 getter는 테스트 계정의 premium_enabled 상태만 확인합니다.
  /// 일반 사용자의 구독 상태는 subscription-status API를 통해 확인됩니다.
  bool get isPremiumActive {
    // 테스트 계정은 testAccountFeatures에서 premium_enabled 확인
    if (isTestAccount && testAccountFeatures != null) {
      return testAccountFeatures!['premium_enabled'] == true;
    }
    // 일반 사용자는 subscriptionProvider를 통해 확인해야 함
    // subscriptionStatus는 DB와 동기화 문제로 신뢰할 수 없음
    return false;
  }

  bool get hasUnlimitedTokens =>
      isTestAccount && testAccountFeatures?['unlimited_tokens'] == true;
}

class FortunePreferences extends Equatable {
  final Map<String, double> categoryWeights;
  final Map<String, int> visitedFortunes;
  final Map<String, DateTime> lastVisited;
  final List<String> favorites;
  final List<String> excluded;
  final int? preferredHour;
  final String languagePreference;
  final bool showTrending;
  final bool showPersonalized;

  const FortunePreferences({
    this.categoryWeights = const {},
    this.visitedFortunes = const {},
    this.lastVisited = const {},
    this.favorites = const [],
    this.excluded = const [],
    this.preferredHour,
    this.languagePreference = 'ko',
    this.showTrending = true,
    this.showPersonalized = true,
  });

  factory FortunePreferences.fromJson(Map<String, dynamic> json) {
    return FortunePreferences(
      categoryWeights: (json['category_weights'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      visitedFortunes: (json['visited_fortunes'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      lastVisited: (json['last_visited'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, DateTime.parse(v as String))) ??
          {},
      favorites: (json['favorites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      excluded: (json['excluded'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferredHour: json['preferred_hour'],
      languagePreference: json['language_preference'] as String? ?? 'ko',
      showTrending: json['show_trending'] as bool? ?? true,
      showPersonalized: json['show_personalized'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_weights': categoryWeights,
      'visited_fortunes': visitedFortunes,
      'last_visited':
          lastVisited.map((k, v) => MapEntry(k, v.toIso8601String())),
      'favorites': favorites,
      'excluded': excluded,
      'preferred_hour': preferredHour,
      'language_preference': languagePreference,
      'show_trending': showTrending,
      'show_personalized': showPersonalized,
    };
  }

  @override
  List<Object?> get props => [
        categoryWeights,
        visitedFortunes,
        lastVisited,
        favorites,
        excluded,
        preferredHour,
        languagePreference,
        showTrending,
        showPersonalized
      ];

  FortunePreferences copyWith({
    Map<String, double>? categoryWeights,
    Map<String, int>? visitedFortunes,
    Map<String, DateTime>? lastVisited,
    List<String>? favorites,
    List<String>? excluded,
    int? preferredHour,
    String? languagePreference,
    bool? showTrending,
    bool? showPersonalized,
  }) {
    return FortunePreferences(
      categoryWeights: categoryWeights ?? this.categoryWeights,
      visitedFortunes: visitedFortunes ?? this.visitedFortunes,
      lastVisited: lastVisited ?? this.lastVisited,
      favorites: favorites ?? this.favorites,
      excluded: excluded ?? this.excluded,
      preferredHour: preferredHour ?? this.preferredHour,
      languagePreference: languagePreference ?? this.languagePreference,
      showTrending: showTrending ?? this.showTrending,
      showPersonalized: showPersonalized ?? this.showPersonalized,
    );
  }

  /// Update visit information for a fortune type
  FortunePreferences recordVisit(String fortuneType, String category) {
    final newVisitedFortunes = Map<String, int>.from(visitedFortunes);
    newVisitedFortunes[fortuneType] =
        (newVisitedFortunes[fortuneType] ?? 0) + 1;

    final newLastVisited = Map<String, DateTime>.from(lastVisited);
    newLastVisited[fortuneType] = DateTime.now();

    // Update category weights based on visit patterns
    final newCategoryWeights = Map<String, double>.from(categoryWeights);
    final currentWeight = newCategoryWeights[category] ?? 0.5;
    // Slightly increase weight for visited category (max 1.0)
    newCategoryWeights[category] = (currentWeight + 0.05).clamp(0.0, 1.0);

    return copyWith(
      visitedFortunes: newVisitedFortunes,
      lastVisited: newLastVisited,
      categoryWeights: newCategoryWeights,
    );
  }

  /// Get personalization score for a fortune type
  double getPersonalizationScore(String fortuneType, String category) {
    double score = 0.5; // Base score

    // Category preference weight (0-0.3)
    final categoryWeight = categoryWeights[category] ?? 0.5;
    score += categoryWeight * 0.3;

    // Visit frequency score (0-0.2)
    final visitCount = visitedFortunes[fortuneType] ?? 0;
    if (visitCount > 0) {
      score += (visitCount / 10.0).clamp(0.0, 0.2);
    }

    // Recency score (0-0.2)
    final lastVisit = lastVisited[fortuneType];
    if (lastVisit != null) {
      final daysSinceVisit = DateTime.now().difference(lastVisit).inDays;
      if (daysSinceVisit > 7) {
        // Boost score if haven't visited in a while
        score += 0.2;
      } else if (daysSinceVisit < 1) {
        // Reduce score if visited very recently
        score -= 0.1;
      }
    } else {
      // Never visited - slight boost for discovery
      score += 0.1;
    }

    // Favorites boost (0.3)
    if (favorites.contains(fortuneType)) {
      score += 0.3;
    }

    // Excluded penalty
    if (excluded.contains(fortuneType)) {
      score = 0.0;
    }

    return score.clamp(0.0, 1.0);
  }
}
