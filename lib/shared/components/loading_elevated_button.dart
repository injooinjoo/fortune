import 'package:flutter/material.dart';

/// 로딩 애니메이션이 있는 ElevatedButton
/// 광고 로딩 중에는 점 3개 애니메이션을 표시하고 버튼을 비활성화합니다.
class LoadingElevatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isLoading;
  final String? loadingText;

  const LoadingElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isLoading = false,
    this.loadingText,
  });

  @override
  State<LoadingElevatedButton> createState() => _LoadingElevatedButtonState();
}

class _LoadingElevatedButtonState extends State<LoadingElevatedButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LoadingElevatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: widget.style,
      child: widget.isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.loadingText != null) ...[
                  Text(widget.loadingText!),
                  const SizedBox(width: 8),
                ],
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(0),
                        const SizedBox(width: 4),
                        _buildDot(1),
                        const SizedBox(width: 4),
                        _buildDot(2),
                      ],
                    );
                  },
                ),
              ],
            )
          : widget.child,
    );
  }

  Widget _buildDot(int index) {
    final delay = index * 0.2;
    final progress = (_animation.value + delay) % 1.0;
    final theme = Theme.of(context);

    double opacity;
    if (progress < 0.5) {
      opacity = progress * 2; // 0 to 1
    } else {
      opacity = 2 - (progress * 2); // 1 to 0
    }

    opacity = opacity.clamp(0.3, 1.0);

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.onPrimary.withValues(alpha: opacity),
      ),
    );
  }
}

/// StatefulWidget를 사용하는 페이지에서 쉽게 사용할 수 있는 Stateful 로딩 버튼
class StatefulLoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final ButtonStyle? style;
  final String? loadingText;

  const StatefulLoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.loadingText,
  });

  @override
  State<StatefulLoadingButton> createState() => _StatefulLoadingButtonState();
}

class _StatefulLoadingButtonState extends State<StatefulLoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LoadingElevatedButton(
      isLoading: _isLoading,
      loadingText: widget.loadingText,
      style: widget.style,
      onPressed: _isLoading ? null : _handlePress,
      child: widget.child,
    );
  }

  Future<void> _handlePress() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}