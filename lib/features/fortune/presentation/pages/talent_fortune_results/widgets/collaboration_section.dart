import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class CollaborationSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const CollaborationSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final collaboration = fortuneResult?.data['collaboration'] as Map<String, dynamic>?;
    if (collaboration == null) {
      return Center(
        child: Text(
          '협업 궁합 데이터가 없습니다',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
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
              color: colors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              teamRole,
              style: DSTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.6,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (goodMatch.isNotEmpty) ...[
          Text(
            '✅ 잘 맞는 타입',
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.success,
            ),
          ),
          const SizedBox(height: 8),
          ...goodMatch.map((match) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, size: 16, color: DSColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match,
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
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
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.warning,
            ),
          ),
          const SizedBox(height: 8),
          ...challenges.map((challenge) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning, size: 16, color: DSColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge,
                    style: DSTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
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
