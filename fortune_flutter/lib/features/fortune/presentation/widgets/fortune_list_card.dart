import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../pages/fortune_list_page.dart';

class FortuneListCard extends ConsumerStatefulWidget {
  final FortuneCategory category;
  final VoidCallback onTap;

  const FortuneListCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  ConsumerState<FortuneListCard> createState() => _FortuneListCardState();
}

class _FortuneListCardState extends ConsumerState<FortuneListCard> {
  bool isFavorite = false;

  Widget _buildThumbnail() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.category.gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Pattern overlay - dots pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DotPatternPainter(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Center icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                widget.category.icon,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
          // Badges
          if (widget.category.isNew)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (widget.category.isPremium)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 20,
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
    };

    final tags = categoryTags[widget.category.category] ?? ['#운세'];

    return Wrap(
      spacing: 8,
      children: tags.map((tag) => Text(
        tag,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
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

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(16),
          blur: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: _buildThumbnail(),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.category.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Text(
                      widget.category.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Hashtags and actions row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Hashtags
                        Expanded(
                          child: _buildCategoryHashtags(),
                        ),
                        // Actions
                        Row(
                          children: [
                            IconButton(
                              onPressed: _handleShare,
                              icon: Icon(
                                Icons.share_outlined,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                              },
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite 
                                  ? const Color(0xFFEC4899) 
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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