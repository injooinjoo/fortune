import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/utils/fortune_text_cleaner.dart';
import 'package:fortune/core/widgets/gpt_style_typing_text.dart';

/// MBTI 오늘의 조언 카드
class MbtiAdviceCard extends StatelessWidget {
  final String advice;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const MbtiAdviceCard({
    super.key,
    required this.advice,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cleanedAdvice = FortuneTextCleaner.clean(advice);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '오늘의 조언',
                style: DSTypography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GptStyleTypingText(
            text: cleanedAdvice,
            style: DSTypography.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
            startTyping: startTyping,
            showGhostText: true,
            onComplete: onTypingComplete,
          ),
        ],
      ),
    );
  }
}
