import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service that monitors and refreshes auth tokens in the background
class TokenMonitorService {
  static TokenMonitorService? _instance;
  static TokenMonitorService get instance {
    _instance ??= TokenMonitorService._();
    return _instance!;
  }

  TokenMonitorService._();

  Timer? _timer;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Check token every 4 minutes (tokens typically last 1 hour,
  static const Duration _checkInterval = Duration(minutes: 4);

  // Refresh if token expires within 10 minutes
  static const int _refreshThresholdSeconds = 600;

  /// Start monitoring auth tokens
  void startMonitoring() {
    stopMonitoring(); // Stop any existing timer

    // Initial check
    _checkAndRefreshToken();

    // Set up periodic check
    _timer = Timer.periodic(_checkInterval, (_) {
      _checkAndRefreshToken();
    });

    debugPrint('Token monitor service started');
  }

  /// Stop monitoring auth tokens
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    debugPrint('Token monitor service stopped');
  }

  /// Check token expiry and refresh if needed
  Future<void> _checkAndRefreshToken() async {
    try {
      final session = _supabase.auth.currentSession;

      if (session == null) {
        debugPrint('No active session to monitor');
        return;
      }

      final expiresAt = session.expiresAt;
      if (expiresAt == null) {
        debugPrint('Session has no expiry time');
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeUntilExpiry = expiresAt - now;

      debugPrint(
          'Token expires in ${timeUntilExpiry}s (${(timeUntilExpiry / 60).toStringAsFixed(1)} minutes)');

      if (timeUntilExpiry < _refreshThresholdSeconds) {
        debugPrint('Token expiring soon, refreshing...');

        try {
          final response = await _supabase.auth.refreshSession();

          if (response.session != null) {
            debugPrint('Token refreshed successfully via monitor service');

            // Notify listeners about the refresh
            _notifyTokenRefreshed();
          } else {
            debugPrint('Token refresh returned null session');
          }
        } catch (e) {
          debugPrint('Error refreshing token: $e');

          // If refresh fails, it might mean the refresh token is also expired
          // In this case, the user will need to re-authenticate
          if (e.toString().contains('refresh_token') ||
              e.toString().contains('invalid') ||
              e.toString().contains('expired')) {
            _handleAuthExpired();
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking token expiry: $e');
    }
  }

  /// Force a token refresh
  Future<bool> forceRefresh() async {
    try {
      final response = await _supabase.auth.refreshSession();
      if (response.session != null) {
        _notifyTokenRefreshed();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking token expiry: $e');
      return false;
    }
  }

  /// Get remaining token lifetime in seconds
  int? getTokenLifetime() {
    final session = _supabase.auth.currentSession;
    if (session?.expiresAt == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final lifetime = session!.expiresAt! - now;

    return lifetime > 0 ? lifetime : 0;
  }

  /// Check if token needs refresh
  bool needsRefresh() {
    final lifetime = getTokenLifetime();
    if (lifetime == null) return false;

    return lifetime < _refreshThresholdSeconds;
  }

  void _notifyTokenRefreshed() {
    // You can add event broadcasting here if needed
    // For example, using an event bus or stream controller
    debugPrint('Token refreshed, notifying app components');
  }

  void _handleAuthExpired() {
    // Sign out and redirect to login
    debugPrint('Auth expired, signing out');
    _supabase.auth.signOut();
  }

  void dispose() {
    stopMonitoring();
  }
}

/// Extension to make it easier to use from widgets
extension TokenMonitorExtension on SupabaseClient {
  TokenMonitorService get tokenMonitor => TokenMonitorService.instance;
}
