import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/fortune_constants.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../core/widgets/paper_runtime_surface_kit.dart';
import '../../models/user_profile.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/social_accounts_section.dart';
import '../../services/in_app_purchase_service.dart';

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

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const PaperRuntimeAppBar(title: '프로필'),
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
              _ProfileSummaryRow(
                profile: profile,
                fallbackName: user.userMetadata?['name'] as String? ??
                    user.userMetadata?['full_name'] as String? ??
                    user.email ??
                    '사용자',
                fallbackEmail: user.email ?? '',
                onTap: () => context.push('/profile/edit'),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: context.colors.border.withValues(alpha: 0.72),
              ),
              PaperRuntimeMenuTile(
                title: '사주 요약',
                onTap: () => context.push('/profile/saju-summary'),
              ),
              PaperRuntimeMenuTile(
                title: '인간관계',
                onTap: () => context.push('/profile/relationships'),
              ),
              PaperRuntimeMenuTile(
                title: '알림 설정',
                onTap: () => context.push('/profile/notifications'),
              ),
              PaperRuntimeMenuTile(
                title: '구독 및 토큰',
                subtitle: '구독 플랜 · 토큰 충전 · 프리미엄 콘텐츠',
                onTap: () => context.push('/premium'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal,
                ),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: context.colors.border.withValues(alpha: 0.72),
                ),
              ),
              PaperRuntimeMenuTile(
                title: '개인정보처리방침',
                onTap: () => context.push('/privacy-policy'),
              ),
              PaperRuntimeMenuTile(
                title: '이용약관',
                onTap: () => context.push('/terms-of-service'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal,
                ),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: context.colors.border.withValues(alpha: 0.72),
                ),
              ),
              PaperRuntimeMenuTile(
                title: '로그아웃',
                destructive: true,
                showChevron: false,
                onTap: () => _handleLogout(context, ref),
              ),
              PaperRuntimeMenuTile(
                title: '계정 삭제',
                destructive: true,
                showChevron: false,
                onTap: () => context.push('/account-deletion'),
              ),
              const SizedBox(height: DSSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal,
                ),
                child: PaperRuntimeExpandablePanel(
                  title: '추가 관리',
                  subtitle: '테마 모드, 구매 복원, 구독 관리, 계정 연결',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: DSSpacing.sm,
                        runSpacing: DSSpacing.sm,
                        children: [
                          DSChip(
                            label: _providerLabel(profile?.primaryProvider),
                            style: DSChipStyle.outlined,
                          ),
                          DSChip(
                            label:
                                _subscriptionLabel(profile?.subscriptionStatus),
                            style: DSChipStyle.outlined,
                          ),
                          DSChip(
                            label: '토큰 ${profile?.tokenBalance ?? 0}',
                            style: DSChipStyle.outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: DSSpacing.lg),
                      Text(
                        '테마 모드',
                        style: context.bodyLarge.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      DSChoiceChips(
                        options: const ['시스템', '라이트', '다크'],
                        selected: switch (themeMode) {
                          ThemeMode.system => 0,
                          ThemeMode.light => 1,
                          ThemeMode.dark => 2,
                        },
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
                      const SizedBox(height: DSSpacing.lg),
                      PaperRuntimeMenuTile(
                        title: '구매 복원',
                        subtitle: '이전 구매 항목을 복원합니다',
                        onTap: () => _handleRestorePurchases(context),
                        showDivider: true,
                      ),
                      PaperRuntimeMenuTile(
                        title: '구독 관리',
                        subtitle: Platform.isIOS
                            ? 'Apple 구독을 관리합니다'
                            : 'Google Play 구독을 관리합니다',
                        onTap: _openSubscriptionManagement,
                      ),
                      const SizedBox(height: DSSpacing.lg),
                      Text(
                        '계정 연결',
                        style: context.bodyLarge.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      SocialAccountsSection(
                        linkedProviders: profile?.linkedProviders,
                        primaryProvider: profile?.primaryProvider ??
                            user.appMetadata['provider'] as String?,
                        onProvidersChanged: (providers) async {
                          if (profile == null) {
                            return;
                          }
                          await ref
                              .read(userProfileNotifierProvider.notifier)
                              .updateProfile(
                                profile.copyWith(linkedProviders: providers),
                              );
                        },
                        socialAuthService: ref.watch(socialAuthServiceProvider),
                      ),
                    ],
                  ),
                ),
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
      appBar: const PaperRuntimeAppBar(title: '프로필'),
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

class _ProfileSummaryRow extends StatelessWidget {
  final UserProfile? profile;
  final String fallbackName;
  final String fallbackEmail;
  final VoidCallback onTap;

  const _ProfileSummaryRow({
    required this.profile,
    required this.fallbackName,
    required this.fallbackEmail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        profile?.name.isNotEmpty == true ? profile!.name : fallbackName;
    final email = fallbackEmail.isNotEmpty
        ? fallbackEmail
        : (profile?.email.isNotEmpty == true ? profile!.email : '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.pageHorizontal,
            vertical: DSSpacing.lg,
          ),
          child: Row(
            children: [
              _ProfileAvatar(
                imageUrl: profile?.profileImageUrl,
                name: displayName,
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: context.heading4.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: context.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.colors.textTertiary,
              ),
            ],
          ),
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
        radius: 28,
        backgroundColor: context.colors.surface,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: context.colors.selectionBackground.withValues(
        alpha: 0.92,
      ),
      child: Text(
        initial,
        style: context.heading4.copyWith(
          color: context.colors.selectionForeground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _providerLabel(String? provider) {
  switch (provider) {
    case 'google':
      return 'Google 연결';
    case 'apple':
      return 'Apple 연결';
    case 'kakao':
      return 'Kakao 연결';
    default:
      return '이메일 계정';
  }
}

String _subscriptionLabel(SubscriptionStatus? subscriptionStatus) {
  switch (subscriptionStatus) {
    case SubscriptionStatus.premium:
      return '프리미엄';
    case SubscriptionStatus.premiumPlus:
      return '프리미엄 플러스';
    case SubscriptionStatus.enterprise:
      return '엔터프라이즈';
    default:
      return '무료 플랜';
  }
}
