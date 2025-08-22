import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fortune.dart';
import '../../data/services/fortune_api_service.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../services/cache_service.dart';
import '../../models/fortune_model.dart';
import 'auth_provider.dart';

// Fortune State
class FortuneState {
  final bool isLoading;
  final Fortune? fortune;
  final String? error;

  const FortuneState({
    this.isLoading = false,
    this.fortune,
    this.error
  });

  FortuneState copyWith({
    bool? isLoading,
    Fortune? fortune,
    String? error}) {
    return FortuneState(
      isLoading: isLoading ?? this.isLoading,
      fortune: fortune ?? this.fortune,
      error: error);
  }
}

// Base Fortune Notifier
abstract class BaseFortuneNotifier extends StateNotifier<FortuneState> {
  final FortuneApiService _apiService;
  final Ref ref;

  BaseFortuneNotifier(this._apiService, this.ref) : super(const FortuneState());

  Future<void> loadFortune() async {
    final stopwatch = Logger.startTimer('Fortune Loading - ${runtimeType}');
    Logger.info('🔍 [BaseFortuneNotifier] loadFortune: Starting to load fortune', {
      'notifierType': runtimeType.toString(),
      'timestamp': null});
    Logger.debug('🔍 [BaseFortuneNotifier] Current state', {
      'isLoading': state.isLoading,
      'hasError': state.error != null,
      'hasFortune': state.fortune != null,
      'fortuneId': state.fortune?.id,
      'errorMessage': null});
    
    Logger.debug('🔄 [BaseFortuneNotifier] Updating state to loading');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Option 2: Use Supabase client directly for immediate access
      Logger.debug('🔍 [BaseFortuneNotifier] Getting user from Supabase client directly...');
      final supabase = ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      
      Logger.debug('🔍 [BaseFortuneNotifier] User authentication status', {
        'userId': user?.id,
        'email': user?.email,
        'isAuthenticated': user != null,
        'userRole': user?.role,
        'emailVerified': null});
      
      if (user == null) {
        Logger.error('❌ [BaseFortuneNotifier] User is null - throwing UnauthorizedException');
        throw UnauthorizedException('로그인이 필요합니다');
      }

      Logger.debug('🔍 [BaseFortuneNotifier] Calling generateFortune', {
        'userId': user.id,
        'notifierType': runtimeType.toString(),
        'timestamp': null});
      
      final fortuneStopwatch = Logger.startTimer('Generate Fortune - ${runtimeType}');
      final fortune = await generateFortune(user.id);
      Logger.endTimer('Generate Fortune - ${runtimeType}', fortuneStopwatch);
      
      Logger.info('🔍 [BaseFortuneNotifier] Fortune generated successfully', {
        'fortuneId': fortune.id,
        'fortuneType': fortune.type,
        'contentLength': fortune.content.length,
        'overallScore': fortune.overallScore,
        'hasDescription': fortune.description?.isNotEmpty ?? false,
        'luckyItemsCount': fortune.luckyItems?.length ?? 0,
        'recommendationsCount': fortune.recommendations?.length ?? 0,
        'generationTime': '${fortuneStopwatch.elapsedMilliseconds}ms'});
      
      state = state.copyWith(
        isLoading: false,
        fortune: fortune);
      Logger.endTimer('Fortune Loading - ${runtimeType}', stopwatch);
      Logger.debug('🔍 [BaseFortuneNotifier] State updated with fortune', {
        'totalLoadTime': '${stopwatch.elapsedMilliseconds}ms',
        'fortuneId': null});
    } catch (e, stackTrace) {
      Logger.endTimer('Fortune Loading - ${runtimeType}', stopwatch);
      Logger.error('❌ [BaseFortuneNotifier] Error in loadFortune', {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'notifierType': runtimeType.toString(),
        'stackTrace': stackTrace.toString(),
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
      Logger.debug('🔍 [BaseFortuneNotifier] State updated with error', {
        'errorMessage'});
    }
  }

  Future<Fortune> generateFortune(String userId);

  void reset() {
    Logger.debug('🔄 [BaseFortuneNotifier] Resetting state', {
      'notifierType': runtimeType.toString(),
      'hadFortune': state.fortune != null,
      'hadError': null});
    state = const FortuneState();
  }
}

// Daily Fortune Notifier
class DailyFortuneNotifier extends BaseFortuneNotifier {
  DateTime? _selectedDate;
  final CacheService _cacheService = CacheService();

