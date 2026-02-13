import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';
import '../score_circle_widget.dart';
import '../category_bar_chart.dart';

/// 커리어 인사이트 인포그래픽 헤더
///
/// 종합 점수, 강점 분석, 행운 시기를 표시
///
/// 사용 예시:
/// ```dart
/// CareerInfoHeader(
///   score: 85,
///   prediction: '향후 3개월 내 좋은 기회가...',
///   strengths: {'리더십': 85, '커뮤니케이션': 72, '문제해결': 91},
///   luckyPeriod: '2월 중순 ~ 3월 초',
///   cautionPeriod: '4월 말',
/// )
/// ```
class CareerInfoHeader extends StatelessWidget {
  /// 종합 점수 (0-100)
  final int score;

  /// 전망 요약
  final String? prediction;

  /// 강점 분석 (이름: 점수)
  final Map<String, dynamic>? strengths;

  /// 행운 시기
  final String? luckyPeriod;

  /// 주의 시기
  final String? cautionPeriod;

  const CareerInfoHeader({
    super.key,
    required this.score,
    this.prediction,
    this.strengths,
    this.luckyPeriod,
    this.cautionPeriod,
  });

  /// API 응답 데이터에서 생성
  factory CareerInfoHeader.fromData(Map<String, dynamic> data) {
    return CareerInfoHeader(
      score: (data['score'] as num?)?.toInt() ??
          (data['overallScore'] as num?)?.toInt() ??
          75,
      prediction: data['prediction'] as String? ?? data['summary'] as String?,
      strengths: data['strengths'] as Map<String, dynamic>? ??
          data['skillAnalysis'] as Map<String, dynamic>?,
      luckyPeriod:
          data['luckyPeriod'] as String? ?? data['bestTiming'] as String?,
      cautionPeriod:
          data['cautionPeriod'] as String? ?? data['riskTiming'] as String?,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 점수 + 별점
          _buildScoreSection(context),

          // 전망 요약
          if (prediction != null && prediction!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildPrediction(context),
          ],

          // 강점 분석
          if (strengths != null && strengths!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildStrengthsSection(context),
          ],

          // 시기 정보
          if (luckyPeriod != null || cautionPeriod != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildTimingSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final colors = context.colors;
    final stars = (score / 20).round().clamp(1, 5);

    return Row(
      children: [
        ScoreCircleWidget(
          score: score,
          size: 70,
          strokeWidth: 5,
        ),
        const SizedBox(width: DSSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💼 커리어 인사이트',
              style: context.heading4.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  size: 18,
                  color: index < stars ? colors.warning : colors.textTertiary,
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrediction(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📈', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              prediction!,
              style: context.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsSection(BuildContext context) {
    final colors = context.colors;

    // 상위 3개 강점만 표시
    final topStrengths = strengths!.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    final displayStrengths = topStrengths.take(3).toList();

    final categories = displayStrengths.map((e) {
      return CategoryScore(
        name: e.key,
        score: (e.value as num).toInt(),
        icon: _getStrengthIcon(e.key),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              '강점 TOP ${categories.length}',
              style: context.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        CategoryBarChart(
          categories: categories,
          barHeight: 8,
          spacing: 10,
          showIcon: false,
          showScore: true,
        ),
      ],
    );
  }

  Widget _buildTimingSection(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        if (luckyPeriod != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.successBackground,
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⏰', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '행운 시기',
                        style: context.labelSmall.copyWith(
                          color: colors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    luckyPeriod!,
                    style: context.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (luckyPeriod != null && cautionPeriod != null)
          const SizedBox(width: DSSpacing.sm),
        if (cautionPeriod != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.warningBackground,
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '주의 시기',
                        style: context.labelSmall.copyWith(
                          color: colors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cautionPeriod!,
                    style: context.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getStrengthIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('리더') || lower.contains('leader')) return '👑';
    if (lower.contains('커뮤') || lower.contains('commun')) return '💬';
    if (lower.contains('문제') || lower.contains('problem')) return '🧩';
    if (lower.contains('창의') || lower.contains('creat')) return '💡';
    if (lower.contains('분석') || lower.contains('analy')) return '📊';
    if (lower.contains('협업') || lower.contains('team')) return '🤝';
    return '⭐';
  }
}
