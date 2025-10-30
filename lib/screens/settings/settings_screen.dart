import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/toss_design_system.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/providers/token_provider.dart';
import '../../core/theme/typography_unified.dart';
import '../../core/services/debug_premium_service.dart';
import '../../shared/components/toast.dart';

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

    // 토스트 메시지
    if (!enabled) {
      Toast.show(context, message: '프리미엄 오버라이드 해제');
    } else {
      Toast.show(
        context,
        message: newValue ? '디버그: 프리미엄 활성화' : '디버그: 일반 사용자 모드',
      );
    }
  }

  // TOSS Design System Helper Methods (프로필 페이지와 동일)
  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark900
        : TossDesignSystem.gray900;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark400
        : TossDesignSystem.gray600;
  }

  Color _getBackgroundColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark50
        : TossDesignSystem.gray50;
  }

  Color _getCardColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark100
        : TossDesignSystem.white;
  }

  Color _getDividerColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray200;
  }

  @override
  Widget build(BuildContext context) {
    final tokenState = ref.watch(tokenProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: isDarkMode ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '설정',
          style: TypographyUnified.heading3.copyWith(
            color: isDarkMode ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TossDesignSystem.spacingM),

              // 계정 섹션
              _buildSectionHeader('계정'),
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.marginHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListItem(
                      icon: Icons.person_outline,
                      title: '프로필 편집',
                      onTap: () async {
                        final result = await context.push('/profile/edit');
                        if (result == true && mounted) {
                          setState(() {});
                        }
                      },
                    ),
                    _buildListItem(
                      icon: Icons.link_outlined,
                      title: '소셜 계정 연동',
                      subtitle: '여러 로그인 방법을 하나로 관리',
                      onTap: () => context.push('/settings/social-accounts'),
                    ),
                    _buildListItem(
                      icon: Icons.phone_outlined,
                      title: '전화번호 관리',
                      subtitle: '전화번호 변경 및 인증',
                      onTap: () => context.push('/settings/phone-management'),
                    ),
                    _buildListItem(
                      icon: Icons.notifications_outlined,
                      title: '알림 설정',
                      subtitle: '푸시, 문자, 운세 알림 관리',
                      onTap: () => context.push('/settings/notifications'),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 앱 설정 섹션
              _buildSectionHeader('앱 설정'),
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.marginHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListItem(
                      icon: Icons.dark_mode_outlined,
                      title: '다크 모드',
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          ref.read(themeModeProvider.notifier).setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light);
                        },
                        activeColor: TossDesignSystem.tossBlue,
                      ),
                    ),
                    _buildListItem(
                      icon: Icons.language_outlined,
                      title: '언어',
                      subtitle: '한국어',
                      onTap: () {
                        // TODO: Implement language selection
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 결제 섹션
              _buildSectionHeader('결제'),
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.marginHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListItem(
                      icon: Icons.local_offer_outlined,
                      title: '토큰 구매',
                      subtitle: '토큰 충전하기',
                      onTap: () => context.go('/payment/tokens'),
                    ),
                    _buildListItem(
                      icon: Icons.card_membership_outlined,
                      title: '구독 관리',
                      subtitle: tokenState.hasUnlimitedAccess
                          ? '프리미엄 구독 중'
                          : '프리미엄 시작하기',
                      showBadge: tokenState.hasUnlimitedAccess,
                      onTap: () => context.go('/subscription'),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 지원 섹션
              _buildSectionHeader('지원'),
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.marginHorizontal),
                decoration: BoxDecoration(
                  color: _getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDividerColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TossDesignSystem.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListItem(
                      icon: Icons.help_outline,
                      title: '도움말',
                      onTap: () => context.push('/help'),
                    ),
                    _buildListItem(
                      icon: Icons.privacy_tip_outlined,
                      title: '개인정보 처리방침',
                      onTap: () => context.push('/policy/privacy'),
                    ),
                    _buildListItem(
                      icon: Icons.description_outlined,
                      title: '이용약관',
                      onTap: () => context.push('/policy/terms'),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 개발자 도구 (개발 환경에서만 표시)
              if (kDebugMode) ...[
                _buildSectionHeader('개발자 도구'),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: TossDesignSystem.marginHorizontal),
                  decoration: BoxDecoration(
                    color: _getCardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getDividerColor(context),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TossDesignSystem.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildListItem(
                        icon: Icons.cloud_download_outlined,
                        title: '유명인 정보 크롤링',
                        onTap: () => context.push('/admin/celebrity-crawling'),
                      ),
                      _buildListItem(
                        icon: _overrideEnabled
                            ? (_premiumOverride
                                ? Icons.workspace_premium
                                : Icons.person_outline)
                            : Icons.toggle_off_outlined,
                        title: '프리미엄 상태 토글',
                        subtitle: _overrideEnabled
                            ? (_premiumOverride ? '강제 프리미엄' : '강제 일반 사용자')
                            : '오버라이드 해제됨',
                        onTap: _togglePremiumOverride,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],

              // 로그아웃
              const SizedBox(height: TossDesignSystem.spacingXL),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.marginHorizontal),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            '로그아웃',
                            style: TossDesignSystem.heading4.copyWith(
                              color: _getTextColor(context),
                            ),
                          ),
                          content: Text(
                            '정말 로그아웃 하시겠습니까?',
                            style: TossDesignSystem.body2.copyWith(
                              color: _getTextColor(context),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                '취소',
                                style: TossDesignSystem.button.copyWith(
                                  color: _getSecondaryTextColor(context),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                '로그아웃',
                                style: TossDesignSystem.button.copyWith(
                                  color: TossDesignSystem.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await supabase.auth.signOut();
                        if (mounted) {
                          context.go('/splash');
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: TossDesignSystem.spacingM),
                      side: BorderSide(color: TossDesignSystem.errorRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            TossDesignSystem.radiusM),
                      ),
                    ),
                    child: Text(
                      '로그아웃',
                      style: TossDesignSystem.button.copyWith(
                        color: TossDesignSystem.errorRed,
                      ),
                    ),
                  ),
                ),
              ),

              // 버전 정보
              const SizedBox(height: TossDesignSystem.spacingL),
              Center(
                child: Text(
                  'Fortune v1.0.0',
                  style: TossDesignSystem.caption.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ),
              const SizedBox(height: TossDesignSystem.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }

  // 섹션 헤더 빌더 (프로필 페이지와 동일)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingL,
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingS,
      ),
      child: Text(
        title,
        style: TossDesignSystem.caption.copyWith(
          color: _getSecondaryTextColor(context),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // 리스트 아이템 빌더 (프로필 페이지와 동일한 스타일)
  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showBadge = false,
    Widget? trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TossDesignSystem.marginHorizontal,
            vertical: TossDesignSystem.spacingM,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isLast ? Colors.transparent : _getDividerColor(context),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // 아이콘 (프로필 스타일: 배경 없이 간결하게)
              Icon(
                icon,
                size: 22,
                color: _getSecondaryTextColor(context),
              ),
              const SizedBox(width: TossDesignSystem.spacingM),

              // 타이틀 & 서브타이틀
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TossDesignSystem.body2.copyWith(
                            color: _getTextColor(context),
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.tossBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PRO',
                              style: TossDesignSystem.caption.copyWith(
                                color: TossDesignSystem.white,
                                
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TossDesignSystem.caption.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing 위젯 또는 기본 화살표
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _getSecondaryTextColor(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
