import 'package:flutter/material.dart';
import 'utils.dart';

/// Card styles - TOSS design system cards
@immutable
class CardStyles {
  final EdgeInsets defaultPadding;
  final EdgeInsets sectionPadding;
  final EdgeInsets listItemPadding;
  final double defaultBorderRadius;
  final double glassBorderRadius;
  final double elevation;
  final double glassBlur;
  final double borderWidth;
  final double sectionHeaderFontSize;
  final double listItemTitleFontSize;
  final double listItemSubtitleFontSize;
  final double itemSpacing;
  final double sectionSpacing;
  final double pressScale;
  final Duration pressAnimationDuration;

  const CardStyles(
      {required this.defaultPadding,
      required this.sectionPadding,
      required this.listItemPadding,
      required this.defaultBorderRadius,
      required this.glassBorderRadius,
      required this.elevation,
      required this.glassBlur,
      required this.borderWidth,
      required this.sectionHeaderFontSize,
      required this.listItemTitleFontSize,
      required this.listItemSubtitleFontSize,
      required this.itemSpacing,
      required this.sectionSpacing,
      required this.pressScale,
      required this.pressAnimationDuration});

  factory CardStyles.light() => const CardStyles(
      defaultPadding: EdgeInsets.all(16),
      sectionPadding: EdgeInsets.all(20),
      listItemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      defaultBorderRadius: 16.0,
      glassBorderRadius: 24.0,
      elevation: 8.0,
      glassBlur: 20.0,
      borderWidth: 1.0,
      sectionHeaderFontSize: 18.0,
      listItemTitleFontSize: 16.0,
      listItemSubtitleFontSize: 14.0,
      itemSpacing: 16.0,
      sectionSpacing: 4.0,
      pressScale: 0.98,
      pressAnimationDuration: Duration(milliseconds: 100));

  factory CardStyles.dark() => const CardStyles(
      defaultPadding: EdgeInsets.all(16),
      sectionPadding: EdgeInsets.all(20),
      listItemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      defaultBorderRadius: 16.0,
      glassBorderRadius: 24.0,
      elevation: 8.0,
      glassBlur: 20.0,
      borderWidth: 1.0,
      sectionHeaderFontSize: 18.0,
      listItemTitleFontSize: 16.0,
      listItemSubtitleFontSize: 14.0,
      itemSpacing: 16.0,
      sectionSpacing: 4.0,
      pressScale: 0.98,
      pressAnimationDuration: Duration(milliseconds: 100));

  static CardStyles lerp(CardStyles a, CardStyles b, double t) {
    return CardStyles(
        defaultPadding: EdgeInsets.lerp(a.defaultPadding, b.defaultPadding, t)!,
        sectionPadding: EdgeInsets.lerp(a.sectionPadding, b.sectionPadding, t)!,
        listItemPadding:
            EdgeInsets.lerp(a.listItemPadding, b.listItemPadding, t)!,
        defaultBorderRadius:
            lerpDouble(a.defaultBorderRadius, b.defaultBorderRadius, t)!,
        glassBorderRadius:
            lerpDouble(a.glassBorderRadius, b.glassBorderRadius, t)!,
        elevation: lerpDouble(a.elevation, b.elevation, t)!,
        glassBlur: lerpDouble(a.glassBlur, b.glassBlur, t)!,
        borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t)!,
        sectionHeaderFontSize:
            lerpDouble(a.sectionHeaderFontSize, b.sectionHeaderFontSize, t)!,
        listItemTitleFontSize:
            lerpDouble(a.listItemTitleFontSize, b.listItemTitleFontSize, t)!,
        listItemSubtitleFontSize: lerpDouble(
            a.listItemSubtitleFontSize, b.listItemSubtitleFontSize, t)!,
        itemSpacing: lerpDouble(a.itemSpacing, b.itemSpacing, t)!,
        sectionSpacing: lerpDouble(a.sectionSpacing, b.sectionSpacing, t)!,
        pressScale: lerpDouble(a.pressScale, b.pressScale, t)!,
        pressAnimationDuration: Duration(
            milliseconds: lerpDouble(a.pressAnimationDuration.inMilliseconds,
                    b.pressAnimationDuration.inMilliseconds, t)!
                .round()));
  }
}
