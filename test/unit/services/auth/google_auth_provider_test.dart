import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/cache/profile_cache.dart';
import 'package:fortune/services/social_auth/providers/google_auth_provider.dart';
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

  test('Google launch exception is ignored when auth session is recovered',
      () async {
    final session = AuthTestData.createMockSession(
      user: AuthTestData.createGoogleUser(),
    );

    final provider = GoogleAuthProvider(
      _createTestSupabaseClient('https://real-project.supabase.co'),
      ProfileCache(),
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
}
