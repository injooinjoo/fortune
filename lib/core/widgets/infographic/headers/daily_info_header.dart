import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';
import '../../../theme/typography_unified.dart';
import '../score_circle_widget.dart';
import '../category_bar_chart.dart';
import '../lucky_items_compact.dart';

/// 일일 운세 인포그래픽 헤더
///
/// 기존 히어로 이미지 대신 점수, 카테고리 차트, 행운 요소를 표시
///
/// 사용 예시:
/// ```dart
/// DailyInfoHeader(
///   score: 78,
///   date: '2025.01.08 (수)',
///   categories: {'연애': 82, '재물': 65, '직장': 91, '학업': 74, '건강': 78},
///   luckyItems: {'color': '빨강', 'number': '7', 'direction': '동쪽'},
/// )
/// ```
class DailyInfoHeader extends StatelessWidget {
  /// 종합 점수 (0-100)
  final int score;

  /// 날짜 표시 (예: '2025.01.08 (수)')
  final String? date;

  /// 제목 (기본값: '오늘의 운세')
  final String title;

  /// 카테고리별 점수
  final Map<String, dynamic>? categories;

  /// 행운 요소
  final Map<String, dynamic>? luckyItems;

  /// 행운 요소 표시 여부
  final bool showLuckyItems;

  /// 카테고리 차트 표시 여부
  final bool showCategories;

  const DailyInfoHeader({
    super.key,
    required this.score,
    this.date,
    this.title = '오늘의 운세',
    this.categories,
    this.luckyItems,
    this.showLuckyItems = true,
    this.showCategories = true,
  });

  /// API 응답 데이터에서 생성
  factory DailyInfoHeader.fromData(Map<String, dynamic> data) {
    return DailyInfoHeader(
      score: (data['score'] as num?)?.toInt() ??
          (data['totalScore'] as num?)?.toInt() ??
          75,
      date: data['date'] as String?,
      title: data['title'] as String? ?? '오늘의 운세',
      categories: data['categories'] as Map<String, dynamic>? ??
          data['categoryScores'] as Map<String, dynamic>?,
      luckyItems: data['luckyItems'] as Map<String, dynamic>? ??
          data['lucky'] as Map<String, dynamic>?,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.surfaceSecondary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 점수 원형 + 제목
          _buildScoreSection(context),

          // 카테고리 차트
          if (showCategories && categories != null && categories!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildCategorySection(context),
          ],

          // 행운 요소
          if (showLuckyItems && luckyItems != null && luckyItems!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildLuckySection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        ScoreCircleWidget(
          score: score,
          size: 80,
          strokeWidth: 6,
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.heading3.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  date!,
                  style: context.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final colors = context.colors;
    final categoryScores = CategoryScore.fromFortuneCategories(categories!);

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                '카테고리별 점수',
                style: context.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          CategoryBarChart(
            categories: categoryScores,
            barHeight: 6,
            spacing: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildLuckySection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🍀', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              '행운 요소',
              style: context.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        LuckyItemsCompact.fromMap(luckyItems!),
      ],
    );
  }
}
