import 'package:flutter/material.dart';
import '../../../../../shared/components/toss_button.dart';
import 'dart:math' as dart_math;

class TarotLoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;

  const TarotLoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.loadingText,
  });

  @override
  State<TarotLoadingButton> createState() => _TarotLoadingButtonState();
}

class _TarotLoadingButtonState extends State<TarotLoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant TarotLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading && !oldWidget.isLoading) {
      _animationController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isLoading ? _scaleAnimation.value : 1.0,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isLoading 
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF3182F6),
                foregroundColor: Colors.white,
                elevation: widget.isLoading ? 0 : 2,
                shadowColor: const Color(0xFF3182F6).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.isLoading 
                    ? _buildLoadingContent()
                    : _buildNormalContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNormalContent() {
    return Row(
      key: const ValueKey('normal'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          widget.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: _rotationAnimation.value * 2.0 * 3.14159,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CustomPaint(
              painter: _LoadingSpinnerPainter(
                progress: _rotationAnimation.value,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.loadingText ?? '카드를 뽑는 중...',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _LoadingSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingSpinnerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // 회전하는 호 그리기
    final startAngle = progress * 2 * 3.14159;
    const sweepAngle = 3.14159; // 반원

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 특별한 타로 스타일 로딩 버튼 (미스티컬한 효과)
class MysticalTarotLoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;

  const MysticalTarotLoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.loadingText,
  });

  @override
  State<MysticalTarotLoadingButton> createState() => _MysticalTarotLoadingButtonState();
}

class _MysticalTarotLoadingButtonState extends State<MysticalTarotLoadingButton>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isLoading) {
      _glowController.repeat(reverse: true);
      _particleController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant MysticalTarotLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading && !oldWidget.isLoading) {
      _glowController.repeat(reverse: true);
      _particleController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _glowController.stop();
      _particleController.stop();
      _glowController.reset();
      _particleController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _particleController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: widget.isLoading
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(_glowAnimation.value * 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isLoading 
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFF3182F6),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 파티클 효과 (로딩 중에만)
                if (widget.isLoading)
                  CustomPaint(
                    painter: _ParticleEffectPainter(
                      progress: _particleController.value,
                    ),
                    size: const Size(double.infinity, 56),
                  ),
                
                // 버튼 텍스트/아이콘
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.isLoading 
                      ? _buildMysticalLoadingContent()
                      : _buildMysticalNormalContent(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMysticalNormalContent() {
    return Row(
      key: const ValueKey('normal'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          widget.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMysticalLoadingContent() {
    return Row(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 회전하는 신비로운 심볼
        Transform.rotate(
          angle: _particleController.value * 2.0 * 3.14159,
          child: Container(
            width: 20,
            height: 20,
            child: CustomPaint(
              painter: _MysticalSymbolPainter(
                opacity: _glowAnimation.value,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.loadingText ?? '신비로운 메시지를 받는 중...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(_glowAnimation.value),
          ),
        ),
      ],
    );
  }
}

// 파티클 효과 페인터
class _ParticleEffectPainter extends CustomPainter {
  final double progress;

  _ParticleEffectPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // 작은 별들을 그리기
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * 3.14159 + progress * 2 * 3.14159;
      final radius = 15 + (i % 3) * 5;
      
      final x = size.width / 2 + radius * (angle.cos());
      final y = size.height / 2 + radius * (angle.sin()) * 0.3;
      
      canvas.drawCircle(
        Offset(x, y),
        1 + (progress * 2).abs(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 신비로운 심볼 페인터
class _MysticalSymbolPainter extends CustomPainter {
  final double opacity;

  _MysticalSymbolPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // 육각별 그리기
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      final x = center.dx + radius * (angle.cos());
      final y = center.dy + radius * (angle.sin());
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 중앙 원
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Math extensions
extension on double {
  double cos() => dart_math.cos(this);
  double sin() => dart_math.sin(this);
}