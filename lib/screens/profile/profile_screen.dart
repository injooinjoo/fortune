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
import '../../services/app_version_service.dart';
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
    final fallbackName = user.userMetadata?['name'] as String? ??
        user.userMetadata?['full_name'] as String? ??
        user.email ??
        '사용자';
    final fallbackEmail = user.email ?? '';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: PaperRuntimeAppBar(
        title: '설정',
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
              const _SectionLabel(title: '내 정보'),
              const SizedBox(height: DSSpacing.sm),
              _ProfileInfoPanel(
                profile: profile,
                fallbackName: fallbackName,
                fallbackEmail: fallbackEmail,
              ),
              const SizedBox(height: DSSpacing.sm),
              _ProfileStatChips(profile: profile),
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
                      PaperRuntimeMenuTile(
                        title: '알림 설정',
                        subtitle: '일일 운세와 캐릭터 메시지 수신을 관리해요',
                        onTap: () => context.push('/profile/notifications'),
                        showDivider: true,
                      ),
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
              const _SectionLabel(title: '이용 정보'),
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
                      _ProfileValueTile(
                        title: '구독 상태',
                        value: _subscriptionStatusLabel(
                          profile?.subscriptionStatus ??
                              SubscriptionStatus.free,
                        ),
                        subtitle: profile?.isTestAccount == true
                            ? '테스트 계정으로 일부 프리미엄 기능이 열려 있어요'
                            : '현재 계정에서 사용 중인 플랜 정보예요',
                        showDivider: true,
                      ),
                      _ProfileValueTile(
                        title: '토큰 잔액',
                        value: '${profile?.tokenBalance ?? 0}',
                        subtitle: '운세와 AI 기능에 사용할 수 있는 토큰이에요',
                        showDivider: true,
                      ),
                      _ProfileValueTile(
                        title: '누적 인사이트',
                        value: '${profile?.fortuneCount ?? 0}회',
                        subtitle: '지금까지 받은 결과와 인사이트 누적 횟수예요',
                        showDivider: true,
                      ),
                      PaperRuntimeMenuTile(
                        title: '사주 요약',
                        subtitle: profile?.birthDate == null
                            ? '출생 정보를 등록하면 사주 요약을 볼 수 있어요'
                            : '등록한 출생 정보로 사주 요약을 확인해요',
                        onTap: () => context.push('/profile/saju-summary'),
                        showDivider: true,
                      ),
                      PaperRuntimeMenuTile(
                        title: '인간관계',
                        subtitle: '스토리 캐릭터와의 관계를 정리해서 확인해요',
                        onTap: () => context.push('/profile/relationships'),
                        showDivider: true,
                      ),
                      PaperRuntimeMenuTile(
                        title: '구독 및 토큰',
                        subtitle: '플랜과 토큰 사용 현황을 자세히 관리해요',
                        onTap: () => context.push('/premium'),
                        showDivider: true,
                      ),
                      PaperRuntimeMenuTile(
                        title: '구매 복원',
                        subtitle: '복원 가능한 결제 내역을 다시 불러와요',
                        onTap: () => _handleRestorePurchases(context),
                        showDivider: true,
                      ),
                      PaperRuntimeMenuTile(
                        title: '구독 관리',
                        subtitle: '스토어 구독 관리 화면으로 이동해요',
                        onTap: _openSubscriptionManagement,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              const _SectionLabel(title: '정책 및 기타 정보'),
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
                      _ProfileValueTile(
                        title: '계정 유형',
                        value:
                            profile?.isTestAccount == true ? '테스트 계정' : '일반 계정',
                        subtitle: '로그인한 계정 상태를 기준으로 표시돼요',
                        showDivider: true,
                      ),
                      _ProfileValueTile(
                        title: '가입일',
                        value: _formatDate(
                          profile?.createdAt,
                          fallback: '기록 없음',
                        ),
                        showDivider: true,
                      ),
                      _ProfileValueTile(
                        title: '최근 수정',
                        value: _formatDateTime(
                          profile?.updatedAt,
                          fallback: '기록 없음',
                        ),
                        showDivider: true,
                      ),
                      const _AppVersionTile(showDivider: true),
                      PaperRuntimeMenuTile(
                        title: '개인정보처리방침',
                        subtitle: '개인정보 수집 및 사용 정책을 확인해요',
                        onTap: () => context.push('/privacy-policy'),
                        showDivider: true,
                      ),
                      PaperRuntimeMenuTile(
                        title: '이용약관',
                        subtitle: '서비스 이용 조건과 약관을 확인해요',
                        onTap: () => context.push('/terms-of-service'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
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
        title: '설정',
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
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              alignment: WrapAlignment.center,
              children: [
                DSChip(
                  label: _subscriptionStatusLabel(
                    profile?.subscriptionStatus ?? SubscriptionStatus.free,
                  ),
                  style: DSChipStyle.outlined,
                ),
                DSChip(
                  label: _providerLabel(profile?.primaryProvider),
                  style: DSChipStyle.outlined,
                ),
                if (profile?.isTestAccount == true)
                  const DSChip(
                    label: '테스트 계정',
                    style: DSChipStyle.outlined,
                  ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
            PaperRuntimeButton(
              label: '프로필 수정',
              onPressed: onEditTap,
              variant: PaperRuntimeButtonVariant.secondary,
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
      backgroundColor: context.colors.selectionBackground.withValues(
        alpha: 0.92,
      ),
      child: Text(
        initial,
        style: context.typography.headingMedium.copyWith(
          color: context.colors.selectionForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileStatChips extends StatelessWidget {
  final UserProfile? profile;

  const _ProfileStatChips({required this.profile});

  @override
  Widget build(BuildContext context) {
    final tokenBalance = profile?.tokenBalance ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              value: profile?.chineseZodiac?.isNotEmpty == true
                  ? '${profile!.chineseZodiac}띠'
                  : '-',
              label: '띠',
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: _StatChip(
              value: '${profile?.fortuneCount ?? 0}',
              label: '인사이트',
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: _StatChip(
              value: '$tokenBalance',
              label: '토큰 잔액',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoPanel extends StatelessWidget {
  final UserProfile? profile;
  final String fallbackName;
  final String fallbackEmail;

  const _ProfileInfoPanel({
    required this.profile,
    required this.fallbackName,
    required this.fallbackEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
      ),
      child: PaperRuntimePanel(
        padding: EdgeInsets.zero,
        elevated: false,
        child: Column(
          children: [
            _ProfileValueTile(
              title: '이름',
              value: profile?.name.isNotEmpty == true
                  ? profile!.name
                  : fallbackName,
              showDivider: true,
            ),
            _ProfileValueTile(
              title: '이메일',
              value: fallbackEmail.isNotEmpty
                  ? fallbackEmail
                  : (profile?.email.isNotEmpty == true ? profile!.email : '-'),
              showDivider: true,
            ),
            _ProfileValueTile(
              title: '생년월일',
              value: _formatDate(profile?.birthDate),
              showDivider: true,
            ),
            _ProfileValueTile(
              title: '태어난 시간',
              value: _displayValue(profile?.birthTime),
              showDivider: true,
            ),
            _ProfileValueTile(
              title: '성별',
              value: profile?.gender.label ?? Gender.other.label,
              showDivider: true,
            ),
            _ProfileValueTile(
              title: 'MBTI',
              value: _displayValue(profile?.mbti),
              showDivider: true,
            ),
            _ProfileValueTile(
              title: '혈액형',
              value: _displayValue(profile?.bloodType),
              showDivider: true,
            ),
            _ProfileValueTile(
              title: '별자리 · 띠',
              value: _zodiacSummary(profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({
    required this.value,
    required this.label,
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
              color: context.colors.textPrimary,
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

class _ProfileValueTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final bool showDivider;

  const _ProfileValueTile({
    required this.title,
    required this.value,
    this.subtitle,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
        vertical: DSSpacing.md,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: DSSpacing.xxs),
                  Text(
                    subtitle!,
                    style: context.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Flexible(
            child: Text(
              value,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.right,
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
        vertical: DSSpacing.md,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            '앱 전반의 밝기와 색상 모드를 설정해요',
            style: context.bodySmall.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
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
    );
  }
}

class _LinkedAccountTile extends StatelessWidget {
  final UserProfile? profile;

  const _LinkedAccountTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    return PaperRuntimeMenuTile(
      title: '계정 연결',
      subtitle: _linkedProviderSummary(profile),
      showChevron: false,
      trailing: DSChip(
        label: _connectionCountLabel(profile),
        style: DSChipStyle.outlined,
      ),
    );
  }
}

class _AppVersionTile extends StatelessWidget {
  final bool showDivider;

  const _AppVersionTile({this.showDivider = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AppVersionService().getCurrentVersion(),
      builder: (context, snapshot) {
        final version = snapshot.hasError
            ? '확인 불가'
            : (snapshot.data?.isNotEmpty == true ? snapshot.data! : '확인 중');

        return _ProfileValueTile(
          title: '앱 버전',
          value: version,
          subtitle: '현재 기기에 설치된 앱 버전 정보예요',
          showDivider: showDivider,
        );
      },
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
        DSSpacing.xs,
      ),
      child: Text(
        title,
        style: context.typography.labelSmall.copyWith(
          color: context.colors.textTertiary,
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

String _displayValue(
  String? value, {
  String fallback = '아직 입력 안 됨',
}) {
  if (value == null) {
    return fallback;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

String _formatDate(
  DateTime? date, {
  String fallback = '아직 입력 안 됨',
}) {
  if (date == null) {
    return fallback;
  }

  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}.$month.$day';
}

String _formatDateTime(
  DateTime? dateTime, {
  String fallback = '기록 없음',
}) {
  if (dateTime == null) {
    return fallback;
  }

  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${_formatDate(dateTime, fallback: fallback)} $hour:$minute';
}

String _zodiacSummary(UserProfile? profile) {
  final values = <String>[
    if (profile?.zodiacSign?.isNotEmpty == true) profile!.zodiacSign!,
    if (profile?.chineseZodiac?.isNotEmpty == true)
      '${profile!.chineseZodiac}띠',
  ];

  if (values.isEmpty) {
    return '아직 계산 안 됨';
  }

  return values.join(' · ');
}

String _subscriptionStatusLabel(SubscriptionStatus status) {
  return switch (status) {
    SubscriptionStatus.free => '무료',
    SubscriptionStatus.premium => '프리미엄',
    SubscriptionStatus.premiumPlus => '프리미엄 플러스',
    SubscriptionStatus.enterprise => '엔터프라이즈',
  };
}

String _linkedProviderSummary(UserProfile? profile) {
  final providers = <String>{
    ...?profile?.linkedProviders,
    if (profile?.primaryProvider?.isNotEmpty == true) profile!.primaryProvider!,
  };

  if (providers.isEmpty) {
    return '연결된 소셜 계정이 없어요. 이메일 계정으로 사용 중이에요';
  }

  return providers.map(_providerLabel).join(' · ');
}

String _connectionCountLabel(UserProfile? profile) {
  final providers = <String>{
    ...?profile?.linkedProviders,
    if (profile?.primaryProvider?.isNotEmpty == true) profile!.primaryProvider!,
  };

  if (providers.isEmpty) {
    return '기본 계정';
  }

  return '${providers.length}개 연결';
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
