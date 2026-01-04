import 'package:flutter/material.dart';
import '../../../../../../core/design_system/tokens/ds_spacing.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 기본 조건 카드 (MBTI, 혈액형, 별자리, 띠)
class BasicInfoCard extends StatelessWidget {
  final PersonalityDNA dna;

  const BasicInfoCard({super.key, required this.dna});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dividerColor.withValues(alpha: isDark ? 0.3 : 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 + MBTI 이미지
          Row(
            children: [
              // MBTI 캐릭터 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/mbti/${dna.mbti.toLowerCase()}.webp',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나의 기본 조건',
                      style: context.heading4.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dna.mbti,
                      style: context.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Row(
            children: [
              Expanded(child: _buildInfoItem(context, isDark, '혈액형', '${dna.bloodType}형', '🩸')),
              const SizedBox(width: DSSpacing.sm),
              Expanded(child: _buildInfoItem(context, isDark, '별자리', dna.zodiac, '⭐')),
              const SizedBox(width: DSSpacing.sm),
              Expanded(child: _buildInfoItem(context, isDark, '띠', '${dna.zodiacAnimal}띠', _getZodiacEmoji(dna.zodiacAnimal))),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 설명
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dna.description,
              style: context.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isDark ? 0.9 : 0.8),
                height: 1.5,
              ),
            ),
          ),
          // 특성 태그
          if (dna.traits.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              children: dna.traits.map((trait) => _buildTraitChip(context, isDark, trait)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, bool isDark, String label, String value, String emoji) {
    final dividerColor = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm, horizontal: DSSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dividerColor.withValues(alpha: isDark ? 0.3 : 0.1),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: DSSpacing.xs),
          Text(
            value,
            style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: context.labelLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: isDark ? 0.8 : 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitChip(BuildContext context, bool isDark, String trait) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        trait,
        style: context.labelLarge.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getZodiacEmoji(String animal) {
    const Map<String, String> zodiacEmojis = {
      '쥐': '🐭',
      '소': '🐂',
      '호랑이': '🐅',
      '토끼': '🐰',
      '용': '🐉',
      '뱀': '🐍',
      '말': '🐴',
      '양': '🐑',
      '원숭이': '🐒',
      '닭': '🐓',
      '개': '🐕',
      '돼지': '🐷',
    };
    return zodiacEmojis[animal] ?? '🐾';
  }
}
