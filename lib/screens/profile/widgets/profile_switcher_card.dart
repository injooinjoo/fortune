import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/tokens/ds_colors.dart';
import '../../../core/theme/typography_unified.dart';
import '../../../core/theme/app_theme/fortune_theme_extension.dart';
import '../../../presentation/providers/active_profile_provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/secondary_profiles_provider.dart';
import 'profile_list_sheet.dart';

/// 프로필 스위처 카드 (프로필 화면 상단)
///
/// 현재 활성 프로필을 보여주고, 탭하면 프로필 목록 바텀시트 표시
class ProfileSwitcherCard extends ConsumerWidget {
  const ProfileSwitcherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneTheme = context.fortuneTheme;
    final activeState = ref.watch(activeProfileProvider);
    final primaryProfileAsync = ref.watch(userProfileProvider);
    final secondaryProfiles = ref.watch(secondaryProfilesProvider);

    final profileCount = 1 + (secondaryProfiles.valueOrNull?.length ?? 0);

    // 활성 프로필 정보 가져오기
    String profileName;
    String profileInitial;

    if (activeState.isPrimary) {
      profileName = primaryProfileAsync.valueOrNull?.name ?? '나';
      profileInitial = profileName.isNotEmpty ? profileName.substring(0, 1) : '나';
    } else {
      final activeSecondary = ref.watch(activeSecondaryProfileProvider);
      profileName = activeSecondary?.name ?? '프로필';
      profileInitial = activeSecondary?.initial ?? '?';
    }

    return GestureDetector(
      onTap: () => _showProfileList(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fortuneTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fortuneTheme.dividerColor),
        ),
        child: Row(
          children: [
            // 아바타
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  profileInitial,
                  style: context.heading3.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 이름 & 프로필 개수
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profileName,
                          style: context.heading3.copyWith(
                            color: fortuneTheme.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (activeState.isSecondary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '대리',
                            style: context.labelSmall.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '프로필 $profileCount개',
                    style: context.bodySmall.copyWith(
                      color: fortuneTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // 드롭다운 아이콘
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: fortuneTheme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (_) => const ProfileListSheet(),
    );
  }
}
