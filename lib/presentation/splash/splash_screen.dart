import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/toss_design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? TossDesignSystem.grayDark50
          : TossDesignSystem.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with dark/light mode support
            Image.asset(
              Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/flower_transparent_white.png'
                : 'assets/images/flower_transparent.png',
              width: 120,
              height: 120,
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 40),
            // App name
            Text(
              '관상은 과학',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.white
                    : TossDesignSystem.black,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                fontFamily: 'ZenSerif',
              ),
            )
                .animate()
                .fadeIn(
                  delay: 400.ms,
                  duration: 800.ms,
                )
                .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 400.ms,
                  duration: 800.ms,
                  curve: Curves.easeOutCubic,
                ),
          ],
        ),
      ),
    );
  }
}