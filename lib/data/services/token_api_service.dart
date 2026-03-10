import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/token.dart';
import '../../presentation/providers/providers.dart';

/// 캐시된 토큰 잔액 (비용 최적화)
class _CachedBalance {
  final TokenBalance balance;
  final DateTime timestamp;

  _CachedBalance(this.balance, this.timestamp);

  bool isExpired(Duration ttl) => DateTime.now().difference(timestamp) > ttl;
}

class TokenApiService {
  final ApiClient _apiClient;

  // 토큰 잔액 인메모리 캐시 (60초 TTL) - 비용 최적화
  static final Map<String, _CachedBalance> _balanceCache = {};
  static const Duration _cacheTTL = Duration(seconds: 60);

  TokenApiService(this._apiClient);

  /// 캐시 무효화 (토큰 소비/획득 후 호출)
  static void invalidateCache(String userId) {
    _balanceCache.remove(userId);
    Logger.debug('[TokenApiService] 캐시 무효화: $userId');
  }

  /// 전체 캐시 초기화
  static void clearCache() {
    _balanceCache.clear();
    Logger.debug('[TokenApiService] 전체 캐시 초기화');
  }

  // 토큰 잔액 조회 (캐싱 적용)
  Future<TokenBalance> getTokenBalance({required String userId}) async {
    // 캐시 확인
    final cached = _balanceCache[userId];
    if (cached != null && !cached.isExpired(_cacheTTL)) {
      Logger.debug(
          '[TokenApiService] 캐시 히트: $userId (${cached.balance.remainingTokens} tokens)');
      return cached.balance;
    }

    try {
      Logger.info('========== 🔍 토큰 잔액 조회 시작 ==========');
      Logger.info('userId: $userId');

      // ApiClient.get() returns the data directly, not a Response object
      final data = await _apiClient.get('/token-balance');

      Logger.info('========== ✅ 토큰 잔액 응답 ==========');
      Logger.info('data 타입: ${data.runtimeType}');
      Logger.info('data: $data');

      // Handle different response structures from backend
      // data is already the Map, not response.data
      final balance = data['balance'] ?? 0;
      final totalPurchased = data['totalPurchased'] ?? 0;
      final totalUsed = data['totalUsed'] ?? 0;
      final isUnlimited = data['isUnlimited'] ?? false;

      Logger.info(
          '파싱된 값: balance=$balance, totalPurchased=$totalPurchased, totalUsed=$totalUsed, isUnlimited=$isUnlimited');
      Logger.info('==========================================');

      final result = TokenBalance(
          userId: userId,
          totalTokens: totalPurchased,
          usedTokens: totalUsed,
          remainingTokens: balance,
          lastUpdated: DateTime.now(),
          hasUnlimitedAccess: isUnlimited);

      // 캐시에 저장
      _balanceCache[userId] = _CachedBalance(result, DateTime.now());
      Logger.debug(
          '[TokenApiService] 캐시 저장: $userId (${result.remainingTokens} tokens)');

      return result;
    } on DioException catch (e, stackTrace) {
      Logger.error('========== ❌ 토큰 잔액 조회 오류 ==========');
      Logger.error('statusCode: ${e.response?.statusCode}');
      Logger.error('response.data: ${e.response?.data}');
      Logger.error('error: $e');
      Logger.error('stackTrace: $stackTrace');
      Logger.error('==========================================');

      // Handle profile not found specifically
      if (e.response?.statusCode == 404 &&
          e.response?.data?['error'] == 'Profile not found') {
        // Return default token balance for users without profiles
        // This allows the app to continue functioning while profile is being created
        return TokenBalance(
            userId: userId,
            totalTokens: 0,
            usedTokens: 0,
            remainingTokens: 0,
            lastUpdated: DateTime.now(),
            hasUnlimitedAccess: false);
      }
      throw _handleDioError(e);
    }
  }

