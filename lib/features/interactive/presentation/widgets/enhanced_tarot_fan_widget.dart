import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class EnhancedTarotFanWidget extends StatefulWidget {
  final String fortuneType;
  final Color primaryColor;
  final Function(int) onCardSelected;
  
  const EnhancedTarotFanWidget({
    Key? key,
    required this.fortuneType,
    required this.primaryColor,
    required this.onCardSelected}) : super(key: key);

  @override
  State<EnhancedTarotFanWidget> createState() => _EnhancedTarotFanWidgetState();
}

class _EnhancedTarotFanWidgetState extends State<EnhancedTarotFanWidget>
    with TickerProviderStateMixin {
  late AnimationController _gatherController;
  late AnimationController _fanController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  
  late List<Animation<Offset>> _gatherAnimations;
  late List<Animation<double>> _scaleAnimations;
  late Animation<double> _fanAnimation;
  
  final int cardCount = 12;
  final double cardWidth = 100;
  final double cardHeight = 160;
  
  PageController? _pageController;
  double _currentPage = 6.0; // Start at center
  int _centerIndex = 6;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize page controller with center page
    _pageController = PageController(
      initialPage: 6,
      viewportFraction: 0.3);
    
    // Gathering animation controller
    _gatherController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this);
    
    // Fan out animation controller
    _fanController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this);
    
    // Floating animation for center card
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this)..repeat(reverse: true);
    
    // Rotation animation for circular scroll effect
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this);
    
    // Create gathering animations from different screen positions
    _gatherAnimations = List.generate(cardCount, (index) {
      // Random starting positions around screen edges
      final angle = (index / cardCount) * 2 * math.pi;
      final startX = math.cos(angle) * 2.0;
      final startY = math.sin(angle) * 2.0;
      
      return Tween<Offset>(
        begin: Offset(startX, startY),
        end: Offset.zero).animate(CurvedAnimation(
        parent: _gatherController,
        curve: Interval(
          index / cardCount * 0.5,
          0.5 + index / cardCount * 0.5,
          curve: Curves.easeOutBack)));
    });
    
    // Scale animations during gathering
    _scaleAnimations = List.generate(cardCount, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0).animate(CurvedAnimation(
        parent: _gatherController,
        curve: Interval(
          index / cardCount * 0.5,
          0.5 + index / cardCount * 0.5,
          curve: Curves.easeOutBack)));
    });
    
    // Fan animation
    _fanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _fanController,
      curve: Curves.easeOutBack));
    
    // Start animations sequence
    _startAnimationSequence();
    
    // Listen to page changes
    _pageController!.addListener(() {
      setState(() {
        _currentPage = _pageController!.page ?? 0;
        _centerIndex = _currentPage.round() % cardCount;
      });
    });
  }
  
  void _startAnimationSequence() async {
    // First gather cards
    await _gatherController.forward();
    // Then fan them out
    await _fanController.forward();
  }
  
  @override
  void dispose() {
    _gatherController.dispose();
    _fanController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    _pageController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Fortune type title
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  widget.fortuneType,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Choose your card',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.7)))
              ]))
          
          // Card fan
          Positioned(
            top: screenSize.height * 0.25,
            left: 0,
            right: 0,
            // Removed bottom constraint to avoid assertion error
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _gatherController,
                _fanController,
                _floatController
              ]),
              builder: (context, child) {
                return PageView.builder(
                  controller: _pageController,
                  itemCount: cardCount * 100, // Large number for infinite scroll
                  onPageChanged: (index) {
                    HapticFeedback.selectionClick();
                  },
                  itemBuilder: (context, index) {
                    final cardIndex = index % cardCount;
                    final isCenter = cardIndex == _centerIndex;
                    
                    // Calculate position offset from center
                    final pageOffset = (_currentPage - index).abs();
                    final rotation = pageOffset * 0.1;
                    final scale = 1.0 - (pageOffset * 0.15).clamp(0.0, 0.5);
                    
                    // Elevation for center card
                    final elevation = isCenter ? 30.0 : 0.0;
                    final floatOffset = isCenter 
                        ? _floatController.value * 15.0 
                        : 0.0;
                    
                    return AnimatedBuilder(
                      animation: _gatherAnimations[cardIndex],
                      builder: (context, child) {
                        final gatherProgress = _gatherController.value;
                        final fanProgress = _fanAnimation.value;
                        
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..translate(
                              _gatherAnimations[cardIndex].value.dx * screenSize.width * (1 - gatherProgress),
                              _gatherAnimations[cardIndex].value.dy * screenSize.height * (1 - gatherProgress) - elevation - floatOffset,
                              0)
                            ..rotateY(rotation * fanProgress)
                            ..scale(scale * _scaleAnimations[cardIndex].value, scale * _scaleAnimations[cardIndex].value),
                          child: GestureDetector(
                            onTap: () {
                              if (isCenter) {
                                HapticFeedback.mediumImpact();
                                widget.onCardSelected(cardIndex);
                              } else {
                                // Scroll to tapped card
                                _pageController!.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                              }
                            },
                            child: _buildCard(
                              cardIndex,
                              isCenter,
                              _scaleAnimations[cardIndex].value)));
                      });
                  }
                );
              })),
          
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context)
            ))
        ]));
  }
  
  Widget _buildCard(int index, bool isCenter, double scale) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isCenter ? [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 10)
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5))
        ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Card background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCenter ? [
                    widget.primaryColor,
                    widget.primaryColor.withOpacity(0.7)
                  ] : [
                    const Color(0xFF2C1810),
                    const Color(0xFF1A0F08)
                  ])),
            
            // Card pattern
            Positioned.fill(
              child: CustomPaint(
                painter: CardPatternPainter(
                  color: isCenter 
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  isAnimated: isCenter)
              )),
            
            // Card border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCenter 
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                  width: isCenter ? 3 : 1)
              )),
            
            // Center icon
            if (scale > 0.5)
              Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 40 * scale,
                  color: Colors.white.withOpacity(isCenter ? 0.9 : 0.5)
                ))
          ]))
    );
  }
}

class CardPatternPainter extends CustomPainter {
  final Color color;
  final bool isAnimated;
  
  CardPatternPainter({
    required this.color,
    this.isAnimated = false});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw mystical pattern
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final radius = size.width * 0.3;
      
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle));
      
      canvas.drawLine(center, point, paint);
      
      // Draw small circles at endpoints
      canvas.drawCircle(point, 4, paint..style = PaintingStyle.fill);
      paint..style = PaintingStyle.stroke;
    }
    
    // Draw center circle
    canvas.drawCircle(center, size.width * 0.15, paint);
    canvas.drawCircle(center, size.width * 0.25, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => isAnimated;
}