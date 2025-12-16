import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';
import 'package:fortune/core/widgets/gpt_style_typing_text.dart';
import 'package:fortune/domain/entities/fortune.dart';

class CompatibilityAnalysisCard extends StatelessWidget {
  final Fortune fortune;
  final bool isBlurred;
  final List<String> blurredSections;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const CompatibilityAnalysisCard({
    super.key,
    required this.fortune,
    required this.isBlurred,
    required this.blurredSections,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                  style: DSTypography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            GptStyleTypingText(
              text: fortune.content,
              style: DSTypography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
              ),
              startTyping: startTyping,
              showGhostText: true,
              onComplete: onTypingComplete,
            ),
          ],
        ),
      ),
    );
  }
}
