import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/toss_design_system.dart';
import '../models/fortune_result.dart';
import '../../presentation/providers/subscription_provider.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ 프리미엄 사용자는 블러 처리 없이 전체 콘텐츠 표시
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) {
      return child;
    }

    // 블러 상태가 아니면 그냥 child 반환
    if (!fortuneResult.isBlurred) {
      return child;
    }

    // 블러 처리된 콘텐츠 (버튼 없음)
    // SizedBox로 감싸서 부모 전체 너비를 차지하게 함 → 자물쇠가 항상 중앙에 위치
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // 원본 콘텐츠 (블러 처리)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: child,
          ),

        // 반투명 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.3),
                  (isDark
                      ? TossDesignSystem.backgroundDark
                      : TossDesignSystem.backgroundLight)
                      .withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),

        // 중앙 잠금 아이콘만 표시
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 40,
              color: (isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight)
                  .withValues(alpha: 0.4),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: TossDesignSystem.tossBlue.withValues(alpha: 0.2)),
          ),
        ),
        ],
      ),
    );
  }
}
