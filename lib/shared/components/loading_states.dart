import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fortune/core/theme/toss_design_system.dart';

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

class TossLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const TossLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Prevent taps from passing through
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(TossDesignSystem.spacingL),
                    decoration: BoxDecoration(
                      color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
                      boxShadow: TossDesignSystem.shadowL,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoadingIndicator(),
                        if (message != null) ...[
                          const SizedBox(height: TossDesignSystem.spacingM),
                          Text(
                            message!,
                            style: TossDesignSystem.body2.copyWith(
                              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                            ),
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
        ? TossDesignSystem.grayDark300
        : TossDesignSystem.gray200,
      highlightColor: isDark 
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray100,
      child: Container(
        width: width,
        height: height ?? 20,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: height ?? 120,
      margin: margin,
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
        boxShadow: isDark ? null : TossDesignSystem.shadowXS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 150, height: 20),
          const SizedBox(height: TossDesignSystem.spacingS),
          const SkeletonLoader(height: 16),
          const SizedBox(height: TossDesignSystem.spacingXS),
          const SkeletonLoader(height: 16),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacingL),
      child: Column(
        children: [
          // Overall Score Skeleton
          Container(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
              boxShadow: isDark ? null : TossDesignSystem.shadowXS,
            ),
            child: Column(
              children: [
                SkeletonLoader(
                  width: 120,
                  height: 120,
                  borderRadius: BorderRadius.circular(60)),
                const SizedBox(height: TossDesignSystem.spacingM),
                const SkeletonLoader(width: 200, height: 24),
                const SizedBox(height: TossDesignSystem.spacingXS),
                const SkeletonLoader(width: 150, height: 16),
              ],
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacingM),

          // Score Breakdown Skeleton
          Container(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
              boxShadow: isDark ? null : TossDesignSystem.shadowXS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: TossDesignSystem.spacingM),
                ...List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingS),
                    child: Row(
                      children: const [
                        SkeletonLoader(width: 80, height: 16),
                        SizedBox(width: TossDesignSystem.spacingS),
                        Expanded(
                          child: SkeletonLoader(height: 8),
                        ),
                        SizedBox(width: TossDesignSystem.spacingS),
                        SkeletonLoader(width: 40, height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacingM),

          // Lucky Items Skeleton
          Container(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
              boxShadow: isDark ? null : TossDesignSystem.shadowXS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: TossDesignSystem.spacingM),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: List.generate(
                    6,
                    (index) => SkeletonLoader(
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacingM),

          // Description Skeleton
          Container(
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
              boxShadow: isDark ? null : TossDesignSystem.shadowXS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: TossDesignSystem.spacingM),
                ...List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingXS),
                    child: const SkeletonLoader(height: 16),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(TossDesignSystem.spacingL),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: TossDesignSystem.spacingM),
          child: Container(
            height: itemHeight,
            padding: const EdgeInsets.all(TossDesignSystem.spacingL),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
              boxShadow: isDark ? null : TossDesignSystem.shadowXS,
            ),
            child: Row(
              children: [
                SkeletonLoader(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(width: TossDesignSystem.spacingM),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(TossDesignSystem.spacingL),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: TossDesignSystem.spacingM,
        crossAxisSpacing: TossDesignSystem.spacingM),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(TossDesignSystem.spacingL),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusXL),
            boxShadow: isDark ? null : TossDesignSystem.shadowXS,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonLoader(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(30),
              ),
              const SizedBox(height: TossDesignSystem.spacingS),
              const SkeletonLoader(width: 80, height: 16),
            ],
          ),
        );
      },
    );
  }
}