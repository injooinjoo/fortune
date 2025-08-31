import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/toss_design_system.dart';
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
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '소셜 계정 연동',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TossDesignSystem.tossBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: TossDesignSystem.tossBlue,
                          size: 24.0),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            '여러 소셜 계정을 연동하면 어떤 방법으로든 로그인할 수 있습니다.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (userIdentities.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        '연동된 계정',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...userIdentities.map(
                      (identity) => _buildConnectedAccount(
                        provider: identity.provider ?? '',
                        email: identity.identityData?['email'] ?? '',
                        isPrimary: identity.provider == 
                            userProfile?['primary_provider'],
                      ),
                    ).toList(),
                  ],
                  if (userProfile?['phone'] != null &&
                      userProfile!['phone'].toString().isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        '전화번호',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildConnectedAccount(
                      provider: 'phone',
                      email: userProfile!['phone'],
                      isPrimary: false,
                      isPhone: true,
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                    child: Text(
                      '연동 가능한 계정',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SocialAccountsSection(
                      linkedProviders:
                          userIdentities.map((identity) => identity.provider).toList(),
                      primaryProvider:
                          userIdentities.isNotEmpty ? userIdentities.first.provider : null,
                      onProvidersChanged: (providers) {
                        _loadUserData();
                      },
                      socialAuthService: _socialAuthService,
                    ),
                  ),
                  SizedBox(height: 32.0),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectedAccount({
    required String provider,
    required String email,
    required bool isPrimary,
    bool isPhone = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? TossDesignSystem.tossBlue : Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(20.0)),
            child: Icon(
              _getProviderIcon(provider),
              color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
              size: 24.0,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProviderName(provider),
                  style: Theme.of(context).textTheme.titleMedium),
                if (email.isNotEmpty) ...[
                  SizedBox(height: 4.0),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isPrimary)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0),
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue,
                borderRadius: BorderRadius.circular(12)),
              child: Text(
                '주 계정',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          if (!isPrimary && userIdentities.length > 1 && !isPhone)
            TextButton(
              onPressed: () => _showUnlinkDialog(provider),
              child: Text(
                '연동 해제',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: TossDesignSystem.errorRed),
              ),
            ),
        ],
      ),
    );
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
              foregroundColor: TossDesignSystem.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlinkProvider(String provider) async {
    try {
      await _socialAuthService.unlinkProvider(provider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정 연동이 해제되었습니다'),
            backgroundColor: TossDesignSystem.successGreen));
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', '')
            ),
            backgroundColor: TossDesignSystem.errorRed));
      }
    }
  }
}
