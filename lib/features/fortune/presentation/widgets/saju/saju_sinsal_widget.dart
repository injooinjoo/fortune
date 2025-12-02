import 'package:flutter/material.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/saju_colors.dart';
import '../../../../../core/components/app_card.dart';
import '../../../domain/models/saju/sinsal_data.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sinsals = _analyzeSinsals();

    if (sinsals.isEmpty) {
      return const SizedBox.shrink();
    }

    final luckySinsals = SinsalData.filterLucky(sinsals);
    final unluckySinsals = SinsalData.filterUnlucky(sinsals);
    final neutralSinsals =
        sinsals.where((s) => s.category == SinsalCategory.neutral).toList();

    return AppCard(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle) ...[
            _buildTitle(isDark),
            const SizedBox(height: TossTheme.spacingS),
          ],
          // 길신 섹션
          if (luckySinsals.isNotEmpty) ...[
            _buildSectionHeader('길신', '吉神', SinsalCategory.lucky, isDark),
            const SizedBox(height: TossTheme.spacingS),
            ...luckySinsals.map((s) => _buildSinsalItem(s, isDark)),
            const SizedBox(height: TossTheme.spacingM),
          ],
          // 중립 섹션 (도화살 등)
          if (neutralSinsals.isNotEmpty) ...[
            _buildSectionHeader('중립', '中立', SinsalCategory.neutral, isDark),
            const SizedBox(height: TossTheme.spacingS),
            ...neutralSinsals.map((s) => _buildSinsalItem(s, isDark)),
            const SizedBox(height: TossTheme.spacingM),
          ],
          // 흉신 섹션
          if (unluckySinsals.isNotEmpty) ...[
            _buildSectionHeader('흉신', '凶神', SinsalCategory.unlucky, isDark),
            const SizedBox(height: TossTheme.spacingS),
            ...unluckySinsals.map((s) => _buildSinsalItem(s, isDark)),
          ],
          // 종합 해석
          if (sinsals.isNotEmpty) ...[
            const SizedBox(height: TossTheme.spacingS),
            _buildSummary(luckySinsals.length, unluckySinsals.length, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.stars_outlined,
          color: TossTheme.brandBlue,
          size: 20,
        ),
        const SizedBox(width: TossTheme.spacingXS),
        Row(
          children: [
            Text(
              '신살',
              style: TossTheme.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '神殺',
              style: TossTheme.caption.copyWith(
                color: isDark
                    ? TossTheme.textGray400
                    : TossTheme.textGray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    String hanja,
    SinsalCategory category,
    bool isDark,
  ) {
    final color = category.getColor(isDark: isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossTheme.spacingM,
        vertical: TossTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
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
          const SizedBox(width: TossTheme.spacingXS),
          Text(
            title,
            style: TossTheme.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hanja,
            style: TossTheme.caption.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinsalItem(Sinsal sinsal, bool isDark) {
    final color = sinsal.getColor(isDark: isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: TossTheme.spacingXS),
      padding: const EdgeInsets.all(TossTheme.spacingS),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.cardBackgroundDark
            : TossTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
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
                  borderRadius: BorderRadius.circular(TossTheme.radiusS),
                ),
                child: Center(
                  child: Text(
                    sinsal.hanja.length > 2
                        ? sinsal.hanja.substring(0, 2)
                        : sinsal.hanja,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TossTheme.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sinsal.name,
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sinsal.hanja,
                          style: TossTheme.caption.copyWith(
                            color: isDark
                                ? TossTheme.textGray400
                                : TossTheme.textGray600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      sinsal.meaning,
                      style: TossTheme.caption.copyWith(
                        color: isDark
                            ? TossDesignSystem.grayDark600
                            : TossDesignSystem.gray700,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
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
                    style: TossTheme.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: TossTheme.spacingXS),
            // 상세 설명
            Text(
              sinsal.description,
              style: TossTheme.caption.copyWith(
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: TossTheme.spacingXS),
            // 해소/활용법
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TossTheme.spacingS,
                vertical: TossTheme.spacingXS,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(TossTheme.radiusS),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: TossTheme.warning,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      sinsal.remedy,
                      style: TossTheme.caption.copyWith(
                        color: isDark
                            ? TossDesignSystem.grayDark600
                            : TossDesignSystem.gray700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(int luckyCount, int unluckyCount, bool isDark) {
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
        horizontal: TossTheme.spacingS,
        vertical: TossTheme.spacingXS,
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
        borderRadius: BorderRadius.circular(TossTheme.radiusS),
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
          const SizedBox(width: TossTheme.spacingS),
          Expanded(
            child: Text(
              summaryText,
              style: TossTheme.caption.copyWith(
                color:
                    isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray700,
                fontSize: 11,
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
