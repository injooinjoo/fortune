import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class GrowthRoadmapSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const GrowthRoadmapSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final growthRoadmap = fortuneResult?.data['growthRoadmap'] as Map<String, dynamic>?;
    if (growthRoadmap == null) {
      return Center(
        child: Text(
          '성장 로드맵 데이터가 없습니다',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    final periods = ['month1', 'month3', 'month6', 'year1'];
    final periodNames = {'month1': '1개월', 'month3': '3개월', 'month6': '6개월', 'year1': '1년'};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final periodData = growthRoadmap[period] as Map<String, dynamic>?;
          if (periodData == null) return const SizedBox.shrink();

          final goal = FortuneTextCleaner.cleanNullable(periodData['goal'] as String?);
          final milestones = (periodData['milestones'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];

          return Padding(
            padding: EdgeInsets.only(bottom: index < periods.length - 1 ? 16 : 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      periodNames[period] ?? period,
                      style: DSTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (goal.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      goal,
                      style: DSTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                  if (milestones.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...milestones.map((milestone) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 14, color: DSColors.success),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              milestone,
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
              ),
            ),
          );
        }),
      ],
    );
  }
}
