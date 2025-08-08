import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class TarotInterpretationBubble extends StatefulWidget {
  final String interpretation;
  final bool isCurrentCard;
  final double fontScale;
  final VoidCallback? onTap;

  const TarotInterpretationBubble({
    Key? key,
    required this.interpretation,
    required this.isCurrentCard,
    required this.fontScale,
    this.onTap}) : super(key: key);

  @override
  State<TarotInterpretationBubble> createState() => _TarotInterpretationBubbleState();
}

class _TarotInterpretationBubbleState extends State<TarotInterpretationBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _typingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<int> _typingAnimation;
  
  bool _isExpanded = false;
  final int _maxLines = 4;
  String _displayedText = '';
  bool _typingComplete = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this);
    
    _typingController = AnimationController(
      duration: Duration(milliseconds: widget.interpretation.length * 15),
      vsync: this
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack));
    
    _typingAnimation = IntTween(
      begin: 0,
      end: widget.interpretation.length).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut));
    
    _typingAnimation.addListener(() {
      setState(() {
        _displayedText = widget.interpretation.substring(0, _typingAnimation.value);
      });
    });
    
    _typingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _typingComplete = true;
        });
      }
    });
    
    if (widget.isCurrentCard) {
      _animationController.forward().then((_) {
        _typingController.forward();
      });
    } else {
      _animationController.value = 1.0;
      _typingController.value = 1.0;
      _typingComplete = true;
      _displayedText = widget.interpretation;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = (_typingComplete ? widget.interpretation : _displayedText).split('\n\n');
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
            widget.onTap?.call();
          },
          child: Container(
            margin: EdgeInsets.only(
              left: widget.isCurrentCard ? 0 : 40,
              right: widget.isCurrentCard ? 0 : 0),
            child: Stack(
              children: [
                // Main bubble
                GlassContainer(
                  padding: AppSpacing.paddingAll16,
                  gradient: LinearGradient(
                    colors: widget.isCurrentCard
                        ? [
                            Colors.purple.withOpacity(0.3),
                            Colors.indigo.withOpacity(0.3)]
                        : [
                            Colors.grey.withOpacity(0.1),
                            Colors.grey.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                  borderRadius: AppDimensions.borderRadiusLarge,
                  border: Border.all(
                    color: widget.isCurrentCard
                        ? Colors.purple.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                    width: 1),
                  blur: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarot reader avatar and name
                      if (widget.isCurrentCard) Row(
                          children: [
                            Container(
                              width: 32,
                              height: AppSpacing.spacing8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.withOpacity(0.6),
                                    Colors.indigo.withOpacity(0.6)])),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 18)),
                            const SizedBox(width: AppSpacing.spacing2),
                            Text(
                              '타로 마스터',
                              style: Theme.of(context).textTheme.bodyMedium)]),
                      if (widget.isCurrentCard) const SizedBox(height: AppSpacing.spacing3),
                      
                      // Interpretation text with typing effect
                      if (widget.isCurrentCard && !_typingComplete) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _displayedText,
                                style: Theme.of(context).textTheme.bodyMedium)),
                            // Typing cursor
                            AnimatedBuilder(
                              animation: _typingController,
                              builder: (context, child) {
                                return Container(
                                  width: 2,
                                  height: AppSpacing.spacing4 * 1.125,
                                  color: Colors.white.withOpacity((math.sin(_typingController.value * math.pi * 4) + 1) / 2));
                              },
                            ),
                          ]),
                      ] else ...[
                        ...lines.asMap().entries.map((entry) {
                          final index = entry.key;
                          final line = entry.value;
                          
                          if (!_isExpanded && index >= 2) {
                            return const SizedBox.shrink();
                          }
                          
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < lines.length - 1 ? 12 : 0),
                            child: _buildInterpretationLine(line));
                        }).toList(),
                      ],
                      
                      // Show more/less button
                      if (lines.length > 2) Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.spacing2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isExpanded ? '접기' : '더 보기',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500)),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 16,
                                color: Colors.purple.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Speech bubble tail (only for current card)
                if (widget.isCurrentCard) Positioned(
                    top: 40,
                    left: -10,
                    child: CustomPaint(
                      painter: _BubbleTailPainter(
                        color: Colors.purple.withOpacity(0.2)),
                      size: const Size(20, 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
}

  Widget _buildInterpretationLine(String line) {
    // Check if this line contains special formatting
    if (line.startsWith('**') && line.endsWith('**')) {
      // Bold emphasis
      return Text(
        line.replaceAll('**', ''),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold));
    } else if (line.startsWith('- ')) {
      // Bullet point
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: Text(
              line.substring(2),
              style: Theme.of(context).textTheme.bodyMedium)),
        ],
      );
    } else if (line.startsWith('💡') || line.startsWith('⚠️') || line.startsWith('✨')) {
      // Special callout
      final emoji = line.substring(0, 2);
      final text = line.substring(2).trim();
      
      return Container(
        padding: AppSpacing.paddingAll12,
        decoration: BoxDecoration(
          color: _getCalloutColor(emoji).withOpacity(0.1),
          borderRadius: AppDimensions.borderRadiusSmall,
          border: Border.all(
            color: _getCalloutColor(emoji).withOpacity(0.3),
            width: 1)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emoji,
              style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: AppSpacing.spacing2),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      );
    } else {
      // Regular text
      return Text(
        line,
        style: Theme.of(context).textTheme.bodyMedium);
    }
  }

  Color _getCalloutColor(String emoji) {
    switch (emoji) {
      case '💡': return Colors.amber;
      case '⚠️': return Colors.orange;
      case '✨': return Colors.purple;
      default: return Colors.blue;
    }
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;

  _BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.9,
        0,
        size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width,
        0)
      ..close();

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}