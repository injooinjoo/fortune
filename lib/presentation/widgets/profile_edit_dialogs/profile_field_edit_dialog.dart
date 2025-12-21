import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/fortune_design_system.dart';
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
            SizedBox(height: AppSpacing.spacing6),
            content,
            SizedBox(height: AppSpacing.spacing6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: AppTypography.button)),
                SizedBox(width: AppSpacing.spacing3),
                ElevatedButton(
                  onPressed: isLoading ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TossDesignSystem.tossBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSmall),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing6,
                      vertical: AppSpacing.spacing3)),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.grayDark900)))
                      : const Text('저장'))])])));
  }
}