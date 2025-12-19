import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';
import 'toss_section_widget.dart';

/// 업무 스타일 섹션 - 한국 전통 스타일
///
/// HanjiColorScheme.fortune (자주+금)을 사용합니다.
class WorkStyleSection extends StatelessWidget {
  final WorkStyle workStyle;

  const WorkStyleSection({
    super.key,
    required this.workStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossSectionWidget(
      title: '업무 스타일',
      hanja: '業',
      colorScheme: HanjiColorScheme.fortune,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workStyle.title,
            style: TextStyle(
              fontFamily: 'GowunBatang',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DSFortuneColors.getGold(isDark),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          _WorkDetailCard(
            title: '상사가 된다면',
            content: workStyle.asBoss,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _WorkDetailCard(
            title: '회식에서',
            content: workStyle.atCompanyDinner,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _WorkDetailCard(
            title: '업무 습관',
            content: workStyle.workHabit,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _WorkDetailCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _WorkDetailCard({
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSFortuneColors.getGold(isDark).withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DSFortuneColors.getGold(isDark).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'GowunBatang',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DSFortuneColors.getGold(isDark),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: DSFortuneColors.getInk(isDark),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
