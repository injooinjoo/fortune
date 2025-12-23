import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/domain/entities/fortune.dart';

class NumericCompatibilityCard extends StatelessWidget {
  final Fortune fortune;
  final String person1Name;
  final String person2Name;

  const NumericCompatibilityCard({
    super.key,
    required this.fortune,
    required this.person1Name,
    required this.person2Name,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: DSColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '숫자 궁합',
                style: DSTypography.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 이름 궁합
          if (fortune.metadata?['name_compatibility'] != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이름 궁합',
                      style: DSTypography.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$person1Name ♥ $person2Name',
                      style: DSTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: DSColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${fortune.metadata!['name_compatibility']}%',
                    style: DSTypography.headingSmall.copyWith(
                      color: DSColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // 운명수
          if (fortune.metadata?['destiny_number'] != null) ...[
            const SizedBox(height: 16),
            Divider(color: colors.border),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '두 사람의 운명수',
                  style: DSTypography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DSColors.warning.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${fortune.metadata!['destiny_number']['number']}',
                          style: DSTypography.headingMedium.copyWith(
                            color: DSColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fortune.metadata!['destiny_number']['meaning'],
                        style: DSTypography.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
