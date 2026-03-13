import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/shared/components/cards/fortune_cards.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        (borderRadius ?? AppDimensions.borderRadiusMedium)
            .resolve(Directionality.of(context));

    return FortuneCardSurface(
      style: (elevation ?? 2) > 0 ? DSCardStyle.elevated : DSCardStyle.flat,
      margin: margin ?? AppSpacing.paddingAll8,
      padding: padding ?? AppSpacing.paddingAll16,
      borderRadius: effectiveBorderRadius.topLeft.x,
      backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
      onTap: onTap,
      child: child,
    );
  }
}
