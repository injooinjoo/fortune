import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/providers/token_provider.dart';
import '../../services/storage_service.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

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
    
    final fortuneTheme = context.fortuneTheme;
    
    return Scaffold(
      backgroundColor: AppColors.getCardBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '설정',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // 계정 섹션
            SizedBox(height: AppSpacing.spacing6),
            Container(
              margin: AppSpacing.paddingHorizontal16,
              decoration: BoxDecoration(
                color: fortuneTheme.cardSurface,
                borderRadius: AppDimensions.borderRadiusLarge,
        boxShadow: [
                  BoxShadow(
                    color: fortuneTheme.shadowColor.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                    padding: AppSpacing.paddingAll20,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '계정',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: '프로필 편집',
                    onTap: () => context.push('/profile/edit'),
                    isFirst: true,
                  ),
                  _buildSettingItem(
                    icon: Icons.link_outlined,
                    title: '소셜 계정 연동',
                    subtitle: '여러 로그인 방법을 하나로 관리',
                    onTap: () => context.push('/settings/social-accounts'),
                  _buildSettingItem(
                    icon: Icons.phone_outlined,
                    title: '전화번호 관리',
                    subtitle: '전화번호 변경 및 인증',
                    onTap: () => context.push('/settings/phone'),
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                    subtitle: '푸시, 문자, 운세 알림 관리',
                    onTap: () => context.push('/settings/notifications'),
                  _buildSettingItem(
                    icon: Icons.history_outlined,
                    title: '운세 기록',
                    subtitle: '지난 운세 보기',
                    onTap: () => context.push('/fortune/history'),
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            // 앱 설정 섹션
            SizedBox(height: AppSpacing.spacing6),
            Container(
              margin: AppSpacing.paddingHorizontal16,
              decoration: BoxDecoration(
                color: fortuneTheme.cardSurface,
                borderRadius: AppDimensions.borderRadiusLarge,
        boxShadow: [
                  BoxShadow(
                    color: fortuneTheme.shadowColor.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                    padding: AppSpacing.paddingAll20,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '앱 설정',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                      activeColor: AppColors.primary,
                    ),
                    isFirst: true),
                  _buildSettingItem(
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
            SizedBox(height: AppSpacing.spacing6),
            Container(
              margin: AppSpacing.paddingHorizontal16,
              decoration: BoxDecoration(
                color: fortuneTheme.cardSurface,
                borderRadius: AppDimensions.borderRadiusLarge,
        boxShadow: [
                  BoxShadow(
                    color: fortuneTheme.shadowColor.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                    padding: AppSpacing.paddingAll20,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '결제',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                    title: '구독 관리'),
        subtitle: tokenState.hasUnlimitedAccess ? '프리미엄 구독 중' : '프리미엄 시작하기',
      showBadge: tokenState.hasUnlimitedAccess),
        onTap: () => context.go('/subscription'),
                    isLast: true)])
            
            // 지원 섹션
            SizedBox(height: AppSpacing.spacing6),
            Container(
              margin: AppSpacing.paddingHorizontal16,
              decoration: BoxDecoration(
                color: fortuneTheme.cardSurface,
                borderRadius: AppDimensions.borderRadiusLarge,
        boxShadow: [
                  BoxShadow(
                    color: fortuneTheme.shadowColor.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                    padding: AppSpacing.paddingAll20,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '지원',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.help_outline),
        title: '도움말',
                    onTap: () => context.push('/help'),
                    isFirst: true),
                  _buildSettingItem(
                    icon: Icons.privacy_tip_outlined),
        title: '개인정보 처리방침',
                    onTap: () => context.push('/policy/privacy'),
                  _buildSettingItem(
                    icon: Icons.description_outlined),
        title: '이용약관',
                    onTap: () => context.push('/policy/terms'),
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            // 로그아웃
            SizedBox(height: AppSpacing.spacing8),
            Padding(
              padding: AppSpacing.paddingHorizontal16),
        child: SizedBox(,
      width: double.infinity),
              child: OutlinedButton(,
      onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(,
      title: const Text('로그아웃'),
                        content: const Text('정말 로그아웃 하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소')
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              '로그아웃',
                          style: AppTypography.button))])
                    
                    if (shouldLogout == true) {
                      await supabase.auth.signOut();
                      if (mounted) {
                        context.go('/');
                      }
                    }
                  }
                  style: OutlinedButton.styleFrom(
                    padding: AppSpacing.paddingVertical16,
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    '로그아웃',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ))
            
            // 버전 정보
            SizedBox(height: AppSpacing.spacing6),
            Center(
              child: Text(
                'Fortune v1.0.0',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            SizedBox(height: AppSpacing.spacing8)));
  }
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showBadge = false,
    Widget? trailing,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            )
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing5,
          vertical: AppSpacing.spacing4,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : const BorderSide(
                    color: AppColors.divider,
                    width: 1,
                  ),
          ),
        ),
      child: Row(
          children: [
            Container(
width: AppDimensions.buttonHeightSmall,
              height: AppDimensions.buttonHeightSmall,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(icon),
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
              child: Icon(
                icon,
                color: _getIconColor(icon),
                size: 22,
              ),
            SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      if (showBadge) ...[
                        SizedBox(width: AppSpacing.spacing2),
                        Container(
                          padding: EdgeInsets.symmetric(,
      horizontal: AppSpacing.spacing1 * 1.5,
              ),
              vertical: AppSpacing.spacing0 * 0.5),
                          decoration: BoxDecoration(,
      color: AppColors.primary,
        ),
        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXxSmall),
      child: Text(
                            'PRO'),
        style: context.captionMedium))
                    ])
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xxxSmall),
                    Text(
                      subtitle),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: AppColors.textSecondary,
                          ))
                ])))
            trailing ??
            (onTap != null
                ? const Icon(
                    Icons.arrow_forward_ios,
                    size: AppDimensions.iconSizeXSmall,
                    color: AppColors.textSecondary,
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
    );
  }
  
  Color _getIconBackgroundColor(IconData icon) {
    if (icon == Icons.person_outline || icon == Icons.link_outlined) {
      return AppColors.primary.withValues(alpha: 0.2);
    } else if (icon == Icons.phone_outlined || icon == Icons.notifications_outlined) {
      return AppColors.success.withValues(alpha: 0.2);
    } else if (icon == Icons.history_outlined || icon == Icons.dark_mode_outlined) {
      return Colors.purple.withValues(alpha: 0.2);
    } else if (icon == Icons.language_outlined || icon == Icons.local_offer_outlined) {
      return AppColors.warning.withValues(alpha: 0.2);
    } else if (icon == Icons.card_membership_outlined) {
      return AppColors.error.withValues(alpha: 0.2);
    } else {
      return AppColors.textSecondary.withValues(alpha: 0.2);
    }
  }
  
  Color _getIconColor(IconData icon) {
    if (icon == Icons.person_outline || icon == Icons.link_outlined) {
      return AppColors.primary.withValues(alpha: 0.9);
    } else if (icon == Icons.phone_outlined || icon == Icons.notifications_outlined) {
      return AppColors.success.withValues(alpha: 0.9);
    } else if (icon == Icons.history_outlined || icon == Icons.dark_mode_outlined) {
      return Colors.purple.withValues(alpha: 0.9);
    } else if (icon == Icons.language_outlined || icon == Icons.local_offer_outlined) {
      return AppColors.warning.withValues(alpha: 0.9);
    } else if (icon == Icons.card_membership_outlined) {
      return AppColors.error.withValues(alpha: 0.9);
    } else {
      return AppColors.textSecondary.withValues(alpha: 0.9);
    }
  }
  
  Widget _buildDivider() {
    return const SizedBox.shrink();
  }
}