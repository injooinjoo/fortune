import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../../../core/design_system/design_system.dart';

class HealthScoreCard extends StatefulWidget {
  final int score; // 0-100
  final String mainMessage;
  final VoidCallback? onTap;

  const HealthScoreCard({
    super.key,
    required this.score,
    required this.mainMessage,
    this.onTap,
  });

  @override
  State<HealthScoreCard> createState() => _HealthScoreCardState();
}

class _HealthScoreCardState extends State<HealthScoreCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score / 100.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
    ));
    
    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.score >= 90) return const Color(0xFF4CAF50); // 고유 색상 - 건강 매우좋음
    if (widget.score >= 70) return const Color(0xFF2196F3); // 고유 색상 - 건강 양호
    if (widget.score >= 50) return const Color(0xFFFF9800); // 고유 색상 - 건강 주의
    return const Color(0xFFFF5722); // 고유 색상 - 건강 경고
  }

  String get _scoreLabel {
    if (widget.score >= 90) return '매우 좋음';
    if (widget.score >= 70) return '좋음';
    if (widget.score >= 50) return '주의';
    return '경고';
  }

  String get _scoreEmoji {
    if (widget.score >= 90) return '😊';
    if (widget.score >= 70) return '🙂';
    if (widget.score >= 50) return '😐';
    return '😰';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _scoreColor.withValues(alpha: 0.1),
              _scoreColor.withValues(alpha: 0.05),
              context.colors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _scoreColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: context.isDark ? null : [
            BoxShadow(
              color: _scoreColor.withValues(alpha: 0.1),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // 제목
            Text(
              '오늘의 건강 점수',
              style: context.heading2.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            // 원형 점수 표시
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 배경 원
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CustomPaint(
                          painter: _CircularProgressPainter(
                            progress: _progressAnimation.value,
                            backgroundColor: context.colors.border.withValues(alpha: 0.3),
                            progressColor: _scoreColor,
                            strokeWidth: 12,
                          ),
                        ),
                      ),
                      
                      // 점수 텍스트
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _scoreEmoji,
                            style: context.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(widget.score * _progressAnimation.value).round()}',
                            style: context.displaySmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _scoreColor,
                            ),
                          ),
                          Text(
                            _scoreLabel,
                            style: context.bodyMedium.copyWith(
                              color: _scoreColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // 메인 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _scoreColor.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                widget.mainMessage,
                style: context.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // 탭 가이드 (선택적)
            if (widget.onTap != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: context.colors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '탭하여 자세히 보기',
                    style: context.labelMedium.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, end: 0);
  }
}

// 원형 프로그레스 페인터
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 프로그레스 원
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // 12시 방향부터 시작
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // 프로그레스 끝점에 강조 점
    if (progress > 0) {
      final endAngle = startAngle + sweepAngle;
      final endPointX = center.dx + radius * math.cos(endAngle);
      final endPointY = center.dy + radius * math.sin(endAngle);
      
      final endPointPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
        
      canvas.drawPoints(
        ui.PointMode.points,
        [Offset(endPointX, endPointY)],
        endPointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}