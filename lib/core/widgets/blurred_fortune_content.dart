import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune_result.dart';
import 'simple_blur_overlay.dart';

/// 블러 처리된 운세 콘텐츠 위젯 (단순 블러만 적용)
///
/// FortuneResult.isBlurred가 true일 때만 블러 처리
/// 버튼은 제거하고 Floating Button으로 통합
///
/// **프리미엄 사용자**: 프리미엄 구독자는 블러 없이 전체 콘텐츠를 볼 수 있습니다.
class BlurredFortuneContent extends ConsumerWidget {
  final FortuneResult fortuneResult;
  final Widget child;

  const BlurredFortuneContent({
    super.key,
    required this.fortuneResult,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimpleBlurOverlay(
      isBlurred: fortuneResult.isBlurred,
      child: child,
    );
  }
}
