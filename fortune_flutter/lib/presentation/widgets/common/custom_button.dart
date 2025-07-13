import 'package:flutter/material.dart';

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
  }) : super(key: key);

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
        fgColor = textColor ?? Colors.white;
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
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  variant == ButtonVariant.primary ? Colors.white : theme.primaryColor,
                ),
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: fgColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
    
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: gradient != null
          ? Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: button,
            )
          : button,
    );
  }
}