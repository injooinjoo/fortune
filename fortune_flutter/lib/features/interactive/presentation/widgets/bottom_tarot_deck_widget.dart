import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:math' show Random;

class BottomTarotDeckWidget extends StatefulWidget {
  final Function(int, Offset, Size) onCardSelected;
  
  const BottomTarotDeckWidget({
    Key? key,
    required this.onCardSelected,
  }) : super(key: key);

  @override
  State<BottomTarotDeckWidget> createState() => _BottomTarotDeckWidgetState();
}

class _BottomTarotDeckWidgetState extends State<BottomTarotDeckWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideUpController;
  late AnimationController _fanController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  
  late Animation<double> _slideUpAnimation;
  late Animation<double> _fanAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  final int cardCount = 30;
  final double cardWidth = 60;
  final double cardHeight = 84;  // Maintaining 1:1.4 ratio (5:7)
  
  double _dragStartX = 0;
  double _currentRotation = 0;
  int _selectedIndex = 15; // Center card selected by default
  int? _animatingToIndex; // Track which card is being animated to
  
  // GlobalKeys to track card positions
  late List<GlobalKey> _cardKeys;
  
  // Random card mappings - each deck position maps to a tarot card
  late List<int> _cardMappings;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize card keys
    _cardKeys = List.generate(cardCount, (index) => GlobalKey());
    
    // Initialize card mappings with random tarot cards (0-21 for Major Arcana)
    _initializeCardMappings();
    
    // Slide up animation
    _slideUpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideUpAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideUpController,
      curve: Curves.easeOutCubic,
    ));
    
    // Fan animation
    _fanController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fanController,
      curve: Curves.easeOutBack,
    ));
    
    // Rotation animation for drag gestures
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Initialize with current rotation
    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.fastOutSlowIn,
    ));
    
    // Scale animation for clicked cards
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _startAnimations();
  }
  
  void _startAnimations() async {
    await _slideUpController.forward();
    await _fanController.forward();
  }
  
  void _initializeCardMappings() {
    final random = Random();
    // Generate random card indices from 0-21 (22 Major Arcana cards)
    _cardMappings = List.generate(cardCount, (index) => random.nextInt(22));
  }
  
  @override
  void dispose() {
    _slideUpController.dispose();
    _fanController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_slideUpAnimation, _fanAnimation, _rotationAnimation, _scaleAnimation]),
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
              // Clear any animation state when dragging
              setState(() {
                _animatingToIndex = null;
              });
              // Snap to nearest card
              final velocity = details.velocity.pixelsPerSecond.dx;
              _animateToNearestCard(velocity);
            },
            child: Container(
              height: cardHeight * 2.5,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ...List.generate(cardCount, (index) {
                    return _buildCard(index, screenWidth);
                  }),
                  // Swipe indicator
                  Positioned(
                    bottom: -20,
                    left: 0,
                    right: 0,
                    child: _buildSwipeIndicator(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCard(int index, double screenWidth) {
    final fanProgress = _fanAnimation.value;
    final normalizedIndex = (index - cardCount / 2) / (cardCount / 2);
    
    // Calculate arc position
    final baseAngle = normalizedIndex * math.pi * 0.5; // 90 degree spread
    // Use animated rotation value for smooth movement
    final animatedRotation = _rotationController.isAnimating 
        ? _rotationAnimation.value 
        : _currentRotation;
    final angle = baseAngle + animatedRotation;
    
    // Calculate position on the arc
    final radius = screenWidth * 0.7; // Radius of the arc
    final x = radius * math.sin(angle);
    var y = -radius * math.cos(angle) + radius * 0.8; // Lift cards up
    
    // Check if this is the center card
    final distanceFromCenter = (angle).abs();
    final isCenter = distanceFromCenter < 0.1;
    final scale = 1.0 - (distanceFromCenter * 0.2).clamp(0.0, 0.4);
    
    // Lift center card higher
    if (isCenter) {
      y -= 15; // Lift center card 15 pixels higher
    }
    
    // Calculate z-index (cards in front should be on top)
    final zIndex = (cardCount - distanceFromCenter * 10).round();
    
    // Apply scale animation when this card is being animated to
    double animationScale = scale;
    if (_animatingToIndex == index) {
      animationScale *= _scaleAnimation.value;
    }
    
    return Positioned(
      bottom: 0,
      left: screenWidth / 2 - cardWidth / 2,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..translate(x * fanProgress, y * fanProgress, zIndex.toDouble())
          ..rotateZ(angle * 0.3 * fanProgress)
          ..scale(animationScale * fanProgress),
        child: Opacity(
          opacity: (0.3 + fanProgress * 0.7).clamp(0.0, 1.0),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              
              if (isCenter && _selectedIndex == index) {
                // If already centered and clicked again, trigger selection
                HapticFeedback.mediumImpact();
                final RenderBox? renderBox = _cardKeys[index].currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final position = renderBox.localToGlobal(Offset.zero);
                  final size = renderBox.size;
                  // Pass the actual tarot card index from mappings
                  widget.onCardSelected(_cardMappings[index], position, size);
                }
              } else {
                // Always animate to clicked card
                _animateToCard(index);
              }
            },
            child: Container(
              key: _cardKeys[index],
              child: Hero(
                tag: 'tarot-card-$index',
                child: _buildTarotCard(isCenter, index),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _animateToCard(int index) {
    // Cancel any ongoing animations
    _rotationController.stop();
    _scaleController.stop();
    
    // Set the animating index for scale effect
    setState(() {
      _animatingToIndex = index;
    });
    
    // Trigger scale animation
    _scaleController.forward(from: 0).then((_) {
      _scaleController.reverse();
    });
    
    final targetRotation = -(index - cardCount / 2) / (cardCount / 2) * math.pi * 0.5;
    final rotationDifference = (targetRotation - _currentRotation).abs();
    
    // Faster dynamic duration based on rotation distance
    final duration = Duration(
      milliseconds: (200 + rotationDifference * 100).clamp(200, 400).toInt(),
    );
    
    _rotationController.duration = duration;
    
    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.fastOutSlowIn, // Snappier response
    ));
    
    _rotationController.forward(from: 0).then((_) {
      setState(() {
        _currentRotation = targetRotation;
        _selectedIndex = index;
        _animatingToIndex = null; // Clear animating index
      });
    });
  }
  
  void _animateToNearestCard(double velocity) {
    // Calculate which card should be centered based on current rotation
    final cardAngle = math.pi * 0.5 / cardCount;
    int nearestCardIndex = ((-_currentRotation / cardAngle) + cardCount / 2).round();
    
    // Apply velocity bias for more natural feel
    if (velocity.abs() > 500) {
      nearestCardIndex += velocity > 0 ? -1 : 1;
    }
    
    // Ensure index is within bounds
    nearestCardIndex = nearestCardIndex.clamp(0, cardCount - 1);
    
    _animateToCard(nearestCardIndex);
  }
  
  Widget _buildSwipeIndicator() {
    return AnimatedBuilder(
      animation: _fanAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fanAnimation.value * 0.4,
          child: CustomPaint(
            size: const Size(100, 30),
            painter: SwipeIndicatorPainter(),
          ),
        );
      },
    );
  }
  
  Widget _buildTarotCard(bool isCenter, int index) {
    // Enhanced glow for animating cards
    final isAnimating = _animatingToIndex == index;
    
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (isAnimating) ...[
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.8 * _scaleAnimation.value),
              blurRadius: 30,
              spreadRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.4 * _scaleAnimation.value),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ] else if (isCenter) ...[
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Card background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E3A5F),
                    const Color(0xFF0D1B2A),
                    const Color(0xFF415A77),
                  ],
                ),
              ),
            ),
            
            // Card pattern
            Positioned.fill(
              child: CustomPaint(
                painter: TarotCardBackPainter(
                  isHighlighted: isCenter,
                ),
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
                  width: isCenter ? 2 : 1,
                ),
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
        center.dy + size.width * 0.25 * math.sin(angle),
      );
      _drawStar(canvas, starPos, size.width * 0.08, paint);
    }
    
    // Draw border pattern
    final borderRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.05,
      size.width * 0.8,
      size.height * 0.9,
    );
    paint.strokeWidth = 1.0;
    canvas.drawRect(borderRect, paint);
    
    // Inner border
    final innerRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.08,
      size.width * 0.7,
      size.height * 0.84,
    );
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

class SwipeIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Left arrow
    final leftPath = Path();
    leftPath.moveTo(centerX - 30, centerY);
    leftPath.quadraticBezierTo(
      centerX - 40, centerY - 5,
      centerX - 45, centerY - 10,
    );
    leftPath.moveTo(centerX - 30, centerY);
    leftPath.quadraticBezierTo(
      centerX - 40, centerY + 5,
      centerX - 45, centerY + 10,
    );
    
    // Right arrow
    final rightPath = Path();
    rightPath.moveTo(centerX + 30, centerY);
    rightPath.quadraticBezierTo(
      centerX + 40, centerY - 5,
      centerX + 45, centerY - 10,
    );
    rightPath.moveTo(centerX + 30, centerY);
    rightPath.quadraticBezierTo(
      centerX + 40, centerY + 5,
      centerX + 45, centerY + 10,
    );
    
    // Draw curved lines
    final curvePath = Path();
    curvePath.moveTo(centerX - 25, centerY);
    curvePath.quadraticBezierTo(
      centerX, centerY - 5,
      centerX + 25, centerY,
    );
    
    canvas.drawPath(leftPath, paint);
    canvas.drawPath(rightPath, paint);
    canvas.drawPath(curvePath, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}