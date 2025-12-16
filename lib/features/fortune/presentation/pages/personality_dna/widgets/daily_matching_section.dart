import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'toss_section_widget.dart';

class DailyMatchingSection extends StatelessWidget {
  final DailyMatching dailyMatching;

  const DailyMatchingSection({
    super.key,
    required this.dailyMatching,
  });

  @override
  Widget build(BuildContext context) {
    return TossSectionWidget(
      title: '일상 매칭',
      icon: Icons.coffee,
      child: Column(
        children: [
          _MatchingCard(title: '카페 메뉴', content: dailyMatching.cafeMenu),
          const SizedBox(height: 8),
          _MatchingCard(title: '넷플릭스 장르', content: dailyMatching.netflixGenre),
          const SizedBox(height: 8),
          _MatchingCard(title: '주말 활동', content: dailyMatching.weekendActivity),
        ],
      ),
    );
  }
}

class _MatchingCard extends StatelessWidget {
  final String title;
  final String content;

  const _MatchingCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DSTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: DSTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.accent,
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
