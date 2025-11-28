import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class CollaborationSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final bool isDark;

  const CollaborationSection({
    super.key,
    required this.fortuneResult,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final collaboration = fortuneResult?.data['collaboration'] as Map<String, dynamic>?;
    if (collaboration == null) {
      return Center(
        child: Text(
          '협업 궁합 데이터가 없습니다',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
      );
    }

    final goodMatch = (collaboration['goodMatch'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
    final challenges = (collaboration['challenges'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
    final teamRole = FortuneTextCleaner.cleanNullable(collaboration['teamRole'] as String?);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (teamRole.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              teamRole,
              style: TypographyUnified.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.6,
                color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (goodMatch.isNotEmpty) ...[
          Text(
            '✅ 잘 맞는 타입',
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.successGreen,
            ),
          ),
          const SizedBox(height: 8),
          ...goodMatch.map((match) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 16, color: TossDesignSystem.successGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match,
                    style: TypographyUnified.bodySmall.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
        ],
        if (challenges.isNotEmpty) ...[
          Text(
            '⚠️ 주의할 타입',
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.warningOrange,
            ),
          ),
          const SizedBox(height: 8),
          ...challenges.map((challenge) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning, size: 16, color: TossDesignSystem.warningOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge,
                    style: TypographyUnified.bodySmall.copyWith(
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }
}
