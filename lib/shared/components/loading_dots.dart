import 'package:flutter/material.dart';

/// 점 3개 로딩 애니메이션 위젯
class LoadingDots extends StatefulWidget {
  final Color? color;
  final double size;
  
  const LoadingDots({
    super.key,
    this.color,
    this.size = 8.0,
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    
    // 각 점이 순차적으로 애니메이션되도록 설정
    _animation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
    
    _animation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
    ));
    
    _animation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.white;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(_animation1, color),
        SizedBox(width: widget.size * 0.5),
        _buildDot(_animation2, color),
        SizedBox(width: widget.size * 0.5),
        _buildDot(_animation3, color),
      ],
    );
  }

  Widget _buildDot(Animation<double> animation, Color color) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -widget.size * animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8 + (0.2 * animation.value)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}