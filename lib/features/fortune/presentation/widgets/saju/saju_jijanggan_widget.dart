import 'package:flutter/material.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/theme/saju_colors.dart';
import '../../../../../core/components/app_card.dart';
import '../../../domain/models/saju/ji_jang_gan_data.dart';

/// 지장간(支藏干) 표시 위젯
///
/// 각 지지 안에 숨어있는 천간들을 시각적으로 표시합니다.
/// - 본기(本氣): 주된 기운 (60-100%)
/// - 중기(中氣): 부차적 기운 (30%)
/// - 여기(餘氣): 잔여 기운 (10%)
class SajuJijangganWidget extends StatelessWidget {
  /// 사주 데이터 (년주, 월주, 일주, 시주)
  final Map<String, dynamic> sajuData;

  /// 제목 표시 여부
  final bool showTitle;

  /// 애니메이션 컨트롤러 (optional)
  final AnimationController? animationController;

  const SajuJijangganWidget({
    super.key,
    required this.sajuData,
    this.showTitle = true,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          _buildJijangganTable(isDark),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.layers_outlined,
          color: TossTheme.brandBlue,
          size: 20,
        ),
        const SizedBox(width: TossTheme.spacingXS),
        Row(
          children: [
            Text(
              '지장간',
              style: TossTheme.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '支藏干',
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

  Widget _buildJijangganTable(bool isDark) {
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
          // 헤더 (지지)
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
                final pillarData = sajuData[pillar['key']];
                final branchData = pillarData?['jiji'] as Map<String, dynamic>?;
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
                        const SizedBox(height: 2),
                        _buildBranchCell(branchData, isDay, isDark),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 지장간 행
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: pillars.asMap().entries.map((entry) {
              final index = entry.key;
              final pillar = entry.value;
              final pillarData = sajuData[pillar['key']];
              final branchData = pillarData?['jiji'] as Map<String, dynamic>?;
              final branch = branchData?['char'] as String? ?? '';
              final isDay = pillar['key'] == 'day';

              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(TossTheme.spacingS),
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
                  child: _buildHiddenStemsCell(branch, isDark),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCell(
    Map<String, dynamic>? branchData,
    bool isDay,
    bool isDark,
  ) {
    if (branchData == null) {
      return const Center(child: Text('-', textAlign: TextAlign.center));
    }

    final name = branchData['char'] as String? ?? '';
    final hanja = branchData['hanja'] as String? ?? '';
    final element = branchData['element'] as String? ?? '';
    final color = SajuColors.getWuxingColor(element, isDark: isDark);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 한자 크게
        Text(
          hanja,
          style: TextStyle(
            fontSize: isDay ? 22 : 18,
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
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHiddenStemsCell(String branch, bool isDark) {
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
        final bgColor =
            SajuColors.getWuxingBackgroundColor(stem.wuxing, isDark: isDark);

        return Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stem.stemHanja,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '${stem.ratio}%',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
