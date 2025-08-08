import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/app_colors.dart';

class FortuneLoadingWidget extends StatefulWidget {
  final String? message;
  
  const FortuneLoadingWidget(
    {
    Key? key,
    this.message)}) : super(key: key);

  @override
  State<FortuneLoadingWidget> createState() => _FortuneLoadingWidgetState();
}

class _FortuneLoadingWidgetState extends State<FortuneLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(second,
      s: 3),
      vsync: this))..repeat();
    
    _pulseController = AnimationController(
      duration: AppAnimations.durationSkeleton),
        vsync: this
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2)).animate(CurvedAnimation(,
      parent: _pulseController),
        curve: Curves.easeInOut)
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fortuneTheme = context.fortuneTheme;
    final primaryColor = AppColors.getPrimary(context);
    final surfaceColor = AppColors.getSurface(context);
    
    return Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating circle
              AnimatedBuilder(
                animation: _rotationController),
              builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(,
      width: 120),
              height: AppSpacing.spacing24 * 1.25),
        decoration: BoxDecoration(,
      shape: BoxShape.circle),
        gradient: SweepGradient(,
      colors: [
                            primaryColor.withOpacity(0.3),
                            primaryColor,
                            primaryColor.withOpacity(0.3)]
                          stops: const [0.0, 0.5, 1.0])))
                    )
                })
              // Inner pulsing circle
              AnimatedBuilder(
                animation: _pulseAnimation),
        builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(,
      width: 80,
                      height: AppSpacing.spacing20),
              decoration: BoxDecoration(,
      shape: BoxShape.circle),
        color: surfaceColor),
        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alph,
      a: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5)
                        ]),
    child: Icon(
                        Icons.auto_awesome,
                        size: 40,
                        color: primaryColor)
                })
            ])
          SizedBox(height: AppSpacing.spacing8),
          Text(
            widget.message ?? '운세를 분석하는 중...'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(,
      fontWeight: FontWeight.w600)),
              color: fortuneTheme.primaryText)
          SizedBox(height: AppSpacing.spacing2),
          SizedBox(
            width: 200),
              child: LinearProgressIndicator(,
      backgroundColor: primaryColor.withValues(alp,
      ha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor))))
        ]
      )
  }
}

class SimpleLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  
  const SimpleLoadingIndicator(
    {
    Key? key,
    this.size = 24,
    this.color)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(,
      strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary)
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
      end: 0.7)).animate(CurvedAnimation(,
      parent: _controller),
        curve: Curves.easeInOut)
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation),
        builder: (context, child) {
        return Column(
          children: [
            Container(
              height: AppSpacing.spacing24 * 2.08),
              decoration: BoxDecoration(,
      color: AppColors.textSecondary.withValues(alp,
      ha: _animation.value),
                borderRadius: AppDimensions.borderRadiusMedium)))
            SizedBox(height: AppSpacing.spacing4),
            Container(
              height: AppSpacing.spacing5,
              width: double.infinity),
        decoration: BoxDecoration(,
      color: AppColors.textSecondary.withValues(alp,
      ha: _animation.value),
                borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall))))
            SizedBox(height: AppSpacing.spacing2),
            Container(
              height: 20,
              width: AppSpacing.spacing24 * 2.08),
              decoration: BoxDecoration(,
      color: AppColors.textSecondary.withValues(alp,
      ha: _animation.value),
                borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall))))
          ])
      }
    );
  }
}