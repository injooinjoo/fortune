import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'toss_section_widget.dart';

class CelebritySection extends StatelessWidget {
  final Celebrity celebrity;

  const CelebritySection({
    super.key,
    required this.celebrity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TossSectionWidget(
      title: '닮은 유명인',
      icon: Icons.star_border,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              celebrity.name,
              style: TypographyUnified.heading4.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.tossBlue,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              celebrity.reason,
              style: TypographyUnified.buttonMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
