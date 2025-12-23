import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/theme/saju_colors.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../data/saju_explanations.dart';
import '../../../domain/models/saju/stem_branch_relations.dart';
import 'saju_concept_card.dart';

/// 합충형파해(合沖刑破害) 표시 위젯
///
/// 사주에서 발견된 천간/지지 간의 관계를 표시합니다.
/// - 합(合): 결합, 조화 - 보라색
/// - 충(沖): 충돌, 변화 - 빨간색
/// - 형(刑): 형벌, 고통 - 주황색
/// - 파(破): 파괴 - 빨간색
/// - 해(害): 해침 - 빨간색
class SajuHapchungWidget extends StatelessWidget {
  /// 사주 데이터
  final Map<String, dynamic> sajuData;

  /// 제목 표시 여부
  final bool showTitle;

  /// 애니메이션 컨트롤러 (optional)
  final AnimationController? animationController;

  const SajuHapchungWidget({
    super.key,
    required this.sajuData,
    this.showTitle = true,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final relations = _analyzeRelations();

    if (relations.isEmpty) {
      return const SizedBox.shrink();
    }

    final combinationRelations = StemBranchRelations.filterByType(
      relations,
      RelationType.combination,
    );
    final inauspiciousRelations = StemBranchRelations.filterInauspicious(relations);

    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle) ...[
            _buildTitle(context, isDark),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 관계 요약 시각화
          _buildRelationSummary(context, relations, isDark),
          const SizedBox(height: DSSpacing.sm),
          // 합(合) 섹션
          if (combinationRelations.isNotEmpty) ...[
            _buildSectionHeader(context, RelationType.combination, isDark),
            const SizedBox(height: DSSpacing.sm),
            ...combinationRelations.map((r) => _buildRelationItem(context, r, isDark)),
            const SizedBox(height: DSSpacing.md),
          ],
          // 충/형/파/해 섹션
          if (inauspiciousRelations.isNotEmpty) ...[
            _buildSectionHeader(context, null, isDark, isInauspicious: true),
            const SizedBox(height: DSSpacing.sm),
            ...inauspiciousRelations.map((r) => _buildRelationItem(context, r, isDark)),
          ],
          // 종합 해석
          if (relations.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildSummary(
              context,
              combinationRelations.length,
              inauspiciousRelations.length,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    return Row(
      children: [
        const Icon(
          Icons.swap_horizontal_circle_outlined,
          color: DSColors.accent,
          size: 20,
        ),
        const SizedBox(width: DSSpacing.xs),
        Row(
          children: [
            Text(
              '합충형파해',
              style: context.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '合沖刑破害',
              style: context.labelSmall.copyWith(
                color: isDark
                    ? DSColors.textTertiary
                    : DSColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRelationSummary(BuildContext context, List<SajuRelation> relations, bool isDark) {
    final typeCounts = <RelationType, int>{};
    for (final relation in relations) {
      typeCounts[relation.type] = (typeCounts[relation.type] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? DSColors.surface
            : DSColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: RelationType.values.map((type) {
          final count = typeCounts[type] ?? 0;
          final color = type.getColor(isDark: isDark);

          // 합충 데이터 조회
          final hapchungData = SajuExplanations.hapchung[type.hanja];

          return GestureDetector(
            onTap: () {
              if (hapchungData != null) {
                showHapchungExplanationSheet(
                  context: context,
                  hanja: type.hanja,
                  korean: type.korean,
                  meaning: hapchungData['meaning'] ?? '',
                  description: hapchungData['description'] ?? '',
                  effect: hapchungData['effect'] ?? '',
                  relationColor: color,
                  realLife: hapchungData['realLife'],
                  advice: hapchungData['advice'],
                );
              }
            },
            child: Column(
              children: [
                // 한자
                Text(
                  type.hanja,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: count > 0 ? color : (isDark ? DSColors.textSecondary : DSColors.textTertiary),
                  ),
                ),
                // 한글 + 개수
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.korean,
                      style: context.labelTiny.copyWith(
                        color: count > 0
                            ? (isDark ? DSColors.textTertiary : DSColors.textSecondary)
                            : (isDark ? DSColors.textSecondary : DSColors.textTertiary),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: count > 0
                            ? color.withValues(alpha: 0.2)
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: context.labelTiny.copyWith(
                            fontWeight: FontWeight.bold,
                            color: count > 0
                                ? color
                                : (isDark ? DSColors.textSecondary : DSColors.textTertiary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    RelationType? type,
    bool isDark, {
    bool isInauspicious = false,
  }) {
    Color color;
    String title;
    String hanja;
    IconData icon;

    if (isInauspicious) {
      color = SajuColors.inauspiciousLight;
      title = '충형파해';
      hanja = '沖刑破害';
      icon = Icons.warning_amber_outlined;
    } else if (type != null) {
      color = type.getColor(isDark: isDark);
      title = type.korean;
      hanja = type.hanja;
      icon = type == RelationType.combination
          ? Icons.link_outlined
          : Icons.broken_image_outlined;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: DSSpacing.xs),
          Text(
            title,
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hanja,
            style: context.labelSmall.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationItem(BuildContext context, SajuRelation relation, bool isDark) {
    final color = relation.type.getColor(isDark: isDark);

    // 합충 데이터 조회
    final hapchungData = SajuExplanations.hapchung[relation.type.hanja];

    return GestureDetector(
      onTap: () {
        if (hapchungData != null) {
          showHapchungExplanationSheet(
            context: context,
            hanja: relation.type.hanja,
            korean: relation.type.korean,
            meaning: hapchungData['meaning'] ?? '',
            description: '${hapchungData['description'] ?? ''}\n\n📍 ${relation.name}\n${relation.description}',
            effect: hapchungData['effect'] ?? '',
            relationColor: color,
            realLife: hapchungData['realLife'],
            advice: hapchungData['advice'],
          );
        }
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: DSSpacing.xs),
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? DSColors.surface
            : DSColors.background,
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 관계 한자 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...relation.hanjaCharacters.map((char) {
                      return Text(
                        char,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          relation.name,
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            relation.type.hanja,
                            style: context.labelTiny.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (relation.positions != null &&
                        relation.positions!.isNotEmpty)
                      Text(
                        relation.positions!.join(' - '),
                        style: context.labelTiny.copyWith(
                          color: isDark
                              ? DSColors.textTertiary
                              : DSColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // 결과 오행 표시 (합의 경우)
              if (relation.resultWuxing != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: SajuColors.getWuxingBackgroundColor(
                      relation.resultWuxing!,
                      isDark: isDark,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SajuColors.getWuxingColor(
                        relation.resultWuxing!,
                        isDark: isDark,
                      ).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: SajuColors.getWuxingColor(
                          relation.resultWuxing!,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        relation.resultWuxing!,
                        style: context.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: SajuColors.getWuxingColor(
                            relation.resultWuxing!,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          // 설명
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(DSRadius.sm),
            ),
            child: Text(
              relation.description,
              style: context.labelTiny.copyWith(
                color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    int combinationCount,
    int inauspiciousCount,
    bool isDark,
  ) {
    String summaryText;
    Color summaryColor;
    IconData summaryIcon;

    if (combinationCount > inauspiciousCount) {
      summaryText = '합이 우세합니다. 조화롭고 협력적인 기운이 강합니다.';
      summaryColor = SajuColors.combinationLight;
      summaryIcon = Icons.sentiment_very_satisfied_outlined;
    } else if (inauspiciousCount > combinationCount) {
      summaryText = '충/형이 있습니다. 변화와 도전이 예상되지만 성장의 기회가 됩니다.';
      summaryColor = SajuColors.clashLight;
      summaryIcon = Icons.sentiment_neutral_outlined;
    } else if (combinationCount == 0 && inauspiciousCount == 0) {
      summaryText = '특별한 관계가 없습니다. 안정적인 사주입니다.';
      summaryColor = DSColors.textSecondary;
      summaryIcon = Icons.balance_outlined;
    } else {
      summaryText = '합과 충이 균형을 이룹니다. 상황에 따라 유연하게 대처하세요.';
      summaryColor = SajuColors.neutralLight;
      summaryIcon = Icons.balance_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            summaryColor.withValues(alpha: 0.1),
            summaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: summaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(summaryIcon, color: summaryColor, size: 18),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              summaryText,
              style: context.labelTiny.copyWith(
                color:
                    isDark ? DSColors.textTertiary : DSColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SajuRelation> _analyzeRelations() {
    // 사주 데이터에서 필요한 값 추출
    final yearData = sajuData['year'] as Map<String, dynamic>?;
    final monthData = sajuData['month'] as Map<String, dynamic>?;
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    final hourData = sajuData['hour'] as Map<String, dynamic>?;

    final yearStem =
        (yearData?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ??
            '';
    final monthStem = (monthData?['cheongan']
            as Map<String, dynamic>?)?['char'] as String? ??
        '';
    final dayStem =
        (dayData?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ??
            '';
    final hourStem =
        (hourData?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ??
            '';

    final yearBranch =
        (yearData?['jiji'] as Map<String, dynamic>?)?['char'] as String? ?? '';
    final monthBranch =
        (monthData?['jiji'] as Map<String, dynamic>?)?['char'] as String? ?? '';
    final dayBranch =
        (dayData?['jiji'] as Map<String, dynamic>?)?['char'] as String? ?? '';
    final hourBranch =
        (hourData?['jiji'] as Map<String, dynamic>?)?['char'] as String? ?? '';

    if (yearStem.isEmpty || yearBranch.isEmpty) {
      return [];
    }

    return StemBranchRelations.analyzeAllRelations(
      yearStem: yearStem,
      monthStem: monthStem,
      dayStem: dayStem,
      hourStem: hourStem,
      yearBranch: yearBranch,
      monthBranch: monthBranch,
      dayBranch: dayBranch,
      hourBranch: hourBranch,
    );
  }
}
