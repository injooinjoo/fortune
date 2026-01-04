import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_spacing.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 일상 매칭 카드
class DailyMatchingCard extends StatelessWidget {
  final DailyMatching dailyMatching;

  // 테마 색상 상수
  static const Color _matchingColor = Color(0xFFE67E22);

  const DailyMatchingCard({super.key, required this.dailyMatching});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _matchingColor.withValues(alpha: isDark ? 0.5 : 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('☕', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '나의 일상 매칭',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          _buildMatchingItem(
            context,
            isDark,
            '☕',
            '카페 메뉴',
            dailyMatching.cafeMenu,
            const Color(0xFF8D6E63),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildMatchingItem(
            context,
            isDark,
            '🎬',
            '넷플릭스 장르',
            dailyMatching.netflixGenre,
            const Color(0xFFE50914),
          ),
          const SizedBox(height: DSSpacing.sm),
          _buildMatchingItem(
            context,
            isDark,
            '🌴',
            '주말 활동',
            dailyMatching.weekendActivity,
            const Color(0xFF27AE60),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingItem(
    BuildContext context,
    bool isDark,
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  value,
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
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
