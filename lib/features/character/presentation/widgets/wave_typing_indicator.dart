import 'dart:math';
import 'package:flutter/material.dart';

/// 물결 타이핑 인디케이터 (인스타그램 DM 스타일)
/// 점 3개가 사인 곡선으로 위아래로 물결처럼 움직임
class WaveTypingIndicator extends StatefulWidget {
  final Color? dotColor;
  final double dotSize;
  final double bounceHeight;

  const WaveTypingIndicator({
    super.key,
    this.dotColor,
    this.dotSize = 8.0,
    this.bounceHeight = 4.0,
  });

  @override
  State<WaveTypingIndicator> createState() => _WaveTypingIndicatorState();
}

class _WaveTypingIndicatorState extends State<WaveTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.dotColor ?? Colors.grey[500]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // 각 점마다 0.15초 간격으로 딜레이
            final delay = index * 0.15;
            final value = (_controller.value + delay) % 1.0;

            // 사인 곡선으로 부드러운 바운스 (위아래로 움직임)
            final bounce = sin(value * pi * 2) * widget.bounceHeight;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -bounce.abs()),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// 작은 타이핑 인디케이터 (DM 목록 아바타용)
class MiniTypingIndicator extends StatefulWidget {
  final Color? dotColor;

  const MiniTypingIndicator({
    super.key,
    this.dotColor,
  });

  @override
  State<MiniTypingIndicator> createState() => _MiniTypingIndicatorState();
}

class _MiniTypingIndicatorState extends State<MiniTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.dotColor ?? Colors.grey[600]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = (_controller.value + delay) % 1.0;
            final bounce = sin(value * pi * 2) * 2;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Transform.translate(
                offset: Offset(0, -bounce.abs()),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
