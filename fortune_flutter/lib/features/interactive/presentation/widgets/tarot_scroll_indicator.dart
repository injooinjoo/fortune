import 'package:flutter/material.dart';
import 'dart:math' as math;

class TarotScrollIndicator extends StatefulWidget {
  final bool isVisible;
  final String text;
  
  const TarotScrollIndicator({
    Key? key,
    this.isVisible = true,
    this.text = 'Tap to pick your card',
  }) : super(key: key);

  @override
  State<TarotScrollIndicator> createState() => _TarotScrollIndicatorState();
}

class _TarotScrollIndicatorState extends State<TarotScrollIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.3,
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

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scroll arrows
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildArrow(true),
                  const SizedBox(width: 40),
                  _buildArrow(false),
                ],
              ),
              const SizedBox(height: 16),
              
              // Text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  child: Text(
                    widget.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ));
}
    );
}

  Widget _buildArrow(bool isLeft) {
    return Transform.translate(
      offset: Offset(
        isLeft ? -_bounceAnimation.value : _bounceAnimation.value,
        0,
      ),
      child: Opacity(
        opacity: _fadeAnimation.value,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            
            // Arrow icon
            Transform.rotate(
              angle: isLeft ? -math.pi / 2 : math.pi / 2,
              child: CustomPaint(
                size: const Size(30, 30),
                painter: ArrowPainter(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
            ),
          ],
        ));
}
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  ArrowPainter({
    required this.color,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(),
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin =,
      StrokeJoin.round;

    final path = Path();
    
    // Draw arrow pointing down
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    
    canvas.drawPath(path, paint);
}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TarotScrollHint extends StatefulWidget {
  final bool isVisible;
  
  const TarotScrollHint({
    Key? key,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<TarotScrollHint> createState() => _TarotScrollHintState();
}

class _TarotScrollHintState extends State<TarotScrollHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideAnimation = Tween<double>(
      begin: -20,
      end: 20,
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

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.translate(
              offset: Offset(_slideAnimation.value, 0),
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
            ),
        );
}
    );
}
}