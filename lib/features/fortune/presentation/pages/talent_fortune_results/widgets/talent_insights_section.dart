import 'package:flutter/material.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class TalentInsightsSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final bool isDark;

  const TalentInsightsSection({
    super.key,
    required this.fortuneResult,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final talentInsights = fortuneResult?.data['talentInsights'] as List<dynamic>? ?? [];

    if (talentInsights.isEmpty) {
      return Center(
        child: Text(
          '재능 인사이트 데이터가 없습니다',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...talentInsights.asMap().entries.map((entry) {
          final index = entry.key;
          final insight = entry.value as Map<String, dynamic>;
          final talent = FortuneTextCleaner.cleanNullable(insight['talent'] as String?);
          final potential = insight['potential'] as int? ?? 0;
          final description = FortuneTextCleaner.cleanNullable(insight['description'] as String?);
          final developmentPath = FortuneTextCleaner.cleanNullable(insight['developmentPath'] as String?);
          final practicalApplications = (insight['practicalApplications'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];
          final monetizationStrategy = FortuneTextCleaner.cleanNullable(insight['monetizationStrategy'] as String?);
          final portfolioBuilding = FortuneTextCleaner.cleanNullable(insight['portfolioBuilding'] as String?);
          final recommendedResources = (insight['recommendedResources'] as List<dynamic>?)?.map((e) => FortuneTextCleaner.clean(e.toString())).toList() ?? [];

          return Padding(
            padding: EdgeInsets.only(bottom: index < talentInsights.length - 1 ? 16 : 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TossDesignSystem.tossBlue,
                              TossDesignSystem.tossBlueDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: TypographyUnified.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          talent,
                          style: TypographyUnified.heading4.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                          ),
                        ),
                      ),
                      Text(
                        '$potential점',
                        style: TypographyUnified.buttonMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TossDesignSystem.tossBlue,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TypographyUnified.bodySmall.copyWith(
                        height: 1.6,
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ],
                  if (developmentPath.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📈 6개월 개발 로드맵',
                            style: TypographyUnified.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TossDesignSystem.tossBlue,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            developmentPath,
                            style: TypographyUnified.bodySmall.copyWith(
                              height: 1.5,
                              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (practicalApplications.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '💼 실전 활용법',
                      style: TypographyUnified.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.warningOrange,
                      ),
                    ),
                    SizedBox(height: 6),
                    ...practicalApplications.map((app) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TypographyUnified.bodySmall),
                          Expanded(
                            child: Text(
                              app,
                              style: TypographyUnified.bodySmall.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  if (monetizationStrategy.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.successGreen.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💰 수익화 전략',
                            style: TypographyUnified.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TossDesignSystem.successGreen,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            monetizationStrategy,
                            style: TypographyUnified.bodySmall.copyWith(
                              height: 1.5,
                              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (portfolioBuilding.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.warningOrange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📁 포트폴리오 구축',
                            style: TypographyUnified.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TossDesignSystem.warningOrange,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            portfolioBuilding,
                            style: TypographyUnified.bodySmall.copyWith(
                              height: 1.5,
                              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (recommendedResources.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '📚 추천 리소스',
                      style: TypographyUnified.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.tossBlue,
                      ),
                    ),
                    SizedBox(height: 6),
                    ...recommendedResources.map((resource) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TypographyUnified.bodySmall),
                          Expanded(
                            child: Text(
                              resource,
                              style: TypographyUnified.bodySmall.copyWith(
                                color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
