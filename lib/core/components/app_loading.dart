import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// TOSS 스타일 스켈레톤 로딩
class TossSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets? margin;
  final bool animate;

  const TossSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 4,
    this.margin,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget skeleton = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (animate) {
      return skeleton
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .shimmer(
            duration: const Duration(milliseconds: 1500),
            color: context.colors.border.withValues(alpha: 0.6),
          );
    }

    return skeleton;
  }

  /// 텍스트 스켈레톤
  factory TossSkeleton.text({
    double width = 100,
    double height = 16,
    EdgeInsets? margin,
  }) {
    return TossSkeleton(
      width: width,
      height: height,
      borderRadius: DSRadius.xs,
      margin: margin,
    );
  }

  /// 원형 스켈레톤 (아바타 등)
  factory TossSkeleton.circle({
    double size = 40,
    EdgeInsets? margin,
  }) {
    return TossSkeleton(
      width: size,
      height: size,
      borderRadius: size / 2,
      margin: margin,
    );
  }

  /// 사각형 스켈레톤 (이미지 등)
  factory TossSkeleton.rectangle({
    double? width,
    double? height,
    double borderRadius = 8,
    EdgeInsets? margin,
  }) {
    return TossSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
    );
  }
}

/// 카드 스켈레톤
class AppCardSkeleton extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;

  const AppCardSkeleton({
    super.key,
    this.height = 120,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: context.colors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TossSkeleton.text(width: 120),
          const SizedBox(height: DSSpacing.sm),
          TossSkeleton.text(width: double.infinity, height: 14),
          const SizedBox(height: DSSpacing.xs),
          TossSkeleton.text(width: double.infinity, height: 14),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TossSkeleton.text(width: 80, height: 12),
              TossSkeleton.text(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

/// 리스트 아이템 스켈레톤
class TossListItemSkeleton extends StatelessWidget {
  final bool showAvatar;
  final EdgeInsets? margin;

  const TossListItemSkeleton({
    super.key,
    this.showAvatar = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        children: [
          if (showAvatar) ...[
            TossSkeleton.circle(size: 48),
            const SizedBox(width: DSSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TossSkeleton.text(width: 120, height: 16),
                const SizedBox(height: DSSpacing.sm),
                TossSkeleton.text(width: double.infinity, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// TOSS 스타일 로딩 인디케이터
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? context.colors.accent,
        ),
      ),
    );
  }
}

/// 전체 화면 로딩
class TossFullScreenLoading extends StatelessWidget {
  final String? message;

  const TossFullScreenLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoadingIndicator(size: 48),
            if (message != null) ...[
              const SizedBox(height: DSSpacing.md),
              Text(
                message!,
                style: context.bodyMedium.copyWith(
                  color: context.colors.textDisabled,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
