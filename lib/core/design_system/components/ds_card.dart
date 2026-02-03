import 'package:flutter/material.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_animation.dart';
import '../theme/ds_extensions.dart';

/// Card style variants
enum DSCardStyle {
  /// Elevated card with subtle drop shadow (default, modern)
  elevated,

  /// Flat card with no shadow
  flat,

  /// Card with clean border
  outlined,

  /// @deprecated Use [flat] instead - legacy hanji style
  hanji,

  /// Premium card with accent border
  premium,

  /// Gradient background card
  gradient,

  /// Glassmorphism card with semi-transparent background
  glassmorphism,
}

/// Modern AI Chat style card component
///
/// Clean, minimalist design with subtle elevation
/// and neutral color palette
///
/// Usage:
/// ```dart
/// // Default elevated card
/// DSCard(
///   child: Text('Content'),
///   style: DSCardStyle.elevated,
/// )
///
/// // Flat card (no shadow)
/// DSCard.flat(
///   child: Text('Flat content'),
/// )
///
/// // Outlined card with border
/// DSCard.outlined(
///   child: Text('Outlined content'),
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

  /// Custom gradient (for gradient style)
  final Gradient? cardGradient;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom border
  final BoxBorder? border;

  const DSCard({
    super.key,
    required this.child,
    this.style = DSCardStyle.elevated,
    this.padding,
    this.borderRadius,
    this.fullWidth = true,
    this.margin,
    this.onTap,
    this.cardGradient,
    this.backgroundColor,
    this.border,
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

  /// @deprecated Use [flat] instead - legacy hanji style
  @Deprecated('Use DSCard.flat instead')
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
      style: DSCardStyle.flat, // Maps to flat in modern design
      padding: padding,
      borderRadius: borderRadius,
      fullWidth: fullWidth,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// Premium card with accent border
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

  /// Gradient card with custom gradient background
  factory DSCard.gradient({
    Key? key,
    required Widget child,
    required Gradient gradient,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    bool fullWidth = true,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    BoxBorder? border,
  }) {
    return DSCard(
      key: key,
      style: DSCardStyle.gradient,
      padding: padding,
      borderRadius: borderRadius,
      fullWidth: fullWidth,
      margin: margin,
      onTap: onTap,
      cardGradient: gradient,
      border: border,
      child: child,
    );
  }

  /// Glassmorphism card with semi-transparent background
  factory DSCard.glassmorphism({
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
      style: DSCardStyle.glassmorphism,
      padding: padding,
      borderRadius: borderRadius ?? DSRadius.xl,
      fullWidth: fullWidth,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveRadius = borderRadius ?? DSRadius.card;
    final effectivePadding =
        padding ?? const EdgeInsets.all(DSSpacing.cardPadding);

    BoxDecoration decoration;

    switch (style) {
      case DSCardStyle.elevated:
        // Modern flat card without shadow (minimal style)
        decoration = BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(effectiveRadius),
        );
        break;

      case DSCardStyle.flat:
      case DSCardStyle.hanji: // Legacy hanji maps to flat
        // Flat card with secondary background
        decoration = BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(effectiveRadius),
        );
        break;

      case DSCardStyle.outlined:
        // Clean bordered card
        decoration = BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: colors.border,
            width: 1,
          ),
        );
        break;

      case DSCardStyle.premium:
        // Premium card with subtle accent border (no shadow)
        decoration = BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.3),
            width: 1,
          ),
        );
        break;

      case DSCardStyle.gradient:
        // Gradient background card
        decoration = BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: border,
        );
        break;

      case DSCardStyle.glassmorphism:
        // Glassmorphism with semi-transparent surface
        decoration = BoxDecoration(
          color: (backgroundColor ?? colors.surface).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.2),
            width: 1,
          ),
        );
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

/// Tappable card with subtle press animation
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
        scale: _isPressed ? DSAnimation.tapScale : 1.0, // Claude standard: 0.98
        duration: _isPressed ? DSAnimation.cardTap : DSAnimation.cardRelease,
        curve: _isPressed ? DSAnimation.cardTapCurve : DSAnimation.cardReleaseCurve,
        child: widget.child,
      ),
    );
  }
}

/// Grouped card for settings-style layouts
///
/// Clean, modern design with subtle styling
///
/// Usage:
/// ```dart
/// DSGroupedCard(
///   header: 'Account',
///   children: [
///     DSListTile(title: 'Profile'),
///     DSListTile(title: 'Email'),
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
    final effectiveRadius = borderRadius ?? DSRadius.card;

    // Determine decoration based on style
    BoxDecoration decoration;
    switch (style) {
      case DSCardStyle.elevated:
        // Modern flat card without shadow (minimal style)
        decoration = BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(effectiveRadius),
        );
        break;

      case DSCardStyle.flat:
      case DSCardStyle.hanji: // Legacy hanji maps to flat
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
            color: colors.border,
            width: 1,
          ),
        );
        break;

      case DSCardStyle.premium:
        // Premium card with subtle accent border (no shadow)
        decoration = BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.3),
            width: 1,
          ),
        );
        break;

      case DSCardStyle.gradient:
        // Gradient not typical for grouped cards, fallback to flat
        decoration = BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(effectiveRadius),
        );
        break;

      case DSCardStyle.glassmorphism:
        // Glassmorphism grouped card
        decoration = BoxDecoration(
          color: colors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.2),
            width: 1,
          ),
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
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

        // Card container
        Container(
          margin: margin ??
              const EdgeInsets.symmetric(
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
