import 'dart:ui';
import 'package:flutter/material.dart';

/// 심플 블러 오버레이
///
/// **특징**:
/// - 좌우 대칭 풀 블러 (가운데 기준)
/// - 테두리 없음
/// - 연한 자물쇠 아이콘만 중앙에 표시
///
/// **사용법**:
/// ```dart
/// SimpleBlurOverlay(
///   isBlurred: true,
///   child: MyContent(),
/// )
/// ```
class SimpleBlurOverlay extends StatelessWidget {
  /// 블러 적용 여부
  final bool isBlurred;

  /// 블러 처리할 자식 위젯
  final Widget child;

  /// 블러 강도 (기본값: 4.0 - 더 연한 블러, 뒤가 잘 보임)
  final double blurSigma;

  /// 자물쇠 아이콘 크기 (기본값: 32)
  final double lockIconSize;

  /// 자물쇠 아이콘 투명도 (기본값: 0.3 - 연한 느낌)
  final double lockIconOpacity;

  const SimpleBlurOverlay({
    super.key,
    required this.isBlurred,
    required this.child,
    this.blurSigma = 4.0,
    this.lockIconSize = 32,
    this.lockIconOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    if (!isBlurred) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    return ClipRect(
      child: Stack(
        children: [
          // 블러된 컨텐츠 (좌우 대칭 풀 블러)
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
              tileMode: TileMode.decal,
            ),
            child: child,
          ),

          // 연한 자물쇠 아이콘 (가운데)
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.lock_outline_rounded,
                size: lockIconSize,
                color: iconColor.withValues(alpha: lockIconOpacity),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
