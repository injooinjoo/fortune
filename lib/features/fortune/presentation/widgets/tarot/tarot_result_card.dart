import 'package:flutter/material.dart';
import '../../../../../shared/components/toss_button.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/typography_unified.dart';

class TarotResultCard extends StatefulWidget {
  final Map<String, dynamic> result;
  final String question;
  final VoidCallback onRetry;

  const TarotResultCard({
    super.key,
    required this.result,
    required this.question,
    required this.onRetry,
  });

  @override
  State<TarotResultCard> createState() => _TarotResultCardState();
}

class _TarotResultCardState extends State<TarotResultCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _contentController;
  late AnimationController _shimmerController;
  
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  
  bool _isCardFlipped = false;

  @override
  void initState() {
    super.initState();
    
    // 카드 뒤집기 애니메이션
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // 내용 표시 애니메이션
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 반짝임 효과
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _cardFlipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));
    
    _cardScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 0.7,
      ),
    ]).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    ));
    
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
    
    // 순차적으로 애니메이션 시작
    _startAnimations();
  }

  void _startAnimations() async {
    // 0.5초 후 카드 뒤집기 시작
    await Future.delayed(const Duration(milliseconds: 500));
    _cardController.forward();
    
    // 카드 뒤집기 중간 지점에서 상태 변경
    _cardController.addListener(() {
      if (_cardController.value >= 0.5 && !_isCardFlipped) {
        setState(() {
          _isCardFlipped = true;
        });
      }
    });
    
    // 카드 뒤집기 완료 후 내용 표시
    _cardController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _contentController.forward();
        });
      }
    });
    
    // 반짝임 효과 시작
    Future.delayed(const Duration(milliseconds: 800), () {
      _shimmerController.repeat();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _contentController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // 질문 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '질문',
                  style: TypographyUnified.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.question,
                  style: TypographyUnified.buttonMedium.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF191919),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 타로 카드
          Center(
            child: AnimatedBuilder(
              animation: _cardController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardScaleAnimation.value,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_cardFlipAnimation.value * math.pi),
                    child: _isCardFlipped
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildCardFront(),
                          )
                        : _buildCardBack(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 카드 이름
          FadeTransition(
            opacity: _contentFadeAnimation,
            child: SlideTransition(
              position: _contentSlideAnimation,
              child: Text(
                widget.result['cardName'] ?? 'Unknown Card',
                textAlign: TextAlign.center,
                style: TypographyUnified.heading1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191919),
                  height: 1.2,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 키워드들
          if (widget.result['keywords'] != null)
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: (widget.result['keywords'] as List<String>).map(
                    (keyword) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        keyword,
                        style: TypographyUnified.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),
          
          const SizedBox(height: 32),
          
          // 해석
          FadeTransition(
            opacity: _contentFadeAnimation,
            child: SlideTransition(
              position: _contentSlideAnimation,
              child: _buildSection(
                title: '카드의 메시지',
                content: widget.result['interpretation'] ?? '',
                icon: Icons.auto_awesome,
                color: const Color(0xFF7C3AED),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 조언
          if (widget.result['advice'] != null)
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: _buildSection(
                  title: '조언',
                  content: widget.result['advice'],
                  icon: Icons.lightbulb_outline,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          
          const SizedBox(height: 40),
          
          // 액션 버튼들
          FadeTransition(
            opacity: _contentFadeAnimation,
            child: SlideTransition(
              position: _contentSlideAnimation,
              child: Column(
                children: [
                  // 다시 보기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: TossButton(
                      text: '다른 질문하기',
                      onPressed: widget.onRetry,
                      style: TossButtonStyle.ghost,
                      size: TossButtonSize.large,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 공유 버튼
                  SizedBox(
                    width: double.infinity,
                    child: TossButton(
                      text: '결과 공유하기',
                      onPressed: _shareResult,
                      style: TossButtonStyle.primary,
                      size: TossButtonSize.large,
                      icon: Icon(Icons.share),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A5F),
            Color(0xFF0D1B2A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: _TarotCardBackPainter(),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 카드 이미지
            Image.asset(
              widget.result['cardImage'] ?? 'assets/images/tarot/major_00.jpg',
              fit: BoxFit.cover,
              width: 200,
              height: 280,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF7C3AED),
                        const Color(0xFF3B82F6),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: TossDesignSystem.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.result['cardName'] ?? 'The Fool',
                        style: const TextStyle(
                          color: TossDesignSystem.white,
                          
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // 반짝임 효과
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + _shimmerController.value * 2, -1.0),
                        end: Alignment(1.0 + _shimmerController.value * 2, 1.0),
                        colors: [
                          TossDesignSystem.white.withValues(alpha: 0.0),
                          TossDesignSystem.white.withValues(alpha: 0.2),
                          TossDesignSystem.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _shareResult() {
    final shareText = '''
🔮 타로 카드 결과 🔮

질문: ${widget.question}
카드: ${widget.result['cardName']}

${widget.result['interpretation']}

포춘 앱에서 더 많은 운세를 확인해보세요!
''';
    
    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('결과가 클립보드에 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// 타로 카드 뒷면 페인터
class _TarotCardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TossDesignSystem.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // 중앙 별
    _drawStar(canvas, center, size.width * 0.15, paint);

    // 주변 별들
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final starPos = Offset(
        center.dx + size.width * 0.25 * math.cos(angle),
        center.dy + size.width * 0.25 * math.sin(angle),
      );
      _drawStar(canvas, starPos, size.width * 0.08, paint);
    }

    // 테두리
    final borderRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.05,
      size.width * 0.8,
      size.height * 0.9,
    );
    canvas.drawRect(borderRect, paint);

    final innerRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.08,
      size.width * 0.7,
      size.height * 0.84,
    );
    paint.strokeWidth = 0.5;
    canvas.drawRect(innerRect, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const angle = -math.pi / 2;

    for (int i = 0; i < 5; i++) {
      final outerAngle = angle + i * 2 * math.pi / 5;
      final outerX = center.dx + radius * math.cos(outerAngle);
      final outerY = center.dy + radius * math.sin(outerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerRadius = radius * 0.4;
      final innerAngle = angle + (i * 2 + 1) * math.pi / 5;
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}