import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';

/// 신의 응답을 기다리는 신비로운 로딩 애니메이션
class DivineLoadingAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final int durationSeconds;

  const DivineLoadingAnimation({
    super.key,
    this.onComplete,
    this.durationSeconds = 4,
  });

  @override
  State<DivineLoadingAnimation> createState() => _DivineLoadingAnimationState();
}

class _DivineLoadingAnimationState extends State<DivineLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;

  int _currentStep = 0;
  final List<String> _loadingSteps = [
    '신께 소원을 전달하는 중...',
    '우주의 기운을 모으는 중...',
    '운명의 실을 찾는 중...',
    '신의 응답을 받는 중...',
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startLoadingSequence();
  }

  void _startLoadingSequence() async {
    final stepDuration = Duration(milliseconds: (widget.durationSeconds * 1000 / _loadingSteps.length).round());

    for (int i = 0; i < _loadingSteps.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentStep = i;
      });

      _fadeController.forward(from: 0);

      await Future.delayed(stepDuration);
    }

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1a1a2e),
                  const Color(0xFF16213e),
                  const Color(0xFF0f1624),
                ]
              : [
                  const Color(0xFFF0F4FF),
                  const Color(0xFFE6EDFF),
                  const Color(0xFFDBE4FF),
                ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 신비로운 원형 로더
            Stack(
              alignment: Alignment.center,
              children: [
                // 외부 회전 링
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * 3.141592,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _ArcPainter(
                            color: TossDesignSystem.tossBlue,
                            progress: _rotateController.value,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 중간 펄스 링
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.7 + (_pulseController.value * 0.2),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: TossDesignSystem.tossBlue.withValues(alpha: 0.1 + (_pulseController.value * 0.1)),
                        ),
                      ),
                    );
                  },
                ),

                // 중심 아이콘
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        TossDesignSystem.tossBlue,
                        TossDesignSystem.tossBlue.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TossDesignSystem.tossBlue.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 40,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 2000.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
              ],
            ),

            const SizedBox(height: 60),

            // 로딩 텍스트
            FadeTransition(
              opacity: _fadeController,
              child: Text(
                _loadingSteps[_currentStep],
                style: TextStyle(
                  color: isDark ? Colors.white : TossDesignSystem.grayDark900,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey(_currentStep))
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),
            ),

            const SizedBox(height: 20),

            // 프로그레스 바
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_currentStep + 1) / _loadingSteps.length,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.tossBlue,
                        TossDesignSystem.tossBlue.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ).animate()
                  .scaleX(
                    begin: 0,
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.centerLeft,
                  ),
              ),
            ),

            const SizedBox(height: 12),

            // 단계 표시
            Text(
              '${_currentStep + 1} / ${_loadingSteps.length}',
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 원호를 그리는 커스텀 페인터
class _ArcPainter extends CustomPainter {
  final Color color;
  final double progress;

  _ArcPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -3.141592 / 2; // -90도 (12시 방향)
    final sweepAngle = 2 * 3.141592 * 0.7; // 70% 원호

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
