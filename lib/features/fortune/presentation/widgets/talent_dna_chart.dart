import 'package:flutter/material.dart';
import 'dart:math' as math;

class TalentDnaChart extends StatelessWidget {
  final Map<String, int> talents;
  final double size;

  const TalentDnaChart({
    super.key,
    required this.talents,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TalentDnaPainter(
          talents: talents,
          primaryColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          textStyle: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _TalentDnaPainter extends CustomPainter {
  final Map<String, int> talents;
  final Color primaryColor;
  final Color backgroundColor;
  final TextStyle? textStyle;

  _TalentDnaPainter({
    required this.talents,
    required this.primaryColor,
    required this.backgroundColor,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    
    // Draw hexagon background
    _drawHexagonBackground(canvas, center, radius);
    
    // Draw talent levels
    _drawTalentLevels(canvas, center, radius);
    
    // Draw labels
    _drawLabels(canvas, center, radius + 20);
  }

  void _drawHexagonBackground(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw concentric hexagons for scale
    for (int i = 1; i <= 5; i++) {
      final hexRadius = radius * i / 5;
      final path = _createHexagonPath(center, hexRadius);
      canvas.drawPath(path, paint);
    }
  }

  void _drawTalentLevels(Canvas canvas, Offset center, double radius) {
    final talentList = talents.entries.toList();
    final angleStep = 2 * math.pi / talentList.length;
    
    final path = Path();
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < talentList.length; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final value = talentList[i].value / 100.0; // Normalize to 0-1
      final pointRadius = radius * value;
      
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw outline
    final outlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, outlinePaint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
      
    for (int i = 0; i < talentList.length; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final value = talentList[i].value / 100.0;
      final pointRadius = radius * value;
      
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double labelRadius) {
    final talentList = talents.entries.toList();
    final angleStep = 2 * math.pi / talentList.length;
    
    for (int i = 0; i < talentList.length; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: talentList[i].key,
          style: textStyle?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // Center the text
      final textOffset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, textOffset);
    }
  }

  Path _createHexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TalentProgressBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color? color;

  const TalentProgressBar({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final progress = value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$value점',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: progressColor.withValues(alpha: 0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: progressColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TalentTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> traits;

  const TalentTypeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.traits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: traits.map((trait) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  trait,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}