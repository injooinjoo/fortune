import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
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
    
    final fortuneTheme = context.fortuneTheme;
    
    return Scaffold(
      backgroundColor: AppColors.getCardBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: fortuneTheme.primaryText),
          onPressed: () => context.pop()),
        title: Text(
          '설정',
          style: TextStyle(
            color: fortuneTheme.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 계정 섹션
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: fortuneTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: fortuneTheme.shadowColor.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16))),
                    child: Row(
                      children: [
                        Text(
                          '계정',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20))])),
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
                    onTap: () => context.push('/settings/notifications')),
                  _buildSettingItem(
                    icon: Icons.history_outlined,
                    title: '운세 기록',
                    subtitle: '지난 운세 보기',
                    onTap: () => context.push('/fortune/history'),
                    isLast: true)])),
            
            // 앱 설정 섹션
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: fortuneTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: fortuneTheme.shadowColor.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16))),
                    child: Row(
                      children: [
                        Text(
                          '앱 설정',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20))])),
                  _buildSettingItem(
                    icon: Icons.dark_mode_outlined,
                    title: '다크 모드',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light);
                      },
                      activeColor: AppColors.primary),
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
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: fortuneTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: fortuneTheme.shadowColor.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16))),
                    child: Row(
                      children: [
                        Text(
                          '결제',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20))])),
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
                    isLast: true)])),
            
            // 지원 섹션
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: fortuneTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: fortuneTheme.shadowColor.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16))),
                    child: Row(
                      children: [
                        Text(
                          '지원',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20))])),
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
                    isLast: true)])),
            
            // 로그아웃
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              style: TextStyle(color: theme.colorScheme.error)))]));
                    
                    if (shouldLogout == true) {
                      await supabase.auth.signOut();
                      if (mounted) {
                        context.go('/');
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600))))),
            
            // 버전 정보
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Fortune v1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12))),
            const SizedBox(height: 32)])));
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
            bottom: isLast ? BorderSide.none : const BorderSide(
              color: AppColors.divider,
              width: 1))),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(icon),
                borderRadius: BorderRadius.circular(8)),
              child: Icon(
                icon,
                color: _getIconColor(icon),
                size: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500)),
                      if (showBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4)),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)))]]),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary))]])),
            trailing ?? (onTap != null ? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary) : const SizedBox.shrink())])));
  }
  
  Color _getIconBackgroundColor(IconData icon) {
    if (icon == Icons.person_outline || icon == Icons.link_outlined) {
      return Colors.blue.shade100;
    } else if (icon == Icons.phone_outlined || icon == Icons.notifications_outlined) {
      return Colors.green.shade100;
    } else if (icon == Icons.history_outlined || icon == Icons.dark_mode_outlined) {
      return Colors.purple.shade100;
    } else if (icon == Icons.language_outlined || icon == Icons.local_offer_outlined) {
      return Colors.orange.shade100;
    } else if (icon == Icons.card_membership_outlined) {
      return Colors.red.shade100;
    } else {
      return Colors.grey.shade100;
    }
  }
  
  Color _getIconColor(IconData icon) {
    if (icon == Icons.person_outline || icon == Icons.link_outlined) {
      return Colors.blue.shade700;
    } else if (icon == Icons.phone_outlined || icon == Icons.notifications_outlined) {
      return Colors.green.shade700;
    } else if (icon == Icons.history_outlined || icon == Icons.dark_mode_outlined) {
      return Colors.purple.shade700;
    } else if (icon == Icons.language_outlined || icon == Icons.local_offer_outlined) {
      return Colors.orange.shade700;
    } else if (icon == Icons.card_membership_outlined) {
      return Colors.red.shade700;
    } else {
      return Colors.grey.shade700;
    }
  }
  
  Widget _buildDivider() {
    return const SizedBox.shrink();
  }
}