  DailyFortuneNotifier(super._apiService, super.ref);

  void setDate(DateTime date) {
    Logger.debug('📅 [DailyFortuneNotifier] Setting date', {
      'previousDate': _selectedDate?.toIso8601String(),
      'newDate': null});
    _selectedDate = date;
  }

  @override
  Future<Fortune> generateFortune(String userId) async {
    Logger.info('🔍 [DailyFortuneNotifier] generateFortune called', {
      'userId': userId,
      'selectedDate': _selectedDate?.toIso8601String(),
      'isToday': _selectedDate == null || 
                 (_selectedDate!.year == DateTime.now().year && 
                  _selectedDate!.month == DateTime.now().month && 
                  _selectedDate!.day == DateTime.now().day),
      'timestamp': null});
    
    final stopwatch = Logger.startTimer('DailyFortune Generation');
    
    try {
      // 1. 먼저 캐시 확인
      Logger.debug('📦 [DailyFortuneNotifier] Checking cache first');
      final cachedFortune = await _cacheService.getCachedFortune('daily', {'userId': userId});
      
      if (cachedFortune != null) {
        Logger.endTimer('DailyFortune Generation', stopwatch);
        final fortuneEntity = cachedFortune.toEntity();
        Logger.info('✅ [DailyFortuneNotifier] Using cached fortune', {
          'fortuneId': cachedFortune.id,
          'overallScore': fortuneEntity.overallScore,
          'cacheTime': '${stopwatch.elapsedMilliseconds}ms'});
        return fortuneEntity;
      }
      
      // 2. 캐시가 없으면 API 호출
      Logger.debug('📡 [DailyFortuneNotifier] No cache found, calling API', {
        'method': 'getDailyFortune',
        'userId': userId,
        'date': null});
      
      final apiStopwatch = Logger.startTimer('DailyFortune API Call');
      final fortune = await _apiService.getDailyFortune(
        userId: userId,
        date: _selectedDate ?? DateTime.now());
      Logger.endTimer('DailyFortune API Call', apiStopwatch);
      
      // 3. API 결과를 캐시에 저장
      await _cacheService.cacheFortune('daily', {'userId': userId}, FortuneModel.fromEntity(fortune));
      
      Logger.endTimer('DailyFortune Generation', stopwatch);
      Logger.info('🔍 [DailyFortuneNotifier] getDailyFortune returned successfully', {
        'fortuneId': fortune.id,
        'fortuneType': fortune.type,
        'overallScore': fortune.overallScore,
        'category': fortune.category,
        'hasDescription': fortune.description?.isNotEmpty ?? false,
        'luckyItemsCount': fortune.luckyItems?.length ?? 0,
        'apiCallTime': '${apiStopwatch.elapsedMilliseconds}ms',
        'totalTime': '${stopwatch.elapsedMilliseconds}ms'});
      
      return fortune;
    } catch (e, stackTrace) {
      Logger.endTimer('DailyFortune Generation', stopwatch);
      Logger.error('❌ [DailyFortuneNotifier] Error in generateFortune', {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'userId': userId,
        'selectedDate': _selectedDate?.toIso8601String(),
        'totalTime': '${stopwatch.elapsedMilliseconds}ms',
        'stackTrace': null});
      rethrow;
    }
  }
}

// Saju Fortune Notifier
class SajuFortuneNotifier extends BaseFortuneNotifier {
  SajuFortuneNotifier(super._apiService, super.ref);

