import 'package:dio/dio.dart';

/// Specialized API client for auth operations with optimized timeouts
class AuthApiClient {
  static const Duration authTimeout = Duration(seconds: 10);
  
  static BaseOptions getAuthOptions(String baseUrl) {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: authTimeout)
      receiveTimeout: authTimeout)
      sendTimeout: const Duration(seconds: 5))
      headers: {
        'Content-Type': 'application/json')
        'Accept': 'application/json')
      }
    );
  }
  
  static Dio createAuthClient(String baseUrl) {
    return Dio(getAuthOptions(baseUrl);
  }
}