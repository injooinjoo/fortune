import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 오행 상생상극(五行 相生相剋) 다이어그램 위젯
///
/// 오각형 형태로 木火土金水를 배치하고
/// 상생 화살표(외곽)와 상극 화살표(내부)를 표시합니다.
/// 사용자의 오행 분포에 따라 각 요소의 크기가 달라집니다.
class OhengCycleWidget extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const OhengCycleWidget({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final distribution = _extractDistribution();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? context.colors.backgroundSecondary : Colors.white,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Column(
        children: [
          // 다이어그램
          SizedBox(
            height: 240,
            child: CustomPaint(
              size: const Size(280, 240),
              painter: _OhengPainter(
                distribution: distribution,
                isDark: isDark,
              ),
              child: _buildLabels(context, distribution, isDark),
            ),
          ),
          const SizedBox(height: DSSpacing.sm),

          // 범례
          _buildLegend(context, isDark),
          const SizedBox(height: DSSpacing.sm),

          // 오행 분포 바
          _buildDistributionBar(context, distribution, isDark),
        ],
      ),
    );
  }

  Widget _buildLabels(
    BuildContext context,
    Map<String, int> distribution,
    bool isDark,
  ) {
    const elements = ['화', '목', '수', '금', '토'];
    const hanja = ['火', '木', '水', '金', '土'];
    const positions = [
      Alignment(0.0, -0.85), // 화 (상단)
      Alignment(-0.85, -0.15), // 목 (좌상)
      Alignment(-0.55, 0.85), // 수 (좌하)
      Alignment(0.55, 0.85), // 금 (우하)
      Alignment(0.85, -0.15), // 토 (우상)
    ];

    return Stack(
      children: List.generate(5, (i) {
        final count = distribution[elements[i]] ?? 0;
        final color = SajuColors.getWuxingColor(elements[i], isDark: isDark);
        final bgColor = SajuColors.getWuxingBackgroundColor(
          elements[i],
          isDark: isDark,
        );

        return Align(
          alignment: positions[i],
          child: Container(
            width: 48 + (count * 4).clamp(0, 16).toDouble(),
            height: 48 + (count * 4).clamp(0, 16).toDouble(),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: count > 0 ? 2.5 : 1),
              boxShadow: count > 2
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hanja[i],
                  style: context.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$count개',
                  style: context.labelTiny.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLegend(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(
          context,
          color: const Color(0xFF66BB6A),
          label: '상생(相生)',
          isDashed: false,
        ),
        const SizedBox(width: DSSpacing.md),
        _legendItem(
          context,
          color: const Color(0xFFEF4444),
          label: '상극(相剋)',
          isDashed: true,
        ),
      ],
    );
  }

  Widget _legendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required bool isDashed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            border: isDashed
                ? Border(
                    bottom: BorderSide(
                      color: color,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.labelTiny.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionBar(
    BuildContext context,
    Map<String, int> distribution,
    bool isDark,
  ) {
    final total = distribution.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    const order = ['목', '화', '토', '금', '수'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: order.map((element) {
            final count = distribution[element] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Expanded(
              flex: count,
              child: Container(
                color: SajuColors.getWuxingColor(element, isDark: isDark),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Map<String, int> _extractDistribution() {
    final Map<String, int> dist = {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};

    // elements 필드에서 추출
    final elements = sajuData['elements'] as Map<String, dynamic>?;
    if (elements != null) {
      for (final key in dist.keys) {
        dist[key] = (elements[key] as num?)?.toInt() ?? 0;
      }
      return dist;
    }

    // elementBalance에서 추출
    final balance = sajuData['elementBalance'] as Map<String, dynamic>?;
    if (balance != null) {
      for (final key in dist.keys) {
        dist[key] = (balance[key] as num?)?.toInt() ?? 0;
      }
      return dist;
    }

    // myungsik에서 직접 계산
    final myungsik = sajuData['myungsik'] as Map<String, dynamic>?;
    if (myungsik != null) {
      final stemEl = {
        '갑': '목',
        '을': '목',
        '병': '화',
        '정': '화',
        '무': '토',
        '기': '토',
        '경': '금',
        '신': '금',
        '임': '수',
        '계': '수',
      };
      final branchEl = {
        '자': '수',
        '축': '토',
        '인': '목',
        '묘': '목',
        '진': '토',
        '사': '화',
        '오': '화',
        '미': '토',
        '신': '금',
        '유': '금',
        '술': '토',
        '해': '수',
      };

      for (final prefix in ['year', 'month', 'day', 'hour']) {
        final sky = myungsik['${prefix}Sky'] as String?;
        final earth = myungsik['${prefix}Earth'] as String?;
        if (sky != null && stemEl.containsKey(sky)) {
          dist[stemEl[sky]!] = (dist[stemEl[sky]!] ?? 0) + 1;
        }
        if (earth != null && branchEl.containsKey(earth)) {
          dist[branchEl[earth]!] = (dist[branchEl[earth]!] ?? 0) + 1;
        }
      }
    }

    return dist;
  }
}

/// 오행 상생상극 다이어그램 페인터
class _OhengPainter extends CustomPainter {
  final Map<String, int> distribution;
  final bool isDark;

  _OhengPainter({required this.distribution, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.32;

    // 오각형 꼭짓점 계산 (상단에서 시작, 시계방향)
    // 순서: 화(상), 토(우상), 금(우하), 수(좌하), 목(좌상)
    final points = List.generate(5, (i) {
      final angle = -math.pi / 2 + (2 * math.pi * i / 5);
      return Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    });

    // 상생 화살표 (외곽, 시계방향): 목→화→토→금→수→목
    // 매핑: 화(0), 토(1), 금(2), 수(3), 목(4) → 상생 순서: 목(4)→화(0)→토(1)→금(2)→수(3)
    final shengOrder = [4, 0, 1, 2, 3]; // 목→화→토→금→수
    final shengPaint = Paint()
      ..color = (isDark ? const Color(0xFF66BB6A) : const Color(0xFF43A047))
          .withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final from = points[shengOrder[i]];
      final to = points[shengOrder[(i + 1) % 5]];
      _drawArrow(canvas, from, to, shengPaint, center, radius * 0.15);
    }

    // 상극 화살표 (내부, 별 형태): 목→토→수→화→금→목
    // 매핑: 목(4)→토(1), 토(1)→수(3), 수(3)→화(0), 화(0)→금(2), 금(2)→목(4)
    final keOrder = [
      [4, 1],
      [1, 3],
      [3, 0],
      [0, 2],
      [2, 4],
    ];
    final kePaint = Paint()
      ..color = (isDark ? const Color(0xFFEF5350) : const Color(0xFFE53935))
          .withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (final pair in keOrder) {
      final from = points[pair[0]];
      final to = points[pair[1]];
      _drawDashedLine(canvas, from, to, kePaint);
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
    Offset center,
    double curveOffset,
  ) {
    // 곡선 화살표 (중심에서 바깥으로 살짝 볼록)
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final dx = mid.dx - center.dx;
    final dy = mid.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final control = Offset(
      mid.dx + (dx / dist) * curveOffset,
      mid.dy + (dy / dist) * curveOffset,
    );

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);

    canvas.drawPath(path, paint);

    // 화살촉
    final angle = math.atan2(to.dy - control.dy, to.dx - control.dx);
    final arrowSize = 6.0;
    final arrowPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      to,
      Offset(
        to.dx - arrowSize * math.cos(angle - 0.5),
        to.dy - arrowSize * math.sin(angle - 0.5),
      ),
      arrowPaint,
    );
    canvas.drawLine(
      to,
      Offset(
        to.dx - arrowSize * math.cos(angle + 0.5),
        to.dy - arrowSize * math.sin(angle + 0.5),
      ),
      arrowPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final dashLength = 4.0;
    final gapLength = 4.0;
    final steps = dist / (dashLength + gapLength);

    for (int i = 0; i < steps; i++) {
      final startRatio = i * (dashLength + gapLength) / dist;
      final endRatio = (i * (dashLength + gapLength) + dashLength) / dist;

      if (endRatio > 1.0) break;

      canvas.drawLine(
        Offset(from.dx + dx * startRatio, from.dy + dy * startRatio),
        Offset(from.dx + dx * endRatio, from.dy + dy * endRatio),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OhengPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.distribution != distribution;
  }
}
