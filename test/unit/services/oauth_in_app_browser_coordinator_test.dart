import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/services/oauth_in_app_browser_coordinator.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mock_auth_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient supabase;
  late MockGoTrueClient authClient;
  late dynamic session;

  setUp(() {
    supabase = MockSupabaseClient();
    authClient = MockGoTrueClient();
    session = AuthTestData.createMockSession();

    when(() => supabase.auth).thenReturn(authClient);
    when(() => authClient.currentSession).thenReturn(session);
  });

  tearDown(() {
    OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'test_cleanup');
  });

  test(
      'restores OAuth session after iOS launch errors like Safari cannot open page',
      () async {
    OAuthInAppBrowserCoordinator.markOAuthStarted('apple');

    final response =
        await OAuthInAppBrowserCoordinator.recoverAuthResponseAfterLaunchError(
      supabase,
      provider: 'apple',
      error: Exception('Safari cannot open page'),
      isIOSOverride: true,
      maxAttempts: 1,
      interval: Duration.zero,
    );

    expect(response?.session, same(session));
    expect(response?.user, same(session.user));
  });

  test('ignores non-recoverable OAuth launch errors', () async {
    OAuthInAppBrowserCoordinator.markOAuthStarted('apple');

    final response =
        await OAuthInAppBrowserCoordinator.recoverAuthResponseAfterLaunchError(
      supabase,
      provider: 'apple',
      error: Exception('invalid client id'),
      isIOSOverride: true,
      maxAttempts: 1,
      interval: Duration.zero,
    );

    expect(response, isNull);
  });
}
