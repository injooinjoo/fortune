import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/utils/theme_utils.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final Color? borderColor;
  final double borderWidth;
  final Border? border;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 10,
    this.borderColor,
    this.borderWidth = 1.5,
    this.border,
    this.gradient,
    this.boxShadow,
    this.alignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fortuneTheme = context.fortuneTheme;
    final glassColors = ThemeUtils.getGlassColors(context);
    final isDark = ThemeUtils.isDarkMode(context);

    final defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              glassColors.background,
              glassColors.background.withOpacity(0.5)]
          : [
              AppColors.textPrimaryDark.withOpacity(0.6),
              AppColors.textPrimaryDark.withOpacity(0.3)]
    );

    final defaultBorderColor = borderColor ?? glassColors.border;

    final defaultShadow = [
      BoxShadow(
        color: fortuneTheme.shadowColor.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 10))];

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient ?? defaultGradient,
              borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusXLarge),
              border: border ?? Border.all(
                color: borderColor ?? defaultBorderColor,
                width: borderWidth),
              boxShadow: boxShadow ?? defaultShadow),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final Color? splashColor;
  final Gradient? gradient;
  final Border? border;

  const GlassButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.blur = 10,
    this.splashColor,
    this.gradient,
    this.border}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius as BorderRadius? ?? AppDimensions.borderRadiusLarge,
        splashColor: splashColor ?? Theme.of(context).primaryColor.withOpacity(0.2),
        child: GlassContainer(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.xLarge, vertical: AppSpacing.small),
          borderRadius: borderRadius ?? AppDimensions.borderRadiusLarge,
          blur: blur,
          gradient: gradient,
          border: border,
          child: child)));
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double elevation;
  final Gradient? gradient;

  const GlassCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation = 8,
    this.gradient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = GlassContainer(
      width: width,
      height: height,
      padding: padding ?? AppSpacing.paddingAll20,
      margin: margin,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge),
      blur: 20,
      gradient: gradient,
      boxShadow: [
        BoxShadow(
          color: AppColors.textPrimary.withOpacity(0.1),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation))],
      child: child);

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge),
          child: card));
    }

    return card;
  }
}