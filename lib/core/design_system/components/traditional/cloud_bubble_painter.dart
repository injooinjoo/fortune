import 'package:flutter/material.dart';
import '../../tokens/ds_fortune_colors.dart';

/// Cloud bubble shape types
enum CloudBubbleType {
  /// AI/System message (왼쪽)
  ai,

  /// User message (오른쪽)
  user,
}

/// CustomPainter for vintage banner-style chat bubbles
///
/// Creates rectangular banners with:
/// - Double border frame
/// - Cream/white background
/// - Corner decorations handled separately via assets
class CloudBubblePainter extends CustomPainter {
  final bool isDark;
  final CloudBubbleType bubbleType;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool showInkBleed;

  CloudBubblePainter({
    required this.isDark,
    required this.bubbleType,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.showInkBleed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = backgroundColor ?? _getDefaultBackgroundColor();
    final brdColor = borderColor ?? _getDefaultBorderColor();

    final w = size.width;
    final h = size.height;

    const radius = 2.0;
    const borderGap = 4.0;

    // 1. Subtle shadow
    if (showInkBleed) {
      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, w - 2, h - 2),
        const Radius.circular(radius),
      );
      canvas.drawRRect(
        shadowRect,
        Paint()
          ..color = brdColor.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // 2. Background fill
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(radius),
    );
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill,
    );

    // 3. Outer border
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = brdColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // 4. Inner border (double border effect)
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderGap, borderGap, w - borderGap * 2, h - borderGap * 2),
      const Radius.circular(radius),
    );
    canvas.drawRRect(
      innerRect,
      Paint()
        ..color = brdColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 0.8,
    );
  }

  Color _getDefaultBackgroundColor() {
    if (bubbleType == CloudBubbleType.user) {
      return DSFortuneColors.getUserBubbleBackground(isDark);
    }
    return DSFortuneColors.getAiBubbleBackground(isDark);
  }

  Color _getDefaultBorderColor() {
    return DSFortuneColors.getBubbleBorder(isDark);
  }

  @override
  bool shouldRepaint(covariant CloudBubblePainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.bubbleType != bubbleType ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.showInkBleed != showInkBleed;
  }
}
