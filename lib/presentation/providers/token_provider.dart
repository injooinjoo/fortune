import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/soul_rates.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/request_audit_tracker.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/token_api_service.dart';
import '../../domain/entities/token.dart';
import 'providers.dart';

// Token State (토큰 시스템)
// 모든 운세가 토큰을 소비합니다. 구독 = 매월 토큰 자동 충전
class TokenState {
  static const Object _unset = Object();

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
    Object? balance = _unset,
    bool? isLoading,
    Object? error = _unset,
    List<TokenPackage>? packages,
    List<TokenTransaction>? history,
    Object? subscription = _unset,
    Map<String, int>? consumptionRates,
    bool? isConsumingToken,
    Object? userProfile = _unset,
  }) {
    return TokenState(
      balance:
          identical(balance, _unset) ? this.balance : balance as TokenBalance?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      packages: packages ?? this.packages,
      history: history ?? this.history,
      subscription: identical(subscription, _unset)
          ? this.subscription
          : subscription as UnlimitedSubscription?,
      consumptionRates: consumptionRates ?? this.consumptionRates,
      isConsumingToken: isConsumingToken ?? this.isConsumingToken,
      userProfile: identical(userProfile, _unset)
          ? this.userProfile
          : userProfile as UserProfile?,
    );
  }

  bool get hasActiveSubscription =>
      subscription?.isActive == true || userProfile?.isPremiumActive == true;

  bool get hasUnlimitedTokens =>
      balance?.hasUnlimitedAccess == true ||
      userProfile?.hasUnlimitedTokens == true;

  bool canConsumeTokens(int amount) {
    if (amount <= 0) return true;
    if (hasUnlimitedTokens) return true;
    return currentTokens >= amount;
  }

  int getTokensForFortuneType(String fortuneType) {
    return consumptionRates[fortuneType] ?? SoulRates.getTokenCost(fortuneType);
  }

  int get currentTokens =>
      balance?.remainingTokens ?? userProfile?.tokenBalance ?? 0;

  int get totalBalance => currentTokens;
}

class TokenNotifier extends StateNotifier<TokenState> {
  final TokenApiService _apiService;
  final Ref ref;
  bool _isAuthSyncInProgress = false;
  Future<void>? _loadTokenDataFuture;
  Future<List<TokenTransaction>>? _loadTokenHistoryFuture;
  String? _lastLoadedUserId;
  DateTime? _lastLoadedAt;

  static const Duration _tokenRefreshStaleThreshold = Duration(minutes: 5);

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
    final user = authState.session?.user;
    final hasSession = user != null;

    if (authState.event == AuthChangeEvent.signedOut || !hasSession) {
      _loadTokenDataFuture = null;
      _loadTokenHistoryFuture = null;
      _lastLoadedUserId = null;
      _lastLoadedAt = null;
      state = const TokenState();
      return;
    }

    if (_isAuthSyncInProgress || state.isLoading) {
      return;
    }

    final eventName = authState.event.name;
    if (authState.event == AuthChangeEvent.signedIn ||
        authState.event == AuthChangeEvent.initialSession) {
      await _runAuthSync(
        () => ensureLoaded(
          force: _lastLoadedUserId != user.id || state.balance == null,
          trigger: 'auth.$eventName',
        ),
      );
      return;
    }

