import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';
import '../compatibility_utils.dart';

class DetailedScoresCard extends StatelessWidget {
  final Map<String, double> scores;
  final bool isBlurred;
  final List<String> blurredSections;

  const DetailedScoresCard({
    super.key,
    required this.scores,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'detailed_scores',
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TossTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: TossTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '세부 궁합 분석',
                  style: TossTheme.heading4.copyWith(
                    color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ...scores.entries.where((e) => e.key != '전체 궁합').map((entry) {
              final index = scores.keys.toList().indexOf(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TossTheme.body2.copyWith(
                            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(entry.value * 100).round()}점',
                          style: TossTheme.body2.copyWith(
                            color: CompatibilityUtils.getScoreColor(entry.value),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: entry.value,
                      backgroundColor: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CompatibilityUtils.getScoreColor(entry.value),
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ).animate(delay: (index * 100).ms)
                 .fadeIn(duration: 600.ms)
                 .slideX(begin: 0.3),
              );
            }),
          ],
        ),
      ),
    );
  }
}
