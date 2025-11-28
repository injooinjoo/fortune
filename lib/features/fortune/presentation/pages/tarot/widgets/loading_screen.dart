import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C3AED),
                  const Color(0xFF3B82F6),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: TossDesignSystem.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '카드를 뽑고 있어요...',
            style: TypographyUnified.buttonMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
