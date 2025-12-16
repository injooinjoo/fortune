import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system/design_system.dart';

/// Loading screen shown while checking authentication status
class LandingLoadingScreen extends StatelessWidget {
  const LandingLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/flower_transparent_white.png'
                  : 'assets/images/flower_transparent.png',
              width: 64,
              height: 64,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 2.seconds),
            SizedBox(height: 16),
            Text(
              '로그인 상태를 확인하고 있습니다...',
              style: DSTypography.labelMedium.copyWith(
                  color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
