import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/cache/profile_cache.dart';
import 'package:fortune/services/social_auth/base/social_auth_attempt_result.dart';
import 'package:fortune/services/social_auth/providers/apple_auth_provider.dart';

import '../../../mocks/mock_auth_services.dart';

void main() {
  setUpAll(() {
    registerAuthFallbackValues();
  });

  test('Apple native fallback returns pending external auth on iOS', () async {
    final provider = AppleAuthProvider(
      MockSupabaseClient(),
      ProfileCache(),
      isIOSOverride: true,
      nativeSignInOverride: () async => null,
      oauthSignInOverride: () async =>
          const SocialAuthAttemptResult.pendingExternalAuth(),
    );

    final result = await provider.signIn();

    expect(result.isPendingExternalAuth, isTrue);
    expect(result.isAuthenticated, isFalse);
  });
}
