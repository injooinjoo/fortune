import 'package:flutter/material.dart';
import '../theme/ds_extensions.dart';
import '../tokens/ds_colors.dart';

/// Korean Traditional Hanji paper background wrapper
///
/// Applies hanji paper texture and color to any screen
/// for an authentic Korean traditional aesthetic
///
/// Usage:
/// ```dart
/// HanjiBackground(
///   child: Scaffold(
///     backgroundColor: Colors.transparent,
///     body: YourContent(),
///   ),
/// )
///
/// // With subtle texture
/// HanjiBackground.subtle(
///   child: YourContent(),
/// )
/// ```
class HanjiBackground extends StatelessWidget {
  /// Child widget to wrap
  final Widget child;

  /// Whether to show subtle fiber texture (default: false)
  /// When hanji_light.png/hanji_dark.png assets are available
  final bool showTexture;

  /// Texture opacity (default: 0.05)
  final double textureOpacity;

  /// Background color override (default: theme-aware hanji color)
  final Color? backgroundColor;

  const HanjiBackground({
    super.key,
    required this.child,
    this.showTexture = false,
    this.textureOpacity = 0.05,
    this.backgroundColor,
  });

  /// Subtle hanji background with minimal texture
  factory HanjiBackground.subtle({
    Key? key,
    required Widget child,
    Color? backgroundColor,
  }) {
    return HanjiBackground(
      key: key,
      showTexture: true,
      textureOpacity: 0.03,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Prominent hanji background with visible texture
  factory HanjiBackground.prominent({
    Key? key,
    required Widget child,
    Color? backgroundColor,
  }) {
    return HanjiBackground(
      key: key,
      showTexture: true,
      textureOpacity: 0.08,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    final effectiveBackground = backgroundColor ?? colors.background;

    return Container(
      color: effectiveBackground,
      child: showTexture
          ? Stack(
              children: [
                // Hanji texture overlay
                Positioned.fill(
                  child: _HanjiTexture(
                    brightness: brightness,
                    opacity: textureOpacity,
                  ),
                ),
                // Content
                child,
              ],
            )
          : child,
    );
  }
}

/// Hanji paper texture overlay
class _HanjiTexture extends StatelessWidget {
  final Brightness brightness;
  final double opacity;

  const _HanjiTexture({
    required this.brightness,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    // Try to load hanji texture asset
    // Falls back to subtle color pattern if asset not available
    final texturePath = brightness == Brightness.dark
        ? 'assets/textures/hanji_dark.png'
        : 'assets/textures/hanji_light.png';

    return Opacity(
      opacity: opacity,
      child: Image.asset(
        texturePath,
        fit: BoxFit.cover,
        repeat: ImageRepeat.repeat,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to subtle pattern when texture not available
          return _FallbackTexture(brightness: brightness);
        },
      ),
    );
  }
}

/// Fallback texture pattern when hanji asset is not available
class _FallbackTexture extends StatelessWidget {
  final Brightness brightness;

  const _FallbackTexture({required this.brightness});

  @override
  Widget build(BuildContext context) {
    // Create subtle noise pattern as fallback
    final baseColor = brightness == Brightness.dark
        ? DSColors.textPrimaryDark
        : DSColors.textPrimary;

    return CustomPaint(
      painter: _HanjiPatternPainter(baseColor: baseColor),
      size: Size.infinite,
    );
  }
}

/// Custom painter for subtle hanji-like pattern
class _HanjiPatternPainter extends CustomPainter {
  final Color baseColor;

  _HanjiPatternPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Create very subtle fiber-like pattern
    final paint = Paint()
      ..color = baseColor.withValues(alpha: 0.02)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw subtle horizontal fibers (like paper texture)
    for (var y = 0.0; y < size.height; y += 3) {
      // Slight variation in line position to simulate paper fibers
      final offset = (y.toInt() % 7) * 0.3;
      canvas.drawLine(
        Offset(offset, y),
        Offset(size.width - offset, y + 0.2),
        paint,
      );
    }

    // Draw subtle vertical fibers
    for (var x = 0.0; x < size.width; x += 5) {
      final offset = (x.toInt() % 11) * 0.2;
      canvas.drawLine(
        Offset(x, offset),
        Offset(x + 0.1, size.height - offset),
        paint..color = baseColor.withValues(alpha: 0.015),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Clean background wrapper for modern AI Chat aesthetic
///
/// Simple, neutral background with no decorations or textures.
class CleanBackground extends StatelessWidget {
  /// Child widget to wrap
  final Widget child;

  /// Background color override (default: theme-aware background color)
  final Color? backgroundColor;

  const CleanBackground({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveBackground = backgroundColor ?? colors.background;

    return Container(
      color: effectiveBackground,
      child: child,
    );
  }
}

/// Clean container for modern card-like elements
class CleanContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const CleanContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: colors.border,
              width: 1,
            ),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Hanji-textured container for smaller elements
class HanjiContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showTexture;

  const HanjiContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 8.0,
    this.showTexture = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: showTexture
            ? Stack(
                children: [
                  _HanjiTexture(
                    brightness: Theme.of(context).brightness,
                    opacity: 0.04,
                  ),
                  child,
                ],
              )
            : child,
      ),
    );
  }
}
