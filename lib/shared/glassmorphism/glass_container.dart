import 'package:flutter/material.dart';
import '../../core/theme/fortune_design_system.dart';

/// Toss-style Card Container (replacing GlassCard)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final Gradient? gradient; // Deprecated, kept for compatibility

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.gradient, // Deprecated, ignored in Toss design
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

/// Toss-style Button (replacing GlassButton)
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.cardBackgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Toss-style Container (replacing GlassContainer)
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? blur;
  final Color? borderColor;
  final double? borderWidth;
  final Border? border; // Direct border parameter
  final Gradient? gradient; // Deprecated, kept for compatibility
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur,
    this.borderColor,
    this.borderWidth,
    this.border, // Direct border control
    this.gradient, // Deprecated, ignored in Toss design
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.cardBackgroundLight,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ?? Border.all(
          color: borderColor ?? (isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight),
          width: borderWidth ?? 1,
        ),
      ),
      child: child,
    );
  }
}
