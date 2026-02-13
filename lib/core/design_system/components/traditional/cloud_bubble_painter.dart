import 'package:flutter/material.dart';
import '../../tokens/ds_colors.dart';

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

    // Skip all drawing when both background and border are transparent
    // (ChatGPT style: AI messages have no bubble)
    if (bgColor == Colors.transparent && brdColor == Colors.transparent) {
      return;
    }

    final w = size.width;
    final h = size.height;

    const radius = 12.0;

    // 1. Background fill (skip if transparent)
    if (bgColor != Colors.transparent) {
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
    }

    // 2. Border (skip if transparent)
    if (brdColor != Colors.transparent) {
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(radius),
      );
      canvas.drawRRect(
        bgRect,
        Paint()
          ..color = brdColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }

  Color _getDefaultBackgroundColor() {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    if (bubbleType == CloudBubbleType.user) {
      return DSColors.getUserBubble(brightness);
    }
    // AI messages: transparent (ChatGPT style)
    return Colors.transparent;
  }

  Color _getDefaultBorderColor() {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return DSColors.getBorder(brightness);
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
