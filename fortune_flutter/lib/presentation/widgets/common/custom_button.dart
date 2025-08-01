import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final ButtonVariant variant;
  final Gradient? gradient;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.variant = ButtonVariant.primary,
    this.gradient,
  })) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine colors based on variant
    Color? bgColor;
    Color? fgColor;
    BorderSide? borderSide;
    
    switch (variant) {
      case ButtonVariant.primary:
        bgColor = backgroundColor ?? theme.primaryColor;
        fgColor = textColor ?? AppColors.textPrimaryDark;
        break;
      case ButtonVariant.secondary:
        bgColor = backgroundColor ?? theme.primaryColor.withValues(alpha: 0.1);
        fgColor = textColor ?? theme.primaryColor;
        break;
      case ButtonVariant.outline:
        bgColor = backgroundColor ?? Colors.transparent;
        fgColor = textColor ?? theme.primaryColor;
        borderSide = BorderSide(color: theme.primaryColor);
        break;
    }
    
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: gradient != null ? Colors.transparent : bgColor,
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing6,
          vertical: AppSpacing.spacing3,
        ),
        side: borderSide,
        shadowColor: Colors.transparent,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  variant == ButtonVariant.primary ? AppColors.textPrimaryDark : theme.primaryColor,
                ),
              ),
            )
          : Text(
              text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
    );
    
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: gradient != null
          ? Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
              child: button,
            )
          : button,
    );
  }
}