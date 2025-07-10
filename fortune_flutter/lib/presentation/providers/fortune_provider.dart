import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fortune.dart';
import '../../data/services/fortune_api_service.dart';
import '../../core/errors/exceptions.dart';
import 'auth_provider.dart';

// Fortune State
class FortuneState {
  final bool isLoading;
  final Fortune? fortune;
  final String? error;

  const FortuneState({
    this.isLoading = false,
    this.fortune,
    this.error,
  });

  FortuneState copyWith({
    bool? isLoading,
    Fortune? fortune,
    String? error,
  }) {
    return FortuneState(
      isLoading: isLoading ?? this.isLoading,
      fortune: fortune ?? this.fortune,
      error: error,
    );
  }
}

// Base Fortune Notifier
abstract class BaseFortuneNotifier extends StateNotifier<FortuneState> {
  final FortuneApiService _apiService;
  final Ref ref;

  BaseFortuneNotifier(this._apiService, this.ref) : super(const FortuneState());

  Future<void> loadFortune() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      final fortune = await generateFortune(user.id);
      state = state.copyWith(
        isLoading: false,
        fortune: fortune,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Fortune> generateFortune(String userId);

  void reset() {
    state = const FortuneState();
  }
}

// Daily Fortune Notifier
class DailyFortuneNotifier extends BaseFortuneNotifier {
  DateTime? _selectedDate;

  DailyFortuneNotifier(super._apiService, super.ref);

  void setDate(DateTime date) {
    _selectedDate = date;
  }

  @override
  Future<Fortune> generateFortune(String userId) async {
    return await _apiService.getDailyFortune(
      userId: userId,
      date: _selectedDate,
    );
  }
}

// Saju Fortune Notifier
class SajuFortuneNotifier extends BaseFortuneNotifier {
  SajuFortuneNotifier(super._apiService, super.ref);

  @override
  Future<Fortune> generateFortune(String userId) async {
    final user = ref.read(userProvider).value;
    if (user?.userMetadata?['birthDate'] == null) {
      throw const ValidationException(message: '생년월일 정보가 필요합니다');
    }

    final birthDate = DateTime.parse(user!.userMetadata!['birthDate']);
    return await _apiService.getSajuFortune(
      userId: userId,
      birthDate: birthDate,
    );
  }
}

// Compatibility Fortune Notifier
class CompatibilityFortuneNotifier extends BaseFortuneNotifier {
  Map<String, dynamic>? _person1Data;
  Map<String, dynamic>? _person2Data;

  CompatibilityFortuneNotifier(super._apiService, super.ref);

  void setPersonData({
    required Map<String, dynamic> person1,
    required Map<String, dynamic> person2,
  }) {
    _person1Data = person1;
    _person2Data = person2;
  }

  @override
  Future<Fortune> generateFortune(String userId) async {
    if (_person1Data == null || _person2Data == null) {
      throw const ValidationException(message: '두 사람의 정보가 모두 필요합니다');
    }

    return await _apiService.getCompatibilityFortune(
      person1: _person1Data!,
      person2: _person2Data!,
    );
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
    _financialData = data;
  }

  @override
  Future<Fortune> generateFortune(String userId) async {
    if (_financialData == null) {
      throw const ValidationException(message: '재무 정보가 필요합니다');
    }

    return await _apiService.getWealthFortune(
      userId: userId,
      financialData: _financialData!,
    );
  }
}

// MBTI Fortune Notifier
class MbtiFortuneNotifier extends BaseFortuneNotifier {
  String? _mbtiType;
  List<String> _categories = [];

  MbtiFortuneNotifier(super._apiService, super.ref);

  void setMbtiData({
    required String mbtiType,
    required List<String> categories,
  }) {
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
      categories: _categories,
    );
  }
}

// Fortune History Notifier
class FortuneHistoryNotifier extends StateNotifier<AsyncValue<List<Fortune>>> {
  final FortuneApiService _apiService;
  final Ref ref;

  FortuneHistoryNotifier(this._apiService, this.ref)
      : super(const AsyncValue.loading());

  Future<void> loadHistory({int? limit, int? offset}) async {
    state = const AsyncValue.loading();

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      final history = await _apiService.getFortuneHistory(
        userId: user.id,
        limit: limit,
        offset: offset,
      );

      state = AsyncValue.data(history);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Providers
final dailyFortuneProvider =
    StateNotifierProvider<DailyFortuneNotifier, FortuneState>((ref) {
  final apiService = ref.watch(fortuneApiServiceProvider);
  return DailyFortuneNotifier(apiService, ref);
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

// Validation Exception (removed - already defined in exceptions.dart)

// Fortune Generation Params
class FortuneGenerationParams {
  final String fortuneType;
  final Map<String, dynamic> userInfo;

  FortuneGenerationParams({
    required this.fortuneType,
    required this.userInfo,
  });
}

// Fortune Generation Provider
final fortuneGenerationProvider = FutureProvider.family<Fortune, FortuneGenerationParams>((ref, params) async {
  final apiService = ref.watch(fortuneApiServiceProvider);
  final user = ref.watch(userProvider).value;
  
  if (user == null) {
    throw UnauthorizedException('로그인이 필요합니다');
  }

  return await apiService.getFortune(
    userId: user.id,
    fortuneType: params.fortuneType,
    params: params.userInfo,
  );
});