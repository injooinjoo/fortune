import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/typography_unified.dart';

/// ⏱️ 시간대별 점수 그래프 카드
class HourlyScoreGraphCard extends StatelessWidget {
  final List<FlSpot> spots;
  final int bestHour;
  final int worstHour;
  final bool isDark;

  const HourlyScoreGraphCard({
    super.key,
    required this.spots,
    required this.bestHour,
    required this.worstHour,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간대별 운세 그래프',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '하루 24시간 운세 흐름과 추천 시간대',
          style: context.bodySmall.copyWith(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 12),

        // 베스트/워스트 시간대 요약
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('吉', style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ZenSerif',
                      )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '베스트',
                        style: context.labelSmall.copyWith(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$bestHour시',
                        style: context.labelSmall.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 36,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
              ),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('凶', style: TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ZenSerif',
                      )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '주의',
                        style: context.labelSmall.copyWith(
                          color: const Color(0xFFE53935),
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$worstHour시',
                        style: context.labelSmall.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          height: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 6,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}시',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  // U08: 더욱 밝고 선명한 색상으로 가시성 대폭 개선
                  gradient: LinearGradient(
                    colors: isDark
                      ? [const Color(0xFF64B5F6), const Color(0xFF81C784)] // 다크모드: 더 밝은 파랑 → 더 밝은 녹색
                      : [const Color(0xFF1E88E5), const Color(0xFF43A047)], // 라이트모드: 더 선명한 파랑 → 녹색
                  ),
                  barWidth: 4,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      return spot.x.toInt() == bestHour || spot.x.toInt() == worstHour;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      final isBest = spot.x.toInt() == bestHour;
                      // 전통 색상: 吉(녹색) / 凶(적색)
                      return FlDotCirclePainter(
                        radius: 7,
                        color: isBest ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                        strokeWidth: 2.5,
                        strokeColor: isDark ? Colors.white : Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: isDark
                        ? [
                            const Color(0xFF64B5F6).withValues(alpha: 0.45), // 더 강한 그라디언트
                            const Color(0xFF81C784).withValues(alpha: 0.15),
                          ]
                        : [
                            const Color(0xFF1E88E5).withValues(alpha: 0.35),
                            const Color(0xFF43A047).withValues(alpha: 0.12),
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

        // U08: 아래 공백 활용 - 시간대 활용 팁
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFFB300),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '베스트 시간대에 중요한 결정이나 미팅을 배치하세요',
                  style: context.labelSmall.copyWith(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
