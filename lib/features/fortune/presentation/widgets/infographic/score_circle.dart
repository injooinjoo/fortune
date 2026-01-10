import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_assets.dart';

/// 원형 점수 게이지 위젯
///
/// 종합 점수를 시각적으로 표현하는 원형 게이지입니다.
/// 애니메이션과 그라데이션을 지원합니다.
class ScoreCircle extends StatefulWidget {
  const ScoreCircle({
    super.key,
    required this.score,
    this.maxScore = 100,
    this.size = 120,
    this.strokeWidth = 10,
    this.backgroundColor,
    this.progressColor,
    this.gradient,
    this.showPercentile = false,
    this.percentile,
    this.label,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.showStars = false,
    this.starCount,
  });

  /// 현재 점수
  final int score;

  /// 최대 점수
  final int maxScore;

  /// 위젯 크기
  final double size;

  /// 게이지 두께
  final double strokeWidth;

  /// 배경 원 색상
  final Color? backgroundColor;

  /// 진행 원 색상 (gradient가 없을 때)
  final Color? progressColor;

  /// 진행 원 그라데이션 (progressColor보다 우선)
  final Gradient? gradient;

  /// 상위 퍼센타일 표시 여부
  final bool showPercentile;

  /// 상위 몇 % 인지
  final int? percentile;

  /// 하단 라벨 (예: "종합 점수")
  final String? label;

  /// 애니메이션 활성화
  final bool animate;

  /// 애니메이션 시간
  final Duration animationDuration;

  /// 별점 표시 여부
  final bool showStars;

  /// 별 개수 (5점 만점 기준)
  final int? starCount;

  @override
  State<ScoreCircle> createState() => _ScoreCircleState();
}

class _ScoreCircleState extends State<ScoreCircle>
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
      end: widget.score / widget.maxScore,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(ScoreCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score / widget.maxScore,
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

  Color _getScoreColor(BuildContext context) {
    if (widget.progressColor != null) return widget.progressColor!;

    final ratio = widget.score / widget.maxScore;
    if (ratio >= 0.8) return context.colors.success;
    if (ratio >= 0.6) return context.colors.accentTertiary;
    if (ratio >= 0.4) return context.colors.warning;
    return context.colors.error;
  }

  int _calculateStars() {
    if (widget.starCount != null) return widget.starCount!;
    final ratio = widget.score / widget.maxScore;
    if (ratio >= 0.9) return 5;
    if (ratio >= 0.7) return 4;
    if (ratio >= 0.5) return 3;
    if (ratio >= 0.3) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    // 점수에 따른 글로우 이미지 선택
    final glowImage = InfographicAssets.getGlowForScore(widget.score);
    final showGlow = widget.score >= 50; // 50점 이상일 때만 글로우 표시

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 레이아웃 크기는 widget.size로 유지, 글로우는 시각적으로만 오버플로우
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            clipBehavior: Clip.none, // 글로우가 밖으로 나갈 수 있도록
            alignment: Alignment.center,
            children: [
              // 글로우 효과 (점수 50 이상) - 중앙 정렬로 밖으로 넘침
              if (showGlow)
                Positioned(
                  left: -20,
                  right: -20,
                  top: -20,
                  bottom: -20,
                  child: Image.asset(
                    glowImage,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // 점수 원형 게이지
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ScoreCirclePainter(
                        progress: _animation.value,
                        backgroundColor: widget.backgroundColor ??
                            context.colors.border.withValues(alpha: 0.3),
                        progressColor: _getScoreColor(context),
                        gradient: widget.gradient,
                        strokeWidth: widget.strokeWidth,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 점수 숫자
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, _) {
                                final displayScore =
                                    (_animation.value * widget.maxScore).round();
                                return Text(
                                  '$displayScore',
                                  style: context.typography.displayLarge.copyWith(
                                    fontSize: widget.size * 0.28,
                                    fontWeight: FontWeight.w800,
                                    color: context.colors.textPrimary,
                                  ),
                                );
                              },
                            ),

                            // 별점
                            if (widget.showStars) ...[
                              const SizedBox(height: 2),
                              _StarRating(
                                stars: _calculateStars(),
                                size: widget.size * 0.1,
                                color: _getScoreColor(context),
                              ),
                            ],

                            // 상위 퍼센타일
                            if (widget.showPercentile && widget.percentile != null)
                              Text(
                                '상위 ${widget.percentile}%',
                                style: context.typography.labelSmall.copyWith(
                                  fontSize: widget.size * 0.09,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 라벨
        if (widget.label != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            widget.label!,
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// 원형 게이지 페인터
class _ScoreCirclePainter extends CustomPainter {
  _ScoreCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.gradient,
    required this.strokeWidth,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final Gradient? gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행 원
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      progressPaint.shader = gradient!.createShader(rect);
    } else {
      progressPaint.color = progressColor;
    }

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 12시 방향에서 시작
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

/// 별점 위젯
class _StarRating extends StatelessWidget {
  const _StarRating({
    required this.stars,
    required this.size,
    required this.color,
  });

  final int stars;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: index < stars ? color : context.colors.border,
        );
      }),
    );
  }
}

/// 미니 점수 원 (작은 사이즈용)
class MiniScoreCircle extends StatelessWidget {
  const MiniScoreCircle({
    super.key,
    required this.score,
    this.size = 48,
    this.backgroundColor,
    this.textColor,
  });

  final int score;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  Color _getScoreColor(BuildContext context) {
    if (score >= 80) return context.colors.success;
    if (score >= 60) return context.colors.accentTertiary;
    if (score >= 40) return context.colors.warning;
    return context.colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _getScoreColor(context).withOpacity(0.15);
    final fgColor = textColor ?? _getScoreColor(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$score',
          style: context.typography.bodyMedium.copyWith(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}
