import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/providers/token_provider.dart';
import '../../core/services/debug_premium_service.dart';
import '../../core/providers/user_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final supabase = Supabase.instance.client;
  bool _premiumOverride = false;
  bool _overrideEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPremiumOverride();
  }

  Future<void> _loadPremiumOverride() async {
    final override = await DebugPremiumService.getOverrideValue();
    final enabled = await DebugPremiumService.isOverrideEnabled();
    setState(() {
      _premiumOverride = override ?? false;
      _overrideEnabled = enabled;
    });
  }

  Future<void> _togglePremiumOverride() async {
    final newValue = await DebugPremiumService.togglePremium();
    final enabled = await DebugPremiumService.isOverrideEnabled();

    if (!mounted) return;

    setState(() {
      _premiumOverride = newValue;
      _overrideEnabled = enabled;
    });

    // Toast message
    if (!enabled) {
      DSToast.info(context, '프리미엄 오버라이드 해제');
    } else {
      DSToast.info(
        context,
        newValue ? '디버그: 프리미엄 활성화' : '디버그: 일반 사용자 모드',
      );
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await DSModal.confirm(
      context: context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
      cancelText: '취소',
      isDestructive: true,
    );

    if (shouldLogout == true) {
      await supabase.auth.signOut();
      if (mounted) {
        context.go('/splash');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final tokenState = ref.watch(tokenProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '설정',
          style: typography.headingMedium.copyWith(
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DSSpacing.md),

              // 계정 섹션
              DSGroupedCard(
                header: '계정',
                children: [
                  DSListTile(
                    leading: const Icon(Icons.person_outline),
                    title: '프로필 편집',
                    onTap: () async {
                      final result = await context.push('/profile/edit');
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  DSListTile(
                    leading: const Icon(Icons.link_outlined),
                    title: '소셜 계정 연동',
                    subtitle: '여러 로그인 방법을 하나로 관리',
                    onTap: () => context.push('/settings/social-accounts'),
                  ),
                  DSListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: '전화번호 관리',
                    subtitle: '전화번호 변경 및 인증',
                    onTap: () => context.push('/settings/phone-management'),
                  ),
                  DSListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: '알림 설정',
                    subtitle: '푸시, 문자, 운세 알림 관리',
                    onTap: () => context.push('/settings/notifications'),
                    isLast: true,
                  ),
                ],
              ),

              // 앱 설정 섹션
              DSGroupedCard(
                header: '앱 설정',
                children: [
                  DSListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: '다크 모드',
                    trailing: DSToggle(
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ),
                  DSListTile(
                    leading: const Icon(Icons.vibration_outlined),
                    title: '진동 피드백',
                    subtitle: '버튼 및 카드 터치 시 진동',
                    trailing: DSToggle(
                      value: ref.watch(userSettingsProvider).hapticEnabled,
                      onChanged: (value) {
                        ref.read(userSettingsProvider.notifier).setHapticEnabled(value);
                        if (value) {
                          DSHaptics.light();
                        }
                      },
                    ),
                  ),
                  DSListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: '언어',
                    subtitle: '한국어',
                    onTap: () {
                      // TODO: Implement language selection
                    },
                    isLast: true,
                  ),
                ],
              ),

              // 결제 섹션
              DSGroupedCard(
                header: '결제',
                children: [
                  DSListTile(
                    leading: const Icon(Icons.local_offer_outlined),
                    title: '토큰 구매',
                    subtitle: '토큰 충전하기',
                    onTap: () => context.push('/token-purchase'),
                  ),
                  DSListTile(
                    leading: const Icon(Icons.card_membership_outlined),
                    title: '구독 관리',
                    subtitle: tokenState.hasUnlimitedAccess
                        ? '프리미엄 구독 중'
                        : '프리미엄 시작하기',
                    trailing: tokenState.hasUnlimitedAccess
                        ? DSBadge.pro()
                        : null,
                    onTap: () => context.go('/subscription'),
                    isLast: true,
                  ),
                ],
              ),

              // 지원 섹션
              DSGroupedCard(
                header: '지원',
                children: [
                  DSListTile(
                    leading: const Icon(Icons.help_outline),
                    title: '도움말',
                    onTap: () => context.push('/help'),
                  ),
                  DSListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: '개인정보 처리방침',
                    onTap: () => context.push('/policy/privacy'),
                  ),
                  DSListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: '이용약관',
                    onTap: () => context.push('/policy/terms'),
                    isLast: true,
                  ),
                ],
              ),

              // 개발자 도구 (개발 환경에서만 표시)
              if (kDebugMode)
                DSGroupedCard(
                  header: '개발자 도구',
                  children: [
                    DSListTile(
                      leading: const Icon(Icons.cloud_download_outlined),
                      title: '유명인 정보 크롤링',
                      onTap: () => context.push('/admin/celebrity-crawling'),
                    ),
                    DSListTile(
                      leading: Icon(
                        _overrideEnabled
                            ? (_premiumOverride
                                ? Icons.workspace_premium
                                : Icons.person_outline)
                            : Icons.toggle_off_outlined,
                      ),
                      title: '프리미엄 상태 토글',
                      subtitle: _overrideEnabled
                          ? (_premiumOverride ? '강제 프리미엄' : '강제 일반 사용자')
                          : '오버라이드 해제됨',
                      onTap: _togglePremiumOverride,
                      isLast: true,
                    ),
                  ],
                ),

              // 로그아웃 버튼
              const SizedBox(height: DSSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal,
                ),
                child: DSButton.destructive(
                  text: '로그아웃',
                  onPressed: _handleLogout,
                  size: DSButtonSize.medium,
                ),
              ),

              // 버전 정보
              const SizedBox(height: DSSpacing.lg),
              Center(
                child: Text(
                  'Fortune v1.0.0',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
