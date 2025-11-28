import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_theme.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../domain/models/health_fortune_model.dart';

class BodyPartHealthSection extends StatelessWidget {
  final List<BodyPartHealth> bodyPartHealthList;
  final List<BodyPart> selectedBodyParts;
  final bool isDark;

  const BodyPartHealthSection({
    super.key,
    required this.bodyPartHealthList,
    required this.selectedBodyParts,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final concernedParts = bodyPartHealthList
        .where((bph) => selectedBodyParts.contains(bph.bodyPart))
        .toList();

    if (concernedParts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관심 부위 상태',
            style: TossTheme.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),

          ...concernedParts.map((bph) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(bph.level.colorValue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(bph.level.colorValue).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bph.bodyPart.displayName,
                        style: TossTheme.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(bph.level.colorValue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${bph.score}점',
                          style: TossTheme.caption.copyWith(
                            color: TossDesignSystem.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    bph.description,
                    style: TossTheme.body3.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
