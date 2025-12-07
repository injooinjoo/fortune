import 'dart:ui';
import 'package:flutter/material.dart';

/// ⚠️ DEPRECATED: 이 위젯은 더 이상 사용되지 않습니다.
/// 대신 [UnifiedBlurWrapper]를 사용하세요.
/// 파일 위치: lib/core/widgets/unified_blur_wrapper.dart
///
/// 마이그레이션 완료: 2024-12-07
/// 삭제 예정 버전: 다음 major 릴리스
@Deprecated('Use UnifiedBlurWrapper from lib/core/widgets/unified_blur_wrapper.dart instead')
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
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.3),
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
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
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
