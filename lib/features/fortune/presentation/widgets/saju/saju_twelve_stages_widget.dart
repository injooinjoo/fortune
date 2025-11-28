import 'package:flutter/material.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/components/app_card.dart';
import '../../../domain/models/saju/twelve_stage_calculator.dart';

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
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            _buildTitle(isDark),
            const SizedBox(height: TossTheme.spacingL),
          ],
          // 12운성 테이블
          _buildStagesTable(stages, isDark),
          const SizedBox(height: TossTheme.spacingL),
          // 신강/신약 판단
          _buildStrengthIndicator(totalStrength, strengthLevel, isDark),
          const SizedBox(height: TossTheme.spacingM),
          // 각 운성 설명
          _buildStageDescriptions(stages, isDark),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.loop_outlined,
          color: TossTheme.brandBlue,
          size: 24,
        ),
        const SizedBox(width: TossTheme.spacingS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '12운성',
                  style: TossTheme.heading2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '十二運星',
                  style: TossTheme.body2.copyWith(
                    color: isDark
                        ? TossTheme.textGray400
                        : TossTheme.textGray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '일간의 생명력 주기를 나타내는 12단계',
              style: TossTheme.caption.copyWith(
                color: isDark ? TossTheme.textGray400 : TossTheme.textGray600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStagesTable(
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
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
        ),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? TossDesignSystem.cardBackgroundDark
                  : TossTheme.backgroundSecondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(TossTheme.radiusM),
                topRight: Radius.circular(TossTheme.radiusM),
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
                      vertical: TossTheme.spacingM,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: index < pillars.length - 1
                            ? BorderSide(
                                color: isDark
                                    ? TossDesignSystem.borderDark
                                    : TossTheme.borderPrimary,
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                      color: isDay
                          ? TossTheme.brandBlue.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          pillar['hanja']!,
                          style: TossTheme.caption.copyWith(
                            color: isDark
                                ? TossTheme.textGray400
                                : TossTheme.textGray600,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          pillar['title']!,
                          style: TossTheme.body2.copyWith(
                            fontWeight: isDay ? FontWeight.bold : FontWeight.w600,
                            color: isDay ? TossTheme.brandBlue : null,
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
                  padding: const EdgeInsets.all(TossTheme.spacingM),
                  decoration: BoxDecoration(
                    border: Border(
                      right: index < pillars.length - 1
                          ? BorderSide(
                              color: isDark
                                  ? TossDesignSystem.borderDark
                                  : TossTheme.borderPrimary,
                              width: 1,
                            )
                          : BorderSide.none,
                    ),
                    color: isDay
                        ? TossTheme.brandBlue.withValues(alpha: 0.05)
                        : null,
                    borderRadius: index == 0
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(TossTheme.radiusM),
                          )
                        : index == pillars.length - 1
                            ? const BorderRadius.only(
                                bottomRight: Radius.circular(TossTheme.radiusM),
                              )
                            : null,
                  ),
                  child: _buildStageCell(stage, isDay, isDark),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCell(TwelveStage? stage, bool isDay, bool isDark) {
    if (stage == null) {
      return const Center(child: Text('-'));
    }

    final color = stage.color;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 한자 크게
        Text(
          stage.hanja,
          style: TextStyle(
            fontSize: isDay ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: isDay ? TossTheme.brandBlue : color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        // 한글 작게
        Text(
          stage.korean,
          style: TossTheme.caption.copyWith(
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray700,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // 강도 표시 (세련된 도트 스타일)
        _buildStrengthBadge(stage.strength, color),
      ],
    );
  }

  Widget _buildStrengthBadge(int strength, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(left: index > 0 ? 2 : 0),
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
      padding: const EdgeInsets.all(TossTheme.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColor.withValues(alpha: 0.15),
            levelColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
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
                  size: 20,
                ),
                Text(
                  '$totalStrength',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: TossTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      strengthLevel,
                      style: TossTheme.body1.copyWith(
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
                      style: TossTheme.caption.copyWith(
                        color: isDark
                            ? TossTheme.textGray400
                            : TossTheme.textGray600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  levelDescription,
                  style: TossTheme.caption.copyWith(
                    color:
                        isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray700,
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
    Map<String, TwelveStage> stages,
    bool isDark,
  ) {
    final pillars = ['year', 'month', 'day', 'hour'];
    final pillarNames = {'year': '년주', 'month': '월주', 'day': '일주', 'hour': '시주'};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운성별 의미',
          style: TossTheme.body2.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray900,
          ),
        ),
        const SizedBox(height: TossTheme.spacingS),
        ...pillars.map((key) {
          final stage = stages[key];
          if (stage == null) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: TossTheme.spacingS),
            padding: const EdgeInsets.all(TossTheme.spacingS),
            decoration: BoxDecoration(
              color: isDark
                  ? TossDesignSystem.cardBackgroundDark
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(TossTheme.radiusS),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TossTheme.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: stage.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pillarNames[key]!,
                    style: TossTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stage.color,
                      fontSize: 10,
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
                            '${stage.korean}(${stage.hanja})',
                            style: TossTheme.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? TossDesignSystem.grayDark700
                                  : TossDesignSystem.gray900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: stage.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stage.fortune,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: stage.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage.meaning,
                        style: TossTheme.caption.copyWith(
                          color: isDark
                              ? TossTheme.textGray400
                              : TossTheme.textGray600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
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
