import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/models/fortune_card_score.dart';
import '../../core/constants/edge_functions_endpoints.dart';
import '../../core/utils/logger.dart';
import '../../services/analytics_service.dart';
import 'user_profile_notifier.dart' as profile_notifier;
import '../../features/fortune/domain/entities/fortune_category.dart';
import 'providers.dart';
import 'auth_provider.dart';

/// State notifier for managing fortune recommendations
class FortuneRecommendationNotifier extends StateNotifier<AsyncValue<List<FortuneCardScore>>> {
  final Ref ref;
  final Dio _dio;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  FortuneRecommendationNotifier(this.ref)
      : _dio = Dio(),
        super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() {
    // Setup Dio interceptors
    _dio.options.baseUrl = EdgeFunctionsEndpoints.currentBaseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    
    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(authTokenProvider.future);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      }));

    // Fetch recommendations on initialization
    fetchRecommendations();
  }

  /// Fetch fortune recommendations from the server
  Future<void> fetchRecommendations({bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration &&
        state.hasValue) {
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Get current user
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        Logger.warning('User not authenticated - using empty recommendations');
        state = const AsyncValue.data([]);
        return;
      }

      // TODO: Fortune Recommendations API is not implemented yet
      // Temporarily disable API call to prevent errors
      Logger.info('Fortune Recommendations API disabled - using empty fallback');
      state = const AsyncValue.data([]);
      _lastFetchTime = DateTime.now();

      // Log analytics event for monitoring
      await AnalyticsService.instance.logEvent(
        'fortune_recommendations_disabled',
        parameters: {
          'reason': 'api_not_implemented',
          'timestamp': DateTime.now().toIso8601String(),
        });

      // TODO: Uncomment when API is implemented
      /*
      // Make API call
      final response = await _dio.get(
        EdgeFunctionsEndpoints.fortuneRecommendations,
        queryParameters: {'limit': 30}, // Get top 30 recommendations
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final recommendations = (data['recommendations'] as List)
            .map((json) => FortuneCardScore.fromJson(json))
            .toList();

        // Update state
        state = AsyncValue.data(recommendations);
        _lastFetchTime = DateTime.now();

        // Log analytics event
        await AnalyticsService.instance.logEvent(
          'fortune_recommendations_fetched',
          parameters: {
            'count': recommendations.length,
            'top_type': recommendations.firstOrNull?.fortuneType,
            'top_score': null});
      } else {
        throw Exception('Failed to fetch recommendations: ${response.statusCode}');
      }
      */
    } catch (error) {
      // This catch block should not be reached since API is disabled above
      // But keeping it for future API implementation
      Logger.warning('Fortune recommendations API disabled - using empty fallback');
      // Provide empty data instead of error state to prevent UI blocking
      state = const AsyncValue.data([]);
    }
  }

  /// Get recommendations filtered by category
  List<FortuneCardScore> getByCategory(String category) {
    if (!state.hasValue) return [];
    return state.value!.where((score) => score.category == category).toList();
  }

  /// Get top N recommendations
  List<FortuneCardScore> getTopRecommendations(int count) {
    if (!state.hasValue) return [];
    return state.value!.take(count).toList();
  }

  /// Get recommendations excluding recently visited
  List<FortuneCardScore> getExcludingRecent(int recentDays) {
    if (!state.hasValue) return [];
    return state.value!.filterRecentlyVisited(recentDays);
  }

  /// Record a fortune visit
  Future<void> recordVisit(String fortuneType, String category) async {
    try {
      // Update local user profile preferences
      final userProfile = ref.read(userProfileProvider).value;
      if (userProfile?.fortunePreferences != null) {
        final updatedPreferences = userProfile!.fortunePreferences!.recordVisit(
          fortuneType,
          category);

        // Update user profile with new preferences
        final updatedProfile = userProfile.copyWith(
          fortunePreferences: updatedPreferences);

        // Update the provider
        ref.read(profile_notifier.userProfileNotifierProvider.notifier).updateProfile(updatedProfile);
      }

      // Log visit to analytics
      await AnalyticsService.instance.logEvent(
        'fortune_card_visit',
        parameters: {
          'fortune_type': fortuneType,
          'category': category,
          'source': 'recommendation'});

      // Optionally refresh recommendations after visit
      // This helps to update personal scores based on new visit data
      Future.delayed(const Duration(seconds: 2), () {
        fetchRecommendations();
      });
    } catch (error) {
      Logger.error('Failed to record fortune visit', error);
    }
  }

  /// Toggle favorite status for a fortune
  Future<void> toggleFavorite(String fortuneType) async {
    try {
      final userProfile = ref.read(userProfileProvider).value;
      if (userProfile?.fortunePreferences != null) {
        final currentFavorites = List<String>.from(
          userProfile!.fortunePreferences!.favorites);

        if (currentFavorites.contains(fortuneType)) {
          currentFavorites.remove(fortuneType);
        } else {
          currentFavorites.add(fortuneType);
        }

        final updatedPreferences = userProfile.fortunePreferences!.copyWith(
          favorites: currentFavorites);

        final updatedProfile = userProfile.copyWith(
          fortunePreferences: updatedPreferences);

        ref.read(profile_notifier.userProfileNotifierProvider.notifier).updateProfile(updatedProfile);

        // Refresh recommendations to reflect favorite status
        await fetchRecommendations(forceRefresh: true);
      }
    } catch (error) {
      Logger.error('Failed to toggle favorite', error);
    }
  }

  /// Clear cache and refresh
  Future<void> refresh() async {
    _lastFetchTime = null;
    await fetchRecommendations(forceRefresh: true);
  }
}

