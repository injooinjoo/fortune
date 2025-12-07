import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/token.dart';
import '../../presentation/providers/providers.dart';

class TokenApiService {
  final ApiClient _apiClient;

  TokenApiService(this._apiClient);

  // 토큰 잔액 조회
  Future<TokenBalance> getTokenBalance({required String userId}) async {
    try {
      final response = await _apiClient.get('/token-balance');
      
      // Handle different response structures from backend
      final balance = response.data['balance'] ?? 0;
      final totalPurchased = response.data['totalPurchased'] ?? 0;
      final totalUsed = response.data['totalUsed'] ?? 0;
      final isUnlimited = response.data['isUnlimited'] ?? false;
      
      return TokenBalance(
        userId: userId,
        totalTokens: totalPurchased,
        usedTokens: totalUsed,
        remainingTokens: balance,
        lastUpdated: DateTime.now(),
        hasUnlimitedAccess: isUnlimited);
    } on DioException catch (e) {
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
  Future<TokenBalance> consumeTokens({
    required String userId,
    required String fortuneType,
    required int amount,
    String? referenceId}) async {
    try {
      // 새로운 soul-consume 엔드포인트 사용
      final response = await _apiClient.post(
        '/soul-consume',
        data: {
          'fortuneType': fortuneType,
          'referenceId': null});

      return TokenBalance(
        userId: userId,
        totalTokens: response.data['balance']['totalTokens'],
        usedTokens: response.data['balance']['usedTokens'],
        remainingTokens: response.data['balance']['remainingTokens'],
        lastUpdated: DateTime.parse(response.data['balance']['lastUpdated']),
        hasUnlimitedAccess: response.data['balance']['hasUnlimitedAccess']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && 
          e.response?.data['code'] == 'INSUFFICIENT_TOKENS') {
        throw InsufficientTokensException(
          e.response?.data['message'] ?? '영혼이 부족합니다'
        );
      }
      throw _handleDioError(e);
    }
  }

  // 토큰 패키지 목록 조회
  Future<List<TokenPackage>> getTokenPackages() async {
    try {
      final response = await _apiClient.get('/token-packages');
      
      return (response.data['packages'] as List)
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
  Future<Map<String, dynamic>> purchaseTokens({
    required String packageId,
    required String paymentMethodId}) async {
    try {
      final response = await _apiClient.post(
        '/token-purchase',
        data: {
          'packageId': packageId,
          'paymentMethodId': null});

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 토큰 거래 내역 조회
  Future<List<TokenTransaction>> getTokenHistory({
    required String userId,
    int? limit,
    int? offset}) async {
    try {
      final queryParams = {
        if (limit != null) 'limit': null,
        if (offset != null) 'offset': null};

      final response = await _apiClient.get(
        '/token-history',
        queryParameters: queryParams);

      // Handle the response format from the backend
      final transactions = response.data['transactions'] as List? ?? [];
      
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
      final response = await _apiClient.get('/token-consumption-rates');

      return Map<String, int>.from(response.data['rates'] ?? {});
    } on DioException catch (e) {
      // 404 또는 네트워크 에러 시 기본값 반환 (optional endpoint)
      if (e.type == DioExceptionType.connectionError ||
          e.response?.statusCode == 0 ||
          e.response?.statusCode == 404) {
        // Return default token consumption rates
        return _defaultConsumptionRates;
      }
      throw _handleDioError(e);
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
  Future<UnlimitedSubscription?> getSubscription({required String userId}) async {
    try {
      final response = await _apiClient.get('/subscription-status');

      // subscription-status Edge Function 응답 형식:
      // { active: bool, expiresAt?: string, productId?: string, autoRenewing?: bool }
      final isActive = response.data['active'] == true;

      if (!isActive) {
        return null;
      }

      // 활성 구독이 있는 경우
      final expiresAt = response.data['expiresAt'];
      final productId = response.data['productId'];

      return UnlimitedSubscription(
        id: productId ?? 'subscription',
        userId: userId,
        startDate: DateTime.now(), // 시작일은 정확히 알 수 없음
        endDate: expiresAt != null ? DateTime.parse(expiresAt) : DateTime.now().add(const Duration(days: 30)),
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
      final response = await _apiClient.post('/token-daily-claim');
      
      return TokenBalance(
        userId: userId,
        totalTokens: response.data['balance']['totalTokens'],
        usedTokens: response.data['balance']['usedTokens'],
        remainingTokens: response.data['balance']['remainingTokens'],
        lastUpdated: DateTime.parse(response.data['balance']['lastUpdated']),
        hasUnlimitedAccess: response.data['balance']['hasUnlimitedAccess']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && 
          e.response?.data['code'] == 'ALREADY_CLAIMED') {
        throw AlreadyClaimedException(
          e.response?.data['message'] ?? '이미 오늘의 무료 영혼을 받으셨습니다'
        );
      }
      throw _handleDioError(e);
    }
  }

  // 광고 시청 후 토큰 보상 (영혼 획득으로 변경)
  Future<TokenBalance> rewardTokensForAdView({
    required String userId,
    required String fortuneType,
    int rewardAmount = 1}) async {
    try {
      // 새로운 soul-earn 엔드포인트 사용
      final response = await _apiClient.post(
        '/soul-earn',
        data: {
          'fortuneType': fortuneType});

      return TokenBalance(
        userId: userId,
        totalTokens: response.data['balance']['totalTokens'],
        usedTokens: response.data['balance']['usedTokens'],
        remainingTokens: response.data['balance']['remainingTokens'],
        lastUpdated: DateTime.parse(response.data['balance']['lastUpdated']),
        hasUnlimitedAccess: response.data['balance']['hasUnlimitedAccess']);
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
        return NetworkException('연결 시간이 초과되었습니다');
        
      case DioExceptionType.connectionError:
        return NetworkException('네트워크 연결을 확인해주세요');
        
      case DioExceptionType.cancel:
        return NetworkException('요청이 취소되었습니다');
        
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
            return ServerException(message: '서버 오류가 발생했습니다', statusCode: 500);
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

// Custom Exceptions
class InsufficientTokensException extends AppException {
  const InsufficientTokensException([String message = '영혼이 부족합니다'])
      : super(message: message, code: 'INSUFFICIENT_TOKENS');
}

class AlreadyClaimedException extends AppException {
  const AlreadyClaimedException([String message = '이미 받으셨습니다'])
      : super(message: message, code: 'ALREADY_CLAIMED');
}