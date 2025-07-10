import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/environment.dart';
import '../errors/exceptions.dart' as app_exceptions;
import '../utils/logger.dart';

class ApiClient {
  late final Dio _dio;
  final Supabase _supabase = Supabase.instance;

  ApiClient() {
    final baseUrl = Environment.apiBaseUrl;
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.addAll([
      // 커스텀 로깅 인터셉터
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Logger.apiRequest(
            options.method,
            options.uri.toString(),
            options.data,
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          Logger.apiResponse(
            response.requestOptions.method,
            response.requestOptions.uri.toString(),
            response.statusCode ?? 0,
            response.data,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          Logger.apiResponse(
            error.requestOptions.method,
            error.requestOptions.uri.toString(),
            error.response?.statusCode ?? 0,
            error.response?.data,
          );
          handler.next(error);
        },
      ),
      // 인증 인터셉터
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Supabase 세션 토큰 추가
          final session = _supabase.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // 토큰 갱신 시도
            try {
              await _supabase.client.auth.refreshSession();
              // 원래 요청 재시도
              final retryOptions = error.requestOptions;
              final session = _supabase.client.auth.currentSession;
              if (session != null) {
                retryOptions.headers['Authorization'] = 'Bearer ${session.accessToken}';
              }
              final response = await _dio.request(
                retryOptions.path,
                options: Options(
                  method: retryOptions.method,
                  headers: retryOptions.headers,
                ),
                data: retryOptions.data,
                queryParameters: retryOptions.queryParameters,
              );
              handler.resolve(response);
              return;
            } catch (e) {
              // 토큰 갱신 실패
              handler.reject(DioException(
                requestOptions: error.requestOptions,
                error: app_exceptions.AuthException(
                  message: '인증이 만료되었습니다. 다시 로그인해주세요.',
                  code: 'auth_expired',
                ),
              ));
              return;
            }
          }
          handler.next(error);
        },
      ),
    ]);
  }

  // GET 요청
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
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
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
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
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
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
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data!;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 스트리밍 응답 처리 (운세 생성용)
  Stream<String> getStream(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
  }) async* {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
          },
        ),
        cancelToken: cancelToken,
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
                remainingTokens: data['remainingTokens'],
              );
            }
            
            // 유효성 검사 에러
            if (statusCode == 400) {
              return app_exceptions.ValidationException(
                message: message,
                errors: data['errors'],
              );
            }
            
            return app_exceptions.ServerException(
              message: message,
              statusCode: statusCode,
              data: data,
            );
          }
          
          return app_exceptions.ServerException(
            message: '서버 오류가 발생했습니다. (${statusCode ?? 'Unknown'})',
            statusCode: statusCode,
          );
        
        default:
          return app_exceptions.NetworkException('네트워크 오류가 발생했습니다.');
      }
    }
    
    if (error is SocketException) {
      return app_exceptions.NetworkException('인터넷 연결을 확인해주세요.');
    }
    
    return app_exceptions.ServerException(
      message: error.toString(),
    );
  }
}