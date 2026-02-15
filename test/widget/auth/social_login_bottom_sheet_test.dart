import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/presentation/widgets/social_login_bottom_sheet.dart';

void main() {
  const dummySvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<rect width="24" height="24"/></svg>';

  setUpAll(() {
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

  testWidgets('Google button closes sheet and runs callback once',
      (tester) async {
    var googleLoginCallCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  SocialLoginBottomSheet.show(
                    context,
                    onGoogleLogin: () async {
                      googleLoginCallCount++;
                    },
                    onAppleLogin: () async {},
                    onKakaoLogin: () async {},
                    onNaverLogin: () async {},
                  );
                },
                child: const Text('open-sheet'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Google로 계속하기'), findsOneWidget);

    await tester.tap(find.text('Google로 계속하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpAndSettle();

    expect(googleLoginCallCount, 1);
    expect(find.text('Google로 계속하기'), findsNothing);
  });
}
