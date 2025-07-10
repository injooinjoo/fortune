import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/token.dart';
import '../../data/services/token_api_service.dart';
import '../../core/errors/exceptions.dart';
import 'auth_provider.dart';

// Token State
class TokenState {
  final TokenBalance? balance;
  final bool isLoading;
  final String? error;
  final List<TokenPackage> packages;
  final List<TokenTransaction> history;
  final UnlimitedSubscription? subscription;
  final Map<String, int> consumptionRates;
  final bool isConsumingToken;

  const TokenState({
    this.balance,
    this.isLoading = false,
    this.error,
    this.packages = const [],
    this.history = const [],
    this.subscription,
    Map<String, int>? consumptionRates,
    this.isConsumingToken = false,
  }) : consumptionRates = consumptionRates ?? _defaultConsumptionRates;
  
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
    
    // Medium complexity (2 tokens)
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
    
    // Complex fortunes (3 tokens)
    'saju': 3,
    'traditional-saju': 3,
    'saju-psychology': 3,
    'tojeong': 3,
    'past-life': 3,
    'destiny': 3,
    'marriage': 3,
    'couple-match': 3,
    'chemistry': 3,
    
    // Premium fortunes (5 tokens)
    'startup': 5,
    'business': 5,
    'lucky-investment': 5,
    'lucky-realestate': 5,
    'celebrity-match': 5,
    'network-report': 5,
    'five-blessings': 5,
  };

  TokenState copyWith({
    TokenBalance? balance,
    bool? isLoading,
    String? error,
    List<TokenPackage>? packages,
    List<TokenTransaction>? history,
    UnlimitedSubscription? subscription,
    Map<String, int>? consumptionRates,
    bool? isConsumingToken,
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
    );
  }

  bool get hasUnlimitedAccess => 
      balance?.hasUnlimitedAccess == true || subscription?.isActive == true;

  bool canConsumeTokens(int amount) {
    if (hasUnlimitedAccess) return true;
    return (balance?.remainingTokens ?? 0) >= amount;
  }

  int getTokensForFortuneType(String fortuneType) {
    return consumptionRates[fortuneType] ?? 1;
  }
}

// Token Notifier
class TokenNotifier extends StateNotifier<TokenState> {
  final TokenApiService _apiService;
  final Ref ref;

  TokenNotifier(this._apiService, this.ref) : super(const TokenState()) {
    loadTokenData();
  }

  // 토큰 데이터 로드 (잔액, 구독 정보 등)
  Future<void> loadTokenData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw UnauthorizedException('로그인이 필요합니다');
      }

      // 병렬로 데이터 로드
      final results = await Future.wait([
        _apiService.getTokenBalance(userId: user.id),
        _apiService.getSubscription(userId: user.id),
        _apiService.getTokenConsumptionRates(),
      ]);

      state = state.copyWith(
        balance: results[0] as TokenBalance,
        subscription: results[1] as UnlimitedSubscription?,
        consumptionRates: results[2] as Map<String, int>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 토큰 소비
  Future<bool> consumeTokens({
    required String fortuneType,
    required int amount,
    String? referenceId,
  }) async {
    // 무제한 이용권이 있으면 토큰 소비 안함
    if (state.hasUnlimitedAccess) {
      return true;
    }

    // 토큰 부족 체크
    if (!state.canConsumeTokens(amount)) {
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
            remainingTokens: state.balance!.remainingTokens - amount,
            usedTokens: state.balance!.usedTokens + amount,
          ),
        );
      }

      // API 호출
      final newBalance = await _apiService.consumeTokens(
        userId: user.id,
        fortuneType: fortuneType,
        amount: amount,
        referenceId: referenceId,
      );

      state = state.copyWith(
        balance: newBalance,
        isConsumingToken: false,
      );

      return true;
    } catch (e) {
      // 실패 시 롤백
      await loadTokenData();
      
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
        offset: offset,
      );

      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // 토큰 구매
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

      // 구매 후 잔액 갱신
      await loadTokenData();

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
        isLoading: false,
      );

      return true;
    } catch (e) {
      if (e is AlreadyClaimedException) {
        state = state.copyWith(
          isLoading: false,
          error: 'ALREADY_CLAIMED',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
      return false;
    }
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