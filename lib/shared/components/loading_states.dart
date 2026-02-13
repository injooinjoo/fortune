import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/design_system/design_system.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator(
      {super.key, this.size = 40, this.color, this.strokeWidth = 3});

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
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingIndicator(size: size, color: colors.accentSecondary),
        if (message != null) ...[
          const SizedBox(height: DSSpacing.md),
          Text(
            message!,
            style: typography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Prevent taps from passing through
              child: Container(
                color: colors.textPrimary.withValues(alpha: 0.5),
                child: Center(
                  child: DSCard.flat(
                    padding: const EdgeInsets.all(DSSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LoadingIndicator(color: colors.accentSecondary),
                        if (message != null) ...[
                          const SizedBox(height: DSSpacing.md),
                          Text(
                            message!,
                            style: typography.bodyMedium.copyWith(
                              color: colors.textSecondary,
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
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Shimmer.fromColors(
      baseColor: colors.surfaceSecondary,
      highlightColor: colors.surface,
      child: Container(
        width: width,
        height: height ?? 20,
        margin: margin,
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: borderRadius ?? BorderRadius.circular(DSRadius.sm),
        ),
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;

  const CardSkeleton({
    super.key,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 120,
      margin: margin,
      child: DSCard.flat(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(width: 150, height: 20),
            SizedBox(height: DSSpacing.sm),
            SkeletonLoader(height: 16),
            SizedBox(height: DSSpacing.xs),
            SkeletonLoader(height: 16),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(width: 80, height: 16),
                SkeletonLoader(width: 60, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FortuneResultSkeleton extends StatelessWidget {
  const FortuneResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        children: [
          // Overall Score Skeleton
          DSCard.flat(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              children: [
                SkeletonLoader(
                    width: 120,
                    height: 120,
                    borderRadius: BorderRadius.circular(60)),
                const SizedBox(height: DSSpacing.md),
                const SkeletonLoader(width: 200, height: 24),
                const SizedBox(height: DSSpacing.xs),
                const SkeletonLoader(width: 150, height: 16),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),

          // Score Breakdown Skeleton
          DSCard.flat(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: DSSpacing.md),
                ...List.generate(
                  4,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: DSSpacing.sm),
                    child: Row(
                      children: [
                        SkeletonLoader(width: 80, height: 16),
                        SizedBox(width: DSSpacing.sm),
                        Expanded(
                          child: SkeletonLoader(height: 8),
                        ),
                        SizedBox(width: DSSpacing.sm),
                        SkeletonLoader(width: 40, height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),

          // Lucky Items Skeleton
          DSCard.flat(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: DSSpacing.md),
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
                      borderRadius: BorderRadius.circular(DSRadius.md),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),

          // Description Skeleton
          DSCard.flat(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 100, height: 20),
                const SizedBox(height: DSSpacing.md),
                ...List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: DSSpacing.xs),
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
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(DSSpacing.lg),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.md),
          child: SizedBox(
            height: itemHeight,
            child: DSCard.flat(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Row(
                children: [
                  SkeletonLoader(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonLoader(width: 150, height: 16),
                        SizedBox(height: DSSpacing.xs),
                        SkeletonLoader(height: 14),
                      ],
                    ),
                  ),
                  const SkeletonLoader(width: 60, height: 30),
                ],
              ),
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
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(DSSpacing.lg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: DSSpacing.md,
          crossAxisSpacing: DSSpacing.md),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return DSCard.flat(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonLoader(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(30),
              ),
              const SizedBox(height: DSSpacing.sm),
              const SkeletonLoader(width: 80, height: 16),
            ],
          ),
        );
      },
    );
  }
}
