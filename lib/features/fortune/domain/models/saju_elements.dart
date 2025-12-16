/// 오행(五行) 모델 및 시각화 위젯
///
/// 오행: 목(木), 화(火), 토(土), 금(金), 수(水)
/// - 사주에서 추출된 오행 분포를 모델링
/// - 오각형 차트로 시각화
library;

import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import 'dart:math' as math;

/// 오행 타입
enum WuxingType {
  wood('목', '木', Color(0xFF4CAF50), '성장', '봄', '동쪽'),
  fire('화', '火', Color(0xFFF44336), '열정', '여름', '남쪽'),
  earth('토', '土', Color(0xFFFF9800), '안정', '환절기', '중앙'),
  metal('금', '金', Color(0xFFC0C0C0), '결단', '가을', '서쪽'),
  water('수', '水', Color(0xFF2196F3), '지혜', '겨울', '북쪽');

  final String korean;
  final String chinese;
  final Color color;
  final String keyword;
  final String season;
  final String direction;

  const WuxingType(
    this.korean,
    this.chinese,
    this.color,
    this.keyword,
    this.season,
    this.direction,
  );

  static WuxingType? fromKorean(String korean) {
    return WuxingType.values.firstWhere(
      (e) => e.korean == korean,
      orElse: () => WuxingType.wood,
    );
  }
}

/// 오행 분포 모델
class WuxingDistribution {
  final Map<WuxingType, int> counts; // 각 오행의 개수
  final Map<WuxingType, double> percentages; // 각 오행의 비율 (0~1)
  final WuxingType dominant; // 가장 강한 오행
  final WuxingType? weak; // 가장 약한 오행 (없으면 null)

  const WuxingDistribution({
    required this.counts,
    required this.percentages,
    required this.dominant,
    this.weak,
  });

  /// SajuCalculator의 결과로부터 생성
  factory WuxingDistribution.fromCounts(Map<String, int> countsMap) {
    // String -> WuxingType으로 변환
    final typedCounts = <WuxingType, int>{};
    final typedPercentages = <WuxingType, double>{};

    int total = 0;
    for (final type in WuxingType.values) {
      final count = countsMap[type.korean] ?? 0;
      typedCounts[type] = count;
      total += count;
    }

    // 비율 계산
    if (total > 0) {
      for (final type in WuxingType.values) {
        typedPercentages[type] = (typedCounts[type] ?? 0) / total;
      }
    }

    // 가장 강한/약한 오행 찾기
    WuxingType dominant = WuxingType.wood;
    WuxingType? weak;
    int maxCount = 0;
    int minCount = 999;

    for (final entry in typedCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominant = entry.key;
      }
      if (entry.value > 0 && entry.value < minCount) {
        minCount = entry.value;
        weak = entry.key;
      }
    }

    return WuxingDistribution(
      counts: typedCounts,
      percentages: typedPercentages,
      dominant: dominant,
      weak: weak,
    );
  }

  /// 오행 균형 점수 (0~100)
  /// - 100에 가까울수록 오행이 균형잡힘
  /// - 0에 가까울수록 특정 오행에 치우침
  double get balanceScore {
    final ideal = 1.0 / 5; // 이상적 비율 (20%)
    double totalDeviation = 0;

    for (final percentage in percentages.values) {
      totalDeviation += (percentage - ideal).abs();
    }

    // 최대 편차는 0.8 (한 오행만 100%, 나머지 0%)
    // 점수로 변환: 100 - (편차 / 최대편차 * 100)
    return 100 - (totalDeviation / 0.8 * 100);
  }

  /// 오행 설명
  String get description {
    if (balanceScore >= 80) {
      return '오행이 매우 균형잡혀 있습니다. 다재다능하고 적응력이 뛰어납니다.';
    } else if (balanceScore >= 60) {
      return '오행이 전반적으로 조화롭습니다. ${dominant.korean}의 기운이 강하지만 다른 요소도 잘 갖춰져 있습니다.';
    } else if (balanceScore >= 40) {
      return '${dominant.korean}의 기운이 두드러집니다. ${dominant.keyword}의 특성이 강하게 나타나며, ${weak?.korean ?? '다른 요소'}를 보완하면 좋습니다.';
    } else {
      return '${dominant.korean}에 크게 치우쳐 있습니다. ${dominant.keyword}은 강점이지만, ${weak?.korean ?? '다른 오행'}의 기운을 의식적으로 보충해야 균형을 이룰 수 있습니다.';
    }
  }

  /// 추천 보완 요소
  List<String> get recommendations {
    final recs = <String>[];

    if (weak != null) {
      recs.add('${weak!.korean}(${weak!.keyword}) 요소를 강화하세요: ${weak!.season}, ${weak!.direction} 방향, ${weak!.color.toARGB32().toRadixString(16)} 색상 활용');
    }

    if (balanceScore < 60) {
      recs.add('${dominant.korean}이 강하므로 과도한 ${dominant.keyword}을 조절하세요');
    }

    if (percentages[WuxingType.water]! < 0.1) {
      recs.add('수(水) 기운이 약하므로 지혜와 유연성을 기르세요');
    }

    if (percentages[WuxingType.fire]! < 0.1) {
      recs.add('화(火) 기운이 약하므로 열정과 추진력을 키우세요');
    }

    return recs;
  }
}

