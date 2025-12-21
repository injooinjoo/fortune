import 'package:flutter/material.dart';

/// Face Mesh 타입
enum FaceMeshType {
  front, // 정면
  side,  // 측면
}

/// Face Mesh 시각적 효과 위젯
/// 관상 분석 화면에서 폴리곤 와이어프레임 얼굴을 표시
class FaceMeshOverlay extends StatefulWidget {
  final FaceMeshType type;
  final Color meshColor;
  final double size;
  final bool animate;

  const FaceMeshOverlay({
    super.key,
    this.type = FaceMeshType.front,
    this.meshColor = const Color(0xFF00D9D9), // 사이언 색상
    this.size = 150,
    this.animate = true,
  });

  @override
  State<FaceMeshOverlay> createState() => _FaceMeshOverlayState();
}

class _FaceMeshOverlayState extends State<FaceMeshOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
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
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.8),
            boxShadow: widget.animate
                ? [
                    BoxShadow(
                      color: widget.meshColor.withValues(alpha: _glowAnimation.value * 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: widget.type == FaceMeshType.front
                  ? _FrontFaceMeshPainter(
                      meshColor: widget.meshColor,
                      glowIntensity: widget.animate ? _glowAnimation.value : 0.5,
                    )
                  : _SideFaceMeshPainter(
                      meshColor: widget.meshColor,
                      glowIntensity: widget.animate ? _glowAnimation.value : 0.5,
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// 정면 얼굴 메쉬 페인터
class _FrontFaceMeshPainter extends CustomPainter {
  final Color meshColor;
  final double glowIntensity;

  _FrontFaceMeshPainter({
    required this.meshColor,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = meshColor.withValues(alpha: glowIntensity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = meshColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;

    // 정면 얼굴 포인트들 (단순화된 버전)
    final points = _getFrontFacePoints(center, scale);

    // 점들 그리기
    for (final point in points) {
      canvas.drawCircle(point, 2 * scale, dotPaint);
    }

    // 메쉬 선들 그리기
    _drawFrontFaceMesh(canvas, paint, points, scale);
  }

  List<Offset> _getFrontFacePoints(Offset center, double scale) {
    return [
      // 얼굴 윤곽 (외곽)
      center + Offset(0, -80 * scale),      // 0: 이마 상단
      center + Offset(-30, -70 * scale),    // 1: 이마 좌
      center + Offset(30, -70 * scale),     // 2: 이마 우
      center + Offset(-50, -40 * scale),    // 3: 관자놀이 좌
      center + Offset(50, -40 * scale),     // 4: 관자놀이 우
      center + Offset(-55, 0 * scale),      // 5: 광대 좌
      center + Offset(55, 0 * scale),       // 6: 광대 우
      center + Offset(-45, 40 * scale),     // 7: 턱선 좌
      center + Offset(45, 40 * scale),      // 8: 턱선 우
      center + Offset(-25, 65 * scale),     // 9: 하관 좌
      center + Offset(25, 65 * scale),      // 10: 하관 우
      center + Offset(0, 80 * scale),       // 11: 턱 끝

      // 눈 영역
      center + Offset(-30, -25 * scale),    // 12: 좌안 외측
      center + Offset(-15, -25 * scale),    // 13: 좌안 내측
      center + Offset(15, -25 * scale),     // 14: 우안 내측
      center + Offset(30, -25 * scale),     // 15: 우안 외측
      center + Offset(-22, -30 * scale),    // 16: 좌안 상단
      center + Offset(-22, -20 * scale),    // 17: 좌안 하단
      center + Offset(22, -30 * scale),     // 18: 우안 상단
      center + Offset(22, -20 * scale),     // 19: 우안 하단

      // 코
      center + Offset(0, -15 * scale),      // 20: 콧대 상단
      center + Offset(0, 5 * scale),        // 21: 콧대 중간
      center + Offset(-12, 15 * scale),     // 22: 콧볼 좌
      center + Offset(12, 15 * scale),      // 23: 콧볼 우
      center + Offset(0, 18 * scale),       // 24: 코끝

      // 입
      center + Offset(-20, 35 * scale),     // 25: 입꼬리 좌
      center + Offset(20, 35 * scale),      // 26: 입꼬리 우
      center + Offset(0, 30 * scale),       // 27: 윗입술 중앙
      center + Offset(0, 42 * scale),       // 28: 아랫입술 중앙
      center + Offset(-10, 33 * scale),     // 29: 윗입술 좌
      center + Offset(10, 33 * scale),      // 30: 윗입술 우

      // 눈썹
      center + Offset(-35, -40 * scale),    // 31: 좌 눈썹 외측
      center + Offset(-10, -38 * scale),    // 32: 좌 눈썹 내측
      center + Offset(10, -38 * scale),     // 33: 우 눈썹 내측
      center + Offset(35, -40 * scale),     // 34: 우 눈썹 외측
    ];
  }

  void _drawFrontFaceMesh(Canvas canvas, Paint paint, List<Offset> p, double scale) {
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

    // 내부 메쉬 (삼각형들)
    _drawLine(canvas, paint, p[1], p[2]);
    _drawLine(canvas, paint, p[3], p[4]);
    _drawLine(canvas, paint, p[5], p[6]);
    _drawLine(canvas, paint, p[7], p[8]);

    // 이마 영역
    _drawLine(canvas, paint, p[0], p[31]);
    _drawLine(canvas, paint, p[0], p[34]);
    _drawLine(canvas, paint, p[31], p[32]);
    _drawLine(canvas, paint, p[33], p[34]);

    // 눈 영역
    _drawLine(canvas, paint, p[12], p[16]);
    _drawLine(canvas, paint, p[16], p[13]);
    _drawLine(canvas, paint, p[13], p[17]);
    _drawLine(canvas, paint, p[17], p[12]);
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

    // 대각선 메쉬
    _drawLine(canvas, paint, p[3], p[12]);
    _drawLine(canvas, paint, p[4], p[15]);
    _drawLine(canvas, paint, p[5], p[22]);
    _drawLine(canvas, paint, p[6], p[23]);
    _drawLine(canvas, paint, p[7], p[25]);
    _drawLine(canvas, paint, p[8], p[26]);
  }

  void _drawLine(Canvas canvas, Paint paint, Offset p1, Offset p2) {
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant _FrontFaceMeshPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}

/// 측면 얼굴 메쉬 페인터
class _SideFaceMeshPainter extends CustomPainter {
  final Color meshColor;
  final double glowIntensity;

  _SideFaceMeshPainter({
    required this.meshColor,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = meshColor.withValues(alpha: glowIntensity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = meshColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;

    // 측면 얼굴 포인트들
    final points = _getSideFacePoints(center, scale);

    // 점들 그리기
    for (final point in points) {
      canvas.drawCircle(point, 2 * scale, dotPaint);
    }

    // 메쉬 선들 그리기
    _drawSideFaceMesh(canvas, paint, points);
  }

  List<Offset> _getSideFacePoints(Offset center, double scale) {
    // 오른쪽을 바라보는 측면
    return [
      // 머리 윤곽
      center + Offset(-10, -80 * scale),    // 0: 두정부
      center + Offset(-30, -60 * scale),    // 1: 뒤통수 상단
      center + Offset(-40, -30 * scale),    // 2: 뒤통수
      center + Offset(-35, 10 * scale),     // 3: 뒷목
      center + Offset(-25, 40 * scale),     // 4: 목 뒤

      // 얼굴 앞면 윤곽
      center + Offset(20, -70 * scale),     // 5: 이마
      center + Offset(35, -45 * scale),     // 6: 눈썹 앞
      center + Offset(40, -25 * scale),     // 7: 눈 위치
      center + Offset(50, -5 * scale),      // 8: 코 시작
      center + Offset(60, 10 * scale),      // 9: 코끝
      center + Offset(45, 20 * scale),      // 10: 인중
      center + Offset(40, 35 * scale),      // 11: 입
      center + Offset(25, 55 * scale),      // 12: 턱
      center + Offset(0, 70 * scale),       // 13: 턱 끝
      center + Offset(-20, 60 * scale),     // 14: 턱선 아래
      center + Offset(-10, 50 * scale),     // 15: 목 앞

      // 귀
      center + Offset(-5, -25 * scale),     // 16: 귀 상단
      center + Offset(0, -10 * scale),      // 17: 귀 중간
      center + Offset(-5, 5 * scale),       // 18: 귀 하단

      // 내부 메쉬 포인트
      center + Offset(10, -40 * scale),     // 19: 이마 내부
      center + Offset(20, -15 * scale),     // 20: 눈-코 사이
      center + Offset(15, 15 * scale),      // 21: 코-입 사이
      center + Offset(5, 40 * scale),       // 22: 입-턱 사이
    ];
  }

  void _drawSideFaceMesh(Canvas canvas, Paint paint, List<Offset> p) {
    // 머리 윤곽 (뒤에서 앞으로)
    _drawLine(canvas, paint, p[0], p[1]);
    _drawLine(canvas, paint, p[1], p[2]);
    _drawLine(canvas, paint, p[2], p[3]);
    _drawLine(canvas, paint, p[3], p[4]);

    // 얼굴 앞 윤곽
    _drawLine(canvas, paint, p[0], p[5]);
    _drawLine(canvas, paint, p[5], p[6]);
    _drawLine(canvas, paint, p[6], p[7]);
    _drawLine(canvas, paint, p[7], p[8]);
    _drawLine(canvas, paint, p[8], p[9]);
    _drawLine(canvas, paint, p[9], p[10]);
    _drawLine(canvas, paint, p[10], p[11]);
    _drawLine(canvas, paint, p[11], p[12]);
    _drawLine(canvas, paint, p[12], p[13]);
    _drawLine(canvas, paint, p[13], p[14]);
    _drawLine(canvas, paint, p[14], p[15]);
    _drawLine(canvas, paint, p[15], p[4]);

    // 귀 영역
    _drawLine(canvas, paint, p[16], p[17]);
    _drawLine(canvas, paint, p[17], p[18]);
    _drawLine(canvas, paint, p[16], p[2]);
    _drawLine(canvas, paint, p[18], p[3]);

    // 내부 메쉬
    _drawLine(canvas, paint, p[5], p[19]);
    _drawLine(canvas, paint, p[19], p[0]);
    _drawLine(canvas, paint, p[19], p[16]);
    _drawLine(canvas, paint, p[6], p[20]);
    _drawLine(canvas, paint, p[20], p[17]);
    _drawLine(canvas, paint, p[7], p[20]);
    _drawLine(canvas, paint, p[20], p[21]);
    _drawLine(canvas, paint, p[10], p[21]);
    _drawLine(canvas, paint, p[21], p[18]);
    _drawLine(canvas, paint, p[11], p[22]);
    _drawLine(canvas, paint, p[22], p[15]);
    _drawLine(canvas, paint, p[12], p[22]);
  }

  void _drawLine(Canvas canvas, Paint paint, Offset p1, Offset p2) {
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant _SideFaceMeshPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}

/// Face Mesh 2개를 나란히 보여주는 위젯
class DualFaceMeshDisplay extends StatelessWidget {
  final Color meshColor;
  final double size;
  final bool animate;

  const DualFaceMeshDisplay({
    super.key,
    this.meshColor = const Color(0xFF00D9D9),
    this.size = 120,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaceMeshOverlay(
          type: FaceMeshType.side,
          meshColor: meshColor,
          size: size,
          animate: animate,
        ),
        const SizedBox(width: 16),
        FaceMeshOverlay(
          type: FaceMeshType.front,
          meshColor: meshColor,
          size: size,
          animate: animate,
        ),
      ],
    );
  }
}
