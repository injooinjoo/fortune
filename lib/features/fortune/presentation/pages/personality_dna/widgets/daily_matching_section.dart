import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
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
                  style: TypographyUnified.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textSecondaryDark : const Color(0xFF8B95A1),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TypographyUnified.buttonMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TossDesignSystem.tossBlue,
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
