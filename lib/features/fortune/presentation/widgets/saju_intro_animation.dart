import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/toss_button.dart';

/// 사주팔자 시작 애니메이션 위젯
class SajuIntroAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const SajuIntroAnimation({
    super.key,
    required this.onComplete,
  });

  @override
  State<SajuIntroAnimation> createState() => _SajuIntroAnimationState();
}

class _SajuIntroAnimationState extends State<SajuIntroAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));
    
    _textFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _rotationController.repeat();
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TossTheme.backgroundPrimary,
              TossTheme.backgroundSecondary,
              TossTheme.backgroundPrimary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 배경 패턴
            _buildBackgroundPattern(),
            
            // 메인 콘텐츠
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(TossTheme.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // 태극 심볼과 애니메이션
                    _buildTaeguekSymbol(),
                    
                    const SizedBox(height: TossTheme.spacingXXL),
                    
                    // 제목과 설명
                    AnimatedBuilder(
                      animation: _textFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                '천간지지로 보는',
                                style: TossTheme.heading1.copyWith(
                                  color: TossTheme.textBlack,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: TossTheme.spacingS),
                              Text(
                                '당신의 운명',
                                style: TossTheme.heading1.copyWith(
                                  color: TossTheme.brandBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: TossTheme.spacingL),
                              Text(
                                '만세력을 바탕으로 정확한\n사주팔자 분석을 제공합니다',
                                style: TossTheme.body1.copyWith(
                                  color: TossTheme.textGray600,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(flex: 3),
                    
                    // 시작 버튼
                    AnimatedBuilder(
                      animation: _textFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value,
                          child: TossButton(
                            text: '사주팔자 보기',
                            onPressed: widget.onComplete,
                            style: TossButtonStyle.primary,
                            width: double.infinity,
                            icon: const Icon(Icons.auto_awesome),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: TossTheme.spacingL),
                    
                    // 하단 안내 텍스트
                    AnimatedBuilder(
                      animation: _textFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value * 0.7,
                          child: Text(
                            '정확한 분석을 위해 출생 정보를 입력해주세요',
                            style: TossTheme.caption.copyWith(
                              color: TossTheme.textGray500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: TossTheme.spacingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value * 0.05,
            child: CustomPaint(
              painter: TraditionalPatternPainter(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaeguekSymbol() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _scaleAnimation,
        _fadeAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 외부 원
                  Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TossTheme.brandBlue.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: CustomPaint(
                        painter: TaeguekPainter(),
                      ),
                    ),
                  ),
                  
                  // 천간지지 문자들
                  ...List.generate(12, (index) {
                    final angle = (index * 30.0) * math.pi / 180;
                    final radius = 85.0;
                    final x = radius * math.cos(angle);
                    final y = radius * math.sin(angle);
                    
                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Transform.rotate(
                        angle: -_rotationAnimation.value + angle + math.pi / 2,
                        child: Text(
                          _getZodiacChar(index),
                          style: TossTheme.caption.copyWith(
                            color: TossTheme.textGray600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // 중앙 사주 문자
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TossTheme.backgroundPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: TossTheme.brandBlue.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '사주\n팔자',
                        style: TossTheme.body2.copyWith(
                          color: TossTheme.brandBlue,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getZodiacChar(int index) {
    const zodiacChars = [
      '子', '丑', '寅', '卯', '辰', '巳',
      '午', '未', '申', '酉', '戌', '亥'
    ];
    return zodiacChars[index];
  }
}

/// 태극 그리기 페인터
class TaeguekPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    final yinPaint = Paint()
      ..color = TossTheme.textBlack.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    final yangPaint = Paint()
      ..color = TossTheme.backgroundPrimary
      ..style = PaintingStyle.fill;
    
    // 태극 그리기
    final path = Path();
    path.addArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      0,
      math.pi,
    );
    path.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius / 2),
        width: radius,
        height: radius,
      ),
      0,
      math.pi,
    );
    path.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius / 2),
        width: radius,
        height: radius,
      ),
      math.pi,
      math.pi,
    );
    
    canvas.drawPath(path, yinPaint);
    
    // 양의 점
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius / 2),
      radius / 6,
      yangPaint,
    );
    
    // 음의 점
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius / 2),
      radius / 6,
      yinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 전통 패턴 페인터
class TraditionalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TossTheme.textGray600.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    const spacing = 50.0;
    
    // 격자 패턴
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}