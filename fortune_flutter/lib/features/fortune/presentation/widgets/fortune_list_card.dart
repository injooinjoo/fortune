import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../../../../core/constants/soul_rates.dart';
import '../pages/fortune_list_page.dart';

class FortuneListCard extends ConsumerStatefulWidget {
  final FortuneCategory category;
  final VoidCallback onTap;
  final GlobalKey? thumbnailKey;

  const FortuneListCard({
    super.key,
    required this.category,
    required this.onTap,
    this.thumbnailKey,
  });

  @override
  ConsumerState<FortuneListCard> createState() => _FortuneListCardState();
}

class _FortuneListCardState extends ConsumerState<FortuneListCard> with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  final GlobalKey _cardKey = GlobalKey();
  double _parallaxOffset = 0.0;
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
        final clampedOffset = offset.clamp(-1.0, 1.0);
        
        if (mounted) {
          setState(() {
            _parallaxOffset = clampedOffset * 30; // Adjust multiplier for effect intensity
          });
        }
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
    // Use specific fortune type image instead of random thumbnail
    final imagePath = FortuneCardImages.getImagePath(widget.category.type);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Clean image without any overlays
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient if image not found
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.category.gradientColors,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.category.icon,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                );
              },
            ),
          ),
          // Badges only
          if (widget.category.isNew)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (widget.category.isPremiumFortune)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: Colors.white,
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
      'petFamily': ['#반려동물', '#가족', '#육아'],
    };

    final tags = categoryTags[widget.category.category] ?? ['#운세'];

    return Wrap(
      spacing: 4,
      children: tags.map((tag) => Text(
        tag,
        style: TextStyle(
          color: const Color(0xFF1976D2), // Instagram blue
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      )).toList(),
    );
  }

  void _handleShare() async {
    try {
      await Share.share(
        '${widget.category.title}\n'
        '${widget.category.description}\n\n'
        '포춘 앱에서 더 많은 운세를 확인해보세요! 🔮',
        subject: widget.category.title,
      );
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
    final caption = FortuneCardImages.instagramCaptions[widget.category.type] 
        ?? FortuneCardImages.instagramCaptions['default']!;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        key: _cardKey,
        margin: const EdgeInsets.only(bottom: 16),
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
            // Content below image (Instagram style)
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
                            ? Colors.red 
                            : theme.colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: widget.onTap,
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: theme.colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
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
                  const SizedBox(height: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.category.isFreeFortune 
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.category.isFreeFortune 
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 12,
                              color: widget.category.isFreeFortune 
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.category.soulDescription,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: widget.category.isFreeFortune 
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 6),
                  // Hashtags
                  _buildCategoryHashtags(),
                  const SizedBox(height: 12),
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