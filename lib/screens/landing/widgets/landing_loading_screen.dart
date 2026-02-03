import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/components/loading_video_player.dart';

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
            const LoadingVideoPlayer(
              width: 120,
              height: 120,
              loop: true,
            ),
            const SizedBox(height: 16),
            Text(
              '로그인 상태를 확인하고 있습니다...',
              style: context.labelMedium.copyWith(
                  color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
