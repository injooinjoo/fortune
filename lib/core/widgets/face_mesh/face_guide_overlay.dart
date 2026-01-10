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

/// 바운딩 박스 페인터 + Face Mesh 오버레이
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
    final double y = result.y;
    final double w = result.width;
    final double h = result.height;
    final double x = cameraLensDirection == CameraLensDirection.front
        ? imageSize.width - result.x - w
        : result.x;

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

    // ✨ Face Mesh 오버레이 그리기
    _drawFaceMesh(canvas, rect);

    // 코너 강조
    _drawCorners(canvas, rect, boxPaint);

    // 신뢰도 표시
    _drawConfidence(canvas, rect, size);
  }

  /// 얼굴 메쉬 오버레이 그리기
  void _drawFaceMesh(Canvas canvas, Rect faceRect) {
    final meshPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6 * animationValue)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8 * animationValue)
      ..style = PaintingStyle.fill;

    // 얼굴 바운딩 박스 중심과 스케일 계산
    final center = faceRect.center;
    final scaleW = faceRect.width / 200;
    final scaleH = faceRect.height / 260;

    // 메쉬 포인트 생성 (바운딩 박스에 맞춰 스케일)
    final points = _getFaceMeshPoints(center, scaleW, scaleH);

    // 포인트 그리기
    for (final point in points) {
      canvas.drawCircle(point, 2.5 * scaleW, dotPaint);
    }

    // 메쉬 연결선 그리기
    _drawMeshLines(canvas, meshPaint, points);
  }

  List<Offset> _getFaceMeshPoints(Offset center, double scaleW, double scaleH) {
    return [
      // 얼굴 윤곽 (외곽) - 0~11
      center + Offset(0, -100 * scaleH),           // 0: 이마 상단
      center + Offset(-40 * scaleW, -85 * scaleH), // 1: 이마 좌
      center + Offset(40 * scaleW, -85 * scaleH),  // 2: 이마 우
      center + Offset(-60 * scaleW, -50 * scaleH), // 3: 관자놀이 좌
      center + Offset(60 * scaleW, -50 * scaleH),  // 4: 관자놀이 우
      center + Offset(-70 * scaleW, 0),            // 5: 광대 좌
      center + Offset(70 * scaleW, 0),             // 6: 광대 우
      center + Offset(-55 * scaleW, 50 * scaleH),  // 7: 턱선 좌
      center + Offset(55 * scaleW, 50 * scaleH),   // 8: 턱선 우
      center + Offset(-30 * scaleW, 80 * scaleH),  // 9: 하관 좌
      center + Offset(30 * scaleW, 80 * scaleH),   // 10: 하관 우
      center + Offset(0, 100 * scaleH),            // 11: 턱 끝

      // 눈 영역 - 12~19
      center + Offset(-38 * scaleW, -30 * scaleH), // 12: 좌안 외측
      center + Offset(-18 * scaleW, -30 * scaleH), // 13: 좌안 내측
      center + Offset(18 * scaleW, -30 * scaleH),  // 14: 우안 내측
      center + Offset(38 * scaleW, -30 * scaleH),  // 15: 우안 외측
      center + Offset(-28 * scaleW, -38 * scaleH), // 16: 좌안 상단
      center + Offset(-28 * scaleW, -22 * scaleH), // 17: 좌안 하단
      center + Offset(28 * scaleW, -38 * scaleH),  // 18: 우안 상단
      center + Offset(28 * scaleW, -22 * scaleH),  // 19: 우안 하단

      // 코 - 20~24
      center + Offset(0, -18 * scaleH),            // 20: 콧대 상단
      center + Offset(0, 5 * scaleH),              // 21: 콧대 중간
      center + Offset(-15 * scaleW, 18 * scaleH),  // 22: 콧볼 좌
      center + Offset(15 * scaleW, 18 * scaleH),   // 23: 콧볼 우
      center + Offset(0, 22 * scaleH),             // 24: 코끝

      // 입 - 25~30
      center + Offset(-25 * scaleW, 42 * scaleH),  // 25: 입꼬리 좌
      center + Offset(25 * scaleW, 42 * scaleH),   // 26: 입꼬리 우
      center + Offset(0, 36 * scaleH),             // 27: 윗입술 중앙
      center + Offset(0, 52 * scaleH),             // 28: 아랫입술 중앙
      center + Offset(-12 * scaleW, 40 * scaleH),  // 29: 윗입술 좌
      center + Offset(12 * scaleW, 40 * scaleH),   // 30: 윗입술 우

      // 눈썹 - 31~34
      center + Offset(-45 * scaleW, -50 * scaleH), // 31: 좌 눈썹 외측
      center + Offset(-12 * scaleW, -48 * scaleH), // 32: 좌 눈썹 내측
      center + Offset(12 * scaleW, -48 * scaleH),  // 33: 우 눈썹 내측
      center + Offset(45 * scaleW, -50 * scaleH),  // 34: 우 눈썹 외측
    ];
  }

  void _drawMeshLines(Canvas canvas, Paint paint, List<Offset> p) {
    // 얼굴 윤곽 연결
    _drawLine(canvas, paint, p[0], p[1]);
    _drawLine(canvas, paint, p[0], p[2]);
    _drawLine(canvas, paint, p[1], p[3]);
    _drawLine(canvas, paint, p[2], p[4]);
    _drawLine(canvas, paint, p[3], p[5]);
    _drawLine(canvas, paint, p[4], p[6]);
    _drawLine(canvas, paint, p[5], p[7]);
    _drawLine(canvas, paint, p[6], p[8]);
    _drawLine(canvas, paint, p[7], p[9]);
    _drawLine(canvas, paint, p[8], p[10]);
    _drawLine(canvas, paint, p[9], p[11]);
    _drawLine(canvas, paint, p[10], p[11]);

    // 내부 가로 메쉬
    _drawLine(canvas, paint, p[1], p[2]);
    _drawLine(canvas, paint, p[3], p[4]);
    _drawLine(canvas, paint, p[5], p[6]);
    _drawLine(canvas, paint, p[7], p[8]);

    // 눈썹 영역
    _drawLine(canvas, paint, p[0], p[31]);
    _drawLine(canvas, paint, p[0], p[34]);
    _drawLine(canvas, paint, p[31], p[32]);
    _drawLine(canvas, paint, p[33], p[34]);
    _drawLine(canvas, paint, p[32], p[33]);

    // 눈 영역 - 좌
    _drawLine(canvas, paint, p[12], p[16]);
    _drawLine(canvas, paint, p[16], p[13]);
    _drawLine(canvas, paint, p[13], p[17]);
    _drawLine(canvas, paint, p[17], p[12]);
    // 눈 영역 - 우
    _drawLine(canvas, paint, p[14], p[18]);
    _drawLine(canvas, paint, p[18], p[15]);
    _drawLine(canvas, paint, p[15], p[19]);
    _drawLine(canvas, paint, p[19], p[14]);

    // 코 영역
    _drawLine(canvas, paint, p[13], p[20]);
    _drawLine(canvas, paint, p[14], p[20]);
    _drawLine(canvas, paint, p[20], p[21]);
    _drawLine(canvas, paint, p[21], p[22]);
    _drawLine(canvas, paint, p[21], p[23]);
    _drawLine(canvas, paint, p[22], p[24]);
    _drawLine(canvas, paint, p[23], p[24]);

    // 입 영역
    _drawLine(canvas, paint, p[25], p[29]);
    _drawLine(canvas, paint, p[29], p[27]);
    _drawLine(canvas, paint, p[27], p[30]);
    _drawLine(canvas, paint, p[30], p[26]);
    _drawLine(canvas, paint, p[25], p[28]);
    _drawLine(canvas, paint, p[26], p[28]);

    // 대각선 연결 (삼각형 메쉬)
    _drawLine(canvas, paint, p[3], p[12]);
    _drawLine(canvas, paint, p[4], p[15]);
    _drawLine(canvas, paint, p[5], p[17]);
    _drawLine(canvas, paint, p[6], p[19]);
    _drawLine(canvas, paint, p[5], p[22]);
    _drawLine(canvas, paint, p[6], p[23]);
    _drawLine(canvas, paint, p[7], p[25]);
    _drawLine(canvas, paint, p[8], p[26]);
    _drawLine(canvas, paint, p[9], p[28]);
    _drawLine(canvas, paint, p[10], p[28]);
  }

  void _drawLine(Canvas canvas, Paint paint, Offset p1, Offset p2) {
    canvas.drawLine(p1, p2, paint);
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
