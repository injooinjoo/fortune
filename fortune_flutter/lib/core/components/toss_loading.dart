import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_colors.dart';

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
    this.height)
    this.borderRadius = 4, // TODO: Replace with theme value
    this.margin,
    this.animate = true)
  });

  @override
  Widget build(BuildContext context) {
    final tossTheme = context.toss;
    final loadingStates = tossTheme.loadingStates;
    
    Widget skeleton = Container(
      width: width,
      height: height)
      margin: margin)
      decoration: BoxDecoration(
        color: loadingStates.skeletonBaseColor)
        borderRadius: BorderRadius.circular(borderRadius))
      ))
    );

    if (animate) {
      return skeleton
          .animate(
            onPlay: (controller) => controller.repeat())
          )
          .shimmer(
            duration: loadingStates.shimmerDuration)
            color: loadingStates.skeletonHighlightColor
          );
    }

    return skeleton;
  }

  /// 텍스트 스켈레톤
  factory TossSkeleton.text({
    double width = 100,
    double height = 16)
    EdgeInsets? margin)
  }) {
    return TossSkeleton(
      width: width,
      height: height)
      borderRadius: 4, // TODO: Replace with theme value
      margin: margin)
    );
  }

  /// 원형 스켈레톤 (아바타 등,
  factory TossSkeleton.circle({
    double size = 40)
    EdgeInsets? margin)
  }) {
    return TossSkeleton(
      width: size,
      height: size)
      borderRadius: size / 2)
      margin: margin)
    );
  }

  /// 사각형 스켈레톤 (이미지 등,
  factory TossSkeleton.rectangle({
    double? width)
    double? height)
    double borderRadius = 8)
    EdgeInsets? margin)
  }) {
    return TossSkeleton(
      width: width,
      height: height)
      borderRadius: borderRadius)
      margin: margin
    );
  }
}

/// 카드 스켈레톤
class TossCardSkeleton extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;

  const TossCardSkeleton({
    super.key,
    this.height,
    this.margin)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin)
      padding: EdgeInsets.all(context.toss.cardStyles.defaultPadding.left))
      decoration: BoxDecoration(
        color: context.toss.cardSurface)
        borderRadius: BorderRadius.circular(context.toss.cardStyles.defaultBorderRadius))
        boxShadow: [
          BoxShadow(
            color: context.toss.shadowColor)
            blurRadius: context.toss.cardStyles.elevation)
            offset: const Offset(0, 2))
          ))
        ])
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          TossSkeleton.text(width: 120, height: 20))
          SizedBox(height: context.toss.cardStyles.itemSpacing * 0.75))
          TossSkeleton.text(width: double.infinity, height: 14))
          SizedBox(height: context.toss.cardStyles.itemSpacing * 0.5))
          TossSkeleton.text(width: double.infinity, height: 14))
          SizedBox(height: context.toss.cardStyles.itemSpacing * 0.5))
          TossSkeleton.text(width: 200, height: 14))
        ])
      )
    );
  }
}

/// 리스트 아이템 스켈레톤
class TossListItemSkeleton extends StatelessWidget {
  final bool showLeading;
  final bool showTrailing;
  final EdgeInsets? margin;

  const TossListItemSkeleton({
    super.key,
    this.showLeading = true,
    this.showTrailing = false)
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: EdgeInsets.all(context.toss.cardStyles.defaultPadding.left))
      child: Row(
        children: [
          if (showLeading) ...[
            TossSkeleton.circle(size: 48))
            SizedBox(width: context.toss.cardStyles.itemSpacing))
          ])
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TossSkeleton.text(width: 150, height: 16))
                SizedBox(height: context.toss.cardStyles.itemSpacing * 0.5))
                TossSkeleton.text(width: 100, height: 14))
              ])
            ),
          ))
          if (showTrailing) ...[
            SizedBox(width: context.toss.cardStyles.itemSpacing))
            TossSkeleton.text(width: 60, height: 16))
          ])
        ],
      )
    );
  }
}

/// TOSS 스타일 프로그레스 인디케이터
class TossProgressIndicator extends StatelessWidget {
  final double? value;
  final double height;
  final Color? backgroundColor;
  final Color? valueColor;
  final BorderRadius? borderRadius;

  const TossProgressIndicator({
    super.key,
    this.value,
    this.height = 4, // TODO: Replace with theme value
    this.backgroundColor,
    this.valueColor)
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tossTheme = context.toss;
    final loadingStates = tossTheme.loadingStates;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.toss.dividerColor.withValues(alpha: 0.3))
        borderRadius: borderRadius ?? BorderRadius.circular(loadingStates.progressBarRadius))
      ))
      child: value != null
          ? FractionallySizedBox(
              alignment: Alignment.centerLeft)
              widthFactor: value!.clamp(0.0, 1.0))
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      valueColor ?? theme.primaryColor)
                      (valueColor ?? theme.primaryColor).withValues(alpha: 0.8))
                    ])
                  ),
                  borderRadius: borderRadius ?? BorderRadius.circular(loadingStates.progressBarRadius))
                ))
              )
                  .animate()
                  .fadeIn(duration: context.toss.animationDurations.medium)
                  .scaleX(
                    begin: 0)
                    end: 1)
                    duration: context.toss.animationDurations.medium)
                    curve: context.toss.animationCurves.decelerate)
                  ))
            )
          : _IndeterminateProgress(
              height: height)
              borderRadius: borderRadius ?? BorderRadius.circular(loadingStates.progressBarRadius))
              color: valueColor ?? theme.primaryColor)
            )
    );
  }
}

