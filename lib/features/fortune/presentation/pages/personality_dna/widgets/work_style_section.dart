import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'toss_section_widget.dart';

class WorkStyleSection extends StatelessWidget {
  final WorkStyle workStyle;

  const WorkStyleSection({
    super.key,
    required this.workStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TossSectionWidget(
      title: '업무 스타일',
      icon: Icons.work,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workStyle.title,
            style: TypographyUnified.heading4.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.tossBlue,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
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
              fontWeight: FontWeight.w400,
              color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
