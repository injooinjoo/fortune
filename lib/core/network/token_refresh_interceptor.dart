import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that handles automatic token refresh on 401 errors
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final SupabaseClient supabase;

  // Track ongoing refresh to prevent multiple simultaneous refreshes
  static Future<void>? _refreshTokenFuture;
  static DateTime? _lastRefreshTime;
  static const Duration _minRefreshInterval = Duration(seconds: 30);

  TokenRefreshInterceptor({required this.dio, required this.supabase});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Check if we have a valid session
    final session = supabase.auth.currentSession;

    if (session != null) {
      // Check if token is about to expire (within 5 minutes,
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final timeUntilExpiry = expiresAt - now;

        if (timeUntilExpiry < 300) {
          // Token expires in less than 5 minutes, refresh it
          debugPrint('Token expires soon, refreshing proactively...');
          try {
            await _refreshToken();
            // Update the header with new token
            final newSession = supabase.auth.currentSession;
            if (newSession != null) {
              options.headers['Authorization'] =
                  'Bearer ${newSession.accessToken}';
            }
          } catch (e) {
            debugPrint('Token refresh failed: $e');
            // Continue with existing token
          }
        }
      }

      // Add the current token to headers
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token might be expired, try to refresh
      try {
        debugPrint('Got 401, attempting token refresh...');

        // Wait for any ongoing refresh to complete
        if (_refreshTokenFuture != null) {
          await _refreshTokenFuture;
        } else {
          await _refreshToken();
        }

        // Retry the original request with new token
        final session = supabase.auth.currentSession;
        if (session != null) {
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';

          try {
            final response = await dio.fetch(options);
            handler.resolve(response);
            return;
          } catch (retryError) {
            // Retry failed, pass through the error
            handler
                .next(DioException(requestOptions: options, error: retryError));
            return;
          }
        }
      } catch (refreshError) {
        debugPrint('Token refresh error: $refreshError');
        // If refresh fails, user needs to re-authenticate
        _handleAuthFailure();
      }
    }

    handler.next(err);
  }

  Future<void> _refreshToken() async {
    // Check if we recently refreshed to avoid rapid refresh attempts
    if (_lastRefreshTime != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
      if (timeSinceLastRefresh < _minRefreshInterval) {
        debugPrint(
            'Skipping refresh, recently refreshed ${timeSinceLastRefresh.inSeconds}s ago');
        return;
      }
    }

    // Ensure only one refresh happens at a time
    if (_refreshTokenFuture != null) {
      return _refreshTokenFuture!;
    }

    _refreshTokenFuture = _performRefresh();

    try {
      await _refreshTokenFuture;
    } finally {
      _refreshTokenFuture = null;
    }
  }

  Future<void> _performRefresh() async {
    try {
      debugPrint('Refreshing auth token...');

      // Supabase handles token refresh automatically
      final response = await supabase.auth.refreshSession();

      if (response.session != null) {
        _lastRefreshTime = DateTime.now();
        debugPrint('Token refreshed successfully');
      } else {
        throw Exception('Refresh returned null session');
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      rethrow;
    }
  }

  void _handleAuthFailure() {
    // Sign out the user and redirect to login
    // This should be handled by the app's auth state management
    debugPrint('Authentication failed, signing out user');
    supabase.auth.signOut();
  }
}

/// Extension to easily add token refresh interceptor to Dio
extension DioTokenRefresh on Dio {
  void addTokenRefreshInterceptor(SupabaseClient supabase) {
    interceptors.add(TokenRefreshInterceptor(dio: this, supabase: supabase));
  }
}
