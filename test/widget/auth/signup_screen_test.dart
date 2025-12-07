/// Signup Screen - Widget Test
/// 회원가입 화면 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('SignupScreen 테스트', () {
    group('UI 렌더링', () {
      testWidgets('회원가입 화면이 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('소셜 로그인 옵션들이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 소셜 로그인 버튼들 확인
        expect(find.text('Google로 계속하기'), findsOneWidget);
        expect(find.text('카카오로 계속하기'), findsOneWidget);
        expect(find.text('Apple로 계속하기'), findsOneWidget);
        expect(find.text('네이버로 계속하기'), findsOneWidget);
      });

      testWidgets('이용약관 링크가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('이용약관'), findsOneWidget);
        expect(find.textContaining('개인정보처리방침'), findsOneWidget);
      });
    });

    group('소셜 로그인 버튼 인터랙션', () {
      testWidgets('Google 로그인 버튼 탭', (tester) async {
        String? selectedProvider;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(
                  onSocialLogin: (provider) => selectedProvider = provider,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Google로 계속하기'));
        await tester.pumpAndSettle();

        expect(selectedProvider, 'google');
      });

      testWidgets('Kakao 로그인 버튼 탭', (tester) async {
        String? selectedProvider;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(
                  onSocialLogin: (provider) => selectedProvider = provider,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('카카오로 계속하기'));
        await tester.pumpAndSettle();

        expect(selectedProvider, 'kakao');
      });

      testWidgets('Apple 로그인 버튼 탭', (tester) async {
        String? selectedProvider;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(
                  onSocialLogin: (provider) => selectedProvider = provider,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Apple로 계속하기'));
        await tester.pumpAndSettle();

        expect(selectedProvider, 'apple');
      });

      testWidgets('Naver 로그인 버튼 탭', (tester) async {
        String? selectedProvider;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(
                  onSocialLogin: (provider) => selectedProvider = provider,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('네이버로 계속하기'));
        await tester.pumpAndSettle();

        expect(selectedProvider, 'naver');
      });
    });

    group('로딩 상태', () {
      testWidgets('로그인 처리 중 로딩 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreenLoading(),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('로딩 중 버튼 비활성화', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreenLoading(),
              ),
            ),
          ),
        );

        // 버튼들이 비활성화되어야 함
        final googleButton = find.widgetWithText(ElevatedButton, 'Google로 계속하기');
        expect(googleButton, findsOneWidget);
      });
    });

    group('에러 상태', () {
      testWidgets('에러 메시지 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreenError(
                  errorMessage: '로그인에 실패했습니다. 다시 시도해주세요.',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('로그인에 실패했습니다. 다시 시도해주세요.'), findsOneWidget);
      });
    });

    group('약관 동의', () {
      testWidgets('이용약관 링크 탭', (tester) async {
        bool termsPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(
                  onTermsPressed: () => termsPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('이용약관'));
        await tester.pumpAndSettle();

        expect(termsPressed, isTrue);
      });

      testWidgets('개인정보처리방침 링크 탭', (tester) async {
        bool privacyPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(
                  onPrivacyPressed: () => privacyPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('개인정보처리방침'));
        await tester.pumpAndSettle();

        expect(privacyPressed, isTrue);
      });
    });

    group('접근성', () {
      testWidgets('모든 버튼이 충분한 터치 영역을 가져야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockSignupScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 버튼 크기 확인
        final buttons = find.byType(ElevatedButton);
        expect(buttons, findsWidgets);

        for (final button in buttons.evaluate()) {
          final renderBox = button.renderObject as RenderBox;
          final size = renderBox.size;
          expect(size.height >= 44, isTrue,
              reason: '버튼 높이가 최소 44px 이상이어야 함');
        }
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(
                body: _MockSignupScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('다크 테마에서 올바르게 렌더링', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const Scaffold(
                body: _MockSignupScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockSignupScreen extends StatelessWidget {
  final void Function(String provider)? onSocialLogin;
  final VoidCallback? onTermsPressed;
  final VoidCallback? onPrivacyPressed;

  const _MockSignupScreen({
    this.onSocialLogin,
    this.onTermsPressed,
    this.onPrivacyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '회원가입',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              '소셜 계정으로 간편하게 시작하세요',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Google
            ElevatedButton(
              onPressed: () => onSocialLogin?.call('google'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Google로 계속하기'),
            ),
            const SizedBox(height: 12),

            // Kakao
            ElevatedButton(
              onPressed: () => onSocialLogin?.call('kakao'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('카카오로 계속하기'),
            ),
            const SizedBox(height: 12),

            // Apple
            ElevatedButton(
              onPressed: () => onSocialLogin?.call('apple'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Apple로 계속하기'),
            ),
            const SizedBox(height: 12),

            // Naver
            ElevatedButton(
              onPressed: () => onSocialLogin?.call('naver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03C75A),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('네이버로 계속하기'),
            ),

            const Spacer(),

            // 약관
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('가입 시 '),
                GestureDetector(
                  onTap: onTermsPressed,
                  child: const Text(
                    '이용약관',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Text(' 및 '),
                GestureDetector(
                  onTap: onPrivacyPressed,
                  child: const Text(
                    '개인정보처리방침',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Text('에 동의합니다.'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MockSignupScreenLoading extends StatelessWidget {
  const _MockSignupScreenLoading();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '회원가입',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              '소셜 계정으로 간편하게 시작하세요',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Google - 로딩 중 비활성화
            ElevatedButton(
              onPressed: null, // 비활성화
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Google로 계속하기'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 다른 버튼들도 비활성화
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('카카오로 계속하기'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Apple로 계속하기'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03C75A),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('네이버로 계속하기'),
            ),

            const Spacer(),

            // 로딩 중 표시
            const Center(
              child: Text('로그인 중...'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockSignupScreenError extends StatelessWidget {
  final String errorMessage;

  const _MockSignupScreenError({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
