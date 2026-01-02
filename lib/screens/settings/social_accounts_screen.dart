import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/providers/user_settings_provider.dart';
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

  String? _getProviderAsset(String provider) {
    switch (provider) {
      case 'google':
        return 'assets/images/social/google.svg';
      case 'apple':
        return 'assets/images/social/apple.svg';
      case 'kakao':
        return 'assets/images/social/kakao.svg';
      case 'naver':
        return 'assets/images/social/naver.svg';
      default:
        return null;
    }
  }

  Widget _buildProviderIcon(String provider, dynamic colors) {
    final assetPath = _getProviderAsset(provider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (assetPath != null) {
      final isApple = provider == 'apple';
      return SvgPicture.asset(
        assetPath,
        width: 22,
        height: 22,
        colorFilter: isApple
            ? ColorFilter.mode(
                isDark ? Colors.white : Colors.black,
                BlendMode.srcIn,
              )
            : null,
      );
    }

    // Fallback for phone and other providers
    IconData icon;
    switch (provider) {
      case 'facebook':
        icon = Icons.facebook;
        break;
      case 'phone':
        icon = Icons.phone;
        break;
      default:
        icon = Icons.account_circle;
    }
    return Icon(icon, size: 22, color: colors.textSecondary);
  }

  Widget _buildSectionHeader(String title) {
    final colors = context.colors;
    final typography = ref.watch(typographyThemeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.pageHorizontal,
        DSSpacing.lg,
        DSSpacing.pageHorizontal,
        DSSpacing.sm,
      ),
      child: Text(
        title,
        style: typography.labelSmall.copyWith(
          color: colors.textSecondary,
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
    final colors = context.colors;
    final typography = ref.watch(typographyThemeProvider);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.pageHorizontal,
        vertical: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : colors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          _buildProviderIcon(provider, colors),
          const SizedBox(width: DSSpacing.md),

          // 제목 & 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProviderName(provider),
                  style: typography.bodySmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
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
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '주 계정',
                style: typography.labelSmall.copyWith(
                  color: colors.accent,
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
                style: typography.labelSmall.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showUnlinkDialog(String provider) {
    final colors = context.colors;
    final typography = ref.watch(typographyThemeProvider);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '계정 연동 해제',
          style: typography.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          '${_getProviderName(provider)} 계정 연동을 해제하시겠습니까?',
          style: typography.bodySmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              '취소',
              style: typography.buttonMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _unlinkProvider(provider);
            },
            child: Text(
              '연동 해제',
              style: typography.buttonMedium.copyWith(
                color: colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlinkProvider(String provider) async {
    final colors = context.colors;
    try {
      await _socialAuthService.unlinkProvider(provider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('계정 연동이 해제되었습니다'),
            backgroundColor: colors.success,
          ),
        );
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = ref.watch(typographyThemeProvider);

    if (isLoading) {
      return Scaffold(
        backgroundColor: colors.backgroundSecondary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            '소셜 계정 연동',
            style: typography.headingSmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: colors.accent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '소셜 계정 연동',
          style: typography.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DSSpacing.md),

              // 안내 메시지
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.pageHorizontal),
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Expanded(
                        child: Text(
                          '여러 소셜 계정을 연동하면 어떤 방법으로든 로그인할 수 있습니다.',
                          style: typography.labelSmall.copyWith(
                            color: colors.accent,
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
                      horizontal: DSSpacing.pageHorizontal),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: colors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.textPrimary.withValues(alpha: 0.04),
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
                    horizontal: DSSpacing.pageHorizontal),
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

              const SizedBox(height: DSSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
