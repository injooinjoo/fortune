import 'package:flutter/material.dart';
import '../../../../../../core/models/personality_dna_model.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 기본 조건 카드 (MBTI, 혈액형, 별자리, 띠)
class BasicInfoCard extends StatelessWidget {
  final PersonalityDNA dna;

  const BasicInfoCard({super.key, required this.dna});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha:0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '나의 기본 조건',
                style: context.heading4.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoItem(context, 'MBTI', dna.mbti, '🧠')),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoItem(context, '혈액형', '${dna.bloodType}형', '🩸')),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoItem(context, '별자리', dna.zodiac, '⭐')),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoItem(context, '띠', '${dna.zodiacAnimal}띠', _getZodiacEmoji(dna.zodiacAnimal))),
            ],
          ),
          const SizedBox(height: 16),
          // 설명
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dna.description,
              style: context.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
              ),
            ),
          ),
          // 특성 태그
          if (dna.traits.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dna.traits.map((trait) => _buildTraitChip(context, trait)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha:0.1),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: context.labelLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitChip(BuildContext context, String trait) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
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
