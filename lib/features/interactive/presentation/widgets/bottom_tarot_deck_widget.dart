import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:fortune/core/design_system/design_system.dart';

class BottomTarotDeckWidget extends ConsumerStatefulWidget {
  final Function(int) onCardSelected;

  const BottomTarotDeckWidget({
    super.key,
    required this.onCardSelected,
  });

  @override
  ConsumerState<BottomTarotDeckWidget> createState() => _BottomTarotDeckWidgetState();
}

class _BottomTarotDeckWidgetState extends ConsumerState<BottomTarotDeckWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideUpController;
  late AnimationController _fanController;
  late AnimationController _rotationController;
  
  late Animation<double> _slideUpAnimation;
  late Animation<double> _fanAnimation;
  late Animation<double> _rotationAnimation;
  
  final int cardCount = 30;
  final double cardWidth = 60;
  final double cardHeight = 84;  // Maintaining 1:1.4 ratio (5:7)
  
  double _dragStartX = 0;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    
    // Slide up animation
    _slideUpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this);
    
    _slideUpAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0).animate(CurvedAnimation(
      parent: _slideUpController,
      curve: Curves.easeOutCubic));
    
    // Fan animation
    _fanController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this);
    
    _fanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _fanController,
      curve: Curves.easeOutBack));
    
    // Rotation animation for drag gestures
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this);
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut));
    
    // Start animations
    _startAnimations();
  }
  
  void _startAnimations() async {
    await _slideUpController.forward();
    await _fanController.forward();
  }
  
  @override
  void dispose() {
    _slideUpController.dispose();
    _fanController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_slideUpAnimation, _fanAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, screenHeight * 0.3 * _slideUpAnimation.value),
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              _dragStartX = details.globalPosition.dx;
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                final dragDistance = details.globalPosition.dx - _dragStartX;
                _currentRotation = (dragDistance / screenWidth) * math.pi;
              });
            },
            onHorizontalDragEnd: (details) {
              // Snap to nearest card
              final velocity = details.velocity.pixelsPerSecond.dx;
              _animateToNearestCard(velocity);
            },
            child: SizedBox(
              height: cardHeight * 2.5,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: List.generate(cardCount, (index) {
                  return _buildCard(index, screenWidth);
                }),
              ),
            ),
          ),
        );
      });
  }
  
  Widget _buildCard(int index, double screenWidth) {
    final fanProgress = _fanAnimation.value;
    final normalizedIndex = (index - cardCount / 2) / (cardCount / 2);
    
    // Calculate arc position
    final baseAngle = normalizedIndex * math.pi * 0.5; // 90 degree spread
    final angle = baseAngle + _currentRotation;
    
    // Calculate position on the arc
    final radius = screenWidth * 0.7; // Radius of the arc
    final x = radius * math.sin(angle);
    final y = -radius * math.cos(angle) + radius * 0.8; // Lift cards up
    
    // Check if this is the center card
    final distanceFromCenter = (angle).abs();
    final isCenter = distanceFromCenter < 0.1;
    final scale = 1.0 - (distanceFromCenter * 0.2).clamp(0.0, 0.4);
    
    // Calculate z-index (cards in front should be on top)
    final zIndex = (cardCount - distanceFromCenter * 10).round();
    
    return Positioned(
      bottom: 0,
      left: screenWidth / 2 - cardWidth / 2,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..translateByDouble(x * fanProgress, y * fanProgress, zIndex.toDouble(), 0.0)
          ..rotateZ(angle * 0.3 * fanProgress)
          ..scaleByDouble(scale * fanProgress, scale * fanProgress, 1.0, 1.0),
        child: Opacity(
          opacity: (0.3 + fanProgress * 0.7).clamp(0.0, 1.0),
          child: GestureDetector(
            onTap: () {
              if (isCenter) {
                HapticFeedback.mediumImpact();
                // 카드 선택
                widget.onCardSelected(index);
              } else {
                // Animate to this card
                _animateToCard(index);
              }
            },
            child: _buildTarotCard(isCenter),
          ),
        ),
      ),
    );
  }
  
  void _animateToCard(int index) {
    final targetRotation = -(index - cardCount / 2) / (cardCount / 2) * math.pi * 0.5;
    
    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut));
    
    _rotationController.forward(from: 0).then((_) {
      setState(() {
        _currentRotation = targetRotation;
      });
    });
  }
  
  void _animateToNearestCard(double velocity) {
    // Calculate which card should be centered based on current rotation
    final cardAngle = math.pi * 0.5 / cardCount;
    final nearestCardIndex = ((-_currentRotation / cardAngle) + cardCount / 2).round().clamp(0, cardCount - 1);
    
    _animateToCard(nearestCardIndex);
  }
  
  Widget _buildTarotCard(bool isCenter) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: isCenter ? [
          BoxShadow(
            color: DSColors.accentDark.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 5),
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Card background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A5F), // 고유 색상 - 타로 카드 뒷면 그라데이션
                    Color(0xFF0D1B2A), // 고유 색상 - 타로 카드 뒷면 그라데이션
                    Color(0xFF415A77), // 고유 색상 - 타로 카드 뒷면 그라데이션
                  ],
                ),
              ),
            ),
            
            // Card pattern
            Positioned.fill(
              child: CustomPaint(
                painter: TarotCardBackPainter(
                  isHighlighted: isCenter),
              ),
            ),
            
            // Card border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCenter
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.2),
                  width: isCenter ? 2 : 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TarotCardBackPainter extends CustomPainter {
  final bool isHighlighted;
  
  TarotCardBackPainter({required this.isHighlighted});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Center design
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw stars pattern
    paint.color = Colors.white.withValues(alpha: isHighlighted ? 0.4 : 0.2);
    
    // Center star
    _drawStar(canvas, center, size.width * 0.15, paint);
    
    // Surrounding stars
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final starPos = Offset(
        center.dx + size.width * 0.25 * math.cos(angle),
        center.dy + size.width * 0.25 * math.sin(angle));
      _drawStar(canvas, starPos, size.width * 0.08, paint);
    }
    
    // Draw border pattern
    final borderRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.05,
      size.width * 0.8,
      size.height * 0.9);
    paint.strokeWidth = 1.0;
    canvas.drawRect(borderRect, paint);
    
    // Inner border
    final innerRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.08,
      size.width * 0.7,
      size.height * 0.84);
    paint.strokeWidth = 0.5;
    canvas.drawRect(innerRect, paint);
  }
  
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final angle = -math.pi / 2;
    
    for (int i = 0; i < 5; i++) {
      final outerX = center.dx + radius * math.cos(angle + i * 2 * math.pi / 5);
      final outerY = center.dy + radius * math.sin(angle + i * 2 * math.pi / 5);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      
      final innerRadius = radius * 0.4;
      final innerAngle = angle + (i * 2 + 1) * math.pi / 5;
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}