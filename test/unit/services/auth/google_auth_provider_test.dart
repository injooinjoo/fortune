import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/cache/profile_cache.dart';
import 'package:fortune/services/social_auth/providers/google_auth_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  test('Google uses native sign-in on iPhone and returns authenticated user',
      () async {
    final user = AuthTestData.createGoogleUser();
    final session = AuthTestData.createMockSession(user: user);
    final authResponse =
        AuthTestData.createMockAuthResponse(session: session, user: user);

    final provider = GoogleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      nativeSignInOverride: () async => authResponse,
    );

    final result = await provider.signIn();

    expect(result.isAuthenticated, isTrue);
    expect(result.user?.id, 'google-user-id');
  });

  test('Google does not fall back to browser OAuth on iPhone', () async {
    final user = AuthTestData.createGoogleUser();
    final session = AuthTestData.createMockSession(user: user);
    final authResponse =
        AuthTestData.createMockAuthResponse(session: session, user: user);
    var oauthCalled = false;

    final provider = GoogleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      nativeSignInOverride: () async => authResponse,
      signInWithOAuthOverride: () async {
        oauthCalled = true;
        return true;
      },
    );

    final result = await provider.signIn();

    expect(result.isAuthenticated, isTrue);
    expect(oauthCalled, isFalse);
  });

  test('Google treats native cancellation as a cancelled login attempt',
      () async {
    final provider = GoogleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      nativeSignInOverride: () async {
        throw PlatformException(
          code: GoogleSignIn.kSignInCanceledError,
          message: 'Sign in canceled',
        );
      },
    );

    final result = await provider.signIn();

    expect(result.isCancelled, isTrue);
  });

  test('Google launch exception is ignored when auth session is recovered',
      () async {
    final session = AuthTestData.createMockSession(
      user: AuthTestData.createGoogleUser(),
    );

    final provider = GoogleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isWebOverride: true,
      signInWithOAuthOverride: () async {
        throw PlatformException(
          code: 'Error',
          message:
              'Error while launching https://real-project.supabase.co/auth/v1/authorize?provider=google',
        );
      },
      recoverAuthResponseAfterLaunchErrorOverride: (_) async =>
          AuthResponse(session: session),
      isIOSOverride: true,
    );

    final result = await provider.signIn();

    expect(result.isAuthenticated, isTrue);
    expect(result.user?.id, 'google-user-id');
  });

  test(
      'Google launch exception still throws when auth session is not recovered',
      () async {
    final provider = GoogleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
      isWebOverride: true,
      signInWithOAuthOverride: () async {
        throw PlatformException(
          code: 'Error',
          message:
              'Error while launching https://real-project.supabase.co/auth/v1/authorize?provider=google',
        );
      },
      recoverAuthResponseAfterLaunchErrorOverride: (_) async => null,
      isIOSOverride: true,
    );

    await expectLater(
      provider.signIn(),
      throwsA(
        predicate(
          (error) => error.toString().contains(
              'Error while launching https://real-project.supabase.co/auth/v1/authorize?provider=google'),
        ),
      ),
    );
  });

  test('Google sign-in blocks placeholder Supabase clients before auth',
      () async {
    final provider = GoogleAuthProvider(
      _createTestSupabaseClient('https://test-placeholder.supabase.co'),
      ProfileCache(),
      isIOSOverride: true,
      nativeSignInOverride: () async {
        fail(
            'native Google sign-in should not start with a placeholder client');
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