/// 오행 오각형 차트 위젯
///
/// 사용 예시:
/// ```dart
/// WuxingPentagonChart(
///   distribution: WuxingDistribution.fromCounts(sajuResult['wuxing']),
///   size: 200,
/// )
/// ```
class WuxingPentagonChart extends StatelessWidget {
  final WuxingDistribution distribution;
  final double size;
  final bool showLabels;
  final bool showValues;

  const WuxingPentagonChart({
    super.key,
    required this.distribution,
    this.size = 200,
    this.showLabels = true,
    this.showValues = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PentagonPainter(
          distribution: distribution,
          showLabels: showLabels,
          showValues: showValues,
        ),
      ),
    );
  }
}

class _PentagonPainter extends CustomPainter {
  final WuxingDistribution distribution;
  final bool showLabels;
  final bool showValues;

  _PentagonPainter({
    required this.distribution,
    required this.showLabels,
    required this.showValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;

    // 5개 꼭짓점 좌표 계산 (12시 방향부터 시계방향)
    // 목(木) - 12시, 화(火) - 2시, 토(土) - 5시, 금(金) - 7시, 수(水) - 10시
    final points = _calculatePentagonPoints(center, radius);

    // 배경 오각형 (회색 반투명)
    _drawBackgroundPentagon(canvas, points);

    // 격자선 (20%, 40%, 60%, 80%, 100%)
    _drawGridLines(canvas, center, radius, points);

    // 실제 데이터 오각형 (채워진 색상)
    _drawDataPentagon(canvas, center, radius, points);

    // 라벨 및 값 표시
    if (showLabels || showValues) {
      _drawLabels(canvas, center, radius, points);
    }
  }

  List<Offset> _calculatePentagonPoints(Offset center, double radius) {
    final points = <Offset>[];
    final types = [
      WuxingType.wood,  // 12시
      WuxingType.fire,  // 2시
      WuxingType.earth, // 5시
      WuxingType.metal, // 7시
      WuxingType.water, // 10시
    ];

    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / 5) * i; // 12시부터 시작
      final percentage = distribution.percentages[types[i]] ?? 0;
      final distance = radius * percentage;

      points.add(Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      ));
    }

    return points;
  }

  void _drawBackgroundPentagon(Canvas canvas, List<Offset> points) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawGridLines(Canvas canvas, Offset center, double radius, List<Offset> dataPoints) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 20%, 40%, 60%, 80%, 100% 격자
    for (int i = 1; i <= 5; i++) {
      final gridRadius = radius * (i / 5);
      final gridPoints = <Offset>[];

      for (int j = 0; j < 5; j++) {
        final angle = -math.pi / 2 + (2 * math.pi / 5) * j;
        gridPoints.add(Offset(
          center.dx + gridRadius * math.cos(angle),
          center.dy + gridRadius * math.sin(angle),
        ));
      }

      final path = Path()..moveTo(gridPoints[0].dx, gridPoints[0].dy);
      for (int k = 1; k < gridPoints.length; k++) {
        path.lineTo(gridPoints[k].dx, gridPoints[k].dy);
      }
      path.close();

      canvas.drawPath(path, paint);
    }

    // 중심에서 꼭짓점으로 선
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / 5) * i;
      final endpoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endpoint, paint);
    }
  }

  void _drawDataPentagon(Canvas canvas, Offset center, double radius, List<Offset> points) {
    // 채워진 오각형
    final fillPaint = Paint()
      ..color = distribution.dominant.color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final fillPath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    // 테두리
    final strokePaint = Paint()
      ..color = distribution.dominant.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(fillPath, strokePaint);

    // 꼭짓점에 점 표시
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = distribution.dominant.color);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, List<Offset> dataPoints) {
    final types = [
      WuxingType.wood,
      WuxingType.fire,
      WuxingType.earth,
      WuxingType.metal,
      WuxingType.water,
    ];

    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (2 * math.pi / 5) * i;
      final labelRadius = radius + 30;
      final labelPos = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final type = types[i];
      final percentage = distribution.percentages[type] ?? 0;

      String text = '';
      if (showLabels && showValues) {
        text = '${type.korean}(${type.chinese})\n${(percentage * 100).toStringAsFixed(0)}%';
      } else if (showLabels) {
        text = '${type.korean}(${type.chinese})';
      } else if (showValues) {
        text = '${(percentage * 100).toStringAsFixed(0)}%';
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: type.color,
            
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          labelPos.dx - textPainter.width / 2,
          labelPos.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_PentagonPainter oldDelegate) {
    return distribution != oldDelegate.distribution;
  }
}

/// 오행 상세 정보 카드 위젯
class WuxingDetailCard extends StatelessWidget {
  final WuxingDistribution distribution;

  const WuxingDetailCard({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '오행 분포 분석',
            style: DSTypography.headingSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 차트
          Center(
            child: WuxingPentagonChart(
              distribution: distribution,
              size: 220,
            ),
          ),
          SizedBox(height: 20),

          // 균형 점수
          Row(
            children: [
              Text(
                '균형 점수',
                style: DSTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Spacer(),
              Text(
                '${distribution.balanceScore.toStringAsFixed(0)}점',
                style: DSTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: distribution.balanceScore >= 60
                      ? Colors.green
                      : distribution.balanceScore >= 40
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // 설명
          Text(
            distribution.description,
            style: DSTypography.bodySmall.copyWith(
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 추천 사항
          if (distribution.recommendations.isNotEmpty) ...[
            Text(
              '추천 사항',
              style: DSTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            ...distribution.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: DSTypography.bodySmall.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          rec,
                          style: DSTypography.bodySmall.copyWith(
                            height: 1.4,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
