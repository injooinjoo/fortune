import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class DetailedAnalysisSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const DetailedAnalysisSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final description = FortuneTextCleaner.cleanNullable(fortuneResult?.data['description'] as String?);
    final hexagonScores = fortuneResult?.data['hexagonScores'] as Map<String, dynamic>?;

    if (description.isEmpty && hexagonScores == null) {
      return Center(
        child: Text(
          '상세 분석 데이터가 없습니다',
          style: DSTypography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description.isNotEmpty) ...[
          _buildFormattedDescription(description),
          if (hexagonScores != null) ...[
            const SizedBox(height: 24),
            Divider(color: colors.border.withValues(alpha: 0.5), height: 1),
            const SizedBox(height: 24),
          ],
        ],
        if (hexagonScores != null) ...[
          _buildHexagonHeader(),
          const SizedBox(height: 16),
          _buildHexagonGrid(hexagonScores),
        ],
      ],
    );
  }

  /// 설명 텍스트를 문단 단위로 포맷팅
  Widget _buildFormattedDescription(String description) {
    // 줄바꿈 또는 마침표+공백으로 문단 분리
    final paragraphs = description
        .split(RegExp(r'\n\n|\n(?=[가-힣A-Z])'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    if (paragraphs.length == 1) {
      // 단일 문단인 경우 그대로 표시
      return Text(
        description,
        style: DSTypography.bodyMedium.copyWith(
          height: 1.8,
          color: colors.textPrimary,
        ),
      );
    }

    // 여러 문단인 경우 간격을 두고 표시
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.asMap().entries.map((entry) {
        final index = entry.key;
        final paragraph = entry.value.trim();

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < paragraphs.length - 1 ? 16 : 0,
          ),
          child: Text(
            paragraph,
            style: DSTypography.bodyMedium.copyWith(
              height: 1.8,
              color: colors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 재능 육각형 헤더
  Widget _buildHexagonHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DSColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.hexagon_outlined,
            size: 20,
            color: DSColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '재능 육각형',
              style: DSTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            Text(
              '6가지 핵심 역량 분석',
              style: DSTypography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 육각형 점수를 2열 그리드로 표시
  Widget _buildHexagonGrid(Map<String, dynamic> hexagonScores) {
    final items = [
      _HexagonItem('창의성', hexagonScores['creativity'] as int? ?? 0, Icons.brush, DSColors.warning),
      _HexagonItem('기술력', hexagonScores['technique'] as int? ?? 0, Icons.build, colors.accent),
      _HexagonItem('열정', hexagonScores['passion'] as int? ?? 0, Icons.local_fire_department, DSColors.error),
      _HexagonItem('훈련', hexagonScores['discipline'] as int? ?? 0, Icons.fitness_center, DSColors.success),
      _HexagonItem('독창성', hexagonScores['uniqueness'] as int? ?? 0, Icons.auto_awesome, Colors.purple),
      _HexagonItem('시장가치', hexagonScores['marketValue'] as int? ?? 0, Icons.trending_up, Colors.blue),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) => _buildHexagonCard(item)).toList(),
    );
  }

  Widget _buildHexagonCard(_HexagonItem item) {
    final scoreColor = _getScoreColor(item.score);
    final scoreLabel = _getScoreLabel(item.score);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 16, color: item.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  style: DSTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${item.score}',
                style: DSTypography.headingMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  scoreLabel,
                  style: DSTypography.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.score / 100,
              minHeight: 4,
              backgroundColor: colors.border.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return colors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return '최상';
    if (score >= 80) return '우수';
    if (score >= 70) return '양호';
    if (score >= 60) return '보통';
    if (score >= 40) return '발전 필요';
    return '집중 필요';
  }
}

class _HexagonItem {
  final String label;
  final int score;
  final IconData icon;
  final Color color;

  _HexagonItem(this.label, this.score, this.icon, this.color);
}
