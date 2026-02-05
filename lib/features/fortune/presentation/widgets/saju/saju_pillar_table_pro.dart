import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/design_system/tokens/ds_saju_colors.dart';
import '../../../../../core/components/app_card.dart';
import '../../../../../data/saju_explanations.dart';
import '../../../domain/models/saju/ji_jang_gan_data.dart';
import '../../../domain/models/saju/twelve_stage_calculator.dart';
import '../../../domain/models/saju/gong_mang_calculator.dart';
import 'saju_concept_card.dart';

/// 전문가용 사주 4주 테이블
///
/// 한자를 크게 표시하고 지장간, 12운성, 공망까지 표시하는 전문적인 사주 테이블입니다.
/// - 천간: 한자 크게 + 한글 작게 + 오행
/// - 지지: 한자 크게 + 한글 작게 + 띠 + 오행
/// - 지장간: 본기/중기/여기
/// - 12운성: 각 지지별 운성
/// - 공망: 공망 여부 표시
class SajuPillarTablePro extends StatelessWidget {
  /// 사주 데이터
  final Map<String, dynamic> sajuData;

  /// 제목 표시 여부
  final bool showTitle;

  /// 지장간 표시 여부
  final bool showJijanggan;

  /// 12운성 표시 여부
  final bool showTwelveStages;

  /// 공망 표시 여부
  final bool showGongMang;

  /// 애니메이션 컨트롤러 (optional)
  final AnimationController? animationController;

