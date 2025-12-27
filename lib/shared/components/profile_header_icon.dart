import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../presentation/providers/user_profile_notifier.dart';
import '../../features/chat/presentation/widgets/profile_bottom_sheet.dart';

/// 프로필 헤더 아이콘
/// 모든 탭 페이지의 좌측 상단에 표시되는 원형 프로필 아이콘
class ProfileHeaderIcon extends ConsumerWidget {
  const ProfileHeaderIcon({super.key});

  void _showProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final profileAsync = ref.watch(userProfileNotifierProvider);

    return GestureDetector(
      onTap: () => _showProfileBottomSheet(context),
      child: profileAsync.when(
        data: (profile) => CircleAvatar(
          radius: 14,
          backgroundColor: colors.surfaceSecondary,
          backgroundImage: profile?.profileImageUrl != null
              ? NetworkImage(profile!.profileImageUrl!)
              : null,
          child: profile?.profileImageUrl == null
              ? Icon(Icons.person, size: 16, color: colors.textSecondary)
              : null,
        ),
        loading: () => CircleAvatar(
          radius: 14,
          backgroundColor: colors.surfaceSecondary,
          child: const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
        error: (_, __) => CircleAvatar(
          radius: 14,
          backgroundColor: colors.surfaceSecondary,
          child: Icon(Icons.person, size: 16, color: colors.textSecondary),
        ),
      ),
    );
  }
}
