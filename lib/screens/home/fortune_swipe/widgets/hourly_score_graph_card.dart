import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/font_config.dart';

/// ⏱️ 시간대별 점수 그래프 카드
class HourlyScoreGraphCard extends StatelessWidget {
  final List<FlSpot> spots;
  final int bestHour;
  final int worstHour;

  // 고유 색상: 吉/凶 전통 표시 색상 (DS 토큰에 매칭 없음)
  static const _goodFortuneGreen = Color(0xFF4CAF50); // 고유 색상: 吉 녹색
  static const _badFortunRed = Color(0xFFE53935); // 고유 색상: 凶 적색

  const HourlyScoreGraphCard({
    super.key,
    required this.spots,
    required this.bestHour,
    required this.worstHour,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간대별 운세 그래프',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '하루 24시간 운세 흐름과 추천 시간대',
          style: context.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),

        const SizedBox(height: 12),

        // 베스트/워스트 시간대 요약
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
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
                      color: _goodFortuneGreen.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('吉', style: TextStyle(
                        color: _goodFortuneGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontConfig.primary,
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
                          color: _goodFortuneGreen,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$bestHour시',
                        style: context.labelSmall.copyWith(
                          color: context.colors.textPrimary,
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
                color: context.colors.divider,
              ),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _badFortunRed.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('凶', style: TextStyle(
                        color: _badFortunRed,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontConfig.primary,
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
                          color: _badFortunRed,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$worstHour시',
                        style: context.labelSmall.copyWith(
                          color: context.colors.textPrimary,
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
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: context.colors.divider,
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
                          color: context.colors.textTertiary,
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
                  // 고유 색상: 그래프 그라디언트 라인
                  gradient: LinearGradient(
                    colors: context.isDark
                      ? [const Color(0xFF64B5F6), const Color(0xFF81C784)] // 고유 색상: 다크모드 파랑→녹색
                      : [const Color(0xFF1E88E5), const Color(0xFF43A047)], // 고유 색상: 라이트모드 파랑→녹색
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
                        color: isBest ? _goodFortuneGreen : _badFortunRed,
                        strokeWidth: 2.5,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    // 고유 색상: 그래프 영역 그라디언트
                    gradient: LinearGradient(
                      colors: context.isDark
                        ? [
                            const Color(0xFF64B5F6).withValues(alpha: 0.45), // 고유 색상
                            const Color(0xFF81C784).withValues(alpha: 0.15), // 고유 색상
                          ]
                        : [
                            const Color(0xFF1E88E5).withValues(alpha: 0.35), // 고유 색상
                            const Color(0xFF43A047).withValues(alpha: 0.12), // 고유 색상
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
            color: context.colors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.colors.border,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: DSColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '베스트 시간대에 중요한 결정이나 미팅을 배치하세요',
                  style: context.labelSmall.copyWith(
                    color: context.colors.textSecondary,
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