  @override
  Future<Fortune> generateFortune(String userId) async {
    Logger.info('🔍 [SajuFortuneNotifier] generateFortune called', {
      'userId': userId,
      'timestamp': null});
    
    final stopwatch = Logger.startTimer('SajuFortune Generation');
    
    try {
      final user = ref.read(userProvider).value;
      Logger.debug('👤 [SajuFortuneNotifier] Checking user metadata', {
        'hasUser': user != null,
        'hasUserMetadata': user?.userMetadata != null,
        'hasBirthDate': user?.userMetadata?['birthDate']});
      
      if (user?.userMetadata?['birthDate'] == null) {
        Logger.warning(
          '⚠️ [SajuFortuneNotifier] Missing birth date', {
          'userId'});
        throw const ValidationException(message: '생년월일 정보가 필요합니다');
      }

      final birthDate = DateTime.parse(user!.userMetadata!['birthDate']);
      Logger.debug('📅 [SajuFortuneNotifier] Birth date parsed', {
        'birthDate': birthDate.toIso8601String(),
        'age': null});
      
      Logger.debug('📡 [SajuFortuneNotifier] Calling API service');
      final fortune = await _apiService.getSajuFortune(
        userId: userId,
        birthDate: birthDate);
      
      Logger.endTimer('SajuFortune Generation', stopwatch);
      Logger.info('✅ [SajuFortuneNotifier] Saju fortune generated', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'generationTime': '${stopwatch.elapsedMilliseconds}ms'});
      
      return fortune;
    } catch (e) {
      Logger.endTimer('SajuFortune Generation', stopwatch);
      Logger.error('❌ [SajuFortuneNotifier] Error generating saju fortune', {
        'error': e.toString(),
        'userId': userId,
        'generationTime': '${stopwatch.elapsedMilliseconds}ms'});
      rethrow;
    }
  }
}

// Compatibility Fortune Notifier
class CompatibilityFortuneNotifier extends BaseFortuneNotifier {
  Map<String, dynamic>? _person1Data;
  Map<String, dynamic>? _person2Data;

  CompatibilityFortuneNotifier(super._apiService, super.ref);

  void setPersonData({
    required Map<String, dynamic> person1,
    required Map<String, dynamic> person2
  }) {
    Logger.debug('👥 [CompatibilityFortuneNotifier] Setting person data', {
      'person1Keys': person1.keys.toList(),
      'person2Keys': person2.keys.toList(),
      'person1Name': person1['name'],
      'person2Name': person2['name']});
    _person1Data = person1;
    _person2Data = person2;
  }

  @override
  Future<Fortune> generateFortune(String userId) async {
    Logger.info('🔍 [CompatibilityFortuneNotifier] generateFortune called', {
      'userId': userId,
      'hasPerson1Data': _person1Data != null,
      'hasPerson2Data': null});
    
    if (_person1Data == null || _person2Data == null) {
      Logger.warning('⚠️ [CompatibilityFortuneNotifier] Missing person data', {
        'person1': _person1Data != null,
        'person2': null});
      throw const ValidationException(message: '두 사람의 정보가 모두 필요합니다');
    }

    final stopwatch = Logger.startTimer('CompatibilityFortune API Call');
    try {
      Logger.debug('📡 [CompatibilityFortuneNotifier] Calling API with person data', {
        'person1': _person1Data!['name'],
        'person2': _person2Data!['name']});
      
      final fortune = await _apiService.getCompatibilityFortune(
        person1: _person1Data!,
        person2: _person2Data!);
      
      Logger.endTimer('CompatibilityFortune API Call', stopwatch);
      Logger.info('✅ [CompatibilityFortuneNotifier] Compatibility calculated', {
        'fortuneId': fortune.id,
        'overallScore': fortune.overallScore,
        'apiCallTime': '${stopwatch.elapsedMilliseconds}ms'});
      
      return fortune;
    } catch (e) {
      Logger.endTimer('CompatibilityFortune API Call', stopwatch);
      Logger.error('❌ [CompatibilityFortuneNotifier] Error in compatibility', {
        'error': e.toString(),
        'apiCallTime': '${stopwatch.elapsedMilliseconds}ms'});
      rethrow;
    }
  }
}

// Love Fortune Notifier
class LoveFortuneNotifier extends BaseFortuneNotifier {
  LoveFortuneNotifier(super._apiService, super.ref);

  @override
  Future<Fortune> generateFortune(String userId) async {
    return await _apiService.getLoveFortune(userId: userId);
  }
}

// Wealth Fortune Notifier
class WealthFortuneNotifier extends BaseFortuneNotifier {
  Map<String, dynamic>? _financialData;

  WealthFortuneNotifier(super._apiService, super.ref);

  void setFinancialData(Map<String, dynamic> data) {
    Logger.debug('💰 [WealthFortuneNotifier] Setting financial data', {
      'dataKeys': data.keys.toList(),
      'hasIncome': data.containsKey('income'),
      'hasExpenses': data.containsKey('expenses'),
      'hasSavings': data.containsKey('savings')});
    _financialData = data;
  }

