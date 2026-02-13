import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/face_condition.dart';
import '../../providers/face_condition_tracker_provider.dart';

/// 컨디션 트렌드 그래프
/// 일주일간의 얼굴 컨디션 변화를 라인 그래프로 표시합니다.
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
class ConditionTrendGraph extends ConsumerStatefulWidget {
  /// 표시할 메트릭 타입들 (선택적)
  /// 기본: ['overall', 'complexion', 'puffiness', 'fatigue']
  final List<String>? visibleMetrics;

  /// 그래프 높이
  final double height;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 커스텀 데이터 (없으면 Provider에서 가져옴)
  final List<DailyCondition>? customData;

  const ConditionTrendGraph({
    super.key,
    this.visibleMetrics,
    this.height = 220,
    this.onTap,
    this.customData,
  });

  @override
  ConsumerState<ConditionTrendGraph> createState() =>
      _ConditionTrendGraphState();
}

class _ConditionTrendGraphState extends ConsumerState<ConditionTrendGraph>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // 선택된 메트릭 (터치로 하이라이트)
  String? _selectedMetric;

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

    Future.delayed(const Duration(milliseconds: 300), () {
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

  List<String> get _visibleMetrics =>
      widget.visibleMetrics ??
      ['overall', 'complexion', 'puffiness', 'fatigue'];

  @override
  Widget build(BuildContext context) {
    final trackerState = ref.watch(faceConditionTrackerProvider);
    final conditions = widget.customData ?? trackerState.weeklyConditions;

    // 데이터 없는 경우
    if (conditions.isEmpty) {
      return _buildEmptyState();
    }

    // 날짜순 정렬
    final sortedConditions = List<DailyCondition>.from(conditions)
      ..sort((a, b) => a.date.compareTo(b.date));

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.isDark ? DSColors.surfaceDark : DSColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.isDark ? DSColors.borderDark : DSColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(),
            const SizedBox(height: DSSpacing.md),

            // 범례
            _buildLegend(),
            const SizedBox(height: 12),

            // 그래프
            SizedBox(
              height: widget.height,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return LineChart(
                    _buildChartData(sortedConditions),
                  );
                },
              ),
            ),

            // 로딩 상태
            if (trackerState.isLoading) ...[
              const SizedBox(height: DSSpacing.sm),
              const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      DSColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// 헤더 빌드
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DSColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.show_chart,
            color: DSColors.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: DSSpacing.sm + 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 주 컨디션 변화',
              style: context.labelMedium.copyWith(
                color: context.isDark
                    ? DSColors.textPrimaryDark
                    : DSColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '매일의 변화를 한눈에 볼 수 있어요',
              style: context.labelSmall.copyWith(
                color: context.isDark
                    ? DSColors.textSecondaryDark
                    : DSColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 범례 빌드
  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _visibleMetrics.map((metric) {
        final (color, label) = _getMetricStyle(metric);
        final isSelected = _selectedMetric == metric;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMetric = _selectedMetric == metric ? null : metric;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: color.withValues(alpha: 0.5))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: context.labelSmall.copyWith(
                    color: context.isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 차트 데이터 빌드
  LineChartData _buildChartData(List<DailyCondition> conditions) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: context.isDark
                ? DSColors.borderDark.withValues(alpha: 0.5)
                : DSColors.border,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 20,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: context.labelSmall.copyWith(
                  color: context.isDark
                      ? DSColors.textSecondaryDark
                      : DSColors.textSecondary,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < conditions.length) {
                final date = conditions[index].date;
                final dayLabel = _getDayLabel(date);
                final isToday = _isToday(date);

                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dayLabel,
                    style: context.labelSmall.copyWith(
                      color: isToday
                          ? DSColors.accent
                          : context.isDark
                              ? DSColors.textSecondaryDark
                              : DSColors.textSecondary,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (conditions.length - 1).toDouble(),
      minY: 0,
      maxY: 100,
      lineBarsData: _buildLineBars(conditions),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < conditions.length) {
                final date = conditions[index].date;
                final dateStr = DateFormat('M/d (E)', 'ko_KR').format(date);

                // 어떤 메트릭인지 찾기
                String metricLabel = '';
                for (final metric in _visibleMetrics) {
                  final (color, label) = _getMetricStyle(metric);
                  if (color == spot.bar.gradient?.colors.first) {
                    metricLabel = label;
                    break;
                  }
                }

                return LineTooltipItem(
                  '$dateStr\n$metricLabel: ${spot.y.toInt()}',
                  context.labelSmall.copyWith(
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
    );
  }

  /// 라인 바 데이터 빌드
  List<LineChartBarData> _buildLineBars(List<DailyCondition> conditions) {
    final bars = <LineChartBarData>[];

    for (final metric in _visibleMetrics) {
      final (color, _) = _getMetricStyle(metric);
      final isHighlighted =
          _selectedMetric == null || _selectedMetric == metric;
      final effectiveColor = isHighlighted ? color : color.withValues(alpha: 0.3);

      bars.add(LineChartBarData(
        spots: _generateSpots(conditions, metric),
        isCurved: true,
        curveSmoothness: 0.3,
        gradient: LinearGradient(
          colors: [
            effectiveColor,
            effectiveColor.withValues(alpha: 0.7),
          ],
        ),
        barWidth: isHighlighted ? 3 : 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: isHighlighted,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: effectiveColor,
              strokeWidth: 2,
              strokeColor: context.isDark ? DSColors.surfaceDark : DSColors.surface,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: isHighlighted && _selectedMetric == metric,
          gradient: LinearGradient(
            colors: [
              effectiveColor.withValues(alpha: 0.2),
              effectiveColor.withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ));
    }

    return bars;
  }

  /// 스팟 데이터 생성
  List<FlSpot> _generateSpots(List<DailyCondition> conditions, String metric) {
    return conditions.asMap().entries.map((entry) {
      final condition = entry.value;
      double rawValue;

      switch (metric) {
        case 'overall':
          rawValue = condition.overallScore.toDouble();
          break;
        case 'complexion':
          rawValue = condition.complexionScore.toDouble();
          break;
        case 'puffiness':
          // 붓기는 낮을수록 좋으므로 반전
          rawValue = (100 - condition.puffinessLevel).toDouble();
          break;
        case 'fatigue':
          // 피로도는 낮을수록 좋으므로 반전
          rawValue = (100 - condition.fatigueLevel).toDouble();
          break;
        default:
          rawValue = condition.overallScore.toDouble();
      }

      // 애니메이션 적용
      final animatedValue = rawValue * _animation.value;
      return FlSpot(entry.key.toDouble(), animatedValue);
    }).toList();
  }

  /// 메트릭 스타일 반환
  (Color, String) _getMetricStyle(String metric) {
    switch (metric) {
      case 'overall':
        return (DSColors.accent, '종합');
      case 'complexion':
        return (DSColors.success, '혈색');
      case 'puffiness':
        return (DSColors.warning, '붓기');
      case 'fatigue':
        return (DSColors.accentSecondary, '피로도');
      default:
        return (DSColors.textSecondary, metric);
    }
  }

  /// 요일 라벨 반환
  String _getDayLabel(DateTime date) {
    if (_isToday(date)) return '오늘';

    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  /// 오늘 여부 확인
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark ? DSColors.borderDark : DSColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insert_chart_outlined,
              color: DSColors.accent.withValues(alpha: 0.6),
              size: 32,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            '아직 기록이 없어요',
            style: context.bodyMedium.copyWith(
              color: context.isDark
                  ? DSColors.textPrimaryDark
                  : DSColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            '매일 분석을 받으면 변화를 볼 수 있어요',
            style: context.labelSmall.copyWith(
              color: context.isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// 간단한 미니 트렌드 그래프 (작은 공간용)
class MiniConditionGraph extends ConsumerWidget {
  final double width;
  final double height;

  const MiniConditionGraph({
    super.key,
    this.width = 80,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerState = ref.watch(faceConditionTrackerProvider);
    final conditions = trackerState.weeklyConditions;

    if (conditions.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    // 최근 7개 데이터만
    final recentConditions = conditions.length > 7
        ? conditions.sublist(conditions.length - 7)
        : conditions;

    final sortedConditions = List<DailyCondition>.from(recentConditions)
      ..sort((a, b) => a.date.compareTo(b.date));

    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (sortedConditions.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: sortedConditions.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  e.value.overallScore.toDouble(),
                );
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: LinearGradient(
                colors: [
                  DSColors.accent,
                  DSColors.accent.withValues(alpha: 0.5),
                ],
              ),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    DSColors.accent.withValues(alpha: 0.15),
                    DSColors.accent.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
