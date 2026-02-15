import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/utils/logger.dart';

/// Coordinates OAuth in-app browser lifecycle.
///
/// On iOS, `LaunchMode.inAppBrowserView` may remain visible even after
/// authentication succeeds. This coordinator tracks active OAuth attempts and
/// force-closes the in-app browser when a valid auth session is observed.
class OAuthInAppBrowserCoordinator {
  static bool _isOAuthInProgress = false;
  static String? _activeProvider;
  static int _flowId = 0;
  static Timer? _safetyResetTimer;

  static int markOAuthStarted(String provider) {
    _flowId++;
    _isOAuthInProgress = true;
    _activeProvider = provider;

    _safetyResetTimer?.cancel();
    _safetyResetTimer = Timer(const Duration(minutes: 2), () {
      Logger.warning(
          '[OAuthBrowser] Safety timeout reached, clearing pending OAuth state (provider: $_activeProvider)');
      _clearState();
    });

    Logger.info('[OAuthBrowser] OAuth started (provider: $provider)');
    return _flowId;
  }

  static void markOAuthFinished({required String reason}) {
    if (_isOAuthInProgress) {
      Logger.info(
          '[OAuthBrowser] OAuth flow finished (provider: $_activeProvider, reason: $reason)');
    }
    _clearState();
  }

  static Future<void> onAuthStateChanged(AuthState authState) async {
    if (!_isOAuthInProgress) return;

    final hasSession = authState.session?.user != null;
    final isSuccessfulAuthEvent = authState.event == AuthChangeEvent.signedIn ||
        authState.event == AuthChangeEvent.initialSession ||
        authState.event == AuthChangeEvent.tokenRefreshed;

    if (!hasSession || !isSuccessfulAuthEvent) return;

    Logger.info(
        '[OAuthBrowser] Auth session detected via auth event (${authState.event}), closing in-app browser');
    await _closeInAppBrowserIfNeeded();
    markOAuthFinished(reason: 'auth_event_${authState.event.name}');
  }

  static Future<void> watchForSessionAndClose(
    SupabaseClient supabase, {
    required int flowId,
    int maxAttempts = 80,
    Duration interval = const Duration(milliseconds: 250),
  }) async {
    if (!_isOAuthInProgress) return;

    for (var i = 0; i < maxAttempts; i++) {
      if (!_isOAuthInProgress || flowId != _flowId) return;

      final session = supabase.auth.currentSession;
      if (session?.user != null) {
        Logger.info(
            '[OAuthBrowser] Auth session detected via polling, closing in-app browser');
        await _closeInAppBrowserIfNeeded();
        markOAuthFinished(reason: 'session_polling');
        return;
      }

      await Future<void>.delayed(interval);
    }
  }

  static Future<void> _closeInAppBrowserIfNeeded() async {
    if (kIsWeb || !Platform.isIOS) return;

    try {
      final supportsClose =
          await supportsCloseForLaunchMode(LaunchMode.inAppBrowserView);
      if (!supportsClose) {
        Logger.info('[OAuthBrowser] In-app browser close not supported');
        return;
      }

      await closeInAppWebView();
      Logger.info('[OAuthBrowser] In-app browser closed');
    } catch (error) {
      Logger.warning(
          '[OAuthBrowser] Failed to close in-app browser (non-fatal): $error');
    }
  }

  static void _clearState() {
    _isOAuthInProgress = false;
    _activeProvider = null;
    _safetyResetTimer?.cancel();
    _safetyResetTimer = null;
  }
}
