import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/token.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/token_api_service.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/soul_rates.dart';
import '../../core/utils/logger.dart';
import 'providers.dart';

// Token State (토큰 시스템)
// 모든 운세가 토큰을 소비합니다. 구독 = 매월 토큰 자동 충전
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
    this.consumptionRates = const {},
    this.isConsumingToken = false,
    this.userProfile,
  });

  TokenState copyWith({
    TokenBalance? balance,
    bool? isLoading,
    String? error,
    List<TokenPackage>? packages,
    List<TokenTransaction>? history,
    UnlimitedSubscription? subscription,
    Map<String, int>? consumptionRates,
    bool? isConsumingToken,
    UserProfile? userProfile,
  }) {
    return TokenState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      packages: packages ?? this.packages,
      history: history ?? this.history,
      subscription: subscription ?? this.subscription,
      consumptionRates: consumptionRates ?? this.consumptionRates,
      isConsumingToken: isConsumingToken ?? this.isConsumingToken,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  /// 구독 활성화 여부 (구독 = 매월 토큰 자동 충전)
  bool get hasActiveSubscription => subscription?.isActive == true;

  /// 테스트 계정 무제한 토큰 (개발용)
  bool get hasUnlimitedTokens {
    if (userProfile == null) return false;
    return userProfile!.hasUnlimitedTokens ||
        (userProfile!.isTestAccount && userProfile!.isPremiumActive);
  }

  /// 토큰 소비 가능 여부 (단순화: 테스트 계정 또는 잔액 체크)
  bool canConsumeTokens(int amount) {
    if (hasUnlimitedTokens) return true;
    return (balance?.remainingTokens ?? 0) >= amount;
  }

  /// 운세 타입에 필요한 토큰
  int getTokensForFortuneType(String fortuneType) {
    return SoulRates.getTokenCost(fortuneType);
  }

  /// 현재 사용 가능한 토큰
  int get currentTokens {
    if (hasUnlimitedTokens) return 999999;
    return balance?.remainingTokens ?? 0;
  }

  /// 전체 잔액
  int get totalBalance => balance?.remainingTokens ?? 0;
}

// Token Notifier
class TokenNotifier extends StateNotifier<TokenState> {
  final TokenApiService _apiService;
  final Ref ref;
  bool _isAuthSyncInProgress = false;

  TokenNotifier(this._apiService, this.ref) : super(const TokenState()) {
    _setupAuthStateListener();
    _initializeTokenData();
  }

