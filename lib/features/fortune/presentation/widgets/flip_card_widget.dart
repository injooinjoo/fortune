import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/fortune_haptic_service.dart';

class FlipCardWidget extends ConsumerStatefulWidget {
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
    this.showParticles = true,
  });

  @override
  ConsumerState<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends ConsumerState<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  bool _showParticles = false;
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: DSAnimation.durationXLong,
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 50% 지점에서 mysticalReveal 햅틱 트리거
    _flipAnimation.addListener(() {
      if (_flipAnimation.value >= 0.5 && !_hapticTriggered && _isFlipped) {
        _hapticTriggered = true;
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });

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
        _hapticTriggered = false; // 햅틱 트리거 리셋
      });
      _flipController.forward();
      // mysticalReveal 햅틱은 애니메이션 50% 지점에서 자동 트리거됨
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card
          AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final isShowingFront = _flipAnimation.value < 0.5;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value * math.pi),
                child: SizedBox(
                  width: 80,
                  height: 96 * 1.25,
                  child: isShowingFront
                      ? _buildCardBack(theme)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildCardFront(theme),
                        ),
                ),
              );
            },
          ),

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
                      math.cos(angle) * distance * value,
                      math.sin(angle) * distance * value,
                    ),
                    child: Opacity(
                      opacity: 1 - value,
                      child: Container(
                        width: 4 + (index % 3) * 2,
                        height: 4 + (index % 3) * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DSColors.accentSecondary.withValues(alpha: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: DSColors.accentSecondary.withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCardBack(ThemeData theme) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.3),
          theme.colorScheme.secondary.withValues(alpha: 0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(DSRadius.sm),
      border: Border.all(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        width: 1,
      ),
      child: Stack(
        children: [
          // Back pattern
          CustomPaint(
            size: Size.infinite,
            painter: _CardBackPatternPainter(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          Center(
            child: Icon(
              Icons.auto_awesome,
              size: 32,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(ThemeData theme) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          DSColors.accentSecondary.withValues(alpha: 0.6),
          DSColors.accent.withValues(alpha: 0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(DSRadius.sm),
      border: Border.all(
        color: theme.colorScheme.primary,
        width: 2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            size: 36,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.selectionOrder + 1}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBackPatternPainter extends CustomPainter {
  final Color color;

  _CardBackPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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