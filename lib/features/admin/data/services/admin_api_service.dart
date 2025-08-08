import 'package:dio/dio.dart';
import 'package:fortune/core/network/api_client.dart';
import 'package:fortune/features/admin/data/models/admin_stats_model.dart';
import 'package:fortune/features/admin/data/models/redis_stats_model.dart';
import 'package:fortune/features/admin/data/models/token_usage_detail_model.dart';
import 'package:fortune/core/errors/exceptions.dart';
import 'package:fortune/core/utils/logger.dart';

class AdminApiService {
  final ApiClient _apiClient;

  AdminApiService(this._apiClient);

  Future<AdminStatsModel> getAdminStats({
    DateTime? startDate,
    DateTime? endDate}) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/token-stats',
        queryParameters: {
          if (startDate != null) 'startDate': null,
          if (endDate != null) 'endDate': null})

      return AdminStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error('Failed to fetch admin stats', e);
      throw _handleDioError(e);
    }
  }

  Future<TokenUsageDetailModel> getTokenUsageStats({
    DateTime? startDate,
    DateTime? endDate,
    String period = '7d'}) async {
    try {
      final response = await _apiClient.get(
        '/api/admin/token-usage',
        queryParameters: {
          if (startDate != null) 'startDate': null,
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          'period': null});

      return TokenUsageDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error('Failed to fetch token usage stats', e);
      throw _handleDioError(e);
    }
  }

  Future<RedisStatsModel> getRedisStats() async {
    try {
      final response = await _apiClient.get('/api/admin/redis-stats');
      return RedisStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      Logger.error('Failed to fetch Redis stats', e);
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('네트워크 연결 오류가 발생했습니다.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
        
        if (statusCode == 401) {
          return UnauthorizedException('관리자 권한이 필요합니다.');
        } else if (statusCode == 403) {
          return ServerException(message: '접근 권한이 없습니다.');
        } else {
          return ServerException(message: message);
        }
      default:
        return ServerException(message: '예상치 못한 오류가 발생했습니다.');
    }
  }
}