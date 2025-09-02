import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../glassmorphism/glass_container.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    Key? key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? theme.primaryColor,
          ),
        ),
      ),
    );
  }
}

// Alias for LoadingStateWidget for backward compatibility
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double size;
  
  const LoadingStateWidget({
    super.key,
    this.message,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingIndicator(size: size),
        if (message != null) ...[
          SizedBox(height: TossDesignSystem.spacingM),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class GlassLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const GlassLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Prevent taps from passing through
              child: Container(
                color: TossDesignSystem.gray900.withOpacity(0.3),
                child: Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(TossDesignSystem.spacingL),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    blur: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoadingIndicator(),
                        if (message != null) ...[
                          SizedBox(height: TossDesignSystem.spacingM),
                          Text(
                            message!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark 
        ? TossDesignSystem.gray400.withOpacity(0.8) 
        : TossDesignSystem.gray400.withOpacity(0.3),
      highlightColor: isDark 
        ? TossDesignSystem.gray400.withOpacity(0.7) 
        : TossDesignSystem.gray400.withOpacity(0.1),
      child: Container(
        width: width,
        height: height ?? 20,
        margin: margin,
        decoration: BoxDecoration(
          color: TossDesignSystem.grayDark900,
          borderRadius: borderRadius ?? BorderRadius.circular(TossDesignSystem.radiusS),
        ),
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;

  const CardSkeleton({
    Key? key,
    this.height,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: height ?? 120,
      margin: margin,
      padding: const EdgeInsets.all(TossDesignSystem.spacingM),
      borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
      blur: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 150, height: 20),
          SizedBox(height: TossDesignSystem.spacingS),
          const SkeletonLoader(height: 16),
          SizedBox(height: TossDesignSystem.spacingXS),
          const SkeletonLoader(height: 16),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(width: 80, height: 16),
              SkeletonLoader(width: 60, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class FortuneResultSkeleton extends StatelessWidget {
  const FortuneResultSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingM),
      child: Column(
        children: [
          // Overall Score Skeleton
          GlassContainer(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
            blur: 20,
            child: Column(
              children: [
                SkeletonLoader(
                  width: 120,
                  height: 120,
                  borderRadius: BorderRadius.circular(TossDesignSystem.spacingM)),
                SizedBox(height: TossDesignSystem.spacingM),
                const SkeletonLoader(width: 200, height: 24),
                SizedBox(height: TossDesignSystem.spacingXS),
                const SkeletonLoader(width: 150, height: 16),
              ],
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingM),

          // Score Breakdown Skeleton
          GlassContainer(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
            blur: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                SizedBox(height: TossDesignSystem.spacingM),
                ...List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
                    child: Row(
                      children: [
                        const SkeletonLoader(width: 80, height: 16),
                        SizedBox(width: TossDesignSystem.spacingS),
                        const Expanded(
                          child: SkeletonLoader(height: 8),
                        ),
                        SizedBox(width: TossDesignSystem.spacingS),
                        const SkeletonLoader(width: 40, height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingM),

          // Lucky Items Skeleton
          GlassContainer(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
            blur: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                SizedBox(height: TossDesignSystem.spacingM),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: List.generate(
                    6,
                    (index) => const SkeletonLoader(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: TossDesignSystem.spacingM),

          // Description Skeleton
          GlassContainer(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
            blur: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                SizedBox(height: TossDesignSystem.spacingM),
                ...List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
                    child: SkeletonLoader(height: 16),
                  ),
                ),
                const SkeletonLoader(width: 200, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ListItemSkeleton({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(TossDesignSystem.spacingM),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
          child: GlassContainer(
            height: itemHeight,
            padding: const EdgeInsets.all(TossDesignSystem.spacingM),
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
            blur: 10,
            child: Row(
              children: [
                const SkeletonLoader(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                SizedBox(width: TossDesignSystem.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SkeletonLoader(width: 150, height: 16),
                      SizedBox(height: TossDesignSystem.spacingXS),
                      SkeletonLoader(height: 14),
                    ],
                  ),
                ),
                const SkeletonLoader(width: 60, height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const GridSkeleton({
    Key? key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(TossDesignSystem.spacingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return GlassContainer(
          padding: const EdgeInsets.all(TossDesignSystem.spacingM),
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
          blur: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SkeletonLoader(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              SizedBox(height: TossDesignSystem.spacingS),
              SkeletonLoader(width: 80, height: 16),
            ],
          ),
        );
      },
    );
  }
}