import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/design_system/theme/ds_theme.dart';
import 'package:fortune/presentation/widgets/social_accounts_section.dart';
import 'package:fortune/screens/onboarding/steps/name_input_step.dart';
import 'package:fortune/services/social_auth/base/social_auth_attempt_result.dart';
import 'package:fortune/services/social_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks/mock_auth_services.dart';

class _FakeSocialAuthService extends SocialAuthService {
  _FakeSocialAuthService({
    required this.appleResult,
  }) : super(MockSupabaseClient());

  final SocialAuthAttemptResult appleResult;

  @override
  Future<SocialAuthAttemptResult> signInWithApple() async => appleResult;

  @override
  Future<SocialAuthAttemptResult> signInWithGoogle(
      {BuildContext? context}) async {
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('NameInputStep keeps pending Apple OAuth as non-error state',
      (tester) async {
    final service = _FakeSocialAuthService(
      appleResult: const SocialAuthAttemptResult.pendingExternalAuth(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: DSTheme.light(),
          home: Scaffold(
            body: NameInputStep(
              initialName: '',
              onNameChanged: (_) {},
              onNext: () {},
              socialAuthService: service,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    expect(find.text('계정이 있어요'), findsOneWidget);

    await tester.tap(find.text('계정이 있어요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apple로 계속하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('브라우저에서 인증을 완료해 주세요. 완료되면 앱으로 돌아옵니다.'), findsOneWidget);
    expect(find.textContaining('로그인 실패'), findsNothing);
  });

  testWidgets('SocialAccountsSection shows pending message for Apple OAuth',
      (tester) async {
    final service = _FakeSocialAuthService(
      appleResult: const SocialAuthAttemptResult.pendingExternalAuth(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: DSTheme.light(),
          home: Scaffold(
            body: SocialAccountsSection(
              linkedProviders: const [],
              primaryProvider: null,
              onProvidersChanged: (_) {},
              socialAuthService: service,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, '연결').at(1));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('브라우저에서 인증을 완료해 주세요. 완료되면 앱으로 돌아옵니다.'), findsOneWidget);
    expect(find.textContaining('계정 연결에 실패했습니다'), findsNothing);
  });
}
