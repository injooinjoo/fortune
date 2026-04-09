import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ondo/core/cache/profile_cache.dart';
import 'package:ondo/services/social_auth/base/social_auth_attempt_result.dart';
import 'package:ondo/services/social_auth/providers/apple_auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../mocks/mock_auth_services.dart';

final _testAnonKey = List.filled(120, 'a').join();

SupabaseClient _createTestSupabaseClient(String url) {
  return SupabaseClient(url, _testAnonKey);
}

void main() {
  setUpAll(() {
    dotenv.testLoad(
      mergeWith: {
        'SUPABASE_URL': 'https://real-project.supabase.co',
        'SUPABASE_ANON_KEY': _testAnonKey,
      },
    );
  });

  test('Apple retries native sign-in on iPhone before succeeding', () async {
    var nativeCallCount = 0;
    var oauthCallCount = 0;
    final user = AuthTestData.createAppleUser();
    final session = AuthTestData.createMockSession(user: user);
    final authResponse =
        AuthTestData.createMockAuthResponse(session: session, user: user);

    final provider = AppleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      shouldUseNativeAppleSignInOverride: () async => true,
      nativeRetryDelay: Duration.zero,
      nativeSignInOverride: () async {
        nativeCallCount++;
        if (nativeCallCount == 1) {
          return null;
        }
        return authResponse;
      },
      oauthSignInOverride: () async {
        oauthCallCount++;
        return const SocialAuthAttemptResult.pendingExternalAuth();
      },
    );

    final result = await provider.signIn();

    expect(result.isAuthenticated, isTrue);
    expect(nativeCallCount, 2);
    expect(oauthCallCount, 0);
  });

  test(
      'Apple falls back to OAuth when iPhone native sign-in fails after retries',
      () async {
    var nativeCallCount = 0;
    var oauthCallCount = 0;

    final provider = AppleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      shouldUseNativeAppleSignInOverride: () async => true,
      nativeRetryDelay: Duration.zero,
      nativeSignInOverride: () async {
        nativeCallCount++;
        return null;
      },
      oauthSignInOverride: () async {
        oauthCallCount++;
        return const SocialAuthAttemptResult.pendingExternalAuth();
      },
    );

    final result = await provider.signIn();

    expect(result.isPendingExternalAuth, isTrue);
    expect(nativeCallCount, 2);
    expect(oauthCallCount, 1);
  });

  test(
      'Apple retries OAuth fallback once on non-native devices after launch failure',
      () async {
    var oauthCallCount = 0;

    final provider = AppleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      shouldUseNativeAppleSignInOverride: () async => false,
      oauthRetryDelay: Duration.zero,
      oauthSignInOverride: () async {
        oauthCallCount++;
        if (oauthCallCount == 1) {
          throw Exception('Safari cannot open page');
        }
        return const SocialAuthAttemptResult.pendingExternalAuth();
      },
    );

    final result = await provider.signIn();

    expect(result.isPendingExternalAuth, isTrue);
    expect(oauthCallCount, 2);
  });

  test(
      'Apple treats OAuth cancellation as a cancelled login attempt on OAuth flow',
      () async {
    var oauthCallCount = 0;

    final provider = AppleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      shouldUseNativeAppleSignInOverride: () async => false,
      oauthRetryDelay: Duration.zero,
      oauthSignInOverride: () async {
        oauthCallCount++;
        throw Exception('사용자가 Apple 로그인을 취소했습니다.');
      },
    );

    final result = await provider.signIn();

    expect(result.isCancelled, isTrue);
    expect(oauthCallCount, 1);
  });

  test('Apple treats native cancellation as a cancelled login attempt',
      () async {
    final provider = AppleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      shouldUseNativeAppleSignInOverride: () async => true,
      nativeSignInOverride: () async {
        throw Exception('사용자가 Apple 로그인을 취소했습니다.');
      },
    );

    final result = await provider.signIn();

    expect(result.isCancelled, isTrue);
  });

  test('Apple skips native sign-in and starts OAuth on iPad-like devices',
      () async {
    var nativeSignInCalled = false;

    final provider = AppleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      shouldUseNativeAppleSignInOverride: () async => false,
      nativeSignInOverride: () async {
        nativeSignInCalled = true;
        return null;
      },
      oauthSignInOverride: () async =>
          const SocialAuthAttemptResult.pendingExternalAuth(),
    );

    final result = await provider.signIn();

    expect(nativeSignInCalled, isFalse);
    expect(result.isPendingExternalAuth, isTrue);
    expect(result.isAuthenticated, isFalse);
  });

  test('Apple sign-in blocks placeholder Supabase clients before auth',
      () async {
    final supabase =
        _createTestSupabaseClient('https://test-placeholder.supabase.co');

    final provider = AppleAuthProvider(
      supabase,
      ProfileCache(),
      isIOSOverride: true,
      shouldUseNativeAppleSignInOverride: () async => true,
      nativeSignInOverride: () async {
        fail('native Apple sign-in should not start with a placeholder client');
      },
    );

    await expectLater(
      provider.signIn(),
      throwsA(
        predicate(
          (error) => error
              .toString()
              .contains('현재 Supabase client가 placeholder 값으로 초기화되었습니다.'),
        ),
      ),
    );
  });
}
