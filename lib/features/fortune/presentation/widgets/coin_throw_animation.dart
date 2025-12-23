import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/design_system/design_system.dart';

/// 동전 던지기 애니메이션 위젯
class CoinThrowAnimation extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final String wishText;
  final String category;

  const CoinThrowAnimation({
    super.key,
    required this.onAnimationComplete,
    required this.wishText,
    required this.category,
  });

  @override
  State<CoinThrowAnimation> createState() => _CoinThrowAnimationState();
}

class _CoinThrowAnimationState extends State<CoinThrowAnimation>
    with TickerProviderStateMixin {
  late AnimationController _throwController;
  late AnimationController _rotationController;
  late AnimationController _splashController;
  late AnimationController _rippleController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _splashAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _scaleAnimation;

  bool _showSplash = false;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    
    _throwController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    // 동전 회전 애니메이션
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 6.0 * math.pi, // 3번 회전
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // 동전 크기 애니메이션 (멀어질수록 작아짐)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _throwController,
      curve: Curves.easeIn,
    ));
    
    // 물 튀는 애니메이션
    _splashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.easeOut,
    ));
    
    // 물결 애니메이션
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    // 애니메이션 완료 리스너
    _throwController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_showSplash) {
        setState(() {
          _showSplash = true;
        });
        _splashController.forward();
        _rippleController.forward();
      }
    });
    
    _rippleController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_animationCompleted) {
        _animationCompleted = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onAnimationComplete();
        });
      }
    });
    
    // 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

  void _startAnimation() {
    _throwController.forward();
    _rotationController.forward();
  }

  @override
  void dispose() {
    _throwController.dispose();
    _rotationController.dispose();
    _splashController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFF4682B4),
            Color(0xFF1E3A8A),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 배경 분수대 (고정)
            _buildStaticFountain(),
            
            // 동전 던지기 애니메이션
            if (!_showSplash) _buildCoinAnimation(),
            
            // 물 튀는 효과
            if (_showSplash) _buildSplashEffect(),
            
            // 상단 메시지
            _buildTopMessage(),
            
            // 하단 소원 정보
            _buildWishInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticFountain() {
    return Center(
      child: CustomPaint(
        size: const Size(300, 300),
        painter: StaticFountainPainter(),
      ),
    );
  }

  Widget _buildCoinAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([_throwController, _rotationController]),
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final startY = screenSize.height - 200; // 하단에서 시작
        final endY = screenSize.height * 0.5; // 중앙에서 끝
        final centerX = screenSize.width * 0.5;
        
        // 포물선 계산
        final progress = _throwController.value;
        final currentY = startY + (endY - startY) * progress;
        final currentX = centerX + math.sin(progress * math.pi) * 50; // 약간의 수평 이동
        
        return Positioned(
          left: currentX - 25,
          top: currentY - 25,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFDAA520),
                      Color(0xFFB8860B),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDAA520),
                      border: Border.all(
                        color: const Color(0xFFB8860B),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '¥',
                        style: TextStyle(
                          color: Colors.white,
                          
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSplashEffect() {
    return AnimatedBuilder(
      animation: Listenable.merge([_splashController, _rippleController]),
      builder: (context, child) {
        return Center(
          child: CustomPaint(
            size: const Size(400, 400),
            painter: SplashEffectPainter(
              splashProgress: _splashAnimation.value,
              rippleProgress: _rippleAnimation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopMessage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _showSplash ? '🌊 소원이 분수대에 담겼습니다!' : '🪙 동전을 던지고 있어요...',
                    style: DSTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showSplash
                      ? '신이 당신의 소원을 들었습니다. 잠시만 기다려주세요.'
                      : '간절한 마음을 담아 동전이 날아가고 있어요.',
                    style: DSTypography.bodySmall.copyWith(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF1E3A8A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '당신의 소원',
                    style: DSTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryName(),
                    style: DSTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _getCategoryColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.wishText,
              style: DSTypography.bodySmall.copyWith(
                color: const Color(0xFF374151),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName() {
    switch (widget.category) {
      case '사랑': return '💕 사랑';
      case '돈': return '💰 재물';
      case '건강': return '🌿 건강';
      case '성공': return '🏆 성공';
      case '가족': return '👨‍👩‍👧‍👦 가족';
      case '학업': return '📚 학업';
      case '기타': return '🌟 기타';
      default: return widget.category;
    }
  }

  Color _getCategoryColor() {
    switch (widget.category) {
      case '사랑': return DSColors.accentSecondary;
      case '돈': return DSColors.success;
      case '건강': return DSColors.success;
      case '성공': return DSColors.warning;
      case '가족': return DSColors.accent;
      case '학업': return DSColors.accentSecondary;
      case '기타': return DSColors.accentSecondary;
      default: return DSColors.accent;
    }
  }
}

/// 고정된 분수대를 그리는 페인터
class StaticFountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // 분수대 베이스
    paint.color = const Color(0xFF708090);
    canvas.drawCircle(center, 120, paint);
    
    paint.color = const Color(0xFF778899);
    canvas.drawCircle(center, 80, paint);
    
    paint.color = const Color(0xFF696969);
    canvas.drawCircle(center, 30, paint);
    
    // 물 표면
    paint.color = const Color(0xFF87CEEB).withValues(alpha: 0.8);
    canvas.drawCircle(center, 115, paint);

    // 물 하이라이트
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(center + const Offset(-20, -20), 100, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 물 튀는 효과를 그리는 페인터
class SplashEffectPainter extends CustomPainter {
  final double splashProgress;
  final double rippleProgress;

  SplashEffectPainter({
    required this.splashProgress,
    required this.rippleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint();

    // 물 튀는 효과
    if (splashProgress > 0) {
      paint.color = Colors.white.withValues(alpha: 0.8 * (1 - splashProgress));
      
      final splashCount = 12;
      for (int i = 0; i < splashCount; i++) {
        final angle = (i * 2 * math.pi / splashCount);
        final distance = splashProgress * 60;
        final splashCenter = center + Offset(
          math.cos(angle) * distance,
          math.sin(angle) * distance,
        );
        
        canvas.drawCircle(
          splashCenter,
          5 * (1 - splashProgress),
          paint,
        );
      }
    }

    // 물결 효과
    if (rippleProgress > 0) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      
      for (int i = 0; i < 4; i++) {
        final opacity = (1 - rippleProgress) * (1 - i * 0.2);
        if (opacity > 0) {
          paint.color = Colors.white.withValues(alpha: opacity);
          final radius = rippleProgress * 150 + (i * 20);
          canvas.drawCircle(center, radius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(SplashEffectPainter oldDelegate) {
    return oldDelegate.splashProgress != splashProgress ||
        oldDelegate.rippleProgress != rippleProgress;
  }
}