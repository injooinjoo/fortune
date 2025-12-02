import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';
import 'package:fortune/core/widgets/gpt_style_typing_text.dart';
import 'package:fortune/domain/entities/fortune.dart';

class RelationshipAdviceCard extends StatelessWidget {
  final Fortune fortune;
  final bool isBlurred;
  final List<String> blurredSections;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const RelationshipAdviceCard({
    super.key,
    required this.fortune,
    required this.isBlurred,
    required this.blurredSections,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'advice',
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
                    color: TossTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: TossTheme.success,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '관계 개선 조언',
                  style: TossTheme.heading4.copyWith(
                    color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            GptStyleTypingText(
              text: fortune.advice!,
              style: TossTheme.body2.copyWith(
                color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
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
