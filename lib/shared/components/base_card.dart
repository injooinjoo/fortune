import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../core/theme/app_theme_extensions.dart';

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
    final colors = context.colors;
    final shadows = context.shadows;

    final cardColor = backgroundColor ?? colors.surface;

    final Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient != null ? null : cardColor,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(DSRadius.lg),
        boxShadow: boxShadow ?? [shadows.card],
        border: border),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(DSSpacing.lg),
        child: child));

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(DSRadius.lg),
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
        color: fortuneTheme.fortuneGradientStart.withValues(alpha: 0.3),
        width: 1),
      child: child);
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
    final colors = context.colors;
    final typography = context.typography;

    return BaseCard(
      onTap: onTap,
      backgroundColor: colors.surface,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: DSSpacing.md)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    subtitle!,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
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