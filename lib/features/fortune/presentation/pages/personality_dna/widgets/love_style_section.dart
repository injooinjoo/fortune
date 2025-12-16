import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'toss_section_widget.dart';

class LoveStyleSection extends StatelessWidget {
  final LoveStyle loveStyle;

  const LoveStyleSection({
    super.key,
    required this.loveStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TossSectionWidget(
      title: '연애 스타일',
      icon: Icons.favorite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loveStyle.title,
            style: DSTypography.headingSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.accent,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loveStyle.description,
            style: DSTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _DetailCard(title: '연애할 때', content: loveStyle.whenDating),
          const SizedBox(height: 8),
          _DetailCard(title: '이별 후', content: loveStyle.afterBreakup),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String content;

  const _DetailCard({
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
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
