import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';
import 'toss_section_widget.dart';

/// 연애 스타일 섹션 - 한국 전통 스타일
///
/// HanjiColorScheme.love (연지색)를 사용합니다.
class LoveStyleSection extends StatelessWidget {
  final LoveStyle loveStyle;

  const LoveStyleSection({
    super.key,
    required this.loveStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loveAccent = isDark
        ? const Color(0xFFE8A4B8)
        : const Color(0xFFD4526E);

    return TossSectionWidget(
      title: '연애 스타일',
      hanja: '戀',
      colorScheme: HanjiColorScheme.love,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loveStyle.title,
            style: TextStyle(
              fontFamily: 'GowunBatang',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: loveAccent,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loveStyle.description,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: DSFortuneColors.getInk(isDark),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _LoveDetailCard(
            title: '연애할 때',
            content: loveStyle.whenDating,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _LoveDetailCard(
            title: '이별 후',
            content: loveStyle.afterBreakup,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _LoveDetailCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _LoveDetailCard({
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final loveAccent = isDark
        ? const Color(0xFFE8A4B8)
        : const Color(0xFFD4526E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: loveAccent.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: loveAccent.withValues(alpha: 0.2),
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
              color: loveAccent,
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
