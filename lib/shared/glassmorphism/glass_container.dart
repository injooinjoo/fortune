import 'package:flutter/material.dart';
import '../../core/theme/toss_design_system.dart';

/// Toss-style Card Container (replacing GlassCard)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray200,
          width: 1,
        ),
      ),
      child: child,
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

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur,
    this.borderColor,
    this.borderWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? (isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray200),
          width: borderWidth ?? 1,
        ),
      ),
      child: child,
    );
  }
}
