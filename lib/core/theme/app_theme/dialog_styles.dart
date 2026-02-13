import 'package:flutter/material.dart';
import 'utils.dart';

/// Dialog styles - TOSS design system dialogs
@immutable
class DialogStyles {
  final EdgeInsets contentPadding;
  final EdgeInsets wrapperPadding;
  final double borderRadius;
  final double barrierOpacity;
  final double titleFontSize;
  final double messageFontSize;
  final double iconSize;
  final double iconContainerSize;
  final double spacing;
  final double largeSpacing;
  final double loadingSize;
  final double loadingStrokeWidth;
  final Duration scaleAnimationDuration;
  final Duration fadeAnimationDuration;
  final Duration shakeAnimationDuration;
  final Duration shimmerDuration;

  const DialogStyles(
      {required this.contentPadding,
      required this.wrapperPadding,
      required this.borderRadius,
      required this.barrierOpacity,
      required this.titleFontSize,
      required this.messageFontSize,
      required this.iconSize,
      required this.iconContainerSize,
      required this.spacing,
      required this.largeSpacing,
      required this.loadingSize,
      required this.loadingStrokeWidth,
      required this.scaleAnimationDuration,
      required this.fadeAnimationDuration,
      required this.shakeAnimationDuration,
      required this.shimmerDuration});

  factory DialogStyles.light() => const DialogStyles(
      contentPadding: EdgeInsets.all(24),
      wrapperPadding: EdgeInsets.symmetric(horizontal: 40),
      borderRadius: 16.0,
      barrierOpacity: 0.5,
      titleFontSize: 18.0,
      messageFontSize: 15.0,
      iconSize: 48.0,
      iconContainerSize: 72.0,
      spacing: 12.0,
      largeSpacing: 24.0,
      loadingSize: 48.0,
      loadingStrokeWidth: 3.0,
      scaleAnimationDuration: Duration(milliseconds: 200),
      fadeAnimationDuration: Duration(milliseconds: 150),
      shakeAnimationDuration: Duration(milliseconds: 300),
      shimmerDuration: Duration(milliseconds: 1500));

  factory DialogStyles.dark() => const DialogStyles(
      contentPadding: EdgeInsets.all(24),
      wrapperPadding: EdgeInsets.symmetric(horizontal: 40),
      borderRadius: 16.0,
      barrierOpacity: 0.5,
      titleFontSize: 18.0,
      messageFontSize: 15.0,
      iconSize: 48.0,
      iconContainerSize: 72.0,
      spacing: 12.0,
      largeSpacing: 24.0,
      loadingSize: 48.0,
      loadingStrokeWidth: 3.0,
      scaleAnimationDuration: Duration(milliseconds: 200),
      fadeAnimationDuration: Duration(milliseconds: 150),
      shakeAnimationDuration: Duration(milliseconds: 300),
      shimmerDuration: Duration(milliseconds: 1500));

  static DialogStyles lerp(DialogStyles a, DialogStyles b, double t) {
    return DialogStyles(
        contentPadding: EdgeInsets.lerp(a.contentPadding, b.contentPadding, t)!,
        wrapperPadding: EdgeInsets.lerp(a.wrapperPadding, b.wrapperPadding, t)!,
        borderRadius: lerpDouble(a.borderRadius, b.borderRadius, t)!,
        barrierOpacity: lerpDouble(a.barrierOpacity, b.barrierOpacity, t)!,
        titleFontSize: lerpDouble(a.titleFontSize, b.titleFontSize, t)!,
        messageFontSize: lerpDouble(a.messageFontSize, b.messageFontSize, t)!,
        iconSize: lerpDouble(a.iconSize, b.iconSize, t)!,
        iconContainerSize:
            lerpDouble(a.iconContainerSize, b.iconContainerSize, t)!,
        spacing: lerpDouble(a.spacing, b.spacing, t)!,
        largeSpacing: lerpDouble(a.largeSpacing, b.largeSpacing, t)!,
        loadingSize: lerpDouble(a.loadingSize, b.loadingSize, t)!,
        loadingStrokeWidth:
            lerpDouble(a.loadingStrokeWidth, b.loadingStrokeWidth, t)!,
        scaleAnimationDuration: Duration(
            milliseconds: lerpDouble(a.scaleAnimationDuration.inMilliseconds,
                    b.scaleAnimationDuration.inMilliseconds, t)!
                .round()),
        fadeAnimationDuration: Duration(
            milliseconds: lerpDouble(a.fadeAnimationDuration.inMilliseconds,
                    b.fadeAnimationDuration.inMilliseconds, t)!
                .round()),
        shakeAnimationDuration: Duration(
            milliseconds: lerpDouble(a.shakeAnimationDuration.inMilliseconds,
                    b.shakeAnimationDuration.inMilliseconds, t)!
                .round()),
        shimmerDuration: Duration(
            milliseconds: lerpDouble(a.shimmerDuration.inMilliseconds, b.shimmerDuration.inMilliseconds, t)!.round()));
  }
}