/// Main provider for fortune recommendations
final fortuneRecommendationProvider = StateNotifierProvider<FortuneRecommendationNotifier, AsyncValue<List<FortuneCardScore>>>((ref) => FortuneRecommendationNotifier(ref));

/// Provider for getting recommendations by category
final fortuneRecommendationsByCategoryProvider = Provider.family<List<FortuneCardScore>, String>(
  (ref, category) {
    final recommendations = ref.watch(fortuneRecommendationProvider);
    return recommendations.maybeWhen(
      data: (scores) => scores.filterByCategory(category),
      orElse: () => []);
  });

/// Provider for getting top recommendations
final topFortuneRecommendationsProvider = Provider.family<List<FortuneCardScore>, int>(
  (ref, count) {
    final recommendations = ref.watch(fortuneRecommendationProvider);
    return recommendations.maybeWhen(
      data: (scores) => scores.getTopRecommendations(count),
      orElse: () => []);
  });

/// Provider to convert FortuneCardScore to FortuneCategory
final fortuneCategoryFromScoreProvider = Provider.family<FortuneCategory?, FortuneCardScore>(
  (ref, score) {
    // Map category to gradient colors
    final categoryGradients = {
      'love': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
      'career': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      'money': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'health': [const Color(0xFF10B981), const Color(0xFF059669)],
      'traditional': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      'lifestyle': [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
      'interactive': [const Color(0xFF9333EA), const Color(0xFF7C3AED)],
      'petFamily': null};

    // Map category to icons
    final categoryIcons = {
      'love': Icons.favorite_rounded,
      'career': Icons.work_rounded,
      'money': Icons.attach_money_rounded,
      'health': Icons.health_and_safety_rounded,
      'traditional': Icons.auto_awesome_rounded,
      'lifestyle': Icons.calendar_today_rounded,
      'interactive': Icons.touch_app_rounded,
      'petFamily': null};

    final gradients = categoryGradients[score.category] ?? 
        [const Color(0xFF7C3AED), const Color(0xFF3B82F6)];
    
    final icon = categoryIcons[score.category] ?? Icons.star_rounded;

    return FortuneCategory(
      title: score.title,
      route: score.route,
      type: score.fortuneType,
      icon: icon,
      gradientColors: gradients,
      description: score.description,
      category: score.category,
      isNew: score.isNew,
      isPremium: score.isPremium);
  });

/// Provider for checking if recommendations are ready
final recommendationsReadyProvider = Provider<bool>((ref) {
  final recommendations = ref.watch(fortuneRecommendationProvider);
  return recommendations.hasValue && recommendations.value!.isNotEmpty;
});

/// Provider for recommendation loading state
final recommendationsLoadingProvider = Provider<bool>((ref) {
  final recommendations = ref.watch(fortuneRecommendationProvider);
  return recommendations.isLoading;
});

