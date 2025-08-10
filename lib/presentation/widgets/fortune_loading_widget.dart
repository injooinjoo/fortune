import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_animations.dart';
import '../../core/components/toss_fortune_loading_screen.dart';

class FortuneLoadingWidget extends StatelessWidget {
  final String? message;
  final String fortuneType;
  
  const FortuneLoadingWidget({
    Key? key,
    this.message,
    this.fortuneType = 'default',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 새로운 토스 스타일 로딩 위젯 사용
    return TossFortuneLoadingWidget(
      message: message ?? '운세를 분석하는 중...',
    );
  }
}

class SimpleLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  
  const SimpleLoadingIndicator({
    Key? key,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary),
      ),
    );
  }
}

class FortuneSkeletonLoader extends StatefulWidget {
  const FortuneSkeletonLoader({Key? key}) : super(key: key);

  @override
  State<FortuneSkeletonLoader> createState() => _FortuneSkeletonLoaderState();
}

class _FortuneSkeletonLoaderState extends State<FortuneSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.durationSkeleton,
      vsync: this)..repeat();
    
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              height: AppSpacing.spacing24 * 2.08,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(_animation.value),
                borderRadius: AppDimensions.borderRadiusMedium,
              ),
            ),
            SizedBox(height: AppSpacing.spacing4),
            Container(
              height: AppSpacing.spacing5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(_animation.value),
                borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall),
              ),
            ),
            SizedBox(height: AppSpacing.spacing2),
            Container(
              height: 20,
              width: AppSpacing.spacing24 * 2.08,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(_animation.value),
                borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall),
              ),
            ),
          ],
        );
      },
    );
  }
}