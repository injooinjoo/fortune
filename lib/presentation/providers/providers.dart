import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/api_client.dart';
import '../../data/datasources/fortune_remote_data_source.dart';
import '../../data/datasources/token_remote_data_source.dart';
import '../../data/services/fortune_api_service_edge_functions.dart';
import '../../domain/entities/fortune.dart';
import '../../domain/entities/token.dart';
import '../../services/user_statistics_service.dart';
import '../../services/storage_service.dart';

// Export providers for easy access
export 'auth_provider.dart';
export 'token_provider.dart';
export 'fortune_provider.dart';
export 'social_auth_provider.dart';
export 'today_fortune_provider.dart';
export 'font_size_provider.dart';
export 'theme_provider.dart';
export 'user_statistics_provider.dart';
export 'recommendation_provider.dart';
export 'navigation_visibility_provider.dart';
export 'fortune_gauge_provider.dart';
export 'user_profile_notifier.dart';

// Core providers
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Data source providers
final fortuneRemoteDataSourceProvider =
    Provider<FortuneRemoteDataSource>((ref) {
  return FortuneRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final tokenRemoteDataSourceProvider = Provider<TokenRemoteDataSource>((ref) {
  return TokenRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

// Service providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final userStatisticsServiceProvider = Provider<UserStatisticsService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final storageService = ref.watch(storageServiceProvider);
  return UserStatisticsService(supabase, storageService);
});

// Token balance provider
final tokenBalanceProvider = FutureProvider<TokenBalance>((ref) async {
  final tokenDataSource = ref.watch(tokenRemoteDataSourceProvider);
  return tokenDataSource.getTokenBalance();
});

// Token history provider
final tokenHistoryProvider =
    FutureProvider.family<List<TokenTransaction>, int?>((ref, limit) async {
  final tokenDataSource = ref.watch(tokenRemoteDataSourceProvider);
  return tokenDataSource.getTokenHistory(limit: limit);
});

// Daily fortune provider
final dailyFortuneProvider = FutureProvider<DailyFortune?>((ref) async {
  final fortuneDataSource = ref.watch(fortuneRemoteDataSourceProvider);

  try {
    final response = await fortuneDataSource.getDailyFortune();
    return response.data?.toDailyFortune();
  } catch (e) {
    // Handle error
    rethrow;
  }
});

// Batch fortune provider
final batchFortuneProvider =
    FutureProvider.family<Map<String, Fortune>, List<String>>(
        (ref, types) async {
  final fortuneDataSource = ref.watch(fortuneRemoteDataSourceProvider);

  try {
    final responses = await fortuneDataSource.getBatchFortune(types);
    final Map<String, Fortune> fortunes = {};

    responses.forEach((key, response) {
      if (response.data != null) {
        fortunes[key] = response.data!.toGeneralFortune();
      }
    });

    return fortunes;
  } catch (e) {
    rethrow;
  }
});

// Fortune type info provider
final fortuneTypesProvider = Provider<List<FortuneTypeInfo>>((ref) {
  return [
    // 일일/시간별 운세
    const FortuneTypeInfo(
        id: 'daily',
        title: '일일 운세',
        description: '매일 달라지는 운의 흐름',
        category: FortuneCategory.daily,
        tokenCost: 1,
        iconName: 'sun',
        color: 'orange',
        gradient: 'from-orange-50 to-yellow-50'),
    const FortuneTypeInfo(
        id: 'today',
        title: '오늘의 운세',
        description: '오늘 하루의 전체적인 운세',
        category: FortuneCategory.daily,
        tokenCost: 1,
        iconName: 'calendar',
        color: 'blue',
        gradient: 'from-blue-50 to-indigo-50'),
    const FortuneTypeInfo(
        id: 'tomorrow',
        title: '내일의 운세',
        description: '내일을 준비하는 운세',
        category: FortuneCategory.daily,
        tokenCost: 1,
        iconName: 'sunrise',
        color: 'purple',
        gradient: 'from-purple-50 to-pink-50'),
    const FortuneTypeInfo(
        id: 'hourly',
        title: '시간대별 운세',
        description: '시간별 상세 운세',
        category: FortuneCategory.daily,
        tokenCost: 2,
        iconName: 'clock',
        color: 'green',
        gradient: 'from-green-50 to-emerald-50'),

    // 전통 운세
    const FortuneTypeInfo(
        id: 'saju',
        title: '사주팔자',
        description: '정통 사주 풀이',
        category: FortuneCategory.traditional,
        tokenCost: 3,
        iconName: 'sun',
        color: 'orange',
        gradient: 'from-orange-50 to-yellow-50',
        isPopular: true),
    const FortuneTypeInfo(
        id: 'tojeong',
        title: '토정비결',
        description: '전통 토정비결 운세',
        category: FortuneCategory.traditional,
        tokenCost: 3,
        iconName: 'scroll',
        color: 'amber',
        gradient: 'from-amber-50 to-orange-50'),
    const FortuneTypeInfo(
        id: 'palmistry',
        title: '손금',
        description: '손에 새겨진 운명의 선',
        category: FortuneCategory.traditional,
        tokenCost: 2,
        iconName: 'hand',
        color: 'amber',
        gradient: 'from-amber-50 to-yellow-50'),
    const FortuneTypeInfo(
        id: 'physiognomy',
        title: '관상',
        description: '얼굴에 담긴 운명과 성격',
        category: FortuneCategory.traditional,
        tokenCost: 3,
        iconName: 'face',
        color: 'indigo',
        gradient: 'from-indigo-50 to-purple-50'),
    const FortuneTypeInfo(
        id: 'salpuli',
        title: '살풀이',
        description: '액운을 막고 행운을 부르는 전통 운세',
        category: FortuneCategory.traditional,
        tokenCost: 3,
        iconName: 'shield',
        color: 'red',
        gradient: 'from-red-50 to-orange-50'),

    // MBTI/성격
    const FortuneTypeInfo(
        id: 'mbti',
        title: 'MBTI 운세',
        description: '성격 유형별 조언',
        category: FortuneCategory.personality,
        tokenCost: 2,
        iconName: 'brain',
        color: 'violet',
        gradient: 'from-violet-50 to-purple-50',
        isNew: true),

    // 별자리/띠
    const FortuneTypeInfo(
        id: 'zodiac',
        title: '별자리 운세',
        description: '별이 알려주는 흐름',
        category: FortuneCategory.personality,
        tokenCost: 1,
        iconName: 'star',
        color: 'cyan',
        gradient: 'from-cyan-50 to-blue-50'),
    const FortuneTypeInfo(
        id: 'zodiac-animal',
        title: '띠 운세',
        description: '12간지로 보는 운세',
        category: FortuneCategory.personality,
        tokenCost: 1,
        iconName: 'crown',
        color: 'orange',
        gradient: 'from-orange-50 to-yellow-50'),

    // 연애/결혼
    const FortuneTypeInfo(
        id: 'love',
        title: '연애운',
        description: '사랑과 인연의 흐름',
        category: FortuneCategory.love,
        tokenCost: 2,
        iconName: 'heart',
        color: 'pink',
        gradient: 'from-pink-50 to-red-50',
        isPopular: true),
    const FortuneTypeInfo(
        id: 'marriage',
        title: '결혼운',
        description: '평생의 동반자 운세',
        category: FortuneCategory.love,
        tokenCost: 3,
        iconName: 'heart',
        color: 'rose',
        gradient: 'from-rose-50 to-pink-50'),
    const FortuneTypeInfo(
        id: 'compatibility',
        title: '궁합',
        description: '둘의 운명적 만남',
        category: FortuneCategory.love,
        tokenCost: 3,
        iconName: 'users',
        color: 'rose',
        gradient: 'from-rose-50 to-pink-50'),
    const FortuneTypeInfo(
        id: 'traditional-compatibility',
        title: '전통 궁합',
        description: '사주와 오행으로 보는 천생연분',
        category: FortuneCategory.love,
        tokenCost: 3,
        iconName: 'yin-yang',
        color: 'purple',
        gradient: 'from-purple-50 to-pink-50'),
    const FortuneTypeInfo(
        id: 'couple-match',
        title: '연인 궁합',
        description: '현재 연인과의 깊은 궁합 분석',
        category: FortuneCategory.love,
        tokenCost: 2,
        iconName: 'heart-circle',
        color: 'pink',
        gradient: 'from-pink-50 to-red-50'),
    const FortuneTypeInfo(
        id: 'ex-lover',
        title: '전 애인 운세',
        description: '과거 관계의 의미와 새로운 시작',
        category: FortuneCategory.love,
        tokenCost: 2,
        iconName: 'heart-broken',
        color: 'grey',
        gradient: 'from-grey-50 to-blue-50'),
    const FortuneTypeInfo(
        id: 'blind-date',
        title: '소개팅 운세',
        description: '성공적인 만남을 위한 운세',
        category: FortuneCategory.love,
        tokenCost: 2,
        iconName: 'users',
        color: 'pink',
        gradient: 'from-pink-50 to-purple-50'),

    // 직업/사업
    const FortuneTypeInfo(
        id: 'career',
        title: '취업운',
        description: '커리어와 성공의 길',
        category: FortuneCategory.career,
        tokenCost: 2,
        iconName: 'briefcase',
        color: 'blue',
        gradient: 'from-blue-50 to-indigo-50'),
    const FortuneTypeInfo(
        id: 'business',
        title: '사업운',
        description: '창업과 사업 성공의 운',
        category: FortuneCategory.career,
        tokenCost: 3,
        iconName: 'trending-up',
        color: 'indigo',
        gradient: 'from-indigo-50 to-purple-50'),

    // 재물/투자
    const FortuneTypeInfo(
        id: 'wealth',
        title: '금전운',
        description: '재물과 투자의 운',
        category: FortuneCategory.wealth,
        tokenCost: 2,
        iconName: 'coins',
        color: 'yellow',
        gradient: 'from-yellow-50 to-orange-50',
        isPopular: true)
  ];
});

// Recent fortunes provider
final recentFortunesProvider =
    StateNotifierProvider<RecentFortunesNotifier, List<RecentFortune>>((ref) {
  return RecentFortunesNotifier();
});

class RecentFortune {
  final String path;
  final String title;
  final DateTime visitedAt;

  RecentFortune(
      {required this.path, required this.title, required this.visitedAt});
}

class RecentFortunesNotifier extends StateNotifier<List<RecentFortune>> {
  RecentFortunesNotifier() : super([]);

  void addFortune(String path, String title) {
    state = [
      RecentFortune(path: path, title: title, visitedAt: DateTime.now()),
      ...state.where((f) => f.path != path).take(9)
    ];
  }

  void clearAll() {
    state = [];
  }
}

// Fortune API Service with Edge Functions Provider
final fortuneApiServiceEdgeFunctionsProvider =
    Provider<FortuneApiServiceWithEdgeFunctions>((ref) {
  return FortuneApiServiceWithEdgeFunctions(ref);
});
