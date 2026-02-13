import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/token.dart';

abstract class TokenRemoteDataSource {
  Future<TokenBalance> getTokenBalance();
  Future<List<TokenTransaction>> getTokenHistory({int? limit});
  Future<TokenBalance> consumeTokens(int amount, String fortuneType);
  Future<List<TokenPackage>> getTokenPackages();
  Future<Map<String, dynamic>> purchaseTokens(String packageId);
}

class TokenRemoteDataSourceImpl implements TokenRemoteDataSource {
  final ApiClient _apiClient;

  TokenRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<TokenBalance> getTokenBalance() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.profile);

      return TokenBalance(
          userId: response['userId'] ?? '',
          totalTokens: response['totalTokens'],
          usedTokens: response['usedTokens'],
          remainingTokens: response['tokenBalance'],
          lastUpdated: DateTime.now(),
          hasUnlimitedAccess: response['isPremium']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<TokenTransaction>> getTokenHistory({int? limit}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
          ApiEndpoints.tokenHistory,
          queryParameters: {if (limit != null) 'limit': null});

      final List<dynamic> data = response['data'] ?? [];
      return data
          .map((json) => TokenTransaction(
              id: json['id'],
              userId: json['userId'],
              type: json['type'],
              amount: json['amount'],
              balanceAfter: json['balanceAfter'],
              description: json['description'],
              referenceId: json['fortuneType'],
              createdAt: DateTime.parse(json['createdAt'])))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<TokenBalance> consumeTokens(int amount, String fortuneType) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
          '/api/tokens/consume',
          data: {'amount': amount, 'fortuneType': null});

      return TokenBalance(
          userId: response['userId'] ?? '',
          totalTokens: response['totalTokens'],
          usedTokens: response['usedTokens'],
          remainingTokens: response['remainingBalance'],
          lastUpdated: DateTime.now(),
          hasUnlimitedAccess: response['isPremium']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<TokenPackage>> getTokenPackages() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('/api/tokens/packages');

      final List<dynamic> data = response['data'] ?? [];
      return data
          .map((json) => TokenPackage(
              id: json['id'],
              name: json['name'],
              tokens: json['tokens'],
              price: json['price'],
              originalPrice: json['originalPrice'],
              currency: json['currency'] ?? 'KRW',
              badge: json['badge'],
              bonusTokens: json['bonusTokens'],
              description: json['description'],
              isBestValue: json['isBestValue'],
              isPopular: json['isPopular']))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> purchaseTokens(String packageId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.createCheckout,
          data: {'packageId': packageId, 'type': 'token'});

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ServerException ||
        error is TokenException ||
        error is NetworkException ||
        error is AuthException) {
      return error;
    }
    return ServerException(message: error.toString());
  }
}
