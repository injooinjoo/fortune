import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconSize = 80});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingAll24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingAll24,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle),
              child: Icon(
                icon,
                size: iconSize,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6))),
            SizedBox(height: AppSpacing.spacing6),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.spacing2),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center)]
            if (action != null) ...[
              SizedBox(height: AppSpacing.spacing6),
              action!]])));
  }
}