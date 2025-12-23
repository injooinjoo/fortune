import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';

/// Interactive Face Map for Physiognomy (관상학)
/// 터치 가능한 얼굴 맵 - 오관(五官) 영역 표시
class InteractiveFaceMap extends StatefulWidget {
  final Map<String, dynamic>? ogwanData;
  final bool isBlurred;
  final VoidCallback? onUnlockRequested;

  const InteractiveFaceMap({
    super.key,
    this.ogwanData,
    this.isBlurred = false,
    this.onUnlockRequested,
  });

  @override
  State<InteractiveFaceMap> createState() => _InteractiveFaceMapState();
}

class _InteractiveFaceMapState extends State<InteractiveFaceMap>
    with SingleTickerProviderStateMixin {
  String? _selectedZone;
  late AnimationController _pulseController;

  // 오관(五官) 정의
  static const Map<String, _FaceZoneData> _faceZones = {
    'ear': _FaceZoneData(
      name: '귀(耳)',
      subtitle: '채청관 - 복록과 수명',
      icon: Icons.hearing,
      color: Color(0xFF9B59B6), // Purple
      relativePosition: Offset(0.12, 0.38),
      relativeSize: 0.12,
    ),
    'eyebrow': _FaceZoneData(
      name: '눈썹(眉)',
      subtitle: '보수관 - 형제와 친구',
      icon: Icons.remove_red_eye_outlined,
      color: Color(0xFF3498DB), // Blue
      relativePosition: Offset(0.5, 0.28),
      relativeSize: 0.25,
    ),
    'eye': _FaceZoneData(
      name: '눈(目)',
      subtitle: '감찰관 - 마음의 창',
      icon: Icons.remove_red_eye,
      color: Color(0xFF27AE60), // Green
      relativePosition: Offset(0.5, 0.38),
      relativeSize: 0.28,
    ),
    'nose': _FaceZoneData(
      name: '코(鼻)',
      subtitle: '심변관 - 재물의 중심',
      icon: Icons.air,
      color: Color(0xFFF39C12), // Amber
      relativePosition: Offset(0.5, 0.52),
      relativeSize: 0.15,
    ),
    'mouth': _FaceZoneData(
      name: '입(口)',
      subtitle: '출납관 - 식복과 언변',
      icon: Icons.sentiment_satisfied,
      color: Color(0xFFE91E63), // Pink
      relativePosition: Offset(0.5, 0.68),
      relativeSize: 0.18,
    ),
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  DSColors.backgroundSecondary,
                  DSColors.surface,
                ]
              : [
                  DSColors.surface,
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: DSColors.accentSecondary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
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
                      '오관(五官) 인터랙티브 맵',
                      style: DSTypography.headingSmall.copyWith(
                        color: isDark
                            ? DSColors.textPrimary
                            : DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '터치하여 상세 분석 보기',
                      style: DSTypography.labelSmall.copyWith(
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

          const SizedBox(height: 24),

          // Face Map 영역
          AspectRatio(
            aspectRatio: 1.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                return Stack(
                  children: [
                    // 얼굴 윤곽 배경
                    Center(
                      child: CustomPaint(
                        size: Size(size.width * 0.85, size.height * 0.95),
                        painter: _FaceOutlinePainter(
                          color: isDark
                              ? DSColors.textTertiary
                              : DSColors.textTertiary,
                        ),
                      ),
                    ),

                    // 터치 가능한 영역들
                    ..._faceZones.entries.map((entry) {
                      final key = entry.key;
                      final zone = entry.value;
                      final isSelected = _selectedZone == key;
                      final hasData = widget.ogwanData?[key] != null;

                      return Positioned(
                        left: size.width * zone.relativePosition.dx -
                            (size.width * zone.relativeSize / 2),
                        top: size.height * zone.relativePosition.dy -
                            (size.width * zone.relativeSize / 2),
                        child: GestureDetector(
                          onTap: () => _onZoneTapped(key),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final pulseScale = isSelected
                                  ? 1.0 + (_pulseController.value * 0.1)
                                  : 1.0;

                              return Transform.scale(
                                scale: pulseScale,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: size.width * zone.relativeSize,
                                  height: size.width * zone.relativeSize,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? zone.color.withValues(alpha: 0.3)
                                        : zone.color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? zone.color
                                          : zone.color.withValues(alpha: 0.5),
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: zone.color
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          zone.icon,
                                          color: zone.color,
                                          size: size.width * zone.relativeSize * 0.35,
                                        ),
                                        if (hasData && !widget.isBlurred)
                                          Container(
                                            margin: const EdgeInsets.only(top: 4),
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: DSColors.success,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),

                    // 블러 오버레이
                    if (widget.isBlurred)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: widget.onUnlockRequested,
                          child: Container(
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 48,
                                    color: DSColors.accentSecondary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '프리미엄 잠금',
                                    style: DSTypography.headingSmall.copyWith(
                                      color: DSColors.accentSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '터치하여 잠금 해제',
                                    style: DSTypography.labelSmall.copyWith(
                                      color: isDark
                                          ? DSColors.textSecondary
                                          : DSColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // 선택된 영역 상세 정보
          if (_selectedZone != null && !widget.isBlurred) ...[
            const SizedBox(height: 20),
            _buildSelectedZoneDetail(isDark),
          ],

          // 범례
          const SizedBox(height: 16),
          _buildLegend(isDark),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  void _onZoneTapped(String key) {
    if (widget.isBlurred) {
      widget.onUnlockRequested?.call();
      return;
    }

    setState(() {
      _selectedZone = _selectedZone == key ? null : key;
    });
  }

  Widget _buildSelectedZoneDetail(bool isDark) {
    final zone = _faceZones[_selectedZone];
    if (zone == null) return const SizedBox.shrink();

    // Map 객체로 파싱 (JSON 버그 수정)
    final ogwanData = widget.ogwanData?[_selectedZone] as Map<String, dynamic>?;
    final observation = ogwanData?['observation'] as String? ?? '';
    final interpretation = ogwanData?['interpretation'] as String? ?? '';
    final score = (ogwanData?['score'] as num?)?.toInt();
    final advice = ogwanData?['advice'] as String? ?? '';

    final hasData = observation.isNotEmpty || interpretation.isNotEmpty || advice.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: zone.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: zone.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 아이콘 + 제목 + 점수 + 닫기 버튼
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: zone.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(zone.icon, color: zone.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: DSTypography.headingSmall.copyWith(
                        color: isDark
                            ? DSColors.textPrimary
                            : DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      zone.subtitle,
                      style: DSTypography.labelSmall.copyWith(
                        color: zone.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // 점수 배지
              if (score != null && score > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: zone.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$score점',
                    style: DSTypography.labelSmall.copyWith(
                      color: zone.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: isDark
                    ? DSColors.textSecondary
                    : DSColors.textSecondary,
                onPressed: () => setState(() => _selectedZone = null),
              ),
            ],
          ),

          // 점수 게이지 바
          if (score != null && score > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: zone.color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(zone.color),
                minHeight: 4,
              ),
            ),
          ],

          if (hasData) ...[
            // 관찰 내용
            if (observation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '관찰',
                style: DSTypography.labelSmall.copyWith(
                  color: zone.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                observation,
                style: DSTypography.bodyMedium.copyWith(
                  color: isDark
                      ? DSColors.textPrimary
                      : DSColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],

            // 관상학적 해석
            if (interpretation.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '해석',
                style: DSTypography.labelSmall.copyWith(
                  color: zone.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                interpretation,
                style: DSTypography.bodyMedium.copyWith(
                  color: isDark
                      ? DSColors.textPrimary
                      : DSColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],

            // 개운 조언
            if (advice.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: zone.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: zone.color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        advice,
                        style: DSTypography.bodyMedium.copyWith(
                          color: isDark
                              ? DSColors.textPrimary
                              : DSColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 12),
            Text(
              '분석 데이터가 없습니다.',
              style: DSTypography.bodyMedium.copyWith(
                color: isDark
                    ? DSColors.textSecondary
                    : DSColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildLegend(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _faceZones.entries.map((entry) {
        final zone = entry.value;
        final isSelected = _selectedZone == entry.key;

        return GestureDetector(
          onTap: () => _onZoneTapped(entry.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? zone.color.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? zone.color
                    : (isDark
                        ? DSColors.textTertiary
                        : DSColors.textTertiary),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: zone.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  zone.name.split('(')[0],
                  style: DSTypography.labelSmall.copyWith(
                    color: isSelected
                        ? zone.color
                        : (isDark
                            ? DSColors.textSecondary
                            : DSColors.textSecondary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// 얼굴 영역 데이터 클래스
class _FaceZoneData {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Offset relativePosition; // 0.0 - 1.0 상대 위치
  final double relativeSize; // 0.0 - 1.0 상대 크기

  const _FaceZoneData({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.relativePosition,
    required this.relativeSize,
  });
}

// 얼굴 윤곽 페인터
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
      width: size.width * 0.7,
      height: size.height * 0.75,
    );

    // 얼굴 채우기
    canvas.drawOval(faceRect, fillPaint);

    // 얼굴 윤곽선
    canvas.drawOval(faceRect, paint);

    // 머리카락 영역 (상단 반원)
    final hairPath = Path();
    hairPath.moveTo(size.width * 0.15, size.height * 0.3);
    hairPath.quadraticBezierTo(
      size.width * 0.5,
      -size.height * 0.05,
      size.width * 0.85,
      size.height * 0.3,
    );
    canvas.drawPath(hairPath, paint..strokeWidth = 1.5);

    // 목 영역
    final neckPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.82),
      Offset(size.width * 0.35, size.height),
      neckPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.82),
      Offset(size.width * 0.65, size.height),
      neckPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
