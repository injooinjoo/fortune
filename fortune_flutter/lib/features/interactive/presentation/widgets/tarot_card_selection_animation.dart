import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class TarotCardSelectionAnimation extends StatefulWidget {
  final int selectedIndex;
  final int totalCards;
  final String cardImagePath;
  final VoidCallback onAnimationComplete;
  final double cardWidth;
  final double cardHeight;

  const TarotCardSelectionAnimation({
    Key? key,
    required this.selectedIndex,
    required this.totalCards,
    required this.cardImagePath,
    required this.onAnimationComplete,
    this.cardWidth = 200,
    this.cardHeight = 350,
  }) : super(key: key);

  @override
  State<TarotCardSelectionAnimation> createState() => _TarotCardSelectionAnimationState();
}

class _TarotCardSelectionAnimationState extends State<TarotCardSelectionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pickController;
  late AnimationController _flipController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  
  late Animation<double> _pickAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    
    // Card pick animation
    _pickController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Card flip animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Other cards fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Set up animations
    _pickAnimation = CurvedAnimation(
      parent: _pickController,
      curve: Curves.easeOutBack,
    );
    
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pickController,
      curve: Curves.easeOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(_glowController);
    
    // Add listener for flip timing
    _flipAnimation.addStatusListener((status) {
      if (status == AnimationStatus.forward && _flipAnimation.value > 0.5) {
        setState(() {
          _showFront = true;
        });
      }
    });
    
    // Start animations
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    // Start fade animation for other cards
    _fadeController.forward();
    
    // Start pick animation
    await _pickController.forward();
    
    // Start flip animation
    await _flipController.forward();
    
    // Notify completion
    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    _pickController.dispose();
    _flipController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background darkening
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Container(
              color: Colors.black.withValues(alpha: _fadeAnimation.value * 0.7),
            );
          },
        ),
        
        // Other cards fading out
        ..._buildOtherCards(),
        
        // Selected card
        AnimatedBuilder(
          animation: Listenable.merge([
            _pickAnimation,
            _flipAnimation,
            _scaleAnimation,
            _glowAnimation,
          ]),
          builder: (context, child) {
            final pickOffset = _pickAnimation.value * -100;
            final flipAngle = _flipAnimation.value * math.pi;
            
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(0.0, pickOffset)
                ..scale(_scaleAnimation.value)
                ..setEntry(3, 2, 0.001)
                ..rotateY(flipAngle),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  if (_flipAnimation.value > 0.5)
                    Container(
                      width: widget.cardWidth * 1.3,
                      height: widget.cardHeight * 1.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: _glowAnimation.value),
                            blurRadius: 40,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  
                  // Card
                  GestureDetector(
                    onTap: () {}, // Prevent interaction during animation
                    child: _buildCard(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildOtherCards() {
    return List.generate(widget.totalCards, (index) {
      if (index == widget.selectedIndex) return const SizedBox.shrink();
      
      final offset = (index - widget.selectedIndex) * 30.0;
      
      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(offset * (1 - _fadeAnimation.value), 0),
            child: Opacity(
              opacity: 1 - _fadeAnimation.value,
              child: Container(
                width: widget.cardWidth * 0.8,
                height: widget.cardHeight * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCard() {
    final isFlipped = _flipAnimation.value > 0.5;
    
    return Container(
      width: widget.cardWidth,
      height: widget.cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Card content
            if (!_showFront) 
              _buildCardBack()
            else
              _buildCardFront(),
            
            // Shimmer effect during flip
            if (_flipAnimation.value > 0.3 && _flipAnimation.value < 0.7)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0),
                      ],
                      transform: GradientRotation(_flipAnimation.value * math.pi),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Mandala pattern
          Positioned.fill(
            child: CustomPaint(
              painter: AnimatedMandalaPainter(
                color: Colors.white.withValues(alpha: 0.2),
                progress: _pickAnimation.value,
              ),
            ),
          ),
          
          // Center icon
          Center(
            child: Icon(
              Icons.auto_awesome,
              size: 60,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    return Image.asset(
      widget.cardImagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Theme.of(context).primaryColor,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class AnimatedMandalaPainter extends CustomPainter {
  final Color color;
  final double progress;

  AnimatedMandalaPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.4;

    // Animated concentric circles
    for (int i = 1; i <= 4; i++) {
      final radius = maxRadius * i / 4 * progress;
      canvas.drawCircle(center, radius, paint);
    }

    // Animated radial lines
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final lineLength = maxRadius * progress;
      final start = Offset(
        center.dx + lineLength * 0.3 * math.cos(angle),
        center.dy + lineLength * 0.3 * math.sin(angle),
      );
      final end = Offset(
        center.dx + lineLength * math.cos(angle),
        center.dy + lineLength * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }

    // Center star
    if (progress > 0.5) {
      final starPaint = Paint()
        ..color = color.withValues(alpha: (progress - 0.5) * 2)
        ..style = PaintingStyle.fill;
      
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final angle = -math.pi / 2 + (i * 2 * math.pi / 5);
        final x = center.dx + 30 * math.cos(angle) * progress;
        final y = center.dy + 30 * math.sin(angle) * progress;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}