  const SajuPillarTablePro({
    super.key,
    required this.sajuData,
    this.showTitle = true,
    this.showJijanggan = true,
    this.showTwelveStages = true,
    this.showGongMang = true,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

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
          _buildProTable(context, isDark),
          const SizedBox(height: DSSpacing.sm),
          _buildDayMasterInfo(context, isDark),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    return Row(
      children: [
        const Icon(
          Icons.grid_view_rounded,
          color: DSColors.accent,
          size: 20,
        ),
        const SizedBox(width: DSSpacing.xs),
        Row(
          children: [
            Text(
              '사주명식',
              style: context.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '四柱命式',
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

  Widget _buildProTable(BuildContext context, bool isDark) {
    final pillars = [
      {'title': '시주', 'hanja': '時柱', 'key': 'hour'},
      {'title': '일주', 'hanja': '日柱', 'key': 'day'},
      {'title': '월주', 'hanja': '月柱', 'key': 'month'},
      {'title': '년주', 'hanja': '年柱', 'key': 'year'},
    ];

    // 공망 계산
    GongMangInfo? gongMangInfo;
    if (showGongMang) {
      gongMangInfo = _calculateGongMang();
    }

    // 12운성 계산
    Map<String, TwelveStage>? stages;
    if (showTwelveStages) {
      stages = _calculateStages();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: DSColors.border,
        ),
      ),
      child: Column(
        children: [
          // 헤더 행 (년주, 월주, 일주, 시주)
          _buildHeaderRow(context, pillars, isDark),
          // 천간 행
          _buildStemRow(context, pillars, isDark),
          // 지지 행
          _buildBranchRow(context, pillars, gongMangInfo, isDark),
          // 지장간 행 (옵션)
          if (showJijanggan) _buildJijangganRow(context, pillars, isDark),
          // 12운성 행 (옵션)
          if (showTwelveStages && stages != null)
            _buildTwelveStagesRow(context, pillars, stages, isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, List<Map<String, String>> pillars, bool isDark) {
    return Container(
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
                vertical: DSSpacing.sm,
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
                    ? DSColors.accent.withValues(alpha: 0.15)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    pillar['hanja']!,
                    style: context.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDay
                          ? DSColors.accent
                          : (isDark
                              ? DSColors.textTertiary
                              : DSColors.textSecondary),
                    ),
                  ),
                  Text(
                    pillar['title']!,
                    style: context.labelTiny.copyWith(
                      color: isDay
                          ? DSColors.accent
                          : (isDark
                              ? DSColors.textTertiary
                              : DSColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStemRow(
      BuildContext context, List<Map<String, String>> pillars, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? DSColors.border : DSColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: pillars.asMap().entries.map((entry) {
          final index = entry.key;
          final pillar = entry.value;
          final pillarData = sajuData[pillar['key']];
          final stemData = pillarData?['cheongan'] as Map<String, dynamic>?;
          final isDay = pillar['key'] == 'day';

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: DSSpacing.sm,
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
                    ? DSColors.accent.withValues(alpha: 0.08)
                    : null,
              ),
              child: GestureDetector(
                onTap: () => _showStemExplanation(context, stemData),
                behavior: HitTestBehavior.opaque,
                child: _buildStemCell(context, stemData, isDay, isDark),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBranchRow(
    BuildContext context,
    List<Map<String, String>> pillars,
    GongMangInfo? gongMangInfo,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? DSColors.border : DSColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: pillars.asMap().entries.map((entry) {
          final index = entry.key;
          final pillar = entry.value;
          final pillarData = sajuData[pillar['key']];
          final branchData = pillarData?['jiji'] as Map<String, dynamic>?;
          final isDay = pillar['key'] == 'day';

          // 공망 확인
          bool isGongMang = false;
          if (gongMangInfo != null && pillar['key'] != 'day') {
            final positionName = _getPositionName(pillar['key']!);
            isGongMang = gongMangInfo.foundInSaju.containsKey(positionName);
          }

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: DSSpacing.sm,
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
                    ? DSColors.accent.withValues(alpha: 0.08)
                    : null,
              ),
              child: GestureDetector(
                onTap: () => _showBranchExplanation(context, branchData),
                behavior: HitTestBehavior.opaque,
                child: _buildBranchCell(context, branchData, isDay, isGongMang, isDark),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJijangganRow(BuildContext context, List<Map<String, String>> pillars, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? DSColors.border : DSColors.border,
            width: 1,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: pillars.asMap().entries.map((entry) {
            final index = entry.key;
            final pillar = entry.value;
            final pillarData = sajuData[pillar['key']];
            final branchData = pillarData?['jiji'] as Map<String, dynamic>?;
            final branch = branchData?['char'] as String? ?? '';
            final isDay = pillar['key'] == 'day';

            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: DSSpacing.sm,
                  horizontal: DSSpacing.xs,
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
                      ? DSColors.accent.withValues(alpha: 0.05)
                      : context.colors.surfaceSecondary,
                ),
                child: _buildJijangganCell(context, branch, isDark),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTwelveStagesRow(
    BuildContext context,
    List<Map<String, String>> pillars,
    Map<String, TwelveStage> stages,
    bool isDark,
  ) {
    // 키 매핑 (전통 순서)
    final keyMap = {
      'hour': 'hour',
      'day': 'day',
      'month': 'month',
      'year': 'year',
    };

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(DSRadius.md),
          bottomRight: Radius.circular(DSRadius.md),
        ),
      ),
      child: Row(
        children: pillars.asMap().entries.map((entry) {
          final index = entry.key;
          final pillar = entry.value;
          final stage = stages[keyMap[pillar['key']]];

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: DSSpacing.sm,
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
                color: isDark
                    ? DSColors.surface
                    : DSColors.backgroundSecondary,
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
              child: _buildTwelveStageCell(context, stage, isDark),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStemCell(
    BuildContext context,
    Map<String, dynamic>? stemData,
    bool isDay,
    bool isDark,
  ) {
    if (stemData == null) {
      return const Center(child: Text('-'));
    }

    final name = stemData['char'] as String? ?? '';
    final hanja = stemData['hanja'] as String? ?? '';
    final element = stemData['element'] as String? ?? '';
    final color = SajuColors.getStemColor(name, isDark: isDark);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 한자 크게
        Text(
          hanja,
          style: context.heading2.copyWith(
            fontSize: isDay ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: isDay ? DSColors.accent : color,
          ),
          textAlign: TextAlign.center,
        ),
        // 한글 작게
        Text(
          name,
          style: context.labelTiny.copyWith(
            color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        // 오행 태그
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            element,
            style: context.labelTiny.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCell(
    BuildContext context,
    Map<String, dynamic>? branchData,
    bool isDay,
    bool isGongMang,
    bool isDark,
  ) {
    if (branchData == null) {
      return const Center(child: Text('-'));
    }

    final name = branchData['char'] as String? ?? '';
    final hanja = branchData['hanja'] as String? ?? '';
    final animal = branchData['animal'] as String? ?? '';
    final element = branchData['element'] as String? ?? '';
    final color = SajuColors.getBranchColor(name, isDark: isDark);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 한자 크게
            Text(
              hanja,
              style: context.heading2.copyWith(
                fontSize: isDay ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: isDay ? DSColors.accent : color,
              ),
              textAlign: TextAlign.center,
            ),
            // 한글 + 띠 한줄로
            Text(
              '$name $animal',
              style: context.labelTiny.copyWith(
                color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // 오행 태그
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                element,
                style: context.labelTiny.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        // 공망 표시
        if (isGongMang)
          Positioned(
            top: 0,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: SajuColors.emptinessLight,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '空',
                style: context.labelTiny.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJijangganCell(BuildContext context, String branch, bool isDark) {
    if (branch.isEmpty) {
      return const Center(child: Text('-'));
    }

    final hiddenStems = JiJangGanData.getHiddenStems(branch);
    if (hiddenStems.isEmpty) {
      return const Center(child: Text('-'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: hiddenStems.map((stem) {
        final color = SajuColors.getWuxingColor(stem.wuxing, isDark: isDark);
        final bgColor = SajuColors.getWuxingBackgroundColor(stem.wuxing, isDark: isDark);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stem.stemHanja,
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${stem.ratio}%',
                style: context.labelTiny.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTwelveStageCell(BuildContext context, TwelveStage? stage, bool isDark) {
    if (stage == null) {
      return const Center(child: Text('-'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          stage.hanja,
          style: context.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: stage.color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          stage.korean,
          style: context.labelTiny.copyWith(
            color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDayMasterInfo(BuildContext context, bool isDark) {
    final dayData = sajuData['day'];
    if (dayData == null) return const SizedBox.shrink();

    final stemData = dayData['cheongan'] as Map<String, dynamic>?;
    if (stemData == null) return const SizedBox.shrink();

    final stemName = stemData['char'] as String? ?? '';
    final stemHanja = stemData['hanja'] as String? ?? '';
    final element = stemData['element'] as String? ?? '';
    final color = SajuColors.getStemColor(stemName, isDark: isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stemHanja,
                style: context.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Row(
              children: [
                Text(
                  '일간 日干',
                  style: context.labelTiny.copyWith(
                    color: isDark
                        ? DSColors.textTertiary
                        : DSColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$stemName($stemHanja)',
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$element 오행',
                    style: context.labelTiny.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  GongMangInfo? _calculateGongMang() {
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    final dayStem =
        (dayData?['cheongan'] as Map<String, dynamic>?)?['char'] as String? ??
            '';
    final dayBranch =
        (dayData?['jiji'] as Map<String, dynamic>?)?['char'] as String? ?? '';

    if (dayStem.isEmpty || dayBranch.isEmpty) {
      return null;
    }

    final yearBranch =
        (sajuData['year']?['jiji'] as Map<String, dynamic>?)?['char']
                as String? ??
            '';
    final monthBranch =
        (sajuData['month']?['jiji'] as Map<String, dynamic>?)?['char']
                as String? ??
            '';
    final hourBranch =
        (sajuData['hour']?['jiji'] as Map<String, dynamic>?)?['char']
                as String? ??
            '';

    return GongMangCalculator.analyzeGongMang(
      dayStem: dayStem,
      dayBranch: dayBranch,
      yearBranch: yearBranch,
      monthBranch: monthBranch,
      hourBranch: hourBranch,
    );
  }

  String _getPositionName(String key) {
    switch (key) {
      case 'year':
        return '년주';
      case 'month':
        return '월주';
      case 'hour':
        return '시주';
      default:
        return '';
    }
  }

  /// 천간 터치 시 해설 바텀시트 표시
  void _showStemExplanation(
      BuildContext context, Map<String, dynamic>? stemData) {
    if (stemData == null) return;

    final hanja = stemData['hanja'] as String?;
    if (hanja == null) return;

    final explanation = SajuExplanations.heavenlyStem[hanja];
    if (explanation == null) return;

    showCharacterExplanationSheet(
      context: context,
      hanja: hanja,
      korean: explanation['korean']!,
      element: explanation['element']!,
      elementKorean: explanation['elementKorean']!,
      meaning: explanation['meaning']!,
      description: explanation['description']!,
      // 보강된 콘텐츠
      realLife: explanation['realLife'],
      love: explanation['love'],
      career: explanation['career'],
      health: explanation['health'],
      tips: explanation['tips'],
      compatibility: explanation['compatibility'],
    );
  }

  /// 지지 터치 시 해설 바텀시트 표시
  void _showBranchExplanation(
      BuildContext context, Map<String, dynamic>? branchData) {
    if (branchData == null) return;

    final hanja = branchData['hanja'] as String?;
    if (hanja == null) return;

    final explanation = SajuExplanations.earthlyBranch[hanja];
    if (explanation == null) return;

    showCharacterExplanationSheet(
      context: context,
      hanja: hanja,
      korean: explanation['korean']!,
      element: explanation['element']!,
      elementKorean: explanation['elementKorean']!,
      meaning: explanation['meaning']!,
      description: explanation['description']!,
      animal: explanation['animal'],
      time: explanation['time'],
      // 보강된 콘텐츠
      realLife: explanation['realLife'],
      love: explanation['love'],
      career: explanation['career'],
      health: explanation['health'],
      tips: explanation['tips'],
      compatibility: explanation['compatibility'],
    );
  }
}
