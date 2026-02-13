import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';

/// 마음의 원석 시각화 위젯
/// 명상 횟수에 따라 원석이 점점 성장하는 모습을 보여줌
class MindGemWidget extends StatefulWidget {
  const MindGemWidget({
    super.key,
    required this.level,
    this.size = 120,
    this.showLabel = true,
    this.animate = true,
  });

  /// 원석 레벨 (0-4)
  /// 0: 원석의 씨앗
  /// 1: 싹트는 원석
  /// 2: 자라는 원석
  /// 3: 빛나는 원석
  /// 4: 완성된 보석
  final int level;

  /// 위젯 크기
  final double size;

  /// 레벨 라벨 표시 여부
  final bool showLabel;

  /// 애니메이션 여부
  final bool animate;

  @override
  State<MindGemWidget> createState() => _MindGemWidgetState();
}

class _MindGemWidgetState extends State<MindGemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _pulseAnimation.value : 1.0,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _MindGemPainter(
              level: widget.level,
              glowIntensity:
                  widget.animate ? (_pulseAnimation.value - 0.95) / 0.1 : 0.5,
              rotationAngle:
                  widget.level >= 3 ? _rotateAnimation.value * 0.1 : 0,
            ),
          ),
        );
      },
    );
  }
}

class _MindGemPainter extends CustomPainter {
  _MindGemPainter({
    required this.level,
    this.glowIntensity = 0.5,
    this.rotationAngle = 0,
  });

  final int level;
  final double glowIntensity;
  final double rotationAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    switch (level) {
      case 0:
        _drawSeed(canvas, center, radius);
        break;
      case 1:
        _drawSprout(canvas, center, radius);
        break;
      case 2:
        _drawGrowing(canvas, center, radius);
        break;
      case 3:
        _drawShining(canvas, center, radius);
        break;
      case 4:
        _drawComplete(canvas, center, radius);
        break;
      default:
        _drawSeed(canvas, center, radius);
    }

