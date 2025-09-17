import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
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
/// Includes fade in/out effects during scroll transitions
class FortuneSnapScrollView extends StatefulWidget {
  final List<FortuneSnapCard> cards;
  final double imageHeight;
  final Duration snapDuration;
  final Curve snapCurve;
  final double velocityThreshold;
  final double snapDistance;
  final Color? backgroundColor;
  final bool enableFadeEffect;
  final double fadeStartOffset;
  final double fadeEndOffset;

  const FortuneSnapScrollView({
    Key? key,
    required this.cards,
    this.imageHeight = 300,
    this.snapDuration = const Duration(milliseconds: 350),
    this.snapCurve = Curves.easeOutCubic,
    this.velocityThreshold = 100,
    this.snapDistance = 50,
    this.backgroundColor,
    this.enableFadeEffect = true,
    this.fadeStartOffset = 0.3,
    this.fadeEndOffset = 0.7}) : super(key: key);

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
      curve: widget.snapCurve));

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

  double _calculateCardOpacity(int index) {
    if (!widget.enableFadeEffect) return 1.0;
    
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
    final cardOffset = _getCardOffset(index);
    final cardHeight = widget.cards[index].totalHeight;
    
    // Calculate card's position relative to viewport
    final cardTop = cardOffset - scrollOffset;
    final cardBottom = cardTop + cardHeight;
    final viewportHeight = MediaQuery.of(context).size.height;
    
    // 더 민감한 페이드 임계값 설정
    // 상단 20% 지점에서 페이드 아웃 시작
    final fadeOutThreshold = viewportHeight * 0.2;
    // 하단 80% 지점에서 페이드 인 시작
    final fadeInThreshold = viewportHeight * 0.8;
    
    // Card is completely below viewport
    if (cardTop > viewportHeight) {
      return 0.0;
    }
    
    // Card is completely above viewport
    if (cardBottom < 0) {
      return 0.0;
    }
    
    // Card is entering from bottom (fade in - 더 일찍 시작)
    if (cardTop > fadeInThreshold) {
      final fadeInProgress = 1.0 - ((cardTop - fadeInThreshold) / (viewportHeight - fadeInThreshold));
      return Curves.fastOutSlowIn.transform(fadeInProgress.clamp(0.0, 1.0));
    }
    
    // Card is exiting from top (fade out - 더 일찍 시작)
    if (cardBottom < fadeOutThreshold) {
      final fadeOutProgress = cardBottom / fadeOutThreshold;
      return Curves.fastOutSlowIn.transform(fadeOutProgress.clamp(0.0, 1.0));
    }
    
    // Card가 화면 중앙 영역을 벗어나기 시작하면 페이드 처리
    final centerPoint = viewportHeight / 2;
    
    // 위로 스크롤 중 (카드가 위로 올라감)
    if (cardTop < fadeOutThreshold && cardBottom > centerPoint) {
      // 카드 상단이 임계점을 넘으면 페이드 아웃 시작
      final fadeProgress = (cardTop - fadeOutThreshold).abs() / (centerPoint - fadeOutThreshold);
      return Curves.easeInOut.transform((1.0 - fadeProgress).clamp(0.0, 1.0));
    }
    
    // 아래로 스크롤 중 (카드가 아래로 내려감)
    if (cardBottom > fadeInThreshold && cardTop < centerPoint) {
      // 카드 하단이 임계점을 넘으면 페이드 아웃 시작
      final fadeProgress = (cardBottom - fadeInThreshold) / (viewportHeight - fadeInThreshold);
      return Curves.easeInOut.transform((1.0 - fadeProgress).clamp(0.0, 1.0));
    }
    
    // Card is in the safe zone - fully visible
    return 1.0;
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
                child: widget.enableFadeEffect
                    ? AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, child) {
                          final opacity = _calculateCardOpacity(index);
                          return AnimatedOpacity(
                            opacity: opacity,
                            duration: const Duration(milliseconds: 50),
                            child: card,
                          );
                        },
                      )
                    : card,
              );
            }).toList(),
          ),
        ),
      ),
    );
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
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      TossDesignSystem.transparent,
                      TossDesignSystem.gray900.withOpacity(0.3),
                      TossDesignSystem.gray900.withOpacity(0.7),
                    ],
                    stops: const [0.5, 0.8, 1.0],
                  ),
                ),
                padding: EdgeInsets.all(contentPadding),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: TossDesignSystem.grayDark900,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: TossDesignSystem.gray900.withOpacity(0.8),
                            blurRadius: 8)])),
                    SizedBox(height: AppSpacing.spacing2),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: TossDesignSystem.grayDark900.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            color: TossDesignSystem.gray900.withOpacity(0.8),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content Section
            Container(
              padding: EdgeInsets.all(contentPadding),
              child: content,
            ),
          ],
        ),
      ),
    );
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