import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/token.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/token_api_service.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/soul_rates.dart';
import '../../core/services/test_account_service.dart';
import 'auth_provider.dart';
import 'providers.dart';
import 'soul_animation_provider.dart';

// Token State
// TODO: Phase 2 - Rename to SoulState and update all references
// 영혼 시스템으로 전환 예정 - 현재는 하위 호환성을 위해 Token 명칭 유지
class TokenState {
  final TokenBalance? balance;
  final bool isLoading;
  final String? error;
  final List<TokenPackage> packages;
  final List<TokenTransaction> history;
  final UnlimitedSubscription? subscription;
  final Map<String, int> consumptionRates;
  final bool isConsumingToken;
  final UserProfile? userProfile;

  const TokenState({
    this.balance,
    this.isLoading = false,
    this.error,
    this.packages = const [],
    this.history = const [],
    this.subscription,
    Map<String, int>? consumptionRates,
    this.isConsumingToken = false,
    this.userProfile}) : consumptionRates = consumptionRates ?? _defaultConsumptionRates;
  
  static const Map<String, int> _defaultConsumptionRates = {
    // Simple fortunes (1 token)
    'daily': 1,
    'today': 1,
    'tomorrow': 1,
    'lucky-color': 1,
    'lucky-number': 1,
    'lucky-food': 1,
    'lucky-outfit': 1,
    'birthstone': 1,
    'blood-type': 1,
    'zodiac': 1,
    'zodiac-animal': 1,
    'fortune-cookie': 1,
    
    // Medium complexity (2 tokens,
    'love': 2,
    'career': 2,
    'wealth': 2,
    'health': 2,
    'compatibility': 2,
    'tarot': 2,
    'dream': 2,
    'biorhythm': 2,
    'mbti': 2,
    'hourly': 2,
    'weekly': 2,
    'monthly': 2,
    
    // Complex fortunes (3 tokens,
    'saju': 3,
    'traditional-saju': 3,
    'saju-psychology': 3,
    'tojeong': 3,
    'past-life': 3,
    'destiny': 3,
    'marriage': 3,
    'couple-match': 3,
    'chemistry': 3,
    
    // Premium fortunes (5 tokens,
    'startup': 5,
    'business': 5,
    'lucky-investment': 5,
    'lucky-realestate': 5,
    'celebrity-match': 5,
    'network-report': 5,
    'five-blessings': 5};

  TokenState copyWith({
    TokenBalance? balance,
    bool? isLoading,
    String? error,
    List<TokenPackage>? packages,
    List<TokenTransaction>? history,
    UnlimitedSubscription? subscription,
    Map<String, int>? consumptionRates,
    bool? isConsumingToken,
    UserProfile? userProfile}) {
    return TokenState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      packages: packages ?? this.packages,
      history: history ?? this.history,
      subscription: subscription ?? this.subscription,
      consumptionRates: consumptionRates ?? this.consumptionRates,
      isConsumingToken: isConsumingToken ?? this.isConsumingToken,
      userProfile: userProfile ?? this.userProfile);
  }

  bool get hasUnlimitedAccess => 
      balance?.hasUnlimitedAccess == true || subscription?.isActive == true || hasUnlimitedTokens;

  bool canConsumeTokens(int amount) {
    if (hasUnlimitedAccess) return true;
    return (balance?.remainingTokens ?? 0) >= amount;
  }
  
  // Check if user has unlimited tokens (for test accounts,
  bool get hasUnlimitedTokens {
    if (userProfile == null) return false;
    return userProfile!.hasUnlimitedTokens || 
           (userProfile!.isTestAccount && userProfile!.isPremiumActive);
  }

  int getTokensForFortuneType(String fortuneType) {
    return consumptionRates[fortuneType] ?? 1;
  }

  // Getter for current tokens (compatibility,
  int get currentTokens => balance?.remainingTokens ?? 0;
}

// Token Notifier
class TokenNotifier extends StateNotifier<TokenState> {
  final TokenApiService _apiService;
  final Ref ref;

  TokenNotifier(this._apiService, this.ref) : super(const TokenState()) {
    loadTokenData();
  }

  // 토큰 데이터 로드 (잔액, 구독 정보 등,
  Future<void> loadTokenData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      // Load user profile
      final userProfile = await ref.read(userProfileProvider.future);

      // 병렬로 데이터 로드
      final results = await Future.wait([
        _apiService.getTokenBalance(userId: user.id),
        _apiService.getSubscription(userId: user.id),
        _apiService.getTokenConsumptionRates()]);