    if (authState.event == AuthChangeEvent.tokenRefreshed &&
        _shouldReloadForTokenRefresh(user.id)) {
      await _runAuthSync(
        () => ensureLoaded(
          force: state.balance == null,
          trigger: 'auth.$eventName',
        ),
      );
    }
  }

  Future<void> _initializeTokenData() async {
    await Future.delayed(Duration.zero);
    await ensureLoaded(trigger: 'bootstrap');
  }

  User? _resolveCurrentUser() {
    return ref.read(userProvider).value ??
        ref.read(supabaseClientProvider).auth.currentUser;
  }

  bool _shouldReloadForTokenRefresh(String userId) {
    return state.balance == null ||
        _lastLoadedUserId != userId ||
        _isTokenStateStale();
  }

  bool _hasLoadedStateFor(String userId) {
    return _lastLoadedUserId == userId && !_isTokenStateStale();
  }

  bool _isTokenStateStale() {
    if (_lastLoadedAt == null) return true;
    return DateTime.now().difference(_lastLoadedAt!) >
        _tokenRefreshStaleThreshold;
  }

  Future<void> _runAuthSync(Future<void> Function() action) async {
    if (_isAuthSyncInProgress) return;

    _isAuthSyncInProgress = true;
    try {
      await action();
    } finally {
      _isAuthSyncInProgress = false;
    }
  }

  Future<void> ensureLoaded({
    bool force = false,
    String trigger = 'manual',
  }) async {
    final currentUserId = _resolveCurrentUser()?.id ?? 'guest';

    if (!force &&
        _loadTokenDataFuture == null &&
        _hasLoadedStateFor(currentUserId)) {
      return;
    }

    if (_loadTokenDataFuture != null) {
      return _loadTokenDataFuture!;
    }

    final future = _performLoadTokenData(
      trigger: trigger,
      force: force,
    );
    _loadTokenDataFuture = future;

    try {
      await future;
    } finally {
      if (identical(_loadTokenDataFuture, future)) {
        _loadTokenDataFuture = null;
      }
    }
  }

  Future<void> loadTokenData({
    bool force = true,
    String trigger = 'manual',
  }) async {
    await ensureLoaded(force: force, trigger: trigger);
  }

  Future<void> _performLoadTokenData({
    required String trigger,
    required bool force,
  }) async {
    RequestAuditTracker.record(
      key: 'token.load',
      trigger: trigger,
      source: 'TokenNotifier',
    );
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _resolveCurrentUser();
      if (user == null) {
        state = const TokenState();
        _lastLoadedUserId = 'guest';
        _lastLoadedAt = DateTime.now();
        return;
      }

      final userProfile =
          await ref.read(userProfileNotifierProvider.notifier).ensureLoaded(
                force: force,
                trigger: 'token.$trigger.profile',
              );

      final results = await Future.wait<Object?>([
        _apiService.getTokenBalance(userId: user.id),
        _apiService.getSubscription(userId: user.id),
        _apiService.getTokenConsumptionRates(),
      ]);

      final balance =
          _applyTestAccountOverrides(results[0] as TokenBalance, userProfile);
      final subscription = results[1] as UnlimitedSubscription?;
      final consumptionRates = results[2] as Map<String, int>;

      state = state.copyWith(
        balance: balance,
        subscription: subscription,
        consumptionRates: consumptionRates,
        userProfile: userProfile,
        isLoading: false,
        error: null,
      );
      _lastLoadedUserId = user.id;
      _lastLoadedAt = DateTime.now();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  TokenBalance _applyTestAccountOverrides(
    TokenBalance balance,
    UserProfile? userProfile,
  ) {
    if (userProfile?.hasUnlimitedTokens == true) {
      return balance.copyWith(hasUnlimitedAccess: true);
    }
    return balance;
  }

  String _extractErrorMessage(Object error) {
    if (error is AppException) {
      return error.code ?? error.message;
    }
    return error.toString();
  }

  Future<bool> consumeTokens({
    required String fortuneType,
    int? amount,
    String? referenceId,
  }) async {
    final tokenCost = amount ?? SoulRates.getTokenCost(fortuneType);

    if (state.balance == null && !state.isLoading) {
      await ensureLoaded(force: true, trigger: 'consume.$fortuneType');
    }

    if (state.hasUnlimitedTokens) {
      return true;
    }

    final user = _resolveCurrentUser();
    if (user == null) {
      state = state.copyWith(error: 'UNAUTHORIZED');
      return false;
    }

    if (!state.canConsumeTokens(tokenCost)) {
      state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
      return false;
    }

    state = state.copyWith(isConsumingToken: true, error: null);

    try {
      final updatedBalance = await _apiService.consumeTokens(
        userId: user.id,
        fortuneType: fortuneType,
        amount: tokenCost,
        referenceId: referenceId,
      );

      state = state.copyWith(
        balance: _applyTestAccountOverrides(updatedBalance, state.userProfile),
        isConsumingToken: false,
        error: null,
      );
      _lastLoadedAt = DateTime.now();
      return true;
    } on InsufficientTokensException {
      state = state.copyWith(
        isConsumingToken: false,
        error: 'INSUFFICIENT_TOKENS',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isConsumingToken: false,
        error: _extractErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> checkAndConsumeTokens(int amount, String fortuneType) async {
    return consumeTokens(fortuneType: fortuneType, amount: amount);
  }

  bool canAccessFortune(String fortuneType) {
    if (state.hasUnlimitedTokens) return true;
    final cost = SoulRates.getTokenCost(fortuneType);
    return state.canConsumeTokens(cost);
  }

  bool isPremiumFortune(String fortuneType) {
    return SoulRates.isPremiumFortune(fortuneType);
  }

  Future<bool> claimDailyTokens() async {
    final user = _resolveCurrentUser();
    if (user == null) {
      state = state.copyWith(error: 'UNAUTHORIZED');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedBalance =
          await _apiService.claimDailyTokens(userId: user.id);
      state = state.copyWith(
        balance: _applyTestAccountOverrides(updatedBalance, state.userProfile),
        isLoading: false,
        error: null,
      );
      _lastLoadedAt = DateTime.now();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> loadTokenPackages() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final packages = await _apiService.getTokenPackages();
      state = state.copyWith(
        packages: packages,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  Future<List<TokenTransaction>> loadTokenHistory({
    int? limit,
    int? offset,
  }) async {
    if (_loadTokenHistoryFuture != null) {
      return _loadTokenHistoryFuture!;
    }

    final future = _performLoadTokenHistory(limit: limit, offset: offset);
    _loadTokenHistoryFuture = future;

    try {
      return await future;
    } finally {
      if (identical(_loadTokenHistoryFuture, future)) {
        _loadTokenHistoryFuture = null;
      }
    }
  }

  Future<List<TokenTransaction>> _performLoadTokenHistory({
    int? limit,
    int? offset,
  }) async {
    RequestAuditTracker.record(
      key: 'token.history.load',
      trigger: 'limit:${limit ?? 'default'}:offset:${offset ?? 0}',
      source: 'TokenNotifier',
    );

    final user = _resolveCurrentUser();
    if (user == null) {
      const history = <TokenTransaction>[];
      state = state.copyWith(history: history, error: null);
      return history;
    }

    try {
      final history = await _apiService.getTokenHistory(
        userId: user.id,
        limit: limit,
        offset: offset,
      );
      state = state.copyWith(history: history, error: null);
      return history;
    } catch (e) {
      state = state.copyWith(error: _extractErrorMessage(e));
      return const [];
    }
  }

  Future<Map<String, dynamic>?> purchaseTokens({
    required String packageId,
    required String paymentMethodId,
  }) async {
    final user = _resolveCurrentUser();
    if (user == null) {
      state = state.copyWith(error: 'UNAUTHORIZED');
      return {
        'success': false,
        'message': '로그인이 필요합니다.',
      };
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.purchaseTokens(
        packageId: packageId,
        paymentMethodId: paymentMethodId,
      );
      await ensureLoaded(force: true, trigger: 'purchaseTokens');
      state = state.copyWith(isLoading: false, error: null);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
      return {
        'success': false,
        'message': _extractErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> claimProfileCompletionBonus() async {
    final user = _resolveCurrentUser();
    if (user == null) {
      state = state.copyWith(error: 'UNAUTHORIZED');
      return {
        'success': false,
        'bonusGranted': false,
        'bonusAmount': 0,
        'message': '로그인이 필요합니다.',
      };
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result =
          await _apiService.claimProfileCompletionBonus(userId: user.id);
      final updatedBalance = result['balance'] as TokenBalance?;

      state = state.copyWith(
        balance: updatedBalance == null
            ? state.balance
            : _applyTestAccountOverrides(updatedBalance, state.userProfile),
        isLoading: false,
        error: null,
      );
      _lastLoadedAt = DateTime.now();
      return result;
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return {
        'success': false,
        'bonusGranted': false,
        'bonusAmount': 0,
        'message': errorMessage,
      };
    }
  }

  Future<void> refreshBalance() async {
    await ensureLoaded(force: true, trigger: 'refreshBalance');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @Deprecated('모든 운세가 토큰 소비형입니다')
  Future<bool> earnSouls({
    required String fortuneType,
    String? referenceId,
  }) async {
    return true;
  }

  @Deprecated('광고 시스템이 제거되었습니다')
  Future<bool> rewardTokensForAd({
    required String fortuneType,
    int rewardAmount = 1,
  }) async {
    return true;
  }

  Future<bool> processSoulForFortune(String fortuneType) async {
    return consumeTokens(fortuneType: fortuneType);
  }
}

final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>((ref) {
  final apiService = ref.watch(tokenApiServiceProvider);
  return TokenNotifier(apiService, ref);
});

final tokenServiceProvider = tokenProvider;

final tokenBalanceProvider = Provider<TokenBalance?>((ref) {
  return ref.watch(tokenProvider).balance;
});

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

final tokenHistoryStateProvider = Provider<List<TokenTransaction>>((ref) {
  return ref.watch(tokenProvider).history;
});

final currentTokensProvider = Provider<int>((ref) {
  return ref.watch(tokenProvider).currentTokens;
});

final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  return ref.watch(tokenProvider).hasActiveSubscription;
});
