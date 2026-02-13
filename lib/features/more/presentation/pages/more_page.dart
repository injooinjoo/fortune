import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../shared/components/premium_membership_card.dart';
import '../../../../shared/components/section_header.dart';
import '../../../../shared/components/settings_list_tile.dart';

/// 더보기 탭 - 프로필/프리미엄/트렌드/건강/설정/고객지원
class MorePage extends ConsumerStatefulWidget {
  const MorePage({super.key});

  @override
  ConsumerState<MorePage> createState() => _MorePageState();
}

class _MorePageState extends ConsumerState<MorePage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = 'v${info.version}');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.pageHorizontal,
                DSSpacing.md,
                DSSpacing.pageHorizontal,
                0,
              ),
              child: Text(
                '더보기',
                style: typography.headingLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),

            // 프로필 카드
            _buildProfileCard(colors, typography),

            // 프리미엄 멤버십
            const PremiumMembershipCard(),

            const SizedBox(height: DSSpacing.lg),

            // 트렌드 섹션
            const SectionHeader(title: '트렌드'),
            SettingsListTile(
              icon: Icons.psychology_outlined,
              title: '심리테스트',
              onTap: () => context.push('/trend'),
            ),
            SettingsListTile(
              icon: Icons.favorite_outline,
              title: '이상형 월드컵',
              onTap: () => context.push('/trend'),
            ),
            SettingsListTile(
              icon: Icons.balance_outlined,
              title: '밸런스 게임',
              isLast: true,
              onTap: () => context.push('/trend'),
            ),

            // 건강/웰니스 섹션
            const SectionHeader(title: '건강 · 웰니스'),
            SettingsListTile(
              icon: Icons.health_and_safety_outlined,
              title: '건강운',
              onTap: () => context.push('/health-toss'),
            ),
            SettingsListTile(
              icon: Icons.fitness_center,
              title: '운동',
              onTap: () => context.push('/exercise'),
            ),
            SettingsListTile(
              icon: Icons.sports_soccer,
              title: '스포츠 게임',
              onTap: () => context.push('/sports-game'),
            ),
            SettingsListTile(
              icon: Icons.self_improvement_outlined,
              title: '명상 · 호흡',
              isLast: true,
              onTap: () => context.push('/wellness/meditation'),
            ),

            // 설정 섹션
            const SectionHeader(title: '설정'),
            SettingsListTile(
              icon: Icons.person_outline,
              title: '프로필 수정',
              onTap: () => context.push('/profile/edit'),
            ),
            SettingsListTile(
              icon: Icons.text_fields,
              title: '폰트 설정',
              onTap: () => context.push('/profile/font'),
            ),
            SettingsListTile(
              icon: Icons.notifications_outlined,
              title: '알림 설정',
              onTap: () => context.push('/profile/notifications'),
            ),
            SettingsListTile(
              icon: Icons.link,
              title: '소셜 계정',
              isLast: true,
              onTap: () => context.push('/profile/social-accounts'),
            ),

            // 고객지원 섹션
            const SectionHeader(title: '고객지원'),
            SettingsListTile(
              icon: Icons.help_outline,
              title: '도움말 / FAQ',
              onTap: () => context.push('/help'),
            ),
            SettingsListTile(
              icon: Icons.description_outlined,
              title: '이용약관',
              onTap: () => context.push('/terms-of-service'),
            ),
            SettingsListTile(
              icon: Icons.shield_outlined,
              title: '개인정보 처리방침',
              onTap: () => context.push('/privacy-policy'),
            ),
            SettingsListTile(
              icon: Icons.delete_outline,
              title: '계정 삭제',
              isLast: true,
              onTap: () => context.push('/profile/account-deletion'),
            ),

            // 버전 정보
            if (_appVersion.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DSSpacing.lg,
                ),
                child: Center(
                  child: Text(
                    _appVersion,
                    style: typography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),

            // 하단 여백
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.pageHorizontal,
        DSSpacing.md,
        DSSpacing.pageHorizontal,
        0,
      ),
      child: GestureDetector(
        onTap: () => context.push('/profile'),
        child: Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(color: colors.divider, width: 0.5),
          ),
          child: userProfileAsync.when(
            data: (profile) {
              final name = profile?.name ?? '게스트';
              final birthDate = profile?.birthDate;
              final zodiac = profile?.chineseZodiac ?? '';
              final mbti = profile?.mbti ?? '';

              final subtitleParts = <String>[
                if (birthDate != null)
                  '${birthDate.year}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.day.toString().padLeft(2, '0')}',
                if (zodiac.isNotEmpty) zodiac,
                if (mbti.isNotEmpty) mbti,
              ];

              return Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.accent.withValues(alpha: 0.15),
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: typography.headingMedium.copyWith(
                        color: colors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: typography.headingSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        if (subtitleParts.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleParts.join(' · '),
                            style: typography.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colors.textSecondary,
                    size: 20,
                  ),
                ],
              );
            },
            loading: () => Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.surface,
                ),
                const SizedBox(width: DSSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            error: (_, __) => Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.accent.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person_outline,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Text(
                    '로그인해주세요',
                    style: typography.headingSmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
