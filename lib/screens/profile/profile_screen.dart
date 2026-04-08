import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../core/widgets/paper_runtime_surface_kit.dart';
import '../../models/user_profile.dart';
import '../../presentation/providers/providers.dart';
import '../../services/app_version_service.dart';
import '../../services/in_app_purchase_service.dart';
import 'providers/character_relationships_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(supabaseProvider).auth.currentUser;
    if (user == null) {
      return const _ProfileAuthRequiredView();
    }

    final profile = ref.watch(userProfileNotifierProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final relationshipStats = ref.watch(profileRelationshipStatsProvider);
    final fallbackName = user.userMetadata?['name'] as String? ??
        user.userMetadata?['full_name'] as String? ??
        user.email ??
        '사용자';
    final fallbackEmail = user.email ?? '';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: PaperRuntimeAppBar(
        title: '프로필',
        leading: IconButton(
          tooltip: '뒤로 가기',
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.colors.textPrimary,
          ),
          onPressed: () => _handleBack(context),
        ),
      ),
      body: PaperRuntimeBackground(
        showRings: false,
        applySafeArea: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(userProfileNotifierProvider.notifier).refresh();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              0,
              DSSpacing.sm,
              0,
              DSSpacing.xxl,
            ),
            children: [
              _ProfileSummaryCard(
                profile: profile,
                fallbackName: fallbackName,
                fallbackEmail: fallbackEmail,
                onEditTap: () => context.push('/profile/edit'),
              ),
              const SizedBox(height: DSSpacing.sm),
              _ProfileStatChips(
                profile: profile,
                relationshipCount: relationshipStats.activeRelationshipCount,
              ),
              const SizedBox(height: DSSpacing.sm),
              const _SectionLabel(title: '나의 온도'),
              const SizedBox(height: DSSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal,
                ),
                child: PaperRuntimePanel(
                  padding: EdgeInsets.zero,
                  elevated: false,
                  child: Column(
                    children: [
                      _ProfileActionTile(
                        icon: Icons.circle_outlined,
                        title: '사주 요약',
                        onTap: () => context.push('/profile/saju-summary'),
                        showDivider: true,
                      ),
                      _ProfileActionTile(
                        icon: Icons.groups_outlined,
                        title: '인간관계',
                        onTap: () => context.push('/profile/relationships'),
                        showDivider: true,
                      ),
                      _ProfileActionTile(
                        icon: Icons.notifications_none_rounded,
                        title: '알림 설정',
                        onTap: () => context.push('/profile/notifications'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              const _SectionLabel(title: '구독 관리'),
              const SizedBox(height: DSSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal,
                ),
                child: PaperRuntimePanel(
                  padding: EdgeInsets.zero,
                  elevated: false,
                  child: Column(
                    children: [
                      _ProfileActionTile(
                        icon: Icons.workspace_premium_outlined,
                        title: '구독 및 토큰',
                        onTap: () => context.push('/premium'),
                        showDivider: true,
                      ),
                      _ProfileActionTile(
                        icon: Icons.restore_rounded,
                        title: '구매 복원',
                        onTap: () => _handleRestorePurchases(context),
                        showDivider: true,
                      ),
                      _ProfileActionTile(
                        icon: Icons.credit_card_outlined,
                        title: '구독 관리',
                        onTap: _openSubscriptionManagement,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              const _SectionLabel(title: '설정'),
              const SizedBox(height: DSSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal,
                ),
                child: PaperRuntimePanel(
                  padding: EdgeInsets.zero,
                  elevated: false,
                  child: Column(
                    children: [
                      _ThemeModeTile(
                        themeMode: themeMode,
                        onSelected: (index) async {
                          final nextMode = switch (index) {
                            0 => ThemeMode.system,
                            1 => ThemeMode.light,
                            _ => ThemeMode.dark,
                          };
                          await ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(nextMode);
                        },
                      ),
                      _LinkedAccountTile(profile: profile),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              const _SectionLabel(title: '정보'),
              const SizedBox(height: DSSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal,
                ),
                child: PaperRuntimePanel(
                  padding: EdgeInsets.zero,
                  elevated: false,
                  child: Column(
                    children: [
                      _ProfileActionTile(
                        icon: Icons.description_outlined,
                        title: '개인정보처리방침',
                        onTap: () => context.push('/privacy-policy'),
                        showDivider: true,
                      ),
                      _ProfileActionTile(
                        icon: Icons.article_outlined,
                        title: '이용약관',
                        onTap: () => context.push('/terms-of-service'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.xl),
              _ProfileFooter(
                onLogoutTap: () => _handleLogout(context, ref),
                onDeleteTap: () => context.push('/account-deletion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRestorePurchases(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Restoring purchases... / 구매 복원 중...'),
        duration: Duration(seconds: 2),
      ),
    );
    try {
      await InAppPurchaseService().restorePurchases();
      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Purchases restored. / 구매가 복원되었습니다.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to restore purchases. Please try again.\n구매 복원에 실패했습니다. 다시 시도해 주세요.',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  Future<void> _openSubscriptionManagement() async {
    final Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await DSModal.confirm(
      context: context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
      cancelText: '취소',
      isDestructive: true,
    );

    if (shouldLogout != true) {
      return;
    }

    await ref.read(sessionCleanupServiceProvider).signOutAndClearSession();

    if (!context.mounted) {
      return;
    }

    context.go('/chat');
  }
}

class _ProfileAuthRequiredView extends StatelessWidget {
  const _ProfileAuthRequiredView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: PaperRuntimeAppBar(
        title: '프로필',
        leading: IconButton(
          tooltip: '뒤로 가기',
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.colors.textPrimary,
          ),
          onPressed: () => _handleBack(context),
        ),
      ),
      body: PaperRuntimeBackground(
        ringAlignment: Alignment.center,
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Center(
          child: PaperRuntimePanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(height: DSSpacing.md),
                Text(
                  '로그인 후 계정 정보를 확인할 수 있어요.',
                  style: context.bodyLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DSSpacing.lg),
                PaperRuntimeButton(
                  label: '채팅으로 돌아가기',
                  onPressed: () => context.go('/chat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final UserProfile? profile;
  final String fallbackName;
  final String fallbackEmail;
  final VoidCallback onEditTap;

  const _ProfileSummaryCard({
    required this.profile,
    required this.fallbackName,
    required this.fallbackEmail,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        profile?.name.isNotEmpty == true ? profile!.name : fallbackName;
    final email = fallbackEmail.isNotEmpty
        ? fallbackEmail
        : (profile?.email.isNotEmpty == true ? profile!.email : '');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
        vertical: DSSpacing.lg,
      ),
      child: PaperRuntimePanel(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.xl,
        ),
        elevated: false,
        child: Column(
          children: [
            _ProfileAvatar(
              imageUrl: profile?.profileImageUrl,
              name: displayName,
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              displayName,
              style: context.typography.headingSmall.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              email,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            _SummaryPillButton(
              label: '프로필 수정',
              onTap: onEditTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const _ProfileAvatar({
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim().characters.first : 'U';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 36,
        backgroundColor: context.colors.surface,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return CircleAvatar(
      radius: 36,
      backgroundColor: context.colors.surface,
      child: Text(
        initial,
        style: context.typography.headingMedium.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileStatChips extends StatelessWidget {
  final UserProfile? profile;
  final int relationshipCount;

  const _ProfileStatChips({
    required this.profile,
    required this.relationshipCount,
  });

  @override
  Widget build(BuildContext context) {
    final tokenBalance = profile?.tokenBalance ?? 0;
    final sajuInfo = _sajuElementValue(profile);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              value: sajuInfo,
              label: '사주 원소',
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: _StatChip(
              value: '$relationshipCount명',
              label: '인간관계',
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: _StatChip(
              value: '$tokenBalance',
              label: '토큰 잔액',
              valueColor: context.colors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatChip({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: context.colors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: context.typography.headingSmall.copyWith(
              color: valueColor ?? context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            label,
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<int> onSelected;

  const _ThemeModeTile({
    required this.themeMode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: 0.72),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dark_mode_outlined,
                size: 20,
                color: colors.textSecondary,
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  '테마 모드',
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DSChoiceChips(
                options: const ['시스템', '라이트', '다크'],
                selected: switch (themeMode) {
                  ThemeMode.system => 0,
                  ThemeMode.light => 1,
                  ThemeMode.dark => 2,
                },
                onSelected: onSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkedAccountTile extends StatelessWidget {
  final UserProfile? profile;

  const _LinkedAccountTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _ProfileActionTile(
      icon: Icons.link_outlined,
      title: '계정 연결',
      showDivider: false,
      trailing: DSChip(
        label: _providerLabel(profile?.primaryProvider),
        style: DSChipStyle.outlined,
      ),
      onTap: null,
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool showDivider;
  final Widget? trailing;

  const _ProfileActionTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.showDivider = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final row = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colors.border.withValues(alpha: 0.72),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colors.textSecondary,
          ),
          const SizedBox(width: DSSpacing.sm),
          Text(
            title,
            style: context.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: DSSpacing.xs),
          ],
          Icon(
            Icons.chevron_right,
            size: 18,
            color: colors.textTertiary,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: row,
      ),
    );
  }
}

class _SummaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SummaryPillButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colors.selectionBackground,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: context.bodyMedium.copyWith(
              color: context.colors.selectionForeground,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  final VoidCallback onLogoutTap;
  final VoidCallback onDeleteTap;

  const _ProfileFooter({
    required this.onLogoutTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        TextButton(
          onPressed: onLogoutTap,
          child: Text(
            '로그아웃',
            style: context.bodySmall.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: onDeleteTap,
          child: Text(
            '계정 삭제',
            style: context.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ),
        FutureBuilder<String>(
          future: AppVersionService().getCurrentVersion(),
          builder: (context, snapshot) {
            final version = snapshot.hasError
                ? 'v-'
                : 'v${snapshot.data?.isNotEmpty == true ? snapshot.data! : '-'}';

            return Padding(
              padding: const EdgeInsets.only(
                top: DSSpacing.xs,
                bottom: DSSpacing.xl,
              ),
              child: Text(
                version,
                style: context.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.pageHorizontal,
        DSSpacing.md,
        DSSpacing.pageHorizontal,
        DSSpacing.xxs,
      ),
      child: Text(
        title,
        style: context.bodyLarge.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

void _handleBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go('/chat');
}

String _sajuElementValue(UserProfile? profile) {
  if (profile?.zodiacSign?.isNotEmpty == true) {
    return profile!.zodiacSign!;
  }

  if (profile?.chineseZodiac?.isNotEmpty == true) {
    return profile!.chineseZodiac!;
  }

  return '-';
}

String _providerLabel(String? provider) {
  switch (provider) {
    case 'google':
      return 'Google';
    case 'apple':
      return 'Apple';
    case 'kakao':
      return 'Kakao';
    case 'naver':
      return 'Naver';
    default:
      return '이메일';
  }
}
