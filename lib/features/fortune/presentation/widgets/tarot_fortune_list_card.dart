import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/fortune_card_images.dart';
import 'package:fortune/core/theme/fortune_colors.dart';
import '../../../../core/design_system/design_system.dart';

class TarotFortuneListCard extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isPremium;
  final int soulCost;
  final String route;

  const TarotFortuneListCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.isPremium = false,
    this.soulCost = 1,
    required this.route});

  @override
  ConsumerState<TarotFortuneListCard> createState() => _TarotFortuneListCardState();
}

class _TarotFortuneListCardState extends ConsumerState<TarotFortuneListCard> 
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this)..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut));
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildTarotCardDisplay() {
    return Stack(
      children: [
        // Use the actual tarot image
        ClipRRect(
          borderRadius: BorderRadius.circular(DSRadius.lg),
          child: Image.asset(
            FortuneCardImages.getImagePath('tarot'),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to gradient container if image fails
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DSRadius.lg),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FortuneColors.tarotDark,
                      FortuneColors.tarotDarkest],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.style_rounded,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.5)),
                ),
              );
            },
          ),
        ),
        // Animated glow effect
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: DSColors.accentSecondary.withValues(alpha: 0.3 * _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 5),
                ],
              ),
            );
          },
        ),
        // Premium badge
        if (widget.isPremium) Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DSColors.warning.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: DSColors.warning.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 20,
                color: Colors.white),
            ),
          ),
        // Title overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
          icon: AnimatedSwitcher(
            duration: DSAnimation.durationMedium,
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              color: isFavorite ? DSColors.error : theme.colorScheme.onSurface)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: widget.onTap,
          icon: Icon(
            Icons.visibility_outlined,
            color: theme.colorScheme.onSurface),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _handleShare,
          icon: Icon(
            Icons.share_outlined,
            color: theme.colorScheme.onSurface),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const Spacer(),
        // Soul cost badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.soulCost == 0
                  ? [DSColors.success, DSColors.accent]
                  : [FortuneColors.spiritualPrimary, FortuneColors.spiritualDark]),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            boxShadow: [
              BoxShadow(
                color: (widget.soulCost == 0 ? DSColors.success : FortuneColors.spiritualPrimary)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: Colors.white),
              const SizedBox(width: 4),
              Text(
                widget.soulCost == 0 ? '무료' : '${widget.soulCost}소울',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleShare() async {
    try {
      await Share.share(
        '${widget.title} 타로 운세 🔮\n'
        '${widget.description}\n\n'
        '포춘 앱에서 나만의 타로 운세를 확인해보세요!',
        subject: widget.title);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유하기 실패')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarot card display with Hero animation
            Hero(
              tag: 'tarot-hero-${widget.route}',
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _buildTarotCardDisplay()),
            ),
            // Content section
            Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionButtons(),
                  const SizedBox(height: 12),
                  // Hashtags
                  Wrap(
                    spacing: 8,
                    children: [
                      '#타로카드',
                      '#운세',
                      '#${widget.title.replaceAll(' ', '')}'].map((tag) => Text(
                      tag,
                      style: TextStyle(
                        color: FortuneColors.spiritualPrimary,
                        fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                        fontWeight: FontWeight.w500),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

