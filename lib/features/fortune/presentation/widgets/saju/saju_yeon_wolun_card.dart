import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/saju/daeun_calculator.dart';

/// 연운(年運) / 월운(月運) 카드 위젯
///
/// 올해의 연운 간지와 이달의 월운 간지를 미니 필러로 표시합니다.
/// DaeunCalculator를 사용하여 현재 연운/월운을 계산합니다.
class SajuYeonWolunCard extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const SajuYeonWolunCard({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final now = DateTime.now();
    final yeonun = DaeunCalculator.calculateYeonun(now.year);
    final wolun = DaeunCalculator.calculateWolun(now.year, now.month);

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? context.colors.backgroundSecondary : Colors.white,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.borderDark,
        ),
      ),
      child: Row(
        children: [
          // 연운
          Expanded(
            child: _buildPillarSection(
              context: context,
              title: '연운 · ${now.year}년',
              titleHanja: '年運',
              info: yeonun,
              isDark: isDark,
            ),
          ),
          // 구분선
          Container(
            width: 1,
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
            color: isDark
                ? DSColors.border
                : DSColors.borderDark.withValues(alpha: 0.5),
          ),
          // 월운
          Expanded(
            child: _buildPillarSection(
              context: context,
              title: '월운 · ${now.month}월',
              titleHanja: '月運',
              info: wolun,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarSection({
    required BuildContext context,
    required String title,
    required String titleHanja,
    required YeonWolunInfo info,
    required bool isDark,
  }) {
    final stemColor = SajuColors.getStemColor(info.stem, isDark: isDark);
    final branchColor = SajuColors.getBranchColor(info.branch, isDark: isDark);

    return Column(
      children: [
        // 제목
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: context.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              titleHanja,
              style: context.labelTiny.copyWith(
                color: context.colors.textTertiary,
                fontSize: 9,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),

        // 미니 필러
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? context.colors.surface.withValues(alpha: 0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(DSRadius.sm),
            border: Border.all(
              color: isDark ? DSColors.border : DSColors.borderDark,
            ),
          ),
          child: Column(
            children: [
              // 천간
              Text(
                info.stemHanja,
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: stemColor,
                ),
              ),
              Container(
                width: 32,
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: isDark
                    ? DSColors.border
                    : DSColors.borderDark.withValues(alpha: 0.3),
              ),
              // 지지
              Text(
                info.branchHanja,
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: branchColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // 한글
        Text(
          '${info.stem}${info.branch}',
          style: context.labelSmall.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),

        // 오행
        Text(
          info.element,
          style: context.labelTiny.copyWith(
            color: context.colors.textTertiary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
