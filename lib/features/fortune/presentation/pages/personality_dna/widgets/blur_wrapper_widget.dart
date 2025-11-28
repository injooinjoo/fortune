import 'dart:ui';
import 'package:flutter/material.dart';

class BlurWrapperWidget extends StatelessWidget {
  final Widget child;
  final bool isBlurred;

  const BlurWrapperWidget({
    super.key,
    required this.child,
    required this.isBlurred,
  });

  @override
  Widget build(BuildContext context) {
    if (!isBlurred) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. 블러된 child
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: child,
              ),
            ),
            // 2. 어두운 오버레이
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0,
                    child: child,
                  ),
                ),
              ),
            ),
            // 3. 자물쇠 아이콘
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
