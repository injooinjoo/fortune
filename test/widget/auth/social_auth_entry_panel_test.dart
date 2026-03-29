import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/design_system/theme/ds_theme.dart';
import 'package:ondo/presentation/widgets/social_login_bottom_sheet.dart';
import 'package:ondo/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  testWidgets('browse action stores required policies before continuing',
      (tester) async {
    final storageService = StorageService();
    var browseCallCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: DSTheme.light(),
          home: Scaffold(
            body: SocialAuthEntryPanel(
              title: '대화를 바로 시작해볼까요?',
              description: '로그인하면 흐름을 저장하고, 개인화된 인사이트를 더 자연스럽게 이어갈 수 있어요.',
              onBrowseAsGuest: () async {
                browseCallCount++;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('둘러보기'));
    await tester.pumpAndSettle();

    expect(browseCallCount, 1);
    expect(await storageService.hasAcceptedTerms(), isTrue);
    expect(await storageService.hasAcceptedPrivacyPolicy(), isTrue);
  });
}
