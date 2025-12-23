import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/design_system/design_system.dart';
import 'moving_fortune_data.dart';
import 'moving_result_utils.dart';

/// 페이지 2: 시기별 운세
class MovingTimingPage extends StatelessWidget {
  final MovingFortuneData fortuneData;

  const MovingTimingPage({
    super.key,
    required this.fortuneData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3개월 이사운 흐름',
            style: DSTypography.headingLarge,
          ),
          const SizedBox(height: 20),

          // 운세 차트
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(
                            color: DSColors.border,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 30,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.now().add(Duration(days: value.toInt()));
                              return Text(
                                '${date.month}/${date.day}',
                                style: DSTypography.labelSmall,
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: DSTypography.labelSmall,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 89,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: fortuneData.monthlyScores.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              DSColors.accent.withValues(alpha: 0.8),
                              DSColors.accent,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                DSColors.accent.withValues(alpha: 0.1),
                                DSColors.accent.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 범례
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegend('매우 좋음', DSColors.success),
                    _buildLegend('좋음', DSColors.accent),
                    _buildLegend('보통', DSColors.warning),
                    _buildLegend('주의', DSColors.error),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 추천 날짜 리스트
          Text(
            '추천 이사 날짜 TOP 5',
            style: DSTypography.headingMedium,
          ),
          const SizedBox(height: 12),

          ...fortuneData.luckyDates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? DSColors.warning.withValues(alpha: 0.2)
                            : DSColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: DSTypography.headingMedium.copyWith(
                            color: index == 0 ? DSColors.warning : DSColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.month}월 ${date.day}일 (${MovingResultUtils.getWeekdayName(date.weekday)})',
                            style: DSTypography.headingSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            index == 0 ? '최고의 이사 날짜입니다' : '좋은 기운이 가득한 날입니다',
                            style: DSTypography.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    if (index == 0)
                      const Icon(
                        Icons.star_rounded,
                        color: DSColors.warning,
                        size: 24,
                      ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: Duration(milliseconds: 200 + index * 100))
                .slideX(begin: 0.1, end: 0),
            );
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: DSTypography.labelSmall),
      ],
    );
  }
}
