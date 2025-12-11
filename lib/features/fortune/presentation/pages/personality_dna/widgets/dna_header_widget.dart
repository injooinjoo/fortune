import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

class DnaHeaderWidget extends StatelessWidget {
  final PersonalityDNA dna;

  const DnaHeaderWidget({
    super.key,
    required this.dna,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (dna.popularityRank != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: dna.popularityColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, color: TossDesignSystem.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    dna.popularityText,
                    style: const TextStyle(
                      color: TossDesignSystem.white,
                      fontFamily: 'ZenSerif',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(dna.emoji, style: TypographyUnified.displayLarge),
          const SizedBox(height: 16),
          Text(
            dna.title,
            style: TypographyUnified.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            dna.description,
            style: TextStyle(
              color: isDark ? TossDesignSystem.textSecondaryDark : const Color(0xFF8B95A1),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dna.dnaCode,
              style: TextStyle(
                color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
