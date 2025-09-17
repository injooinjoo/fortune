import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/utils/theme_utils.dart';

/// Base card widget that enforces consistent design guidelines
/// Light mode: Background #f6f6f6, Card #ffffff
/// Dark mode: Background #0A0A0A, Card #1C1C1C
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final Gradient? gradient;

  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.gradient});

  @override
  Widget build(BuildContext context) {
    final fortuneTheme = context.fortuneTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cardColor = backgroundColor ?? (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white);
    
    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient != null ? null : cardColor,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(TossDesignSystem.radiusL),
        boxShadow: boxShadow ?? (isDark ? null : TossDesignSystem.shadowXS),
        border: border),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(TossDesignSystem.spacingL),
        child: child));
    
    if (onTap != null) {
      return Material(
        color: TossDesignSystem.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(TossDesignSystem.radiusL),
          child: content));
    }
    
    return content;
  }
}

/// Premium card with gradient background
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap});

  @override
  Widget build(BuildContext context) {
    final fortuneTheme = context.fortuneTheme;
    
    return BaseCard(
      child: child,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      onTap: onTap,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          fortuneTheme.fortuneGradientStart,
          fortuneTheme.fortuneGradientEnd]),
      border: Border.all(
        color: fortuneTheme.fortuneGradientStart.withOpacity(0.3),
        width: 1));
  }
}

/// Info card for displaying information
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BaseCard(
      onTap: onTap,
      backgroundColor: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: TossDesignSystem.spacingM)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TossDesignSystem.body1.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: TossDesignSystem.spacingXXS),
                  Text(
                    subtitle!,
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}