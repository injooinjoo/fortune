import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/utils/theme_utils.dart';
import 'package:fortune/core/theme/app_typography.dart';

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
    final defaultShadow = ThemeUtils.getCardShadow(context);
    
    final cardColor = backgroundColor ?? fortuneTheme.cardSurface;
    
    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient != null ? null : cardColor,
        gradient: gradient,
        borderRadius: borderRadius ?? AppDimensions.borderRadiusMedium,
        boxShadow: boxShadow ?? defaultShadow,
        border: border ?? Border.all(
          color: fortuneTheme.dividerColor.withOpacity(0.1),
          width: 1)),
      child: Padding(
        padding: padding ?? AppSpacing.paddingAll16,
        child: child));
    
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppDimensions.borderRadiusMedium,
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
    
    return BaseCard(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: AppSpacing.spacing4)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.spacing1),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6)))]])),
          if (trailing != null) trailing!]))
  }
}