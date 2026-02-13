import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/models/personality_dna_model.dart';

/// 기본 조건 카드 (MBTI, 혈액형, 별자리, 띠)
class BasicInfoCard extends StatelessWidget {
  final PersonalityDNA dna;

  const BasicInfoCard({super.key, required this.dna});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
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
              // MBTI 캐릭터 이미지 (AI 생성)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/fortune/mbti/characters/mbti_${dna.mbti.toLowerCase()}.webp',
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Center(
                      child:
                          Text(dna.emoji, style: const TextStyle(fontSize: 28)),
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
                      style: context.heading4
                          .copyWith(fontWeight: FontWeight.bold),
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
              Expanded(
                  child: _buildInfoItem(
                      context, isDark, '혈액형', '${dna.bloodType}형',
                      iconPath:
                          'assets/images/fortune/items/lucky/lucky_heart.webp')),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                  child: _buildInfoItem(context, isDark, '별자리', dna.zodiac,
                      iconPath:
                          'assets/images/fortune/items/lucky/lucky_star.webp')),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                  child: _buildInfoItem(
                      context, isDark, '띠', '${dna.zodiacAnimal}띠',
                      iconPath:
                          'assets/images/fortune/icons/zodiac/zodiac_${_getZodiacKey(dna.zodiacAnimal)}.webp')),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          // 설명
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: isDark ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dna.description,
              style: context.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: isDark ? 0.9 : 0.8),
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
              children: dna.traits
                  .map((trait) => _buildTraitChip(context, isDark, trait))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, bool isDark, String label, String value,
      {String? emoji, String? iconPath}) {
    final dividerColor = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: DSSpacing.md, horizontal: DSSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dividerColor.withValues(alpha: isDark ? 0.3 : 0.1),
        ),
      ),
      child: Column(
        children: [
          if (iconPath != null)
            Image.asset(
              iconPath,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Text(emoji ?? '✨', style: const TextStyle(fontSize: 24)),
            )
          else
            Text(emoji ?? '✨', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: DSSpacing.sm),
          Text(
            value,
            style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: context.labelLarge.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: isDark ? 0.8 : 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitChip(BuildContext context, bool isDark, String trait) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: isDark ? 0.2 : 0.1),
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

  String _getZodiacKey(String animal) {
    const Map<String, String> keys = {
      '쥐': 'rat',
      '소': 'ox',
      '호랑이': 'tiger',
      '토끼': 'rabbit',
      '용': 'dragon',
      '뱀': 'snake',
      '말': 'horse',
      '양': 'sheep',
      '원숭이': 'monkey',
      '닭': 'rooster',
      '개': 'dog',
      '돼지': 'pig',
    };
    return keys[animal] ?? 'dog';
  }
}
