import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../core/widgets/fortune_action_buttons.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/font_config.dart';

class TarotResultCard extends ConsumerStatefulWidget {
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
  ConsumerState<TarotResultCard> createState() => _TarotResultCardState();
}

class _TarotResultCardState extends ConsumerState<TarotResultCard>
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

  // 동양화 스타일 - 테마 색상 (DSColors 사용)
  static Color _getPrimaryColor(BuildContext context) =>
      context.colors.textPrimary;
  static Color _getSecondaryColor(BuildContext context) => DSColors.info;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: DSSpacing.lg),

          // 질문 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DSSpacing.cardPadding),
            decoration: BoxDecoration(
              color: _getPrimaryColor(context)
                  .withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getPrimaryColor(context)
                    .withValues(alpha: isDark ? 0.3 : 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  final typography = context.typography;
                  return Text(
                    '질문',
                    style: typography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _getPrimaryColor(context),
                    ),
                  );
                }),
                const SizedBox(height: DSSpacing.xs),
                Builder(builder: (context) {
                  final colors = context.colors;
                  final typography = context.typography;
                  return Text(
                    widget.question,
                    style: typography.labelLarge.copyWith(
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: DSSpacing.xl),

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
                            child: _buildCardFront(context),
                          )
                        : _buildCardBack(context),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: DSSpacing.xl),

          // 카드 이름 + 액션 버튼
          FadeTransition(
            opacity: _contentFadeAnimation,
            child: SlideTransition(
              position: _contentSlideAnimation,
              child: Builder(builder: (context) {
                final colors = context.colors;
                final typography = context.typography;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.result['cardName'] ?? 'Unknown Card',
                        textAlign: TextAlign.center,
                        style: typography.headingLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    // 좋아요 + 공유 버튼
                    FortuneActionButtons(
                      contentId:
                          'tarot_${widget.result['cardName']}_${DateTime.now().millisecondsSinceEpoch}',
                      contentType: 'tarot',
                      shareTitle: '타로 카드: ${widget.result['cardName']}',
                      shareContent: widget.result['interpretation'] ?? '',
                      iconSize: 20,
                      iconColor: _getPrimaryColor(context),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: DSSpacing.md),

          // 키워드들
          if (widget.result['keywords'] != null)
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: Wrap(
                  spacing: DSSpacing.sm,
                  runSpacing: DSSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: (widget.result['keywords'] as List<String>)
                      .map(
                        (keyword) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.sm,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getPrimaryColor(context)
                                .withValues(alpha: isDark ? 0.15 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getPrimaryColor(context)
                                  .withValues(alpha: isDark ? 0.3 : 0.2),
                            ),
                          ),
                          child: Builder(builder: (context) {
                            final typography = context.typography;
                            return Text(
                              keyword,
                              style: typography.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _getPrimaryColor(context),
                              ),
                            );
                          }),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

          const SizedBox(height: DSSpacing.xl),

          // 해석 (프리미엄 잠금 메시지가 아닌 경우만 표시)
          if (!((widget.result['interpretation'] ?? '')
                  .toString()
                  .contains('프리미엄') ||
              (widget.result['interpretation'] ?? '')
                  .toString()
                  .contains('🔒')))
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: _buildSection(
                  context: context,
                  isDark: isDark,
                  title: '카드의 메시지',
                  content: widget.result['interpretation'] ?? '',
                  icon: Icons.auto_awesome,
                  color: _getPrimaryColor(context),
                ),
              ),
            ),

          const SizedBox(height: DSSpacing.lg),

          // 조언 (프리미엄 잠금 메시지가 아닌 경우만 표시)
          if (widget.result['advice'] != null &&
              !widget.result['advice'].toString().contains('프리미엄') &&
              !widget.result['advice'].toString().contains('🔒'))
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: _buildSection(
                  context: context,
                  isDark: isDark,
                  title: '조언',
                  content: widget.result['advice'],
                  icon: Icons.lightbulb_outline,
                  color: _getSecondaryColor(context),
                ),
              ),
            ),

          const SizedBox(height: DSSpacing.xl + DSSpacing.md),

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
                    child: UnifiedButton(
                      text: '다른 질문하기',
                      onPressed: widget.onRetry,
                      style: UnifiedButtonStyle.ghost,
                      size: UnifiedButtonSize.large,
                    ),
                  ),

                  const SizedBox(height: DSSpacing.sm),

                  // 공유 버튼
                  SizedBox(
                    width: double.infinity,
                    child: UnifiedButton(
                      text: '결과 공유하기',
                      onPressed: _shareResult,
                      style: UnifiedButtonStyle.primary,
                      size: UnifiedButtonSize.large,
                      icon: const Icon(Icons.share),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DSSpacing.xl + DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context) {
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSColors.info,
            DSColors.info.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getPrimaryColor(context).withValues(alpha: 0.3),
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

  Widget _buildCardFront(BuildContext context) {
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getPrimaryColor(context).withValues(alpha: 0.3),
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
                        DSColors.info,
                        DSColors.info.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.result['cardName'] ?? 'The Fool',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: FontConfig.primary,
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
                        begin: Alignment(
                            -1.0 + _shimmerController.value * 2, -1.0),
                        end: Alignment(1.0 + _shimmerController.value * 2, 1.0),
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.0),
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
    required BuildContext context,
    required bool isDark,
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    final typography = context.typography;
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: DSSpacing.sm),
              Text(
                title,
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            content,
            style: typography.bodySmall.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
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
      ..color = Colors.white.withValues(alpha: 0.3)
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