  @override
  Future<Fortune> generateFortune(String userId) async {
    if (_financialData == null) {
      throw const ValidationException(message: '재무 정보가 필요합니다');
    }

    return await _apiService.getWealthFortune(
      userId: userId,
      financialData: _financialData!);
  }
}

// MBTI Fortune Notifier
class MbtiFortuneNotifier extends BaseFortuneNotifier {
  String? _mbtiType;
  List<String> _categories = [];

  MbtiFortuneNotifier(super._apiService, super.ref);

  void setMbtiData({
    required String mbtiType,
    required List<String> categories
  }) {
    Logger.debug('🧠 [MbtiFortuneNotifier] Setting MBTI data', {
      'previousType': _mbtiType,
      'newType': mbtiType,
      'categoriesCount': categories.length,
      'categories': null});
    _mbtiType = mbtiType;
    _categories = categories;
  }

  @override
  Future<Fortune> generateFortune(String userId) async {
    if (_mbtiType == null || _categories.isEmpty) {
      throw const ValidationException(message: 'MBTI 타입과 카테고리를 선택해주세요');
    }

    return await _apiService.getMbtiFortune(
      userId: userId,
      mbtiType: _mbtiType!,
      categories: _categories);
  }
}

// Fortune History Notifier
class FortuneHistoryNotifier extends StateNotifier<AsyncValue<List<Fortune>>> {
  final FortuneApiService _apiService;
  final Ref ref;

  FortuneHistoryNotifier(this._apiService, this.ref)
      : super(const AsyncValue.loading());

  Future<void> loadHistory({int? limit, int? offset}) async {
    final stopwatch = Logger.startTimer('Fortune History Loading');
    Logger.info('📚 [FortuneHistoryNotifier] Loading fortune history', {
      'limit': limit,
      'offset': offset,
      'timestamp': null});
    
    state = const AsyncValue.loading();

    try {
      final user = ref.read(userProvider).value;
      Logger.debug('👤 [FortuneHistoryNotifier] Checking user', {
        'hasUser': user != null,
        'userId': null});
      
      if (user == null) {
        Logger.warning('⚠️ [FortuneHistoryNotifier] User not authenticated');
        throw UnauthorizedException('로그인이 필요합니다');
      }

      Logger.debug('📡 [FortuneHistoryNotifier] Fetching history from API');
      final history = await _apiService.getFortuneHistory(
        userId: user.id,
        limit: limit,
        offset: offset);

      Logger.endTimer('Fortune History Loading', stopwatch);
      Logger.info('✅ [FortuneHistoryNotifier] History loaded', {
        'itemCount': history.length,
        'loadTime': '${stopwatch.elapsedMilliseconds}ms'});
      
      state = AsyncValue.data(history);
    } catch (e, stack) {
      Logger.endTimer('Fortune History Loading', stopwatch);
      Logger.error('❌ [FortuneHistoryNotifier] Error loading history', {
        'error': e.toString(),
        'loadTime': '${stopwatch.elapsedMilliseconds}ms',
        'stackTrace': null});
      state = AsyncValue.error(e, stack);
    }
  }
}

// Time-based Fortune Notifiers
class TomorrowFortuneNotifier extends BaseFortuneNotifier {
  TomorrowFortuneNotifier(super._apiService, super.ref);

  @override
  Future<Fortune> generateFortune(String userId) async {
    return await _apiService.getTomorrowFortune(userId: userId);
  }
}

class WeeklyFortuneNotifier extends BaseFortuneNotifier {
  WeeklyFortuneNotifier(super._apiService, super.ref);

  @override
  Future<Fortune> generateFortune(String userId) async {
    return await _apiService.getWeeklyFortune(userId: userId);
  }
}

class MonthlyFortuneNotifier extends BaseFortuneNotifier {
  MonthlyFortuneNotifier(super._apiService, super.ref);

  @override
  Future<Fortune> generateFortune(String userId) async {
    return await _apiService.getMonthlyFortune(userId: userId);
  }
}

class YearlyFortuneNotifier extends BaseFortuneNotifier {
  YearlyFortuneNotifier(super._apiService, super.ref);

