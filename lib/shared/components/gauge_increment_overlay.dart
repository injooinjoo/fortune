import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../glassmorphism/glass_container.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/design_system/design_system.dart';

class GaugeIncrementOverlay {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required int fromProgress,
    required int toProgress,
    VoidCallback? onComplete,
  }) {
    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Create new overlay
    _currentOverlay = OverlayEntry(
      builder: (context) => _GaugeIncrementWidget(
        fromProgress: fromProgress,
        toProgress: toProgress,
        onComplete: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
          onComplete?.call();
        },
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_currentOverlay!);

    // Haptic feedback
    HapticUtils.success();
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _GaugeIncrementWidget extends StatefulWidget {
  final int fromProgress;
  final int toProgress;
  final VoidCallback onComplete;

  const _GaugeIncrementWidget({
    required this.fromProgress,
    required this.toProgress,
    required this.onComplete,
  });

  @override
  State<_GaugeIncrementWidget> createState() => _GaugeIncrementWidgetState();
}

class _GaugeIncrementWidgetState extends State<_GaugeIncrementWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _counterAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller - 1.5 seconds total
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Slide down animation (0.0 to 1.0)
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Fade animation
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 20, // Fade in
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 60, // Stay visible
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 20, // Fade out
      ),
    ]).animate(_controller);

    // Counter animation (from -> to)
    _counterAnimation = IntTween(
      begin: widget.fromProgress,
      end: widget.toProgress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    ));

    // Start animation
    _controller.forward();

    // Complete callback
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final topPadding = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: topPadding + DSSpacing.lg,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.xl,
                    vertical: DSSpacing.md,
                  ),
                  borderRadius: BorderRadius.circular(DSRadius.xl),
                  blur: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Text(
                        '${_counterAnimation.value}/10',
                        style: typography.labelLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .shimmer(
                      duration: 1000.ms,
                      color: colors.accentTertiary.withValues(alpha: 0.3),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
