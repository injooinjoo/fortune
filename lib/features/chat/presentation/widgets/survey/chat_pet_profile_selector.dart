import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../data/models/pet_profile.dart';

/// 채팅 펫 프로필 선택 위젯 (반려동물 궁합용)
class ChatPetProfileSelector extends StatelessWidget {
  final List<PetProfile> profiles;
  final void Function(PetProfile? profile) onSelect;
  final String? hintText;

  const ChatPetProfileSelector({
    super.key,
    required this.profiles,
    required this.onSelect,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hintText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Text(
                hintText!,
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          // 등록된 펫 프로필 목록
          if (profiles.isNotEmpty) ...[
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: profiles.map((pet) {
                return _PetProfileChip(
                  pet: pet,
                  onTap: () {
                    DSHaptics.light();
                    onSelect(pet);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 새로 입력하기 버튼
          _NewPetProfileChip(
            onTap: () {
              DSHaptics.light();
              onSelect(null); // null = 새로 입력 모드
            },
          ),
        ],
      ),
    );
  }
}

class _PetProfileChip extends StatelessWidget {
  final PetProfile pet;
  final VoidCallback onTap;

  const _PetProfileChip({
    required this.pet,
    required this.onTap,
  });

  String _getSpeciesEmoji(String species) {
    final petSpecies = PetSpecies.fromString(species);
    return petSpecies.emoji;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? colors.backgroundSecondary : colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.textPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 종류 이모지
              Text(
                _getSpeciesEmoji(pet.species),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: DSSpacing.xs),
              // 이름 및 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.name,
                    style: typography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${pet.species} | ${pet.age}살 | ${pet.gender}',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewPetProfileChip extends StatelessWidget {
  final VoidCallback onTap;

  const _NewPetProfileChip({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colors.accentSecondary.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.accentSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐾', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSSpacing.xs),
              Icon(
                Icons.add,
                size: 14,
                color: colors.accentSecondary,
              ),
              const SizedBox(width: 2),
              Text(
                '반려동물 등록하기',
                style: typography.labelMedium.copyWith(
                  color: colors.accentSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
