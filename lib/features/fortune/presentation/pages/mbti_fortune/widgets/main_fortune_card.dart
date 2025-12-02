import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:fortune/core/utils/fortune_text_cleaner.dart';
import 'package:fortune/core/widgets/gpt_style_typing_text.dart';
import 'lucky_items.dart';

class MainFortuneCard extends StatelessWidget {
  final FortuneResult fortuneResult;
  final String selectedMbti;
  final List<Color> colors;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const MainFortuneCard({
    super.key,
    required this.fortuneResult,
    required this.selectedMbti,
    required this.colors,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = fortuneResult.data as Map<String, dynamic>? ?? {};
    final todayFortune = FortuneTextCleaner.clean(data['todayFortune'] as String? ?? fortuneResult.summary['message'] as String? ?? '');
    final luckyItems = {
      if (data['luckyColor'] != null) '색상': data['luckyColor'],
      if (data['luckyNumber'] != null) '숫자': data['luckyNumber'].toString(),
    };

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$selectedMbti 오늘의 운세',
              style: const TextStyle(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GptStyleTypingText(
            text: todayFortune,
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              height: 1.6,
            ),
            startTyping: startTyping,
            showGhostText: true,
            onComplete: onTypingComplete,
          ),
          if (luckyItems.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            LuckyItems(items: luckyItems),
          ],
        ],
      ),
    );
  }
}
