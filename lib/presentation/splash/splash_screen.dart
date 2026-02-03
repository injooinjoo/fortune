import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';

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
      context.go('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DSFortuneColors.hanjiDark  // 다크 모드 한지 배경
          : DSFortuneColors.hanjiCream, // 크림색 한지 배경
      body: Center(
        child: Text(
          '知',
          style: TextStyle(
            fontFamily: 'ZenSerif',
            fontSize: 120,
            fontWeight: FontWeight.w400,
            color: isDark
                ? DSFortuneColors.hanjiCream
                : DSFortuneColors.inkBlack,
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 800.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}