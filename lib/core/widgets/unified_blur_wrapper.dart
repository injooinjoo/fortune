import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/fortune_design_system.dart';
import '../services/fortune_haptic_service.dart';
import '../utils/fortune_completion_helper.dart';
import 'unified_button.dart';
import 'unified_button_enums.dart';
import '../../presentation/providers/subscription_provider.dart';

/// 통일된 블러 처리 위젯
///
/// **모든 운세 페이지의 블러 처리는 이 위젯을 사용합니다.**
///
/// **사용법**:
/// ```dart
/// UnifiedBlurWrapper(
///   isBlurred: fortuneResult.isBlurred,
///   blurredSections: fortuneResult.blurredSections,
///   sectionKey: 'advice',
///   fortuneType: 'tarot', // 게이지 증가를 위한 운세 타입
///   child: MyContentWidget(),
/// )
/// ```
///
/// **디자인 표준**:
/// - ImageFilter.blur(sigmaX: 10, sigmaY: 10)
/// - 그라디언트 오버레이 (0.3 → 0.8 alpha)
/// - 중앙 자물쇠 아이콘 + shimmer 애니메이션
///
/// **참고**: [docs/design/BLUR_SYSTEM_GUIDE.md](../../docs/design/BLUR_SYSTEM_GUIDE.md)
///
/// **프리미엄 사용자**: 프리미엄 구독자는 블러 없이 전체 콘텐츠를 볼 수 있습니다.
class UnifiedBlurWrapper extends ConsumerStatefulWidget {
  /// 전체 블러 여부 (FortuneResult.isBlurred)
  final bool isBlurred;

  /// 블러 처리할 섹션 목록 (FortuneResult.blurredSections)
  final List<String> blurredSections;

  /// 현재 섹션 키 (예: 'advice', 'future_outlook')
  final String sectionKey;

  /// 블러 처리할 자식 위젯
  final Widget child;

  /// 운세 타입 (게이지 증가용) - 예: 'tarot', 'mbti', 'saju'
  final String? fortuneType;

  /// 가로 블러 강도 (기본값: 10.0)
  final double sigmaX;

  /// 세로 블러 강도 (기본값: 10.0)
  final double sigmaY;

  const UnifiedBlurWrapper({
    super.key,
    required this.isBlurred,
    required this.blurredSections,
    required this.sectionKey,
    required this.child,
    this.fortuneType,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
  });

  @override
  ConsumerState<UnifiedBlurWrapper> createState() => _UnifiedBlurWrapperState();
}

class _UnifiedBlurWrapperState extends ConsumerState<UnifiedBlurWrapper> {
  bool _wasBlurred = false;

  @override
  void initState() {
    super.initState();
    _wasBlurred = widget.isBlurred && widget.blurredSections.contains(widget.sectionKey);
  }

  @override
  void didUpdateWidget(UnifiedBlurWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newShouldBlur = widget.isBlurred && widget.blurredSections.contains(widget.sectionKey);

    // 블러 상태가 true → false로 전환되면 premiumUnlock 햅틱 트리거 + 게이지 증가
    if (_wasBlurred && !newShouldBlur) {
      ref.read(fortuneHapticServiceProvider).premiumUnlock();

      // 게이지 증가 (fortuneType이 있을 때만)
      if (widget.fortuneType != null) {
        FortuneCompletionHelper.onFortuneViewed(
          context,
          ref,
          widget.fortuneType!,
        );
      }
    }

    _wasBlurred = newShouldBlur;
  }

  @override
  Widget build(BuildContext context) {
    // 프리미엄 사용자는 블러 처리 없이 전체 콘텐츠 표시
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) {
      return widget.child;
    }

    // 블러 적용 여부 판단
    final shouldBlur = widget.isBlurred && widget.blurredSections.contains(widget.sectionKey);

    // 블러 필요 없으면 원본 그대로 반환
    if (!shouldBlur) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // SizedBox로 감싸서 부모 전체 너비를 차지하게 함 → 자물쇠가 항상 중앙에 위치
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // 원본 콘텐츠 (블러 처리)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: widget.sigmaX, sigmaY: widget.sigmaY),
            child: widget.child,
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

        // 중앙 자물쇠 아이콘 (shimmer 애니메이션)
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.lock_outline,
              size: 40,
              color: (isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossDesignSystem.textPrimaryLight)
                  .withValues(alpha: 0.4),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 2000.ms,
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
                ),
          ),
        ),
        ],
      ),
    );
  }
}

/// 통일된 광고 잠금 해제 버튼
///
/// **모든 운세 페이지의 광고 버튼은 이 위젯을 사용합니다.**
///
/// **사용법**:
/// ```dart
/// if (fortuneResult.isBlurred)
///   UnifiedAdUnlockButton(
///     onPressed: _showAdAndUnblur,
///   )
/// ```
///
/// **버튼 텍스트 커스터마이징**:
/// ```dart
/// UnifiedAdUnlockButton(
///   onPressed: _showAdAndUnblur,
///   customText: '특별한 광고 버튼 텍스트',
/// )
/// ```
///
/// **프리미엄 사용자**: 프리미엄 구독자에게는 버튼이 표시되지 않습니다.
class UnifiedAdUnlockButton extends ConsumerWidget {
  /// 광고 보기 콜백
  final VoidCallback onPressed;

  /// 커스텀 버튼 텍스트 (기본값: "🎁 광고 보고 전체 내용 보기")
  final String? customText;

  const UnifiedAdUnlockButton({
    super.key,
    required this.onPressed,
    this.customText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 프리미엄 사용자는 광고 버튼 숨김
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) {
      return const SizedBox.shrink();
    }

    return UnifiedButton.floating(
      text: customText ?? '🎁 광고 보고 전체 내용 보기',
      onPressed: onPressed,
      isEnabled: true,
      isLoading: false,
      style: UnifiedButtonStyle.primary,
      size: UnifiedButtonSize.large,
    );
  }
}
