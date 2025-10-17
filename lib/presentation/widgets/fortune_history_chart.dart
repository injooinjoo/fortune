import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FortuneHistoryChart extends StatelessWidget {
  final List<int> fortuneScores;
  final bool isLoading;
  final VoidCallback? onRefresh;
  
  const FortuneHistoryChart({
    super.key,
    required this.fortuneScores,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      child: Container(
        padding: AppSpacing.paddingAll20,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppDimensions.borderRadiusMedium,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '운세 히스토리',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '최근 7일',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (fortuneScores.isEmpty)
                        Text(
                          '예상 운세',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                  if (onRefresh != null) ...[
                    SizedBox(width: AppSpacing.spacing2),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: AppDimensions.iconSizeSmall,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: onRefresh,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.spacing5),
          
          // 차트
          SizedBox(
            height: 200,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _buildChart(context, _getDisplayScores()),
          ),
          
          SizedBox(height: AppSpacing.spacing5),
          _buildStatistics(context, _getDisplayScores()),
        ],
      ),
      ),
    );
  }

  /// 표시할 점수 데이터를 반환 (실제 데이터가 없으면 현실적인 과거 데이터 생성)
  List<int> _getDisplayScores() {
    if (fortuneScores.isNotEmpty) {
      return fortuneScores;
    }

    // 과거 데이터가 없을 때 현실적인 7일 데이터 생성
    final now = DateTime.now();
    final baseScore = 65; // 기본 점수
    final randomScores = <int>[];

    for (int i = 6; i >= 0; i--) {
      final dayOffset = i;
      // 주말과 평일에 따른 점수 조정
      final isWeekend = (now.weekday - dayOffset) % 7 >= 5;
      final weekendBonus = isWeekend ? 5 : 0;

      // 자연스러운 변동 (-10 ~ +15)
      final variation = (DateTime.now().millisecondsSinceEpoch * (i + 1)) % 26 - 10;
      final dayScore = (baseScore + weekendBonus + variation).clamp(45, 85);

      randomScores.add(dayScore);
    }

    return randomScores;
  }

  Widget _buildChart(BuildContext context, List<int> scores) {
    final theme = Theme.of(context);

    // 최근 7일 데이터만 사용
    final recentScores = scores.length > 7
        ? scores.sublist(scores.length - 7)
        : scores;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final days = ['월', '화', '수', '목', '금', '토', '일'];
                if (value.toInt() >= 0 && value.toInt() < recentScores.length) {
                  return Text(
                    days[value.toInt() % 7],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: recentScores.length - 1,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: recentScores.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.toDouble());
            }).toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatistics(BuildContext context, List<int> scores) {
    final average = scores.reduce((a, b) => a + b) / scores.length;
    final highest = scores.reduce((a, b) => a > b ? a : b);
    final lowest = scores.reduce((a, b) => a < b ? a : b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          '평균',
          '${average.toStringAsFixed(1)}점',
          Icons.analytics,
        ),
        _buildStatItem(
          context,
          '최고',
          '$highest점',
          Icons.trending_up,
        ),
        _buildStatItem(
          context,
          '최저',
          '$lowest점',
          Icons.trending_down,
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSizeSmall,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: AppSpacing.spacing1),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}