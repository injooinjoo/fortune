import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 월별 하이라이트 상세 바텀시트
///
/// 월 카드 클릭 시 advice 전문을 보여주는 바텀시트입니다.
class MonthHighlightDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> monthData;
  final int monthNum;
  final bool isCurrentMonth;

  const MonthHighlightDetailBottomSheet({
    super.key,
    required this.monthData,
    required this.monthNum,
    required this.isCurrentMonth,
  });

  /// 바텀시트를 표시합니다.
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> monthData,
    required int monthNum,
    required bool isCurrentMonth,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => MonthHighlightDetailBottomSheet(
        monthData: monthData,
        monthNum: monthNum,
        isCurrentMonth: isCurrentMonth,
      ),
    );
  }

  Color _getEnergyColor(String energyLevel) {
    switch (energyLevel) {
      case 'High':
        return DSColors.success;
      case 'Medium':
        return DSColors.info;
      case 'Low':
        return DSColors.warning;
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final theme = monthData['theme'] as String? ?? '';
    final score = (monthData['score'] as num?)?.toInt() ?? 70;
    final advice = monthData['advice'] as String? ?? '';
    final energyLevel = monthData['energyLevel'] as String? ?? 'Medium';
    final bestDays =
        (monthData['bestDays'] as List<dynamic>?)?.cast<String>() ?? [];
    final recommendedAction = monthData['recommendedAction'] as String? ?? '';
    final avoidAction = monthData['avoidAction'] as String? ?? '';

    final energyColor = _getEnergyColor(energyLevel);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrentMonth
                        ? colors.accent.withValues(alpha: 0.1)
                        : colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrentMonth
                        ? Border.all(color: colors.accent, width: 2)
                        : null,
                  ),
                  child: Text(
                    '$monthNum월',
                    style: typography.headingSmall.copyWith(
                      color:
                          isCurrentMonth ? colors.accent : colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Text(
                    theme,
                    style: typography.headingSmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // 점수 뱃지
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: energyColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$score점',
                    style: typography.labelMedium.copyWith(
                      color: energyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DSSpacing.md),

          // 스크롤 가능한 콘텐츠
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 에너지 레벨 표시
                  Row(
                    children: [
                      Text(
                        '에너지 레벨: ',
                        style: typography.labelMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: energyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          energyLevel,
                          style: typography.labelSmall.copyWith(
                            color: energyColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DSSpacing.md),

                  // 조언 전문
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(DSRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '이달의 조언',
                              style: typography.labelMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          advice,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 추천 행동
                  if (recommendedAction.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DSSpacing.md),
                      decoration: BoxDecoration(
                        color: DSColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.md),
                        border: Border.all(
                          color: DSColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('✅', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '추천 행동',
                                style: typography.labelMedium.copyWith(
                                  color: DSColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DSSpacing.xs),
                          Text(
                            recommendedAction,
                            style: typography.bodySmall.copyWith(
                              color: colors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 피해야 할 것
                  if (avoidAction.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DSSpacing.md),
                      decoration: BoxDecoration(
                        color: DSColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DSRadius.md),
                        border: Border.all(
                          color: DSColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('⚠️', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '주의할 것',
                                style: typography.labelMedium.copyWith(
                                  color: DSColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DSSpacing.xs),
                          Text(
                            avoidAction,
                            style: typography.bodySmall.copyWith(
                              color: colors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 좋은 날
                  if (bestDays.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.md),
                    Row(
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '좋은 날: ',
                          style: typography.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            children: bestDays
                                .map((day) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colors.accent
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        day,
                                        style: typography.labelSmall.copyWith(
                                          color: colors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: DSSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
