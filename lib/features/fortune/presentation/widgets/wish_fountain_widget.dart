import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';

/// 소원 빌기 분수대 위젯
class WishFountainWidget extends StatefulWidget {
  final VoidCallback onWriteWish;
  final VoidCallback? onThrowCoin;
  final bool hasWish;
  final int coinCount;
  final bool isThrowingCoin;

  const WishFountainWidget({
    super.key,
    required this.onWriteWish,
    this.onThrowCoin,
    this.hasWish = false,
    this.coinCount = 127,
    this.isThrowingCoin = false,
  });

  @override
  State<WishFountainWidget> createState() => _WishFountainWidgetState();
}

class _WishFountainWidgetState extends State<WishFountainWidget>
    with TickerProviderStateMixin {
  late AnimationController _waterController;
  late AnimationController _rippleController;
  late AnimationController _coinFloatController;
  
  late Animation<double> _waterAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _coinFloatAnimation;

  @override
  void initState() {
    super.initState();
    
    _waterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _coinFloatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _waterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waterController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    _coinFloatAnimation = Tween<double>(
      begin: -3.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _coinFloatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _waterController.dispose();
    _rippleController.dispose();
    _coinFloatController.dispose();
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
            Color(0xFF87CEEB), // Sky blue
            Color(0xFF4682B4), // Steel blue
            Color(0xFF1E3A8A), // Dark blue
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // 제목과 설명
            _buildHeader(),
            
            const SizedBox(height: 40),
            
            // 분수대
            Expanded(
              child: _buildFountain(),
            ),
            
            // 하단 액션 버튼들
            _buildActionButtons(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          '🌊 소원의 분수대 🌊',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: TossDesignSystem.white,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '간절한 마음으로 소원을 빌고\n분수대에 동전을 던져보세요',
          style: TypographyUnified.buttonMedium.copyWith(
            color: TossDesignSystem.white.withValues(alpha: 0.9),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // 동전 개수 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: TossDesignSystem.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: TossDesignSystem.white.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.monetization_on,
                color: Color(0xFFFFD700),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '분수대 동전: ${widget.coinCount}개',
                style: const TextStyle(
                  color: TossDesignSystem.white,
                  fontFamily: 'ZenSerif',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFountain() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _waterController,
          _rippleController,
          _coinFloatController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            size: const Size(300, 300),
            painter: FountainPainter(
              waterProgress: _waterAnimation.value,
              rippleProgress: _rippleAnimation.value,
              coinFloatOffset: _coinFloatAnimation.value,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 소원 작성하기 버튼
          SizedBox(
            width: double.infinity,
            child: UnifiedButton(
              text: widget.hasWish ? '소원 수정하기' : '소원 작성하기',
              onPressed: widget.onWriteWish,
              style: UnifiedButtonStyle.primary,
              size: UnifiedButtonSize.large,
              icon: Icon(Icons.edit),
            ),
          ),
          
          if (widget.hasWish) ...[
            const SizedBox(height: 16),
            
            // 동전 던지기 버튼
            SizedBox(
              width: double.infinity,
              child: UnifiedButton(
                text: widget.isThrowingCoin ? '동전 던지는 중...' : '행운의 동전 던지기 (남은 동전: ${widget.coinCount}개)',
                onPressed: widget.isThrowingCoin ? null : widget.onThrowCoin,
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.large,
                icon: widget.isThrowingCoin ? null : Icon(Icons.toll),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 안내 메시지
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TossDesignSystem.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.white.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: TossDesignSystem.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '소원 빌기 가이드',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.hasWish 
                    ? '소원을 작성하셨군요! 이제 간절한 마음으로 동전을 던져보세요. 신이 당신의 소원을 들어주실 것입니다.'
                    : '1. 먼저 간절한 소원을 작성해주세요\n2. 소원을 작성한 후 동전을 던져보세요\n3. 신의 응답을 기다려보세요',
                  style: TypographyUnified.bodySmall.copyWith(
                    color: TossDesignSystem.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 분수대를 그리는 커스텀 페인터
class FountainPainter extends CustomPainter {
  final double waterProgress;
  final double rippleProgress;
  final double coinFloatOffset;

  FountainPainter({
    required this.waterProgress,
    required this.rippleProgress,
    required this.coinFloatOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // 분수대 베이스 (돌)
    _drawFountainBase(canvas, center, paint);
    
    // 물
    _drawWater(canvas, center, paint);
    
    // 물방울들
    _drawWaterDrops(canvas, center, paint);
    
    // 물결 효과
    _drawRipples(canvas, center, paint);
    
    // 떠다니는 동전들
    _drawFloatingCoins(canvas, center, paint);
  }

  void _drawFountainBase(Canvas canvas, Offset center, Paint paint) {
    // 외부 링 (큰 분수대)
    paint.color = const Color(0xFF708090); // Slate gray
    canvas.drawCircle(center, 120, paint);
    
    // 내부 링 (작은 분수대)
    paint.color = const Color(0xFF778899); // Light slate gray
    canvas.drawCircle(center, 80, paint);
    
    // 중앙 기둥
    paint.color = const Color(0xFF696969); // Dim gray
    canvas.drawCircle(center, 30, paint);
    
    // 하이라이트 효과
    paint.color = TossDesignSystem.white.withValues(alpha: 0.3);
    canvas.drawCircle(center + const Offset(-10, -10), 25, paint);
  }

  void _drawWater(Canvas canvas, Offset center, Paint paint) {
    // 물 표면
    paint.color = const Color(0xFF87CEEB).withValues(alpha: 0.8);
    canvas.drawCircle(center, 115, paint);
    
    // 물 하이라이트
    paint.color = TossDesignSystem.white.withValues(alpha: 0.4);
    canvas.drawCircle(center + const Offset(-20, -20), 100, paint);
  }

  void _drawWaterDrops(Canvas canvas, Offset center, Paint paint) {
    paint.color = TossDesignSystem.white.withValues(alpha: 0.7);
    
    // 중앙에서 분사되는 물방울들
    final dropCount = 8;
    for (int i = 0; i < dropCount; i++) {
      final angle = (i * 2 * math.pi / dropCount) + (waterProgress * 2 * math.pi);
      final distance = 40 + (waterProgress * 20);
      final dropCenter = center + Offset(
        math.cos(angle) * distance,
        math.sin(angle) * distance - (waterProgress * 30),
      );
      
      canvas.drawCircle(dropCenter, 3 + (waterProgress * 2), paint);
    }
    
    // 수직으로 올라가는 물줄기
    for (int i = 0; i < 5; i++) {
      final height = center.dy - 40 - (i * 8) - (waterProgress * 20);
      if (height > center.dy - 80) {
        canvas.drawCircle(
          Offset(center.dx + (i % 2 == 0 ? -2 : 2), height),
          2 + (waterProgress * 1),
          paint,
        );
      }
    }
  }

  void _drawRipples(Canvas canvas, Offset center, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = TossDesignSystem.white.withValues(alpha: 0.3 * (1 - rippleProgress));
    
    // 여러 개의 동심원 물결
    for (int i = 0; i < 3; i++) {
      final radius = 30 + (rippleProgress * 80) + (i * 15);
      if (radius < 110) {
        canvas.drawCircle(center, radius, paint);
      }
    }
    
    paint.style = PaintingStyle.fill;
  }

  void _drawFloatingCoins(Canvas canvas, Offset center, Paint paint) {
    final coinPositions = [
      Offset(-40, -20),
      Offset(50, -30),
      Offset(-60, 40),
      Offset(35, 45),
      Offset(-20, 60),
      Offset(70, 10),
    ];
    
    for (int i = 0; i < coinPositions.length; i++) {
      final coinCenter = center + coinPositions[i] + Offset(0, coinFloatOffset + (i % 2 == 0 ? 2 : -2));
      
      // 동전 그림자
      paint.color = TossDesignSystem.black.withValues(alpha: 0.2);
      canvas.drawCircle(coinCenter + const Offset(2, 2), 6, paint);
      
      // 동전 베이스
      paint.color = const Color(0xFFFFD700); // Gold
      canvas.drawCircle(coinCenter, 6, paint);
      
      // 동전 하이라이트
      paint.color = TossDesignSystem.white.withValues(alpha: 0.6);
      canvas.drawCircle(coinCenter + const Offset(-2, -2), 3, paint);
      
      // 동전 무늬 (간단한 점)
      paint.color = const Color(0xFFDAA520); // Dark golden rod
      canvas.drawCircle(coinCenter, 2, paint);
    }
  }

  @override
  bool shouldRepaint(FountainPainter oldDelegate) {
    return oldDelegate.waterProgress != waterProgress ||
        oldDelegate.rippleProgress != rippleProgress ||
        oldDelegate.coinFloatOffset != coinFloatOffset;
  }
}