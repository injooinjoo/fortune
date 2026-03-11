import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/soul_rates.dart';
import '../../core/utils/request_audit_tracker.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/token_api_service.dart';
import '../../domain/entities/token.dart';
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

  bool get hasActiveSubscription => true;

  bool get hasUnlimitedTokens => true;

  bool canConsumeTokens(int amount) => true;

  int getTokensForFortuneType(String fortuneType) {
    return SoulRates.getTokenCost(fortuneType);
  }

  int get currentTokens => 999999;

  int get totalBalance => balance?.remainingTokens ?? 999999;
}

class TokenNotifier extends StateNotifier<TokenState> {
  final Ref ref;
  bool _isAuthSyncInProgress = false;
  Future<void>? _loadTokenDataFuture;
  Future<List<TokenTransaction>>? _loadTokenHistoryFuture;
  String? _lastLoadedUserId;
  DateTime? _lastLoadedAt;

  static const Duration _tokenRefreshStaleThreshold = Duration(minutes: 5);

  TokenNotifier(TokenApiService _, this.ref) : super(const TokenState()) {
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
          force: state.balance == null || state.userProfile == null,
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
        state.userProfile == null ||
        _lastLoadedUserId != userId ||
        _isTokenStateStale();
  }

  bool _hasLoadedStateFor(String userId) {
    return state.balance != null &&
        state.userProfile != null &&
        _lastLoadedUserId == userId &&
        !_isTokenStateStale();
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
    final currentUserId = _resolveCurrentUser()?.id ?? 'guest-unlimited';

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
      final userProfile =
          await ref.read(userProfileNotifierProvider.notifier).ensureLoaded(
                force: force,
                trigger: 'token.$trigger.profile',
              );
      final userId = user?.id ?? 'guest-unlimited';
      final balance = TokenBalance(
        userId: userId,
        totalTokens: 999999,
        usedTokens: 0,
        remainingTokens: 999999,
        lastUpdated: DateTime.now(),
        hasUnlimitedAccess: true,
      );
      final subscription = user == null
          ? null
          : UnlimitedSubscription(
              id: 'free-unlimited',
              userId: user.id,
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(days: 3650)),
              status: 'active',
              plan: 'unlimited',
              price: 0,
              currency: 'KRW',
            );

      state = state.copyWith(
        balance: balance,
        subscription: subscription,
        consumptionRates: const {},
        userProfile: userProfile,
        isLoading: false,
      );
      _lastLoadedUserId = userId;
      _lastLoadedAt = DateTime.now();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> consumeTokens({
    required String fortuneType,
    int? amount,
    String? referenceId,
  }) async {
    final tokenCost = amount ?? SoulRates.getTokenCost(fortuneType);
    final currentBalance = state.balance ??
        TokenBalance(
          userId: state.userProfile?.userId ?? 'guest-unlimited',
          totalTokens: 999999,
          usedTokens: 0,
          remainingTokens: 999999,
          lastUpdated: DateTime.now(),
          hasUnlimitedAccess: true,
        );
    state = state.copyWith(
      balance: currentBalance.copyWith(
        totalTokens: 999999,
        remainingTokens: 999999,
        usedTokens: tokenCost > 0
            ? currentBalance.usedTokens + tokenCost
            : currentBalance.usedTokens,
        lastUpdated: DateTime.now(),
        hasUnlimitedAccess: true,
      ),
      isConsumingToken: false,
      error: null,
    );
    return true;
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
    return true;
  }

  Future<bool> claimDailyTokens() async {
    state = state.copyWith(isLoading: false, error: null);
    return true;
  }

  Future<void> loadTokenPackages() async {
    state = state.copyWith(packages: const [], error: null);
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
    const history = <TokenTransaction>[];
    state = state.copyWith(history: history, error: null);
    return history;
  }

  Future<Map<String, dynamic>?> purchaseTokens({
    required String packageId,
    required String paymentMethodId,
  }) async {
    state = state.copyWith(isLoading: false, error: null);
    return {
      'success': true,
      'message': 'Token purchases are disabled because access is unlimited.',
      'packageId': packageId,
      'paymentMethodId': paymentMethodId,
    };
  }

  Future<Map<String, dynamic>> claimProfileCompletionBonus() async {
    state = state.copyWith(isLoading: false, error: null);
    return {
      'success': true,
      'bonusGranted': false,
      'bonusAmount': 0,
      'message': 'Unlimited access enabled',
    };
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
