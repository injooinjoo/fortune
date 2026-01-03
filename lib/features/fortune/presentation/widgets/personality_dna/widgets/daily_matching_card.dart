import 'package:flutter/material.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 일상 매칭 카드
class DailyMatchingCard extends StatelessWidget {
  final DailyMatching dailyMatching;

  const DailyMatchingCard({super.key, required this.dailyMatching});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE67E22).withValues(alpha:0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('☕', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '나의 일상 매칭',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMatchingItem(
            context,
            '☕',
            '카페 메뉴',
            dailyMatching.cafeMenu,
            const Color(0xFF8D6E63),
          ),
          const SizedBox(height: 12),
          _buildMatchingItem(
            context,
            '🎬',
            '넷플릭스 장르',
            dailyMatching.netflixGenre,
            const Color(0xFFE50914),
          ),
          const SizedBox(height: 12),
          _buildMatchingItem(
            context,
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
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
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
