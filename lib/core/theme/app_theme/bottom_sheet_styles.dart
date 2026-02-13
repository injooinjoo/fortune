import 'package:flutter/material.dart';
import 'utils.dart';

/// Bottom sheet styles
@immutable
class BottomSheetStyles {
  final double handleWidth;
  final double handleHeight;
  final double handleOpacity;
  final double maxHeight;
  final double borderRadius;
  final Duration animationDuration;
  final double handleTopMargin;
  final EdgeInsets contentPadding;
  final double titleFontSize;
  final double messageFontSize;
  final double optionFontSize;
  final double subtitleFontSize;
  final double iconSize;
  final double spacing;
  final double largeSpacing;
  final double buttonHeight;
  final double buttonBorderRadius;
  final double barrierOpacity;
  final Duration slideAnimationDuration;
  final Duration fadeAnimationDuration;

  const BottomSheetStyles(
      {required this.handleWidth,
      required this.handleHeight,
      required this.handleOpacity,
      required this.maxHeight,
      required this.borderRadius,
      required this.animationDuration,
      required this.handleTopMargin,
      required this.contentPadding,
      required this.titleFontSize,
      required this.messageFontSize,
      required this.optionFontSize,
      required this.subtitleFontSize,
      required this.iconSize,
      required this.spacing,
      required this.largeSpacing,
      required this.buttonHeight,
      required this.buttonBorderRadius,
      required this.barrierOpacity,
      required this.slideAnimationDuration,
      required this.fadeAnimationDuration});

  factory BottomSheetStyles.light() => const BottomSheetStyles(
      handleWidth: 40.0,
      handleHeight: 4.0,
      handleOpacity: 0.4,
      maxHeight: 0.9,
      borderRadius: 24.0,
      animationDuration: Duration(milliseconds: 300),
      handleTopMargin: 12.0,
      contentPadding: EdgeInsets.all(24),
      titleFontSize: 20.0,
      messageFontSize: 15.0,
      optionFontSize: 16.0,
      subtitleFontSize: 14.0,
      iconSize: 24.0,
      spacing: 12.0,
      largeSpacing: 24.0,
      buttonHeight: 52.0,
      buttonBorderRadius: 12.0,
      barrierOpacity: 0.5,
      slideAnimationDuration: Duration(milliseconds: 350),
      fadeAnimationDuration: Duration(milliseconds: 300));

  factory BottomSheetStyles.dark() => const BottomSheetStyles(
      handleWidth: 40.0,
      handleHeight: 4.0,
      handleOpacity: 0.6,
      maxHeight: 0.9,
      borderRadius: 24.0,
      animationDuration: Duration(milliseconds: 300),
      handleTopMargin: 12.0,
      contentPadding: EdgeInsets.all(24),
      titleFontSize: 20.0,
      messageFontSize: 15.0,
      optionFontSize: 16.0,
      subtitleFontSize: 14.0,
      iconSize: 24.0,
      spacing: 12.0,
      largeSpacing: 24.0,
      buttonHeight: 52.0,
      buttonBorderRadius: 12.0,
      barrierOpacity: 0.5,
      slideAnimationDuration: Duration(milliseconds: 350),
      fadeAnimationDuration: Duration(milliseconds: 300));

  static BottomSheetStyles lerp(
      BottomSheetStyles a, BottomSheetStyles b, double t) {
    return BottomSheetStyles(
        handleWidth: lerpDouble(a.handleWidth, b.handleWidth, t)!,
        handleHeight: lerpDouble(a.handleHeight, b.handleHeight, t)!,
        handleOpacity: lerpDouble(a.handleOpacity, b.handleOpacity, t)!,
        maxHeight: lerpDouble(a.maxHeight, b.maxHeight, t)!,
        borderRadius: lerpDouble(a.borderRadius, b.borderRadius, t)!,
        animationDuration: Duration(
            milliseconds: lerpDouble(a.animationDuration.inMilliseconds,
                    b.animationDuration.inMilliseconds, t)!
                .round()),
        handleTopMargin: lerpDouble(a.handleTopMargin, b.handleTopMargin, t)!,
        contentPadding: EdgeInsets.lerp(a.contentPadding, b.contentPadding, t)!,
        titleFontSize: lerpDouble(a.titleFontSize, b.titleFontSize, t)!,
        messageFontSize: lerpDouble(a.messageFontSize, b.messageFontSize, t)!,
        optionFontSize: lerpDouble(a.optionFontSize, b.optionFontSize, t)!,
        subtitleFontSize:
            lerpDouble(a.subtitleFontSize, b.subtitleFontSize, t)!,
        iconSize: lerpDouble(a.iconSize, b.iconSize, t)!,
        spacing: lerpDouble(a.spacing, b.spacing, t)!,
        largeSpacing: lerpDouble(a.largeSpacing, b.largeSpacing, t)!,
        buttonHeight: lerpDouble(a.buttonHeight, b.buttonHeight, t)!,
        buttonBorderRadius:
            lerpDouble(a.buttonBorderRadius, b.buttonBorderRadius, t)!,
        barrierOpacity: lerpDouble(a.barrierOpacity, b.barrierOpacity, t)!,
        slideAnimationDuration: Duration(
            milliseconds: lerpDouble(a.slideAnimationDuration.inMilliseconds,
                    b.slideAnimationDuration.inMilliseconds, t)!
                .round()),
        fadeAnimationDuration: Duration(
            milliseconds: lerpDouble(a.fadeAnimationDuration.inMilliseconds,
                    b.fadeAnimationDuration.inMilliseconds, t)!
                .round()));
  }
}
