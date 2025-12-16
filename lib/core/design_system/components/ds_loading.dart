import 'package:flutter/material.dart';
import '../tokens/ds_spacing.dart';
import '../theme/ds_extensions.dart';

/// Loading indicator size
enum DSLoadingSize {
  /// 16px
  small,

  /// 24px
  medium,

  /// 32px
  large,
}

/// ChatGPT-inspired loading indicator
///
/// Usage:
/// ```dart
/// DSLoading()  // Default medium size
/// DSLoading(size: DSLoadingSize.small)
/// DSLoading.overlay()  // Full screen overlay
/// ```
class DSLoading extends StatelessWidget {
  /// Loading indicator size
  final DSLoadingSize size;

  /// Custom color
  final Color? color;

  /// Stroke width
  final double? strokeWidth;

  const DSLoading({
    super.key,
    this.size = DSLoadingSize.medium,
    this.color,
    this.strokeWidth,
  });

  double get _dimension {
    switch (size) {
      case DSLoadingSize.small:
        return 16;
      case DSLoadingSize.medium:
        return 24;
      case DSLoadingSize.large:
        return 32;
    }
  }

  double get _strokeWidth {
    if (strokeWidth != null) return strokeWidth!;
    switch (size) {
      case DSLoadingSize.small:
        return 2;
      case DSLoadingSize.medium:
        return 2.5;
      case DSLoadingSize.large:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.accent;

    return SizedBox(
      width: _dimension,
      height: _dimension,
      child: CircularProgressIndicator(
        strokeWidth: _strokeWidth,
        valueColor: AlwaysStoppedAnimation(effectiveColor),
      ),
    );
  }
}

/// Full screen loading overlay
///
/// Usage:
/// ```dart
/// DSLoadingOverlay(
///   isLoading: _isLoading,
///   child: YourContent(),
/// )
/// ```
class DSLoadingOverlay extends StatelessWidget {
  /// Whether to show the loading overlay
  final bool isLoading;

  /// Child widget
  final Widget child;

  /// Loading message
  final String? message;

  /// Overlay color
  final Color? overlayColor;

  /// Block interactions when loading
  final bool blockInteraction;

  const DSLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
    this.blockInteraction = true,
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
            child: IgnorePointer(
              ignoring: !blockInteraction,
              child: Container(
                color: overlayColor ?? colors.overlay,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(DSSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [context.shadows.modal],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const DSLoading(size: DSLoadingSize.large),
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

/// Inline loading indicator with text
///
/// Usage:
/// ```dart
/// DSInlineLoading(text: '로딩 중...')
/// ```
class DSInlineLoading extends StatelessWidget {
  /// Loading text
  final String? text;

  /// Size
  final DSLoadingSize size;

  const DSInlineLoading({
    super.key,
    this.text,
    this.size = DSLoadingSize.small,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DSLoading(size: size),
        if (text != null) ...[
          const SizedBox(width: DSSpacing.sm),
          Text(
            text!,
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Skeleton loading placeholder
///
/// Usage:
/// ```dart
/// DSSkeleton(width: 100, height: 20)
/// DSSkeleton.circle(size: 48)  // Avatar placeholder
/// ```
class DSSkeleton extends StatefulWidget {
  /// Skeleton width
  final double? width;

  /// Skeleton height
  final double height;

  /// Border radius
  final double? borderRadius;

  /// Is circle
  final bool isCircle;

  const DSSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  /// Circle skeleton
  factory DSSkeleton.circle({
    Key? key,
    required double size,
  }) {
    return DSSkeleton(
      key: key,
      width: size,
      height: size,
      isCircle: true,
    );
  }

  /// Text line skeleton
  factory DSSkeleton.text({
    Key? key,
    double? width,
    double height = 16,
  }) {
    return DSSkeleton(
      key: key,
      width: width,
      height: height,
      borderRadius: 4,
    );
  }

  @override
  State<DSSkeleton> createState() => _DSSkeletonState();
}

class _DSSkeletonState extends State<DSSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.border.withValues(alpha: _animation.value),
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius ?? 8),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        );
      },
    );
  }
}
