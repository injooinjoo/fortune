import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../presentation/providers/active_profile_provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/secondary_profiles_provider.dart';
import 'add_profile_sheet.dart';

/// 프로필 목록 바텀시트
///
/// 등록된 모든 프로필을 목록으로 보여주고 선택 가능
class ProfileListSheet extends ConsumerWidget {
  const ProfileListSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final activeState = ref.watch(activeProfileProvider);
    final primaryProfileAsync = ref.watch(userProfileProvider);
    final secondaryProfiles = ref.watch(secondaryProfilesProvider);
    final canAdd = ref.watch(canAddSecondaryProfileProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('프로필 선택', style: context.typography.headingLarge),
                  if (canAdd)
                    TextButton.icon(
                      onPressed: () => _showAddProfile(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('추가'),
                    )
                  else
                    Text(
                      '최대 5개',
                      style: context.typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // 본인 프로필
            _ProfileListTile(
              name: primaryProfileAsync.valueOrNull?.name ?? '나',
              subtitle: '본인',
              initial: (primaryProfileAsync.valueOrNull?.name ?? '나')
                  .substring(0, 1),
              isSelected: activeState.isPrimary,
              onTap: () {
                ref.read(activeProfileProvider.notifier).switchToPrimary();
                Navigator.pop(context);
              },
            ),

            // 구분선
            Divider(color: colors.divider, height: 1),

            // 서브 프로필 목록
            secondaryProfiles.when(
              data: (profiles) {
                if (profiles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 48,
                          color: colors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '등록된 프로필이 없습니다',
                          style: context.typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddProfile(context),
                          child: const Text('프로필 추가하기'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return _ProfileListTile(
                      name: profile.name,
                      subtitle: profile.relationshipText,
                      initial: profile.initial,
                      isSelected: activeState.isSecondary &&
                          activeState.secondaryProfileId == profile.id,
                      onTap: () {
                        ref
                            .read(activeProfileProvider.notifier)
                            .switchToSecondary(profile.id);
                        Navigator.pop(context);
                      },
                      onLongPress: () =>
                          _showProfileOptions(context, ref, profile.id),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '프로필을 불러오지 못했습니다',
                  style: context.typography.bodyMedium.copyWith(
                    color: colors.error,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddProfile(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (_) => const AddProfileSheet(),
    );
  }

  void _showProfileOptions(
      BuildContext context, WidgetRef ref, String profileId) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      barrierColor: DSColors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: colors.textPrimary,
              ),
              title: Text(
                '수정',
                style: context.typography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile/edit');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: colors.error,
              ),
              title: Text(
                '삭제',
                style: context.typography.bodyLarge.copyWith(
                  color: colors.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _showDeleteConfirmation(context);
                if (confirmed == true) {
                  await ref
                      .read(secondaryProfilesProvider.notifier)
                      .deleteProfile(profileId);
                  // 삭제된 프로필이 활성 상태였다면 본인으로 전환
                  final activeState = ref.read(activeProfileProvider);
                  if (activeState.secondaryProfileId == profileId) {
                    ref.read(activeProfileProvider.notifier).switchToPrimary();
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final colors = context.colors;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '프로필 삭제',
          style: context.typography.headingMedium.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          '이 프로필을 삭제하시겠습니까?\n삭제된 프로필은 복구할 수 없습니다.',
          style: context.typography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: context.typography.buttonMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '삭제',
              style: context.typography.buttonMedium.copyWith(
                color: colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 프로필 목록 아이템
class _ProfileListTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String initial;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ProfileListTile({
    required this.name,
    required this.subtitle,
    required this.initial,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentSecondary
              : colors.accentSecondary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initial,
            style: context.typography.headingSmall.copyWith(
              color: isSelected ? Colors.white : colors.accentSecondary,
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: context.typography.bodyLarge.copyWith(
          color: colors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: context.typography.bodySmall.copyWith(color: colors.textSecondary),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colors.accentSecondary)
          : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
