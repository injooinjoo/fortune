import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('온보딩 화면'),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}