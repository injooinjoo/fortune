import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../data/models/secondary_profile.dart';

/// 채팅 프로필 선택 위젯 (궁합용)
class ChatProfileSelector extends StatelessWidget {
  final List<SecondaryProfile> profiles;
  final void Function(SecondaryProfile? profile) onSelect;
  final String? hintText;

  const ChatProfileSelector({
    super.key,
    required this.profiles,
    required this.onSelect,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      // 투명 배경 - 하단 입력 영역과 일관성 유지
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
          // 등록된 프로필 목록
          if (profiles.isNotEmpty) ...[
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: profiles.map((profile) {
                return _ProfileChip(
                  profile: profile,
                  onTap: () {
                    DSHaptics.light();
                    onSelect(profile);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: DSSpacing.sm),
          ],
          // 새로 입력하기 버튼
          _NewProfileChip(
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

class _ProfileChip extends StatelessWidget {
  final SecondaryProfile profile;
  final VoidCallback onTap;

  const _ProfileChip({
    required this.profile,
    required this.onTap,
  });

  String _formatBirthDate(String birthDate) {
    try {
      final date = DateTime.parse(birthDate);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return birthDate;
    }
  }

  IconData _getAvatarIcon() {
    switch (profile.avatarIndex) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.face;
      case 2:
        return Icons.face_2;
      case 3:
        return Icons.face_3;
      case 4:
        return Icons.face_4;
      case 5:
        return Icons.face_5;
      case 6:
        return Icons.face_6;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

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
              // 아바타
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.accentSecondary.withValues(alpha: 0.2),
                ),
                child: Icon(
                  _getAvatarIcon(),
                  size: 16,
                  color: colors.accentSecondary,
                ),
              ),
              const SizedBox(width: DSSpacing.xs),
              // 이름 및 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.name,
                    style: typography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${profile.relationshipText} | ${_formatBirthDate(profile.birthDate)}',
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

class _NewProfileChip extends StatelessWidget {
  final VoidCallback onTap;

  const _NewProfileChip({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

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
              Icon(
                Icons.add,
                size: 16,
                color: colors.accentSecondary,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '새로 입력하기',
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
