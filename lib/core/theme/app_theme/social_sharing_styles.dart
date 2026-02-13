import 'package:flutter/material.dart';
import 'utils.dart';

/// Social sharing styles
@immutable
class SocialSharingStyles {
  final double shareButtonSize;
  final double shareIconSize;
  final EdgeInsets sharePadding;
  final Duration shareAnimationDuration;

  const SocialSharingStyles(
      {required this.shareButtonSize,
      required this.shareIconSize,
      required this.sharePadding,
      required this.shareAnimationDuration});

  factory SocialSharingStyles.light() => const SocialSharingStyles(
      shareButtonSize: 56.0,
      shareIconSize: 24.0,
      sharePadding: EdgeInsets.all(16),
      shareAnimationDuration: Duration(milliseconds: 200));

  factory SocialSharingStyles.dark() => const SocialSharingStyles(
      shareButtonSize: 56.0,
      shareIconSize: 24.0,
      sharePadding: EdgeInsets.all(16),
      shareAnimationDuration: Duration(milliseconds: 200));

  static SocialSharingStyles lerp(
      SocialSharingStyles a, SocialSharingStyles b, double t) {
    return SocialSharingStyles(
        shareButtonSize: lerpDouble(a.shareButtonSize, b.shareButtonSize, t)!,
        shareIconSize: lerpDouble(a.shareIconSize, b.shareIconSize, t)!,
        sharePadding: EdgeInsets.lerp(a.sharePadding, b.sharePadding, t)!,
        shareAnimationDuration: Duration(
            milliseconds: lerpDouble(a.shareAnimationDuration.inMilliseconds,
                    b.shareAnimationDuration.inMilliseconds, t)!
                .round()));
  }
}
