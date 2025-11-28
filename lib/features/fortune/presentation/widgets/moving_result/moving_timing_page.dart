import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
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
            style: TossTheme.heading2,
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
                          return FlLine(
                            color: TossTheme.borderGray200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 30,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.now().add(Duration(days: value.toInt()));
                              return Text(
                                '${date.month}/${date.day}',
                                style: TossTheme.caption,
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
                                style: TossTheme.caption,
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
                              TossTheme.primaryBlue.withValues(alpha: 0.8),
                              TossTheme.primaryBlue,
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                TossTheme.primaryBlue.withValues(alpha: 0.1),
                                TossTheme.primaryBlue.withValues(alpha: 0.0),
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
                    _buildLegend('매우 좋음', TossDesignSystem.success),
                    _buildLegend('좋음', TossTheme.primaryBlue),
                    _buildLegend('보통', TossDesignSystem.warningOrange),
                    _buildLegend('주의', TossDesignSystem.error),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 추천 날짜 리스트
          Text(
            '추천 이사 날짜 TOP 5',
            style: TossTheme.heading3,
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
                            ? TossDesignSystem.warningOrange.withValues(alpha: 0.2)
                            : TossTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TossTheme.heading3.copyWith(
                            color: index == 0 ? TossDesignSystem.warningOrange : TossTheme.primaryBlue,
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
                            style: TossTheme.heading4,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            index == 0 ? '최고의 이사 날짜입니다' : '좋은 기운이 가득한 날입니다',
                            style: TossTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    if (index == 0)
                      Icon(
                        Icons.star_rounded,
                        color: TossDesignSystem.warningOrange,
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
        Text(label, style: TossTheme.caption),
      ],
    );
  }
}
