import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/components/app_card.dart';

class HealthScoreCard extends StatelessWidget {
  final Map<String, dynamic> healthScore;
  final bool isDark;

  const HealthScoreCard({
    super.key,
    required this.healthScore,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final overallScore = healthScore['overall_score'] as int? ?? 0;
    final level = healthScore['level'] as String? ?? '';
    final growthScore = healthScore['growth_score'] as int? ?? 0;
    final satisfactionScore = healthScore['satisfaction_score'] as int? ?? 0;
    final marketScore = healthScore['market_score'] as int? ?? 0;
    final balanceScore = healthScore['balance_score'] as int? ?? 0;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '커리어 건강도',
            style: context.heading3.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 24),

          // Circular Score
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: CircularScorePainter(
                    score: overallScore,
                    gradientColors: [
                      TossDesignSystem.tossBlue,
                      TossDesignSystem.successGreen,
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$overallScore',
                      style: context.displayMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TossDesignSystem.tossBlue,
                      ),
                    ),
                    Text(
                      _getScoreLabel(level),
                      style: context.bodyMedium.copyWith(
                        color: TossDesignSystem.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 32),

          // Sub Scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSubScore(context, '성장', growthScore, TossDesignSystem.successGreen),
              _buildSubScore(context, '만족도', satisfactionScore, TossDesignSystem.warningOrange),
              _buildSubScore(context, '시장', marketScore, TossDesignSystem.tossBlue),
              _buildSubScore(context, '워라벨', balanceScore, AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildSubScore(BuildContext context, String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: TossDesignSystem.gray600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$score',
              style: context.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getScoreLabel(String level) {
    switch (level) {
      case 'excellent': return '매우 우수';
      case 'good': return '양호';
      case 'moderate': return '보통';
      case 'needs-attention': return '개선 필요';
      default: return level;
    }
  }
}

// Custom Painter for Circular Score
class CircularScorePainter extends CustomPainter {
  final int score;
  final List<Color> gradientColors;

  CircularScorePainter({
    required this.score,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = TossDesignSystem.gray200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * score / 100),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * score / 100,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
