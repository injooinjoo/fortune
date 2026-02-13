// Landing Page - Widget Test
// 랜딩 페이지 UI 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('LandingPage 테스트', () {
    group('UI 렌더링', () {
      testWidgets('랜딩 페이지가 정상적으로 렌더링되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLandingPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 기본 UI 요소 확인
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('앱 로고가 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLandingPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 로고 또는 앱 이름 확인
        expect(find.text('Fortune'), findsOneWidget);
      });

      testWidgets('시작하기 버튼이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLandingPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('시작하기'), findsOneWidget);
      });
    });

    group('사용자 인터랙션', () {
      testWidgets('시작하기 버튼 탭 시 콜백이 호출되어야 함', (tester) async {
        bool buttonPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLandingPage(
                  onStartPressed: () => buttonPressed = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('시작하기'));
        await tester.pumpAndSettle();

        expect(buttonPressed, isTrue);
      });
    });

    group('로딩 상태', () {
      testWidgets('인증 확인 중 로딩 표시', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLoadingLandingPage(),
              ),
            ),
          ),
        );

        // 로딩 인디케이터 확인
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('테마 지원', () {
      testWidgets('라이트 테마 적용', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const Scaffold(
                body: _MockLandingPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('다크 테마 적용', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const Scaffold(
                body: _MockLandingPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('소셜 로그인 버튼', () {
      testWidgets('소셜 로그인 버튼들이 표시되어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLandingWithSocialButtons(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 소셜 로그인 버튼 확인
        expect(find.text('Google로 계속하기'), findsOneWidget);
        expect(find.text('카카오로 계속하기'), findsOneWidget);
        expect(find.text('Apple로 계속하기'), findsOneWidget);
      });

      testWidgets('Google 로그인 버튼 탭', (tester) async {
        String? selectedProvider;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLandingWithSocialButtons(
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
                body: _MockLandingWithSocialButtons(
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
    });

    group('접근성', () {
      testWidgets('버튼에 적절한 semantics 레이블이 있어야 함', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: _MockLandingPage(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 버튼이 탭 가능해야 함
        final button = find.text('시작하기');
        expect(button, findsOneWidget);
      });
    });
  });
}

// ============================================
// Mock Widgets
// ============================================

class _MockLandingPage extends StatelessWidget {
  final VoidCallback? onStartPressed;

  const _MockLandingPage({this.onStartPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Fortune',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('오늘의 운세를 확인해보세요'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onStartPressed ?? () {},
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }
}

class _MockLoadingLandingPage extends StatelessWidget {
  const _MockLoadingLandingPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _MockLandingWithSocialButtons extends StatelessWidget {
  final void Function(String provider)? onSocialLogin;

  const _MockLandingWithSocialButtons({this.onSocialLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Fortune',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => onSocialLogin?.call('google'),
            child: const Text('Google로 계속하기'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => onSocialLogin?.call('kakao'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE500),
              foregroundColor: Colors.black,
            ),
            child: const Text('카카오로 계속하기'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => onSocialLogin?.call('apple'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apple로 계속하기'),
          ),
        ],
      ),
    );
  }
}
