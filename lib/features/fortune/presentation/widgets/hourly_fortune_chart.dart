import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class HourlyFortuneChart extends StatefulWidget {
  final Map<String, dynamic> sajuData;
  final DateTime currentTime;

  const HourlyFortuneChart({
    Key? key,
    required this.sajuData,
    required this.currentTime,
  }) : super(key: key);

  @override
  State<HourlyFortuneChart> createState() => _HourlyFortuneChartState();
}

class _HourlyFortuneChartState extends State<HourlyFortuneChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedIndex;

  // 시간대별 이름
  static const List<String> timeNames = [
    '자시': '축시': '인시', '묘시', '진시', '사시',
    '오시', '미시', '신시', '유시', '술시', '해시',
];

  // 오행 색상
  static const Map<String, Color> elementColors = {
    '목': AppColors.success,
    '화': AppColors.warning,
    '토': FortuneColors.goldLight,
    '금': AppColors.textTertiary,
    '수': null,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.durationSkeleton,
      vsync: this);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut);
    _animationController.forward();
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.spacing4),
        _buildChart(),
        const SizedBox(height: AppSpacing.spacing4),
        _buildLegend(),
        const SizedBox(height: AppSpacing.spacing4),
        _buildCurrentTimeInfo(),
      ],
    );
}

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '시간별 운기',
              style: Theme.of(context).textTheme.bodyMedium,
            const SizedBox(height: AppSpacing.spacing1),
            Text(
              '오늘의 시간대별 운세 흐름',
              style: Theme.of(context).textTheme.bodyMedium,
          ],
        ),
        Icon(
          Icons.access_time,
          color: Colors.white54,
          size: 32,
        ),
      ]
    );
}

  Widget _buildChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GlassContainer(
          height: AppSpacing.spacing24 * 3.125,
          padding: AppSpacing.paddingAll20,
          child: LineChart(
            _mainChartData(),
        );
},
    );
}

  LineChartData _mainChartData() {
    final hourlyFortune = _calculateHourlyFortune();
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: 0.2,
        verticalInterval: 2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withValues(alpha: 0.1),
            strokeWidth: 1
          );
},
        getDrawingVerticalLine: (value) {
          // 현재 시간 강조
          if (value.toInt() == widget.currentTime.hour) {
            return FlLine(
              color: Colors.purple.withValues(alpha: 0.5),
              strokeWidth: 2,
              dashArray: [5, 5],
            );
}
          return FlLine(
            color: Colors.white.withValues(alpha: 0.1),
            strokeWidth: 1
          );
},
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 2,
            getTitlesWidget: (value, meta) {
              final hour = value.toInt();
              if (hour % 2 == 0 && hour < 24) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.spacing2),
                  child: Text(
                    timeNames[hour ~/ 2],
                    style: Theme.of(context).textTheme.bodyMedium
                );
}
              return const SizedBox();
},
          ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 0.2,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium
              );
},
          ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: 1,
      lineBarsData: [
        // 전체 운기 라인
        LineChartBarData(
          spots: List.generate(24, (hour) {
            final fortune = hourlyFortune[hour];
            return FlSpot(hour.toDouble(), fortune * _animation.value);
}),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.purple.withValues(alpha: 0.8),
              Colors.blue.withValues(alpha: 0.8),
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isCurrentHour = index == widget.currentTime.hour;
              return FlDotCirclePainter(
                radius: isCurrentHour ? 6 : 4,
                color: isCurrentHour ? Colors.purple : Colors.white,
                strokeWidth: 2,
                strokeColor: isCurrentHour ? Colors.white : Colors.purple
              );
},
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.2),
                Colors.blue.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipPadding: AppSpacing.paddingAll8,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final hour = touchedSpot.x.toInt();
              final fortune = touchedSpot.y;
              final timeRange = '${hour.toString().padLeft(2, '0')}:00~${((hour + 1) % 24).toString().padLeft(2, '0')}:00';
              final element = _getHourElement(hour);
              
              return LineTooltipItem(
                '$timeRange\n${timeNames[hour ~/ 2]} (${element}원소)\n운기: ${(fortune * 100).toInt()}%',
                Theme.of(context).textTheme.bodyMedium
              );
}).toList();
},
        ),
        touchCallback: (event, response) {
          setState(() {
            if (response?.lineBarSpots != null &&
                response!.lineBarSpots!.isNotEmpty) {
              _touchedIndex = response.lineBarSpots!.first.spotIndex;
} else {
              _touchedIndex = null;
}
          });
},
      
    );
}

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('좋음': null,
        _buildLegendItem('보통': null,
        _buildLegendItem('주의'),
        _buildLegendItem('현재 시간'),
      ]
    );
}

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: AppSpacing.spacing4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppDimensions.borderRadiusSmall,
          ),
        const SizedBox(width: AppSpacing.spacing1),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
      ]
    );
}

  Widget _buildCurrentTimeInfo() {
    final currentHour = widget.currentTime.hour;
    final currentFortune = _calculateHourlyFortune()[currentHour];
    final currentElement = _getHourElement(currentHour);
    final timeName = timeNames[currentHour ~/ 2];
    
    return GlassContainer(
      padding: AppSpacing.paddingAll16,
      gradient: LinearGradient(
        colors: [
          elementColors[currentElement]!.withValues(alpha: 0.2),
          elementColors[currentElement]!.withValues(alpha: 0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재 시간 운세',
                style: Theme.of(context).textTheme.bodyMedium,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1 * 1.5),
                decoration: BoxDecoration(
                  color: _getFortuneColor(currentFortune),
                  borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
                child: Text(
                  '${(currentFortune * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
            ],
          ),
          const SizedBox(height: AppSpacing.spacing3),
          Text(
            '${currentHour.toString().padLeft(2, '0')}:00 - $timeName (${currentElement}원소)',
            style: Theme.of(context).textTheme.bodyMedium,
          const SizedBox(height: AppSpacing.spacing2),
          Text(
            _getFortuneDescription(currentFortune, currentElement),
            style: Theme.of(context).textTheme.bodyMedium,
          const SizedBox(height: AppSpacing.spacing3),
          _buildFortuneAdvice(currentFortune, currentElement),
        ],
      
    );
}

  Widget _buildFortuneAdvice(double fortune, String element) {
    String advice;
    IconData icon;
    
    if (fortune >= 0.8) {
      advice = '최고의 운기! 중요한 일을 추진하기 좋은 시간입니다.';
      icon = Icons.star;
} else if (fortune >= 0.6) {
      advice = '좋은 운기가 흐르고 있습니다. 적극적으로 활동하세요.';
      icon = Icons.thumb_up;
} else if (fortune >= 0.4) {
      advice = '평범한 시간대입니다. 차분하게 일을 처리하세요.';
      icon = Icons.info_outline;
} else {
      advice = '신중함이 필요한 시간입니다. 중요한 결정은 미루세요.';
      icon = Icons.warning_amber;
}
    
    return Row(
      children: [
        Icon(
          icon,
          color: _getFortuneColor(fortune),
          size: 20,
        ),
        const SizedBox(width: AppSpacing.spacing2),
        Expanded(
          child: Text(
            advice,
            style: Theme.of(context).textTheme.bodyMedium,
      ]
    );
}

  // 시간별 운기 계산
  List<double> _calculateHourlyFortune() {
    final dayElement = widget.sajuData['day']['element'] ?? '토';
    final fortunes = <double>[];
    
    for (int hour = 0; hour < 24; hour++) {
      final hourElement = _getHourElement(hour);
      final relation = _calculateElementRelation(dayElement, hourElement);
      
      // 현재 시간 근처 보정
      final timeDiff = (hour - widget.currentTime.hour).abs();
      final timeBonus = timeDiff <= 2 ? 0.1 * (3 - timeDiff) / 3 : 0;
      
      fortunes.add(math.min(relation + timeBonus, 1.0);
}
    
    return fortunes;
}

  // 시간대별 오행
  String _getHourElement(int hour) {
    final branchElements = {
      0: '수': 1: '토': 2: '목', 3: '목',
      4: '토', 5: '화', 6: '화', 7: '토',
      8: '금', 9: '금', 10: '토', 11: '수',
    };
    
    return branchElements[hour ~/ 2] ?? '토';
}

  // 오행 상생상극 관계 계산
  double _calculateElementRelation(String element1, String element2) {
    // 상생: 목→화→토→금→수→목
    final generating = {
      '목': '화': '화': '토': '토': '금', '금': '수', '수': '목',
};
    
    // 상극: 목→토→수→화→금→목
    final overcoming = {
      '목': '토', '토': '수', '수': '화', '화': '금', '금': '목',
};
    
    if (element1 == element2) {
      return 0.7; // 같은 오행,
} else if (generating[element1] == element2) {
      return 0.9; // 상생 (생하는,
    } else if (generating[element2] == element1) {
      return 0.8; // 상생 (생받는,
    } else if (overcoming[element1] == element2) {
      return 0.3; // 상극 (극하는,
    } else if (overcoming[element2] == element1) {
      return 0.4; // 상극 (극받는,
    }
    
    return 0.6; // 중립,
}

  Color _getFortuneColor(double fortune) {
    if (fortune >= 0.7) return Colors.green;
    if (fortune >= 0.5) return Colors.orange;
    return Colors.red;
}

  String _getFortuneDescription(double fortune, String element) {
    if (fortune >= 0.8) {
      return '${element}의 기운이 매우 강하게 작용하는 최상의 시간대입니다. 모든 일이 순조롭게 진행될 것입니다.';
} else if (fortune >= 0.6) {
      return '${element}의 긍정적인 에너지가 흐르는 좋은 시간입니다. 계획한 일을 추진하기에 적합합니다.';
} else if (fortune >= 0.4) {
      return '${element}의 기운이 안정적인 평범한 시간대입니다. 일상적인 업무를 처리하기 좋습니다.';
} else {
      return '${element}의 기운이 약하거나 충돌하는 시간입니다. 중요한 일은 다른 시간대로 미루는 것이 좋습니다.';
}
  },
}