  // 토큰 소비 (프리미엄 운세용)
  Future<TokenBalance> consumeTokens(
      {required String userId,
      required String fortuneType,
      required int amount,
      String? referenceId}) async {
    try {
      // 새로운 soul-consume 엔드포인트 사용
      // ApiClient.post() returns the data directly
      final data = await _apiClient.post('/soul-consume',
          data: {'fortuneType': fortuneType, 'referenceId': null});

      final result = TokenBalance(
          userId: userId,
          totalTokens: data['balance']['totalTokens'],
          usedTokens: data['balance']['usedTokens'],
          remainingTokens: data['balance']['remainingTokens'],
          lastUpdated: DateTime.parse(data['balance']['lastUpdated']),
          hasUnlimitedAccess: data['balance']['hasUnlimitedAccess']);

      // 캐시 업데이트 (토큰 소비 후)
      _balanceCache[userId] = _CachedBalance(result, DateTime.now());

      return result;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data['code'] == 'INSUFFICIENT_TOKENS') {
        throw InsufficientTokensException(
            e.response?.data['message'] ?? '토큰가 부족합니다');
      }
      throw _handleDioError(e);
    }
  }

  // 토큰 패키지 목록 조회
  Future<List<TokenPackage>> getTokenPackages() async {
    try {
      final data = await _apiClient.get('/token-packages');

      return (data['packages'] as List)
          .map((json) => TokenPackage(
              id: json['id'],
              name: json['name'],
              tokens: json['tokens'],
              price: (json['price'] as num).toDouble(),
              originalPrice: json['originalPrice'] != null
                  ? (json['originalPrice'] as num).toDouble()
                  : null,
              currency: json['currency'] ?? 'KRW',
              badge: json['badge'],
              bonusTokens: json['bonusTokens'],
              description: json['description'],
              isPopular: json['isPopular']))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 토큰 구매
  Future<Map<String, dynamic>> purchaseTokens(
      {required String packageId, required String paymentMethodId}) async {
    try {
      final data = await _apiClient.post('/token-purchase',
          data: {'packageId': packageId, 'paymentMethodId': null});

      return data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 토큰 거래 내역 조회
  Future<List<TokenTransaction>> getTokenHistory(
      {required String userId, int? limit, int? offset}) async {
    try {
      final queryParams = {
        if (limit != null) 'limit': null,
        if (offset != null) 'offset': null
      };

      final data =
          await _apiClient.get('/token-history', queryParameters: queryParams);

      // Handle the response format from the backend
      final transactions = data['transactions'] as List? ?? [];

      return transactions
          .map((json) => TokenTransaction(
              id: json['id'],
              userId: userId,
              amount: json['amount'],
              type: json['type'],
              description: json['description'],
              referenceId: json['referenceId'],
              createdAt: DateTime.parse(json['createdAt']),
              balanceAfter: json['balanceAfter']))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 운세별 토큰 소비량 조회
  Future<Map<String, int>> getTokenConsumptionRates() async {
    try {
      final data = await _apiClient.get('/token-consumption-rates');

      return Map<String, int>.from(data['rates'] ?? {});
    } catch (e) {
      // 모든 에러에서 기본값 반환 (optional endpoint)
      // ApiClient가 DioException을 NotFoundException 등으로 변환하므로
      // 모든 예외를 catch해야 함
      Logger.debug('Token consumption rates 조회 실패, 기본값 사용: $e');
      return _defaultConsumptionRates;
    }
  }

  // 기본 토큰 소비량 (Edge Function 미구현 시 사용)
  static const Map<String, int> _defaultConsumptionRates = {
    'daily': 0,
    'time': 0,
    'dream': 1,
    'tarot': 1,
    'compatibility': 2,
    'love': 1,
    'career': 1,
    'health': 1,
    'mbti': 1,
    'talent': 2,
    'traditional-saju': 3,
    'face-reading': 2,
    'investment': 2,
    'moving': 2,
  };

  // 구독 정보 조회
  Future<UnlimitedSubscription?> getSubscription(
      {required String userId}) async {
    try {
      final data = await _apiClient.get('/subscription-status');

      // subscription-status Edge Function 응답 형식:
      // { active: bool, expiresAt?: string, productId?: string, autoRenewing?: bool }
      final isActive = data['active'] == true;

      if (!isActive) {
        return null;
      }

      // 활성 구독이 있는 경우
      final expiresAt = data['expiresAt'];
      final productId = data['productId'];

      return UnlimitedSubscription(
          id: productId ?? 'subscription',
          userId: userId,
          startDate: DateTime.now(), // 시작일은 정확히 알 수 없음
          endDate: expiresAt != null
              ? DateTime.parse(expiresAt)
              : DateTime.now().add(const Duration(days: 30)),
          status: 'active',
          plan: productId ?? 'premium',
          price: 0, // 가격 정보는 별도 조회 필요
          currency: 'KRW');
    } on DioException catch (e) {
      // Handle CORS/network errors gracefully
      if (e.type == DioExceptionType.connectionError ||
          e.response?.statusCode == 0) {
        // Return null subscription for network errors
        return null;
      }
      // 404는 구독 없음으로 처리 (정상)
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioError(e);
    }
  }

  // 일일 무료 토큰 받기
  Future<TokenBalance> claimDailyTokens({required String userId}) async {
    try {
      final data = await _apiClient.post('/token-daily-claim');

      final result = TokenBalance(
          userId: userId,
          totalTokens: data['balance']['totalTokens'],
          usedTokens: data['balance']['usedTokens'],
          remainingTokens: data['balance']['remainingTokens'],
          lastUpdated: DateTime.parse(data['balance']['lastUpdated']),
          hasUnlimitedAccess: data['balance']['hasUnlimitedAccess']);

      // 캐시 업데이트 (토큰 획득 후)
      _balanceCache[userId] = _CachedBalance(result, DateTime.now());

      return result;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data['code'] == 'ALREADY_CLAIMED') {
        throw AlreadyClaimedException(
            e.response?.data['message'] ?? '이미 오늘의 무료 토큰를 받으셨습니다');
      }
      throw _handleDioError(e);
    }
  }

  // 프로필 완성 보너스 청구
  Future<Map<String, dynamic>> claimProfileCompletionBonus({
    required String userId,
  }) async {
    try {
      final data = await _apiClient.post('/profile-completion-bonus');

      return {
        'success': data['success'] ?? false,
        'bonusGranted': data['bonusGranted'] ?? false,
        'bonusAmount': data['bonusAmount'] ?? 0,
        'message': data['message'] ?? '',
        'balance': data['balance'] != null
            ? TokenBalance(
                userId: userId,
                totalTokens: data['balance']['totalTokens'] ?? 0,
                usedTokens: data['balance']['usedTokens'] ?? 0,
                remainingTokens: data['balance']['remainingTokens'] ?? 0,
                lastUpdated: DateTime.parse(data['balance']['lastUpdated']),
                hasUnlimitedAccess: false,
              )
            : null,
      };
    } on DioException catch (e) {
      // 404는 프로필 미완성으로 처리
      if (e.response?.statusCode == 404) {
        return {
          'success': false,
          'bonusGranted': false,
          'message': '프로필을 찾을 수 없습니다',
        };
      }
      throw _handleDioError(e);
    }
  }

  // 토큰 획득 (출석 체크, 공유 등)
  Future<TokenBalance> rewardTokensForAdView(
      {required String userId,
      required String fortuneType,
      int rewardAmount = 1}) async {
    try {
      // 새로운 soul-earn 엔드포인트 사용
      final data = await _apiClient
          .post('/soul-earn', data: {'fortuneType': fortuneType});

      final result = TokenBalance(
          userId: userId,
          totalTokens: data['balance']['totalTokens'],
          usedTokens: data['balance']['usedTokens'],
          remainingTokens: data['balance']['remainingTokens'],
          lastUpdated: DateTime.parse(data['balance']['lastUpdated']),
          hasUnlimitedAccess: data['balance']['hasUnlimitedAccess']);

      // 캐시 업데이트 (토큰 획득 후)
      _balanceCache[userId] = _CachedBalance(result, DateTime.now());

      return result;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Error Handler
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('연결 시간이 초과되었습니다');

      case DioExceptionType.connectionError:
        return const NetworkException('네트워크 연결을 확인해주세요');

      case DioExceptionType.cancel:
        return const NetworkException('요청이 취소되었습니다');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? '오류가 발생했습니다';

        switch (statusCode) {
          case 401:
            return const UnauthorizedException();
          case 403:
            return const ForbiddenException();
          case 404:
            return const NotFoundException();
          case 500:
            return const ServerException(
                message: '서버 오류가 발생했습니다', statusCode: 500);
          default:
            return ServerException(message: message, statusCode: statusCode);
        }

      default:
        return const UnknownException();
    }
  }
}

// Provider
final tokenApiServiceProvider = Provider<TokenApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TokenApiService(apiClient);
});

// Custom Exceptions moved to lib/core/errors/exceptions.dart
// - InsufficientTokensException
// - AlreadyClaimedException
