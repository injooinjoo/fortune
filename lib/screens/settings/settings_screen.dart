import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/toss_design_system.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/providers/token_provider.dart';
import '../../services/storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final supabase = Supabase.instance.client;
  final _storageService = StorageService();
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokenState = ref.watch(tokenProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      appBar: AppBar(
        backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
          onPressed: () => context.pop()),
        title: Text(
          '설정',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            fontSize: 18,
            fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 계정 섹션
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '계정',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: '프로필 편집',
                    onTap: () => context.push('/profile/edit'),
                    isFirst: true),
                  _buildSettingItem(
                    icon: Icons.link_outlined,
                    title: '소셜 계정 연동',
                    subtitle: '여러 로그인 방법을 하나로 관리',
                    onTap: () => context.push('/settings/social-accounts')),
                  _buildSettingItem(
                    icon: Icons.phone_outlined,
                    title: '전화번호 관리',
                    subtitle: '전화번호 변경 및 인증',
                    onTap: () => context.push('/settings/phone-management')),
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                    subtitle: '푸시, 문자, 운세 알림 관리',
                    onTap: () => context.push('/settings/notifications'),
                    isLast: true)])),
            
            // 앱 설정 섹션
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '앱 설정',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.dark_mode_outlined,
                    title: '다크 모드',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light);
                      },
                      activeColor: TossDesignSystem.tossBlue),
                    isFirst: true),
                  _buildSettingItem(
                    icon: Icons.language_outlined,
                    title: '언어',
                    subtitle: '한국어',
                    onTap: () {
                      // TODO: Implement language selection
                    },
                    isLast: true)])),
            
            // 결제 섹션
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '결제',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.local_offer_outlined,
                    title: '토큰 구매',
                    subtitle: '토큰 충전하기',
                    onTap: () => context.go('/payment/tokens'),
                    isFirst: true),
                  _buildSettingItem(
                    icon: Icons.card_membership_outlined,
                    title: '구독 관리',
                    subtitle: tokenState.hasUnlimitedAccess ? '프리미엄 구독 중' : '프리미엄 시작하기',
                    showBadge: tokenState.hasUnlimitedAccess,
                    onTap: () => context.go('/subscription'),
                    isLast: true),
                ],
              ),
            ),
            
            // 지원 섹션
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '지원',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: '도움말',
                    onTap: () => context.push('/help'),
                    isFirst: true),
                  _buildSettingItem(
                    icon: Icons.privacy_tip_outlined,
                    title: '개인정보 처리방침',
                    onTap: () => context.push('/policy/privacy')),
                  _buildSettingItem(
                    icon: Icons.description_outlined,
                    title: '이용약관',
                    onTap: () => context.push('/policy/terms'),
                    isLast: true),
                ],
              ),
            ),
            
            // 개발자 도구 (개발 환경에서만 표시)
            if (kDebugMode) ...[
              const SizedBox(height: 32),
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.developer_mode,
                            size: 20,
                            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '개발자 도구',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSettingItem(
                      icon: Icons.cloud_download_outlined,
                      title: '유명인 정보 크롤링',
                      onTap: () => context.push('/admin/celebrity-crawling'),
                      isFirst: true,
                      isLast: true),
                  ],
                ),
              ),
            ),
            ],
            
            // 로그아웃
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('로그아웃'),
                        content: const Text('정말 로그아웃 하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              '로그아웃',
                              style: TextStyle(color: theme.colorScheme.error))),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            
            // 버전 정보
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Fortune v1.0.0',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  fontSize: 12)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showBadge = false,
    Widget? trailing,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast ? const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16)) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast ? BorderSide.none : BorderSide(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
              width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(icon),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: _getIconColor(icon),
                size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                          fontWeight: FontWeight.w500)),
                      if (showBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.tossBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600)),
                  ],
                ],
              ),
            ),
            trailing ?? (onTap != null ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600) : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
  
  Color _getIconBackgroundColor(IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (icon == Icons.person_outline || icon == Icons.link_outlined) {
      return isDark ? TossDesignSystem.tossBlue.withValues(alpha: 0.3) : TossDesignSystem.tossBlue.withValues(alpha: 0.1);
    } else if (icon == Icons.phone_outlined || icon == Icons.notifications_outlined) {
      return isDark ? TossDesignSystem.successGreen.withValues(alpha: 0.3) : TossDesignSystem.successGreen.withValues(alpha: 0.1);
    } else if (icon == Icons.history_outlined || icon == Icons.dark_mode_outlined) {
      return isDark ? TossDesignSystem.tossBlue.withValues(alpha: 0.2) : TossDesignSystem.gray200;
    } else if (icon == Icons.language_outlined || icon == Icons.local_offer_outlined) {
      return isDark ? TossDesignSystem.warningOrange.withValues(alpha: 0.3) : TossDesignSystem.warningOrange.withValues(alpha: 0.1);
    } else if (icon == Icons.card_membership_outlined) {
      return isDark ? TossDesignSystem.errorRed.withValues(alpha: 0.3) : TossDesignSystem.errorRed.withValues(alpha: 0.1);
    } else {
      return isDark ? TossDesignSystem.grayDark300.withValues(alpha: 0.3) : TossDesignSystem.gray200;
    }
  }
  
  Color _getIconColor(IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (icon == Icons.person_outline || icon == Icons.link_outlined) {
      return isDark ? TossDesignSystem.tossBlue : TossDesignSystem.tossBlue;
    } else if (icon == Icons.phone_outlined || icon == Icons.notifications_outlined) {
      return isDark ? TossDesignSystem.successGreen : TossDesignSystem.successGreen;
    } else if (icon == Icons.history_outlined || icon == Icons.dark_mode_outlined) {
      return isDark ? TossDesignSystem.gray600 : TossDesignSystem.gray700;
    } else if (icon == Icons.language_outlined || icon == Icons.local_offer_outlined) {
      return isDark ? TossDesignSystem.warningOrange : TossDesignSystem.warningOrange;
    } else if (icon == Icons.card_membership_outlined) {
      return isDark ? TossDesignSystem.errorRed : TossDesignSystem.errorRed;
    } else {
      return isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600;
    }
  }
  
  Widget _buildDivider() {
    return const SizedBox.shrink();
  }
}