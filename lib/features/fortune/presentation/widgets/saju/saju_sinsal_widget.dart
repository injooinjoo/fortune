import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/components/app_card.dart';
import '../../../domain/models/saju/sinsal_data.dart';
import '../../../domain/models/saju/sinsal_detail_data.dart';
import 'saju_concept_card.dart';

/// 신살(神殺) 표시 위젯
///
/// 사주에서 발견된 신살들을 길신/흉신으로 구분하여 표시합니다.
/// - 길신(吉神): 초록색 계열
/// - 흉신(凶神): 빨간색 계열
/// - 중립: 주황색 계열
class SajuSinsalWidget extends StatelessWidget {
  /// 사주 데이터
  final Map<String, dynamic> sajuData;

  /// 제목 표시 여부
  final bool showTitle;

  /// 상세 설명 표시 여부
  final bool showDetails;

  /// 애니메이션 컨트롤러 (optional)
  final AnimationController? animationController;

  const SajuSinsalWidget({
    super.key,
    required this.sajuData,
    this.showTitle = true,
    this.showDetails = true,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final sinsals = _analyzeSinsals();

    if (sinsals.isEmpty) {
      return const SizedBox.shrink();
    }

    final luckySinsals = SinsalData.filterLucky(sinsals);
    final unluckySinsals = SinsalData.filterUnlucky(sinsals);
    final neutralSinsals =
        sinsals.where((s) => s.category == SinsalCategory.neutral).toList();

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
          // 길신 섹션
          if (luckySinsals.isNotEmpty) ...[
            _buildSectionHeader(
                context, '길신', '吉神', SinsalCategory.lucky, isDark),
            const SizedBox(height: DSSpacing.sm),
            ...luckySinsals.map((s) => _buildSinsalItem(context, s, isDark)),
            const SizedBox(height: DSSpacing.md),
          ],
          // 중립 섹션 (도화살 등)
          if (neutralSinsals.isNotEmpty) ...[
            _buildSectionHeader(
                context, '중립', '中立', SinsalCategory.neutral, isDark),
            const SizedBox(height: DSSpacing.sm),
            ...neutralSinsals.map((s) => _buildSinsalItem(context, s, isDark)),
            const SizedBox(height: DSSpacing.md),
          ],
          // 흉신 섹션
          if (unluckySinsals.isNotEmpty) ...[
            _buildSectionHeader(
                context, '흉신', '凶神', SinsalCategory.unlucky, isDark),
            const SizedBox(height: DSSpacing.sm),
            ...unluckySinsals.map((s) => _buildSinsalItem(context, s, isDark)),
          ],
          // 종합 해석
          if (sinsals.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildSummary(
                context, luckySinsals.length, unluckySinsals.length, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    return Row(
      children: [
        const Icon(
          Icons.stars_outlined,
          color: DSColors.accent,
          size: 20,
        ),
        const SizedBox(width: DSSpacing.xs),
        Row(
          children: [
            Text(
              '신살',
              style: context.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: DSSpacing.xs),
            Text(
              '神殺',
              style: context.labelSmall.copyWith(
                color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String hanja,
    SinsalCategory category,
    bool isDark,
  ) {
    final color = category.getColor(isDark: isDark);

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
          Icon(
            category == SinsalCategory.lucky
                ? Icons.thumb_up_outlined
                : category == SinsalCategory.unlucky
                    ? Icons.warning_amber_outlined
                    : Icons.balance_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(
            title,
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
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

  Widget _buildSinsalItem(BuildContext context, Sinsal sinsal, bool isDark) {
    final color = sinsal.getColor(isDark: isDark);

    // 신살 타입 결정
    String sinsalType;
    switch (sinsal.category) {
      case SinsalCategory.lucky:
        sinsalType = '길신';
        break;
      case SinsalCategory.unlucky:
        sinsalType = '흉신';
        break;
      case SinsalCategory.neutral:
        sinsalType = '중립';
        break;
    }

    // 보강된 신살 데이터 조회
    final detailData = SinsalDetailDataProvider.sinsalData[sinsal.name];

    // 보강된 콘텐츠 포맷팅
    String? realLife;
    String? goodSide;
    String? tips;
    String? career;

    if (detailData != null) {
      // 친근한 설명 + 실생활 예시
      final examples = detailData['realLifeExamples'] as List<dynamic>?;
      if (examples != null && examples.isNotEmpty) {
        realLife =
            '${detailData['friendlyExplanation'] ?? ''}\n\n📌 이런 분이에요:\n${examples.take(4).map((e) => '• $e').join('\n')}';
      } else {
        realLife = detailData['friendlyExplanation'] as String?;
      }

      // 활용/활성화 팁
      final activationTips = detailData['activationTips'] as List<dynamic>?;
      if (activationTips != null && activationTips.isNotEmpty) {
        goodSide = '✨ 활용법:\n${activationTips.map((e) => '• $e').join('\n')}';
      }

      // 실용적 조언
      final seasonalTips = detailData['seasonalTips'] as Map<String, dynamic>?;
      if (seasonalTips != null) {
        tips =
            '📅 시기별 팁:\n• 최적기: ${seasonalTips['best'] ?? ''}\n• 주의: ${seasonalTips['caution'] ?? ''}';
      }

      // 커리어 팁
      final careerTips = detailData['careerTips'] as List<dynamic>?;
      if (careerTips != null && careerTips.isNotEmpty) {
        career = '💼 커리어:\n${careerTips.map((e) => '• $e').join('\n')}';
      }
    }

    return GestureDetector(
      onTap: () {
        showSinsalExplanationSheet(
          context: context,
          hanja: sinsal.hanja,
          korean: sinsal.name,
          type: sinsalType,
          meaning: sinsal.meaning,
          description: '${sinsal.description}\n\n💡 ${sinsal.remedy}',
          sinsalColor: color,
          // 보강된 콘텐츠
          realLife: realLife,
          goodSide: goodSide,
          tips: tips,
          career: career,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: DSSpacing.xs),
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? DSColors.surface : DSColors.background,
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
                // 한자 크게
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Center(
                    child: Text(
                      sinsal.hanja.length > 2
                          ? sinsal.hanja.substring(0, 2)
                          : sinsal.hanja,
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
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
                            sinsal.name,
                            style: context.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: DSSpacing.xs),
                          Text(
                            sinsal.hanja,
                            style: context.labelTiny.copyWith(
                              color: isDark
                                  ? DSColors.textTertiary
                                  : DSColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        sinsal.meaning,
                        style: context.labelTiny.copyWith(
                          color: isDark
                              ? DSColors.textTertiary
                              : DSColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11, // 예외: 초소형 신살 의미
                        ),
                      ),
                    ],
                  ),
                ),
                // 위치 표시
                if (sinsal.position != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sinsal.position!,
                      style: context.labelTiny.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (showDetails) ...[
              const SizedBox(height: DSSpacing.xs),
              // 상세 설명
              Text(
                sinsal.description,
                style: context.labelTiny.copyWith(
                  color:
                      isDark ? DSColors.textTertiary : DSColors.textSecondary,
                  fontSize: 11, // 예외: 초소형 신살 설명
                ),
              ),
              const SizedBox(height: DSSpacing.xs),
              // 해소/활용법
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: DSColors.warning,
                      size: 12,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        sinsal.remedy,
                        style: context.labelTiny.copyWith(
                          color: isDark
                              ? DSColors.textTertiary
                              : DSColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
      BuildContext context, int luckyCount, int unluckyCount, bool isDark) {
    String summaryText;
    Color summaryColor;
    IconData summaryIcon;

    if (luckyCount > unluckyCount) {
      summaryText = '길신이 우세합니다. 전반적으로 행운이 따르는 사주입니다.';
      summaryColor = SajuColors.auspiciousLight;
      summaryIcon = Icons.sentiment_very_satisfied_outlined;
    } else if (unluckyCount > luckyCount) {
      summaryText = '흉신이 있지만 적절한 대처로 액운을 피할 수 있습니다.';
      summaryColor = SajuColors.inauspiciousLight;
      summaryIcon = Icons.sentiment_neutral_outlined;
    } else {
      summaryText = '길흉이 균형을 이루고 있습니다. 중립적인 운세입니다.';
      summaryColor = SajuColors.neutralLight;
      summaryIcon = Icons.balance_outlined;
    }

    if (isDark) {
      summaryColor = summaryColor.withValues(alpha: 0.8);
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
          Icon(
            summaryIcon,
            color: summaryColor,
            size: 18,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              summaryText,
              style: context.labelTiny.copyWith(
                color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                fontSize: 11, // 예외: 초소형 신살 요약
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Sinsal> _analyzeSinsals() {
    // 사주 데이터에서 필요한 값 추출
    final yearData = sajuData['year'] as Map<String, dynamic>?;
    final monthData = sajuData['month'] as Map<String, dynamic>?;
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    final hourData = sajuData['hour'] as Map<String, dynamic>?;

    final yearStem =
        (yearData?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ??
            '';
    final monthStem =
        (monthData?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ??
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

    if (dayStem.isEmpty || yearBranch.isEmpty) {
      return [];
    }

    return SinsalData.analyzeAllSinsal(
      dayStem: dayStem,
      yearStem: yearStem,
      monthStem: monthStem,
      hourStem: hourStem,
      yearBranch: yearBranch,
      monthBranch: monthBranch,
      dayBranch: dayBranch,
      hourBranch: hourBranch,
    );
  }
}
