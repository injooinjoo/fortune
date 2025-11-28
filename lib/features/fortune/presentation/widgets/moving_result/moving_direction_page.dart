import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/typography_unified.dart';
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
            style: TossTheme.heading2,
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
                      radarBorderData: BorderSide(color: TossTheme.borderGray300),
                      gridBorderData: BorderSide(color: TossTheme.borderGray200),
                      tickBorderData: BorderSide(color: TossTheme.borderGray200),
                      titleTextStyle: TossTheme.body2,
                      tickCount: 5,
                      ticksTextStyle: TypographyUnified.labelTiny,
                      dataSets: [
                        RadarDataSet(
                          fillColor: TossTheme.primaryBlue.withValues(alpha: 0.2),
                          borderColor: TossTheme.primaryBlue,
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
                        TossTheme.primaryBlue.withValues(alpha: 0.1),
                        TossTheme.primaryBlue.withValues(alpha: 0.05),
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
                          color: TossTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.navigation_rounded,
                          color: TossDesignSystem.white,
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
                              style: TossTheme.heading3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currentArea에서 ${fortuneData.bestDirection}쪽 방향이 가장 좋습니다',
                              style: TossTheme.body2.copyWith(
                                color: TossTheme.textGray600,
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
            style: TossTheme.heading3,
          ),
          const SizedBox(height: 12),

          ...fortuneData.directionScores.entries.map((entry) {
            final isBest = entry.key == fortuneData.bestDirection;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isBest ? TossTheme.primaryBlue.withValues(alpha: 0.05) : TossDesignSystem.white,
                  border: Border.all(
                    color: isBest ? TossTheme.primaryBlue : TossTheme.borderGray200,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: TossTheme.heading4.copyWith(
                        color: isBest ? TossTheme.primaryBlue : TossTheme.textBlack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: entry.value / 100,
                        backgroundColor: TossTheme.borderGray200,
                        valueColor: AlwaysStoppedAnimation(
                          isBest ? TossTheme.primaryBlue : TossTheme.textGray400,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.value}점',
                      style: TossTheme.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isBest ? TossTheme.primaryBlue : TossTheme.textGray600,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TossTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '최적',
                          style: TossTheme.caption.copyWith(
                            color: TossDesignSystem.white,
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
