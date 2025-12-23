import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';

class TalentInsightsSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;

  const TalentInsightsSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final talentInsights = fortuneResult?.data['talentInsights'] as List<dynamic>? ?? [];

    if (talentInsights.isEmpty) {
      return Center(
        child: Text(
          '재능 인사이트 데이터가 없습니다',
          style: context.bodySmall.copyWith(
            color: colors.textSecondary,
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
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.2),
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
                              colors.accent,
                              colors.accent.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: context.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          talent,
                          style: context.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '$potential점',
                        style: context.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.accent,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: context.bodySmall.copyWith(
                        height: 1.6,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  if (developmentPath.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📈 6개월 개발 로드맵',
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.accent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            developmentPath,
                            style: context.bodySmall.copyWith(
                              height: 1.5,
                              color: colors.textSecondary,
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
                      style: context.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DSColors.warning,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...practicalApplications.map((app) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: context.bodySmall),
                          Expanded(
                            child: Text(
                              app,
                              style: context.bodySmall.copyWith(
                                color: colors.textSecondary,
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
                        color: DSColors.success.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💰 수익화 전략',
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: DSColors.success,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            monetizationStrategy,
                            style: context.bodySmall.copyWith(
                              height: 1.5,
                              color: colors.textSecondary,
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
                        color: DSColors.warning.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📁 포트폴리오 구축',
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: DSColors.warning,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            portfolioBuilding,
                            style: context.bodySmall.copyWith(
                              height: 1.5,
                              color: colors.textSecondary,
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
                      style: context.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.accent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...recommendedResources.map((resource) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: context.bodySmall),
                          Expanded(
                            child: Text(
                              resource,
                              style: context.bodySmall.copyWith(
                                color: colors.textSecondary,
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
