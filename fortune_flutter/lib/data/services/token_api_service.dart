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
      final response = await _apiClient.get('/api/user/token-balance');
      
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
        hasUnlimitedAccess: isUnlimited,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 토큰 소비
  Future<TokenBalance> consumeTokens({
    required String userId,
    required String fortuneType,
    required int amount,
    String? referenceId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/token/consume',
        data: {
          'fortuneType': fortuneType,
          'amount': amount,
          'referenceId': referenceId,
        },
      );

      return TokenBalance(
        userId: userId,
        totalTokens: response.data['balance']['totalTokens'] ?? 0,
        usedTokens: response.data['balance']['usedTokens'] ?? 0,
        remainingTokens: response.data['balance']['remainingTokens'] ?? 0,
        lastUpdated: DateTime.parse(response.data['balance']['lastUpdated'] ?? DateTime.now().toIso8601String()),
        hasUnlimitedAccess: response.data['balance']['hasUnlimitedAccess'] ?? false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && 
          e.response?.data['code'] == 'INSUFFICIENT_TOKENS') {
        throw InsufficientTokensException(
          e.response?.data['message'] ?? '토큰이 부족합니다',
        );
      }
      throw _handleDioError(e);
    }
  }

  // 토큰 패키지 목록 조회
  Future<List<TokenPackage>> getTokenPackages() async {
    try {
      final response = await _apiClient.get('/api/token/packages');
      
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
                isPopular: json['isPopular'] ?? false,
              ))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 토큰 구매
  Future<Map<String, dynamic>> purchaseTokens({
    required String packageId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/token/purchase',
        data: {
          'packageId': packageId,
          'paymentMethodId': paymentMethodId,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 토큰 거래 내역 조회
  Future<List<TokenTransaction>> getTokenHistory({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get(
        '/api/user/token-history',
        queryParameters: queryParams,
      );

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
                balanceAfter: json['balanceAfter'],
              ))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 운세별 토큰 소비량 조회
  Future<Map<String, int>> getTokenConsumptionRates() async {
    try {
      final response = await _apiClient.get('/api/token/consumption-rates');
      
      return Map<String, int>.from(response.data['rates'] ?? {});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 구독 정보 조회
  Future<UnlimitedSubscription?> getSubscription({required String userId}) async {
    try {
      final response = await _apiClient.get('/api/user/subscription');
      
      if (response.data['subscription'] == null) {
        return null;
      }

      final sub = response.data['subscription'];
      return UnlimitedSubscription(
        id: sub['id'],
        userId: sub['userId'],
        startDate: DateTime.parse(sub['startDate']),
        endDate: DateTime.parse(sub['endDate']),
        status: sub['status'],
        plan: sub['plan'],
        price: (sub['price'] as num).toDouble(),
        currency: sub['currency'] ?? 'KRW',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 일일 무료 토큰 받기
  Future<TokenBalance> claimDailyTokens({required String userId}) async {
    try {
      final response = await _apiClient.post('/api/token/claim-daily');
      
      return TokenBalance(
        userId: userId,
        totalTokens: response.data['balance']['totalTokens'] ?? 0,
        usedTokens: response.data['balance']['usedTokens'] ?? 0,
        remainingTokens: response.data['balance']['remainingTokens'] ?? 0,
        lastUpdated: DateTime.parse(response.data['balance']['lastUpdated'] ?? DateTime.now().toIso8601String()),
        hasUnlimitedAccess: response.data['balance']['hasUnlimitedAccess'] ?? false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && 
          e.response?.data['code'] == 'ALREADY_CLAIMED') {
        throw AlreadyClaimedException(
          e.response?.data['message'] ?? '이미 오늘의 무료 토큰을 받으셨습니다',
        );
      }
      throw _handleDioError(e);
    }
  }

  // 광고 시청 후 토큰 보상
  Future<TokenBalance> rewardTokensForAdView({
    required String userId,
    required String fortuneType,
    int rewardAmount = 1,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/token/reward-ad-view',
        data: {
          'fortuneType': fortuneType,
          'rewardAmount': rewardAmount,
        },
      );

      return TokenBalance(
        userId: userId,
        totalTokens: response.data['balance']['totalTokens'] ?? 0,
        usedTokens: response.data['balance']['usedTokens'] ?? 0,
        remainingTokens: response.data['balance']['remainingTokens'] ?? 0,
        lastUpdated: DateTime.parse(response.data['balance']['lastUpdated'] ?? DateTime.now().toIso8601String()),
        hasUnlimitedAccess: response.data['balance']['hasUnlimitedAccess'] ?? false,
      );
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
  const InsufficientTokensException([String message = '토큰이 부족합니다']) 
      : super(message: message, code: 'INSUFFICIENT_TOKENS');
}

class AlreadyClaimedException extends AppException {
  const AlreadyClaimedException([String message = '이미 받으셨습니다']) 
      : super(message: message, code: 'ALREADY_CLAIMED');
}