  @override
  Future<Fortune> generateFortune(String userId) async {
    return await _apiService.getYearlyFortune(userId: userId);
  }
}

// Providers
final dailyFortuneProvider =
    StateNotifierProvider<DailyFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return DailyFortuneNotifier(apiService, ref);
});

final tomorrowFortuneProvider =
    StateNotifierProvider<TomorrowFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return TomorrowFortuneNotifier(apiService, ref);
});

final weeklyFortuneProvider =
    StateNotifierProvider<WeeklyFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return WeeklyFortuneNotifier(apiService, ref);
});

final monthlyFortuneProvider =
    StateNotifierProvider<MonthlyFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return MonthlyFortuneNotifier(apiService, ref);
});

final yearlyFortuneProvider =
    StateNotifierProvider<YearlyFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return YearlyFortuneNotifier(apiService, ref);
});

final sajuFortuneProvider =
    StateNotifierProvider<SajuFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return SajuFortuneNotifier(apiService, ref);
});

final compatibilityFortuneProvider =
    StateNotifierProvider<CompatibilityFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return CompatibilityFortuneNotifier(apiService, ref);
});

final loveFortuneProvider =
    StateNotifierProvider<LoveFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return LoveFortuneNotifier(apiService, ref);
});

final wealthFortuneProvider =
    StateNotifierProvider<WealthFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return WealthFortuneNotifier(apiService, ref);
});

final mbtiFortuneProvider =
    StateNotifierProvider<MbtiFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return MbtiFortuneNotifier(apiService, ref);
});

final fortuneHistoryProvider =
    StateNotifierProvider<FortuneHistoryNotifier, AsyncValue<List<Fortune>>>(
        (ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return FortuneHistoryNotifier(apiService, ref);
});

// Fortune Service Provider (for base pages)
final fortuneServiceProvider = Provider<FortuneApiService>((ref) {
  return ref.watch(fortuneApiServiceProvider);
});

// Validation Exception (removed - already defined in exceptions.dart,

// Fortune Generation Params
class FortuneGenerationParams {
  final String fortuneType;
  final Map<String, dynamic> userInfo;

  FortuneGenerationParams({
    required this.fortuneType,
    required this.userInfo
  });
}

// Fortune Generation Provider
final fortuneGenerationProvider = FutureProvider.family<Fortune, FortuneGenerationParams>((ref, params) async {
  final stopwatch = Logger.startTimer('Fortune Generation Provider');
  Logger.info('🎯 [FortuneGenerationProvider] Starting fortune generation', {
    'fortuneType': params.fortuneType,
    'userInfoKeys': params.userInfo.keys.toList(),
    'timestamp': null});
  
  final apiService = ref.watch(fortuneApiServiceProvider);
  final user = ref.watch(userProvider).value;
  
  Logger.debug('👤 [FortuneGenerationProvider] Checking user authentication', {
    'hasUser': user != null,
    'userId': null});
  
  if (user == null) {
    Logger.endTimer('Fortune Generation Provider', stopwatch);
    Logger.warning('⚠️ [FortuneGenerationProvider] User not authenticated');
    throw UnauthorizedException('로그인이 필요합니다');
  }

  try {
    Logger.debug('📡 [FortuneGenerationProvider] Calling API service', {
      'userId': user.id,
      'fortuneType': params.fortuneType,
      'paramCount': null});
    
    final fortune = await apiService.getFortune(
      userId: user.id,
      fortuneType: params.fortuneType,
      params: params.userInfo);
    
    Logger.endTimer('Fortune Generation Provider', stopwatch);
    Logger.info('✅ [FortuneGenerationProvider] Fortune generated', {
      'fortuneId': fortune.id,
      'fortuneType': params.fortuneType,
      'overallScore': fortune.overallScore,
      'generationTime': '${stopwatch.elapsedMilliseconds}ms'});
    
    return fortune;
  } catch (e, stackTrace) {
    Logger.endTimer('Fortune Generation Provider', stopwatch);
    Logger.error('❌ [FortuneGenerationProvider] Generation failed', {
      'error': e.toString(),
      'fortuneType': params.fortuneType,
      'generationTime': '${stopwatch.elapsedMilliseconds}ms',
      'stackTrace': null});
    rethrow;
  }
});