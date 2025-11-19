import '../../../screens/home/fortune_story_viewer.dart';
import '../../../services/weather_service.dart';

/// 운세 스토리 상태
class FortuneStoryState {
  final bool isLoading;
  final List<StorySegment>? segments;
  final WeatherInfo? weather;
  final Map<String, dynamic>? sajuAnalysis;
  final String? error;

  // Enhanced fortune data
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? weatherSummary;
  final Map<String, dynamic>? overall;
  final Map<String, dynamic>? categories;
  final Map<String, dynamic>? sajuInsight;
  final List<Map<String, dynamic>>? personalActions;
  final Map<String, dynamic>? notification;
  final Map<String, dynamic>? shareCard;

  const FortuneStoryState({
    this.isLoading = false,
    this.segments,
    this.weather,
    this.sajuAnalysis,
    this.error,
    this.meta,
    this.weatherSummary,
    this.overall,
    this.categories,
    this.sajuInsight,
    this.personalActions,
    this.notification,
    this.shareCard,
  });

  FortuneStoryState copyWith({
    bool? isLoading,
    List<StorySegment>? segments,
    WeatherInfo? weather,
    Map<String, dynamic>? sajuAnalysis,
    String? error,
    Map<String, dynamic>? meta,
    Map<String, dynamic>? weatherSummary,
    Map<String, dynamic>? overall,
    Map<String, dynamic>? categories,
    Map<String, dynamic>? sajuInsight,
    List<Map<String, dynamic>>? personalActions,
    Map<String, dynamic>? notification,
    Map<String, dynamic>? shareCard,
  }) {
    return FortuneStoryState(
      isLoading: isLoading ?? this.isLoading,
      segments: segments ?? this.segments,
      weather: weather ?? this.weather,
      sajuAnalysis: sajuAnalysis ?? this.sajuAnalysis,
      error: error ?? this.error,
      meta: meta ?? this.meta,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      overall: overall ?? this.overall,
      categories: categories ?? this.categories,
      sajuInsight: sajuInsight ?? this.sajuInsight,
      personalActions: personalActions ?? this.personalActions,
      notification: notification ?? this.notification,
      shareCard: shareCard ?? this.shareCard,
    );
  }
}
