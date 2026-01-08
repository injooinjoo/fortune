import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/face_detection_service.dart';

/// 얼굴 감지 결과 오버레이 (바운딩 박스)
/// iOS Vision Framework 결과를 시각화합니다.
class FaceDetectionOverlay extends StatefulWidget {
  final FaceDetectionResult? detectionResult;
  final Size imageSize;
  final CameraLensDirection cameraLensDirection;
  final Color accentColor;
  final bool enablePulse;

  const FaceDetectionOverlay({
    super.key,
    this.detectionResult,
    required this.imageSize,
    required this.cameraLensDirection,
    this.accentColor = const Color(0xFF00FFFF),
    this.enablePulse = true,
  });

  @override
  State<FaceDetectionOverlay> createState() => _FaceDetectionOverlayState();
}

class _FaceDetectionOverlayState extends State<FaceDetectionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.enablePulse) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.detectionResult == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _FaceBoundingBoxPainter(
            result: widget.detectionResult!,
            imageSize: widget.imageSize,
            cameraLensDirection: widget.cameraLensDirection,
            accentColor: widget.accentColor,
            animationValue: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 바운딩 박스 페인터
class _FaceBoundingBoxPainter extends CustomPainter {
  final FaceDetectionResult result;
  final Size imageSize;
  final CameraLensDirection cameraLensDirection;
  final Color accentColor;
  final double animationValue;

  _FaceBoundingBoxPainter({
    required this.result,
    required this.imageSize,
    required this.cameraLensDirection,
    required this.accentColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 스케일 계산
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // 좌표 변환
    double x = result.x;
    double y = result.y;
    double w = result.width;
    double h = result.height;

    // 전면 카메라 미러링
    if (cameraLensDirection == CameraLensDirection.front) {
      x = imageSize.width - x - w;
    }

    final rect = Rect.fromLTWH(
      x * scaleX,
      y * scaleY,
      w * scaleX,
      h * scaleY,
    );

    // 글로우 효과
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3 * animationValue)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      glowPaint,
    );

    // 메인 바운딩 박스
    final boxPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.9 * animationValue)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      boxPaint,
    );

    // 코너 강조
    _drawCorners(canvas, rect, boxPaint);

    // 신뢰도 표시
    _drawConfidence(canvas, rect, size);
  }

  void _drawCorners(Canvas canvas, Rect rect, Paint paint) {
    final cornerLength = rect.width * 0.15;
    final cornerPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 좌상단
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // 우상단
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // 좌하단
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // 우하단
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );
  }

  void _drawConfidence(Canvas canvas, Rect rect, Size size) {
    final confidencePercent = (result.confidence * 100).toInt();
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$confidencePercent%',
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.right - textPainter.width - 16,
        rect.top - textPainter.height - 8,
        textPainter.width + 12,
        textPainter.height + 4,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      bgRect,
      Paint()..color = Colors.black54,
    );

    textPainter.paint(
      canvas,
      Offset(rect.right - textPainter.width - 10, rect.top - textPainter.height - 6),
    );
  }

  @override
  bool shouldRepaint(_FaceBoundingBoxPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.animationValue != animationValue;
  }
}

/// 얼굴 가이드 오버레이 (Android용)
/// 실제 감지 없이 가이드만 표시합니다.
class FaceGuideOverlay extends StatefulWidget {
  final Color accentColor;
  final VoidCallback? onCountdownComplete;
  final bool showCountdown;

  const FaceGuideOverlay({
    super.key,
    this.accentColor = const Color(0xFF00FFFF),
    this.onCountdownComplete,
    this.showCountdown = false,
  });

  @override
  State<FaceGuideOverlay> createState() => _FaceGuideOverlayState();
}

class _FaceGuideOverlayState extends State<FaceGuideOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late Animation<double> _pulseAnimation;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    if (widget.showCountdown) {
      _startCountdown();
    }

    _countdownController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  void _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    widget.onCountdownComplete?.call();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 얼굴 가이드 프레임
        Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildGuideFrame(),
              );
            },
          ),
        ),

        // 안내 텍스트
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.showCountdown && _countdown > 0
                    ? '$_countdown초 후 촬영됩니다'
                    : '얼굴을 가이드 안에 맞춰주세요',
                style: TextStyle(
                  color: widget.accentColor,
                  fontSize: 14, // 예외: 카메라 UI
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideFrame() {
    return CustomPaint(
      painter: _FaceGuidePainter(accentColor: widget.accentColor),
      size: const Size(280, 380),
    );
  }
}

/// 얼굴 가이드 프레임 페인터
class _FaceGuidePainter extends CustomPainter {
  final Color accentColor;

  _FaceGuidePainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 글로우 효과
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // 타원형 가이드
    canvas.drawOval(rect, glowPaint);

    // 메인 프레임
    final framePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawOval(rect, framePaint);

    // 십자 가이드
    final crossPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    // 가로선
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.5),
      crossPaint,
    );

    // 세로선
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.7),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(_FaceGuidePainter oldDelegate) => false;
}
