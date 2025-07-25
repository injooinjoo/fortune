import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/components/base_card.dart';
import '../../../../presentation/widgets/simple_fortune_info_sheet.dart';

class TraditionalFortuneEnhancedPage extends ConsumerStatefulWidget {
  const TraditionalFortuneEnhancedPage({super.key});

  @override
  ConsumerState<TraditionalFortuneEnhancedPage> createState() => _TraditionalFortuneEnhancedPageState();
}

class _TraditionalFortuneEnhancedPageState extends ConsumerState<TraditionalFortuneEnhancedPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              Color(0xFFEF4444).withValues(alpha: 0.05),
              AppColors.background,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFEF4444),
                        Color(0xFFEC4899),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: TraditionalBackgroundPainter(),
                        ),
                      ),
                      // Rotating elements
                      Center(
                        child: AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 200,
                                height: 200,
                                child: CustomPaint(
                                  painter: YinYangPainter(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Title overlay
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 60,
                              color: Colors.white,
                            ).animate()
                              .scale(delay: 300.ms, duration: 600.ms)
                              .fade(),
                            const SizedBox(height: 16),
                            Text(
                              '전통운세 종합',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ).animate()
                              .fadeIn(delay: 500.ms, duration: 600.ms)
                              .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 8),
                            Text(
                              '사주 · 토정비결 · 주역',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ).animate()
                              .fadeIn(delay: 700.ms, duration: 600.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                title: const Text('전통운세 종합'),
                centerTitle: true,
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Introduction Card
                  _buildIntroductionCard()
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  // Features Grid
                  _buildFeaturesGrid()
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  // Main Fortune Button
                  _buildMainFortuneButton(context)
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
                  
                  const SizedBox(height: 20),
                  
                  // Philosophy Card
                  _buildPhilosophyCard()
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionCard() {
    return BaseCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEF4444).withValues(alpha: 0.05),
          Color(0xFFEC4899).withValues(alpha: 0.02),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '5000년 동양철학의 지혜',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '사주명리학, 토정비결, 주역을 통합하여\n당신의 운명과 미래를 깊이 있게 분석합니다',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'icon': Icons.account_tree_rounded,
        'title': '정통 사주',
        'description': '생년월일시를 바탕으로\n타고난 운명 분석',
        'color': Color(0xFFEF4444),
      },
      {
        'icon': Icons.menu_book_rounded,
        'title': '토정비결',
        'description': '전통 비결서로 보는\n월별·연간 운세',
        'color': Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': '주역 64괘',
        'description': '변화의 원리로 보는\n오늘의 메시지',
        'color': Color(0xFF3B82F6),
      },
      {
        'icon': Icons.insights_rounded,
        'title': '종합 분석',
        'description': '세 가지 지혜를 통합한\n깊이 있는 해석',
        'color': Color(0xFF10B981),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return BaseCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (feature['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    size: 32,
                    color: feature['color'] as Color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  feature['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ).animate(delay: (100 * index).ms)
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
      },
    );
  }

  Widget _buildMainFortuneButton(BuildContext context) {
    return InkWell(
      onTap: () {
        SimpleFortunInfoSheet.show(
          context,
          fortuneType: 'traditional-unified',
          title: '전통운세 종합',
          description: '사주, 토정비결, 주역을 통합한 깊이 있는 운세 분석',
          onDismiss: () {},
          onFortuneButtonPressed: () {
            // Navigate to fortune generation
            context.push('/fortune/traditional-unified');
          },
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEF4444),
              Color(0xFFEC4899),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFEF4444).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pattern overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: UnifiedPatternPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '운세 보기',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '오늘의 종합 운세를 확인하세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhilosophyCard() {
    return BaseCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 24,
                  color: Color(0xFF795548),
                ),
                const SizedBox(width: 8),
                Text(
                  '동양철학의 핵심',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPhilosophyItem(
              '음양오행',
              '만물의 생성과 변화 원리',
              Icons.sync_rounded,
            ),
            const SizedBox(height: 12),
            _buildPhilosophyItem(
              '천지인',
              '하늘, 땅, 사람의 조화',
              Icons.public_rounded,
            ),
            const SizedBox(height: 12),
            _buildPhilosophyItem(
              '사시순환',
              '시간의 흐름과 운의 변화',
              Icons.loop_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhilosophyItem(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF795548).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Color(0xFF795548),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Background pattern painter
class TraditionalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.1);

    // Draw traditional patterns
    final spacing = 60.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        _drawPattern(canvas, Offset(x, y), 20, paint);
      }
    }
  }

  void _drawPattern(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw hexagon pattern
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Yin Yang painter
class YinYangPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;
    
    // White side
    final whitePath = Path();
    whitePath.addArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi,
    );
    whitePath.arcTo(
      Rect.fromCircle(center: Offset(center.dx, center.dy - radius / 2), radius: radius / 2),
      math.pi / 2,
      math.pi,
      false,
    );
    whitePath.arcTo(
      Rect.fromCircle(center: Offset(center.dx, center.dy + radius / 2), radius: radius / 2),
      math.pi / 2,
      -math.pi,
      false,
    );
    
    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(whitePath, whitePaint);
    
    // Black side
    final blackPath = Path();
    blackPath.addArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2,
      math.pi,
    );
    blackPath.arcTo(
      Rect.fromCircle(center: Offset(center.dx, center.dy + radius / 2), radius: radius / 2),
      -math.pi / 2,
      math.pi,
      false,
    );
    blackPath.arcTo(
      Rect.fromCircle(center: Offset(center.dx, center.dy - radius / 2), radius: radius / 2),
      -math.pi / 2,
      -math.pi,
      false,
    );
    
    final blackPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(blackPath, blackPaint);
    
    // Small circles
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius / 2),
      radius / 8,
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius / 2),
      radius / 8,
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
    
    // Outer circle
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outlinePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Unified pattern painter
class UnifiedPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.15);

    // Draw multiple elements representing different fortune types
    _drawSajuElements(canvas, size, paint);
    _drawTojeongPattern(canvas, size, paint);
    _drawJuyeokSymbols(canvas, size, paint);
  }

  void _drawSajuElements(Canvas canvas, Size size, Paint paint) {
    // Draw 5 elements circles
    final positions = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.8),
    ];
    
    for (final pos in positions) {
      canvas.drawCircle(pos, 15, paint);
    }
  }

  void _drawTojeongPattern(Canvas canvas, Size size, Paint paint) {
    // Draw grid pattern
    final spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..color = Colors.white.withValues(alpha: 0.05),
      );
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint..color = Colors.white.withValues(alpha: 0.05),
      );
    }
  }

  void _drawJuyeokSymbols(Canvas canvas, Size size, Paint paint) {
    // Draw trigram lines
    final centerX = size.width * 0.5;
    final startY = size.height * 0.3;
    final lineWidth = 40.0;
    final lineSpacing = 10.0;
    
    paint.color = Colors.white.withValues(alpha: 0.2);
    paint.strokeWidth = 3.0;
    
    // Top trigram
    for (int i = 0; i < 3; i++) {
      final y = startY + i * lineSpacing;
      if (i == 1) {
        // Broken line
        canvas.drawLine(
          Offset(centerX - lineWidth / 2, y),
          Offset(centerX - 5, y),
          paint,
        );
        canvas.drawLine(
          Offset(centerX + 5, y),
          Offset(centerX + lineWidth / 2, y),
          paint,
        );
      } else {
        // Solid line
        canvas.drawLine(
          Offset(centerX - lineWidth / 2, y),
          Offset(centerX + lineWidth / 2, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}