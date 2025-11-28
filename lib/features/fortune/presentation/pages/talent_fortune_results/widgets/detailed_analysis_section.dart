import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class DetailedAnalysisSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final bool isDark;

  const DetailedAnalysisSection({
    super.key,
    required this.fortuneResult,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final description = FortuneTextCleaner.cleanNullable(fortuneResult?.data['description'] as String?);
    final hexagonScores = fortuneResult?.data['hexagonScores'] as Map<String, dynamic>?;

    if (description.isEmpty && hexagonScores == null) {
      return Center(
        child: Text(
          '상세 분석 데이터가 없습니다',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
            style: TypographyUnified.bodyMedium.copyWith(
              height: 1.7,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          if (hexagonScores != null) const SizedBox(height: 20),
        ],
        if (hexagonScores != null) ...[
          Text(
            '재능 육각형',
            style: TypographyUnified.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.warningOrange,
            ),
          ),
          const SizedBox(height: 12),
          _buildHexagonScore('창의성', hexagonScores['creativity'] as int? ?? 0, Icons.brush, isDark),
          _buildHexagonScore('기술력', hexagonScores['technique'] as int? ?? 0, Icons.build, isDark),
          _buildHexagonScore('열정', hexagonScores['passion'] as int? ?? 0, Icons.local_fire_department, isDark),
          _buildHexagonScore('훈련', hexagonScores['discipline'] as int? ?? 0, Icons.fitness_center, isDark),
          _buildHexagonScore('독창성', hexagonScores['uniqueness'] as int? ?? 0, Icons.auto_awesome, isDark),
          _buildHexagonScore('시장가치', hexagonScores['marketValue'] as int? ?? 0, Icons.trending_up, isDark),
        ],
      ],
    );
  }

  Widget _buildHexagonScore(String label, int score, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: TossDesignSystem.tossBlue),
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
                      style: TypographyUnified.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '$score',
                      style: TypographyUnified.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TossDesignSystem.tossBlue,
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
                    backgroundColor: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.tossBlue),
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
