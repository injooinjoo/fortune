import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../../core/constants/tarot_deck_metadata.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/typography_unified.dart';

/// Unified tarot card widget that handles both front and back display
/// with flip animation support
class TarotCardWidget extends StatefulWidget {
  final int cardIndex;
  final TarotDeck deck;
  final double width;
  final double height;
  final bool showFront;
  final bool isSelected;
  final bool isHovered;
  final int? selectionOrder; // 선택 순서 표시
  final VoidCallback? onTap;
  final Duration flipDuration;
  final bool enableFlipAnimation;

  const TarotCardWidget({
    super.key,
    required this.cardIndex,
    required this.deck,
    this.width = 120,
    this.height = 180,
    this.showFront = false,
    this.isSelected = false,
    this.isHovered = false,
    this.selectionOrder,
    this.onTap,
    this.flipDuration = AppAnimations.durationXLong,
    this.enableFlipAnimation = true,
  });

  @override
  State<TarotCardWidget> createState() => _TarotCardWidgetState();
}

class _TarotCardWidgetState extends State<TarotCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    
    _flipController = AnimationController(
      duration: widget.flipDuration,
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutCubic,
    ));

    if (widget.showFront) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TarotCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFront != oldWidget.showFront && widget.enableFlipAnimation) {
      if (widget.showFront) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    } else if (!widget.enableFlipAnimation) {
      _flipController.value = widget.showFront ? 1.0 : 0.0;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[TarotCard] === Card Widget Build ===');
    debugPrint('[TarotCard] cardIndex: ${widget.cardIndex}');
    debugPrint('[TarotCard] isHovered: ${widget.isHovered}, isSelected: ${widget.isSelected}');
    debugPrint('[TarotCard] showFront: ${widget.showFront}');
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationShort,
        width: widget.width,
        height: widget.height,
        transform: Matrix4.identity()
          ..scale(widget.isHovered ? 1.05 : 1.0, widget.isHovered ? 1.05 : 1.0),
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final isShowingFront = _flipAnimation.value >= 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(math.pi * _flipAnimation.value),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppDimensions.borderRadiusMedium,
                  boxShadow: _buildBoxShadow()),
                child: ClipRRect(
                  borderRadius: AppDimensions.borderRadiusMedium,
                  child: isShowingFront
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildCardFront())
                      : _buildCardBack(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<BoxShadow> _buildBoxShadow() {
    debugPrint('[TarotCard] Building box shadow - isSelected: ${widget.isSelected}, isHovered: ${widget.isHovered}');
    if (widget.isSelected) {
      debugPrint('alpha: 0.6');
      return [
        BoxShadow(
          color: widget.deck.primaryColor.withValues(alpha: 0.6),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ];
    } else if (widget.isHovered) {
      debugPrint('alpha: 0.4');
      return [
        BoxShadow(
          color: widget.deck.primaryColor.withValues(alpha: 0.4),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ];
    } else {
      debugPrint('alpha: 0.3');
      return [
        BoxShadow(
          color: TossDesignSystem.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ];
    }
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.deck.primaryColor,
            widget.deck.secondaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern overlay
          CustomPaint(
            painter: TarotCardBackPainter(
              primaryColor: widget.deck.primaryColor,
              secondaryColor: widget.deck.secondaryColor,
              isHighlighted: widget.isHovered || widget.isSelected),
            size: Size(widget.width, widget.height),
          ),
          // Center emblem
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: widget.width * 0.33,
                  color: TossDesignSystem.white.withValues(alpha: 0.8),
                ),
                const SizedBox(height: AppSpacing.spacing2),
                Text(
                  widget.deck.koreanName,
                  style: TextStyle(
                    fontSize: widget.width * 0.12,
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.white,
                    letterSpacing: 1),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // 선택 순서 표시
          if (widget.selectionOrder != null)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: TossDesignSystem.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${widget.selectionOrder}',
                    style: TypographyUnified.buttonMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.deck.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    // Simplified front display - can be expanded based on actual card data
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TossDesignSystem.white,
            TossDesignSystem.gray100,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Card content area
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: widget.width * 0.5,
                  color: widget.deck.primaryColor),
                const SizedBox(height: AppSpacing.spacing4),
                Text(
                  'Card ${widget.cardIndex + 1}',
                  style: TextStyle(
                    fontSize: widget.width * 0.15,
                    fontWeight: FontWeight.bold,
                    color: widget.deck.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Card number
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing1),
              decoration: BoxDecoration(
                color: widget.deck.primaryColor.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusMedium),
              child: Text(
                '${widget.cardIndex + 1}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for tarot card back patterns
class TarotCardBackPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final bool isHighlighted;

  TarotCardBackPainter({
    required this.primaryColor,
    required this.secondaryColor,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
     
   
    ..strokeWidth = isHighlighted ? 2.0 : 1.5;

    // Draw mystical patterns
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Outer circle
    paint.color = TossDesignSystem.white.withValues(alpha: isHighlighted ? 0.4 : 0.2);
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.3, paint);

    // Inner star pattern
    _drawStar(canvas, paint, centerX, centerY, size.width * 0.25);

    // Corner decorations
    paint.color = TossDesignSystem.white.withValues(alpha: isHighlighted ? 0.5 : 0.3);
    const cornerSize = 15.0;
    
    _drawCornerPattern(canvas, paint, 0, 0, cornerSize, false, false);
    _drawCornerPattern(canvas, paint, size.width, 0, cornerSize, true, false);
    _drawCornerPattern(canvas, paint, 0, size.height, cornerSize, false, true);
    _drawCornerPattern(canvas, paint, size.width, size.height, cornerSize, true, true);

    // Additional circles for highlighted state
    if (isHighlighted) {
      paint.color = TossDesignSystem.white.withValues(alpha: 0.1);
      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(Offset(centerX, centerY), size.width * 0.15 * i, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double cx, double cy, double radius) {
    final path = Path();
    const points = 8;
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * math.pi) / points - math.pi / 2;
      final r = i.isEven ? radius : radius * 0.6;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCornerPattern(Canvas canvas, Paint paint, double x, double y,
      double size, bool flipX, bool flipY) {
    final dx = flipX ? -1 : 1;
    final dy = flipY ? -1 : 1;
    
    canvas.drawLine(Offset(x, y + dy * size), Offset(x, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x + dx * size, y), paint);
    
    // Add decorative arc
    final rect = Rect.fromCenter(
      center: Offset(x + dx * size / 2, y + dy * size / 2),
      width: size,
      height: size);
    canvas.drawArc(
      rect,
      flipX && !flipY ? math.pi : flipX && flipY ? math.pi / 2 : flipY ? 3 * math.pi / 2 : 0,
      math.pi / 2,
      false,
      paint);
  }

  @override
  bool shouldRepaint(covariant TarotCardBackPainter oldDelegate) {
    return oldDelegate.isHighlighted != isHighlighted;
  }
}