  void _setupAuthStateListener() {
    ref.listen<AsyncValue<AuthState?>>(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState == null) return;
        _handleAuthStateChanged(authState);
      });
    });
  }

  Future<void> _handleAuthStateChanged(AuthState authState) async {
    final hasSession = authState.session?.user != null;

    if (authState.event == AuthChangeEvent.signedOut || !hasSession) {
      state = const TokenState();
      return;
    }

    final shouldSyncTokenData = authState.event == AuthChangeEvent.signedIn ||
        authState.event == AuthChangeEvent.initialSession ||
        authState.event == AuthChangeEvent.tokenRefreshed;

    if (!shouldSyncTokenData || _isAuthSyncInProgress || state.isLoading) {
      return;
    }

    _isAuthSyncInProgress = true;
    try {
      ref.invalidate(userProvider);
      await loadTokenData();
    } finally {
      _isAuthSyncInProgress = false;
    }
  }

  Future<void> _initializeTokenData() async {
    await Future.delayed(Duration.zero);

    for (int i = 0; i < 5; i++) {
      final user = ref.read(userProvider).value;
      if (user != null) {
        Logger.info(
            '🔄 [TokenNotifier] User ready, loading token data (attempt ${i + 1})');
        await loadTokenData();
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    Logger.warning('⚠️ [TokenNotifier] User not available after 5 retries');
    state = state.copyWith(isLoading: false, error: 'User not authenticated');
  }

  /// 토큰 데이터 로드
  Future<void> loadTokenData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw const UnauthorizedException('로그인이 필요합니다');
      }

      Logger.info('🔍 [TokenNotifier] Loading token data for user: ${user.id}');

      final userProfile = await ref.read(userProfileProvider.future);

      final results = await Future.wait([
        _apiService.getTokenBalance(userId: user.id),
        _apiService.getSubscription(userId: user.id),
        _apiService.getTokenConsumptionRates(),
      ]);

      final balance = results[0] as TokenBalance;
      final subscription = results[1] as UnlimitedSubscription?;

      state = state.copyWith(
        balance: balance,
        subscription: subscription,
        consumptionRates: results[2] as Map<String, int>,
        userProfile: userProfile,
        isLoading: false,
      );

      Logger.info(
          '✅ [TokenNotifier] Token data loaded: balance=${balance.remainingTokens}, subscription=${subscription?.isActive}');
    } catch (e, stackTrace) {
      Logger.error(
          '❌ [TokenNotifier] Failed to load token data', e, stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 토큰 소비 (모든 운세)
  Future<bool> consumeTokens({
    required String fortuneType,
    int? amount,
    String? referenceId,
  }) async {
    // 테스트 계정 확인
    final userProfile = await ref.read(userProfileProvider.future);
    if (userProfile != null && userProfile.hasUnlimitedTokens) {
      return true;
    }

    // 토큰 비용 계산
    final tokenCost = amount ?? SoulRates.getTokenCost(fortuneType);

    // 토큰 부족 체크
    if (!state.canConsumeTokens(tokenCost)) {
      state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
      return false;
    }

    state = state.copyWith(isConsumingToken: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw const UnauthorizedException('로그인이 필요합니다');
      }

      // 낙관적 업데이트: 잔액 감소
      if (state.balance != null) {
        state = state.copyWith(
          balance: state.balance!.copyWith(
            remainingTokens: state.balance!.remainingTokens - tokenCost,
            usedTokens: state.balance!.usedTokens + tokenCost,
          ),
        );
      }

      // API 호출
      final newBalance = await _apiService.consumeTokens(
        userId: user.id,
        fortuneType: fortuneType,
        amount: tokenCost,
        referenceId: referenceId,
      );

      state = state.copyWith(
        balance: newBalance,
        isConsumingToken: false,
      );

      // 통계 추적
      try {
        final statisticsService = ref.read(userStatisticsServiceProvider);
        await statisticsService.updateTokenUsage(user.id, tokenCost, 0);
      } catch (e) {
        // 통계 추적 실패는 무시
      }

      return true;
    } catch (e) {
      await loadTokenData(); // 실패 시 롤백

      if (e is InsufficientTokensException) {
        state = state.copyWith(
          isConsumingToken: false,
          error: 'INSUFFICIENT_TOKENS',
        );
        return false;
      }

      state = state.copyWith(
        isConsumingToken: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// 토큰 확인 및 소비 (호환성)
  Future<bool> checkAndConsumeTokens(int amount, String fortuneType) async {
    return consumeTokens(fortuneType: fortuneType, amount: amount);
  }

  /// 운세 접근 가능 여부 확인
  bool canAccessFortune(String fortuneType) {
    if (state.hasUnlimitedTokens) return true;
    final cost = SoulRates.getTokenCost(fortuneType);
    return state.canConsumeTokens(cost);
  }

  /// 프리미엄 운세인지 확인 (모든 운세가 프리미엄)
  bool isPremiumFortune(String fortuneType) {
    return true; // 모든 운세가 토큰 소비
  }

  /// 출석체크 토큰 받기
  Future<bool> claimDailyTokens() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw const UnauthorizedException('로그인이 필요합니다');
      }

      final newBalance = await _apiService.claimDailyTokens(userId: user.id);

      state = state.copyWith(
        balance: newBalance,
        isLoading: false,
      );

      return true;
    } catch (e) {
      if (e is AlreadyClaimedException) {
        state = state.copyWith(isLoading: false, error: 'ALREADY_CLAIMED');
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return false;
    }
  }

  /// 토큰 패키지 로드
  Future<void> loadTokenPackages() async {
    try {
      final packages = await _apiService.getTokenPackages();
      state = state.copyWith(packages: packages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 토큰 거래 내역 로드
  Future<void> loadTokenHistory({int? limit, int? offset}) async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw const UnauthorizedException('로그인이 필요합니다');
      }

      final history = await _apiService.getTokenHistory(
        userId: user.id,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 토큰 구매
  Future<Map<String, dynamic>?> purchaseTokens({
    required String packageId,
    required String paymentMethodId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.purchaseTokens(
        packageId: packageId,
        paymentMethodId: paymentMethodId,
      );

      await loadTokenData();
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// 프로필 완성 보너스 청구
  Future<Map<String, dynamic>> claimProfileCompletionBonus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw const UnauthorizedException('로그인이 필요합니다');
      }

      final result =
          await _apiService.claimProfileCompletionBonus(userId: user.id);

      if (result['bonusGranted'] == true && result['balance'] != null) {
        state = state.copyWith(
          balance: result['balance'] as TokenBalance,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {
        'success': false,
        'bonusGranted': false,
        'message': e.toString(),
      };
    }
  }

  /// 잔액 새로고침
  Future<void> refreshBalance() async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      final balance = await _apiService.getTokenBalance(userId: user.id);
      state = state.copyWith(balance: balance);
    } catch (e, stackTrace) {
      debugPrint('Token balance refresh failed: $e');
      debugPrint('$stackTrace');
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ===== 레거시 호환 메서드 (향후 제거 예정) =====

  /// 영혼 획득 - 더 이상 사용하지 않음
  @Deprecated('모든 운세가 토큰 소비형입니다')
  Future<bool> earnSouls({
    required String fortuneType,
    String? referenceId,
  }) async {
    return true; // 획득형 운세 없음
  }

  /// 광고 보상 - 더 이상 사용하지 않음
  @Deprecated('광고 시스템이 제거되었습니다')
  Future<bool> rewardTokensForAd({
    required String fortuneType,
    int rewardAmount = 1,
  }) async {
    return true;
  }

  /// 영혼 처리 - 모든 운세가 소비형
  Future<bool> processSoulForFortune(String fortuneType) async {
    return consumeTokens(fortuneType: fortuneType);
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

/// 테스트 계정 무제한 토큰 여부 (개발용)
final hasUnlimitedTokensProvider = Provider<bool>((ref) {
  return ref.watch(tokenProvider).hasUnlimitedTokens;
});

final tokenPackagesProvider = Provider<List<TokenPackage>>((ref) {
  return ref.watch(tokenProvider).packages;
});

final canConsumeTokensProvider = Provider.family<bool, int>((ref, amount) {
  return ref.watch(tokenProvider).canConsumeTokens(amount);
});

final tokenConsumptionRateProvider =
    Provider.family<int, String>((ref, fortuneType) {
  return ref.watch(tokenProvider).getTokensForFortuneType(fortuneType);
});

final tokenHistoryProvider =
    FutureProvider<List<TokenTransaction>>((ref) async {
  final tokenNotifier = ref.read(tokenProvider.notifier);
  await tokenNotifier.loadTokenHistory();
  return ref.watch(tokenProvider).history;
});

/// 현재 사용 가능한 토큰
final currentTokensProvider = Provider<int>((ref) {
  return ref.watch(tokenProvider).currentTokens;
});

/// 구독 활성화 여부 (구독 = 매월 토큰 자동 충전)
final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  return ref.watch(tokenProvider).hasActiveSubscription;
});
