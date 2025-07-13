import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import '../../core/theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    Key? key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
  }) : super(key: key);

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
          const SizedBox(height: 16),
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
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    blur: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoadingIndicator(),
                        if (message != null) ...[
                          const SizedBox(height: 16),
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
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height ?? 20,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
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
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      blur: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 150, height: 20),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 16),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall Score Skeleton
          GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(24),
            blur: 20,
            child: Column(
              children: [
                SkeletonLoader(
                  width: 120,
                  height: 120,
                  borderRadius: BorderRadius.circular(60),
                ),
                const SizedBox(height: 16),
                const SkeletonLoader(width: 200, height: 24),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 150, height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Score Breakdown Skeleton
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            blur: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: 16),
                ...List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const SkeletonLoader(width: 80, height: 16),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: SkeletonLoader(height: 8),
                        ),
                        const SizedBox(width: 12),
                        const SkeletonLoader(width: 40, height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lucky Items Skeleton
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            blur: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: 16),
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
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description Skeleton
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            blur: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: 16),
                ...List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 8),
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
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            height: itemHeight,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            blur: 10,
            child: Row(
              children: [
                const SkeletonLoader(
                  width: 48,
                  height: 48,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SkeletonLoader(width: 150, height: 16),
                      SizedBox(height: 8),
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
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(20),
          blur: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SkeletonLoader(
                width: 60,
                height: 60,
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              SizedBox(height: 12),
              SkeletonLoader(width: 80, height: 16),
            ],
          ),
        );
      },
    );
  }
}