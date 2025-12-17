import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import 'biorhythm_score_badge.dart';

/// Traditional Korean ink wash style icon for biorhythm types
///
/// Design Philosophy:
/// - Physical (火/불): Sun symbol - 태양/봉황 representing fire and vitality
/// - Emotional (木/나무): Lotus flower - 연꽃 representing growth and emotion
/// - Intellectual (水/물): Moon with clouds - 달/구름 representing water and wisdom
///
/// Each icon is rendered using CustomPainter with ink wash (수묵화) style effects
class RhythmTraditionalIcon extends StatelessWidget {
  final BiorhythmType type;
  final double size;
  final bool showBackground;
  final bool showLabel;
  final Color? overrideColor;

  const RhythmTraditionalIcon({
    super.key,
    required this.type,
    this.size = 48,
    this.showBackground = true,
    this.showLabel = false,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = overrideColor ?? _getTypeColor(isDark);
    final bgColor = _getBackgroundColor(isDark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: showBackground
              ? BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                )
              : null,
          child: CustomPaint(
            size: Size(size, size),
            painter: _RhythmIconPainter(
              type: type,
              color: color,
              isDark: isDark,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            _getTypeLabel(),
            style: TextStyle(
              color: color,
              fontSize: size * 0.25,
              fontFamily: 'GowunBatang',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Color _getTypeColor(bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysical(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotional(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectual(isDark);
    }
  }

  Color _getBackgroundColor(bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysicalBackground(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotionalBackground(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectualBackground(isDark);
    }
  }

  String _getTypeLabel() {
    switch (type) {
      case BiorhythmType.physical:
        return '신체';
      case BiorhythmType.emotional:
        return '감정';
      case BiorhythmType.intellectual:
        return '지적';
    }
  }
}

/// CustomPainter for traditional rhythm icons
class _RhythmIconPainter extends CustomPainter {
  final BiorhythmType type;
  final Color color;
  final bool isDark;

  _RhythmIconPainter({
    required this.type,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case BiorhythmType.physical:
        _drawSunSymbol(canvas, size);
        break;
      case BiorhythmType.emotional:
        _drawLotusSymbol(canvas, size);
        break;
      case BiorhythmType.intellectual:
        _drawMoonSymbol(canvas, size);
        break;
    }
  }

  /// Draw sun symbol (태양) for Physical rhythm
  void _drawSunSymbol(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;

    // Sun rays with ink wash effect
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rayCount = 8;
    final innerRadius = radius * 1.3;
    final outerRadius = radius * 1.8;

    for (var i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * math.pi - math.pi / 2;
      final startPoint = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      // Draw ray with varying thickness (brush stroke effect)
      canvas.drawLine(startPoint, endPoint, rayPaint);

      // Add slight blur at end (ink bleed)
      canvas.drawCircle(
        endPoint,
        2,
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // Sun center with gradient (ink wash layers)
    // Outer glow
    canvas.drawCircle(
      center,
      radius * 1.2,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Main circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
    );

    // Inner highlight
    canvas.drawCircle(
      center.translate(-radius * 0.2, -radius * 0.2),
      radius * 0.3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );

    // Border stroke
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  /// Draw lotus symbol (연꽃) for Emotional rhythm
  void _drawLotusSymbol(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.05);
    final petalRadius = size.width * 0.28;

    // Draw petals with ink wash effect
    final petalCount = 5;

    for (var i = 0; i < petalCount; i++) {
      final angle = (i / petalCount) * math.pi - math.pi / 2;
      _drawLotusPetal(canvas, center, petalRadius, angle);
    }

    // Center stamens
    final stamenPaint = Paint()
      ..color = DSBiorhythmColors.goldAccent.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center.translate(0, -petalRadius * 0.2),
      petalRadius * 0.15,
      stamenPaint,
    );

    // Small dots around center
    for (var i = 0; i < 5; i++) {
      final dotAngle = (i / 5) * math.pi - math.pi * 0.7;
      final dotPos = center.translate(
        petalRadius * 0.25 * math.cos(dotAngle),
        -petalRadius * 0.15 + petalRadius * 0.2 * math.sin(dotAngle),
      );
      canvas.drawCircle(
        dotPos,
        2,
        Paint()..color = DSBiorhythmColors.goldAccent.withValues(alpha: 0.5),
      );
    }
  }

  void _drawLotusPetal(
      Canvas canvas, Offset center, double radius, double angle) {
    final petalPath = Path();
    final petalWidth = radius * 0.5;
    final petalHeight = radius * 0.9;

    // Calculate petal center position
    final petalCenter = Offset(
      center.dx + radius * 0.3 * math.cos(angle),
      center.dy + radius * 0.3 * math.sin(angle) - radius * 0.2,
    );

    // Create petal shape using bezier curves
    final startAngle = angle - math.pi / 2;
    final tipX = petalCenter.dx + petalHeight * math.cos(startAngle);
    final tipY = petalCenter.dy + petalHeight * math.sin(startAngle);

    petalPath.moveTo(petalCenter.dx, petalCenter.dy);

    // Left side of petal
    petalPath.quadraticBezierTo(
      petalCenter.dx +
          petalWidth * 0.5 * math.cos(startAngle - math.pi / 4) -
          petalWidth * 0.3 * math.cos(startAngle),
      petalCenter.dy +
          petalWidth * 0.5 * math.sin(startAngle - math.pi / 4) -
          petalWidth * 0.3 * math.sin(startAngle),
      tipX,
      tipY,
    );

    // Right side of petal
    petalPath.quadraticBezierTo(
      petalCenter.dx +
          petalWidth * 0.5 * math.cos(startAngle + math.pi / 4) -
          petalWidth * 0.3 * math.cos(startAngle),
      petalCenter.dy +
          petalWidth * 0.5 * math.sin(startAngle + math.pi / 4) -
          petalWidth * 0.3 * math.sin(startAngle),
      petalCenter.dx,
      petalCenter.dy,
    );

    petalPath.close();

    // Draw petal with ink wash layers
    // Outer blur
    canvas.drawPath(
      petalPath,
      Paint()
        ..color = color.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Fill
    canvas.drawPath(
      petalPath,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );

    // Stroke
    canvas.drawPath(
      petalPath,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  /// Draw moon symbol (달) for Intellectual rhythm
  void _drawMoonSymbol(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.28;

    // Moon crescent
    final moonPath = Path();

    // Outer circle
    moonPath.addOval(Rect.fromCircle(center: center, radius: radius));

    // Inner circle to create crescent (subtractive)
    final innerCenter = center.translate(radius * 0.35, -radius * 0.1);
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: innerCenter, radius: radius * 0.85));

    // Combine paths
    final crescentPath =
        Path.combine(PathOperation.difference, moonPath, innerPath);

    // Draw moon with ink wash layers
    // Outer glow
    canvas.drawPath(
      crescentPath,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Fill
    canvas.drawPath(
      crescentPath,
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill,
    );

    // Stroke
    canvas.drawPath(
      crescentPath,
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Small clouds around moon
    _drawCloud(canvas, center.translate(-radius * 0.8, radius * 0.5),
        radius * 0.3);
    _drawCloud(canvas, center.translate(radius * 0.6, radius * 0.7),
        radius * 0.25);
  }

  void _drawCloud(Canvas canvas, Offset position, double size) {
    final cloudPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Simple cloud shape with overlapping circles
    canvas.drawCircle(position, size * 0.4, cloudPaint);
    canvas.drawCircle(position.translate(size * 0.3, 0), size * 0.35, cloudPaint);
    canvas.drawCircle(position.translate(size * 0.15, -size * 0.2), size * 0.3, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant _RhythmIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.isDark != isDark;
  }
}

/// Row of all three rhythm icons
class RhythmTraditionalIconRow extends StatelessWidget {
  final double iconSize;
  final bool showBackground;
  final bool showLabels;
  final MainAxisAlignment alignment;

  const RhythmTraditionalIconRow({
    super.key,
    this.iconSize = 48,
    this.showBackground = true,
    this.showLabels = true,
    this.alignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        RhythmTraditionalIcon(
          type: BiorhythmType.physical,
          size: iconSize,
          showBackground: showBackground,
          showLabel: showLabels,
        ),
        RhythmTraditionalIcon(
          type: BiorhythmType.emotional,
          size: iconSize,
          showBackground: showBackground,
          showLabel: showLabels,
        ),
        RhythmTraditionalIcon(
          type: BiorhythmType.intellectual,
          size: iconSize,
          showBackground: showBackground,
          showLabel: showLabels,
        ),
      ],
    );
  }
}

/// Element badge showing the Five Elements (오행) character
class ElementBadge extends StatelessWidget {
  final BiorhythmType type;
  final double size;
  final bool showBackground;

  const ElementBadge({
    super.key,
    required this.type,
    this.size = 32,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getTypeColor(isDark);
    final bgColor = _getBackgroundColor(isDark);

    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1,
              ),
            )
          : null,
      alignment: Alignment.center,
      child: Text(
        _getElementHanja(),
        style: TextStyle(
          color: color,
          fontSize: size * 0.5,
          fontFamily: 'GowunBatang',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _getTypeColor(bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysical(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotional(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectual(isDark);
    }
  }

  Color _getBackgroundColor(bool isDark) {
    switch (type) {
      case BiorhythmType.physical:
        return DSBiorhythmColors.getPhysicalBackground(isDark);
      case BiorhythmType.emotional:
        return DSBiorhythmColors.getEmotionalBackground(isDark);
      case BiorhythmType.intellectual:
        return DSBiorhythmColors.getIntellectualBackground(isDark);
    }
  }

  String _getElementHanja() {
    switch (type) {
      case BiorhythmType.physical:
        return '火'; // Fire
      case BiorhythmType.emotional:
        return '木'; // Wood
      case BiorhythmType.intellectual:
        return '水'; // Water
    }
  }
}
