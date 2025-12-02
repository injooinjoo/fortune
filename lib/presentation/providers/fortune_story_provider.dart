import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/weather_service.dart';
import '../../screens/home/fortune_story_viewer.dart';
import '../../domain/entities/fortune.dart' as fortune_entity;
import '../../domain/entities/user_profile.dart';
import '../../core/utils/logger.dart';

// Import the split files
import 'fortune_story/story_state.dart';
import 'fortune_story/story_generator.dart';

/// 운세 스토리 생성 Provider
class FortuneStoryNotifier extends StateNotifier<FortuneStoryState> {
  final Ref ref;
  final SupabaseClient _supabase = Supabase.instance.client;
  late final StoryGenerator _generator;

  FortuneStoryNotifier(this.ref) : super(const FortuneStoryState()) {
    _generator = StoryGenerator(_supabase);
  }

  /// 운세 스토리 생성
  Future<void> generateFortuneStory({
    required String userName,
    required fortune_entity.Fortune fortune,
    UserProfile? userProfile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. 날씨 정보 가져오기
      Logger.info('🌤️ Getting weather information...');
      final weather = await WeatherService.getCurrentWeather();

      state = state.copyWith(weather: weather);

      // 2. GPT API를 통한 스토리 생성
      Logger.info('📝 Generating fortune story with GPT...');
      final segments = await _generator.generateWithGPT(
        userName: userName,
        weather: weather,
        fortune: fortune,
        userProfile: userProfile,
      );

      // GPT 실패 시 segments가 비어있음 -> 에러 처리
      if (segments.isEmpty) {
        Logger.error('❌ GPT returned empty segments');
        state = state.copyWith(
          isLoading: false,
          segments: null,
          error: 'GPT 스토리 생성 실패',
        );
        return;
      }

      // Edge Function에서 확장된 데이터 추출
      Map<String, dynamic>? sajuAnalysis;
      Map<String, dynamic>? meta;
      Map<String, dynamic>? weatherSummary;
      Map<String, dynamic>? overall;
      Map<String, dynamic>? categories;
      Map<String, dynamic>? sajuInsight;
      List<Map<String, dynamic>>? personalActions;
      Map<String, dynamic>? notification;
      Map<String, dynamic>? shareCard;

      if (_generator.lastResponseData != null) {
        final data = _generator.lastResponseData!;
        sajuAnalysis = data['sajuAnalysis'] as Map<String, dynamic>?;
        meta = data['meta'] as Map<String, dynamic>?;
        weatherSummary = data['weatherSummary'] as Map<String, dynamic>?;
        overall = data['overall'] as Map<String, dynamic>?;
        categories = data['categories'] as Map<String, dynamic>?;
        sajuInsight = data['sajuInsight'] as Map<String, dynamic>?;
        personalActions = (data['personalActions'] as List?)?.cast<Map<String, dynamic>>();
        notification = data['notification'] as Map<String, dynamic>?;
        shareCard = data['shareCard'] as Map<String, dynamic>?;
      }

      state = state.copyWith(
        isLoading: false,
        segments: segments,
        sajuAnalysis: sajuAnalysis,
        meta: meta,
        weatherSummary: weatherSummary,
        overall: overall,
        categories: categories,
        sajuInsight: sajuInsight,
        personalActions: personalActions,
        notification: notification,
        shareCard: shareCard,
      );

      Logger.info('✅ Fortune story generated successfully');
      Logger.info('📦 Final segments count: ${segments.length}');
    } catch (e) {
      Logger.error('❌ Error generating fortune story: $e');

      // 에러 발생 시 에러 상태로 설정 (fallback 없음)
      state = state.copyWith(
        isLoading: false,
        segments: null,
        error: e.toString(),
      );
    }
  }
}

/// Provider 정의
final fortuneStoryProvider = StateNotifierProvider<FortuneStoryNotifier, FortuneStoryState>((ref) {
  return FortuneStoryNotifier(ref);
});
