import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../base/base_social_auth_provider.dart';

class FacebookAuthProvider extends BaseSocialAuthProvider {
  FacebookAuthProvider(super.supabase, super.profileCache);

  @override
  String get providerName => 'facebook';

  @override
  Future<AuthResponse?> signIn() async {
    try {
      Logger.info('Starting Facebook Sign-In process with Supabase OAuth');

      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/auth/callback'
            : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
      );

      if (!response) {
        throw Exception('Facebook OAuth sign in failed');
      }

      Logger.securityCheckpoint('Facebook OAuth sign in initiated');

      return null;
    } catch (error) {
      Logger.warning(
          '[FacebookAuthProvider] Facebook 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      rethrow;
    }
  }
}
