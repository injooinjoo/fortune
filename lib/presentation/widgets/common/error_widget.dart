import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData icon;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline}));

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
                color: colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.error)),
            SizedBox(height: AppSpacing.spacing6),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
            if (details != null) ...[
              SizedBox(height: AppSpacing.spacing2),
              Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis)]
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.spacing6),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError))]])));
  }
}