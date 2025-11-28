import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class OverviewSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final bool isDark;

  const OverviewSection({
    super.key,
    required this.fortuneResult,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final content = FortuneTextCleaner.cleanNullable(fortuneResult?.data['content'] as String?);
    final score = fortuneResult?.score ?? 0;
    final luckyItems = fortuneResult?.data['luckyItems'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.tossBlue.withValues(alpha: 0.1),
            TossDesignSystem.tossBlueDark.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '재능 발견 운세',
                        style: TypographyUnified.heading1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'LLM이 분석한 당신의 재능과 잠재력',
                        style: TypographyUnified.bodySmall.copyWith(
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // 종합 점수 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.tossBlue,
                        TossDesignSystem.tossBlueDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score점',
                        style: TypographyUnified.heading2.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '재능 점수',
                        style: TypographyUnified.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // LLM 분석 브리핑
            if (content.isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: TossDesignSystem.tossBlue,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI 재능 브리핑',
                          style: TypographyUnified.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: TypographyUnified.bodyMedium.copyWith(
                        height: 1.7,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

            if (content.isNotEmpty) const SizedBox(height: 16),

            // 행운 아이템
            if (luckyItems != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: TossDesignSystem.warningOrange,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '행운 아이템',
                          style: TypographyUnified.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLuckyItem('색상', luckyItems['color'] as String? ?? '', Icons.palette, isDark),
                    _buildLuckyItem('숫자', '${luckyItems['number'] ?? ''}', Icons.filter_9_plus, isDark),
                    _buildLuckyItem('방향', luckyItems['direction'] as String? ?? '', Icons.explore, isDark),
                    _buildLuckyItem('도구', luckyItems['tool'] as String? ?? '', Icons.build_circle, isDark),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyItem(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: TossDesignSystem.tossBlue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TypographyUnified.labelSmall.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  ),
                ),
                Text(
                  value,
                  style: TypographyUnified.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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
