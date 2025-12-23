import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fortune/core/design_system/design_system.dart';

class LoveTrendChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  
  const LoveTrendChart({
    super.key,
    required this.data,
  });

  @override
  State<LoveTrendChart> createState() => _LoveTrendChartState();
}

class _LoveTrendChartState extends State<LoveTrendChart>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return LineChart(
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
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: DSTypography.labelSmall.copyWith(
                          color: DSColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            widget.data[index]['week'],
                            style: DSTypography.labelSmall.copyWith(
                              color: DSColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (widget.data.length - 1).toDouble(),
              minY: 60,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: _generateSpots(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      DSColors.accent,
                      DSColors.accent.withValues(alpha: 0.7),
                    ],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: DSColors.accent,
                        strokeWidth: 3,
                        strokeColor: DSColors.background,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        DSColors.accent.withValues(alpha: 0.3),
                        DSColors.accent.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      if (index >= 0 && index < widget.data.length) {
                        return LineTooltipItem(
                          '${widget.data[index]['week']}\n${spot.y.toInt()}점',
                          DSTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, duration: 800.ms);
  }

  List<FlSpot> _generateSpots() {
    return widget.data.asMap().entries.map((entry) {
      final animatedValue = entry.value['score'] * _animation.value;
      return FlSpot(entry.key.toDouble(), animatedValue);
    }).toList();
  }
}