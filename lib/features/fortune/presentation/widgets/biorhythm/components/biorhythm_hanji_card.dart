import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/design_system/tokens/ds_biorhythm_colors.dart';

/// Korean traditional Hanji paper style card for biorhythm pages
///
/// Design Philosophy:
/// - Hanji (한지) paper texture background
/// - Subtle ink bleed effect borders
/// - Minhwa-style decorative corner elements
/// - Traditional seal stamp accent option
class BiorhythmHanjiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final HanjiCardStyle style;
  final bool showCornerDecorations;
  final bool showSealStamp;
  final Color? accentColor;
  final String? sealText;

  const BiorhythmHanjiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.style = HanjiCardStyle.standard,
    this.showCornerDecorations = false,
    this.showSealStamp = false,
    this.accentColor,
    this.sealText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: CustomPaint(
        painter: HanjiCardPainter(
          isDark: isDark,
          style: style,
          showCornerDecorations: showCornerDecorations,
          accentColor: accentColor,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: InkWell(
            onTap: onTap != null
                ? () {
                    DSHaptics.light();
                    onTap!();
                  }
                : null,
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            splashColor: DSBiorhythmColors.inkBleed.withValues(alpha: 0.1),
            highlightColor: DSBiorhythmColors.inkBleed.withValues(alpha: 0.05),
            child: Stack(
              children: [
                Padding(
                  padding: padding ?? const EdgeInsets.all(DSSpacing.lg),
                  child: child,
                ),
                // Seal stamp overlay
                if (showSealStamp)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _SealStamp(
                      text: sealText ?? '운',
                      color: accentColor ?? DSBiorhythmColors.getGoldAccent(isDark),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getBorderRadius() {
    switch (style) {
      case HanjiCardStyle.scroll:
        return DSRadius.lg;
      case HanjiCardStyle.hanging:
        return DSRadius.sm;
      default:
        return DSRadius.md;
    }
  }
}

/// Hanji card style variants
enum HanjiCardStyle {
  /// Standard hanji card with subtle texture
  standard,

  /// Scroll style (두루마리) with rounded edges
  scroll,

  /// Hanging scroll style (족자) with straight edges
  hanging,

  /// Elevated with ink shadow
  elevated,

  /// Minimal with subtle border
  minimal,
}

/// CustomPainter for Hanji card background and decorations
class HanjiCardPainter extends CustomPainter {
  final bool isDark;
  final HanjiCardStyle style;
  final bool showCornerDecorations;
  final Color? accentColor;

  HanjiCardPainter({
    required this.isDark,
    required this.style,
    required this.showCornerDecorations,
    this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = _getBorderRadius();
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Draw hanji paper background
    _drawHanjiBackground(canvas, rrect);

    // 2. Draw ink bleed border effect
    _drawInkBleedBorder(canvas, rrect);

    // 3. Draw corner decorations if enabled
    if (showCornerDecorations) {
      _drawCornerDecorations(canvas, size);
    }

    // 4. Draw style-specific decorations
    _drawStyleDecorations(canvas, size);
  }

  void _drawHanjiBackground(Canvas canvas, RRect rrect) {
    final bgColor = DSBiorhythmColors.getHanjiBackground(isDark);

    // Base fill
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill,
    );

    // Subtle texture overlay (simulated with noise-like dots)
    final random = math.Random(42);
    final textureColor = isDark
        ? Colors.white.withValues(alpha: 0.02)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.02);

    for (var i = 0; i < 50; i++) {
      final x = random.nextDouble() * rrect.width;
      final y = random.nextDouble() * rrect.height;
      final radius = 0.5 + random.nextDouble() * 1.5;

      // Check if point is inside the rounded rect
      if (x > 8 && x < rrect.width - 8 && y > 8 && y < rrect.height - 8) {
        canvas.drawCircle(
          Offset(x, y),
          radius,
          Paint()..color = textureColor,
        );
      }
    }
  }

  void _drawInkBleedBorder(Canvas canvas, RRect rrect) {
    final borderColor = isDark
        ? DSBiorhythmColors.inkBleedLight.withValues(alpha: 0.3)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.15);

    // Outer glow (ink bleed effect)
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Main border with varying thickness effect
    final path = Path()..addRRect(rrect);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawCornerDecorations(Canvas canvas, Size size) {
    final decorColor = accentColor ??
        (isDark
            ? DSBiorhythmColors.goldAccentDark.withValues(alpha: 0.5)
            : DSBiorhythmColors.goldAccent.withValues(alpha: 0.4));

    final paint = Paint()
      ..color = decorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cornerSize = 20.0;
    final margin = 8.0;

    // Top-left corner (L shape with curve)
    _drawCornerCurve(canvas, Offset(margin, margin), cornerSize, 0, paint);

    // Top-right corner
    _drawCornerCurve(
        canvas, Offset(size.width - margin, margin), cornerSize, 1, paint);

    // Bottom-right corner
    _drawCornerCurve(canvas, Offset(size.width - margin, size.height - margin),
        cornerSize, 2, paint);

    // Bottom-left corner
    _drawCornerCurve(
        canvas, Offset(margin, size.height - margin), cornerSize, 3, paint);
  }

  void _drawCornerCurve(
      Canvas canvas, Offset position, double size, int corner, Paint paint) {
    final path = Path();

    switch (corner) {
      case 0: // Top-left
        path.moveTo(position.dx, position.dy + size);
        path.quadraticBezierTo(
            position.dx, position.dy, position.dx + size, position.dy);
        break;
      case 1: // Top-right
        path.moveTo(position.dx - size, position.dy);
        path.quadraticBezierTo(
            position.dx, position.dy, position.dx, position.dy + size);
        break;
      case 2: // Bottom-right
        path.moveTo(position.dx, position.dy - size);
        path.quadraticBezierTo(
            position.dx, position.dy, position.dx - size, position.dy);
        break;
      case 3: // Bottom-left
        path.moveTo(position.dx + size, position.dy);
        path.quadraticBezierTo(
            position.dx, position.dy, position.dx, position.dy - size);
        break;
    }

    canvas.drawPath(path, paint);
  }

  void _drawStyleDecorations(Canvas canvas, Size size) {
    switch (style) {
      case HanjiCardStyle.scroll:
        _drawScrollEndDecorations(canvas, size);
        break;
      case HanjiCardStyle.hanging:
        _drawHangingRodDecoration(canvas, size);
        break;
      case HanjiCardStyle.elevated:
        _drawElevatedShadow(canvas, size);
        break;
      default:
        break;
    }
  }

  void _drawScrollEndDecorations(Canvas canvas, Size size) {
    final rodColor = isDark
        ? DSBiorhythmColors.inkBleedLight.withValues(alpha: 0.3)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.2);

    // Top scroll rod
    canvas.drawLine(
      Offset(20, 4),
      Offset(size.width - 20, 4),
      Paint()
        ..color = rodColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Bottom scroll rod
    canvas.drawLine(
      Offset(20, size.height - 4),
      Offset(size.width - 20, size.height - 4),
      Paint()
        ..color = rodColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHangingRodDecoration(Canvas canvas, Size size) {
    final rodColor = isDark
        ? DSBiorhythmColors.goldAccentDark
        : DSBiorhythmColors.goldAccent;

    // Top hanging rod
    canvas.drawLine(
      Offset(10, 2),
      Offset(size.width - 10, 2),
      Paint()
        ..color = rodColor.withValues(alpha: 0.6)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Hanging string
    final stringPath = Path()
      ..moveTo(size.width / 2 - 20, 2)
      ..quadraticBezierTo(size.width / 2, -10, size.width / 2 + 20, 2);

    canvas.drawPath(
      stringPath,
      Paint()
        ..color = rodColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawElevatedShadow(Canvas canvas, Size size) {
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.15);

    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size.width, size.height),
      Radius.circular(_getBorderRadius()),
    );

    canvas.drawRRect(
      shadowRect,
      Paint()
        ..color = shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  double _getBorderRadius() {
    switch (style) {
      case HanjiCardStyle.scroll:
        return DSRadius.lg;
      case HanjiCardStyle.hanging:
        return DSRadius.sm;
      default:
        return DSRadius.md;
    }
  }

  @override
  bool shouldRepaint(covariant HanjiCardPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.style != style ||
        oldDelegate.showCornerDecorations != showCornerDecorations ||
        oldDelegate.accentColor != accentColor;
  }
}

/// Traditional Korean seal stamp (낙관) widget
class _SealStamp extends StatelessWidget {
  final String text;
  final Color color;
  final double size;

  const _SealStamp({
    required this.text,
    required this.color,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SealStampPainter(
        text: text,
        color: color,
      ),
    );
  }
}

class _SealStampPainter extends CustomPainter {
  final String text;
  final Color color;

  _SealStampPainter({
    required this.text,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Outer circle with slight roughness (seal stamp edge)
    final path = Path();
    final segments = 24;

    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      final variance = math.sin(i * 5) * 0.5; // Slight irregularity
      final r = radius + variance;

      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Draw seal border
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw seal text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.45,
          fontFamily: 'GowunBatang',
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _SealStampPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.color != color;
  }
}

/// Hanji section card with title and content
class BiorhythmHanjiSectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final HanjiCardStyle style;
  final bool showCornerDecorations;
  final Color? accentColor;

  const BiorhythmHanjiSectionCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.margin,
    this.style = HanjiCardStyle.standard,
    this.showCornerDecorations = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return BiorhythmHanjiCard(
      style: style,
      padding: padding ?? const EdgeInsets.all(DSSpacing.lg),
      margin: margin,
      showCornerDecorations: showCornerDecorations,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontFamily: 'GowunBatang',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DSSpacing.xs),
              Text(
                subtitle!,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
            const SizedBox(height: DSSpacing.md),
            // Decorative divider (brush stroke style)
            CustomPaint(
              size: const Size(double.infinity, 2),
              painter: _BrushDividerPainter(
                color: accentColor ?? textColor.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

/// Brush stroke style divider painter
class _BrushDividerPainter extends CustomPainter {
  final Color color;

  _BrushDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Draw brush stroke with varying thickness
    final path = Path();
    path.moveTo(0, size.height / 2);

    for (var x = 0.0; x < size.width; x += 4) {
      final y = size.height / 2 + math.sin(x * 0.1) * 0.3;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BrushDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
