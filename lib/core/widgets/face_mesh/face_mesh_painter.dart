import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

/// Face Mesh 시각화 CustomPainter
/// 얼굴에 3D 모델링 스타일의 점과 선을 그립니다.
class FaceMeshPainter extends CustomPainter {
  final List<FaceMesh> meshes;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final Color meshColor;
  final double pointRadius;
  final double lineWidth;
  final bool showPoints;
  final bool showTriangles;
  final double animationValue;

  FaceMeshPainter({
    required this.meshes,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
    this.meshColor = const Color(0xFF00FFFF),
    this.pointRadius = 2.0,
    this.lineWidth = 0.5,
    this.showPoints = true,
    this.showTriangles = true,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 점 페인트
    final pointPaint = Paint()
      ..color = meshColor.withValues(alpha: 0.9 * animationValue)
      ..style = PaintingStyle.fill;

    // 선 페인트 (글로우 효과)
    final linePaint = Paint()
      ..color = meshColor.withValues(alpha: 0.6 * animationValue)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // 글로우 페인트
    final glowPaint = Paint()
      ..color = meshColor.withValues(alpha: 0.2 * animationValue)
      ..strokeWidth = lineWidth * 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final mesh in meshes) {
      final points = mesh.points;
      final triangles = mesh.triangles;

      // 좌표 변환된 포인트 리스트
      final scaledPoints = <Offset>[];
      for (final point in points) {
        final scaledPoint = _scalePoint(
          point: Offset(point.x.toDouble(), point.y.toDouble()),
          imageSize: imageSize,
          widgetSize: size,
          rotation: rotation,
          cameraLensDirection: cameraLensDirection,
        );
        scaledPoints.add(scaledPoint);
      }

      // 삼각형 그리기 (글로우 + 라인)
      if (showTriangles) {
        for (final triangle in triangles) {
          final triPoints = triangle.points;
          if (triPoints.length >= 3) {
            // 삼각형의 각 점을 직접 변환
            final p1 = _scalePoint(
              point: Offset(triPoints[0].x.toDouble(), triPoints[0].y.toDouble()),
              imageSize: imageSize,
              widgetSize: size,
              rotation: rotation,
              cameraLensDirection: cameraLensDirection,
            );
            final p2 = _scalePoint(
              point: Offset(triPoints[1].x.toDouble(), triPoints[1].y.toDouble()),
              imageSize: imageSize,
              widgetSize: size,
              rotation: rotation,
              cameraLensDirection: cameraLensDirection,
            );
            final p3 = _scalePoint(
              point: Offset(triPoints[2].x.toDouble(), triPoints[2].y.toDouble()),
              imageSize: imageSize,
              widgetSize: size,
              rotation: rotation,
              cameraLensDirection: cameraLensDirection,
            );

            final path = Path()
              ..moveTo(p1.dx, p1.dy)
              ..lineTo(p2.dx, p2.dy)
              ..lineTo(p3.dx, p3.dy)
              ..close();

            // 글로우 효과
            canvas.drawPath(path, glowPaint);
            // 메인 라인
            canvas.drawPath(path, linePaint);
          }
        }
      }

      // 포인트 그리기
      if (showPoints) {
        for (final point in scaledPoints) {
          // 외부 글로우
          canvas.drawCircle(
            point,
            pointRadius * 2,
            Paint()
              ..color = meshColor.withValues(alpha: 0.3 * animationValue)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
          // 메인 포인트
          canvas.drawCircle(point, pointRadius, pointPaint);
        }
      }
    }
  }

  /// 좌표 변환: 이미지 좌표 → 위젯 좌표
  Offset _scalePoint({
    required Offset point,
    required Size imageSize,
    required Size widgetSize,
    required InputImageRotation rotation,
    required CameraLensDirection cameraLensDirection,
  }) {
    double x = point.dx;
    double y = point.dy;

    // 이미지 회전 처리
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        final temp = x;
        x = y;
        y = imageSize.width - temp;
        break;
      case InputImageRotation.rotation180deg:
        x = imageSize.width - x;
        y = imageSize.height - y;
        break;
      case InputImageRotation.rotation270deg:
        final temp = x;
        x = imageSize.height - y;
        y = temp;
        break;
      case InputImageRotation.rotation0deg:
        break;
    }

    // 스케일 계산
    final scaleX = widgetSize.width / imageSize.width;
    final scaleY = widgetSize.height / imageSize.height;

    // 전면 카메라 미러링
    if (cameraLensDirection == CameraLensDirection.front) {
      x = imageSize.width - x;
    }

    return Offset(x * scaleX, y * scaleY);
  }

  @override
  bool shouldRepaint(FaceMeshPainter oldDelegate) {
    return oldDelegate.meshes != meshes ||
        oldDelegate.animationValue != animationValue;
  }
}

/// Face Mesh 오버레이 위젯 (애니메이션 포함)
class FaceMeshOverlay extends StatefulWidget {
  final List<FaceMesh> meshes;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final Color meshColor;
  final bool enablePulse;

  const FaceMeshOverlay({
    super.key,
    required this.meshes,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
    this.meshColor = const Color(0xFF00FFFF),
    this.enablePulse = true,
  });

  @override
  State<FaceMeshOverlay> createState() => _FaceMeshOverlayState();
}

class _FaceMeshOverlayState extends State<FaceMeshOverlay>
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: FaceMeshPainter(
            meshes: widget.meshes,
            imageSize: widget.imageSize,
            rotation: widget.rotation,
            cameraLensDirection: widget.cameraLensDirection,
            meshColor: widget.meshColor,
            animationValue: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
