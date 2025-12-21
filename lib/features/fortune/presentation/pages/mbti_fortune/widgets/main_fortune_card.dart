import 'package:flutter/material.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/utils/fortune_text_cleaner.dart';
import 'package:fortune/core/widgets/gpt_style_typing_text.dart';
import 'lucky_items.dart';
import 'package:fortune/core/theme/font_config.dart';

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
    final themeColors = context.colors;
    final data = fortuneResult.data as Map<String, dynamic>? ?? {};
    // 폴백: todayFortune → summary['message'] → 기본 메시지
    final rawFortune = data['todayFortune'] as String? ??
                       fortuneResult.summary['message'] as String? ??
                       '$selectedMbti 유형의 오늘 운세를 준비하고 있습니다. 페이지를 새로고침 해주세요.';
    final todayFortune = FortuneTextCleaner.clean(rawFortune);
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
                color: Colors.white,
                fontFamily: FontConfig.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GptStyleTypingText(
            text: todayFortune,
            style: DSTypography.bodySmall.copyWith(
              color: themeColors.textPrimary,
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
