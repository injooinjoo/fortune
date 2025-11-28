import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';
import 'package:fortune/domain/entities/fortune.dart';

class CompatibilityAnalysisCard extends StatelessWidget {
  final Fortune fortune;
  final bool isBlurred;
  final List<String> blurredSections;

  const CompatibilityAnalysisCard({
    super.key,
    required this.fortune,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'analysis',
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
                    color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Color(0xFFEC4899),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '궁합 분석 결과',
                  style: TossTheme.heading4.copyWith(
                    color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Text(
              fortune.content,
              style: TossTheme.body2.copyWith(
                color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