      state = state.copyWith(
        balance: results[0] as TokenBalance,
        subscription: results[1] as UnlimitedSubscription?,
        consumptionRates: results[2] as Map<String, int>,
        userProfile: userProfile,
        isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
    }
  }

  // 토큰 확인 및 소비 (simplified method for compatibility,
  Future<bool> checkAndConsumeTokens(int amount, String fortuneType) async {
    return consumeTokens(
      fortuneType: fortuneType,
      amount: amount);
  }

  // 토큰 소비 (프리미엄 운세를 볼 때,
  Future<bool> consumeTokens({
    required String fortuneType,
    required int amount,
    String? referenceId}) async {
    // 테스트 계정 확인
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile != null && userProfile.hasUnlimitedTokens) {
      return true;
    }
    
    // 무제한 이용권이 있으면 토큰 소비 안함
    if (state.hasUnlimitedAccess) {
      return true;
    }

    // 운세 타입에 따른 영혼 소비량 확인 (음수,
    final soulAmount = SoulRates.getSoulAmount(fortuneType);
    
    // 획득형 운세는 이 메서드를 사용하지 않음
    if (soulAmount >= 0) {
      return earnSouls(fortuneType: fortuneType, referenceId: referenceId);
    }
    
    // 실제 소비량 (양수로 변환,
    final actualAmount = -soulAmount;

    // 토큰 부족 체크
    if (!state.canConsumeTokens(actualAmount)) {
      state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
      return false;
    }

    state = state.copyWith(isConsumingToken: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      // 낙관적 업데이트
      if (state.balance != null) {
        state = state.copyWith(
          balance: state.balance!.copyWith(
            remainingTokens: state.balance!.remainingTokens - actualAmount,
            usedTokens: state.balance!.usedTokens + actualAmount));
      }

      // API 호출
      final newBalance = await _apiService.consumeTokens(
        userId: user.id,
        fortuneType: fortuneType,
        amount: actualAmount,
        referenceId: referenceId);

      state = state.copyWith(
        balance: newBalance,
        isConsumingToken: false);

      // Track token usage in statistics
      try {
        final statisticsService = ref.read(userStatisticsServiceProvider);
        await statisticsService.updateTokenUsage(user.id, actualAmount, 0);
      } catch (e) {
        // Don't throw - statistics tracking is not critical
        // Logger is already imported through providers.dart
      }

      return true;
    } catch (e) {
      // 실패 시 롤백
      await loadTokenData();
      
      if (e is InsufficientTokensException) {
        state = state.copyWith(
          isConsumingToken: false,
          error: 'INSUFFICIENT_TOKENS');
        return false;
      }

      state = state.copyWith(
        isConsumingToken: false,
        error: e.toString());
      return false;
    }
  }

  // 토큰 패키지 목록 로드
  Future<void> loadTokenPackages() async {
    try {
      final packages = await _apiService.getTokenPackages();
      state = state.copyWith(packages: packages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 토큰 거래 내역 로드
  Future<void> loadTokenHistory({int? limit, int? offset}) async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      final history = await _apiService.getTokenHistory(
        userId: user.id,
        limit: limit,
        offset: offset
      );

      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 토큰 구매
  Future<Map<String, dynamic>?> purchaseTokens({
    required String packageId,
    required String paymentMethodId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.purchaseTokens(
        packageId: packageId,
        paymentMethodId: paymentMethodId
      );

      // 구매 후 잔액 갱신
      await loadTokenData();

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
      return null;
    }
  }

  // 일일 무료 토큰 받기
  Future<bool> claimDailyTokens() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      final newBalance = await _apiService.claimDailyTokens(userId: user.id);
      
      state = state.copyWith(
        balance: newBalance,
        isLoading: false);

      return true;
    } catch (e) {
      if (e is AlreadyClaimedException) {
        state = state.copyWith(
          isLoading: false,
          error: 'ALREADY_CLAIMED');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString());
      }
      return false;
    }
  }

  // 영혼 획득 (무료 운세를 볼 때,
  Future<bool> earnSouls({
    required String fortuneType,
    String? referenceId}) async {
    // 운세 타입에 따른 영혼 획득량 확인
    final soulAmount = SoulRates.getSoulAmount(fortuneType);
    
    // 소비형 운세는 이 메서드를 사용하지 않음
    if (soulAmount <= 0) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      // 낙관적 업데이트
      if (state.balance != null) {
        state = state.copyWith(
          balance: state.balance!.copyWith(
            remainingTokens: state.balance!.remainingTokens + soulAmount,
            totalTokens: state.balance!.totalTokens + soulAmount));
      }

      // API 호출 (기존 rewardTokensForAdView 사용,
      final newBalance = await _apiService.rewardTokensForAdView(
        userId: user.id,
        fortuneType: fortuneType,
        rewardAmount: soulAmount
      );

      state = state.copyWith(
        balance: newBalance,
        isLoading: false);

      // Track soul earnings in statistics
      try {
        final statisticsService = ref.read(userStatisticsServiceProvider);
        await statisticsService.updateTokenUsage(user.id, 0, soulAmount);
      } catch (e) {
        // Don't throw - statistics tracking is not critical
      }

      return true;
    } catch (e) {
      // 실패 시 롤백
      await loadTokenData();
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
      return false;
    }
  }

  // 광고 시청 후 토큰 보상 (레거시 - 향후 제거 예정,
  Future<bool> rewardTokensForAd({
    required String fortuneType,
    int rewardAmount = 1}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      // 낙관적 업데이트
      if (state.balance != null) {
        state = state.copyWith(
          balance: state.balance!.copyWith(
            remainingTokens: state.balance!.remainingTokens + rewardAmount,
            totalTokens: state.balance!.totalTokens + rewardAmount));
      }

      // API 호출
      final newBalance = await _apiService.rewardTokensForAdView(
        userId: user.id,
        fortuneType: fortuneType,
        rewardAmount: rewardAmount
      );

      state = state.copyWith(
        balance: newBalance,
        isLoading: false);

      // Track token earnings in statistics
      try {
        final statisticsService = ref.read(userStatisticsServiceProvider);
        await statisticsService.updateTokenUsage(user.id, 0, rewardAmount);
      } catch (e) {
        // Don't throw - statistics tracking is not critical
      }

      return true;
    } catch (e) {
      // 실패 시 롤백
      await loadTokenData();
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString());
      return false;
    }
  }

  // 운세 타입에 따른 영혼 처리 (통합 메서드,
  Future<bool> processSoulForFortune(String fortuneType) async {
    final soulAmount = SoulRates.getSoulAmount(fortuneType);
    
    if (soulAmount > 0) {
      // 영혼 획득 (무료 운세,
      return earnSouls(fortuneType: fortuneType);
    } else if (soulAmount < 0) {
      // 영혼 소비 (프리미엄 운세,
      return consumeTokens(
        fortuneType: fortuneType,
        amount: -soulAmount);
    }
    
    // 변화 없음
    return true;
  }

  // 운세가 프리미엄인지 확인
  bool isPremiumFortune(String fortuneType) {
    return SoulRates.isPremiumFortune(fortuneType);
  }

  // 운세 실행에 필요한 영혼 확인
  bool canAccessFortune(String fortuneType) {
    // 테스트 계정 확인 (동기적으로 체크,
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null && userProfile.hasUnlimitedTokens) {
      return true;
    }
    
    // 무제한 이용권이 있으면 모든 운세 이용 가능
    if (state.hasUnlimitedAccess) {
      return true;
    }
    
    final soulAmount = SoulRates.getSoulAmount(fortuneType);
    
    // 무료 운세는 항상 이용 가능
    if (soulAmount >= 0) {
      return true;
    }
    
    // 프리미엄 운세는 영혼 확인
    return state.canConsumeTokens(-soulAmount);
  }

  // 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  // 토큰 잔액 새로고침
  Future<void> refreshBalance() async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      final balance = await _apiService.getTokenBalance(userId: user.id);
      state = state.copyWith(balance: balance);
    } catch (e) {
      // 조용히 실패
    }
  }
}

