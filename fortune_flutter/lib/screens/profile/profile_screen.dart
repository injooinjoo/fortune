import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/components/app_header.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../services/storage_service.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/providers/token_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/social_auth_service.dart';
import '../../presentation/widgets/social_accounts_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _storageService = StorageService();
  late final SocialAuthService _socialAuthService;
  Map<String, dynamic>? userProfile;
  Map<String, dynamic>? localProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _socialAuthService = SocialAuthService(supabase);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Load from local storage first
      localProfile = await _storageService.getUserProfile();
      debugPrint('Local profile: $localProfile');
      
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        debugPrint('Supabase profile: $response');
        
        if (mounted) {
          setState(() {
            userProfile = response;
            isLoading = false;
          });
        }
      } else {
        // Guest user - use local profile only
        if (mounted) {
          setState(() {
            userProfile = localProfile;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final theme = Theme.of(context);
    final tokenState = ref.watch(tokenProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: '프로필',
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Header Card
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      _buildProfileImage(),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile?['name'] ?? localProfile?['name'] ?? '사용자',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '게스트 사용자',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tokenState.hasUnlimitedAccess
                                        ? AppColors.primary.withValues(alpha: 0.1)
                                        : theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tokenState.hasUnlimitedAccess ? '프리미엄' : '무료',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: tokenState.hasUnlimitedAccess
                                          ? AppColors.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subscription Status Card
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '구독 현황',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (tokenState.hasUnlimitedAccess)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '무제한',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '보유 토큰',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tokenState.balance?.remainingTokens ?? 0}개',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (tokenState.subscription?.isActive == true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '다음 갱신일',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tokenState.subscription?.endDate != null
                                      ? DateFormat('yyyy.MM.dd').format(tokenState.subscription!.endDate!)
                                      : '-',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // User Details Card
                if (userProfile != null || localProfile != null) ...[  
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '내 정보',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('생년월일', _formatBirthDate(userProfile?['birth_date'] ?? localProfile?['birth_date'])),
                        const SizedBox(height: 12),
                        _buildInfoRow('성별', _formatGender(userProfile?['gender'] ?? localProfile?['gender'])),
                        const SizedBox(height: 12),
                        _buildInfoRow('MBTI', userProfile?['mbti'] ?? localProfile?['mbti'] ?? '미설정'),
                        const SizedBox(height: 12),
                        _buildInfoRow('태어난 시간', userProfile?['birth_time'] ?? localProfile?['birth_time'] ?? '미설정'),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                
                // Settings Section
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '설정',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '다크 모드',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              ref.read(themeModeProvider.notifier).setThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Social Accounts Section
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: SocialAccountsSection(
                    linkedProviders: userProfile?['linked_providers'] != null
                        ? List<String>.from(userProfile!['linked_providers'])
                        : localProfile?['linked_providers'] != null
                            ? List<String>.from(localProfile!['linked_providers'])
                            : null,
                    primaryProvider: userProfile?['primary_provider'] ?? localProfile?['primary_provider'],
                    socialAuthService: _socialAuthService,
                    onProvidersChanged: (providers) async {
                      // Update profile with new linked providers
                      final updates = {
                        'linked_providers': providers,
                        'updated_at': DateTime.now().toIso8601String(),
                      };
                      
                      if (user != null) {
                        try {
                          await supabase
                              .from('user_profiles')
                              .update(updates)
                              .eq('id', user.id);
                        } catch (e) {
                          debugPrint('Error updating linked providers: $e');
                        }
                      }
                      
                      // Update local state
                      setState(() {
                        if (userProfile != null) {
                          userProfile!['linked_providers'] = providers;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Menu Items
                Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.edit_outlined,
                      title: '프로필 편집',
                      subtitle: '개인정보 수정',
                      onTap: () {
                        context.push('/profile/edit');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: '알림 설정',
                      subtitle: '알림 관리',
                      onTap: () {
                        context.push('/settings/notifications');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.history_outlined,
                      title: '운세 기록',
                      subtitle: '지난 운세 보기',
                      onTap: () {
                        context.push('/fortune/history');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.local_offer_outlined,
                      title: '토큰 구매',
                      subtitle: '토큰 충전하기',
                      onTap: () => context.go('/payment/tokens'),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.card_membership_outlined,
                      title: '구독 관리',
                      subtitle: tokenState.hasUnlimitedAccess ? '프리미엄 구독 중' : '프리미엄 시작하기',
                      showBadge: tokenState.hasUnlimitedAccess,
                      onTap: () => context.go('/subscription'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Logout Link
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('로그아웃'),
                          content: const Text('정말 로그아웃 하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('로그아웃'),
                            ),
                          ],
                        ),
                      );
                      
                      if (shouldLogout == true) {
                        await supabase.auth.signOut();
                        if (mounted) {
                          context.go('/');
                        }
                      }
                    },
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final theme = Theme.of(context);
    final profileImageUrl = userProfile?['profile_image_url'] ?? localProfile?['profile_image_url'];
    
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            profileImageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Default profile icon
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  String _formatBirthDate(String? birthDate) {
    if (birthDate == null) return '미설정';
    try {
      final date = DateTime.parse(birthDate);
      return DateFormat('yyyy년 MM월 dd일').format(date);
    } catch (e) {
      return birthDate;
    }
  }
  
  String _formatGender(String? gender) {
    switch (gender) {
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      case 'other':
        return '기타';
      default:
        return '미설정';
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool showBadge = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
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
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}