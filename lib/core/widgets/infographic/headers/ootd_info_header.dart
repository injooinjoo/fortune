import 'dart:math';
import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';
import '../../../theme/typography_unified.dart';
import '../theme_chips.dart';

/// OOTD 평가 인포그래픽 헤더
///
/// 등급 뱃지, 6축 레이더 차트, 해시태그를 표시
///
/// 사용 예시:
/// ```dart
/// OotdInfoHeader(
///   score: 92,
///   grade: 'A+',
///   radarScores: {'트렌디': 90, '컬러매치': 85, '실루엣': 88, ...},
///   hashtags: ['세련됨', '봄분위기', '데일리룩'],
/// )
/// ```
class OotdInfoHeader extends StatelessWidget {
  /// 종합 점수 (0-100)
  final int score;

  /// 등급 (A+, A, B+, B, C 등)
  final String grade;

  /// 6축 레이더 점수
  final Map<String, dynamic>? radarScores;

  /// 해시태그
  final List<String> hashtags;

  const OotdInfoHeader({
    super.key,
    required this.score,
    required this.grade,
    this.radarScores,
    this.hashtags = const [],
  });

  /// API 응답 데이터에서 생성
  factory OotdInfoHeader.fromData(Map<String, dynamic> data) {
    final tags = (data['hashtags'] as List?)?.cast<String>() ??
        (data['keywords'] as List?)?.cast<String>() ??
        [];

    return OotdInfoHeader(
      score: (data['score'] as num?)?.toInt() ?? 75,
      grade: data['grade'] as String? ?? _calculateGrade((data['score'] as num?)?.toInt() ?? 75),
      radarScores: data['radarScores'] as Map<String, dynamic>? ??
          data['categoryScores'] as Map<String, dynamic>?,
      hashtags: tags,
    );
  }

  static String _calculateGrade(int score) {
    if (score >= 95) return 'A+';
    if (score >= 90) return 'A';
    if (score >= 85) return 'B+';
    if (score >= 80) return 'B';
    if (score >= 75) return 'C+';
    if (score >= 70) return 'C';
    return 'D';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.accentTertiary.withValues(alpha: 0.05),
            colors.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          // 등급 뱃지
          _buildGradeBadge(context),

          // 레이더 차트
          if (radarScores != null && radarScores!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildRadarChart(context),
          ],

          // 해시태그
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            HashtagChips(hashtags: hashtags),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeBadge(BuildContext context) {
    final colors = context.colors;
    final gradeColor = _getGradeColor(colors);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 등급 뱃지
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: gradeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: gradeColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: gradeColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              grade,
              style: context.numberLarge.copyWith(
                color: gradeColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👕 OOTD 평가',
              style: context.heading4.copyWith(
                color: colors.textPrimary,
              ),
            ),
            Text(
              '$score점',
              style: context.numberMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadarChart(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(DSSpacing.sm),
      child: CustomPaint(
        size: const Size(200, 200),
        painter: _HexagonRadarPainter(
          scores: radarScores!,
          color: colors.accentTertiary,
          backgroundColor: colors.surfaceSecondary,
          textColor: colors.textSecondary,
        ),
      ),
    );
  }

  Color _getGradeColor(DSColorScheme colors) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return colors.success;
      case 'B+':
      case 'B':
        return colors.accentTertiary;
      case 'C+':
      case 'C':
        return colors.warning;
      default:
        return colors.error;
    }
  }
}

/// 6축 레이더 차트 페인터
class _HexagonRadarPainter extends CustomPainter {
  final Map<String, dynamic> scores;
  final Color color;
  final Color backgroundColor;
  final Color textColor;

  _HexagonRadarPainter({
    required this.scores,
    required this.color,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 30;
    final entries = scores.entries.toList();
    final sides = entries.length;

    if (sides < 3) return;

    // 배경 육각형들
    _drawBackgroundHexagons(canvas, center, radius, sides);

    // 데이터 다각형
    _drawDataPolygon(canvas, center, radius, entries);

    // 라벨
    _drawLabels(canvas, center, radius, entries);
  }

  void _drawBackgroundHexagons(Canvas canvas, Offset center, double radius, int sides) {
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 4; level++) {
      final levelRadius = radius * level / 4;
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final angle = (i * 2 * pi / sides) - pi / 2;
        final x = center.dx + levelRadius * cos(angle);
        final y = center.dy + levelRadius * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, bgPaint);
    }

    // 축선
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * pi / sides) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), bgPaint);
    }
  }

  void _drawDataPolygon(Canvas canvas, Offset center, double radius, List<MapEntry<String, dynamic>> entries) {
    final sides = entries.length;
    final dataPath = Path();
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < sides; i++) {
      final score = (entries[i].value as num).toDouble().clamp(0, 100);
      final scoreRadius = radius * score / 100;
      final angle = (i * 2 * pi / sides) - pi / 2;
      final x = center.dx + scoreRadius * cos(angle);
      final y = center.dy + scoreRadius * sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // 점
    final dotPaint = Paint()..color = color;
    for (int i = 0; i < sides; i++) {
      final score = (entries[i].value as num).toDouble().clamp(0, 100);
      final scoreRadius = radius * score / 100;
      final angle = (i * 2 * pi / sides) - pi / 2;
      final x = center.dx + scoreRadius * cos(angle);
      final y = center.dy + scoreRadius * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, List<MapEntry<String, dynamic>> entries) {
    final sides = entries.length;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * pi / sides) - pi / 2;
      final labelRadius = radius + 20;
      final x = center.dx + labelRadius * cos(angle);
      final y = center.dy + labelRadius * sin(angle);

      textPainter.text = TextSpan(
        text: entries[i].key,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
        ),
      );
      textPainter.layout();

      // 라벨 위치 조정
      final labelX = x - textPainter.width / 2;
      final labelY = y - textPainter.height / 2;

      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(_HexagonRadarPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
