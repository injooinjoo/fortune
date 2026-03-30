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
    _safetyResetTimer = Timer(const Duration(minutes: 3), () {
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

  /// OAuth 세션 감지 및 브라우저 자동 닫기
  ///
  /// [maxAttempts] × [interval] = 총 대기 시간
  /// 기본값: 180 × 250ms = 45초 (iPad/IPv6 환경 대응)
  /// [onProgress] 콜백으로 UI에서 진행 상황 표시 가능
  static Future<void> watchForSessionAndClose(
    SupabaseClient supabase, {
    required int flowId,
    int maxAttempts = 180, // 45초 (iPad/IPv6 네트워크 지연 대응)
    Duration interval = const Duration(milliseconds: 250),
    void Function(int currentAttempt, int totalAttempts)? onProgress,
  }) async {
    if (!_isOAuthInProgress) return;

    for (var i = 0; i < maxAttempts; i++) {
      if (!_isOAuthInProgress || flowId != _flowId) return;

      // UI 진행 상황 콜백 (선택적)
      onProgress?.call(i, maxAttempts);

      final session = supabase.auth.currentSession;
      if (session?.user != null) {
        Logger.info(
            '[OAuthBrowser] Auth session detected via polling (attempt $i/$maxAttempts), closing in-app browser');
        await _closeInAppBrowserIfNeeded();
        markOAuthFinished(reason: 'session_polling');
        return;
      }

      await Future<void>.delayed(interval);
    }

    // 타임아웃 도달 — 브라우저가 열린 채 남아있을 수 있으므로 닫기 시도
    Logger.warning(
        '[OAuthBrowser] Session polling timeout reached ($maxAttempts attempts), closing browser');
    await _closeInAppBrowserIfNeeded();
    markOAuthFinished(reason: 'polling_timeout');
  }

  static Future<AuthResponse?> recoverAuthResponseAfterLaunchError(
    SupabaseClient supabase, {
    required String provider,
    required Object error,
    int maxAttempts = 12,
    Duration interval = const Duration(milliseconds: 500),
    bool? isIOSOverride,
  }) async {
    if (!_isRecoverableLaunchError(error, isIOSOverride: isIOSOverride)) {
      return null;
    }

    final session = await _waitForSession(
      supabase,
      maxAttempts: maxAttempts,
      interval: interval,
    );
    if (session?.user == null) {
      return null;
    }

    Logger.info(
      '[OAuthBrowser] Auth session detected after launch exception (provider: $provider), treating OAuth launch as successful',
    );
    await _closeInAppBrowserIfNeeded(isIOSOverride: isIOSOverride);
    markOAuthFinished(reason: 'launch_exception_session_restored');
    return AuthResponse(session: session);
  }

  static bool _isRecoverableLaunchError(
    Object error, {
    bool? isIOSOverride,
  }) {
    final isIOS = isIOSOverride ?? (!kIsWeb && Platform.isIOS);
    if (kIsWeb || !isIOS) {
      return false;
    }

    final errorString = error.toString().toLowerCase();
    // 기존 패턴: url_launcher 에러
    if (errorString.contains('error while launching') &&
        errorString.contains('/auth/v1/authorize')) {
      return true;
    }
    // iOS 26+ 확장 패턴: 브라우저 실행 관련 에러 전반
    if (errorString.contains('error while launching') ||
        errorString.contains('cannot open page') ||
        (errorString.contains('safari') && errorString.contains('error'))) {
      return true;
    }
    return false;
  }

  static Future<Session?> _waitForSession(
    SupabaseClient supabase, {
    required int maxAttempts,
    required Duration interval,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final session = supabase.auth.currentSession;
      if (session?.user != null) {
        return session;
      }

      if (attempt == maxAttempts - 1) {
        return null;
      }

      await Future<void>.delayed(interval);
    }

    return null;
  }

  static Future<void> _closeInAppBrowserIfNeeded({bool? isIOSOverride}) async {
    final isIOS = isIOSOverride ?? (!kIsWeb && Platform.isIOS);
    if (kIsWeb || !isIOS) return;

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
