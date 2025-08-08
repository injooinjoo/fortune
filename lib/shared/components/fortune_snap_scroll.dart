import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/haptic_utils.dart';
import '../glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

/// A specialized snap scroll view for fortune cards with image headers
/// Each card's image top snaps to the viewport top when scrolling
class FortuneSnapScrollView extends StatefulWidget {
  final List<FortuneSnapCard> cards;
  final double imageHeight;
  final Duration snapDuration;
  final Curve snapCurve;
  final double velocityThreshold;
  final double snapDistance;
  final Color? backgroundColor;

  const FortuneSnapScrollView({
    Key? key,
    required this.cards,
    this.imageHeight = 300,
    this.snapDuration = const Duration(milliseconds: 350),
    this.snapCurve = Curves.easeOutCubic,
    this.velocityThreshold = 100,
    this.snapDistance = 50,
    this.backgroundColor}) : super(key: key);

  @override
  State<FortuneSnapScrollView> createState() => _FortuneSnapScrollViewState();
}

class _FortuneSnapScrollViewState extends State<FortuneSnapScrollView>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  bool _isSnapping = false;
  double _lastScrollPosition = 0;
  DateTime _lastScrollTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.snapDuration
    );
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isSnapping) return;

    // Calculate velocity
    final now = DateTime.now();
    final timeDiff = now.difference(_lastScrollTime).inMilliseconds;
    if (timeDiff > 0) {
      final velocity = (_scrollController.offset - _lastScrollPosition) / timeDiff * 1000;
      _lastScrollPosition = _scrollController.offset;
      _lastScrollTime = now;

      // Check if we should start snapping
      if (velocity.abs() < widget.velocityThreshold) {
        _checkForSnap();
      }
    }
  }

  void _checkForSnap() {
    if (_isSnapping) return;

    final scrollOffset = _scrollController.offset;
    double minDistance = double.infinity;
    int targetIndex = 0;
    double targetOffset = 0;

    // Find the nearest card snap point
    for (int i = 0; i < widget.cards.length; i++) {
      final cardOffset = _getCardOffset(i);
      final distance = (scrollOffset - cardOffset).abs();
      
      if (distance < minDistance) {
        minDistance = distance;
        targetIndex = i;
        targetOffset = cardOffset;
      }
    }

    // Snap if within threshold distance
    if (minDistance < widget.snapDistance && targetIndex != _currentIndex) {
      _snapToCard(targetIndex, targetOffset);
    }
  }

  double _getCardOffset(int index) {
    double offset = 0;
    for (int i = 0; i < index; i++) {
      offset += widget.cards[i].totalHeight;
    }
    return offset;
  }

  void _snapToCard(int index, double targetOffset) {
    if (_isSnapping) return;

    setState(() {
      _isSnapping = true;
      _currentIndex = index;
    });

    // Haptic feedback
    HapticUtils.lightImpact();

    // Animate to target
    final animation = Tween<double>(
      begin: _scrollController.offset,
      end: targetOffset).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.snapCurve);

    animation.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(animation.value);
      }
    });

    _animationController.forward(from: 0).then((_) {
      setState(() {
        _isSnapping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          // Final snap check when scrolling ends
          Future.delayed(AppAnimations.durationMicro, () {
            if (!_isSnapping) {
              _checkForSnap();
            }
          });
        }
        return false;
      },
      child: Container(
        color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: widget.cards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              
              return RepaintBoundary(
                child: card);
            }).toList()))));
  }
}

/// A fortune card designed for snap scrolling with an image header
class FortuneSnapCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final Widget content;
  final double imageHeight;
  final double contentPadding;
  final VoidCallback? onTap;

  const FortuneSnapCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.content,
    this.imageHeight = 300,
    this.contentPadding = 20,
    this.onTap}) : super(key: key);

  double get totalHeight => imageHeight + 150 + contentPadding * 2; // Approximate height

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xxxSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header with Parallax potential
            Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.textPrimary.withOpacity(0.3),
                      AppColors.textPrimary.withOpacity(0.7)],
                    stops: const [0.5, 0.8, 1.0])),
                padding: EdgeInsets.all(contentPadding),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppColors.textPrimary.withOpacity(0.8),
                            blurRadius: 8)])),
                    SizedBox(height: AppSpacing.spacing2),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimaryDark.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            color: AppColors.textPrimary.withOpacity(0.8),
                            blurRadius: 6)]))]))),
            
            // Content Section
            Container(
              padding: EdgeInsets.all(contentPadding),
              child: content)])));
  }
}

/// Simple implementation using PageView for vertical snap scrolling
class FortunePageSnapView extends StatefulWidget {
  final List<Widget> pages;
  final ValueChanged<int>? onPageChanged;
  final bool enableHapticFeedback;

  const FortunePageSnapView({
    Key? key,
    required this.pages,
    this.onPageChanged,
    this.enableHapticFeedback = true}) : super(key: key);

  @override
  State<FortunePageSnapView> createState() => _FortunePageSnapViewState();
}

class _FortunePageSnapViewState extends State<FortunePageSnapView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (page != _currentPage && widget.enableHapticFeedback) {
      HapticUtils.lightImpact();
    }
    setState(() {
      _currentPage = page;
    });
    widget.onPageChanged?.call(page);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: widget.pages.length,
      itemBuilder: (context, index) => widget.pages[index]
    );
  }
}