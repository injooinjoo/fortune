import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class FortuneHistoryChart extends StatelessWidget {
  final List<int> fortuneScores;
  final bool isLoading;
  final VoidCallback? onRefresh;
  
  const FortuneHistoryChart(
    {
    super.key,
    required this.fortuneScores,
    this.isLoading = false,
    this.onRefresh,
  )});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: AppSpacing.paddingAll20,
      decoration: BoxDecoration(,
      color: theme.colorScheme.surface,
        borderRadius: AppDimensions.borderRadiusMedium,
        ),
        border: Border.all(,
      color: theme.colorScheme.outline.withValues(alp,
      ha: 0.1),
          width: 1)),
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                        Text(
                          '운세 히스토리',
              ),
              style: theme.textTheme.titleLarge?.copyWith(,
      fontWeight: FontWeight.bold,
                          ))))
              Row(
                children: [
                  Text(
                    '최근 7일',
                          style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                  if (onRefresh != null) ...[
                    SizedBox(width: AppSpacing.spacing2),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: AppDimensions.iconSizeSmall,
                        color: theme.colorScheme.primary),
      onPressed: onRefresh,
                      constraints: const BoxConstraints(,
      minWidth: 32,
                        minHeight: 32),
      padding: EdgeInsets.zero)
                  ]
                ])
            ])
          SizedBox(height: AppSpacing.spacing5),
          
          // 차트
          SizedBox(
            height: 200,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(,
      color: theme.colorScheme.primary)
                  ,
                : fortuneScores.isEmpty
                    ? Center(
                        child: Column(,
      mainAxisAlignment: MainAxisAlignment.center
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 48,
              ),
              color: theme.colorScheme.onSurface.withValues(alph,
      a: 0.3))
                            SizedBox(height: AppSpacing.spacing4),
                            Text(
                              '아직 운세 기록이 없습니다'),
        style: theme.textTheme.bodyLarge?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6,
                          )))
                            SizedBox(height: AppSpacing.spacing2),
                            Text(
                              '운세를 확인하면 여기에 기록됩니다'),
        style: theme.textTheme.bodyMedium?.copyWith(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.5,
                          )))
                          ])
                      ,
                    : LineChart(
              LineChartData(
                gridData: FlGridData(,
      show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20),
        getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withValues(alph,
      a: 0.1),
                      strokeWidth: 1
                    );
                  })
                titlesData: FlTitlesData(,
      show: true),
        rightTitles: const AxisTitles(,
      sideTitles: SideTitles(showTitl,
      es: false),
      topTitles: const AxisTitles(,
      sideTitles: SideTitles(showTitles: false),
      bottomTitles: AxisTitles(,
      sideTitles: SideTitles(,
      showTitles: true,
                      reservedSize: 30,
                      interval: 1),
        getTitlesWidget: (value, meta) {
                        const days = ['월', '화', '수', '목', '금', '토', '일'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()]
                            style: TextStyle(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6),
                              fontSize: 12,
                            )
                        }
                        return const Text('');
                      })))
                  leftTitles: AxisTitles(,
      sideTitles: SideTitles(,
      showTitles: true,
                      interval: 20,
                      reservedSize: 40),
        getTitlesWidget: (value, meta) {
                        return Text(
    '${value.toInt(,
  )}',
                          style: TextStyle(,
      color: theme.colorScheme.onSurface.withValues(alp,
      ha: 0.6),
                            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                          )
                      })))))
                borderData: FlBorderData(,
      show: true),
        border: Border(,
      bottom: BorderSide(,
      color: theme.colorScheme.outline.withValues(alph,
      a: 0.2),
                      width: 1),
      left: BorderSide(,
      color: theme.colorScheme.outline.withValues(alph,
      a: 0.2),
                      width: 1)))),
      minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: fortuneScores.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.toDouble();
                    }).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(,
      show: true),
        getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
    radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: theme.colorScheme.surface,
  )})
                    belowBarData: BarAreaData(,
      show: true),
        color: AppColors.primary.withValues(alph,
      a: 0.1))))
                ])))))
          
          SizedBox(height: AppSpacing.spacing5),
          
          // 평균 점수
          Container(
            padding: AppSpacing.paddingAll16),
        decoration: BoxDecoration(,
      color: theme.colorScheme.primary.withValues(alp,
      ha: 0.05),
              borderRadius: AppDimensions.borderRadiusSmall),
      child: Row(,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: AppDimensions.iconSizeSmall,
                      color: theme.colorScheme.primary)
                    SizedBox(width: AppSpacing.spacing2),
                    Text(
                      '이번 주 평균',
                      style: theme.textTheme.bodyMedium)
                  ])
                Text(
    '${_calculateAverage(fortuneScores,
  )}점',
                  style: theme.textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.bold),
        color: theme.colorScheme.primary,
                          )))
              ])))
        ]
      )
  }
  
  int _calculateAverage(List<int> scores) {
    if (scores.isEmpty) return 0;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }
}