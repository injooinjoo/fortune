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

      if (mounted) {
        setState(() {
          userProfile = profileResponse;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      case 'kakao':
        return Icons.chat_bubble;
      case 'naver':
        return Icons.web;
      default:
        return Icons.account_circle;
    }
  }

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

  Widget _buildConnectedAccount({
    required String provider,
    required String email,
    required bool isPrimary,
    bool isPhone = false,
    bool isLast = false,
  }) {
    return Container(
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
          // 아이콘
          Icon(
            _getProviderIcon(provider),
            size: 22,
            color: _getSecondaryTextColor(context),
          ),
          const SizedBox(width: TossDesignSystem.spacingM),

          // 제목 & 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProviderName(provider),
                  style: TossDesignSystem.body2.copyWith(
                    color: _getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TossDesignSystem.caption.copyWith(
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 주 계정 배지 또는 연동 해제 버튼
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '주 계정',
                style: TossDesignSystem.caption.copyWith(
                  color: TossDesignSystem.tossBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (!isPrimary && userIdentities.length > 1 && !isPhone)
            TextButton(
              onPressed: () => _showUnlinkDialog(provider),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 32),
              ),
              child: Text(
                '해제',
                style: TossDesignSystem.caption.copyWith(
                  color: TossDesignSystem.errorRed,
                  fontWeight: FontWeight.w600,
                ),
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
        title: Text(
          '계정 연동 해제',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
        content: Text(
          '${_getProviderName(provider)} 계정 연동을 해제하시겠습니까?',
          style: TossDesignSystem.body2.copyWith(
            color: _getTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TossDesignSystem.button.copyWith(
                color: _getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _unlinkProvider(provider);
            },
            child: Text(
              '연동 해제',
              style: TossDesignSystem.button.copyWith(
                color: TossDesignSystem.errorRed,
              ),
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
          SnackBar(
            content: Text(
              '계정 연동이 해제되었습니다',
              style: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.white,
              ),
            ),
            backgroundColor: TossDesignSystem.successGreen,
          ),
        );
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.white,
              ),
            ),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _getTextColor(context)),
            onPressed: () => context.pop(),
          ),
          title: Text(
            '소셜 계정 연동',
            style: TossDesignSystem.heading4.copyWith(
              color: _getTextColor(context),
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: TossDesignSystem.tossBlue,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _getTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '소셜 계정 연동',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TossDesignSystem.spacingM),

              // 안내 메시지
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.marginHorizontal),
                child: Container(
                  padding: const EdgeInsets.all(TossDesignSystem.spacingM),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: TossDesignSystem.tossBlue,
                        size: 20,
                      ),
                      const SizedBox(width: TossDesignSystem.spacingS),
                      Expanded(
                        child: Text(
                          '여러 소셜 계정을 연동하면 어떤 방법으로든 로그인할 수 있습니다.',
                          style: TossDesignSystem.caption.copyWith(
                            color: TossDesignSystem.tossBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 연동된 계정
              if (userIdentities.isNotEmpty) ...[
                _buildSectionHeader('연동된 계정'),
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
                      for (int i = 0; i < userIdentities.length; i++)
                        _buildConnectedAccount(
                          provider: userIdentities[i].provider,
                          email: userIdentities[i].identityData?['email'] ?? '',
                          isPrimary: userIdentities[i].provider ==
                              userProfile?['primary_provider'],
                          isLast: i == userIdentities.length - 1 &&
                              (userProfile?['phone'] == null ||
                                  userProfile!['phone'].toString().isEmpty),
                        ),
                      if (userProfile?['phone'] != null &&
                          userProfile!['phone'].toString().isNotEmpty)
                        _buildConnectedAccount(
                          provider: 'phone',
                          email: userProfile!['phone'],
                          isPrimary: false,
                          isPhone: true,
                          isLast: true,
                        ),
                    ],
                  ),
                ),
              ],

              // 연동 가능한 계정
              _buildSectionHeader('연동 가능한 계정'),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.marginHorizontal),
                child: SocialAccountsSection(
                  linkedProviders: userIdentities
                      .map((identity) => identity.provider)
                      .toList(),
                  primaryProvider: userIdentities.isNotEmpty
                      ? userIdentities.first.provider
                      : null,
                  onProvidersChanged: (providers) {
                    _loadUserData();
                  },
                  socialAuthService: _socialAuthService,
                ),
              ),

              const SizedBox(height: TossDesignSystem.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }
}
