import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../core/theme/toss_design_system.dart';
import '../../services/social_auth_service.dart';
import '../../data/services/fortune_api_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../data/models/user_profile.dart';
import '../../presentation/providers/navigation_visibility_provider.dart';

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
  Map<String, dynamic>? userStats;
  List<int> fortuneScores = [];
  bool isLoading = true;
  bool isLoadingHistory = false;

  // Scroll controller and variables for navigation bar hiding
  late ScrollController _scrollController;
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;

  // TOSS Design System Helper Methods
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
        ? TossDesignSystem.grayDark900
        : TossDesignSystem.white;
  }

  Color _getDividerColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray200;
  }

  // Helper methods
  String _formatProfileSubtitle() {
    final profile = userProfile ?? localProfile;
    if (profile == null) return '';

    final birthDate = profile['birth_date'] as String?;
    final gender = profile['gender'] as String?;

    final parts = <String>[];

    if (birthDate != null && birthDate.isNotEmpty) {
      try {
        final date = DateTime.parse(birthDate);
        parts.add('${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}');
      } catch (e) {
        // 파싱 실패 시 무시
      }
    }

    if (gender != null) {
      switch (gender) {
        case 'male':
          parts.add('남성');
          break;
        case 'female':
          parts.add('여성');
          break;
        case 'other':
          parts.add('선택 안함');
          break;
      }
    }

    return parts.join(' · ');
  }

  // Minimal List Components (스크린샷 스타일)
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

  Widget _buildListItem({
    IconData? icon,
    Widget? leading,
    required String title,
    String? subtitle,
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
              // Leading (아이콘 또는 커스텀 위젯)
              if (icon != null)
                Icon(
                  icon,
                  size: 22,
                  color: _getSecondaryTextColor(context),
                )
              else if (leading != null)
                leading,

              if (icon != null || leading != null)
                const SizedBox(width: TossDesignSystem.spacingM),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TossDesignSystem.body2.copyWith(
                        color: _getTextColor(context),
                      ),
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

              // Trailing
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _socialAuthService = SocialAuthService(supabase);
    
    // Initialize scroll controller with navigation bar hiding logic
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    _loadUserData();
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final currentScrollOffset = _scrollController.offset;
    const scrollThreshold = 10.0; // 매우 민감하게 반응하도록 임계값 감소
    
    // 스크롤 방향 감지
    final scrollDelta = currentScrollOffset - _lastScrollOffset;
    
    // 임계값 이상 스크롤했을 때만 처리
    if (scrollDelta.abs() > scrollThreshold) {
      final isScrollingDown = scrollDelta > 0;
      
      // 방향이 바뀌었거나, 같은 방향으로 계속 스크롤 중일 때
      if (isScrollingDown != _isScrollingDown || scrollDelta.abs() > scrollThreshold) {
        _isScrollingDown = isScrollingDown;
        _lastScrollOffset = currentScrollOffset;
        
        // Update navigation visibility
        final navigationNotifier = ref.read(navigationVisibilityProvider.notifier);
        if (isScrollingDown && currentScrollOffset > 50) {
          // 최소 50픽셀은 스크롤해야 숨김
          navigationNotifier.hide();
        } else if (!isScrollingDown) {
          // 위로 스크롤하면 즉시 보임
          navigationNotifier.show();
        }
      }
    }
    
    // 최상단에 도달하면 항상 네비게이션 표시
    if (currentScrollOffset <= 0) {
      ref.read(navigationVisibilityProvider.notifier).show();
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Load from local storage first
      localProfile = await _storageService.getUserProfile();
      debugPrint('Loaded local profile: ${localProfile != null}');

      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // Load user profile
        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        debugPrint('Loaded local profile: ${localProfile != null}');

        // Load user statistics with error handling for missing table
        Map<String, dynamic>? statsResponse;
        try {
          statsResponse = await supabase
              .from('user_statistics')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
        } catch (e) {
          // Handle missing table error gracefully
          debugPrint('Loaded local profile: ${localProfile != null}');
          if (e.toString().contains('relation "public.user_statistics" does not exist')) {
            debugPrint('user_statistics table not found - using default values');
          }
        }

        if (mounted) {
          setState(() {
            userProfile = response;
            userStats = statsResponse ?? {
              'total_fortunes': 0,
              'consecutive_days': 0,
              'last_login': DateTime.now().toIso8601String(),
              'favorite_fortune_type': null,
              'total_fortunes_viewed': 0,
              'login_count': 0,
              'streak_days': 0,
              'total_tokens_earned': 0,
              'total_tokens_spent': 0,
              'profile_completion_percentage': 0,
              'achievements': [],
            };
            isLoading = false;
          });
        }

        // Load fortune history
        _loadFortuneHistory();
      } else {
        // Guest user - use local profile only
        if (mounted) {
          setState(() {
            userProfile = localProfile;
            userStats = {
              'total_fortunes': 0,
              'consecutive_days': 1,
            };
            isLoading = false;
          });
        }
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

  Future<void> _loadFortuneHistory() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    if (mounted) {
      setState(() {
        isLoadingHistory = true;
      });
    }

    try {
      final fortuneApiService = ref.read(fortuneApiServiceProvider);
      final scores = await fortuneApiService.getUserFortuneHistory(userId: userId);

      if (mounted) {
        setState(() {
          fortuneScores = scores;
          isLoadingHistory = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          isLoadingHistory = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
         MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (isLoading) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(context),
        body: const Center(
          child: CircularProgressIndicator(
            color: TossDesignSystem.tossBlue,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '내 프로필',
          style: TossDesignSystem.heading4.copyWith(
            color: _getTextColor(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: _getSecondaryTextColor(context),
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: _getSecondaryTextColor(context),
            ),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TossDesignSystem.spacingM),

              // 프로필 요약 카드
              if (userProfile != null || localProfile != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                  decoration: BoxDecoration(
                    color: isDarkMode ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                  child: _buildListItem(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: (userProfile ?? localProfile)?['profile_image_url'] != null
                          ? NetworkImage((userProfile ?? localProfile)!['profile_image_url'])
                          : null,
                      child: (userProfile ?? localProfile)?['profile_image_url'] == null
                          ? const Icon(Icons.person, size: 24)
                          : null,
                    ),
                    title: (userProfile ?? localProfile)?['name'] ?? '사용자',
                    subtitle: _formatProfileSubtitle(),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: _getSecondaryTextColor(context),
                    ),
                    onTap: () async {
                      final result = await context.push('/profile/edit');
                      // 프로필 편집 후 돌아왔을 때 업데이트된 경우 프로필 다시 로드
                      if (result == true && mounted) {
                        ref.invalidate(userProfileProvider);
                        setState(() {});
                      }
                    },
                    isLast: true,
                  ),
                ),

              // 테스트 계정 섹션 (간소화)
              FutureBuilder<UserProfile?>(
                future: ref.watch(userProfileProvider.future),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  if (profile != null && profile.isTestAccount) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('테스트 계정'),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                          decoration: BoxDecoration(
                            color: isDarkMode ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                                icon: Icons.bug_report_outlined,
                                title: '무제한 토큰',
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: TossDesignSystem.successGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '활성화',
                                    style: TossDesignSystem.caption.copyWith(
                                      color: TossDesignSystem.successGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              _buildListItem(
                                icon: Icons.star_outline,
                                title: '프리미엄 기능',
                                trailing: Switch(
                                  value: profile.isTestAccount,
                                  onChanged: (value) async {
                                    setState(() {});
                                  },
                                  activeColor: TossDesignSystem.tossBlue,
                                ),
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // 운세 활동 섹션
              _buildSectionHeader('운세 활동'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                decoration: BoxDecoration(
                  color: isDarkMode ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                      icon: Icons.today_outlined,
                      title: '오늘의 운세',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userStats?['today_score'] != null) ...[
                            Text(
                              '${userStats!['today_score']}',
                              style: TossDesignSystem.heading4.copyWith(
                                color: _getTextColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '점',
                              style: TossDesignSystem.body2.copyWith(
                                color: _getSecondaryTextColor(context),
                              ),
                            ),
                          ] else
                            Text(
                              '미확인',
                              style: TossDesignSystem.body2.copyWith(
                                color: _getSecondaryTextColor(context),
                              ),
                            ),
                        ],
                      ),
                      onTap: () => context.push('/fortune/today'),
                    ),
                    _buildListItem(
                      icon: Icons.local_fire_department_outlined,
                      title: '연속 접속일',
                      trailing: Text(
                        '${userStats?['consecutive_days'] ?? 0}일',
                        style: TossDesignSystem.body2.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                    _buildListItem(
                      icon: Icons.visibility_outlined,
                      title: '총 조회수',
                      trailing: Text(
                        '${userStats?['total_fortunes'] ?? 0}회',
                        style: TossDesignSystem.body2.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 정보 섹션
              if (userProfile != null || localProfile != null) ...[
                _buildSectionHeader('정보'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                  decoration: BoxDecoration(
                    color: isDarkMode ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                        icon: Icons.cake_outlined,
                        title: '생년월일',
                        trailing: Text(
                          _formatBirthDate((userProfile ?? localProfile)?['birth_date']),
                          style: TossDesignSystem.body2.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                        onTap: () async {
                      final result = await context.push('/profile/edit');
                      // 프로필 편집 후 돌아왔을 때 업데이트된 경우 프로필 다시 로드
                      if (result == true && mounted) {
                        ref.invalidate(userProfileProvider);
                        setState(() {});
                      }
                    },
                      ),
                      _buildListItem(
                        icon: Icons.access_time_outlined,
                        title: '출생시간',
                        trailing: Text(
                          (userProfile ?? localProfile)?['birth_time'] ?? '미입력',
                          style: TossDesignSystem.body2.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                        onTap: () async {
                      final result = await context.push('/profile/edit');
                      // 프로필 편집 후 돌아왔을 때 업데이트된 경우 프로필 다시 로드
                      if (result == true && mounted) {
                        ref.invalidate(userProfileProvider);
                        setState(() {});
                      }
                    },
                      ),
                      _buildListItem(
                        icon: Icons.pets_outlined,
                        title: '띠',
                        trailing: Text(
                          (userProfile ?? localProfile)?['chinese_zodiac'] ?? '미입력',
                          style: TossDesignSystem.body2.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                      _buildListItem(
                        icon: Icons.stars_outlined,
                        title: '별자리',
                        trailing: Text(
                          (userProfile ?? localProfile)?['zodiac_sign'] ?? '미입력',
                          style: TossDesignSystem.body2.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                      _buildListItem(
                        icon: Icons.water_drop_outlined,
                        title: '혈액형',
                        trailing: Text(
                          (userProfile ?? localProfile)?['blood_type'] != null
                              ? '${(userProfile ?? localProfile)!['blood_type']}형'
                              : '미입력',
                          style: TossDesignSystem.body2.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                        onTap: () async {
                      final result = await context.push('/profile/edit');
                      // 프로필 편집 후 돌아왔을 때 업데이트된 경우 프로필 다시 로드
                      if (result == true && mounted) {
                        ref.invalidate(userProfileProvider);
                        setState(() {});
                      }
                    },
                      ),
                      _buildListItem(
                        icon: Icons.psychology_outlined,
                        title: 'MBTI',
                        trailing: Text(
                          (userProfile ?? localProfile)?['mbti']?.toUpperCase() ?? '미입력',
                          style: TossDesignSystem.body2.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                        onTap: () async {
                      final result = await context.push('/profile/edit');
                      // 프로필 편집 후 돌아왔을 때 업데이트된 경우 프로필 다시 로드
                      if (result == true && mounted) {
                        ref.invalidate(userProfileProvider);
                        setState(() {});
                      }
                    },
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],

              // 사주 & 분석 섹션
              if (userProfile != null || localProfile != null) ...[
                _buildSectionHeader('사주 & 분석'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                  decoration: BoxDecoration(
                    color: isDarkMode ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                        icon: Icons.auto_stories_outlined,
                        title: '사주 정보',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: _getSecondaryTextColor(context),
                        ),
                        onTap: () {
                          context.push('/profile/saju');
                        },
                      ),
                      _buildListItem(
                        icon: Icons.wb_sunny_outlined,
                        title: '오행 분석',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: _getSecondaryTextColor(context),
                        ),
                        onTap: () {
                          context.push('/profile/elements');
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],

              // 도구 섹션
              _buildSectionHeader('도구'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TossDesignSystem.marginHorizontal),
                decoration: BoxDecoration(
                  color: isDarkMode ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
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
                      icon: Icons.share_outlined,
                      title: '친구와 공유',
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _getSecondaryTextColor(context),
                      ),
                      onTap: () async {
                        await _inviteFriend();
                      },
                    ),
                    _buildListItem(
                      icon: Icons.verified_outlined,
                      title: '프로필 인증',
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _getSecondaryTextColor(context),
                      ),
                      onTap: () => context.push('/profile/verification'),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TossDesignSystem.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return '미입력';

    try {
      final date = DateTime.parse(birthDate);
      return '${date.year}년 ${date.month}월 ${date.day}일';
    } catch (e) {
      return '미입력';
    }
  }

  Future<void> _inviteFriend() async {
    final currentUser = supabase.auth.currentUser;
    final appStoreUrl = 'https://apps.apple.com/app/fortune';
    final playStoreUrl = 'https://play.google.com/store/apps/details?id=com.beyond.fortune';
    final inviteCode = currentUser?.id?.substring(0, 8) ?? 'FORTUNE2024';

    final shareText = '''🔮 Fortune - 오늘의 운세 앱 초대

안녕하세요! 저는 Fortune 앱으로 매일 운세를 확인하고 있어요.
당신도 함께 해보시겠어요?

✨ Fortune의 특별한 점:
🎯 매일 업데이트되는 오늘의 운세
💝 다양한 운세 테마 (사주, 타로, 별자리 등)
🎁 친구 초대 시 무료 토큰 지급!

지금 바로 Fortune을 다운로드하고 운세를 확인해보세요!

iOS: $appStoreUrl
Android: $playStoreUrl

초대 코드: $inviteCode''';

    await Share.share(
      shareText,
      subject: 'Fortune 앱 초대',
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: TossDesignSystem.errorRed,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await supabase.auth.signOut();
      if (mounted) {
        context.go('/landing');
      }
    }
  }
}

// 기존 복잡한 UI 코드는 모두 제거됨:
// - _buildInsightItem() - 사용하지 않음
// - _buildNextStepItem() - 사용하지 않음
// - _buildToolItem() - 사용하지 않음
// - 사주 차트, 오행 분석, 운세 히스토리 위젯들
// - 활동 통계, 추천 활동, 내 도구 카드들
// - 계정 설정 복잡한 버튼

// 이제 프로필 페이지는 깔끔한 리스트 기반 UI로 완전히 재구성되었습니다.
// 기존 1509줄 → 약 800줄 (약 47% 감소)
