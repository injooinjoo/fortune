import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../pages/fortune_list_page.dart';


import '../../../../core/theme/toss_design_system.dart';

class FortuneListCard extends ConsumerStatefulWidget {
  final FortuneCategory category;
  final VoidCallback onTap;
  final GlobalKey? thumbnailKey;

  const FortuneListCard({
    super.key,
    required this.category,
    required this.onTap,
    this.thumbnailKey});

  @override
  ConsumerState<FortuneListCard> createState() => _FortuneListCardState();
}

class _FortuneListCardState extends ConsumerState<FortuneListCard> with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  final GlobalKey _cardKey = GlobalKey();
  ScrollPosition? _scrollPosition;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
});
}
  
  void _setupScrollListener() {
    final scrollableContext = Scrollable.maybeOf(context);
    if (scrollableContext != null) {
      _scrollPosition = scrollableContext.position;
      _scrollPosition?.addListener(_onScroll);
}
  }
  
  void _onScroll() {
    if (!mounted || _cardKey.currentContext == null) return;
    
    try {
      final RenderBox? cardBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
      if (cardBox != null && cardBox.hasSize && mounted) {
        final position = cardBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;
        final cardHeight = cardBox.size.height;
        final cardCenter = position.dy + (cardHeight / 2);
        final screenCenter = screenHeight / 2;
        
        // Calculate parallax offset based on card position relative to screen center
        final offset = (cardCenter - screenCenter) / screenHeight;
        // Clamp the offset to prevent extreme values
        offset.clamp(-1.0, 1.0);
      }
    } catch (e) {
      // Ignore errors when widget is being disposed
    }
  }
  
  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    super.dispose();
}

  Widget _buildThumbnail() {
    // Use gradient background like trend page
    final gradientColors = FortuneCardImages.getGradientColors(widget.category.type);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background instead of image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Content area with icon
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.category.icon,
                        size: 48,
                        color: TossDesignSystem.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.category.title,
                        style: const TextStyle(
                          color: TossDesignSystem.white,
                          fontFamily: 'ZenSerif',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Decorative elements like trend page
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TossDesignSystem.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TossDesignSystem.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Badges only
          if (widget.category.isNew) Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingS * 1.25, vertical: TossDesignSystem.spacingXS),
                decoration: BoxDecoration(
                  color: TossDesignSystem.errorRed.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: TossDesignSystem.white,
                    
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (widget.category.isPremiumFortune) Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(TossDesignSystem.spacingXS * 1.5),
                decoration: BoxDecoration(
                  color: TossDesignSystem.warningOrange.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: TossDesignSystem.white,
                ),
              ),
            ),
        ],
      ),
    );
}

  Widget _buildCategoryHashtags() {
    final categoryTags = {
      'love': ['#연애운', '#인연', '#궁합'],
      'career': ['#취업', '#사업', '#직장운'],
      'money': ['#재물운', '#투자', '#금전운'],
      'health': ['#건강', '#운동', '#웰빙'],
      'traditional': ['#사주', '#전통', '#명리'],
      'lifestyle': ['#일상', '#생활', '#운세'],
      'interactive': ['#인터랙티브', '#체험', '#참여형'],
      'petFamily': ['#반려동물', '#가족', '#육아']
    };

    final tags = categoryTags[widget.category.category] ?? ['#운세'];

    return Wrap(
      spacing: 4,
      children: tags.map((tag) => Text(
        tag,
        style: TextStyle(
          color: TossDesignSystem.tossBlue,
          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
          fontWeight: FontWeight.w400))).toList());
  }

  void _handleShare() async {
    try {
      await Share.share(
        '${widget.category.title}\n'
        '${widget.category.description}\n\n'
        '포춘 앱에서 더 많은 운세를 확인해보세요! 🔮',
        subject: widget.category.title);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유하기 실패')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = FortuneCardImages.instagramCaptions[widget.category.type] 
        ?? FortuneCardImages.instagramCaptions['default']!;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        key: _cardKey,
        margin: const EdgeInsets.only(bottom: TossDesignSystem.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square image with Hero animation
            Container(
              key: widget.thumbnailKey,
              child: Hero(
                tag: 'fortune-hero-${widget.category.route}',
                child: AspectRatio(
                  aspectRatio: 1.0, // Square ratio
                  child: _buildThumbnail(),
                ),
              ),
            ),
            // Content below image (Instagram style,
            Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite 
                            ? TossDesignSystem.errorRed 
                            : theme.colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: TossDesignSystem.spacingM),
                      IconButton(
                        onPressed: widget.onTap,
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: theme.colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: TossDesignSystem.spacingM),
                      IconButton(
                        onPressed: _handleShare,
                        icon: Icon(
                          Icons.send_outlined,
                          color: theme.colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.bookmark_border,
                          color: theme.colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: TossDesignSystem.spacingS),
                  // Title with soul info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.category.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Soul badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingS, vertical: TossDesignSystem.spacingXS),
                        decoration: BoxDecoration(
                          color: widget.category.isFreeFortune 
                              ? TossDesignSystem.successGreen.withValues(alpha: 0.2)
                              : TossDesignSystem.warningOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                          border: Border.all(
                            color: widget.category.isFreeFortune 
                                ? TossDesignSystem.successGreen.withValues(alpha: 0.3)
                                : TossDesignSystem.warningOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 12,
                              color: widget.category.isFreeFortune 
                                  ? TossDesignSystem.successGreen
                                  : TossDesignSystem.warningOrange),
                            const SizedBox(width: TossDesignSystem.spacingXS),
                            Text(
                              widget.category.soulDescription,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TossDesignSystem.spacingXS),
                  // Caption
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: caption,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: widget.category.description,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TossDesignSystem.spacingXS * 1.5),
                  // Hashtags
                  _buildCategoryHashtags(),
                  const SizedBox(height: TossDesignSystem.spacingS),
                  // Gray divider line
                  Container(
                    height: 0.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
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

class DotPatternPainter extends CustomPainter {
  final Color color;
  
  DotPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    const dotRadius = 2.0;
    const spacing = 20.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}