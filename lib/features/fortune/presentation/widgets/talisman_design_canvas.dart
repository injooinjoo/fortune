import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../domain/models/talisman_models.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import '../../../../core/theme/toss_design_system.dart';

class TalismanDesignCanvas extends StatefulWidget {
  final TalismanResult result;
  final double size;

  const TalismanDesignCanvas({
    super.key,
    required this.result,
    this.size = 300});

  @override
  State<TalismanDesignCanvas> createState() => _TalismanDesignCanvasState();
}

class _TalismanDesignCanvasState extends State<TalismanDesignCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20))..repeat();
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
      height: widget.size * 1.2, // Slightly taller for traditional talisman shape,
    decoration: BoxDecoration(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.result.design.primaryColor.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.result.design.primaryColor.withValues(alpha: 0.8),
                    widget.result.design.secondaryColor.withValues(alpha: 0.6)])),
            
            // Traditional paper texture overlay
            Container(
              decoration: BoxDecoration(
                color: TossDesignSystem.white.withValues(alpha: 0.4)),
              child: CustomPaint(
                painter: _TalismanPaperTexturePainter(),
                size: Size(widget.size, widget.size * 1.2)),
            
            // Main content
            Padding(
              padding: EdgeInsets.all(widget.size * 0.08),
              child: Column(
                children: [
                  // Top decoration
                  _buildTopDecoration(),
                  
                  const Spacer(),
                  
                  // Central symbol area
                  _buildCentralSymbol(),
                  
                  const Spacer(),
                  
                  // User info and wish
                  _buildUserInfo(),
                  
                  const SizedBox(height: AppSpacing.spacing5),
                  
                  // Date and seal
                  _buildBottomSeal()]),
            
            // Mystical overlay effects
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MysticalEffectsPainter(
                    progress: _animationController.value,
                    color: widget.result.design.primaryColor),
                  size: Size(widget.size, widget.size * 1.2));
              })])));
  }
  
  Widget _buildTopDecoration() {
    return Column(
      children: [
        Text(
          '護身符',
          style: TextStyle(
            fontSize: widget.size * 0.08,
            fontWeight: FontWeight.bold,
            color: TossDesignSystem.white,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing1),
        Container(
          width: widget.size * 0.5,
          height: 4 * 0.5,
          color: TossDesignSystem.white.withValues(alpha: 0.6),
        ),
      ],
    );
  }
  
  Widget _buildCentralSymbol() {
    return Container(
      width: widget.size * 0.5,
      height: widget.size * 0.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: TossDesignSystem.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: widget.result.design.primaryColor.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5)]),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring with symbols
          CustomPaint(
            painter: _TalismanSymbolPainter(
              primaryColor: widget.result.design.primaryColor,
              secondaryColor: widget.result.design.secondaryColor),
            size: Size(widget.size * 0.5, widget.size * 0.5)),
          
          // Center icon
          Container(
            width: widget.size * 0.25,
            height: widget.size * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  widget.result.design.primaryColor,
                  widget.result.design.secondaryColor])),
            child: Icon(
              widget.result.type.icon,
              size: widget.size * 0.15,
              color: TossDesignSystem.white)]).animate(onPlay: (controller) => controller.repeat(),
      .rotate(duration: const Duration(milliseconds: 20000),;
  }
  
  Widget _buildUserInfo() {
    return Column(
      children: [
        if (widget.result.design.personalText?.isNotEmpty ?? false) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
            decoration: BoxDecoration(
              color: TossDesignSystem.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20)),
            child: Text(
              widget.result.design.personalText!,
              style: TextStyle(
                fontSize: widget.size * 0.045,
                fontWeight: FontWeight.w600,
                color: widget.result.design.primaryColor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis)),
          const SizedBox(height: AppSpacing.spacing2)],
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5, vertical: AppSpacing.spacing2 * 1.25),
          decoration: BoxDecoration(
            color: TossDesignSystem.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppSpacing.spacing6 * 1.04),
            border: Border.all(
              color: widget.result.design.primaryColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Text(
            widget.result.design.userName ?? '소유자',
            style: TextStyle(
              fontSize: widget.size * 0.06,
              fontWeight: FontWeight.bold,
              color: widget.result.design.primaryColor,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomSeal() {
    final date = widget.result.design.createdDate;
    final dateText = '${date.year}年 ${date.month}月 ${date.day}日';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Date
        Text(
          dateText,
          style: TextStyle(
            fontSize: widget.size * 0.04,
            color: TossDesignSystem.white.withValues(alpha: 0.8),
            letterSpacing: 1)),
        const SizedBox(width: AppSpacing.spacing4),
        // Seal
        Container(
          width: widget.size * 0.1,
          height: widget.size * 0.1,
          decoration: BoxDecoration(
            color: TossDesignSystem.errorRed,
            shape: BoxShape.circle),
          child: Center(
            child: Text(
              '符',),
              style: TextStyle(
                fontSize: widget.size * 0.05,
                color: TossDesignSystem.white,
                fontWeight: FontWeight.bold)))]);
  }
}

class _TalismanPaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TossDesignSystem.gray400.withValues(alpha: 0.05)
      ..strokeWidth = 0.5
     
   
    ..style = PaintingStyle.stroke;

    // Draw vertical lines for paper texture
    for (double x = 0; x < size.width; x += 5) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 5) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TalismanSymbolPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _TalismanSymbolPainter({
    required this.primaryColor,
    required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
     
   
    ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer circle
    canvas.drawCircle(center, radius * 0.9, paint);
    
    // Draw inner patterns
    final symbols = ['☰', '☷', '☵', '☲', '☳', '☴', '☶', '☱'];
    final symbolPaint = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 * 2 / 8;
      final x = center.dx + radius * 0.7 * math.cos(angle);
      final y = center.dy + radius * 0.7 * math.sin(angle);
      
      symbolPaint.text = TextSpan(
        text: symbols[i],
        style: const TextStyle(
          fontSize: 14,
          color: TossDesignSystem.white));
      symbolPaint.layout();
      symbolPaint.paint(
        canvas,
        Offset(x - symbolPaint.width / 2, y - symbolPaint.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MysticalEffectsPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MysticalEffectsPainter({
    required this.progress,
    required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1 * (1 - progress),
      ..style = PaintingStyle.fill;

    // Draw expanding circles for mystical effect
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    canvas.drawCircle(
      center,
      maxRadius * progress,
      paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}