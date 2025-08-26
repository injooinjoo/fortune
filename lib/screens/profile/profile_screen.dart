import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/social_auth_service.dart';
import '../../presentation/widgets/saju_chart_widget.dart';
import '../../presentation/widgets/user_info_card.dart';
import '../../presentation/widgets/five_elements_widget.dart';
import '../../data/services/fortune_api_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../shared/components/base_card.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../core/services/test_account_service.dart';
import '../../data/models/user_profile.dart';
import '../../presentation/widgets/fortune_history_summary_widget.dart';
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
    const scrollThreshold = 100.0; // Minimum scroll distance before hiding/showing nav
    
    // Only trigger if we've scrolled more than the threshold
    if ((currentScrollOffset - _lastScrollOffset).abs() > scrollThreshold) {
      final isScrollingDown = currentScrollOffset > _lastScrollOffset;
      
      // Only update if direction changed
      if (isScrollingDown != _isScrollingDown) {
        _isScrollingDown = isScrollingDown;
        _lastScrollOffset = currentScrollOffset;
        
        // Update navigation visibility
        final navigationNotifier = ref.read(navigationVisibilityProvider.notifier);
        if (isScrollingDown) {
          navigationNotifier.hide();
        } else {
          navigationNotifier.show();
        }
      }
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
    final user = supabase.auth.currentUser;
    final theme = Theme.of(context);
    final tokenState = ref.watch(tokenProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
         MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.getTossBackground(context),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section replacing AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '내 프로필',
                        style: TextStyle(
                          color: AppColors.getTossTextPrimary(context),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: AppColors.getTossTextSecondary(context),
                        size: 24,
                      ),
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined, 
                        color: AppColors.getTossTextSecondary(context),
                        size: 24,
                      ),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
              
              // 기본 정보 카드
              if (userProfile != null || localProfile != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: UserInfoCard(
                    userProfile: userProfile ?? localProfile,
                    onProfileUpdated: _loadUserData,
                  ),
                ),
              ],

              // 테스트 계정 섹션 (테스트 계정인 경우에만 표시)
              FutureBuilder<UserProfile?>(
                future: ref.watch(userProfileProvider.future),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  if (profile != null && profile.isTestAccount) {
                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.getTossCardBackground(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.getTossBorder(context),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
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
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bug_report,
                                        color: AppColors.tossBlue,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '테스트 계정 설정',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                          color: AppColors.getTossTextPrimary(context),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '무제한 토큰',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.getTossTextPrimary(context),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              '활성화됨',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '모든 운세를 토큰 제한 없이 이용할 수 있습니다.',
                                        style: TextStyle(
                                          color: AppColors.getTossTextSecondary(context),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '프리미엄 기능',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.getTossTextPrimary(context),
                                            ),
                                          ),
                                          Switch(
                                            value: profile.isPremiumActive,
                                            onChanged: (value) async {
                                              final testAccountService = ref.read(testAccountServiceProvider);
                                              try {
                                                await testAccountService.togglePremium(
                                                  profile.userId,
                                                  value,
                                                );
                                                // Refresh user profile
                                                ref.invalidate(userProfileProvider);
                                                _loadUserData();

                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        value
                                                          ? '프리미엄 기능이 활성화되었습니다.'
                                                          : '프리미엄 기능이 비활성화되었습니다.',
                                                      ),
                                                      backgroundColor: value ? Colors.green : Colors.grey,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('프리미엄 상태 변경에 실패했습니다.'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            activeColor: AppColors.tossBlue,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '프리미엄 기능을 즉시 켜고 끌 수 있습니다.',
                                        style: TextStyle(
                                          color: AppColors.getTossTextSecondary(context),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.tossBluePale,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.getTossBorder(context),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: AppColors.tossBlue,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '계정: ${profile.email}',
                                                style: TextStyle(
                                                  color: AppColors.tossBlue,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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

              // 사주 정보 섹션
              if (userProfile != null || localProfile != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SajuChartWidget(
                    userProfile: userProfile ?? localProfile,
                  ),
                ),
              ],

              // 오행 분석 섹션
              if (userProfile != null || localProfile != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FiveElementsWidget(
                    userProfile: userProfile ?? localProfile,
                  ),
                ),
              ],

              // 운세 히스토리 요약 카드
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FortuneHistorySummaryWidget(
                  userId: userProfile?['user_id'] ?? supabase.auth.currentUser?.id ?? '',
                ),
              ),

              // 활동 통계 섹션
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.getTossCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '활동 통계',
                                style: TextStyle(
                                  color: AppColors.getTossTextPrimary(context),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getDateRange(),
                                style: TextStyle(
                                  color: AppColors.getTossTextSecondary(context),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => context.push('/profile/statistics'),
                            icon: const Icon(
                              Icons.bar_chart,
                              size: 16,
                              color: AppColors.tossBlue,
                            ),
                            label: const Text(
                              '상세 분석',
                              style: TextStyle(
                                color: AppColors.tossBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Statistics Items
                    _buildInsightItem(
                      context,
                      title: '운세 조회수',
                      value: userStats?['total_fortunes'],
                      icon: Icons.visibility_outlined,
                      isFirst: true,
                    ),
                    _buildInsightItem(
                      context,
                      title: '연속 접속일',
                      value: userStats?['consecutive_days'],
                      icon: Icons.local_fire_department_outlined,
                    ),
                    _buildInsightItem(
                      context,
                      title: '획득 토큰',
                      value: userStats?['total_tokens_earned'],
                      icon: Icons.token_outlined,
                    ),
                    _buildInsightItem(
                      context,
                      title: '즐겨찾는 운세',
                      value: userStats?['favorite_fortune_type'] ?? '없음',
                      isText: true,
                      icon: Icons.favorite_outline,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 추천 활동 섹션
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.getTossCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 활동',
                        style: TextStyle(
                          color: AppColors.getTossTextPrimary(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          _buildNextStepItem(
                            context,
                            icon: Icons.verified_outlined,
                            title: '프로필 인증하기',
                            subtitle: '인증 배지를 받고 계정을 보호하세요.',
                            onTap: () => context.push('/profile/verification'),
                          ),
                          const SizedBox(height: 16),
                          _buildNextStepItem(
                            context,
                            icon: Icons.star_outline,
                            title: '프리미엄 체험하기',
                            subtitle: '무제한 운세와 특별한 기능을 이용해보세요.',
                            onTap: () => context.push('/subscription'),
                          ),
                          const SizedBox(height: 16),
                          _buildNextStepItem(
                            context,
                            icon: Icons.people_outline,
                            title: '친구 초대하기',
                            subtitle: '친구를 초대하고 함께 운세를 확인해보세요.',
                            onTap: () async {
                              await _inviteFriend();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 내 도구 섹션
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.getTossCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                        '내 도구',
                        style: TextStyle(
                          color: AppColors.getTossTextPrimary(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    _buildToolItem(
                      context,
                      icon: Icons.school_outlined,
                      title: '운세 활용법',
                      subtitle: '운세를 200% 활용하는 방법',
                      isNew: true,
                      onTap: () => context.push('/fortune/best-practices'),
                      isFirst: true,
                    ),
                    _buildToolItem(
                      context,
                      icon: Icons.lightbulb_outline,
                      title: '오늘의 영감',
                      subtitle: '매일 새로운 긍정 메시지',
                      isNew: true,
                      onTap: () => context.push('/fortune/inspiration'),
                    ),
                    _buildToolItem(
                      context,
                      icon: Icons.history,
                      title: '운세 기록',
                      subtitle: '나의 모든 운세 히스토리',
                      onTap: () => context.push('/fortune/history'),
                    ),
                    _buildToolItem(
                      context,
                      icon: Icons.share_outlined,
                      title: '친구와 공유',
                      subtitle: '운세를 함께 확인해보세요',
                      onTap: () async {
                        await _shareWithFriends();
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // 계정 설정 버튼
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.getTossCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.getTossBorder(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/settings'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        '계정 설정',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.getTossTextPrimary(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _inviteFriend() async {
    final user = supabase.auth.currentUser;
    final userName = userProfile?['name'] ?? localProfile?['name'] ?? '사용자';

    const appStoreUrl = 'https://apps.apple.com/app/fortune/id123456789'; // TODO: Replace with actual App Store URL
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.fortune.app'; // TODO: Replace with actual Play Store URL

    final shareText = '''🔮 Fortune - AI 운세 서비스

안녕하세요! $userName님이 Fortune 앱을 추천했어요!

✨ AI가 분석하는 나만의 맞춤 운세
🎯 매일 업데이트되는 오늘의 운세
💝 다양한 운세 테마 (사주, 타로, 별자리 등)
🎁 친구 초대 시 무료 토큰 지급!

지금 바로 Fortune을 다운로드하고 운세를 확인해보세요!

iOS: $appStoreUrl
Android: $playStoreUrl

초대 코드: ${user?.id?.substring(0, 8) ?? 'FORTUNE2024'}''';

    await Share.share(
      shareText,
      subject: 'Fortune 앱 초대',
    );
  }

  Future<void> _shareWithFriends() async {
    final userName = userProfile?['name'] ?? localProfile?['name'] ?? '나';
    final lastFortuneScore = fortuneScores.isNotEmpty ? fortuneScores.last : 0;

    String fortuneMessage = '';
    if (lastFortuneScore >= 80) {
      fortuneMessage = '오늘의 운세가 아주 좋아요! 🌟';
    } else if (lastFortuneScore >= 60) {
      fortuneMessage = '오늘은 평균 이상의 운세예요! ✨';
    } else if (lastFortuneScore >= 40) {
      fortuneMessage = '오늘은 평범한 하루가 될 거예요 😊';
    } else {
      fortuneMessage = '오늘은 조심하는 게 좋겠어요 🍀';
    }

    final shareText = '''🔮 $userName의 Fortune 운세

$fortuneMessage
운세 점수: $lastFortuneScore점

나의 운세 통계:
• 총 운세 조회: ${userStats?['total_fortunes'] ?? 0}회
• 연속 접속: ${userStats?['consecutive_days'] ?? 0}일
• 즐겨찾는 운세: ${userStats?['favorite_fortune_type'] ?? '없음'}

Fortune 앱에서 나만의 운세를 확인해보세요!
https://fortune.app''';

    await Share.share(
      shareText,
      subject: 'Fortune 운세 공유',
    );
  }

  String _getDateRange() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final formatter = DateFormat('M월 d일', 'ko_KR');
    return '${formatter.format(start)} - ${formatter.format(now)}';
  }

  Widget _buildInsightItem(
    BuildContext context, {
    required String title,
    required dynamic value,
    bool isText = false,
    IconData? icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () => context.push('/profile/statistics'),
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(
                    color: AppColors.getTossBorder(context),
                    width: 1,
                  ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.getTossIconBackground(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: AppColors.tossBlue,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTossTextPrimary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  isText ? value.toString() : value.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isText && value == '없음'
                        ? AppColors.getTossTextSecondary(context)
                        : AppColors.getTossTextPrimary(context),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.getTossArrow(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getTossIconBackground(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.tossBluePale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon, 
                color: AppColors.tossBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTossTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTossTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.getTossArrow(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool isNew = false,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(
                    color: AppColors.getTossBorder(context),
                    width: 1,
                  ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.getTossIconBackground(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.tossBlue,
                size: 24,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTossTextPrimary(context),
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tossBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NEW',
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
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTossTextSecondary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.getTossArrow(context),
            ),
          ],
        ),
      ),
    );
  }
}