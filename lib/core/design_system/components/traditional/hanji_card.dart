import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../design_system.dart';
import '../../../theme/font_config.dart';

/// Korean traditional Hanji paper style card - Universal component
///
/// Design Philosophy:
/// - Hanji (한지) paper texture background
/// - Subtle ink bleed effect borders
/// - Minhwa-style decorative corner elements
/// - Traditional seal stamp accent option
///
/// Usage:
/// ```dart
/// HanjiCard(
///   style: HanjiCardStyle.scroll,
///   colorScheme: HanjiColorScheme.fortune,
///   showSealStamp: true,
///   sealText: '運',
///   child: YourContent(),
/// )
/// ```
class HanjiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final HanjiCardStyle style;
  final HanjiColorScheme colorScheme;
  final bool showCornerDecorations;
  final bool showSealStamp;
  final Color? customBackgroundColor;
  final Color? customBorderColor;
  final Color? customAccentColor;
  final String? sealText;
  final double? sealSize;

  const HanjiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.style = HanjiCardStyle.standard,
    this.colorScheme = HanjiColorScheme.fortune,
    this.showCornerDecorations = false,
    this.showSealStamp = false,
    this.customBackgroundColor,
    this.customBorderColor,
    this.customAccentColor,
    this.sealText,
    this.sealSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = _HanjiColors.fromScheme(colorScheme, isDark);

    return Container(
      margin: margin,
      child: CustomPaint(
        painter: _HanjiCardPainter(
          isDark: isDark,
          style: style,
          showCornerDecorations: showCornerDecorations,
          backgroundColor: customBackgroundColor ?? colors.background,
          borderColor: customBorderColor ?? colors.border,
          accentColor: customAccentColor ?? colors.accent,
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
            splashColor: colors.ink.withValues(alpha: 0.1),
            highlightColor: colors.ink.withValues(alpha: 0.05),
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
                    child: SealStamp(
                      text: sealText ?? '運',
                      color: customAccentColor ?? colors.accent,
                      size: sealSize ?? 32,
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

/// Color scheme presets for different fortune types
enum HanjiColorScheme {
  /// General fortune (자주색 + 금색)
  fortune,

  /// Love/compatibility (연지색)
  love,

  /// Luck/fortune items (황금색)
  luck,

  /// Biorhythm (오방색)
  biorhythm,

  /// Health (청록색)
  health,

  /// Custom (use custom colors)
  custom,
}

/// Internal color holder for Hanji cards
class _HanjiColors {
  final Color background;
  final Color border;
  final Color accent;
  final Color ink;

  const _HanjiColors({
    required this.background,
    required this.border,
    required this.accent,
    required this.ink,
  });

  factory _HanjiColors.fromScheme(HanjiColorScheme scheme, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    switch (scheme) {
      case HanjiColorScheme.fortune:
        return _HanjiColors(
          background: DSColors.getBackground(brightness),
          border: isDark
              ? DSColors.textSecondary.withValues(alpha: 0.3)
              : DSColors.textPrimaryDark.withValues(alpha: 0.15),
          accent: DSColors.warning,
          ink: DSColors.getTextPrimary(brightness),
        );
      case HanjiColorScheme.love:
        return _HanjiColors(
          background: isDark
              ? const Color(0xFF2D2528)
              : const Color(0xFFFDF8F6),
          border: isDark
              ? const Color(0xFFE8A4B8).withValues(alpha: 0.3)
              : const Color(0xFFD4526E).withValues(alpha: 0.15),
          accent: isDark
              ? const Color(0xFFE8A4B8)
              : const Color(0xFFD4526E),
          ink: isDark
              ? const Color(0xFFD4D0C8)
              : const Color(0xFF2C2C2C),
        );
      case HanjiColorScheme.luck:
        return _HanjiColors(
          background: isDark
              ? const Color(0xFF2D2820)
              : const Color(0xFFFDF8E8),
          border: isDark
              ? const Color(0xFFD4AF37).withValues(alpha: 0.3)
              : const Color(0xFFB7950B).withValues(alpha: 0.15),
          accent: isDark
              ? const Color(0xFFD4AF37)
              : const Color(0xFFB7950B),
          ink: isDark
              ? const Color(0xFFD4D0C8)
              : const Color(0xFF2C2C2C),
        );
      case HanjiColorScheme.biorhythm:
        return _HanjiColors(
          background: isDark
              ? const Color(0xFF2A2520)
              : const Color(0xFFF5F0E6),
          border: isDark
              ? const Color(0xFFD4D0C8).withValues(alpha: 0.3)
              : const Color(0xFF2C2C2C).withValues(alpha: 0.15),
          accent: isDark
              ? const Color(0xFFD4AF37)
              : const Color(0xFFB7950B),
          ink: isDark
              ? const Color(0xFFD4D0C8)
              : const Color(0xFF2C2C2C),
        );
      case HanjiColorScheme.health:
        return _HanjiColors(
          background: isDark
              ? const Color(0xFF202D28)
              : const Color(0xFFF0F8F5),
          border: isDark
              ? const Color(0xFF68D391).withValues(alpha: 0.3)
              : const Color(0xFF38A169).withValues(alpha: 0.15),
          accent: isDark
              ? const Color(0xFF68D391)
              : const Color(0xFF38A169),
          ink: isDark
              ? const Color(0xFFD4D0C8)
              : const Color(0xFF2C2C2C),
        );
      case HanjiColorScheme.custom:
        // Return fortune as default, custom colors should be passed directly
        return _HanjiColors.fromScheme(HanjiColorScheme.fortune, isDark);
    }
  }
}

/// CustomPainter for Hanji card background and decorations
class _HanjiCardPainter extends CustomPainter {
  final bool isDark;
  final HanjiCardStyle style;
  final bool showCornerDecorations;
  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;

  _HanjiCardPainter({
    required this.isDark,
    required this.style,
    required this.showCornerDecorations,
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
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
    // Base fill
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    // Subtle texture overlay (simulated with noise-like dots)
    final random = math.Random(42);
    final textureColor = isDark
        ? Colors.white.withValues(alpha: 0.02)
        : Colors.black.withValues(alpha: 0.02);

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
    final decorColor = accentColor.withValues(alpha: isDark ? 0.5 : 0.4);

    final paint = Paint()
      ..color = decorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const cornerSize = 20.0;
    const margin = 8.0;

    // Top-left corner (L shape with curve)
    _drawCornerCurve(canvas, const Offset(margin, margin), cornerSize, 0, paint);

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
    final rodColor = borderColor.withValues(alpha: isDark ? 0.3 : 0.2);

    // Top scroll rod
    canvas.drawLine(
      const Offset(20, 4),
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
    // Top hanging rod
    canvas.drawLine(
      const Offset(10, 2),
      Offset(size.width - 10, 2),
      Paint()
        ..color = accentColor.withValues(alpha: 0.6)
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
        ..color = accentColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawElevatedShadow(Canvas canvas, Size size) {
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.15);

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
  bool shouldRepaint(covariant _HanjiCardPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.style != style ||
        oldDelegate.showCornerDecorations != showCornerDecorations ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.accentColor != accentColor;
  }
}

/// Traditional Korean seal stamp (낙관) widget
class SealStamp extends StatelessWidget {
  final String text;
  final Color color;
  final double size;

  const SealStamp({
    super.key,
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
    const segments = 24;

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
          fontFamily: FontConfig.primary,
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
class HanjiSectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? hanja;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final HanjiCardStyle style;
  final HanjiColorScheme colorScheme;
  final bool showCornerDecorations;
  final Color? accentColor;

  const HanjiSectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.hanja,
    required this.child,
    this.padding,
    this.margin,
    this.style = HanjiCardStyle.standard,
    this.colorScheme = HanjiColorScheme.fortune,
    this.showCornerDecorations = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = _HanjiColors.fromScheme(colorScheme, isDark);
    final textColor = colors.ink;

    return HanjiCard(
      style: style,
      colorScheme: colorScheme,
      padding: padding ?? const EdgeInsets.all(DSSpacing.lg),
      margin: margin,
      showCornerDecorations: showCornerDecorations,
      customAccentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (hanja != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: (accentColor ?? colors.accent).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        hanja!,
                        style: TextStyle(
                          color: accentColor ?? colors.accent,
                          fontSize: 14,
                          fontFamily: FontConfig.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontFamily: FontConfig.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontFamily: FontConfig.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
            // Decorative divider (brush stroke style)
            CustomPaint(
              size: const Size(double.infinity, 2),
              painter: _BrushDividerPainter(
                color: (accentColor ?? textColor).withValues(alpha: 0.2),
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
