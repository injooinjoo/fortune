import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/fortune_design_system.dart';

/// 채팅용 심플 블러 오버레이
///
/// **목적**: 채팅 박스에 깔끔하게 블러만 적용하는 재사용 가능한 컴포넌트
///
/// **사용법**:
/// ```dart
/// ChatBlurOverlay(
///   isBlurred: true,
///   child: MyChatContent(),
/// )
/// ```
///
/// **특징**:
/// - UnifiedBlurWrapper보다 단순: 섹션키, 운세타입 등 불필요
/// - 자물쇠 아이콘 + shimmer 애니메이션 포함
/// - 다크모드 자동 대응
/// - 블러 강도 커스터마이징 가능
class ChatBlurOverlay extends StatelessWidget {
  /// 블러 적용 여부
  final bool isBlurred;

  /// 블러 처리할 자식 위젯
  final Widget child;

  /// 블러 강도 (기본값: 8.0)
  final double blurSigma;

  /// 자물쇠 아이콘 표시 여부 (기본값: true)
  final bool showLockIcon;

  /// 자물쇠 아이콘 크기 (기본값: 28)
  final double lockIconSize;

  /// 오버레이 투명도 (기본값: 0.3 ~ 0.7)
  final double overlayOpacityStart;
  final double overlayOpacityEnd;

  /// 테두리 radius (컨테이너에 적용된 radius와 맞출 때 사용)
  final BorderRadius? borderRadius;

  const ChatBlurOverlay({
    super.key,
    required this.isBlurred,
    required this.child,
    this.blurSigma = 8.0,
    this.showLockIcon = true,
    this.lockIconSize = 28,
    this.overlayOpacityStart = 0.3,
    this.overlayOpacityEnd = 0.7,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // 블러 필요 없으면 원본 그대로
    if (!isBlurred) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? TossDesignSystem.backgroundDark
        : TossDesignSystem.backgroundLight;
    final iconColor = isDark
        ? TossDesignSystem.textSecondaryDark
        : TossDesignSystem.textSecondaryLight;

    return Stack(
      children: [
        // 블러된 컨텐츠
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: child,
        ),

        // 반투명 그라데이션 오버레이
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor.withValues(alpha: overlayOpacityStart),
                  backgroundColor.withValues(alpha: overlayOpacityEnd),
                ],
              ),
            ),
          ),
        ),

        // 자물쇠 아이콘 (선택적)
        if (showLockIcon)
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.lock_outline,
                size: lockIconSize,
                color: iconColor.withValues(alpha: 0.5),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 2000.ms,
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
                  ),
            ),
          ),
      ],
    );
  }
}

/// 채팅 메시지 전용 블러 (더 간단한 버전)
///
/// **사용법**:
/// ```dart
/// ChatMessageBlur(
///   isBlurred: message.isBlurred,
///   child: MessageContent(),
/// )
/// ```
class ChatMessageBlur extends StatelessWidget {
  final bool isBlurred;
  final Widget child;

  const ChatMessageBlur({
    super.key,
    required this.isBlurred,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChatBlurOverlay(
      isBlurred: isBlurred,
      blurSigma: 6.0,
      lockIconSize: 20,
      overlayOpacityStart: 0.2,
      overlayOpacityEnd: 0.6,
      child: child,
    );
  }
}

/// 채팅 카드 전용 블러 (카드 스타일)
///
/// **사용법**:
/// ```dart
/// ChatCardBlur(
///   isBlurred: result.isBlurred,
///   borderRadius: BorderRadius.circular(12),
///   child: FortuneResultCard(),
/// )
/// ```
class ChatCardBlur extends StatelessWidget {
  final bool isBlurred;
  final Widget child;
  final BorderRadius? borderRadius;

  const ChatCardBlur({
    super.key,
    required this.isBlurred,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ChatBlurOverlay(
      isBlurred: isBlurred,
      blurSigma: 8.0,
      lockIconSize: 28,
      overlayOpacityStart: 0.3,
      overlayOpacityEnd: 0.7,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
