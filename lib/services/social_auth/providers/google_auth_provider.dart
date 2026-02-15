import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/environment.dart';
import '../../oauth_in_app_browser_coordinator.dart';
import '../base/base_social_auth_provider.dart';

class GoogleAuthProvider extends BaseSocialAuthProvider {
  GoogleAuthProvider(super.supabase, super.profileCache);

  @override
  String get providerName => 'google';

  @override
  Future<AuthResponse?> signIn() async {
    try {
      debugPrint(
          '🟡 [GoogleAuthProvider] signIn() started with Supabase OAuth');
      Logger.info('=== GOOGLE OAUTH SUPABASE PROCESS STARTED ===');

      final supabaseUrl = Environment.supabaseUrl;
      Logger.info(
          'Using Supabase URL for OAuth: ${supabaseUrl.substring(0, 30)}...');

      if (supabaseUrl.contains('your-project')) {
        Logger.warning(
            '[GoogleAuthProvider] Supabase URL 설정 오류 (선택적 기능, 설정 확인 필요): Supabase URL이 제대로 설정되지 않음');
        throw Exception('Supabase URL is not properly configured');
      }

      debugPrint(
          '🟡 [GoogleAuthProvider] Starting Supabase OAuth for Google...');
      Logger.info('Starting Supabase OAuth for Google');
      final redirectTo = _resolveRedirectTo();
      Logger.info('Google OAuth redirectTo: $redirectTo');
      final flowId =
          OAuthInAppBrowserCoordinator.markOAuthStarted(providerName);

      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        // Keep OAuth inside the app UX on iOS (SFSafariViewController).
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
      );

      if (!response) {
        OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'launch_failed');
        Logger.warning('Google OAuth initiation failed');
        throw Exception('Google OAuth sign in failed to start');
      }

      unawaited(
        OAuthInAppBrowserCoordinator.watchForSessionAndClose(
          supabase,
          flowId: flowId,
        ),
      );

      Logger.info('Google OAuth initiated successfully');
      debugPrint('🟡 [GoogleAuthProvider] OAuth redirect initiated');

      Logger.securityCheckpoint('Google OAuth flow initiated');
      Logger.info('=== GOOGLE OAUTH SUPABASE INITIATED ===');

      return null;
    } catch (error) {
      OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'exception');
      Logger.warning(
          '[GoogleAuthProvider] Google OAuth 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      Logger.warning(
          '[GoogleAuthProvider] Google OAuth 에러 타입 (선택적 기능, 다른 로그인 방법 사용 권장): ${error.runtimeType}');
      rethrow;
    }
  }

  String _resolveRedirectTo() {
    if (kIsWeb) {
      return '${Uri.base.origin}/auth/callback';
    }

    // Keep iOS on the app custom scheme. The current Supabase project
    // redirect allowlist does not reliably accept the Supabase default
    // scheme in this app setup and can fall back to localhost.
    if (Platform.isIOS) {
      return 'com.beyond.fortune://auth-callback';
    }

    return 'com.beyond.fortune://auth-callback';
  }
}
