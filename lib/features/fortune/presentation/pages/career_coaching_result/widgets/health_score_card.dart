import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';

class HealthScoreCard extends StatelessWidget {
  final Map<String, dynamic> healthScore;
  final DSColorScheme colors;

  const HealthScoreCard({
    super.key,
    required this.healthScore,
    required this.colors,
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
            style: DSTypography.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
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
                    accentColor: colors.accent,
                    borderColor: colors.border,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$overallScore',
                      style: DSTypography.displayMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.accent,
                      ),
                    ),
                    Text(
                      _getScoreLabel(level),
                      style: DSTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
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
              _buildSubScore('성장', growthScore, DSColors.success),
              _buildSubScore('만족도', satisfactionScore, DSColors.warning),
              _buildSubScore('시장', marketScore, colors.accent),
              _buildSubScore('워라벨', balanceScore, colors.accent),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildSubScore(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: DSTypography.labelMedium.copyWith(
            color: colors.textSecondary,
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
              style: DSTypography.bodyLarge.copyWith(
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
  final Color accentColor;
  final Color borderColor;

  CircularScorePainter({
    required this.score,
    required this.accentColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [accentColor, DSColors.success],
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
