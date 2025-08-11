import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../services/social_auth_service.dart';
import '../../presentation/widgets/social_accounts_section.dart';

class SocialAccountsScreen extends ConsumerStatefulWidget {
  const SocialAccountsScreen({super.key});

  @override
  ConsumerState<SocialAccountsScreen> createState() => _SocialAccountsScreenState();
}

class _SocialAccountsScreenState extends ConsumerState<SocialAccountsScreen> {
  final supabase = Supabase.instance.client;
  late final SocialAuthService _socialAuthService;
  bool isLoading = true;
  Map<String, dynamic>? userProfile;
  List<UserIdentity> userIdentities = [];

  @override
  void initState() {
    super.initState();
    _socialAuthService = SocialAuthService(supabase);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profileResponse = await supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      userIdentities = user.identities ?? [];

      setState(() {
        userProfile = profileResponse;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getProviderName(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      case 'kakao':
        return 'Kakao';
      case 'naver':
        return 'Naver';
      case 'facebook':
        return 'Facebook';
      case 'instagram':
        return 'Instagram';
      case 'tiktok':
        return 'TikTok';
      case 'phone':
        return '전화번호';
      default:
        return provider;
    }
  }

  IconData _getProviderIcon(String provider) {
    switch (provider) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'facebook':
        return Icons.facebook;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.account_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop()),
        title: Text(
          '소셜 계정 연동',
          style: theme.textTheme.titleLarge)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: AppSpacing.paddingAll16,
                    padding: AppSpacing.paddingAll16,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: AppDimensions.borderRadiusMedium),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: AppDimensions.iconSizeMedium),
                        SizedBox(width: AppSpacing.spacing3),
                        Expanded(
                          child: Text(
                            '여러 소셜 계정을 연동하면 어떤 방법으로든 로그인할 수 있습니다.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5))]),
                  if (userIdentities.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        '연동된 계정',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                    ...userIdentities.map(
                      (identity) => _buildConnectedAccount(
                        provider: identity.provider ?? '',
                        email: identity.identityData?['email'] ?? '',
                        isPrimary:
                            userProfile?['primary_provider']))],
                  if (userProfile?['phone'] != null &&
                      userProfile!['phone'].toString().isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        '전화번호',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                    _buildConnectedAccount(
                      provider: 'phone',
                      email: userProfile!['phone'],
                      isPrimary: false,
                      isPhone: true)],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                    child: Text(
                      '연동 가능한 계정',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold)),
                  Padding(
                    padding: AppSpacing.paddingHorizontal16,
                    child: SocialAccountsSection(
                      linkedProviders:
                          userIdentities.map((identity) => identity.provider).toList(),
                      primaryProvider:
                          userIdentities.isNotEmpty ? userIdentities.first.provider : null,
                      onProvidersChanged: (providers) {
                        _loadUserData();
                      },
                      socialAuthService: _socialAuthService)),
                  SizedBox(height: AppSpacing.spacing8)])));
  }

  Widget _buildConnectedAccount({
    required String provider,
    required String email,
    required bool isPrimary,
    bool isPhone = false}) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing4,
        vertical: AppSpacing.spacing1),
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: AppColors.textPrimaryDark,
        borderRadius: AppDimensions.borderRadiusMedium,
        border: Border.all(
          color: isPrimary ? AppColors.primary : AppColors.divider,
          width: isPrimary ? 2 : 1)),
      child: Row(
        children: [
          Container(
            width: AppDimensions.buttonHeightSmall,
            height: AppDimensions.buttonHeightSmall,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
            child: Icon(
              _getProviderIcon(provider),
              color: AppColors.textSecondary,
              size: AppDimensions.iconSizeMedium)),
          SizedBox(width: AppSpacing.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProviderName(provider),
                  style: Theme.of(context).textTheme.titleMedium),
                if (email.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.spacing1),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary))]])),
          if (isPrimary)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing2,
                vertical: AppSpacing.spacing1),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppDimensions.borderRadiusMedium),
              child: Text(
                '주 계정',
                style: Theme.of(context).textTheme.labelSmall)),
          if (!isPrimary && userIdentities.length > 1 && !isPhone)
            TextButton(
              onPressed: () => _showUnlinkDialog(provider),
              child: Text(
                '연동 해제',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.error))]);
  }

  void _showUnlinkDialog(String provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 연동 해제'),
        content: Text(
          '${_getProviderName(provider)} 계정 연동을 해제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _unlinkProvider(provider);
            },
            child: const Text('연동 해제'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error)]);
  }

  Future<void> _unlinkProvider(String provider) async {
    try {
      await _socialAuthService.unlinkProvider(provider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정 연동이 해제되었습니다'),
            backgroundColor: AppColors.success));
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', '')
            ),
            backgroundColor: AppColors.error));
      }
    }
  }
}
