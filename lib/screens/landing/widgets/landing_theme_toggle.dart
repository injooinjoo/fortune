import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/toss_design_system.dart';
import '../../../presentation/providers/theme_provider.dart';

/// Theme toggle button for landing page
class LandingThemeToggle extends ConsumerWidget {
  const LandingThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).toggleTheme();

          final themeNotifier = ref.read(themeModeProvider.notifier);
          final isDark = themeNotifier.isDarkMode(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isDark ? '다크 모드로 전환되었습니다' : '라이트 모드로 전환되었습니다'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? TossDesignSystem.grayDark300
                    : TossDesignSystem.gray300,
                width: 1),
          ),
          child: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: 24,
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.grayDark300
                  : TossDesignSystem.gray600),
        ),
      ),
    );
  }
}
