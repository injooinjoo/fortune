import 'package:flutter/material.dart';
import '../../../core/theme/toss_theme.dart';
import '../../../core/theme/typography_unified.dart';
import '../../../core/components/app_card.dart';
import 'compact/compact_pillar_table.dart';
import 'compact/compact_element_bars.dart';
import 'compact/compact_info_rows.dart';
import 'compact/compact_relations_badges.dart';
import 'compact/compact_sinsal_summary.dart';
import 'compact/compact_daeun_timeline.dart';

/// 사주 종합 카드
///
/// 전통사주의 모든 정보를 한 장의 인포그래픽으로 압축해서 표시합니다.
class SajuSummaryCard extends StatelessWidget {
  final Map<String, dynamic> sajuData;
  final bool showHeader;

  const SajuSummaryCard({
    super.key,
    required this.sajuData,
    this.showHeader = true,
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
          if (showHeader) ...[
            _buildHeader(context, isDark),
            const SizedBox(height: TossTheme.spacingM),
          ],
          // 1. 사주 팔자 + 십성
          CompactPillarTable(sajuData: sajuData),
          const SizedBox(height: TossTheme.spacingS),

          // 2. 지장간
          CompactJijangganRow(sajuData: sajuData),
          const SizedBox(height: TossTheme.spacingXS),

          // 3. 12운성
          CompactTwelveStagesRow(sajuData: sajuData),
          const SizedBox(height: TossTheme.spacingXS),

          // 4. 납음오행
          CompactNapeumRow(sajuData: sajuData),
          const SizedBox(height: TossTheme.spacingS),

          // 5. 오행 균형 바 차트
          CompactElementBars(sajuData: sajuData),
          const SizedBox(height: TossTheme.spacingS),

          // 6. 합충형해 배지
          CompactRelationsBadges(sajuData: sajuData),
          const SizedBox(height: TossTheme.spacingXS),

          // 7. 공망/천을귀인
          CompactSpecialInfoRow(sajuData: sajuData),
          const SizedBox(height: TossTheme.spacingXS),

          // 8. 신살 요약
          CompactSinsalSummary(sajuData: sajuData),
          const SizedBox(height: TossTheme.spacingS),

          // 9. 대운 타임라인
          CompactDaeunTimeline(sajuData: sajuData),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF7C3AED), const Color(0xFF2563EB)]
                  : [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: TossTheme.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '사주 종합',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '四柱綜合 · 나의 사주 팔자',
                style: context.labelTiny.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
