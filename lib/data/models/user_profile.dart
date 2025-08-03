import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? birthTime;
  final String? gender;
  final String? mbtiType;
  final String? zodiacSign;
  final String? chineseZodiac;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;
  final int tokenBalance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isTestAccount;
  final Map<String, dynamic>? testAccountFeatures;
  final FortunePreferences? fortunePreferences;

  const UserProfile({
    required this.id,
    required this.userId,
    this.name,
    this.email,
    this.phoneNumber,
    this.birthDate,
    this.birthTime,
    this.gender,
    this.mbtiType,
    this.zodiacSign,
    this.chineseZodiac,
    this.profileImageUrl,
    this.preferences,
    this.tokenBalance = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isTestAccount = false,
    this.testAccountFeatures,
    this.fortunePreferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      birthTime: json['birth_time'],
      gender: json['gender'],
      mbtiType: json['mbti_type'],
      zodiacSign: json['zodiac_sign'],
      chineseZodiac: json['chinese_zodiac'],
      profileImageUrl: json['profile_image_url'],
      preferences: json['preferences'],
      tokenBalance: json['token_balance'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      isTestAccount: json['is_test_account'],
      testAccountFeatures: json['test_account_features'],
      fortunePreferences: json['fortune_preferences'] != null
          ? FortunePreferences.fromJson(json['fortune_preferences'] as Map<String, dynamic>)
          : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'birth_date': birthDate?.toIso8601String(),
      'birth_time': birthTime,
      'gender': gender,
      'mbti_type': mbtiType,
      'zodiac_sign': zodiacSign,
      'chinese_zodiac': chineseZodiac,
      'profile_image_url': profileImageUrl,
      'preferences': preferences,
      'token_balance': tokenBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_test_account': isTestAccount,
      'test_account_features': testAccountFeatures,
      'fortune_preferences': null,
    };
  }

  // Check if user has premium access
  bool get isPremiumActive {
    // Test accounts can toggle premium
    if (isTestAccount && testAccountFeatures != null) {
      return testAccountFeatures!['premium_enabled'] == true;
    }
    // Regular users would check subscription status here
    return false;
  }
  
  // Check if user has unlimited tokens (test accounts only)
  bool get hasUnlimitedTokens => isTestAccount && testAccountFeatures?['unlimited_tokens'] == true;

  UserProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? birthTime,
    String? gender,
    String? mbtiType,
    String? zodiacSign,
    String? chineseZodiac,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    int? tokenBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isTestAccount,
    Map<String, dynamic>? testAccountFeatures,
    FortunePreferences? fortunePreferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      gender: gender ?? this.gender,
      mbtiType: mbtiType ?? this.mbtiType,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      chineseZodiac: chineseZodiac ?? this.chineseZodiac,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isTestAccount: isTestAccount ?? this.isTestAccount,
      testAccountFeatures: testAccountFeatures ?? this.testAccountFeatures,
      fortunePreferences: fortunePreferences ?? this.fortunePreferences,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    email,
    phoneNumber,
    birthDate,
    birthTime,
    gender,
    mbtiType,
    zodiacSign,
    chineseZodiac,
    profileImageUrl,
    preferences,
    tokenBalance,
    createdAt,
    updatedAt,
    isTestAccount,
    testAccountFeatures,
    fortunePreferences,
  ];
}

/// User's fortune preferences for personalized recommendations
class FortunePreferences extends Equatable {
  /// Category preference weights (0.0 - 1.0)
  /// e.g., {'love': 0.8, 'career': 0.6, 'money': 0.4}
  final Map<String, double> categoryWeights;
  
  /// Visit count per fortune type
  /// e.g., {'love': 5, 'career': 3, 'tarot': 10}
  final Map<String, int> visitedFortunes;
  
  /// Last visit timestamp per fortune type
  /// e.g., {'love': '2024-01-15': 'career': '2024-01-10'}
  final Map<String, DateTime> lastVisited;
  
  /// Favorite fortune types (manually marked by user)
  final List<String> favorites;
  
  /// Fortune types to exclude from recommendations
  final List<String> excluded;
  
  /// Preferred time of day for fortune checking (0-23)
  final int? preferredHour;
  
  /// Language preference for fortunes
  final String languagePreference;
  
  /// Whether to show trending fortunes
  final bool showTrending;
  
  /// Whether to show personalized recommendations
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
      lastVisited: (json['last_visited'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, DateTime.parse(v as String)),
          ) ??
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
      showTrending: json['show_trending'],
      showPersonalized: json['show_personalized'] as bool? ?? true
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_weights': categoryWeights,
      'visited_fortunes': visitedFortunes,
      'last_visited': lastVisited.map((k, v) => MapEntry(k, v.toIso8601String())),
      'favorites': favorites,
      'excluded': excluded,
      'preferred_hour': preferredHour,
      'language_preference': languagePreference,
      'show_trending': showTrending,
      'show_personalized': null,
    };
  }

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
    newVisitedFortunes[fortuneType] = (newVisitedFortunes[fortuneType] ?? 0) + 1;
    
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
      categoryWeights: newCategoryWeights
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
        showPersonalized,
      ];
}