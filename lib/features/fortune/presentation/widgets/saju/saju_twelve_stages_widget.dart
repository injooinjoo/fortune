import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../data/saju_explanations.dart';
import '../../../domain/models/saju/twelve_stage_calculator.dart';
import 'saju_concept_card.dart';

/// 12운성(十二運星) 표시 위젯
///
/// 일간의 오행이 각 지지에서 어떤 생명 주기 단계에 있는지 표시합니다.
/// 장생 → 목욕 → 관대 → 건록 → 제왕 → 쇠 → 병 → 사 → 묘 → 절 → 태 → 양
class SajuTwelveStagesWidget extends StatelessWidget {
  /// 사주 데이터
  final Map<String, dynamic> sajuData;

  /// 제목 표시 여부
  final bool showTitle;

  /// 애니메이션 컨트롤러 (optional)
  final AnimationController? animationController;

  const SajuTwelveStagesWidget({
    super.key,
    required this.sajuData,
    this.showTitle = true,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stages = _calculateStages();

    if (stages.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalStrength = stages.values.fold(0, (sum, stage) => sum + stage.strength);
    final strengthLevel = _getStrengthLevel(totalStrength);

    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle) ...[
            _buildTitle(context, isDark),
            const SizedBox(height: DSSpacing.md),
          ],
          // 12운성 테이블
          _buildStagesTable(context, stages, isDark),
          const SizedBox(height: DSSpacing.md),
          // 신강/신약 판단
          _buildStrengthIndicator(context, totalStrength, strengthLevel, isDark),
          const SizedBox(height: DSSpacing.sm),
          // 각 운성 설명
          _buildStageDescriptions(context, stages, isDark),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.loop_outlined,
          color: DSColors.accent,
          size: 20,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '12운성',
                    style: context.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '十二運星',
                    style: context.labelSmall.copyWith(
                      color: isDark
                          ? DSColors.textTertiary
                          : DSColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '일간의 생명력 주기를 나타내는 12단계',
                style: context.labelTiny.copyWith(
                  color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStagesTable(
    BuildContext context,
    Map<String, TwelveStage> stages,
    bool isDark,
  ) {
    final pillars = [
      {'title': '년주', 'hanja': '年柱', 'key': 'year'},
      {'title': '월주', 'hanja': '月柱', 'key': 'month'},
      {'title': '일주', 'hanja': '日柱', 'key': 'day'},
      {'title': '시주', 'hanja': '時柱', 'key': 'hour'},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.border,
        ),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? DSColors.surface
                  : DSColors.backgroundSecondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DSRadius.md),
                topRight: Radius.circular(DSRadius.md),
              ),
            ),
            child: Row(
              children: pillars.asMap().entries.map((entry) {
                final index = entry.key;
                final pillar = entry.value;
                final isDay = pillar['key'] == 'day';

                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: index < pillars.length - 1
                            ? BorderSide(
                                color: isDark
                                    ? DSColors.border
                                    : DSColors.border,
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                      color: isDay
                          ? DSColors.accent.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pillar['hanja']!,
                          style: context.labelTiny.copyWith(
                            color: isDark
                                ? DSColors.textTertiary
                                : DSColors.textSecondary,
                          ),
                        ),
                        Text(
                          pillar['title']!,
                          style: context.labelSmall.copyWith(
                            fontWeight: isDay ? FontWeight.bold : FontWeight.w600,
                            color: isDay ? DSColors.accent : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 12운성 행
          Row(
            children: pillars.asMap().entries.map((entry) {
              final index = entry.key;
              final pillar = entry.value;
              final stage = stages[pillar['key']];
              final isDay = pillar['key'] == 'day';

              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      right: index < pillars.length - 1
                          ? BorderSide(
                              color: isDark
                                  ? DSColors.border
                                  : DSColors.border,
                              width: 1,
                            )
                          : BorderSide.none,
                    ),
                    color: isDay
                        ? DSColors.accent.withValues(alpha: 0.05)
                        : null,
                    borderRadius: index == 0
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(DSRadius.md),
                          )
                        : index == pillars.length - 1
                            ? const BorderRadius.only(
                                bottomRight: Radius.circular(DSRadius.md),
                              )
                            : null,
                  ),
                  child: _buildStageCell(context, stage, isDay, isDark),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCell(BuildContext context, TwelveStage? stage, bool isDay, bool isDark) {
    if (stage == null) {
      return const Center(child: Text('-'));
    }

    final color = stage.color;

    // 12운성 설명 데이터 조회
    final stageData = SajuExplanations.twelveStages[stage.korean];

    return GestureDetector(
      onTap: () {
        showTwelveStageExplanationSheet(
          context: context,
          hanja: stage.hanja,
          korean: stage.korean,
          meaning: stage.meaning,
          description: stageData?['description'] ?? stage.meaning,
          fortune: stage.fortune,
          stageColor: color,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 한자 - 컴팩트 사이즈
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stage.hanja,
              style: isDay
                  ? context.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DSColors.accent,
                    )
                  : context.heading4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              textAlign: TextAlign.center,
            ),
          ),
          // 한글
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stage.korean,
              style: context.labelTiny.copyWith(
                color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          // 강도 표시 (세련된 도트 스타일)
          _buildStrengthBadge(stage.strength, color),
        ],
      ),
    );
  }

  Widget _buildStrengthBadge(int strength, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Container(
            width: 4,
            height: 4,
            margin: EdgeInsets.only(left: index > 0 ? 1.5 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < strength ? color : color.withValues(alpha: 0.2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStrengthIndicator(
    BuildContext context,
    int totalStrength,
    String strengthLevel,
    bool isDark,
  ) {
    Color levelColor;
    String levelDescription;
    IconData levelIcon;

    switch (strengthLevel) {
      case '신강':
        levelColor = const Color(0xFF10B981); // 에메랄드 그린
        levelDescription = '일간의 기운이 강합니다. 능동적이고 독립적인 성향을 가집니다.';
        levelIcon = Icons.trending_up;
        break;
      case '신약':
        levelColor = const Color(0xFFF43F5E); // 로즈 핑크
        levelDescription = '일간의 기운이 약합니다. 협력과 지원을 통해 성장합니다.';
        levelIcon = Icons.trending_down;
        break;
      default:
        levelColor = const Color(0xFFF59E0B); // 앰버
        levelDescription = '일간의 기운이 균형을 이룹니다. 상황에 따라 유연하게 대처합니다.';
        levelIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColor.withValues(alpha: 0.15),
            levelColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  levelIcon,
                  color: levelColor,
                  size: 14,
                ),
                Text(
                  '$totalStrength',
                  style: context.labelTiny.copyWith(
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      strengthLevel,
                      style: context.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      strengthLevel == '신강'
                          ? '身強'
                          : strengthLevel == '신약'
                              ? '身弱'
                              : '中和',
                      style: context.labelTiny.copyWith(
                        color: isDark
                            ? DSColors.textTertiary
                            : DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  levelDescription,
                  style: context.labelTiny.copyWith(
                    color:
                        isDark ? DSColors.textTertiary : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageDescriptions(
    BuildContext context,
    Map<String, TwelveStage> stages,
    bool isDark,
  ) {
    final pillars = ['year', 'month', 'day', 'hour'];
    final pillarNames = {'year': '년', 'month': '월', 'day': '일', 'hour': '시'};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '운성별 의미',
          style: context.labelSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? DSColors.textSecondary : DSColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        // 그리드 형태로 2x2 배치
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 6) / 2;
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: pillars.map((key) {
                final stage = stages[key];
                if (stage == null) return const SizedBox.shrink();

                final stageData = SajuExplanations.twelveStages[stage.korean];

                return GestureDetector(
                  onTap: () {
                    showTwelveStageExplanationSheet(
                      context: context,
                      hanja: stage.hanja,
                      korean: stage.korean,
                      meaning: stage.meaning,
                      description: stageData?['description'] ?? stage.meaning,
                      fortune: stage.fortune,
                      stageColor: stage.color,
                    );
                  },
                  child: Container(
                    width: itemWidth,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? DSColors.surface
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: stage.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pillarNames[key]!,
                            style: context.labelTiny.copyWith(
                              fontWeight: FontWeight.bold,
                              color: stage.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    stage.korean,
                                    style: context.labelTiny.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? DSColors.textSecondary
                                          : DSColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stage.color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      stage.fortune,
                                      style: context.labelTiny.copyWith(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: stage.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.touch_app,
                                    size: 10,
                                    color: isDark
                                        ? DSColors.textTertiary
                                        : DSColors.textSecondary.withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                              Text(
                                stage.meaning,
                                style: context.labelTiny.copyWith(
                                  color: isDark
                                      ? DSColors.textTertiary
                                      : DSColors.textSecondary,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Map<String, TwelveStage> _calculateStages() {
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    final dayStem =
        (dayData?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ??
            '';

    if (dayStem.isEmpty) {
      return {};
    }

    final yearBranch =
        (sajuData['year']?['jiji'] as Map<String, dynamic>?)?['char']
                as String? ??
            '';
    final monthBranch =
        (sajuData['month']?['jiji'] as Map<String, dynamic>?)?['char']
                as String? ??
            '';
    final dayBranch =
        (sajuData['day']?['jiji'] as Map<String, dynamic>?)?['char']
                as String? ??
            '';
    final hourBranch =
        (sajuData['hour']?['jiji'] as Map<String, dynamic>?)?['char']
                as String? ??
            '';

    return TwelveStageCalculator.calculateAll(
      ilGan: dayStem,
      yearBranch: yearBranch,
      monthBranch: monthBranch,
      dayBranch: dayBranch,
      hourBranch: hourBranch,
    );
  }

  String _getStrengthLevel(int totalStrength) {
    if (totalStrength >= 12) {
      return '신강';
    } else if (totalStrength >= 8) {
      return '중화';
    } else {
      return '신약';
    }
  }
}
