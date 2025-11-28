import 'package:flutter/material.dart';
import 'utils.dart';

/// Error states configuration
@immutable
class ErrorStates {
  final Color errorBackground;
  final Color errorBorder;
  final IconData errorIcon;
  final double errorIconSize;
  final Duration errorAnimationDuration;

  const ErrorStates({
    required this.errorBackground,
    required this.errorBorder,
    required this.errorIcon,
    required this.errorIconSize,
    required this.errorAnimationDuration});

  factory ErrorStates.light() => const ErrorStates(
        errorBackground: Color(0xFFFEE2E2),
        errorBorder: Color(0xFFFCA5A5),
        errorIcon: Icons.error_outline,
        errorIconSize: 48.0,
        errorAnimationDuration: Duration(milliseconds: 300));

  factory ErrorStates.dark() => const ErrorStates(
        errorBackground: Color(0xFF2D1B1B),
        errorBorder: Color(0xFF991B1B),
        errorIcon: Icons.error_outline,
        errorIconSize: 48.0,
        errorAnimationDuration: Duration(milliseconds: 300));

  static ErrorStates lerp(ErrorStates a, ErrorStates b, double t) {
    return ErrorStates(
      errorBackground: Color.lerp(a.errorBackground, b.errorBackground, t)!,
      errorBorder: Color.lerp(a.errorBorder, b.errorBorder, t)!,
      errorIcon: t < 0.5 ? a.errorIcon : b.errorIcon,
      errorIconSize: lerpDouble(a.errorIconSize, b.errorIconSize, t)!,
      errorAnimationDuration: Duration(milliseconds: lerpDouble(a.errorAnimationDuration.inMilliseconds, b.errorAnimationDuration.inMilliseconds, t)!.round()));
  }
}
