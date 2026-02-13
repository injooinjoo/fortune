import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

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
    final card = Card(
        margin: margin ?? AppSpacing.paddingAll8,
        elevation: elevation ?? 2,
        color: backgroundColor ?? Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? AppDimensions.borderRadiusMedium),
        child:
            Padding(padding: padding ?? AppSpacing.paddingAll16, child: child));

    if (onTap != null) {
      return InkWell(
          onTap: onTap,
          borderRadius: (borderRadius ?? AppDimensions.borderRadiusMedium)
              as BorderRadius,
          child: card);
    }

    return card;
  }
}
