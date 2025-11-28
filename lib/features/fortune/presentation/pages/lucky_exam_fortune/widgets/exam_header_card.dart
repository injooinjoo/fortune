import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/components/app_card.dart';

class ExamHeaderCard extends StatelessWidget {
  const ExamHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.successGreen,
                  TossDesignSystem.successGreen.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: TossDesignSystem.white,
              size: 40,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            '시험 운세 리뉴얼',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : null,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            '시험 종류를 선택하고\n맞춤형 합격 운세를 확인하세요!',
            style: TossDesignSystem.body2.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.gray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }
}
