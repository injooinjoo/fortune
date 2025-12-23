import 'package:flutter/material.dart';
import '../../../../core/theme/obangseok_colors.dart';
import 'fortune_entry_card.dart';

/// 관상/전통운세 상단 진입 섹션
///
/// 운세 목록 페이지 상단에 고정 배치되어
/// 관상과 전통운세로 빠르게 진입할 수 있는 카드 영역
class FortuneEntrySection extends StatelessWidget {
  final bool isDark;

  const FortuneEntrySection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: FortuneEntryCard(
              title: '관상',
              subtitle: '얼굴로 보는 운세',
              imagePath: 'assets/images/fortune_entry/face_reading.png',
              routePath: '/face-reading',
              isDark: isDark,
              accentColor: ObangseokColors.cheong,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FortuneEntryCard(
              title: '전통운세',
              subtitle: '사주명리 기반',
              imagePath: 'assets/images/fortune_entry/traditional.png',
              routePath: '/traditional',
              isDark: isDark,
              accentColor: ObangseokColors.hwang,
            ),
          ),
        ],
      ),
    );
  }
}
