import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/design_system/design_system.dart';
import 'moving_fortune_data.dart';

/// 페이지 3: 방향별 운세
class MovingDirectionPage extends StatelessWidget {
  final MovingFortuneData fortuneData;
  final String currentArea;

  const MovingDirectionPage({
    super.key,
    required this.fortuneData,
    required this.currentArea,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '방향별 이사운',
            style: DSTypography.headingLarge,
          ),
          const SizedBox(height: 20),

          // 레이더 차트
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      radarBorderData: BorderSide(color: DSColors.border),
                      gridBorderData: BorderSide(color: DSColors.border.withValues(alpha: 0.5)),
                      tickBorderData: BorderSide(color: DSColors.border.withValues(alpha: 0.5)),
                      titleTextStyle: DSTypography.bodyMedium,
                      tickCount: 5,
                      ticksTextStyle: DSTypography.labelSmall,
                      dataSets: [
                        RadarDataSet(
                          fillColor: DSColors.accent.withValues(alpha: 0.2),
                          borderColor: DSColors.accent,
                          borderWidth: 2,
                          dataEntries: fortuneData.directionScores.values
                              .map((score) => RadarEntry(value: score.toDouble()))
                              .toList(),
                        ),
                      ],
                      getTitle: (index, angle) {
                        final titles = fortuneData.directionScores.keys.toList();
                        return RadarChartTitle(
                          text: titles[index],
                          angle: 0,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 최적 방향 강조
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DSColors.accent.withValues(alpha: 0.1),
                        DSColors.accent.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: DSColors.accent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '최적 방향: ${fortuneData.bestDirection}쪽',
                              style: DSTypography.headingMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currentArea에서 ${fortuneData.bestDirection}쪽 방향이 가장 좋습니다',
                              style: DSTypography.bodyMedium.copyWith(
                                color: DSColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 방향별 상세 점수
          Text(
            '방향별 상세 분석',
            style: DSTypography.headingMedium,
          ),
          const SizedBox(height: 12),

          ...fortuneData.directionScores.entries.map((entry) {
            final isBest = entry.key == fortuneData.bestDirection;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isBest ? DSColors.accent.withValues(alpha: 0.05) : Colors.white,
                  border: Border.all(
                    color: isBest ? DSColors.accent : DSColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: DSTypography.headingSmall.copyWith(
                        color: isBest ? DSColors.accent : DSColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: entry.value / 100,
                        backgroundColor: DSColors.border,
                        valueColor: AlwaysStoppedAnimation(
                          isBest ? DSColors.accent : DSColors.textTertiary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.value}점',
                      style: DSTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isBest ? DSColors.accent : DSColors.textSecondary,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DSColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '최적',
                          style: DSTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
