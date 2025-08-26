import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/fortune_type_names.dart';
// import '../../../../shared/glassmorphism/glass_container.dart'; // TODO: Remove if not needed
import '../../domain/models/fortune_history.dart';

class CategoryPieChart extends StatelessWidget {
  final List<FortuneHistory> history;
  final double fontScale;

  const CategoryPieChart({
    Key? key,
    required this.history,
    required this.fontScale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryData = _groupHistoryByCategory(history);
    
    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = sortedCategories.take(5).toList();
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.error];
    
    return Container(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '운세 유형별 분포',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: topCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final percentage = (category.value / history.length * 100);
                        
                        return PieChartSectionData(
                          value: category.value.toDouble(),
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 80,
                          titleStyle: TextStyle(
                            fontSize: 12 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          color: colors[index % colors.length],
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.key,
                            style: TextStyle(
                              fontSize: 14 * fontScale,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _groupHistoryByCategory(List<FortuneHistory> history) {
    final Map<String, int> categoryCount = {};
    
    for (final item in history) {
      final category = FortuneTypeNames.getName(item.fortuneType);
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    
    return categoryCount;
  }
}

class MonthlyTrendChart extends StatelessWidget {
  final List<FortuneHistory> history;
  final double fontScale;

  const MonthlyTrendChart({
    Key? key,
    required this.history,
    required this.fontScale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthlyData = _groupHistoryByMonth(history);
    final months = monthlyData.keys.toList();
    final values = monthlyData.values.toList();
    
    if (months.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월별 운세 조회 추이',
            style: TextStyle(
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      strokeWidth: 1);
                  }),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12));
                        }
                        return const Text('');
                      })),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                    left: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                minX: 0,
                maxX: months.length - 1.0,
                minY: 0,
                maxY: maxValue.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: values.asMap().entries.map((entry) {
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
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _groupHistoryByMonth(List<FortuneHistory> history) {
    final Map<String, int> monthlyCount = {};
    
    // Get last 6 months
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('M월').format(month);
      monthlyCount[monthKey] = 0;
    }
    
    // Count history by month
    for (final item in history) {
      final monthKey = DateFormat('M월').format(item.createdAt);
      if (monthlyCount.containsKey(monthKey)) {
        monthlyCount[monthKey] = monthlyCount[monthKey]! + 1;
      }
    }
    
    return monthlyCount;
  }
}

class FortuneCharts extends StatelessWidget {
  final List<FortuneHistory> filteredHistory;
  final double fontScale;

  const FortuneCharts({
    Key? key,
    required this.filteredHistory,
    required this.fontScale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoryPieChart(
          history: filteredHistory,
          fontScale: fontScale,
        ),
        const SizedBox(height: 24),
        MonthlyTrendChart(
          history: filteredHistory,
          fontScale: fontScale,
        ),
      ],
    );
  }
}