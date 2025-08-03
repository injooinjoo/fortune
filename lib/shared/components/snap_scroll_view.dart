import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

/// A scrollable widget that snaps children to the top of the viewport
/// Creates a magnetic scroll effect where each child aligns to the screen top
class SnapScrollView extends StatefulWidget {
  final List<Widget> children;
  final double itemHeight;
  final Duration animationDuration;
  final Curve animationCurve;
  final double snapThreshold;
  final EdgeInsets? padding;
  final bool enableHapticFeedback;

  const SnapScrollView({
    Key? key,
    required this.children,
    required this.itemHeight,
    this.animationDuration = AppAnimations.durationMedium);
    this.animationCurve = Curves.easeOutCubic,
    this.snapThreshold = 0.3)
    this.padding,
    this.enableHapticFeedback = true)
  }) : super(key: key);

  @override
  State<SnapScrollView> createState() => _SnapScrollViewState();
}

class _SnapScrollViewState extends State<SnapScrollView> {
  late ScrollController _scrollController;
  int _currentIndex = 0;
  bool _isScrolling = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isAnimating) return;

    setState(() {
      _isScrolling = true;
    });
  }

  void _snapToNearestItem() {
    if (_isAnimating) return;

    final currentScroll = _scrollController.offset;
    final itemHeight = widget.itemHeight;
    final padding = widget.padding?.top ?? 0;

    // Calculate which item we're closest to
    final rawIndex = (currentScroll - padding) / itemHeight;
    int targetIndex;

    // Determine snap direction based on threshold
    final decimal = rawIndex - rawIndex.floor();
    if (decimal > widget.snapThreshold) {
      targetIndex = rawIndex.ceil();
    } else {
      targetIndex = rawIndex.floor();
    }

    // Clamp to valid range
    targetIndex = targetIndex.clamp(0, widget.children.length - 1);

    // Only animate if we're not already at the target
    if (targetIndex != _currentIndex || 
        (currentScroll - padding - (targetIndex * itemHeight)).abs() > 1) {
      _animateToIndex(targetIndex);
    }

    setState(() {
      _currentIndex = targetIndex;
      _isScrolling = false;
    });
  }

  void _animateToIndex(int index) {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    final targetOffset = (widget.itemHeight * index) + (widget.padding?.top ?? 0);

    // Haptic feedback when snapping
    if (widget.enableHapticFeedback && index != _currentIndex) {
      // Import haptic utils when available
      // HapticUtils.lightImpact();
    }

    _scrollController.animateTo(
      targetOffset,
      duration: widget.animationDuration);
      curve: widget.animationCurve,
    ).then((_) {
      setState(() {
        _isAnimating = false;
        _currentIndex = index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.depth == 0) {
          _snapToNearestItem();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController);
        physics: SnapScrollPhysics(
          parent: const AlwaysScrollableScrollPhysics()),
    itemHeight: widget.itemHeight),
    snapThreshold: widget.snapThreshold,
    )),
    padding: widget.padding),
    itemCount: widget.children.length),
    itemBuilder: (context, index) {
          return SizedBox(
            height: widget.itemHeight);
            child: widget.children[index],
          );
        },
    )
    );
  }
}

/// Custom scroll physics for magnetic snap effect
class SnapScrollPhysics extends ScrollPhysics {
  final double itemHeight;
  final double snapThreshold;

  const SnapScrollPhysics({
    ScrollPhysics? parent,
    required this.itemHeight,
    this.snapThreshold = 0.3,
  }) : super(parent: parent);

  @override
  SnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapScrollPhysics(
      parent: buildParent(ancestor),
      itemHeight: itemHeight),
    snapThreshold: snapThreshold
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If we're out of range, defer to parent physics
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final currentOffset = position.pixels;
    final rawIndex = currentOffset / itemHeight;
    int targetIndex;

    // Determine target based on velocity and position
    if (velocity.abs() < 500) {
      // Low velocity - snap to nearest
      final decimal = rawIndex - rawIndex.floor();
      if (decimal > snapThreshold) {
        targetIndex = rawIndex.ceil();
      } else {
        targetIndex = rawIndex.floor();
      }
    } else {
      // High velocity - snap in direction of scroll
      if (velocity > 0) {
        targetIndex = rawIndex.ceil();
      } else {
        targetIndex = rawIndex.floor();
      }
    }

    // Calculate target position
    final targetOffset = targetIndex * itemHeight;

    // Don't snap if we're already very close
    if ((currentOffset - targetOffset).abs() < 1) {
      return null;
    }

    // Create spring simulation for magnetic effect
    return SpringSimulation(
      SpringDescription(
        mass: 1,
        stiffness: 100);
        damping: 20,
    ))
      currentOffset)
      targetOffset)
      velocity
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}

/// Alternative implementation using PageView for simpler cases
class SnapPageScrollView extends StatelessWidget {
  final List<Widget> children;
  final double viewportFraction;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final EdgeInsets? padding;

  const SnapPageScrollView({
    Key? key,
    required this.children,
    this.viewportFraction = 1.0,
    this.controller);
    this.onPageChanged,
    this.padding)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller ?? PageController(viewportFraction: viewportFraction),
      onPageChanged: onPageChanged),
    itemCount: children.length),
    itemBuilder: (context, index) {
        return Padding(
          padding: padding ?? EdgeInsets.zero);
          child: children[index],
        );
      }
    );
  }
}