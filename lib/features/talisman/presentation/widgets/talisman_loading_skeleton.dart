import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../domain/models/talisman_wish.dart';

/// 부적 생성 로딩 스켈레톤 UI - 결과 화면과 동일한 레이아웃
class TalismanLoadingSkeleton extends StatefulWidget {
  final TalismanCategory category;
  final String? wishText;

  const TalismanLoadingSkeleton({
    super.key,
    required this.category,
    this.wishText,
  });

  @override
  State<TalismanLoadingSkeleton> createState() => _TalismanLoadingSkeletonState();
}

class _TalismanLoadingSkeletonState extends State<TalismanLoadingSkeleton> {
  int _currentMessageIndex = 0;

  final List<String> _loadingMessages = const [
    '소원을 분석하고 있어요...',
    '최적의 부적 디자인을 찾고 있어요...',
    '전통적인 의미를 담고 있어요...',
    '마지막 마법을 부리고 있어요...',
  ];

  @override
  void initState() {
    super.initState();
    _startMessageRotation();
  }

  void _startMessageRotation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentMessageIndex < _loadingMessages.length - 1) {
        setState(() {
          _currentMessageIndex++;
        });
        _startMessageRotation();
      }
    });
  }

  Color get _categoryColor {
    switch (widget.category) {
      case TalismanCategory.wealth:
        return const Color(0xFFFFD700);
      case TalismanCategory.love:
        return const Color(0xFFFF6B9D);
      case TalismanCategory.career:
        return const Color(0xFF4A90E2);
      case TalismanCategory.health:
        return const Color(0xFF7ED321);
      case TalismanCategory.study:
        return const Color(0xFF9013FE);
      case TalismanCategory.relationship:
        return const Color(0xFFFF9500);
      case TalismanCategory.goal:
        return const Color(0xFF50E3C2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200;
    final cardBgColor = isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          _buildHeaderSkeleton(skeletonColor)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms, color: TossDesignSystem.white.withValues(alpha: 0.3)),

          const SizedBox(height: 32),

          // Talisman Card Skeleton
          _buildCardSkeleton(isDark, skeletonColor, cardBgColor)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms, color: _categoryColor.withValues(alpha: 0.2)),

          const SizedBox(height: 24),

          // Loading Message
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _loadingMessages[_currentMessageIndex],
                key: ValueKey(_currentMessageIndex),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progress Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_loadingMessages.length, (index) {
              final isActive = index <= _currentMessageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? _categoryColor : skeletonColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // Blessings Skeleton
          _buildBlessingsSkeleton(isDark, skeletonColor)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms, color: TossDesignSystem.white.withValues(alpha: 0.3)),

          const SizedBox(height: 32),

          // Buttons Skeleton
          _buildButtonsSkeleton(skeletonColor)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms, color: TossDesignSystem.white.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(Color skeletonColor) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: skeletonColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 160,
          height: 24,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSkeleton(bool isDark, Color skeletonColor, Color cardBgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _categoryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Category Badge Skeleton
          Container(
            width: 100,
            height: 32,
            decoration: BoxDecoration(
              color: _categoryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 20),

          // Image Skeleton
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _categoryColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.category.emoji,
                style: const TextStyle(fontSize: 48),
              ).animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                ),
            ),
          ),

          const SizedBox(height: 20),

          // Mantra Skeleton
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: skeletonColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlessingsSkeleton(bool isDark, Color skeletonColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Skeleton
        Container(
          width: 100,
          height: 24,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),

        const SizedBox(height: 16),

        // Blessing Items Skeleton
        for (int i = 0; i < 3; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _categoryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 180,
                      height: 14,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildButtonsSkeleton(Color skeletonColor) {
    return Column(
      children: [
        // Main Button Skeleton
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Buttons Skeleton
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
