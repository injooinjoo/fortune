import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/token_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/social_auth_service.dart';
import '../../presentation/widgets/saju_chart_widget.dart';
import '../../presentation/widgets/user_info_card.dart';
import '../../presentation/widgets/fortune_history_chart.dart';
import '../../presentation/widgets/five_elements_widget.dart';
import '../../data/services/fortune_api_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../shared/components/base_card.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../core/services/test_account_service.dart';
import '../../data/models/user_profile.dart';
import '../../presentation/widgets/fortune_history_summary_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _socialAuthService = SocialAuthService(supabase);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Load from local storage first
      localProfile = await _storageService.getUserProfile();
      debugPrint('Local profile: $localProfile');
      
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        // Load user profile
        final response = await supabase
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        debugPrint('Supabase profile: $response');
        
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
          debugPrint('Error loading user statistics: $e');
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
              'consecutive_days': 0,
            };
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
      debugPrint('Error loading fortune history: $e');
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
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.cardBackground, // #F6F6F6
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '내 프로필',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 정보 카드
            if (userProfile != null || localProfile != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BaseCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bug_report,
                                      color: Colors.orange.shade700,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '테스트 계정 설정',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          '무제한 토큰',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
                                    const Text(
                                      '모든 운세를 토큰 제한 없이 이용할 수 있습니다.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          '프리미엄 기능',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
                                          activeColor: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      '프리미엄 기능을 즉시 켜고 끌 수 있습니다.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.blue.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '테스트 계정: ${profile.email}',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SajuChartWidget(
                  userProfile: userProfile ?? localProfile,
                ),
              ),
            ],
            
            // 오행 분석 섹션
            if (userProfile != null || localProfile != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FiveElementsWidget(
                  userProfile: userProfile ?? localProfile,
                ),
              ),
            ],
            
            // 운세 히스토리 요약 카드
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: FortuneHistorySummaryWidget(),
            ),
            
            // 활동 통계 섹션
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '활동 통계',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDateRange(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
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
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            '상세 분석',
                            style: TextStyle(
                              color: AppColors.primary,
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
                    value: userStats?['total_fortunes'] ?? 0,
                    icon: Icons.visibility_outlined,
                    isFirst: true,
                  ),
                  _buildInsightItem(
                    context,
                    title: '연속 접속일',
                    value: userStats?['consecutive_days'] ?? 0,
                    icon: Icons.local_fire_department_outlined,
                  ),
                  _buildInsightItem(
                    context,
                    title: '획득 토큰',
                    value: userStats?['total_tokens_earned'] ?? 0,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionCard(
                title: '추천 활동',
                headerColor: Colors.blue.shade50,
                child: Column(
                      children: [
                        _buildNextStepItem(
                          context,
                          icon: Icons.verified_outlined,
                          title: '프로필 인증하기',
                          subtitle: '인증 배지를 받고 계정을 보호하세요.',
                          onTap: () => context.push('/profile/verification'),
                        ),
                        const SizedBox(height: 12),
                        _buildNextStepItem(
                          context,
                          icon: Icons.star_outline,
                          title: '프리미엄 체험하기',
                          subtitle: '무제한 운세와 특별한 기능을 이용해보세요.',
                          onTap: () => context.push('/subscription'),
                        ),
                        const SizedBox(height: 12),
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
              ),
            ),
            
            // 내 도구 섹션
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BaseCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '내 도구',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ],
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
            ),
            
            // 계정 설정 버튼
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/settings'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '계정 설정',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
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

  Widget _buildInsightItem(BuildContext context, {
    required String title,
    required dynamic value,
    bool isText = false,
    IconData? icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () => context.push('/profile/statistics'),
      borderRadius: isLast ? const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast ? BorderSide.none : const BorderSide(
              color: AppColors.divider,
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
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
                        ? AppColors.textSecondary 
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const SizedBox.shrink();
  }

  Widget _buildNextStepItem(BuildContext context, {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolItem(BuildContext context, {
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
      borderRadius: isLast ? const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast ? BorderSide.none : const BorderSide(
              color: AppColors.divider,
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
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.purple.shade700,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}