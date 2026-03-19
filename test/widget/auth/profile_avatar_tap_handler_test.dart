import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/theme/ds_theme.dart';
import 'package:fortune/features/character/presentation/utils/profile_avatar_tap_handler.dart';
import 'package:fortune/services/social_auth/base/social_auth_attempt_result.dart';
import 'package:fortune/services/social_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../mocks/mock_auth_services.dart';

class _FakeSocialAuthService extends SocialAuthService {
  _FakeSocialAuthService({
    required this.appleResult,
  }) : super(MockSupabaseClient());

  final SocialAuthAttemptResult appleResult;

  @override
  Future<SocialAuthAttemptResult> signInWithApple() async => appleResult;

  @override
  Future<SocialAuthAttemptResult> signInWithGoogle({
    BuildContext? context,
  }) async {
    return const SocialAuthAttemptResult.cancelled();
  }

  @override
  Future<SocialAuthAttemptResult> signInWithKakao() async {
    return const SocialAuthAttemptResult.cancelled();
  }

  @override
  Future<SocialAuthAttemptResult> signInWithNaver() async {
    return const SocialAuthAttemptResult.cancelled();
  }
}

class _ProfileAvatarTapHarness extends ConsumerWidget {
  const _ProfileAvatarTapHarness({
    required this.currentUser,
    required this.openProfileSheet,
    this.socialAuthService,
    this.onAuthenticated,
  });

  final User? currentUser;
  final SocialAuthService? socialAuthService;
  final Future<void> Function() openProfileSheet;
  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: DSTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (innerContext) => Center(
            child: TextButton(
              onPressed: () => handleProfileAvatarTap(
                context: innerContext,
                ref: ref,
                currentUser: currentUser,
                socialAuthService: socialAuthService,
                openProfileSheet: openProfileSheet,
                onAuthenticated: onAuthenticated,
              ),
              child: const Text('open-profile'),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  const dummySvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<rect width="24" height="24"/></svg>';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      if (message == null) return null;
      final key = utf8.decode(message.buffer.asUint8List());
      if (!key.endsWith('.svg')) return null;

      final bytes = Uint8List.fromList(utf8.encode(dummySvg));
      return ByteData.view(bytes.buffer);
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('guest profile icon opens social login flow', (tester) async {
    var profileSheetOpened = false;
    var authenticated = false;
    final authResponse = AuthTestData.createMockAuthResponse(
      user: AuthTestData.createAppleUser(),
    );
    final service = _FakeSocialAuthService(
      appleResult: SocialAuthAttemptResult.authenticated(authResponse),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: _ProfileAvatarTapHarness(
          currentUser: null,
          socialAuthService: service,
          openProfileSheet: () async {
            profileSheetOpened = true;
          },
          onAuthenticated: () {
            authenticated = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('open-profile'));
    await tester.pumpAndSettle();

    expect(find.text('Apple로 계속하기'), findsOneWidget);
    expect(profileSheetOpened, isFalse);

    await tester.tap(find.text('Apple로 계속하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(authenticated, isTrue);
    expect(profileSheetOpened, isFalse);
  });

  testWidgets('authenticated profile icon opens authenticated destination',
      (tester) async {
    var profileSheetOpened = false;
    final service = _FakeSocialAuthService(
      appleResult: const SocialAuthAttemptResult.cancelled(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: _ProfileAvatarTapHarness(
          currentUser: AuthTestData.createMockUser(),
          socialAuthService: service,
          openProfileSheet: () async {
            profileSheetOpened = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('open-profile'));
    await tester.pumpAndSettle();

    expect(profileSheetOpened, isTrue);
    expect(find.text('Apple로 계속하기'), findsNothing);
  });

  testWidgets(
      'guest profile icon shows retry message when Supabase client is unavailable',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: _ProfileAvatarTapHarness(
          currentUser: null,
          openProfileSheet: () async {},
        ),
      ),
    );

    await tester.tap(find.text('open-profile'));
    await tester.pumpAndSettle();

    expect(find.text('로그인을 시작할 수 없습니다. 네트워크 상태를 확인한 뒤 다시 시도해 주세요.'),
        findsOneWidget);
    expect(find.text('Apple로 계속하기'), findsNothing);
  });
}