// Providers
final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>((ref) {
  final apiService = ref.watch(tokenApiServiceProvider);
  return TokenNotifier(apiService, ref);
});

// Alias for compatibility
final tokenServiceProvider = tokenProvider;

// Convenient providers
final tokenBalanceProvider = Provider<TokenBalance?>((ref) {
  return ref.watch(tokenProvider).balance;
});

final hasUnlimitedAccessProvider = Provider<bool>((ref) {
  return ref.watch(tokenProvider).hasUnlimitedAccess;
});

final tokenPackagesProvider = Provider<List<TokenPackage>>((ref) {
  return ref.watch(tokenProvider).packages;
});

final canConsumeTokensProvider = Provider.family<bool, int>((ref, amount) {
  return ref.watch(tokenProvider).canConsumeTokens(amount);
});

final tokenConsumptionRateProvider = Provider.family<int, String>((ref, fortuneType) {
  return ref.watch(tokenProvider).getTokensForFortuneType(fortuneType);
});

// Token history provider - 토큰 사용 내역 제공
final tokenHistoryProvider = FutureProvider<List<TokenTransaction>>((ref) async {
  final tokenNotifier = ref.read(tokenProvider.notifier);
  await tokenNotifier.loadTokenHistory();
  return ref.watch(tokenProvider).history;
});