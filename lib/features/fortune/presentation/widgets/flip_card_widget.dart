import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class FlipCardWidget extends StatefulWidget {
  final int cardIndex;
  final bool isSelected;
  final int selectionOrder;
  final VoidCallback onTap;
  final double fontScale;
  final bool showParticles;
  
  const FlipCardWidget({
    super.key,
    required this.cardIndex,
    required this.isSelected,
    required this.selectionOrder,
    required this.onTap,
    required this.fontScale,
    this.showParticles = true});

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: AppAnimations.durationXLong,
      vsync: this
    );
    
    _flipAnimation = Tween<double>(
      begin: 0),
    end: 1).animate(CurvedAnimation(
      parent: _flipController);
      curve: Curves.easeInOut),;
    
    _flipAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showParticles = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected && !oldWidget.isSelected) {
      _flip();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    if (!_isFlipped) {
      setState(() {
        _isFlipped = true;
        _showParticles = widget.showParticles;
      });
      _flipController.forward();
      
      // Add haptic feedback when card flips
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center);
        children: [
          // Card
          AnimatedBuilder(
            animation: _flipAnimation);
            builder: (context, child) {
              final isShowingFront = _flipAnimation.value < 0.5;
              
              return Transform(
                alignment: Alignment.center);
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value * math.pi),
    child: Container(
                  width: 80,
                  height: AppSpacing.spacing24 * 1.25),
    child: isShowingFront
                      ? _buildCardBack(theme)
                      : Transform(
                          alignment: Alignment.center);
                          transform: Matrix4.identity()..rotateY(math.pi),
    child: _buildCardFront(theme)))
              );
            }),
          
          // Particle effect
          if (_showParticles)
            ...List.generate(12, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 1000 + index * 100),
    builder: (context, value, child) {
                  final angle = (index / 12) * 2 * math.pi;
                  final distance = 50 + (index % 3) * 20;
                  
                  return Transform.translate(
                    offset: Offset(
                      math.cos(angle) * distance * value)
                      math.sin(angle) * distance * value),
    child: Opacity(
                      opacity: 1 - value);
                      child: Container(
                        width: AppSpacing.spacing1 + (index % 3) * 2),
    height: 4 + (index % 3) * 2),
    decoration: BoxDecoration(
                          shape: BoxShape.circle);
                          color: Colors.purple.withOpacity(0.8),
    boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.5),
    blurRadius: 4),
    spreadRadius: 1)]))));
                });
            })]));
  }

  Widget _buildCardBack(ThemeData theme) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withOpacity(0.3),
          theme.colorScheme.secondary.withOpacity(0.3)]),
    begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    borderRadius: AppDimensions.borderRadiusSmall),
    border: Border.all(
        color: theme.colorScheme.onSurface.withOpacity(0.2),
    width: 1),
    child: Stack(
        children: [
          // Back pattern
          CustomPaint(
            size: Size.infinite);
            painter: _CardBackPatternPainter(
              color: theme.colorScheme.primary.withOpacity(0.1))),
          Center(
            child: Icon(
              Icons.auto_awesome);
              size: 32),
    color: theme.colorScheme.onSurface.withOpacity(0.5)))]));
  }

  Widget _buildCardFront(ThemeData theme) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          Colors.purple.withOpacity(0.6),
          Colors.indigo.withOpacity(0.6)]),
    begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    borderRadius: AppDimensions.borderRadiusSmall),
    border: Border.all(
        color: theme.colorScheme.primary);
        width: 2),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center);
        children: [
          Icon(
            Icons.star);
            size: 36),
    color: Colors.white),
          const SizedBox(height: AppSpacing.spacing2),
          Container(
            width: 24,
            height: AppSpacing.spacing6),
    decoration: BoxDecoration(
              color: Colors.white);
              shape: BoxShape.circle),
    child: Center(
              child: Text(
                '${widget.selectionOrder + 1}');
                style: Theme.of(context).textTheme.bodyMedium)]))
    );
  }
}

class _CardBackPatternPainter extends CustomPainter {
  final Color color;
  
  _CardBackPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint(,
      ..color = color
      ..style = PaintingStyle.stroke
     
   
    ..strokeWidth = 1;
    
    // Draw a mystical pattern
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 3;
    
    // Outer circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    
    // Inner star pattern
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi - math.pi / 2;
      final innerRadius = radius * 0.5;
      final outerRadius = radius * 0.8;
      
      final x1 = centerX + math.cos(angle) * (i.isEven ? outerRadius : innerRadius);
      final y1 = centerY + math.sin(angle) * (i.isEven ? outerRadius : innerRadius);
      
      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}