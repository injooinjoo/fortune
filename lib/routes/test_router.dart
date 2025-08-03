import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Minimal test pages
class TestSplashScreen extends StatelessWidget {
  const TestSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-navigate to landing after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        context.go('/');
      }
    });
    
    return const Scaffold(
      body: Center(
        child: Text('포춘', style: TextStyle(fontSize: 48)),
      ),
    );
  }
}

class TestLandingPage extends StatelessWidget {
  const TestLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('포춘 - AI 운세', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                print('시작하기 button clicked!');
                context.go('/onboarding');
              },
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestOnboardingPage extends StatelessWidget {
  const TestOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('온보딩')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('온보딩 페이지', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Text('시작하기 버튼이 작동합니다!'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('홈으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: const Center(
        child: Text('홈 화면', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// Test router provider
final testRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const TestSplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const TestLandingPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const TestOnboardingPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const TestHomePage(),
      ),
    ],
  );
});