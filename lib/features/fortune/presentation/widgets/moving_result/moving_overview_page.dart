import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/typography_unified.dart';
import 'moving_fortune_data.dart';
import 'circular_score_painter.dart';
import 'moving_result_utils.dart';

/// 페이지 1: 종합 점수와 요약
class MovingOverviewPage extends StatelessWidget {
  final MovingFortuneData fortuneData;
  final Animation<double> scoreAnimation;
  final String purpose;

  const MovingOverviewPage({
    super.key,
    required this.fortuneData,
    required this.scoreAnimation,
    required this.purpose,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 종합 점수 카드
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '종합 이사운',
                  style: TossTheme.heading3,
                ),
                const SizedBox(height: 24),
                // 원형 점수 게이지
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: scoreAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(200, 200),
                            painter: CircularScorePainter(
                              score: scoreAnimation.value,
                              color: MovingResultUtils.getScoreColor(fortuneData.overallScore),
                            ),
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: scoreAnimation,
                            builder: (context, child) {
                              return Text(
                                '${(scoreAnimation.value * 100).toInt()}',
                                style: TypographyUnified.displayLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: MovingResultUtils.getScoreColor(fortuneData.overallScore),
                                ),
                              );
                            },
                          ),
                          Text(
                            MovingResultUtils.getScoreDescription(fortuneData.overallScore),
                            style: TossTheme.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: MovingResultUtils.getScoreColor(fortuneData.overallScore),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 핵심 메시지
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MovingResultUtils.getScoreColor(fortuneData.overallScore).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_rounded,
                        color: MovingResultUtils.getScoreColor(fortuneData.overallScore),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          MovingResultUtils.getMainAdvice(purpose, fortuneData.bestDirection),
                          style: TossTheme.body2.copyWith(
                            height: 1.5,
                            color: TossTheme.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // 빠른 요약 카드들
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  '최적 방향',
                  fortuneData.bestDirection,
                  Icons.explore_rounded,
                  TossTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickInfoCard(
                  '최적 시기',
                  '${fortuneData.luckyDates.first.month}월 ${fortuneData.luckyDates.first.day}일',
                  Icons.calendar_today_rounded,
                  TossDesignSystem.warningOrange,
                ),
              ),
            ],
          ).animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  '추천 주거',
                  fortuneData.houseTypeScores.entries.first.key,
                  Icons.home_rounded,
                  TossDesignSystem.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickInfoCard(
                  '예상 비용',
                  '${fortuneData.budgetBreakdown.values.reduce((a, b) => a + b)}만원',
                  Icons.payments_rounded,
                  TossDesignSystem.primaryBlue,
                ),
              ),
            ],
          ).animate()
            .fadeIn(delay: 600.ms)
            .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TossTheme.caption.copyWith(
                  color: TossTheme.textGray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TossTheme.heading3,
          ),
        ],
      ),
    );
  }
}
