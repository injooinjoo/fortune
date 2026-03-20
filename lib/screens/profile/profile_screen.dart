import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/fortune_constants.dart';
import '../../core/cache/cache_service.dart';
import '../../core/design_system/design_system.dart';
import '../../features/character/data/services/character_affinity_service.dart';
import '../../features/character/data/services/character_chat_local_service.dart';
import '../../features/fortune/presentation/providers/saju_provider.dart';
import '../../models/user_profile.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/social_accounts_section.dart';
import 'providers/character_relationships_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    final user = supabase.auth.currentUser;

    if (user == null) {
      return const _ProfileAuthRequiredView();
    }

    final profileAsync = ref.watch(userProfileNotifierProvider);
    final sajuState = ref.watch(sajuProvider);
    final relationshipStats = ref.watch(profileRelationshipStatsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final profile = profileAsync.valueOrNull;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '내 정보 설정',
          style: context.heading3.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userProfileNotifierProvider.notifier).refresh();
          await ref
              .read(sajuProvider.notifier)
              .fetchUserSaju(force: true, trigger: 'profile.refresh');
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.pageHorizontal,
            DSSpacing.md,
            DSSpacing.pageHorizontal,
            DSSpacing.xxl,
          ),
          children: [
            _AccountHeroCard(
              profile: profile,
              fallbackName: user.userMetadata?['name'] as String? ??
                  user.userMetadata?['full_name'] as String? ??
                  user.email ??
                  '사용자',
              fallbackEmail: user.email,
            ),
            const SizedBox(height: DSSpacing.xl),
            DSSectionHeader(
              title: '내 정보',
              uppercase: false,
              trailing: TextButton(
                onPressed: () => context.push('/profile/edit'),
                child: const Text('수정'),
              ),
            ),
            DSCard.outlined(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _InfoTile(
                    label: '생년월일',
                    value: _formatBirthDate(profile?.birthDate),
                  ),
                  _InfoTile(
                    label: '태어난 시간',
                    value: profile?.birthTime ?? '미설정',
                  ),
                  _InfoTile(
                    label: '성별',
                    value: profile?.gender.label ?? '미설정',
                  ),
                  _InfoTile(
                    label: 'MBTI',
                    value: profile?.mbti ?? '미설정',
                  ),
                  _InfoTile(
                    label: '혈액형',
                    value: profile?.bloodType ?? '미설정',
                  ),
                  _InfoTile(
                    label: '띠 / 별자리',
                    value: _buildZodiacText(profile),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.xl),
            const DSSectionHeader(title: '사주', uppercase: false),
            DSCard.elevated(
              padding: const EdgeInsets.all(DSSpacing.lg),
              onTap: () => context.push('/profile/saju-summary'),
              child: _SajuSummaryPreview(
                state: sajuState,
                profile: profile,
              ),
            ),
            const SizedBox(height: DSSpacing.xl),
            const DSSectionHeader(title: '스토리 캐릭터 관계도', uppercase: false),
            DSCard.elevated(
              padding: const EdgeInsets.all(DSSpacing.lg),
              onTap: () => context.push('/profile/relationships'),
              child: _RelationshipsSummaryCard(stats: relationshipStats),
            ),
            const SizedBox(height: DSSpacing.xl),
            const DSSectionHeader(title: '설정', uppercase: false),
            DSCard.outlined(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '테마 모드',
                    style: context.bodyLarge.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    '시스템, 라이트, 다크 모드를 전환할 수 있어요.',
                    style: context.bodySmall.copyWith(
                      color: context.colors.textSecondary,
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
                  const Divider(height: 1),
                  const SizedBox(height: DSSpacing.md),
                  _ActionRow(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                    subtitle: '일일 운세와 알림 수신 시간을 관리해요.',
                    onTap: () => context.push('/profile/notifications'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.xl),
            const DSSectionHeader(title: '계정 연결', uppercase: false),
            DSCard.outlined(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: SocialAccountsSection(
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
            ),
            const SizedBox(height: DSSpacing.xl),
            const DSSectionHeader(title: '서비스 및 약관', uppercase: false),
            DSCard.outlined(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionListTile(
                    icon: Icons.privacy_tip_outlined,
                    title: '개인정보처리방침',
                    subtitle: '개인정보 수집과 보관 방침을 확인해요.',
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  _ActionListTile(
                    icon: Icons.description_outlined,
                    title: '이용약관',
                    subtitle: '서비스 이용 조건을 확인해요.',
                    onTap: () => context.push('/terms-of-service'),
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.xl),
            const DSSectionHeader(title: '계정', uppercase: false),
            DSCard.outlined(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionListTile(
                    icon: Icons.person_remove_outlined,
                    title: '회원 탈퇴',
                    subtitle: '계정과 관련된 데이터를 삭제해요.',
                    isDestructive: true,
                    onTap: () => context.push('/account-deletion'),
                  ),
                  _ActionListTile(
                    icon: Icons.logout,
                    title: '로그아웃',
                    subtitle: '현재 로그인된 계정을 해제해요.',
                    isDestructive: true,
                    onTap: () => _handleLogout(context, ref),
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

    await ref.read(socialAuthServiceProvider).signOut();
    final storageService = ref.read(storageServiceProvider);
    await storageService.clearUserProfile();
    await storageService.clearActiveProfileOverride();
    await storageService.clearGuestMode();
    await storageService.clearGuestId();
    await CacheService().clearAllCache();
    await CharacterChatLocalService().clearAllConversations();
    await CharacterAffinityService().clearAllAffinities();

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.xl),
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
              const SizedBox(height: DSSpacing.md),
              DSButton.secondary(
                text: '채팅으로 돌아가기',
                onPressed: () => context.go('/chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountHeroCard extends StatelessWidget {
  const _AccountHeroCard({
    required this.profile,
    required this.fallbackName,
    required this.fallbackEmail,
  });

  final UserProfile? profile;
  final String fallbackName;
  final String? fallbackEmail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final providerLabel = _providerLabel(profile?.primaryProvider);

    return DSCard.gradient(
      gradient: LinearGradient(
        colors: [
          colors.surface,
          colors.backgroundSecondary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProfileAvatar(imageUrl: profile?.profileImageUrl),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.name.isNotEmpty == true
                          ? profile!.name
                          : fallbackName,
                      style: context.heading3.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xxs),
                    Text(
                      profile?.email.isNotEmpty == true
                          ? profile!.email
                          : (fallbackEmail ?? '이메일 없음'),
                      style: context.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              DSChip(
                label: providerLabel,
                style: DSChipStyle.outlined,
              ),
              DSChip(
                label: _subscriptionLabel(profile?.subscriptionStatus),
                style: DSChipStyle.outlined,
              ),
              DSChip(
                label: '토큰 ${profile?.tokenBalance ?? 0}',
                style: DSChipStyle.outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SajuSummaryPreview extends StatelessWidget {
  const _SajuSummaryPreview({
    required this.state,
    required this.profile,
  });

  final SajuState state;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (state.isLoading && state.sajuData == null) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile?.birthDate == null) {
      return const _SummaryBlock(
        title: '사주를 아직 계산할 수 없어요',
        description: '생년월일과 태어난 시간을 입력하면 사주 요약을 볼 수 있어요.',
      );
    }

    if (state.sajuData == null) {
      return const _SummaryBlock(
        title: '사주 정보 준비됨',
        description: '등록된 생년월일을 바탕으로 사주 요약을 생성할 수 있어요.',
      );
    }

    final day = state.sajuData!['day'] as Map<String, dynamic>?;
    final dayStem = day?['cheongan']?['char'] ?? '';
    final dayBranch = day?['jiji']?['char'] ?? '';
    final dominantElement =
        state.sajuData!['dominantElement'] as String? ?? '미확인';
    final lackingElement =
        state.sajuData!['lackingElement'] as String? ?? '미확인';
    final interpretation = state.sajuData!['interpretation'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일주는 $dayStem$dayBranch',
          style: context.heading4.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          '강한 오행은 $dominantElement, 보완 포인트는 $lackingElement예요.',
          style: context.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        if (interpretation.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          Text(
            interpretation,
            style: context.bodySmall.copyWith(
              color: colors.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _RelationshipsSummaryCard extends StatelessWidget {
  const _RelationshipsSummaryCard({
    required this.stats,
  });

  final ProfileRelationshipStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지금 가장 가까운 관계',
          style: context.heading4.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          stats.topEntry == null
              ? '아직 진행 중인 스토리 캐릭터 관계가 없어요.'
              : '${stats.topEntry!.character.name}님과 ${stats.topEntry!.phaseName} 단계예요. '
                  '호감도는 ${stats.topEntry!.lovePercent}%입니다.',
          style: context.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          children: [
            DSChip(
              label: '활성 ${stats.activeRelationshipCount}명',
              style: DSChipStyle.outlined,
            ),
            DSChip(
              label: '대화 ${stats.totalMessages}',
              style: DSChipStyle.outlined,
            ),
            DSChip(
              label: '읽지 않음 ${stats.totalUnread}',
              style: DSChipStyle.outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.heading4.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          description,
          style: context.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(DSRadius.md),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: context.colors.textSecondary),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  subtitle,
                  style: context.bodySmall.copyWith(
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
    );
  }
}

class _ActionListTile extends StatelessWidget {
  const _ActionListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isDestructive ? colors.error : colors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.md,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: foreground),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.bodyLarge.copyWith(color: foreground),
                      ),
                      const SizedBox(height: DSSpacing.xxs),
                      Text(
                        subtitle,
                        style: context.bodySmall.copyWith(
                          color: isDestructive
                              ? colors.error.withValues(alpha: 0.75)
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textTertiary),
              ],
            ),
            if (!isLast) ...[
              const SizedBox(height: DSSpacing.md),
              Divider(height: 1, color: colors.divider),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Text(
                  value,
                  style: context.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: DSSpacing.md),
            Divider(height: 1, color: colors.divider),
          ],
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(DSRadius.full),
        child: Image.network(
          imageUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _fallback(colors);
          },
        ),
      );
    }

    return _fallback(colors);
  }

  Widget _fallback(dynamic colors) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.backgroundSecondary,
        border: Border.all(color: colors.border),
      ),
      child: Icon(
        Icons.person_outline,
        color: colors.textSecondary,
      ),
    );
  }
}

String _formatBirthDate(DateTime? birthDate) {
  if (birthDate == null) {
    return '미설정';
  }

  final month = birthDate.month.toString().padLeft(2, '0');
  final day = birthDate.day.toString().padLeft(2, '0');
  return '${birthDate.year}.$month.$day';
}

String _buildZodiacText(UserProfile? profile) {
  final values = <String>[];
  if (profile?.chineseZodiac != null && profile!.chineseZodiac!.isNotEmpty) {
    values.add(profile.chineseZodiac!);
  }
  if (profile?.zodiacSign != null && profile!.zodiacSign!.isNotEmpty) {
    values.add(profile.zodiacSign!);
  }
  if (values.isEmpty) {
    return '미설정';
  }
  return values.join(' / ');
}

String _providerLabel(String? provider) {
  switch (provider) {
    case 'google':
      return 'Google 로그인';
    case 'apple':
      return 'Apple 로그인';
    case 'kakao':
      return 'Kakao 로그인';
    case 'naver':
      return 'Naver 로그인';
    default:
      return '기본 계정';
  }
}

String _subscriptionLabel(SubscriptionStatus? status) {
  switch (status) {
    case SubscriptionStatus.premium:
      return '프리미엄';
    case SubscriptionStatus.premiumPlus:
      return '프리미엄 플러스';
    case SubscriptionStatus.enterprise:
      return '엔터프라이즈';
    case SubscriptionStatus.free:
    case null:
      return '무료 플랜';
  }
}
