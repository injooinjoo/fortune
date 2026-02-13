import 'package:flutter/material.dart';
import 'utils.dart';

/// Loading states configuration
@immutable
class LoadingStates {
  final Color skeletonBase;
  final Color skeletonHighlight;
  final double skeletonOpacity;
  final Duration shimmerDuration;
  final double progressStrokeWidth;
  final double progressBarRadius;

  // Aliases for compatibility
  Color get skeletonBaseColor => skeletonBase;
  Color get skeletonHighlightColor => skeletonHighlight;

  const LoadingStates(
      {required this.skeletonBase,
      required this.skeletonHighlight,
      required this.skeletonOpacity,
      required this.shimmerDuration,
      required this.progressStrokeWidth,
      required this.progressBarRadius});

  factory LoadingStates.light() => const LoadingStates(
      skeletonBase: Color(0xFFE5E7EB),
      skeletonHighlight: Color(0xFFF3F4F6),
      skeletonOpacity: 0.12,
      shimmerDuration: Duration(milliseconds: 1500),
      progressStrokeWidth: 2.0,
      progressBarRadius: 4.0);

  factory LoadingStates.dark() => const LoadingStates(
      skeletonBase: Color(0xFF2D2D2D),
      skeletonHighlight: Color(0xFF3D3D3D),
      skeletonOpacity: 0.08,
      shimmerDuration: Duration(milliseconds: 1500),
      progressStrokeWidth: 2.0,
      progressBarRadius: 4.0);

  static LoadingStates lerp(LoadingStates a, LoadingStates b, double t) {
    return LoadingStates(
        skeletonBase: Color.lerp(a.skeletonBase, b.skeletonBase, t)!,
        skeletonHighlight:
            Color.lerp(a.skeletonHighlight, b.skeletonHighlight, t)!,
        skeletonOpacity: lerpDouble(a.skeletonOpacity, b.skeletonOpacity, t)!,
        shimmerDuration: Duration(
            milliseconds: lerpDouble(a.shimmerDuration.inMilliseconds,
                    b.shimmerDuration.inMilliseconds, t)!
                .round()),
        progressStrokeWidth:
            lerpDouble(a.progressStrokeWidth, b.progressStrokeWidth, t)!,
        progressBarRadius:
            lerpDouble(a.progressBarRadius, b.progressBarRadius, t)!);
  }
}
