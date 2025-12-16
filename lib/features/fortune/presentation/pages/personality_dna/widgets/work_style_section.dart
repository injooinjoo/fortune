import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'toss_section_widget.dart';

class WorkStyleSection extends StatelessWidget {
  final WorkStyle workStyle;

  const WorkStyleSection({
    super.key,
    required this.workStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TossSectionWidget(
      title: '업무 스타일',
      icon: Icons.work,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workStyle.title,
            style: DSTypography.headingSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.accent,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          _DetailCard(title: '상사가 된다면', content: workStyle.asBoss),
          const SizedBox(height: 8),
          _DetailCard(title: '회식에서', content: workStyle.atCompanyDinner),
          const SizedBox(height: 8),
          _DetailCard(title: '업무 습관', content: workStyle.workHabit),
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
