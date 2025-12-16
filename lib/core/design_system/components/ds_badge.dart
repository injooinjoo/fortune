import 'package:flutter/material.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../theme/ds_extensions.dart';

/// Badge style variants
enum DSBadgeStyle {
  /// Default badge
  standard,

  /// Dot badge (no label)
  dot,

  /// Pill badge (longer text)
  pill,
}

/// Badge color variants
enum DSBadgeColor {
  accent,
  success,
  error,
  warning,
  info,
}

/// ChatGPT-inspired badge component
///
/// Usage:
/// ```dart
/// DSBadge(label: 'NEW')
/// DSBadge(label: 'PRO', color: DSBadgeColor.accent)
/// DSBadge.dot()  // notification dot
/// ```
class DSBadge extends StatelessWidget {
  /// Badge label
  final String? label;

  /// Badge count (alternative to label)
  final int? count;

  /// Badge color
  final DSBadgeColor color;

  /// Badge style
  final DSBadgeStyle style;

  /// Max count to show (shows 99+ if exceeded)
  final int maxCount;

  const DSBadge({
    super.key,
    this.label,
    this.count,
    this.color = DSBadgeColor.accent,
    this.style = DSBadgeStyle.standard,
    this.maxCount = 99,
  }) : assert(label != null || count != null || style == DSBadgeStyle.dot,
            'Either label, count must be provided, or style must be dot');

  /// Dot badge for notifications
  factory DSBadge.dot({
    Key? key,
    DSBadgeColor color = DSBadgeColor.error,
  }) {
    return DSBadge(
      key: key,
      color: color,
      style: DSBadgeStyle.dot,
    );
  }

  /// Count badge
  factory DSBadge.count({
    Key? key,
    required int count,
    DSBadgeColor color = DSBadgeColor.error,
    int maxCount = 99,
  }) {
    return DSBadge(
      key: key,
      count: count,
      color: color,
      maxCount: maxCount,
    );
  }

  /// Pro badge
  factory DSBadge.pro({Key? key}) {
    return DSBadge(
      key: key,
      label: 'PRO',
      color: DSBadgeColor.accent,
    );
  }

  /// New badge
  factory DSBadge.newBadge({Key? key}) {
    return DSBadge(
      key: key,
      label: 'NEW',
      color: DSBadgeColor.success,
    );
  }

  Color _getBackgroundColor(DSColorScheme colors) {
    switch (color) {
      case DSBadgeColor.accent:
        return colors.accent;
      case DSBadgeColor.success:
        return colors.success;
      case DSBadgeColor.error:
        return colors.error;
      case DSBadgeColor.warning:
        return colors.warning;
      case DSBadgeColor.info:
        return colors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final backgroundColor = _getBackgroundColor(colors);

    // Dot style
    if (style == DSBadgeStyle.dot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
      );
    }

    // Determine display text
    String displayText;
    if (count != null) {
      displayText = count! > maxCount ? '$maxCount+' : count.toString();
    } else {
      displayText = label!;
    }

    // Standard/pill badge
    final isShort = displayText.length <= 2;

    return Container(
      constraints: BoxConstraints(
        minWidth: isShort ? 18 : 0,
        minHeight: 18,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isShort ? DSSpacing.xs : DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          style == DSBadgeStyle.pill ? DSRadius.full : DSRadius.xs,
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          style: typography.labelSmall.copyWith(
            color: DSColors.ctaForeground,
            fontWeight: FontWeight.w600,
            fontSize: 10,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Badge wrapper for positioning badge on another widget
///
/// Usage:
/// ```dart
/// DSBadgeWrapper(
///   badge: DSBadge.dot(),
///   child: Icon(Icons.notifications),
/// )
/// ```
class DSBadgeWrapper extends StatelessWidget {
  /// The widget to wrap
  final Widget child;

  /// The badge widget
  final Widget badge;

  /// Badge position
  final DSBadgePosition position;

  /// Offset from corner
  final Offset offset;

  const DSBadgeWrapper({
    super.key,
    required this.child,
    required this.badge,
    this.position = DSBadgePosition.topRight,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    double? top, right, bottom, left;

    switch (position) {
      case DSBadgePosition.topRight:
        top = -4 + offset.dy;
        right = -4 + offset.dx;
        break;
      case DSBadgePosition.topLeft:
        top = -4 + offset.dy;
        left = -4 + offset.dx;
        break;
      case DSBadgePosition.bottomRight:
        bottom = -4 + offset.dy;
        right = -4 + offset.dx;
        break;
      case DSBadgePosition.bottomLeft:
        bottom = -4 + offset.dy;
        left = -4 + offset.dx;
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
          child: badge,
        ),
      ],
    );
  }
}

/// Badge position
enum DSBadgePosition {
  topRight,
  topLeft,
  bottomRight,
  bottomLeft,
}
