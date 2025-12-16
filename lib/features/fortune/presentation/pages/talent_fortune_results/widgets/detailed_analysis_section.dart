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
          Text(
            description,
            style: DSTypography.bodyMedium.copyWith(
              height: 1.7,
              color: colors.textPrimary,
            ),
          ),
          if (hexagonScores != null) const SizedBox(height: 20),
        ],
        if (hexagonScores != null) ...[
          Text(
            '재능 육각형',
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: DSColors.warning,
            ),
          ),
          const SizedBox(height: 12),
          _buildHexagonScore('창의성', hexagonScores['creativity'] as int? ?? 0, Icons.brush, colors),
          _buildHexagonScore('기술력', hexagonScores['technique'] as int? ?? 0, Icons.build, colors),
          _buildHexagonScore('열정', hexagonScores['passion'] as int? ?? 0, Icons.local_fire_department, colors),
          _buildHexagonScore('훈련', hexagonScores['discipline'] as int? ?? 0, Icons.fitness_center, colors),
          _buildHexagonScore('독창성', hexagonScores['uniqueness'] as int? ?? 0, Icons.auto_awesome, colors),
          _buildHexagonScore('시장가치', hexagonScores['marketValue'] as int? ?? 0, Icons.trending_up, colors),
        ],
      ],
    );
  }

  Widget _buildHexagonScore(String label, int score, IconData icon, DSColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.accent),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: DSTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '$score',
                      style: DSTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: colors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
