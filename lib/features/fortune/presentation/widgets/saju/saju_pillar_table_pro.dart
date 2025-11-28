import 'package:flutter/material.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/saju_colors.dart';
import '../../../../../core/components/app_card.dart';
import '../../../domain/models/saju/ji_jang_gan_data.dart';
import '../../../domain/models/saju/twelve_stage_calculator.dart';
import '../../../domain/models/saju/gong_mang_calculator.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            _buildTitle(isDark),
            const SizedBox(height: TossTheme.spacingL),
          ],
          _buildProTable(isDark),
          const SizedBox(height: TossTheme.spacingM),
          _buildDayMasterInfo(isDark),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.grid_view_rounded,
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
                  '사주명식',
                  style: TossTheme.heading2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '四柱命式',
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
              '당신의 타고난 운명을 담은 네 기둥',
              style: TossTheme.caption.copyWith(
                color: isDark ? TossTheme.textGray400 : TossTheme.textGray600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProTable(bool isDark) {
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
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(
          color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
        ),
      ),
      child: Column(
        children: [
          // 헤더 행 (년주, 월주, 일주, 시주)
          _buildHeaderRow(pillars, isDark),
          // 천간 행
          _buildStemRow(pillars, isDark),
          // 지지 행
          _buildBranchRow(pillars, gongMangInfo, isDark),
          // 지장간 행 (옵션)
          if (showJijanggan) _buildJijangganRow(pillars, isDark),
          // 12운성 행 (옵션)
          if (showTwelveStages && stages != null)
            _buildTwelveStagesRow(pillars, stages, isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(List<Map<String, String>> pillars, bool isDark) {
    return Container(
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
                vertical: TossTheme.spacingS,
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
                    ? TossTheme.brandBlue.withValues(alpha: 0.15)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    pillar['hanja']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDay
                          ? TossTheme.brandBlue
                          : (isDark
                              ? TossDesignSystem.grayDark600
                              : TossDesignSystem.gray700),
                    ),
                  ),
                  Text(
                    pillar['title']!,
                    style: TossTheme.caption.copyWith(
                      color: isDay
                          ? TossTheme.brandBlue
                          : (isDark
                              ? TossTheme.textGray400
                              : TossTheme.textGray600),
                      fontSize: 10,
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

  Widget _buildStemRow(List<Map<String, String>> pillars, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
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
                    ? TossTheme.brandBlue.withValues(alpha: 0.08)
                    : null,
              ),
              child: _buildStemCell(stemData, isDay, isDark),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBranchRow(
    List<Map<String, String>> pillars,
    GongMangInfo? gongMangInfo,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
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
                    ? TossTheme.brandBlue.withValues(alpha: 0.08)
                    : null,
              ),
              child: _buildBranchCell(branchData, isDay, isGongMang, isDark),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJijangganRow(List<Map<String, String>> pillars, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? TossDesignSystem.borderDark : TossTheme.borderPrimary,
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
                  vertical: TossTheme.spacingS,
                  horizontal: TossTheme.spacingXS,
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
                      ? TossTheme.brandBlue.withValues(alpha: 0.05)
                      : (isDark
                          ? Colors.black.withValues(alpha: 0.1)
                          : Colors.grey.shade50),
                ),
                child: _buildJijangganCell(branch, isDark),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTwelveStagesRow(
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
          bottomLeft: Radius.circular(TossTheme.radiusM),
          bottomRight: Radius.circular(TossTheme.radiusM),
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
                vertical: TossTheme.spacingS,
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
                color: isDark
                    ? TossDesignSystem.cardBackgroundDark
                    : TossTheme.backgroundSecondary,
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
              child: _buildTwelveStageCell(stage, isDark),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStemCell(
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
          style: TextStyle(
            fontSize: isDay ? 36 : 32,
            fontWeight: FontWeight.bold,
            color: isDay ? TossTheme.brandBlue : color,
          ),
          textAlign: TextAlign.center,
        ),
        // 한글 작게
        Text(
          name,
          style: TossTheme.caption.copyWith(
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray700,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // 오행 태그
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            element,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCell(
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
              style: TextStyle(
                fontSize: isDay ? 36 : 32,
                fontWeight: FontWeight.bold,
                color: isDay ? TossTheme.brandBlue : color,
              ),
              textAlign: TextAlign.center,
            ),
            // 한글 작게
            Text(
              name,
              style: TossTheme.caption.copyWith(
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray700,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            // 띠
            Text(
              animal,
              style: TossTheme.caption.copyWith(
                color: isDark ? TossTheme.textGray400 : TossTheme.textGray600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // 오행 태그
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                element,
                style: TextStyle(
                  fontSize: 10,
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
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: SajuColors.emptinessLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '空',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJijangganCell(String branch, bool isDark) {
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${stem.ratio}%',
                style: TextStyle(
                  fontSize: 9,
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

  Widget _buildTwelveStageCell(TwelveStage? stage, bool isDark) {
    if (stage == null) {
      return const Center(child: Text('-'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          stage.hanja,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: stage.color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          stage.korean,
          style: TossTheme.caption.copyWith(
            color: isDark ? TossTheme.textGray400 : TossTheme.textGray600,
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDayMasterInfo(bool isDark) {
    final dayData = sajuData['day'];
    if (dayData == null) return const SizedBox.shrink();

    final stemData = dayData['cheongan'] as Map<String, dynamic>?;
    if (stemData == null) return const SizedBox.shrink();

    final stemName = stemData['char'] as String? ?? '';
    final stemHanja = stemData['hanja'] as String? ?? '';
    final element = stemData['element'] as String? ?? '';
    final color = SajuColors.getStemColor(stemName, isDark: isDark);

    return Container(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stemHanja,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
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
                      '일간',
                      style: TossTheme.caption.copyWith(
                        color: isDark
                            ? TossTheme.textGray400
                            : TossTheme.textGray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '日干',
                      style: TossTheme.caption.copyWith(
                        color: isDark
                            ? TossTheme.textGray500
                            : TossTheme.textGray500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '$stemName($stemHanja)',
                      style: TossTheme.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$element 오행',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '당신의 본질을 나타내는 핵심 요소입니다',
                  style: TossTheme.caption.copyWith(
                    color:
                        isDark ? TossTheme.textGray400 : TossTheme.textGray600,
                    fontSize: 11,
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
}
