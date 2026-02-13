import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/models/health_fortune_model.dart';
import '../../../../core/design_system/design_system.dart';

class HealthTimelineChart extends StatefulWidget {
  final HealthTimeline timeline;

  const HealthTimelineChart({
    super.key,
    required this.timeline,
  });

  @override
  State<HealthTimelineChart> createState() => _HealthTimelineChartState();
}

class _HealthTimelineChartState extends State<HealthTimelineChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _chartAnimation;
  int? _touchedSpotIndex;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _chartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: context.colors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '시간대별 컨디션',
                style: context.heading3.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 차트
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return LineChart(
                  _createLineChartData(),
                  duration: const Duration(milliseconds: 250),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 시간대별 상세 정보
          _buildTimeSlotDetails(),

          // 최적 활동 시간
          if (widget.timeline.bestTimeActivity != null) ...[
            const SizedBox(height: 16),
            _buildBestTimeCard(),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  LineChartData _createLineChartData() {
    final spots = [
      FlSpot(
          0,
          widget.timeline.morning.conditionScore.toDouble() *
              _chartAnimation.value),
      FlSpot(
          1,
          widget.timeline.afternoon.conditionScore.toDouble() *
              _chartAnimation.value),
      FlSpot(
          2,
          widget.timeline.evening.conditionScore.toDouble() *
              _chartAnimation.value),
    ];

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: context.colors.divider,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final style = context.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = Text('오전',
                      style:
                          style.copyWith(color: context.colors.textSecondary));
                  break;
                case 1:
                  text = Text('오후',
                      style:
                          style.copyWith(color: context.colors.textSecondary));
                  break;
                case 2:
                  text = Text('저녁',
                      style:
                          style.copyWith(color: context.colors.textSecondary));
                  break;
                default:
                  text = const Text('');
                  break;
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: text,
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            reservedSize: 42,
            getTitlesWidget: (double value, TitleMeta meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  '${value.toInt()}',
                  style: context.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 2,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colors.accent,
              context.colors.accent.withValues(alpha: 0.7),
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: context.colors.accent,
                strokeWidth: 3,
                strokeColor: context.colors.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colors.accent.withValues(alpha: 0.3),
                context.colors.accent.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => context.colors.accent,
          tooltipRoundedRadius: 8,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              String timeLabel;
              String description;

              switch (touchedSpot.x.toInt()) {
                case 0:
                  timeLabel = '오전';
                  description = widget.timeline.morning.description;
                  break;
                case 1:
                  timeLabel = '오후';
                  description = widget.timeline.afternoon.description;
                  break;
                case 2:
                  timeLabel = '저녁';
                  description = widget.timeline.evening.description;
                  break;
                default:
                  timeLabel = '';
                  description = '';
              }

              return LineTooltipItem(
                '$timeLabel\n${touchedSpot.y.toInt()}점\n$description',
                context.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            if (touchResponse != null &&
                touchResponse.lineBarSpots != null &&
                touchResponse.lineBarSpots!.isNotEmpty) {
              _touchedSpotIndex = touchResponse.lineBarSpots!.first.x.toInt();
            } else {
              _touchedSpotIndex = null;
            }
          });
        },
      ),
    );
  }

  Widget _buildTimeSlotDetails() {
    final timeSlots = [
      widget.timeline.morning,
      widget.timeline.afternoon,
      widget.timeline.evening,
    ];

    return Column(
      children: timeSlots.asMap().entries.map((entry) {
        final index = entry.key;
        final timeSlot = entry.value;
        final isHighlighted = _touchedSpotIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHighlighted
                ? context.colors.accent.withValues(alpha: 0.1)
                : context.colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: isHighlighted
                ? Border.all(
                    color: context.colors.accent.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              // 컨디션 점수
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getScoreColor(timeSlot.conditionScore),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${timeSlot.conditionScore}',
                    style: context.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 시간대 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeSlot.timeLabel,
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isHighlighted
                            ? context.colors.accent
                            : context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeSlot.description,
                      style: context.buttonMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 추천사항 아이콘
              if (timeSlot.recommendations != null &&
                  timeSlot.recommendations!.isNotEmpty)
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: context.colors.accent,
                  size: 16,
                ),
            ],
          ),
        )
            .animate(delay: (300 + index * 100).ms)
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildBestTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSColors.success.withValues(alpha: 0.1),
            context.colors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: context.colors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최적 활동 시간',
                  style: context.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.timeline.bestTimeActivity!,
                  style: context.buttonMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50); // 고유 색상 - 건강 우수
    if (score >= 60) return const Color(0xFF2196F3); // 고유 색상 - 건강 양호
    if (score >= 40) return const Color(0xFFFF9800); // 고유 색상 - 건강 주의
    return const Color(0xFFFF5722); // 고유 색상 - 건강 경고
  }
}
