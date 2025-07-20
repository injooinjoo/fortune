import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/constants/soul_rates.dart';

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
    required this.route,
  });

  @override
  ConsumerState<TarotFortuneListCard> createState() => _TarotFortuneListCardState();
}

class _TarotFortuneListCardState extends ConsumerState<TarotFortuneListCard> 
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  
  // Sample tarot cards for display
  final List<TarotCardInfo> _displayCards = [
    TarotMetadata.majorArcana[0]!,  // The Fool
    TarotMetadata.majorArcana[1]!,  // The Magician
    TarotMetadata.majorArcana[10]!, // Wheel of Fortune
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildTarotCardDisplay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D1B69),
            const Color(0xFF0F0C29),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Mystical background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: MysticalPatternPainter(),
            ),
          ),
          // Animated glow effect
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withValues(alpha: 0.3 * _glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              );
            },
          ),
          // Tarot cards display
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back cards (fanned out)
                for (int i = 0; i < 3; i++)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(
                        (i - 1) * 30.0,
                        i == 1 ? -10.0 : 0.0,
                      )
                      ..rotateZ((i - 1) * 0.15),
                    child: _buildSingleCard(i),
                  ),
              ],
            ),
          ),
          // Premium badge
          if (widget.isPremium)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: Colors.white,
                ),
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
                  bottomRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleCard(int index) {
    final card = _displayCards[index];
    final isCenter = index == 1;
    
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Card back design
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCenter ? [
                    const Color(0xFF6B46C1),
                    const Color(0xFF4C1D95),
                  ] : [
                    const Color(0xFF4C1D95),
                    const Color(0xFF2D1B69),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: TarotCardBackPainter(),
              ),
            ),
            // Card image hint (subtle)
            if (isCenter)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 30,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
            ),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: widget.onTap,
          icon: Icon(
            Icons.visibility_outlined,
            color: theme.colorScheme.onSurface,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _handleShare,
          icon: Icon(
            Icons.share_outlined,
            color: theme.colorScheme.onSurface,
          ),
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
                  ? [Colors.green, Colors.teal]
                  : [const Color(0xFF6B46C1), const Color(0xFF4C1D95)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (widget.soulCost == 0 ? Colors.green : const Color(0xFF6B46C1))
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                widget.soulCost == 0 ? '무료' : '${widget.soulCost}소울',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
        subject: widget.title,
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
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarot card display with Hero animation
            Hero(
              tag: 'tarot-hero-${widget.route}',
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _buildTarotCardDisplay(),
              ),
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
                      '#${widget.title.replaceAll(' ', '')}',
                    ].map((tag) => Text(
                      tag,
                      style: TextStyle(
                        color: const Color(0xFF6B46C1),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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

// Custom painter for mystical background
class MysticalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw constellation pattern
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      paint.color = Colors.white.withValues(alpha: 0.1 + random.nextDouble() * 0.1);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1 + random.nextDouble() * 2, paint);
    }

    // Draw connecting lines
    paint.color = Colors.white.withValues(alpha: 0.05);
    for (int i = 0; i < 5; i++) {
      final x1 = random.nextDouble() * size.width;
      final y1 = random.nextDouble() * size.height;
      final x2 = random.nextDouble() * size.width;
      final y2 = random.nextDouble() * size.height;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for tarot card back
class TarotCardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.2);

    // Draw geometric pattern
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Central star
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final x = centerX + math.cos(angle) * 20;
      final y = centerY + math.sin(angle) * 20;
      canvas.drawLine(Offset(centerX, centerY), Offset(x, y), paint);
    }
    
    // Outer circle
    canvas.drawCircle(Offset(centerX, centerY), 25, paint);
    
    // Corner decorations
    paint.color = Colors.white.withValues(alpha: 0.15);
    canvas.drawLine(const Offset(5, 5), const Offset(15, 5), paint);
    canvas.drawLine(const Offset(5, 5), const Offset(5, 15), paint);
    
    canvas.drawLine(Offset(size.width - 5, 5), Offset(size.width - 15, 5), paint);
    canvas.drawLine(Offset(size.width - 5, 5), Offset(size.width - 5, 15), paint);
    
    canvas.drawLine(Offset(5, size.height - 5), Offset(15, size.height - 5), paint);
    canvas.drawLine(Offset(5, size.height - 5), Offset(5, size.height - 15), paint);
    
    canvas.drawLine(
      Offset(size.width - 5, size.height - 5), 
      Offset(size.width - 15, size.height - 5), 
      paint
    );
    canvas.drawLine(
      Offset(size.width - 5, size.height - 5), 
      Offset(size.width - 5, size.height - 15), 
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}