import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/talisman_models.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_spacing.dart';

class TalismanPreviewWidget extends StatefulWidget {
  final TalismanType type;
  final Color primaryColor;
  final Color secondaryColor;
  final String symbol;
  final String userName;
  final double size;

  const TalismanPreviewWidget({
    super.key,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    required this.symbol,
    required this.userName,
    this.size = 200,
  });

  @override
  State<TalismanPreviewWidget> createState() => _TalismanPreviewWidgetState();
}

class _TalismanPreviewWidgetState extends State<TalismanPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3))..repeat();
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.primaryColor,
                  widget.secondaryColor,
                ],
              ),
            ),
          ),
          
          // Pattern overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
              color: Colors.black.withValues(alpha: 0.1),
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _TalismanPatternPainter(
                style: widget.symbol,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          
          // Central symbol
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * 3.14159 * 0.1,
                child: Container(
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.type.icon,
                      size: widget.size * 0.3,
                      color: widget.primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // User name at bottom
          Positioned(
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                ],
              ),
              child: Text(
                widget.userName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          
          // Decorative corners
          ..._buildCornerDecorations(),
        ],
      ).animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
}
  
  List<Widget> _buildCornerDecorations() {
    final decorations = <Widget>[];
    final positions = [
      (top: 10.0, left: 10.0, right: null, bottom: null),
      (top: 10.0, left: null, right: 10.0, bottom: null),
      (top: null, left: 10.0, right: null, bottom: 10.0),
      (top: null, left: null, right: 10.0, bottom: 10.0),
    ];
    
    for (final pos in positions) {
      decorations.add(
        Positioned(
          top: pos.top,
          left: pos.left,
          right: pos.right,
          bottom: pos.bottom,
          child: Container(
            width: 30,
            height: AppSpacing.spacing7 * 1.07,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.only(
                topLeft: pos.top != null && pos.left != null 
                    ? const Radius.circular(0) 
                    : const Radius.circular(15),
                topRight: pos.top != null && pos.right != null 
                    ? const Radius.circular(0) 
                    : const Radius.circular(15),
                bottomLeft: pos.bottom != null && pos.left != null 
                    ? const Radius.circular(0) 
                    : const Radius.circular(15),
                bottomRight: pos.bottom != null && pos.right != null 
                    ? const Radius.circular(0) 
                    : const Radius.circular(15),
              ),
            ),
          ),
        ),
      );
    }
    
    return decorations;
}
}

class _TalismanPatternPainter extends CustomPainter {
  final String style;
  final Color color;

  _TalismanPatternPainter({
    required this.style,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
     
   
    ..strokeWidth = 1.5;

    switch (style) {
      case 'classic':
        _drawClassicPattern(canvas, size, paint);
        break;
      case 'modern':
        _drawModernPattern(canvas, size, paint);
        break;
      case 'minimal':
        _drawMinimalPattern(canvas, size, paint);
        break;
      case 'ornate':
        _drawOrnatePattern(canvas, size, paint);
        break;
}
  }

  void _drawClassicPattern(Canvas canvas, Size size, Paint paint) {
    // Draw traditional Korean pattern
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    // Outer circle
    canvas.drawCircle(center, radius, paint);
    
    // Inner patterns
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final x = center.dx + radius * 0.7 * math.cos(angle);
      final y = center.dy + radius * 0.7 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 10, paint);
}
  }

  void _drawModernPattern(Canvas canvas, Size size, Paint paint) {
    // Draw geometric modern pattern
    final path = Path();
    final points = <Offset>[];
    
    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      final x = size.width / 2 + size.width * 0.3 * math.cos(angle);
      final y = size.height / 2 + size.height * 0.3 * math.sin(angle);
      points.add(Offset(x, y);
}
    
    path.addPolygon(points, true);
    canvas.drawPath(path, paint);
}

  void _drawMinimalPattern(Canvas canvas, Size size, Paint paint) {
    // Draw simple lines
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.2),
      paint
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.8),
      paint
    );
}

  void _drawOrnatePattern(Canvas canvas, Size size, Paint paint) {
    // Draw complex ornate pattern
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 3; i++) {
      final radius = size.width * (0.2 + i * 0.1);
      canvas.drawCircle(center, radius, paint);
}
    
    // Draw decorative elements
    for (int i = 0; i < 12; i++) {
      final angle = i * 3.14159 / 6;
      final startRadius = size.width * 0.3;
      final endRadius = size.width * 0.45;
      
      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle));
      final end = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle);
      
      canvas.drawLine(start, end, paint);
}
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}