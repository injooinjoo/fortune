import 'package:flutter/material.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'fortune_section_widget.dart';

/// 궁합 섹션 - 한국 전통 스타일
///
/// HanjiColorScheme.love (연지색)를 사용합니다.
class CompatibilitySection extends StatelessWidget {
  final Compatibility compatibility;

  const CompatibilitySection({
    super.key,
    required this.compatibility,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossSectionWidget(
      title: '궁합',
      hanja: '緣',
      colorScheme: HanjiColorScheme.love,
      child: Column(
        children: [
          _CompatibilityCard(
            type: '친구',
            emoji: '👋',
            mbti: compatibility.friend.mbti,
            description: compatibility.friend.description,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _CompatibilityCard(
            type: '연인',
            emoji: '💕',
            mbti: compatibility.lover.mbti,
            description: compatibility.lover.description,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _CompatibilityCard(
            type: '동료',
            emoji: '🤝',
            mbti: compatibility.colleague.mbti,
            description: compatibility.colleague.description,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _CompatibilityCard extends StatelessWidget {
  final String type;
  final String emoji;
  final String mbti;
  final String description;
  final bool isDark;

  const _CompatibilityCard({
    required this.type,
    required this.emoji,
    required this.mbti,
    required this.description,
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
          Row(
            children: [
              // 타입 + 이모지
              Text(
                '$emoji $type',
                style: TextStyle(
                  fontFamily: FontConfig.primary,
                  fontSize: FontConfig.labelMedium,
                  fontWeight: FontWeight.w600,
                  color: DSFortuneColors.getInk(isDark).withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              // MBTI 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      loveAccent,
                      loveAccent.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: loveAccent.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  mbti,
                  style: const TextStyle(
                    fontFamily: FontConfig.primary,
                    fontSize: FontConfig.labelSmall,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontFamily: FontConfig.primary,
              fontSize: FontConfig.labelLarge,
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
