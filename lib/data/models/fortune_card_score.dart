import 'package:equatable/equatable.dart';

/// Model for fortune card scoring and recommendation
class FortuneCardScore extends Equatable {
  /// Fortune type identifier (e.g., 'love': 'career': 'tarot')
  final String fortuneType;

  /// Title of the fortune card
  final String title;

  /// Description of the fortune
  final String description;

  /// Route to navigate to
  final String route;

  /// Category of the fortune (love, career, money, etc.)
  final String category;

  /// Public popularity score (0.0 - 1.0)
  /// Based on overall user visits, trends, and seasonal factors
  final double popularityScore;

  /// Personal preference score (0.0 - 1.0)
  /// Based on user's visit history, profile, and behavior
  final double personalScore;

  /// Total combined score (weighted average of popularity and personal)
  final double totalScore;

  /// Reason for recommendation (e.g., "인기 급상승", "INTJ 맞춤", "최근 관심사")
  final String recommendationReason;

  /// Recommendation type for UI display
  final RecommendationType recommendationType;

  /// Number of times user visited this fortune
  final int userVisitCount;

  /// Last time user visited this fortune
  final DateTime? lastUserVisit;

  /// Total visit count across all users
  final int totalVisitCount;

  /// Weekly trend percentage (-100 to 100+)
  final double weeklyTrend;

  /// Whether this is a new fortune
  final bool isNew;

  /// Whether this is a premium fortune
  final bool isPremium;

  /// Last time the score was updated
  final DateTime lastUpdated;

  const FortuneCardScore(
      {required this.fortuneType,
      required this.title,
      required this.description,
      required this.route,
      required this.category,
      required this.popularityScore,
      required this.personalScore,
      required this.totalScore,
      required this.recommendationReason,
      required this.recommendationType,
      this.userVisitCount = 0,
      this.lastUserVisit,
      this.totalVisitCount = 0,
      this.weeklyTrend = 0.0,
      this.isNew = false,
      this.isPremium = false,
      required this.lastUpdated});

  /// Calculate total score with custom weights
  factory FortuneCardScore.withCustomWeights(
      {required String fortuneType,
      required String title,
      required String description,
      required String route,
      required String category,
      required double popularityScore,
      required double personalScore,
      required String recommendationReason,
      required RecommendationType recommendationType,
      double popularityWeight = 0.5,
      double personalWeight = 0.5,
      int userVisitCount = 0,
      DateTime? lastUserVisit,
      int totalVisitCount = 0,
      double weeklyTrend = 0.0,
      bool isNew = false,
      bool isPremium = false,
      required DateTime lastUpdated}) {
    assert(popularityWeight + personalWeight == 1.0, 'Weights must sum to 1.0');

    final totalScore =
        (popularityScore * popularityWeight) + (personalScore * personalWeight);

    return FortuneCardScore(
        fortuneType: fortuneType,
        title: title,
        description: description,
        route: route,
        category: category,
        popularityScore: popularityScore,
        personalScore: personalScore,
        totalScore: totalScore,
        recommendationReason: recommendationReason,
        recommendationType: recommendationType,
        userVisitCount: userVisitCount,
        lastUserVisit: lastUserVisit,
        totalVisitCount: totalVisitCount,
        weeklyTrend: weeklyTrend,
        isNew: isNew,
        isPremium: isPremium,
        lastUpdated: lastUpdated);
  }