    canvas.restore();
  }

  /// 레벨 0: 원석의 씨앗 (작은 돌)
  void _drawSeed(Canvas canvas, Offset center, double radius) {
    // 배경 원
    final bgPaint = Paint()
      ..color = DSColors.textSecondary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 씨앗 (작은 다이아몬드 형태)
    final seedPath = Path();
    final seedRadius = radius * 0.3;
    seedPath.moveTo(center.dx, center.dy - seedRadius);
    seedPath.lineTo(center.dx + seedRadius * 0.7, center.dy);
    seedPath.lineTo(center.dx, center.dy + seedRadius);
    seedPath.lineTo(center.dx - seedRadius * 0.7, center.dy);
    seedPath.close();

    final seedPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.fill;
    canvas.drawPath(seedPath, seedPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(seedPath, borderPaint);
  }

  /// 레벨 1: 싹트는 원석 (연한 녹색 빛)
  void _drawSprout(Canvas canvas, Offset center, double radius) {
    // 배경 글로우
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF81C784).withValues(alpha: 0.3 * glowIntensity),
          const Color(0xFF81C784).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glowPaint);

    // 원석
    final gemPath = _createGemPath(center, radius * 0.45);
    final gemPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFA5D6A7),
          Color(0xFF66BB6A),
          Color(0xFF43A047),
        ],
      ).createShader(gemPath.getBounds());
    canvas.drawPath(gemPath, gemPaint);

    // 하이라이트
    _drawHighlight(canvas, center, radius * 0.45);
  }

  /// 레벨 2: 자라는 원석 (청록색)
  void _drawGrowing(Canvas canvas, Offset center, double radius) {
    // 배경 글로우
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4DD0E1).withValues(alpha: 0.4 * glowIntensity),
          const Color(0xFF4DD0E1).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glowPaint);

    // 원석
    final gemPath = _createGemPath(center, radius * 0.55);
    final gemPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF80DEEA),
          Color(0xFF26C6DA),
          Color(0xFF00ACC1),
        ],
      ).createShader(gemPath.getBounds());
    canvas.drawPath(gemPath, gemPaint);

    // 내부 빛
    _drawInnerLight(canvas, center, radius * 0.25, const Color(0xFFE0F7FA));
    _drawHighlight(canvas, center, radius * 0.55);
  }

  /// 레벨 3: 빛나는 원석 (보라색, 빛남)
  void _drawShining(Canvas canvas, Offset center, double radius) {
    // 외부 글로우
    for (int i = 3; i >= 1; i--) {
      final glowPaint = Paint()
        ..color =
            const Color(0xFFAB47BC).withValues(alpha: 0.15 * glowIntensity * i)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * (0.7 + i * 0.1), glowPaint);
    }

    // 광선 효과
    _drawRays(canvas, center, radius * 0.9, const Color(0xFFCE93D8));

    // 원석
    final gemPath = _createGemPath(center, radius * 0.65);
    final gemPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE1BEE7),
          Color(0xFFBA68C8),
          Color(0xFF9C27B0),
        ],
      ).createShader(gemPath.getBounds());
    canvas.drawPath(gemPath, gemPaint);

    // 내부 빛
    _drawInnerLight(canvas, center, radius * 0.3, const Color(0xFFF3E5F5));
    _drawHighlight(canvas, center, radius * 0.65);
  }

  /// 레벨 4: 완성된 보석 (황금빛, 무지개 반짝임)
  void _drawComplete(Canvas canvas, Offset center, double radius) {
    // 화려한 글로우
    for (int i = 4; i >= 1; i--) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            HSLColor.fromAHSL(0.2 * glowIntensity * i, 45, 1.0, 0.6).toColor(),
            Colors.transparent,
          ],
        ).createShader(
            Rect.fromCircle(center: center, radius: radius * (0.6 + i * 0.15)));
      canvas.drawCircle(center, radius * (0.6 + i * 0.15), glowPaint);
    }

    // 무지개 광선
    _drawRainbowRays(canvas, center, radius);

    // 보석
    final gemPath = _createGemPath(center, radius * 0.7);
    final gemPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF9C4),
          Color(0xFFFFD54F),
          Color(0xFFFFB300),
          Color(0xFFFF8F00),
        ],
      ).createShader(gemPath.getBounds());
    canvas.drawPath(gemPath, gemPaint);

    // 빛 반사
    _drawSparkles(canvas, center, radius * 0.7);
    _drawInnerLight(canvas, center, radius * 0.35, const Color(0xFFFFFDE7));
    _drawHighlight(canvas, center, radius * 0.7);
  }

  /// 보석 형태 Path 생성
  Path _createGemPath(Offset center, double radius) {
    final path = Path();
    const sides = 8;
    final angle = 2 * math.pi / sides;

    for (int i = 0; i < sides; i++) {
      final r = i.isEven ? radius : radius * 0.85;
      final x = center.dx + r * math.cos(angle * i - math.pi / 2);
      final y = center.dy + r * math.sin(angle * i - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  /// 하이라이트 그리기
  void _drawHighlight(Canvas canvas, Offset center, double radius) {
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(center.dx - radius * 0.3, center.dy - radius * 0.5);
    highlightPath.quadraticBezierTo(
      center.dx - radius * 0.1,
      center.dy - radius * 0.7,
      center.dx + radius * 0.1,
      center.dy - radius * 0.5,
    );
    highlightPath.quadraticBezierTo(
      center.dx,
      center.dy - radius * 0.3,
      center.dx - radius * 0.3,
      center.dy - radius * 0.5,
    );
    canvas.drawPath(highlightPath, highlightPaint);
  }

  /// 내부 빛 그리기
  void _drawInnerLight(
      Canvas canvas, Offset center, double radius, Color color) {
    final innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, innerPaint);
  }

  /// 광선 효과
  void _drawRays(Canvas canvas, Offset center, double radius, Color color) {
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * glowIntensity)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final startX = center.dx + radius * 0.5 * math.cos(angle);
      final startY = center.dy + radius * 0.5 * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  /// 무지개 광선
  void _drawRainbowRays(Canvas canvas, Offset center, double radius) {
    final colors = [
      const Color(0xFFE57373),
      const Color(0xFFFFB74D),
      const Color(0xFFFFF176),
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFFBA68C8),
    ];

    for (int i = 0; i < 12; i++) {
      final rayPaint = Paint()
        ..color =
            colors[i % colors.length].withValues(alpha: 0.4 * glowIntensity)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final angle = i * math.pi / 6;
      final startX = center.dx + radius * 0.6 * math.cos(angle);
      final startY = center.dy + radius * 0.6 * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  /// 반짝임 효과
  void _drawSparkles(Canvas canvas, Offset center, double radius) {
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * glowIntensity)
      ..style = PaintingStyle.fill;

    final sparklePositions = [
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.4),
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.6),
    ];

    for (final pos in sparklePositions) {
      _drawStar(canvas, pos, 4, sparklePaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      final midAngle = angle + math.pi / 4;
      final midX = center.dx + radius * 0.3 * math.cos(midAngle);
      final midY = center.dy + radius * 0.3 * math.sin(midAngle);
      path.lineTo(midX, midY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MindGemPainter oldDelegate) {
    return level != oldDelegate.level ||
        glowIntensity != oldDelegate.glowIntensity ||
        rotationAngle != oldDelegate.rotationAngle;
  }
}

/// 원석 레벨 정보 표시 위젯
class GemLevelInfo extends StatelessWidget {
  const GemLevelInfo({
    super.key,
    required this.level,
    required this.totalSessions,
    required this.sessionsToNext,
  });

  final int level;
  final int totalSessions;
  final int sessionsToNext;

  String get levelName {
    switch (level) {
      case 0:
        return '원석의 씨앗';
      case 1:
        return '싹트는 원석';
      case 2:
        return '자라는 원석';
      case 3:
        return '빛나는 원석';
      case 4:
        return '완성된 보석';
      default:
        return '원석의 씨앗';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Column(
      children: [
        Text(
          levelName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        if (level < 4)
          Text(
            '다음 단계까지 $sessionsToNext회 남음',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? DSColors.textSecondaryDark : DSColors.textSecondary,
            ),
          )
        else
          const Text(
            '최고 단계 달성!',
            style: TextStyle(
              fontSize: 14,
              color: DSColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
