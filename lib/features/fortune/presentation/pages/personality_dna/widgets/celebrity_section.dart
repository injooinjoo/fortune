import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'toss_section_widget.dart';

class CelebritySection extends StatelessWidget {
  final Celebrity celebrity;

  const CelebritySection({
    super.key,
    required this.celebrity,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TossSectionWidget(
      title: '닮은 유명인',
      icon: Icons.star_border,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              celebrity.name,
              style: DSTypography.headingSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.accent,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              celebrity.reason,
              style: DSTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: colors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
