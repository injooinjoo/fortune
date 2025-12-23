import 'package:flutter/material.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_shadows.dart';
import '../tokens/ds_animation.dart';
import '../theme/ds_extensions.dart';

/// Card style variants
enum DSCardStyle {
  /// Ink-wash shadow effect (default, traditional Korean)
  elevated,

  /// Flat card with no shadow
  flat,

  /// Card with ink-wash border
  outlined,

  /// Hanji paper texture card (Korean traditional)
  hanji,

  /// Premium card with gold accent
  premium,
}

/// Korean Traditional "Saaju" card component
///
/// Features ink-wash (번짐) effects instead of drop shadows
/// for an authentic Korean traditional aesthetic
///
/// Usage:
/// ```dart
/// // Default ink-wash card
/// DSCard(
///   child: Text('Content'),
///   style: DSCardStyle.elevated,
/// )
///
/// // Hanji paper texture card
/// DSCard.hanji(
///   child: Text('Traditional content'),
/// )
///
/// // Premium gold accent card
/// DSCard.premium(
///   child: Text('Premium content'),
/// )
/// ```
class DSCard extends StatelessWidget {
  /// Card content
  final Widget child;

  /// Card style
  final DSCardStyle style;

  /// Content padding
  final EdgeInsetsGeometry? padding;

  /// Border radius
  final double? borderRadius;

  /// Full width card
  final bool fullWidth;

  /// Custom margin
  final EdgeInsetsGeometry? margin;

  /// Tap callback
  final VoidCallback? onTap;

  const DSCard({
    super.key,
    required this.child,
    this.style = DSCardStyle.elevated,
    this.padding,
    this.borderRadius,
    this.fullWidth = true,
    this.margin,
    this.onTap,
  });

  /// Elevated card with shadow
  factory DSCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool fullWidth = true,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return DSCard(
      key: key,
      style: DSCardStyle.elevated,
      padding: padding,
      borderRadius: borderRadius,
      fullWidth: fullWidth,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Flat card without shadow
  factory DSCard.flat({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool fullWidth = true,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return DSCard(
      key: key,
      style: DSCardStyle.flat,
      padding: padding,
      borderRadius: borderRadius,
      fullWidth: fullWidth,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Outlined card with border
  factory DSCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool fullWidth = true,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return DSCard(
      key: key,
      style: DSCardStyle.outlined,
      padding: padding,
      borderRadius: borderRadius,
      fullWidth: fullWidth,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Hanji paper texture card (Korean traditional)
  factory DSCard.hanji({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool fullWidth = true,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return DSCard(
      key: key,
      style: DSCardStyle.hanji,
      padding: padding,
      borderRadius: borderRadius,
      fullWidth: fullWidth,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Premium card with gold accent
  factory DSCard.premium({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool fullWidth = true,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return DSCard(
      key: key,
      style: DSCardStyle.premium,
      padding: padding,
      borderRadius: borderRadius,
      fullWidth: fullWidth,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    final effectiveRadius = borderRadius ?? DSRadius.md;
    final effectivePadding = padding ?? const EdgeInsets.all(DSSpacing.cardPadding);

    BoxDecoration decoration;

    switch (style) {
      case DSCardStyle.elevated:
        // Ink-wash effect (번짐) - traditional Korean aesthetic
        decoration = DSShadows.getInkWashDecoration(
          brightness,
          backgroundColor: colors.surface,
          borderRadius: effectiveRadius,
        );
        break;
      case DSCardStyle.flat:
        decoration = BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(effectiveRadius),
        );
        break;
      case DSCardStyle.outlined:
        // Ink-wash border style
        decoration = BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: colors.textPrimary.withValues(alpha: 0.12),
            width: 1,
          ),
        );
        break;
      case DSCardStyle.hanji:
        // Traditional hanji paper card with ink-wash effect
        decoration = DSShadows.getInkWashDecoration(
          brightness,
          backgroundColor: colors.background,
          borderRadius: effectiveRadius,
        );
        break;
      case DSCardStyle.premium:
        // Premium gold accent decoration
        decoration = DSShadows.goldAccentDecoration(
          borderRadius: effectiveRadius,
        ).copyWith(color: colors.surface);
        break;
    }

    final Widget card = Container(
      width: fullWidth ? double.infinity : null,
      margin: margin,
      padding: effectivePadding,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return _TappableCard(
        onTap: onTap!,
        child: card,
      );
    }

    return card;
  }
}

/// Tappable card with ink-press animation
class _TappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TappableCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? DSAnimation.cardTapScale : 1.0,
        duration: _isPressed ? DSAnimation.cardTap : DSAnimation.cardRelease,
        curve: _isPressed ? DSAnimation.cardTapCurve : DSAnimation.cardReleaseCurve,
        child: widget.child,
      ),
    );
  }
}

/// Grouped card for settings-style layouts (Korean Traditional style)
///
/// Features ink-wash borders and traditional hanji paper aesthetic
///
/// Usage:
/// ```dart
/// DSGroupedCard(
///   header: '계정',
///   children: [
///     DSListTile(title: '프로필'),
///     DSListTile(title: '이메일'),
///   ],
/// )
/// ```
class DSGroupedCard extends StatelessWidget {
  /// Section header text
  final String? header;

  /// List items
  final List<Widget> children;

  /// Card style
  final DSCardStyle style;

  /// Card padding (inner content padding)
  final EdgeInsetsGeometry? contentPadding;

  /// Border radius
  final double? borderRadius;

  /// Margin around the card
  final EdgeInsetsGeometry? margin;

  const DSGroupedCard({
    super.key,
    this.header,
    required this.children,
    this.style = DSCardStyle.flat,
    this.contentPadding,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final brightness = Theme.of(context).brightness;
    final effectiveRadius = borderRadius ?? DSRadius.md;

    // Determine decoration based on style
    BoxDecoration decoration;
    switch (style) {
      case DSCardStyle.elevated:
      case DSCardStyle.hanji:
        // Ink-wash decoration for elevated and hanji styles
        decoration = DSShadows.getInkWashDecoration(
          brightness,
          backgroundColor: style == DSCardStyle.hanji
              ? colors.background
              : colors.surface,
          borderRadius: effectiveRadius,
        );
        break;
      case DSCardStyle.flat:
        decoration = BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(effectiveRadius),
        );
        break;
      case DSCardStyle.outlined:
        decoration = BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: colors.textPrimary.withValues(alpha: 0.12),
            width: 1,
          ),
        );
        break;
      case DSCardStyle.premium:
        decoration = DSShadows.goldAccentDecoration(
          borderRadius: effectiveRadius,
        ).copyWith(color: colors.surface);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with traditional styling
        if (header != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: DSSpacing.pageHorizontal,
              bottom: DSSpacing.sm,
              top: margin != null ? 0 : DSSpacing.sectionHeaderTop,
            ),
            child: Text(
              header!,
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],

        // Card with ink-wash decoration
        Container(
          margin: margin ?? const EdgeInsets.symmetric(
            horizontal: DSSpacing.pageHorizontal,
          ),
          decoration: decoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(effectiveRadius),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
