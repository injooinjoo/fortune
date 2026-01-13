import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/face_detection_service.dart';

/// MediaPipe Face Mesh 468 랜드마크 오버레이
/// 흰색 메쉬 디자인으로 실시간 얼굴 추적 시각화
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
    this.accentColor = Colors.white, // 기본 흰색
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
          painter: _FaceMeshPainter(
            result: widget.detectionResult!,
            imageSize: widget.imageSize,
            cameraLensDirection: widget.cameraLensDirection,
            animationValue: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// MediaPipe Face Mesh 468 랜드마크 페인터 (흰색 디자인)
class _FaceMeshPainter extends CustomPainter {
  final FaceDetectionResult result;
  final Size imageSize;
  final CameraLensDirection cameraLensDirection;
  final double animationValue;

  _FaceMeshPainter({
    required this.result,
    required this.imageSize,
    required this.cameraLensDirection,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (result.landmarks == null || result.landmarks!.isEmpty) {
      return;
    }

    final landmarks = result.landmarks!;
    final scaleX = size.width;
    final scaleY = size.height;

    // 좌표 변환 (전면 카메라는 미러링)
    final isFront = cameraLensDirection == CameraLensDirection.front;

    // 모든 랜드마크를 화면 좌표로 변환
    final scaledPoints = landmarks.map((point) {
      final x = isFront ? (1.0 - point.dx) * scaleX : point.dx * scaleX;
      final y = point.dy * scaleY;
      return Offset(x, y);
    }).toList();

    // 메쉬 연결선 그리기 (삼각형 기반)
    _drawMeshTriangles(canvas, scaledPoints);

    // 랜드마크 포인트 그리기
    _drawLandmarkPoints(canvas, scaledPoints);

    // 얼굴 윤곽선 강조
    _drawFaceContour(canvas, scaledPoints);
  }

  /// 메쉬 삼각형 연결선 그리기
  void _drawMeshTriangles(Canvas canvas, List<Offset> points) {
    if (result.triangles == null || result.triangles!.isEmpty) {
      // 삼각형 정보가 없으면 FACEMESH_TESSELATION 사용
      _drawDefaultTesselation(canvas, points);
      return;
    }

    final meshPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 * animationValue)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (final triangle in result.triangles!) {
      if (triangle.indices.length >= 3) {
        final i0 = triangle.indices[0];
        final i1 = triangle.indices[1];
        final i2 = triangle.indices[2];

        if (i0 < points.length && i1 < points.length && i2 < points.length) {
          final path = Path()
            ..moveTo(points[i0].dx, points[i0].dy)
            ..lineTo(points[i1].dx, points[i1].dy)
            ..lineTo(points[i2].dx, points[i2].dy)
            ..close();
          canvas.drawPath(path, meshPaint);
        }
      }
    }
  }

  /// 기본 테셀레이션 패턴 그리기 (삼각형 정보 없을 때)
  void _drawDefaultTesselation(Canvas canvas, List<Offset> points) {
    final meshPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25 * animationValue)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // MediaPipe Face Mesh 주요 연결선 (간소화된 버전)
    final connections = _getSimplifiedConnections();

    for (final conn in connections) {
      if (conn[0] < points.length && conn[1] < points.length) {
        canvas.drawLine(points[conn[0]], points[conn[1]], meshPaint);
      }
    }
  }

  /// 랜드마크 포인트 그리기
  void _drawLandmarkPoints(Canvas canvas, List<Offset> points) {
    // 흰색 포인트
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6 * animationValue)
      ..style = PaintingStyle.fill;

    // 주요 랜드마크 (눈, 코, 입)는 더 크게
    final keyPoints = {
      FaceDetectionResult.leftEyeCenter,
      FaceDetectionResult.rightEyeCenter,
      FaceDetectionResult.noseTip,
      FaceDetectionResult.mouthTop,
      FaceDetectionResult.mouthBottom,
      FaceDetectionResult.leftEyeInner,
      FaceDetectionResult.leftEyeOuter,
      FaceDetectionResult.rightEyeInner,
      FaceDetectionResult.rightEyeOuter,
      FaceDetectionResult.mouthLeft,
      FaceDetectionResult.mouthRight,
    };

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isKeyPoint = keyPoints.contains(i);
      final radius = isKeyPoint ? 2.5 : 1.2;
      canvas.drawCircle(point, radius, dotPaint);
    }

    // 주요 포인트에 글로우 효과
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 * animationValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final keyIndex in keyPoints) {
      if (keyIndex < points.length) {
        canvas.drawCircle(points[keyIndex], 4, glowPaint);
      }
    }
  }

  /// 얼굴 윤곽선 강조
  void _drawFaceContour(Canvas canvas, List<Offset> points) {
    if (points.length < 468) return;

    final contourPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5 * animationValue)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 얼굴 외곽선 인덱스 (MediaPipe FACEMESH_FACE_OVAL)
    final faceOvalIndices = [
      10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288,
      397, 365, 379, 378, 400, 377, 152, 148, 176, 149, 150, 136,
      172, 58, 132, 93, 234, 127, 162, 21, 54, 103, 67, 109
    ];

    if (faceOvalIndices.every((i) => i < points.length)) {
      final path = Path();
      path.moveTo(points[faceOvalIndices[0]].dx, points[faceOvalIndices[0]].dy);

      for (int i = 1; i < faceOvalIndices.length; i++) {
        path.lineTo(points[faceOvalIndices[i]].dx, points[faceOvalIndices[i]].dy);
      }
      path.close();

      canvas.drawPath(path, contourPaint);
    }

    // 눈 윤곽선
    _drawEyeContour(canvas, points, contourPaint, isLeft: true);
    _drawEyeContour(canvas, points, contourPaint, isLeft: false);

    // 입술 윤곽선
    _drawLipsContour(canvas, points, contourPaint);
  }

  /// 눈 윤곽선 그리기
  void _drawEyeContour(Canvas canvas, List<Offset> points, Paint paint, {required bool isLeft}) {
    // MediaPipe 눈 인덱스
    final eyeIndices = isLeft
        ? [33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246]
        : [362, 382, 381, 380, 374, 373, 390, 249, 263, 466, 388, 387, 386, 385, 384, 398];

    if (!eyeIndices.every((i) => i < points.length)) return;

    final path = Path();
    path.moveTo(points[eyeIndices[0]].dx, points[eyeIndices[0]].dy);

    for (int i = 1; i < eyeIndices.length; i++) {
      path.lineTo(points[eyeIndices[i]].dx, points[eyeIndices[i]].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  /// 입술 윤곽선 그리기
  void _drawLipsContour(Canvas canvas, List<Offset> points, Paint paint) {
    // MediaPipe 입술 외곽 인덱스
    final outerLipsIndices = [
      61, 146, 91, 181, 84, 17, 314, 405, 321, 375, 291, 409, 270, 269, 267, 0, 37, 39, 40, 185
    ];

    if (!outerLipsIndices.every((i) => i < points.length)) return;

    final path = Path();
    path.moveTo(points[outerLipsIndices[0]].dx, points[outerLipsIndices[0]].dy);

    for (int i = 1; i < outerLipsIndices.length; i++) {
      path.lineTo(points[outerLipsIndices[i]].dx, points[outerLipsIndices[i]].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  /// 간소화된 연결선 목록
  List<List<int>> _getSimplifiedConnections() {
    // MediaPipe FACEMESH_TESSELATION 중 주요 연결만 추출
    return [
      // 얼굴 윤곽 (일부)
      [10, 338], [338, 297], [297, 332], [332, 284], [284, 251],
      [251, 389], [389, 356], [356, 454], [454, 323], [323, 361],
      [361, 288], [288, 397], [397, 365], [365, 379], [379, 378],
      [378, 400], [400, 377], [377, 152], [152, 148], [148, 176],
      [176, 149], [149, 150], [150, 136], [136, 172], [172, 58],
      [58, 132], [132, 93], [93, 234], [234, 127], [127, 162],
      [162, 21], [21, 54], [54, 103], [103, 67], [67, 109], [109, 10],

      // 눈썹 좌
      [70, 63], [63, 105], [105, 66], [66, 107],

      // 눈썹 우
      [336, 296], [296, 334], [334, 293], [293, 300],

      // 눈 좌
      [33, 133], [133, 173], [173, 157], [157, 158], [158, 159],
      [159, 160], [160, 161], [161, 246], [246, 33],

      // 눈 우
      [362, 263], [263, 466], [466, 388], [388, 387], [387, 386],
      [386, 385], [385, 384], [384, 398], [398, 362],

      // 코
      [168, 6], [6, 197], [197, 195], [195, 5], [5, 4],
      [4, 1], [1, 19], [19, 94], [94, 2],

      // 입
      [61, 185], [185, 40], [40, 39], [39, 37], [37, 0],
      [0, 267], [267, 269], [269, 270], [270, 409], [409, 291],
      [291, 375], [375, 321], [321, 405], [405, 314], [314, 17],
      [17, 84], [84, 181], [181, 91], [91, 146], [146, 61],
    ];
  }

  @override
  bool shouldRepaint(_FaceMeshPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.animationValue != animationValue;
  }
}

/// 얼굴 가이드 오버레이 (초기화 중 또는 가이드 모드)
class FaceGuideOverlay extends StatefulWidget {
  final Color accentColor;
  final VoidCallback? onCountdownComplete;
  final bool showCountdown;

  const FaceGuideOverlay({
    super.key,
    this.accentColor = Colors.white, // 기본 흰색
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
                child: _buildGuideFrame(_pulseAnimation.value),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideFrame(double animationValue) {
    return CustomPaint(
      painter: _FaceGuidePainter(
        accentColor: widget.accentColor,
        animationValue: animationValue,
      ),
      size: const Size(280, 380),
    );
  }
}

/// 얼굴 가이드 프레임 페인터 (흰색 디자인)
class _FaceGuidePainter extends CustomPainter {
  final Color accentColor;
  final double animationValue;

  _FaceGuidePainter({
    required this.accentColor,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 글로우 효과
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3 * animationValue)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // 타원형 가이드
    canvas.drawOval(rect, glowPaint);

    // 메인 프레임
    final framePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8 * animationValue)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawOval(rect, framePaint);

    // 간단한 십자선 가이드
    final center = Offset(size.width / 2, size.height / 2);
    final guidePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4 * animationValue)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 세로선
    canvas.drawLine(
      Offset(center.dx, center.dy - 30),
      Offset(center.dx, center.dy + 30),
      guidePaint,
    );

    // 가로선
    canvas.drawLine(
      Offset(center.dx - 25, center.dy),
      Offset(center.dx + 25, center.dy),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(_FaceGuidePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
