import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/personality_dna_model.dart';

/// 능력치 레이더 차트 (5각형)
class StatsRadarChart extends StatelessWidget {
  final PersonalityStats stats;

  const StatsRadarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final dividerColor = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dividerColor.withValues(alpha: isDark ? 0.3 : 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '나의 능력치',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          SizedBox(
            height: 250,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                    borderColor: Theme.of(context).colorScheme.primary,
                    borderWidth: 2,
                    entryRadius: 4,
                    dataEntries: stats.values
                        .map((value) => RadarEntry(value: value.toDouble()))
                        .toList(),
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(
                  color: dividerColor.withValues(alpha: isDark ? 0.5 : 0.3),
                  width: 1,
                ),
                titlePositionPercentageOffset: 0.15,
                titleTextStyle: context.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                getTitle: (index, angle) {
                  final labels = stats.labels;
                  final values = stats.values;
                  return RadarChartTitle(
                    text: '${labels[index]}\n${values[index]}',
                    angle: 0,
                  );
                },
                tickCount: 5,
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 10,
                ),
                tickBorderData: BorderSide(
                  color: dividerColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  width: 1,
                ),
                gridBorderData: BorderSide(
                  color: dividerColor.withValues(alpha: isDark ? 0.3 : 0.2),
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          // 능력치 상세 목록
          ...List.generate(stats.labels.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
              child: _buildStatBar(
                context,
                isDark,
                stats.labels[index],
                stats.values[index],
                _getStatColor(index),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatBar(
    BuildContext context,
    bool isDark,
    String label,
    int value,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: context.labelLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            style: context.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getStatColor(int index) {
    const colors = [
      Color(0xFFFF6B6B), // 고유 색상 - 카리스마
      Color(0xFF4ECDC4), // 고유 색상 - 지능
      Color(0xFFFFE66D), // 고유 색상 - 창의력
      Color(0xFF95E1D3), // 고유 색상 - 리더십
      Color(0xFFDDA0DD), // 고유 색상 - 공감력
    ];
    return colors[index % colors.length];
  }
}
