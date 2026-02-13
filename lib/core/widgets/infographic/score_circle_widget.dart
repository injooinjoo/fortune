import 'dart:math';
import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// 점수를 원형 게이지로 표시하는 인포그래픽 위젯
///
/// 사용 예시:
/// ```dart
/// ScoreCircleWidget(
///   score: 78,
///   label: '오늘의 운세',
///   subtitle: '2025.01.08 (수)',
/// )
/// ```
class ScoreCircleWidget extends StatelessWidget {
  /// 표시할 점수 (0-100)
  final int score;

  /// 상단 라벨 (예: '오늘의 운세')
  final String? label;

  /// 하단 서브타이틀 (예: 날짜)
  final String? subtitle;

  /// 원형 크기 (기본값: 100)
  final double size;

  /// 게이지 두께 (기본값: 8)
  final double strokeWidth;

  /// 점수에 따른 색상 커스터마이징
  final Color? scoreColor;

  /// 배경 게이지 색상
  final Color? backgroundColor;

  /// 점수 표시 여부 (기본값: true)
  final bool showScore;

  /// 점수 suffix (기본값: '점')
  final String scoreSuffix;

  /// 애니메이션 적용 여부
  final bool animate;

  /// 애니메이션 지속 시간
  final Duration animationDuration;

  const ScoreCircleWidget({
    super.key,
    required this.score,
    this.label,
    this.subtitle,
    this.size = 100,
    this.strokeWidth = 8,
    this.scoreColor,
    this.backgroundColor,
    this.showScore = true,
    this.scoreSuffix = '점',
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final effectiveScoreColor = scoreColor ?? _getScoreColor(isDark);
    final effectiveBgColor = backgroundColor ??
        (isDark
            ? DSColors.backgroundSecondaryDark
            : DSColors.backgroundSecondary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 원형 게이지
        _AnimatedScoreCircle(
          score: score,
          size: size,
          strokeWidth: strokeWidth,
          scoreColor: effectiveScoreColor,
          backgroundColor: effectiveBgColor,
          showScore: showScore,
          scoreSuffix: scoreSuffix,
          animate: animate,
          animationDuration: animationDuration,
        ),
        if (label != null || subtitle != null) ...[
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: context.heading4.copyWith(
                    color: isDark
                        ? DSColors.textPrimaryDark
                        : DSColors.textPrimary,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: context.bodySmall.copyWith(
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  /// 점수에 따른 색상 결정
  Color _getScoreColor(bool isDark) {
    if (score >= 80) {
      return isDark ? DSColors.successDark : DSColors.success;
    } else if (score >= 60) {
      return isDark ? DSColors.accentTertiaryDark : DSColors.accentTertiary;
    } else if (score >= 40) {
      return isDark ? DSColors.warningDark : DSColors.warning;
    } else {
      return isDark ? DSColors.errorDark : DSColors.error;
    }
  }
}

/// 애니메이션이 적용된 점수 원형
class _AnimatedScoreCircle extends StatefulWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final Color scoreColor;
  final Color backgroundColor;
  final bool showScore;
  final String scoreSuffix;
  final bool animate;
  final Duration animationDuration;

  const _AnimatedScoreCircle({
    required this.score,
    required this.size,
    required this.strokeWidth,
    required this.scoreColor,
    required this.backgroundColor,
    required this.showScore,
    required this.scoreSuffix,
    required this.animate,
    required this.animationDuration,
  });

  @override
  State<_AnimatedScoreCircle> createState() => _AnimatedScoreCircleState();
}

class _AnimatedScoreCircleState extends State<_AnimatedScoreCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedScoreCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircleProgressPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: widget.backgroundColor,
                ),
              ),
              // 진행 원
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircleProgressPainter(
                  progress: _animation.value / 100,
                  strokeWidth: widget.strokeWidth,
                  color: widget.scoreColor,
                ),
              ),
              // 점수 텍스트
              if (widget.showScore)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _animation.value.round().toString(),
                      style: context.numberLarge.copyWith(
                        color: isDark
                            ? DSColors.textPrimaryDark
                            : DSColors.textPrimary,
                        fontSize: widget.size * 0.28,
                      ),
                    ),
                    Text(
                      widget.scoreSuffix,
                      style: context.labelSmall.copyWith(
                        color: isDark
                            ? DSColors.textSecondaryDark
                            : DSColors.textSecondary,
                        fontSize: widget.size * 0.12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 원형 진행률 페인터
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 시작 각도: -90도 (12시 방향)
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}

/// 컴팩트 버전 - 점수만 원형으로 표시
class ScoreCircleCompact extends StatelessWidget {
  final int score;
  final double size;
  final Color? scoreColor;

  const ScoreCircleCompact({
    super.key,
    required this.score,
    this.size = 60,
    this.scoreColor,
  });

  @override
  Widget build(BuildContext context) {
    return ScoreCircleWidget(
      score: score,
      size: size,
      strokeWidth: 6,
      scoreSuffix: '',
    );
  }
}
