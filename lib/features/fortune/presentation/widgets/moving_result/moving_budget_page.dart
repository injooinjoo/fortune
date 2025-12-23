import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/design_system/design_system.dart';
import 'moving_fortune_data.dart';
import 'moving_result_utils.dart';

/// 페이지 5: 예산 분석
class MovingBudgetPage extends StatelessWidget {
  final MovingFortuneData fortuneData;

  const MovingBudgetPage({
    super.key,
    required this.fortuneData,
  });

  @override
  Widget build(BuildContext context) {
    final totalBudget = fortuneData.budgetBreakdown.values.reduce((a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예상 이사 비용',
            style: DSTypography.headingLarge,
          ),
          const SizedBox(height: 20),

          // 총 비용 카드
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '예상 총 비용',
                  style: DSTypography.bodyMedium.copyWith(color: DSColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalBudget.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}만원',
                  style: DSTypography.displayLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: DSColors.accent,
                  ),
                ).animate()
                  .fadeIn()
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                const SizedBox(height: 20),

                // 도넛 차트
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: fortuneData.budgetBreakdown.entries.map((entry) {
                        final percentage = (entry.value / totalBudget * 100).round();
                        return PieChartSectionData(
                          color: MovingResultUtils.getBudgetColor(entry.key),
                          value: entry.value.toDouble(),
                          title: '$percentage%',
                          radius: 40,
                          titleStyle: DSTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 항목별 상세
          Text(
            '항목별 상세',
            style: DSTypography.headingMedium,
          ),
          const SizedBox(height: 12),

          ...fortuneData.budgetBreakdown.entries.map((entry) {
            final percentage = (entry.value / totalBudget * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: DSColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: MovingResultUtils.getBudgetColor(entry.key),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: DSTypography.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '전체의 $percentage%',
                            style: DSTypography.labelSmall.copyWith(
                              color: DSColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${entry.value}만원',
                      style: DSTypography.headingSmall,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 절약 팁
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_rounded,
                  color: DSColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '절약 TIP',
                        style: DSTypography.headingSmall.copyWith(
                          color: DSColors.warning,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '평일 이사 시 약 20% 절약 가능합니다',
                        style: DSTypography.bodyMedium.copyWith(
                          color: DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
