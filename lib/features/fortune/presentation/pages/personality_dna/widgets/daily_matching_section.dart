import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'fortune_section_widget.dart';

/// 일상 매칭 섹션 - 한국 전통 스타일
///
/// HanjiColorScheme.luck (황금색)을 사용합니다.
class DailyMatchingSection extends StatelessWidget {
  final DailyMatching dailyMatching;

  const DailyMatchingSection({
    super.key,
    required this.dailyMatching,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final luckAccent = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFFB7950B);

    return TossSectionWidget(
      title: '일상 매칭',
      hanja: '福',
      colorScheme: HanjiColorScheme.luck,
      child: Column(
        children: [
          _MatchingCard(
            title: '카페 메뉴',
            content: dailyMatching.cafeMenu,
            emoji: '☕',
            isDark: isDark,
            accentColor: luckAccent,
          ),
          const SizedBox(height: 8),
          _MatchingCard(
            title: '넷플릭스 장르',
            content: dailyMatching.netflixGenre,
            emoji: '🎬',
            isDark: isDark,
            accentColor: luckAccent,
          ),
          const SizedBox(height: 8),
          _MatchingCard(
            title: '주말 활동',
            content: dailyMatching.weekendActivity,
            emoji: '🌿',
            isDark: isDark,
            accentColor: luckAccent,
          ),
        ],
      ),
    );
  }
}

class _MatchingCard extends StatelessWidget {
  final String title;
  final String content;
  final String emoji;
  final bool isDark;
  final Color accentColor;

  const _MatchingCard({
    required this.title,
    required this.content,
    required this.emoji,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 이모지 배지
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: FontConfig.buttonMedium)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FontConfig.primary,
                    fontSize: FontConfig.labelSmall,
                    fontWeight: FontWeight.w600,
                    color: DSFortuneColors.getInk(isDark).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontFamily: FontConfig.primary,
                    fontSize: FontConfig.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
