import 'package:flutter/material.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 얼굴 부위별 운세 오버레이
/// 카메라 화면에 얼굴 부위와 관련 운세를 표시합니다.
/// 귀→재물운, 코→결혼운, 눈→인간관계
class FaceZoneOverlay extends StatelessWidget {
  /// 오버레이 표시 여부
  final bool showLabels;

  /// 강조할 부위 (선택적)
  final String? highlightedZone;

  /// 애니메이션 활성화
  final bool animate;

  const FaceZoneOverlay({
    super.key,
    this.showLabels = true,
    this.highlightedZone,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 얼굴 가이드 프레임
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _FaceGuideFramePainter(
                highlightedZone: highlightedZone,
              ),
            ),

            // 부위별 라벨
            if (showLabels) ...[
              // 이마 (명궁)
              _buildZoneLabel(
                context,
                constraints,
                zone: 'forehead',
                label: '명궁',
                fortune: '인생 운',
                emoji: '✨',
                position: const Alignment(0, -0.55),
              ),

              // 눈 (좌)
              _buildZoneLabel(
                context,
                constraints,
                zone: 'left_eye',
                label: '눈',
                fortune: '인간관계',
                emoji: '👁️',
                position: const Alignment(-0.35, -0.2),
              ),

              // 눈 (우)
              _buildZoneLabel(
                context,
                constraints,
                zone: 'right_eye',
                label: '눈',
                fortune: '인간관계',
                emoji: '👁️',
                position: const Alignment(0.35, -0.2),
              ),

              // 코
              _buildZoneLabel(
                context,
                constraints,
                zone: 'nose',
                label: '코',
                fortune: '결혼운',
                emoji: '👃',
                position: const Alignment(0, 0.05),
              ),

              // 귀 (좌)
              _buildZoneLabel(
                context,
                constraints,
                zone: 'left_ear',
                label: '귀',
                fortune: '재물운',
                emoji: '👂',
                position: const Alignment(-0.65, -0.1),
              ),

              // 귀 (우)
              _buildZoneLabel(
                context,
                constraints,
                zone: 'right_ear',
                label: '귀',
                fortune: '재물운',
                emoji: '👂',
                position: const Alignment(0.65, -0.1),
              ),

              // 입
              _buildZoneLabel(
                context,
                constraints,
                zone: 'mouth',
                label: '입술',
                fortune: '식복',
                emoji: '👄',
                position: const Alignment(0, 0.35),
              ),

              // 턱
              _buildZoneLabel(
                context,
                constraints,
                zone: 'chin',
                label: '턱',
                fortune: '말년운',
                emoji: '🔮',
                position: const Alignment(0, 0.55),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildZoneLabel(
    BuildContext context,
    BoxConstraints constraints, {
    required String zone,
    required String label,
    required String fortune,
    required String emoji,
    required Alignment position,
  }) {
    final isHighlighted = highlightedZone == zone;
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;

    final left = centerX + (position.x * centerX) - 35;
    final top = centerY + (position.y * centerY) - 20;

    return Positioned(
      left: left.clamp(0, constraints.maxWidth - 70),
      top: top.clamp(0, constraints.maxHeight - 40),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isHighlighted || highlightedZone == null ? 1.0 : 0.4,
        child: _ZoneLabelChip(
          label: label,
          fortune: fortune,
          emoji: emoji,
          isHighlighted: isHighlighted,
          animate: animate,
        ),
      ),
    );
  }
}

/// 부위 라벨 칩
class _ZoneLabelChip extends StatefulWidget {
  final String label;
  final String fortune;
  final String emoji;
  final bool isHighlighted;
  final bool animate;

  const _ZoneLabelChip({
    required this.label,
    required this.fortune,
    required this.emoji,
    required this.isHighlighted,
    required this.animate,
  });

  @override
  State<_ZoneLabelChip> createState() => _ZoneLabelChipState();
}

class _ZoneLabelChipState extends State<_ZoneLabelChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
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
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isHighlighted
            ? Colors.amber.withOpacity(0.9)
            : Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: widget.isHighlighted
            ? Border.all(color: Colors.amber.shade300, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            widget.fortune,
            style: context.labelTiny.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (!widget.animate || !widget.isHighlighted) {
      return chip;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: chip,
    );
  }
}

/// 얼굴 가이드 프레임 페인터
class _FaceGuideFramePainter extends CustomPainter {
  final String? highlightedZone;

  _FaceGuideFramePainter({this.highlightedZone});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 얼굴 타원 (가이드)
    final facePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final faceRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: size.width * 0.7,
      height: size.height * 0.8,
    );

    canvas.drawOval(faceRect, facePaint);

    // 눈 위치 표시
    _drawZoneIndicator(
      canvas,
      Offset(centerX - size.width * 0.15, centerY - size.height * 0.1),
      isHighlighted: highlightedZone == 'left_eye',
    );
    _drawZoneIndicator(
      canvas,
      Offset(centerX + size.width * 0.15, centerY - size.height * 0.1),
      isHighlighted: highlightedZone == 'right_eye',
    );

    // 코 위치 표시
    _drawZoneIndicator(
      canvas,
      Offset(centerX, centerY + size.height * 0.02),
      isHighlighted: highlightedZone == 'nose',
    );

    // 입 위치 표시
    _drawZoneIndicator(
      canvas,
      Offset(centerX, centerY + size.height * 0.15),
      isHighlighted: highlightedZone == 'mouth',
      isOval: true,
    );
  }

  void _drawZoneIndicator(
    Canvas canvas,
    Offset center, {
    bool isHighlighted = false,
    bool isOval = false,
  }) {
    final paint = Paint()
      ..color = isHighlighted
          ? Colors.amber.withOpacity(0.6)
          : Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 3 : 1.5;

    if (isOval) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 40, height: 20),
        paint,
      );
    } else {
      canvas.drawCircle(center, 15, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FaceGuideFramePainter oldDelegate) {
    return oldDelegate.highlightedZone != highlightedZone;
  }
}

/// 간단한 얼굴 프레임 오버레이 (가이드 없이)
class SimpleFaceFrameOverlay extends StatelessWidget {
  const SimpleFaceFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _SimpleFaceFramePainter(),
    );
  }
}

class _SimpleFaceFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 어두운 외곽 영역
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.4);

    // 투명한 얼굴 영역
    final facePath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: size.width * 0.75,
        height: size.height * 0.85,
      ));

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final combinedPath =
        Path.combine(PathOperation.difference, fullPath, facePath);

    canvas.drawPath(combinedPath, backgroundPaint);

    // 얼굴 테두리
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(facePath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