  /// Create from JSON (from backend)
  factory FortuneCardScore.fromJson(Map<String, dynamic> json) {
    return FortuneCardScore(
        fortuneType: json['fortune_type'],
        title: json['title'],
        description: json['description'],
        route: json['route'],
        category: json['category'],
        popularityScore: json['popularity_score'] as double,
        personalScore: json['personal_score'] as double,
        totalScore: json['total_score'] as double,
        recommendationReason: json['recommendation_reason'],
        recommendationType:
            RecommendationType.fromString(json['recommendation_type']),
        userVisitCount: json['user_visit_count'],
        lastUserVisit: json['last_user_visit'] != null
            ? DateTime.parse(json['last_user_visit'] as String)
            : null,
        totalVisitCount: json['total_visit_count'],
        weeklyTrend: json['weekly_trend'] as double,
        isNew: json['is_new'],
        isPremium: json['is_premium'],
        lastUpdated: DateTime.parse(json['last_updated']));
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'fortune_type': fortuneType,
      'title': title,
      'description': description,
      'route': route,
      'category': category,
      'popularity_score': popularityScore,
      'personal_score': personalScore,
      'total_score': totalScore,
      'recommendation_reason': recommendationReason,
      'recommendation_type': recommendationType.value,
      'user_visit_count': userVisitCount,
      'last_user_visit': lastUserVisit?.toIso8601String(),
      'total_visit_count': totalVisitCount,
      'weekly_trend': weeklyTrend,
      'is_new': isNew,
      'is_premium': isPremium,
      'last_updated': null
    };
  }

  /// Create a copy with updated fields
  FortuneCardScore copyWith(
      {String? fortuneType,
      String? title,
      String? description,
      String? route,
      String? category,
      double? popularityScore,
      double? personalScore,
      double? totalScore,
      String? recommendationReason,
      RecommendationType? recommendationType,
      int? userVisitCount,
      DateTime? lastUserVisit,
      int? totalVisitCount,
      double? weeklyTrend,
      bool? isNew,
      bool? isPremium,
      DateTime? lastUpdated}) {
    return FortuneCardScore(
        fortuneType: fortuneType ?? this.fortuneType,
        title: title ?? this.title,
        description: description ?? this.description,
        route: route ?? this.route,
        category: category ?? this.category,
        popularityScore: popularityScore ?? this.popularityScore,
        personalScore: personalScore ?? this.personalScore,
        totalScore: totalScore ?? this.totalScore,
        recommendationReason: recommendationReason ?? this.recommendationReason,
        recommendationType: recommendationType ?? this.recommendationType,
        userVisitCount: userVisitCount ?? this.userVisitCount,
        lastUserVisit: lastUserVisit ?? this.lastUserVisit,
        totalVisitCount: totalVisitCount ?? this.totalVisitCount,
        weeklyTrend: weeklyTrend ?? this.weeklyTrend,
        isNew: isNew ?? this.isNew,
        isPremium: isPremium ?? this.isPremium,
        lastUpdated: lastUpdated ?? this.lastUpdated);
  }

  /// Check if this fortune should be boosted (new or trending)
  bool get shouldBoost => isNew || weeklyTrend > 50.0;

  /// Get display priority (higher is better)
  int get displayPriority {
    if (shouldBoost) return 3;
    if (totalScore > 0.8) return 2;
    if (totalScore > 0.5) return 1;
    return 0;
  }

  @override
  List<Object?> get props => [
        fortuneType,
        title,
        description,
        route,
        category,
        popularityScore,
        personalScore,
        totalScore,
        recommendationReason,
        recommendationType,
        userVisitCount,
        lastUserVisit,
        totalVisitCount,
        weeklyTrend,
        isNew,
        isPremium,
        lastUpdated
      ];
}

/// Types of recommendations for UI display
enum RecommendationType {
  /// Personalized based on user profile/behavior
  personalized('personalized', '맞춤 추천'),

  /// Popular among all users
  popular('popular', '인기'),

  /// Trending upward recently
  trending('trending', '급상승'),

  /// New fortune type
  newFortune('new', '신규'),

  /// Seasonal recommendation
  seasonal('seasonal', '시즌'),

  /// Based on similar users
  collaborative('collaborative', '비슷한 사용자'),

  /// Default/no specific reason
  general('general', '추천');

  final String value;
  final String displayName;

  const RecommendationType(this.value, this.displayName);

  static RecommendationType fromString(String value) {
    return RecommendationType.values.firstWhere((type) => type.value == value,
        orElse: () => RecommendationType.general);
  }
}

/// Extension for sorting fortune cards
extension FortuneCardScoreListExtension on List<FortuneCardScore> {
  /// Sort by total score (descending)
  void sortByScore() {
    sort((a, b) => b.totalScore.compareTo(a.totalScore));
  }

  /// Sort by display priority and score
  void sortByRecommendation() {
    sort((a, b) {
      // First compare by display priority
      final priorityCompare = b.displayPriority.compareTo(a.displayPriority);
      if (priorityCompare != 0) return priorityCompare;

      // Then by total score
      return b.totalScore.compareTo(a.totalScore);
    });
  }

  /// Get top N recommendations
  List<FortuneCardScore> getTopRecommendations(int count) {
    final sorted = List<FortuneCardScore>.from(this);
    sorted.sortByRecommendation();
    return sorted.take(count).toList();
  }

  /// Filter by category
  List<FortuneCardScore> filterByCategory(String category) {
    return where((score) => score.category == category).toList();
  }

  /// Filter out already visited recently (within N days)
  List<FortuneCardScore> filterRecentlyVisited(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return where((score) {
      if (score.lastUserVisit == null) return true;
      return score.lastUserVisit!.isBefore(cutoffDate);
    }).toList();
  }
}
