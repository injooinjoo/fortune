import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'fortune_section_widget.dart';

/// 닮은 유명인 섹션 - 한국 전통 스타일
///
/// HanjiColorScheme.fortune (자주+금)을 사용합니다.
class CelebritySection extends StatelessWidget {
  final Celebrity celebrity;

  const CelebritySection({
    super.key,
    required this.celebrity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossSectionWidget(
      title: '닮은 유명인',
      hanja: '星',
      colorScheme: HanjiColorScheme.fortune,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DSFortuneColors.getGold(isDark).withValues(alpha: isDark ? 0.15 : 0.1),
              DSFortuneColors.getGold(isDark).withValues(alpha: isDark ? 0.08 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DSFortuneColors.getGold(isDark).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 스타 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DSFortuneColors.getGold(isDark).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: DSFortuneColors.getGold(isDark).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text('⭐', style: TextStyle(fontSize: FontConfig.heading3)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    celebrity.name,
                    style: TextStyle(
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.heading4,
                      fontWeight: FontWeight.w700,
                      color: DSFortuneColors.getGold(isDark),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    celebrity.reason,
                    style: TextStyle(
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.labelMedium,
                      fontWeight: FontWeight.w400,
                      color: DSFortuneColors.getInk(isDark).withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
