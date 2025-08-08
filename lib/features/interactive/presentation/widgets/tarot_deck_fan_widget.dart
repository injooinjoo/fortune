import 'package:flutter/material.dart';
import 'dart:math' as math;

class TarotDeckFanWidget extends StatefulWidget {
  final int cardCount;
  final double cardWidth;
  final double cardHeight;
  final Function(int) onCardTap;
  final ScrollController? scrollController;
  final int? selectedIndex;

  const TarotDeckFanWidget({
    Key? key,
    this.cardCount = 22, // Major Arcana
    this.cardWidth = 120,
    this.cardHeight = 200,
    required this.onCardTap,
    this.scrollController,
    this.selectedIndex}) : super(key: key);

  @override
  State<TarotDeckFanWidget> createState() => _TarotDeckFanWidgetState();
}

class _TarotDeckFanWidgetState extends State<TarotDeckFanWidget>
    with TickerProviderStateMixin {
  late AnimationController _fanController;
  late AnimationController _floatController;
  late List<Animation<double>> _fanAnimations;
  late ScrollController _scrollController;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    
    // Fan out animation
    _fanController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this);

    // Floating animation for hovered card
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this)..repeat(reverse: true);

    // Create staggered animations for each card
    _fanAnimations = List.generate(widget.cardCount, (index) {
      final delay = index / widget.cardCount;
      return Tween<double>(
        begin: 0.0,
        end: 1.0).animate(
        CurvedAnimation(
          parent: _fanController,
          curve: Interval(
            delay * 0.5,
            0.5 + delay * 0.5,
            curve: Curves.easeOutBack)));
    });

    // Start fan animation
    _fanController.forward();

    // Listen to scroll changes
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _fanController.dispose();
    _floatController.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final cardSpacing = widget.cardWidth * 0.8;
    final centerIndex = (scrollOffset / cardSpacing).round();
    
    if (centerIndex != _hoveredIndex && centerIndex >= 0 && centerIndex < widget.cardCount) {
      setState(() {
        _hoveredIndex = centerIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.cardHeight * 1.3,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.cardCount,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: Listenable.merge([_fanAnimations[index], _floatController]),
            builder: (context, child) {
              final fanProgress = _fanAnimations[index].value;
              final isHovered = index == _hoveredIndex;
              final isSelected = index == widget.selectedIndex;
              
              // Calculate position and rotation
              final baseAngle = -15.0 + (index / (widget.cardCount - 1)) * 30.0;
              final angle = baseAngle * fanProgress * math.pi / 180;
              
              // Vertical offset for hovered card
              final floatOffset = isHovered ? _floatController.value * 20 - 10 : 0.0;
              final scaleBoost = isHovered ? 0.1 : 0.0;
              
              return GestureDetector(
                onTap: () => widget.onCardTap(index),
                child: Container(
                  width: widget.cardWidth * 0.8,
                  alignment: Alignment.center,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..translate(0.0, -floatOffset + (1 - fanProgress) * 100)
                      ..rotateZ(angle)
                      ..scale(0.9 + scaleBoost + fanProgress * 0.1),
                    child: Opacity(
                      opacity: 0.5 + fanProgress * 0.5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Card shadow
                          if (isHovered)
                            Container(
                              width: widget.cardWidth,
                              height: widget.cardHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5)])),
                          
                          // Card back
                          _buildCardBack(context, index, isHovered, isSelected)])))));
            });
        }));
  }

  Widget _buildCardBack(BuildContext context, int index, bool isHovered, bool isSelected) {
    return Container(
      width: widget.cardWidth,
      height: widget.cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
            Theme.of(context).primaryColor.withValues(alpha: 0.6),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8)]),
        border: Border.all(
          color: isHovered 
              ? Theme.of(context).colorScheme.secondary 
              : Colors.white.withValues(alpha: 0.3),
          width: isHovered ? 3 : 2)),
      child: Stack(
        children: [
          // Mandala pattern
          Positioned.fill(
            child: CustomPaint(
              painter: MandalaPainter(
                color: Colors.white.withValues(alpha: 0.1),
                isAnimated: isHovered))),
          
          // Center symbol
          Center(
            child: Icon(
              Icons.auto_awesome,
              size: 40,
              color: Colors.white.withValues(alpha: isHovered ? 0.9 : 0.7)))]));
  }
}

class MandalaPainter extends CustomPainter {
  final Color color;
  final bool isAnimated;

  MandalaPainter({required this.color, this.isAnimated = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
     
   
    ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, paint);
    }

    // Draw radial lines
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final start = Offset(
        center.dx + radius * 0.3 * math.cos(angle),
        center.dy + radius * 0.3 * math.sin(angle));
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle));
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => isAnimated;
}