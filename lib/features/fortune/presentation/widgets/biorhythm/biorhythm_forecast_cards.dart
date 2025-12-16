import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../../../../core/components/app_card.dart';
import '../../pages/biorhythm_result_page.dart';

class WeeklyForecastHeader extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const WeeklyForecastHeader({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      style: AppCardStyle.elevated,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '이번 주 바이오리듬 전망',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : DSColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${DateTime.now().month}월 ${DateTime.now().day}일 ~ ${DateTime.now().add(const Duration(days: 6)).month}월 ${DateTime.now().add(const Duration(days: 6)).day}일',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// 주간 리듬 차트
class WeeklyRhythmChart extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const WeeklyRhythmChart({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      style: AppCardStyle.outlined,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 50,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDark ? DSColors.textTertiary : DSColors.border,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                        
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final days = ['오늘', '내일', '모레', '3일후', '4일후', '5일후', '6일후'];
                    if (value.toInt() < days.length) {
                      return Text(
                        days[value.toInt()],
                        style: TextStyle(
                          color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                          
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              // 신체 리듬
              LineChartBarData(
                spots: biorhythmData.physicalWeek.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), (entry.value + 100) / 2);
                }).toList(),
                isCurved: true,
                color: const Color(0xFFFF5A5F),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFFFF5A5F),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFFFF5A5F).withValues(alpha: 0.1),
                ),
              ),
              // 감정 리듬
              LineChartBarData(
                spots: biorhythmData.emotionalWeek.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), (entry.value + 100) / 2);
                }).toList(),
                isCurved: true,
                color: const Color(0xFF00C896),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFF00C896),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              ),
              // 지적 리듬
              LineChartBarData(
                spots: biorhythmData.intellectualWeek.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), (entry.value + 100) / 2);
                }).toList(),
                isCurved: true,
                color: const Color(0xFF0068FF),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFF0068FF),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 주요 날짜들
class ImportantDatesCard extends StatelessWidget {
  final BiorhythmData biorhythmData;
  
  const ImportantDatesCard({
    super.key,
    required this.biorhythmData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 최고/최저 날짜 찾기
    final bestDay = _findBestDay();
    final worstDay = _findWorstDay();

    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 주요 날짜',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : DSColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 최고의 날
          _buildDateItem(
            context,
            '최고의 날',
            bestDay['date'] as String,
            bestDay['description'] as String,
            Icons.trending_up_rounded,
            const Color(0xFF00C851),
          ),
          const SizedBox(height: 12),

          // 주의가 필요한 날
          _buildDateItem(
            context,
            '주의가 필요한 날',
            worstDay['date'] as String,
            worstDay['description'] as String,
            Icons.warning_rounded,
            const Color(0xFFFF9500),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(
    BuildContext context,
    String title,
    String date,
    String description,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title - $date',
                style: DSTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : DSColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: DSTypography.bodySmall.copyWith(
                  color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _findBestDay() {
    double bestScore = -1;
    int bestDayIndex = 0;
    
    for (int i = 0; i < 7; i++) {
      final avgScore = (biorhythmData.physicalWeek[i] + 
                       biorhythmData.emotionalWeek[i] + 
                       biorhythmData.intellectualWeek[i]) / 3;
      if (avgScore > bestScore) {
        bestScore = avgScore;
        bestDayIndex = i;
      }
    }
    
    final date = DateTime.now().add(Duration(days: bestDayIndex));
    final dayNames = ['오늘', '내일', '모레'];
    final dateStr = bestDayIndex < 3 
        ? dayNames[bestDayIndex]
        : '${date.month}/${date.day}';
    
    return {
      'date': dateStr,
      'description': '모든 리듬이 높아 활동하기 좋은 날이에요',
    };
  }

  Map<String, String> _findWorstDay() {
    double worstScore = 101;
    int worstDayIndex = 0;
    
    for (int i = 0; i < 7; i++) {
      final avgScore = (biorhythmData.physicalWeek[i] + 
                       biorhythmData.emotionalWeek[i] + 
                       biorhythmData.intellectualWeek[i]) / 3;
      if (avgScore < worstScore) {
        worstScore = avgScore;
        worstDayIndex = i;
      }
    }
    
    final date = DateTime.now().add(Duration(days: worstDayIndex));
    final dayNames = ['오늘', '내일', '모레'];
    final dateStr = worstDayIndex < 3 
        ? dayNames[worstDayIndex]
        : '${date.month}/${date.day}';
    
    return {
      'date': dateStr,
      'description': '컨디션 관리에 신경 써야 하는 날이에요',
    };
  }
}

// 주간 활동 가이드
