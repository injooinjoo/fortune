import 'package:flutter/material.dart';
import 'utils.dart';

/// Form styles
@immutable
class FormStyles {
  final double inputHeight;
  final double inputBorderRadius;
  final double inputBorderWidth;
  final EdgeInsets inputPadding;
  final double labelFontSize;
  final Duration focusAnimationDuration;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final double focusBorderWidth;

  const FormStyles(
      {required this.inputHeight,
      required this.inputBorderRadius,
      required this.inputBorderWidth,
      required this.inputPadding,
      required this.labelFontSize,
      required this.focusAnimationDuration,
      required this.borderColor,
      required this.focusedBorderColor,
      required this.errorBorderColor,
      required this.focusBorderWidth});

  factory FormStyles.light() => const FormStyles(
      inputHeight: 56.0,
      inputBorderRadius: 12.0,
      inputBorderWidth: 1.0,
      inputPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelFontSize: 14.0,
      focusAnimationDuration: Duration(milliseconds: 200),
      borderColor: Color(0xFFE5E7EB),
      focusedBorderColor: Color(0xFF000000),
      errorBorderColor: Color(0xFFEF4444),
      focusBorderWidth: 2.0);

  factory FormStyles.dark() => const FormStyles(
      inputHeight: 56.0,
      inputBorderRadius: 12.0,
      inputBorderWidth: 1.0,
      inputPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelFontSize: 14.0,
      focusAnimationDuration: Duration(milliseconds: 200),
      borderColor: Color(0xFF2D2D2D),
      focusedBorderColor: Color(0xFFFFFFFF),
      errorBorderColor: Color(0xFFF87171),
      focusBorderWidth: 2.0);

  static FormStyles lerp(FormStyles a, FormStyles b, double t) {
    return FormStyles(
        inputHeight: lerpDouble(a.inputHeight, b.inputHeight, t)!,
        inputBorderRadius:
            lerpDouble(a.inputBorderRadius, b.inputBorderRadius, t)!,
        inputBorderWidth:
            lerpDouble(a.inputBorderWidth, b.inputBorderWidth, t)!,
        inputPadding: EdgeInsets.lerp(a.inputPadding, b.inputPadding, t)!,
        labelFontSize: lerpDouble(a.labelFontSize, b.labelFontSize, t)!,
        focusAnimationDuration: Duration(
            milliseconds: lerpDouble(a.focusAnimationDuration.inMilliseconds,
                    b.focusAnimationDuration.inMilliseconds, t)!
                .round()),
        borderColor: Color.lerp(a.borderColor, b.borderColor, t)!,
        focusedBorderColor:
            Color.lerp(a.focusedBorderColor, b.focusedBorderColor, t)!,
        errorBorderColor:
            Color.lerp(a.errorBorderColor, b.errorBorderColor, t)!,
        focusBorderWidth:
            lerpDouble(a.focusBorderWidth, b.focusBorderWidth, t)!);
  }
}
