import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/theme/app_typography.dart';

class ProfileFieldEditDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback? onSave;
  final bool isLoading;

  const ProfileFieldEditDialog({
    super.key,
    required this.title,
    required this.content,
    this.onSave,
    this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLarge),
      child: Padding(
        padding: AppSpacing.paddingAll24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.spacing6),
            content,
            const SizedBox(height: AppSpacing.spacing6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: AppTypography.button)),
                const SizedBox(width: AppSpacing.spacing3),
                ElevatedButton(
                  onPressed: isLoading ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DSColors.accentDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSmall),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing6,
                      vertical: AppSpacing.spacing3)),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(DSColors.textPrimary)))
                      : const Text('저장'))])])));
  }
}