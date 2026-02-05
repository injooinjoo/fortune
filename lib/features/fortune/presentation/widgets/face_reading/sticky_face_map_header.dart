import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// 얼굴 부위 터치 영역 데이터
class FaceZoneTouchArea {
  final String key;
  final String name;
  final String subtitle;
  final Rect relativeRect; // 0.0 - 1.0 상대 좌표
  final Color color;

  const FaceZoneTouchArea({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.relativeRect,
    required this.color,
  });
}

/// Sticky Face Map Header
/// 스크롤 시 축소되고 고정되는 얼굴 맵 헤더
class StickyFaceMapHeader extends SliverPersistentHeaderDelegate {
  final Function(String) onZoneTap;
  final VoidCallback onScrollToTop;
  final Map<String, dynamic>? ogwanData;
  final String? faceMapImagePath;

  // 터치 가능한 부위들 정의
  static const List<FaceZoneTouchArea> touchAreas = [
    // 오관 (五官)
    FaceZoneTouchArea(
      key: 'ear',
      name: '귀(耳)',
      subtitle: '채청관',
      relativeRect: Rect.fromLTWH(0.05, 0.35, 0.12, 0.15),
      color: Color(0xFF9B59B6),
    ),
    FaceZoneTouchArea(
      key: 'ear_right',
      name: '귀(耳)',
      subtitle: '채청관',
      relativeRect: Rect.fromLTWH(0.83, 0.35, 0.12, 0.15),
      color: Color(0xFF9B59B6),
    ),
    FaceZoneTouchArea(
      key: 'eyebrow',
      name: '눈썹(眉)',
      subtitle: '보수관',
      relativeRect: Rect.fromLTWH(0.25, 0.30, 0.50, 0.08),
      color: Color(0xFF3498DB),
    ),
    FaceZoneTouchArea(
      key: 'eye',
      name: '눈(目)',
      subtitle: '감찰관',
      relativeRect: Rect.fromLTWH(0.25, 0.38, 0.50, 0.10),
      color: Color(0xFF27AE60),
    ),
    FaceZoneTouchArea(
      key: 'nose',
      name: '코(鼻)',
      subtitle: '심판관',
      relativeRect: Rect.fromLTWH(0.40, 0.48, 0.20, 0.18),
      color: Color(0xFFF39C12),
    ),
    FaceZoneTouchArea(
      key: 'mouth',
      name: '입(口)',
      subtitle: '출납관',
      relativeRect: Rect.fromLTWH(0.35, 0.68, 0.30, 0.12),
      color: Color(0xFFE91E63),
    ),
    // 삼정 영역
    FaceZoneTouchArea(
      key: 'upper',
      name: '상정(上停)',
      subtitle: '초년운 1-30세',
      relativeRect: Rect.fromLTWH(0.30, 0.08, 0.40, 0.18),
      color: Color(0xFFE74C3C),
    ),
    FaceZoneTouchArea(
      key: 'middle',
      name: '중정(中停)',
      subtitle: '중년운 31-50세',
      relativeRect: Rect.fromLTWH(0.30, 0.28, 0.40, 0.22),
      color: Color(0xFF3498DB),
    ),
    FaceZoneTouchArea(
      key: 'lower',
      name: '하정(下停)',
      subtitle: '말년운 51세+',
      relativeRect: Rect.fromLTWH(0.30, 0.65, 0.40, 0.20),
      color: Color(0xFF27AE60),
    ),
  ];

  StickyFaceMapHeader({
    required this.onZoneTap,
    required this.onScrollToTop,
    this.ogwanData,
    this.faceMapImagePath,
  });

  @override
  double get maxExtent => 420.0; // 전체 맵 표시

  @override
  double get minExtent => 80.0; // 미니 헤더

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final expandRatio =
        1 - (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 전체 맵 (확장 상태)
          Opacity(
            opacity: expandRatio,
            child: _buildExpandedMap(context),
          ),

          // 미니 헤더 (축소 상태)
          Opacity(
            opacity: 1 - expandRatio,
            child: _buildCollapsedHeader(context),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedMap(BuildContext context) {
    final isDark = context.isDark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 제목
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [DSColors.accentSecondary, DSColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '관상 부위별 분석',
                      style: context.labelLarge.copyWith(
                        color: isDark
                            ? DSColors.textPrimary
                            : DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '부위를 터치하여 상세 분석 보기',
                      style: context.labelSmall.copyWith(
                        color: isDark
                            ? DSColors.textSecondary
                            : DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 얼굴 맵 이미지 + 터치 영역
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // 배경 이미지 또는 기본 얼굴 윤곽
                    Center(
                      child: faceMapImagePath != null
                          ? Image.asset(
                              faceMapImagePath!,
                              fit: BoxFit.contain,
                            )
                          : _buildDefaultFaceOutline(constraints, isDark),
                    ),

                    // 터치 영역 오버레이
                    ...touchAreas.map((area) {
                      // ear_right는 ear와 동일한 데이터 사용
                      final dataKey =
                          area.key == 'ear_right' ? 'ear' : area.key;
                      final hasData = ogwanData?[dataKey] != null;

                      return Positioned(
                        left: constraints.maxWidth * area.relativeRect.left,
                        top: constraints.maxHeight * area.relativeRect.top,
                        width: constraints.maxWidth * area.relativeRect.width,
                        height: constraints.maxHeight * area.relativeRect.height,
                        child: GestureDetector(
                          onTap: () => onZoneTap(dataKey),
                          child: Container(
                            decoration: BoxDecoration(
                              color: area.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: area.color.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    area.name.split('(')[0],
                                    style: context.labelSmall.copyWith(
                                      color: area.color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (hasData)
                                    Container(
                                      margin: const EdgeInsets.only(top: 1),
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: DSColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedHeader(BuildContext context) {
    final isDark = context.isDark;

    return GestureDetector(
      onTap: onScrollToTop,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DSColors.accentSecondary, DSColors.accent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '관상 분석 결과',
                style: context.labelLarge.copyWith(
                  color: isDark
                      ? DSColors.textPrimary
                      : DSColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DSColors.accentSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.keyboard_arrow_up,
                    color: DSColors.accentSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '맵 보기',
                    style: context.labelSmall.copyWith(
                      color: DSColors.accentSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultFaceOutline(BoxConstraints constraints, bool isDark) {
    return CustomPaint(
      size: Size(constraints.maxWidth * 0.8, constraints.maxHeight * 0.9),
      painter: _FaceOutlinePainter(
        color:
            isDark ? DSColors.textTertiary : DSColors.textTertiary,
      ),
    );
  }
}

/// 얼굴 윤곽 페인터 (이미지가 없을 때 사용)
class _FaceOutlinePainter extends CustomPainter {
  final Color color;

  _FaceOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // 얼굴 윤곽 (타원형)
    final faceRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: size.width * 0.75,
      height: size.height * 0.8,
    );

    canvas.drawOval(faceRect, fillPaint);
    canvas.drawOval(faceRect, paint);

    // 머리카락 영역
    final hairPath = Path();
    hairPath.moveTo(size.width * 0.15, size.height * 0.25);
    hairPath.quadraticBezierTo(
      size.width * 0.5,
      -size.height * 0.02,
      size.width * 0.85,
      size.height * 0.25,
    );
    canvas.drawPath(hairPath, paint..strokeWidth = 1.5);

    // 목 영역
    final neckPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.85),
      Offset(size.width * 0.35, size.height),
      neckPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.85),
      Offset(size.width * 0.65, size.height),
      neckPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
