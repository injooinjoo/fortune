import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/design_system.dart';
import '../../../../../data/models/secondary_profile.dart';
import '../../../../../presentation/providers/secondary_profiles_provider.dart';

/// 가족 프로필 선택 위젯 (가족운용)
///
/// 특정 가족 관계(부모님/배우자/자녀/형제자매)에 해당하는 프로필 목록을 표시하고
/// 선택하거나 새로 등록할 수 있게 함
class ChatFamilyProfileSelector extends ConsumerWidget {
  /// 가족 관계 타입 (parents/spouse/children/siblings)
  final String familyRelation;

  /// 프로필 선택 콜백
  /// - null이면 "새로 등록하기" 선택
  /// - SecondaryProfile이면 해당 프로필 선택
  final void Function(SecondaryProfile? profile) onSelect;

  /// 안내 텍스트
  final String? hintText;

  const ChatFamilyProfileSelector({
    super.key,
    required this.familyRelation,
    required this.onSelect,
    this.hintText,
  });

  String get _relationText {
    switch (familyRelation) {
      case 'parents':
        return '부모님';
      case 'spouse':
        return '배우자';
      case 'children':
        return '자녀';
      case 'siblings':
        return '형제자매';
      default:
        return '가족';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typography;
    final profilesAsync = ref.watch(secondaryProfilesProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
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
          profilesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(DSSpacing.md),
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
            error: (e, _) => _buildEmptyState(context),
            data: (allProfiles) {
              // 해당 가족 관계의 프로필만 필터링
              final familyProfiles = allProfiles
                  .where((p) =>
                      p.relationship == 'family' &&
                      p.familyRelation == familyRelation)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (familyProfiles.isEmpty) ...[
                    _buildEmptyState(context),
                  ] else ...[
                    // 등록된 프로필 목록
                    Wrap(
                      spacing: DSSpacing.xs,
                      runSpacing: DSSpacing.xs,
                      children: familyProfiles.map((profile) {
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
                  // 새로 등록하기 버튼
                  _NewProfileChip(
                    relationText: _relationText,
                    onTap: () {
                      DSHaptics.light();
                      onSelect(null);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Column(
          children: [
            Icon(
              Icons.family_restroom,
              size: 32,
              color: colors.textSecondary,
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              '등록된 $_relationText 정보가 없어요',
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.xxs),
            Text(
              '아래 버튼을 눌러 등록해주세요',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
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
                    '${profile.familyRelationText} | ${_formatBirthDate(profile.birthDate)}',
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
  final String relationText;
  final VoidCallback onTap;

  const _NewProfileChip({
    required this.relationText,
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
              Icon(
                Icons.add,
                size: 16,
                color: colors.accentSecondary,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '$relationText 등록하기',
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
