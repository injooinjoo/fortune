import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/environment.dart';
import '../errors/exceptions.dart' as app_exceptions;
import '../utils/logger.dart';
import 'token_refresh_interceptor.dart';
import 'cache_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final Supabase _supabase = Supabase.instance;

  // Getter for dio instance
  Dio get dio => _dio;

  ApiClient() {
    final baseUrl = Environment.apiBaseUrl;
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'}));

    // 인터셉터 추가
    _dio.interceptors.addAll([
      // 커스텀 로깅 인터셉터
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Track request timing
          options.extra['requestTime'] = DateTime.now();
          options.extra['requestId'] = DateTime.now().millisecondsSinceEpoch.toString();
          
          Logger.apiRequest(
            options.method,
            options.uri.toString(),
            options.data
          );
          
          // Log fortune-specific requests
          if (options.uri.toString().contains('/fortune/')) {
            final fortuneType = options.uri.pathSegments.lastOrNull ?? 'unknown';
            Logger.info('🚀 [ApiClient] Fortune API request initiated', {
              'requestId': options.extra['requestId'],
              'fortuneType': fortuneType,
              'method': options.method,
              'endpoint': null});
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Calculate response time
          final requestTime = response.requestOptions.extra['requestTime'] as DateTime?;
          final responseTime = requestTime != null 
              ? DateTime.now().difference(requestTime).inMilliseconds 
              : null;
          
          Logger.apiResponse(
            response.requestOptions.method,
            response.requestOptions.uri.toString(),
            response.statusCode ?? 0,
            response.data
          );
          
          // Log fortune-specific responses
          if (response.requestOptions.uri.toString().contains('/fortune/')) {
            final fortuneType = response.requestOptions.uri.pathSegments.lastOrNull ?? 'unknown';
            Logger.info('✅ [ApiClient] Fortune API request completed', {
              'requestId': response.requestOptions.extra['requestId'],
              'fortuneType': fortuneType,
              'statusCode': response.statusCode,
              'responseTime': responseTime != null ? '${responseTime}ms' : 'unknown',
              'hasData': response.data != null});
          }
          
          handler.next(response);
        },
        onError: (error, handler) {
          // Calculate response time even for errors
          final requestTime = error.requestOptions.extra['requestTime'] as DateTime?;
          final responseTime = requestTime != null
              ? DateTime.now().difference(requestTime).inMilliseconds
              : null;

          // Graceful handling for 404 errors on optional endpoints
          final statusCode = error.response?.statusCode ?? 0;
          final uri = error.requestOptions.uri.toString();
          final isOptionalEndpoint = uri.contains('/soul-transaction') ||
                                     uri.contains('/subscription-check') ||
                                     uri.contains('/token-consumption');

          // Use DEBUG log level for 404 errors on optional endpoints
          if (statusCode == 404 && isOptionalEndpoint) {
            Logger.debug('🔍 [ApiClient] Optional endpoint not found (gracefully handled)', {
              'endpoint': uri,
              'statusCode': statusCode,
              'message': 'This is expected - endpoint is optional'
            });
          } else {
            Logger.apiResponse(
              error.requestOptions.method,
              error.requestOptions.uri.toString(),
              statusCode,
              error.response?.data
            );

            // Log fortune-specific errors
            if (error.requestOptions.uri.toString().contains('/fortune/')) {
              final fortuneType = error.requestOptions.uri.pathSegments.lastOrNull ?? 'unknown';
              final errorMessage = error.response?.data?.toString() ?? error.message ?? 'Unknown error';
              Logger.error('❌ [ApiClient] Fortune API request failed', {
                'requestId': error.requestOptions.extra['requestId'],
                'fortuneType': fortuneType,
                'statusCode': statusCode,
                'errorType': error.type.toString(),
                'responseTime': responseTime != null ? '${responseTime}ms' : 'unknown',
                'errorMessage': errorMessage,
                'requestUrl': error.requestOptions.uri.toString(),
                'requestMethod': error.requestOptions.method,
                'requestData': error.requestOptions.data?.toString()});
            }
          }

          handler.next(error);
        })]);
    
    // Add improved token refresh interceptor
    _dio.addTokenRefreshInterceptor(_supabase.client);
    
    // Add cache interceptor
    _dio.addCacheInterceptor();
  }

  // GET 요청
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options}) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options
      );
      return response.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST 요청
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options}) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options
      );
      return response.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT 요청
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options}) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options
      );
      return response.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE 요청
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options}) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options
      );
      return response.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 스트리밍 응답 처리 (운세 생성용,
  Stream<String> getStream(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    CancelToken? cancelToken}) async* {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream'}),
        cancelToken: cancelToken
      );

      final stream = response.data.stream as Stream<List<int>>;
      
      await for (final chunk in stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.trim().isNotEmpty && data != '[DONE]') {
              yield data;
            }
          }
        }
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 에러 처리
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return app_exceptions.NetworkException('네트워크 연결 시간이 초과되었습니다.');
        
        case DioExceptionType.connectionError:
          return app_exceptions.NetworkException('네트워크에 연결할 수 없습니다.');
        
        case DioExceptionType.cancel:
          return app_exceptions.NetworkException('요청이 취소되었습니다.');
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          // API 에러 응답 처리
          if (data is Map<String, dynamic>) {
            final message = data['message'] ?? data['error'] ?? '알 수 없는 오류가 발생했습니다.';
            
            // 토큰 부족 에러
            if (statusCode == 402 || data['code'] == 'insufficient_tokens') {
              return app_exceptions.TokenException(
                message: message,
                remainingTokens: data['remainingTokens']);
            }
            
            // 유효성 검사 에러
            if (statusCode == 400) {
              return app_exceptions.ValidationException(
                message: message,
                errors: data['errors']);
            }
            
            return app_exceptions.ServerException(
              message: message,
              statusCode: statusCode,
              data: data);
          }
          
          return app_exceptions.ServerException(
            message: '서버 오류가 발생했습니다. (${statusCode ?? 'Unknown'})',
            statusCode: statusCode);
        
        default:
          return app_exceptions.NetworkException('네트워크 오류가 발생했습니다.');
      }
    }
    
    if (error is SocketException) {
      return app_exceptions.NetworkException('인터넷 연결을 확인해주세요.');
    }
    
    return app_exceptions.ServerException(
      message: error.toString());
  }
}