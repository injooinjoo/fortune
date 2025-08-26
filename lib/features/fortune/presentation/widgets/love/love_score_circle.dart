import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../../core/theme/toss_theme.dart';

class LoveScoreCircle extends StatefulWidget {
  final int score;
  final bool animated;
  
  const LoveScoreCircle({
    super.key,
    required this.score,
    this.animated = true,
  });

  @override
  State<LoveScoreCircle> createState() => _LoveScoreCircleState();
}

class _LoveScoreCircleState extends State<LoveScoreCircle>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animated) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 90) {
      return const Color(0xFF10B981); // Success green
    } else if (score >= 80) {
      return TossTheme.primaryBlue;
    } else if (score >= 70) {
      return TossTheme.warning;
    } else {
      return TossTheme.error;
    }
  }

  String _getScoreEmoji(int score) {
    if (score >= 90) {
      return '🌟';
    } else if (score >= 80) {
      return '💕';
    } else if (score >= 70) {
      return '😊';
    } else {
      return '💪';
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.animated
        ? AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return _buildScoreCircle(_scoreAnimation.value);
            },
          )
        : _buildScoreCircle(widget.score);
  }

  Widget _buildScoreCircle(int currentScore) {
    final color = _getScoreColor(currentScore);
    final emoji = _getScoreEmoji(currentScore);
    
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TossTheme.backgroundSecondary,
              border: Border.all(
                color: TossTheme.borderGray200,
                width: 2,
              ),
            ),
          ),
          
          // Progress circle
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 12,
            percent: currentScore / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentScore',
                  style: TossTheme.heading1.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 42,
                  ),
                ),
                Text(
                  '점',
                  style: TossTheme.body1.copyWith(
                    color: TossTheme.textGray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            progressColor: color,
            backgroundColor: TossTheme.borderGray200,
            circularStrokeCap: CircularStrokeCap.round,
            animation: false,
          ),
          
          // 외곽 글로우 효과
          if (currentScore >= 80)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ).animate(delay: 800.ms).then()
             .shimmer(duration: 2000.ms, color: color.withOpacity(0.5))
             .animate(onPlay: (controller) => controller.repeat()),
        ],
      ),
    );
  }
}