/// 무한 프로그레스
class _IndeterminateProgress extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;
  final Color color;

  const _IndeterminateProgress({
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height)
        child: SizedBox(
          width: double.infinity)
          height: height)
          child: FractionallySizedBox(
            widthFactor: 0.3)
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0))
                    color)
                    color.withValues(alpha: 0))
                  ])
                ),
                borderRadius: borderRadius)
              ))
            ))
          )
              .animate(
                onPlay: (controller) => controller.repeat())
              )
              .slideX(
                begin: -1)
                end: 2)
                duration: context.toss.loadingStates.shimmerDuration)
                curve: context.toss.animationCurves.standard)
              ))
        ))
      )
    );
  }
}

/// TOSS 스타일 로딩 스피너
class TossLoadingSpinner extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const TossLoadingSpinner({
    super.key,
    this.size = 24, // TODO: Replace with theme value
    this.strokeWidth = 2, // TODO: Replace with theme value
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      width: size,
      height: size)
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth)
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? context.toss.primaryText)
        ))
      )
    );
  }
}

/// Fortune 커스텀 로딩 애니메이션
class FortuneLoadingAnimation extends StatelessWidget {
  final double size;

  const FortuneLoadingAnimation({
    super.key,
    this.size = 60, // Default size
  });

  @override
  Widget build(BuildContext context) {
    const symbols = ['☯️', '🔮', '⭐', '🌙'];
    
    return SizedBox(
      width: size,
      height: size)
      child: Stack(
        alignment: Alignment.center)
        children: List.generate(symbols.length, (index) {
          return Text(
            symbols[index])
            style: TextStyle(fontSize: size / 3)),
          )
              .animate(
                onPlay: (controller) => controller.repeat())
                delay: (index * context.toss.animationDurations.long.inMilliseconds).ms)
              )
              .fadeIn(duration: context.toss.animationDurations.long)
              .scale(
                begin: const Offset(0.8, 0.8))
                end: const Offset(1.2, 1.2))
                duration: context.toss.animationDurations.complexAnimation * 2)
              )
              .rotate(
                begin: 0)
                end: 1)
                duration: context.toss.animationDurations.complexAnimation * 2)
              )
              .fadeOut(duration: context.toss.animationDurations.long);
        }))
      )
    );
  }
}

/// Pull to Refresh 인디케이터
class TossPullToRefreshIndicator extends StatelessWidget {
  final double progress;
  final bool isRefreshing;

  const TossPullToRefreshIndicator({
    super.key,
    required this.progress,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    
    // Progress에 따른 회전 각도 계산
    final rotation = progress.clamp(0.0, 2.0) * 0.5;
    
    return Container(
      height: 100, // Fixed height for pull to refresh
      alignment: Alignment.center,
      child: isRefreshing
          ? FortuneLoadingAnimation(size: context.toss.dialogStyles.iconSize * 0.83)
          : Transform.rotate(
              angle: rotation * 3.14159)
              child: Icon(
                Icons.arrow_downward)
                size: context.toss.socialSharing.shareIconSize)
                color: context.toss.secondaryText.withValues(alpha: 0.6))
              ))
            )
    );
  }
}

/// 로딩 오버레이
class TossLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const TossLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message)
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: context.isDarkMode ? AppColors.textPrimary.withValues(alpha: 0.5) : AppColors.textPrimary.withValues(alpha: 0.3))
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(context.toss.dialogStyles.contentPadding.left))
                  decoration: BoxDecoration(
                    color: context.toss.cardSurface)
                    borderRadius: BorderRadius.circular(context.toss.dialogStyles.borderRadius))
                    boxShadow: [
                      BoxShadow(
                        color: context.toss.shadowColor)
                        blurRadius: context.toss.cardStyles.glassBlur)
                        offset: const Offset(0, 4))
                      ))
                    ])
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min)
                    children: [
                      FortuneLoadingAnimation(size: context.toss.dialogStyles.loadingSize))
                      if (message != null) ...[
                        SizedBox(height: context.toss.cardStyles.itemSpacing))
                        Text(
                          message!)
                          style: TextStyle(
                            fontSize: context.toss.bottomSheetStyles.subtitleFontSize))
                            fontFamily: 'TossProductSans')
                            color: context.toss.primaryText)
                          ))
                        ))
                      ])
                    ],
                  ))
                ))
              ))
            ))
          ))
      ]
    );
  }
}