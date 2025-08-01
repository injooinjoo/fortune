import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
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
import '../../shared/components/app_header.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

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
              'total_fortunes': 0
              'consecutive_days': 0
              'last_login': DateTime.now().toIso8601String(),
              'favorite_fortune_type': null,
              'total_fortunes_viewed': 0,
              'login_count': 0,
              'streak_days': 0,
              'total_tokens_earned': 0,
              'total_tokens_spent': 0,
              'profile_completion_percentage': 0,
              'achievements': []
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
              'consecutive_days': 0;
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
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface),
        body: const Center(,
      child: CircularProgressIndicator(),
        )
    }
    
    // Get user profile to check if test account
    final userProfileAsync = ref.watch(userProfileProvider);
    final isTestAccount = userProfileAsync.when(
      data: (profile) => profile?.isTestAccount ?? false,
      loading: () => false,
      error: (_, __) => false
    );
    final isPremiumActive = userProfileAsync.when(
      data: (profile) => profile?.isPremiumActive ?? false,
      loading: () => false,
      error: (_, __) => false
    );

    return Scaffold(
      backgroundColor: context.fortuneTheme.cardBackground,
      appBar: AppHeader(,
      title: '내 프로필',
        showBackButton: true,
        centerTitle: false,
        backgroundColor: context.fortuneTheme.cardSurface,
        foregroundColor: AppColors.textPrimary),
        showTokenBalance: false),
        actions: [
          // Premium toggle for test accounts only
          if (isTestAccount)
            IconButton(
              icon: Icon(
                isPremiumActive ? Icons.workspace_premium : Icons.workspace_premium_outlined
                color: isPremiumActive ? Colors.amber : AppColors.textPrimary),
      onPressed: () async {
                final testAccountService = ref.read(testAccountServiceProvider);
                final user = ref.read(userProvider).value;
                if (user != null) {
                  await testAccountService.togglePremium(user.id, !isPremiumActive);
                  // Refresh user profile
                  ref.invalidate(userProfileProvider);
                }
              }
              tooltip: isPremiumActive ? '프리미엄 끄기' : '프리미엄 켜기')
          // Dark mode toggle
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode
              color: AppColors.textPrimary),
      onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            })
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => context.push('/settings'))),
      body: SingleChildScrollView(,
      child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
            // 기본 정보 카드
            if (userProfile != null || localProfile != null) ...[
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
              Padding(
                padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal),
                child: UserInfoCard(,
      userProfile: userProfile ?? localProfile),
        onProfileUpdated: _loadUserData)
                )))
            // 테스트 계정 섹션 (테스트 계정인 경우에만 표시,
            FutureBuilder<UserProfile?>(
              future: ref.watch(userProfileProvider.future),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                if (profile != null && profile.isTestAccount) {
                  return Column(
                    children: [
                      SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
                      Padding(
                        padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal),
                        child: BaseCard(,
      padding: EdgeInsets.zero),
        child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
                              Container(
                                padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
                                decoration: BoxDecoration(,
      color: AppColors.warning.withValues(alp,
      ha: 0.1),
                                  borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2),
                                    topRight: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2))),
      child: Row(
                                  children: [
                                    Icon(
                                      Icons.bug_report,
        ),
        color: AppColors.warning.withValues(alph,
      a: 0.9),                                      size: context.fortuneTheme.socialSharing.shareIconSize)
                                    SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.75),
                                    Text(
                                      '테스트 계정 설정'),
        style: theme.textTheme.titleLarge?.copyWith(,
      fontWeight: FontWeight.w700),
        color: AppColors.warning.withValues(alph,
      a: 0.9,
                          )))))))
                              Container(
                                padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
                                child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween),
        children: [
                        Text(
                          '무제한 토큰',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      fontWeight: FontWeight.w600)
                                        Container(
                                          padding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 0.75),
        vertical: context.fortuneTheme.formStyles.inputPadding.vertical * 0.33),
      decoration: BoxDecoration(,
      color: AppColors.success.withValues(alph,
      a: 0.1,
                          ),                                            borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputHeight * 0.4),
      child: Text(
                                            '활성화됨',
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: AppColors.success,
                          ),
        fontWeight: FontWeight.w600)
                                            ))))))
                                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                                    Text(
                                      '모든 운세를 토큰 제한 없이 이용할 수 있습니다.'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ))
                                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween),
        children: [
                        Text(
                          '프리미엄 기능',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      fontWeight: FontWeight.w600)
                                        Switch(
                                          value: profile.isPremiumActive),
        onChanged: (value) async {
                                            final testAccountService = ref.read(testAccountServiceProvider);
                                            try {
                                              await testAccountService.togglePremium(
                                                profile.userId)
                                                value)
                                              // Refresh user profile
                                              ref.invalidate(userProfileProvider);
                                              _loadUserData();
                                              
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      value 
                                                        ? '프리미엄 기능이 활성화되었습니다.',
                          ),
                                                        : '프리미엄 기능이 비활성화되었습니다.')
                                                    backgroundColor: value ? AppColors.success : context.fortuneTheme.subtitleText)))
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('프리미엄 상태 변경에 실패했습니다.'),
                                                    backgroundColor: context.fortuneTheme.errorColor)))
                                              }
                                            }
                                          }
                                          activeColor: AppColors.primary)))
                                    Text(
                                      '프리미엄 기능을 즉시 켜고 끌 수 있습니다.'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ))
                                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
                                    Container(
                                      padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.vertical * 0.75),
                                      decoration: BoxDecoration(,
      color: AppColors.primary.withValues(alp,
      ha: 0.1),                                        borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
                                        border: Border.all(,
      color: AppColors.primary.withValues(alp,
      ha: 0.2),                                        ))
                                      child: Row(,
      children: [
                                          Icon(
                                            Icons.info_outline,
        ),
        color: AppColors.primary.withValues(alph,
      a: 0.9),                                            size: context.fortuneTheme.formStyles.inputHeight * 0.4)
                                          SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                                          Expanded(
                                            child: Text(
                                              '테스트 계정: ${profile.email}'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: AppColors.primary.withValues(alp,
      ha: 0.9,
                          ))))))))))))))))))
                }
                return const SizedBox.shrink();
              })
            
            // 사주 정보 섹션
            if (userProfile != null || localProfile != null) ...[
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
              Padding(
                padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal),
                child: SajuChartWidget(,
      userProfile: userProfile ?? localProfile)
                )))
            // 오행 분석 섹션
            if (userProfile != null || localProfile != null) ...[
              SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),
              Padding(
                padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal),
                child: FiveElementsWidget(,
      userProfile: userProfile ?? localProfile)
                )))
            // 운세 히스토리 요약 카드
            SizedBox(height: AppSpacing.spacing4),
            Padding(
              padding: AppSpacing.paddingHorizontal16),
        child: FortuneHistorySummaryWidget())
            
            // 활동 통계 섹션
            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
            Container(
              margin: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal),
              decoration: BoxDecoration(,
      color: context.fortuneTheme.cardSurface,
        ),
        borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2),
                boxShadow: [
                  BoxShadow(
                    color: context.fortuneTheme.primaryText.withValues(alph,
      a: 0.04),                    blurRadius: context.fortuneTheme.formStyles.inputBorderRadius * 1.25,
                    offset: Offset(0, context.fortuneTheme.formStyles.inputBorderWidth * 2))))
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
                  Container(
                    padding: AppSpacing.paddingAll20),
        decoration: BoxDecoration(,
      color: Theme.of(context).primaryColor.withValues(alp,
      ha: 0.05),
                      borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2),
                        topRight: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2))),
      child: Row(,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Text(
                          '활동 통계',
                          style: theme.textTheme.titleLarge?.copyWith(,
      fontWeight: FontWeight.w700,
                          ))
                            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.25),
                            Text(
                              _getDateRange(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ))))
                        TextButton.icon(
                          onPressed: () => context.push('/profile/statistics'),
                          icon: Icon(
                            Icons.bar_chart),
        size: context.fortuneTheme.formStyles.inputPadding.horizontal),
        color: AppColors.primary),
      label: Text(
                            '상세 분석'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                          )))))))))
                  
                  // Statistics Items
                  _buildInsightItem(
                    context,
                    title: '운세 조회수',
                    value: userStats?['total_fortunes'] ?? 0),
        icon: Icons.visibility_outlined,
      isFirst: true)
                  _buildInsightItem(
                    context,
                    title: '연속 접속일',
                    value: userStats?['consecutive_days'] ?? 0),
        icon: Icons.local_fire_department_outlined)
                  _buildInsightItem(
                    context,
                    title: '획득 토큰',
                    value: userStats?['total_tokens_earned'] ?? 0),
        icon: Icons.token_outlined)
                  _buildInsightItem(
                    context,
                    title: '즐겨찾는 운세',
                    value: userStats?['favorite_fortune_type'] ?? '없음',
                    isText: true,
      icon: Icons.favorite_outline),
        isLast: true)
                  ))))
            
            // 추천 활동 섹션
            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
            Padding(
              padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal),
              child: SectionCard(,
      title: '추천 활동'),
        headerColor: AppColors.primary.withValues(alph,
      a: 0.1),
                child: Column(,
      children: [
                        _buildNextStepItem(
                          context,
                          icon: Icons.verified_outlined,
              ),
              title: '프로필 인증하기'),
        subtitle: '인증 배지를 받고 계정을 보호하세요.'),
        onTap: () => context.push('/profile/verification'))
                        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.75),
                        _buildNextStepItem(
                          context,
                          icon: Icons.star_outline,
                          title: '프리미엄 체험하기'),
        subtitle: '무제한 운세와 특별한 기능을 이용해보세요.'),
        onTap: () => context.push('/subscription'))
                        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.75),
                        _buildNextStepItem(
                          context,
                          icon: Icons.people_outline,
                          title: '친구 초대하기'),
        subtitle: '친구를 초대하고 함께 운세를 확인해보세요.'),
        onTap: () async {
                            await _inviteFriend();
                          })))))))
            
            // 내 도구 섹션
            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
            Padding(
              padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal),
              child: BaseCard(,
      padding: EdgeInsets.zero,
                child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
                    Container(
                      padding: AppSpacing.paddingAll20),
        decoration: BoxDecoration(,
      color: Colors.purple.withValues(alp,
      ha: 0.1),
                        borderRadius: BorderRadius.only(,
      topLeft: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2),
                          topRight: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2))),
      child: Row(
                        children: [
                          Text(
                            '내 도구',
        ),
        style: theme.textTheme.titleLarge?.copyWith(,
      fontWeight: FontWeight.w700,
                          ))))))
                  _buildToolItem(
                    context,
                    icon: Icons.school_outlined,
                    title: '운세 활용법',
                    subtitle: '운세를 200% 활용하는 방법'),
        isNew: true),
        onTap: () => context.push('/fortune/best-practices'),
                    isFirst: true)
                  _buildToolItem(
                    context,
                    icon: Icons.lightbulb_outline,
                    title: '오늘의 영감',
                    subtitle: '매일 새로운 긍정 메시지'),
        isNew: true),
        onTap: () => context.push('/fortune/inspiration'))
                  _buildToolItem(
                    context,
                    icon: Icons.history,
                    title: '운세 기록'),
        subtitle: '나의 모든 운세 히스토리'),
        onTap: () => context.push('/fortune/history'))
                  _buildToolItem(
                    context,
                    icon: Icons.share_outlined,
                    title: '친구와 공유'),
        subtitle: '운세를 함께 확인해보세요'),
        onTap: () async {
                      await _shareWithFriends();
                    }
                    isLast: true)))))))
            
            // 계정 설정 버튼
            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2),
            Padding(
              padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal),
              child: SizedBox(,
      width: double.infinity),
              child: OutlinedButton(,
      onPressed: () => context.push('/settings'),
                  style: OutlinedButton.styleFrom(,
      padding: EdgeInsets.symmetric(vertic,
      al: context.fortuneTheme.formStyles.inputPadding.horizontal),
                    side: BorderSide(colo,
      r: context.fortuneTheme.dividerColor),
                    shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius))))
                  child: Text(
                    '계정 설정'),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      color: context.fortuneTheme.primaryText,
                          ),
        fontWeight: FontWeight.w600)
                    ))))))))
            
            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 2))
      )
  }

  Future<void> _inviteFriend() async {
    final user = supabase.auth.currentUser;
    final userName = userProfile?['name'] ?? localProfile?['name'] ?? '사용자';
    
    const appStoreUrl = 'https: //apps.apple.com/app/fortune/id123456789'; // TOD,
      O: Replace with actual App Store URL
    const playStoreUrl = 'https: //play.google.com/store/apps/details?id=com.fortune.app'; // TOD,
      O: Replace with actual Play Store URL
    
    final shareText = '''🔮 Fortune - AI 운세 서비스

안녕하세요! $userName님이 Fortune 앱을 추천했어요!

✨ AI가 분석하는 나만의 맞춤 운세
🎯 매일 업데이트되는 오늘의 운세
💝 다양한 운세 테마 (사주, 타로, 별자리 등,
🎁 친구 초대 시 무료 토큰 지급!

지금 바로 Fortune을 다운로드하고 운세를 확인해보세요!

iOS: $appStoreUrl,
      Android: $playStoreUrl

초대 코드: ${user?.id?.substring(0, 8) ?? 'FORTUNE2024'}''';
    
    await Share.share(
      shareText),
        subject: 'Fortune 앱 초대')
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
      shareText),
        subject: 'Fortune 운세 공유'
    );
  }

  String _getDateRange() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30);
    final formatter = DateFormat('M월 d일', 'ko_KR');
    return '${formatter.format(
    start,
  )} - ${formatter.format(
    now,
  )}';
  }

  Widget _buildInsightItem(
    BuildContext context, {
    required String title,
    required dynamic value,
    bool isText = false,
    IconData? icon,
    bool isFirst = false,
    bool isLast = false,
  )}) {
    return InkWell(
      onTap: () => context.push('/profile/statistics'),
      borderRadius: isLast ? BorderRadius.only(,
      bottomLeft: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2),
        bottomRight: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2))) : null,
      child: Container(,
      padding: EdgeInsets.symmetric(horizont,
      al: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25, vertical: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.125),
        decoration: BoxDecoration(,
      border: Border(,
      bottom: isLast ? BorderSide.none : BorderSide(,
      color: context.fortuneTheme.dividerColor
              width: context.fortuneTheme.formStyles.inputBorderWidth)
            ))))
        child: Row(,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: context.fortuneTheme.formStyles.inputHeight * 0.8),
              height: context.fortuneTheme.formStyles.inputHeight * 0.8),
        decoration: BoxDecoration(,
      color: Theme.of(context).primaryColor.withValues(alp,
      ha: 0.1),                      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
      child: Icon(
                icon,
        ),
        size: context.fortuneTheme.formStyles.inputHeight * 0.44,
              ),
              color: AppColors.primary)
                    ))
                  SizedBox(width: context.fortuneTheme.formStyles.inputPadding.horizontal * 0.875)
                Text(
                  title),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      color: context.fortuneTheme.primaryText,
                          ),
        fontWeight: FontWeight.w500)
                  ))))
            Row(
              children: [
                Text(
                  isText ? value.toString() : value.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      fontWeight: FontWeight.w700),
        color: isText && value == '없음' 
                        ? context.fortuneTheme.subtitleText 
                        : context.fortuneTheme.primaryText,
                          )))
                SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                Icon(
                  Icons.arrow_forward_ios),
        size: context.fortuneTheme.formStyles.inputPadding.horizontal),
        color: context.fortuneTheme.subtitleText)
                ))))
      )
  }

  Widget _buildDivider() {
    return const SizedBox.shrink();
  }

  Widget _buildNextStepItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle)
    required VoidCallback onTap)
  }) {
    return InkWell(
      onTap: onTap),
      borderRadius: AppDimensions.borderRadiusMedium),
        child: Container(,
      padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal),
        decoration: BoxDecoration(,
      color: context.fortuneTheme.cardSurface,
        ),
        borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 1.5),
      child: Row(
          children: [
            Container(
              width: context.fortuneTheme.formStyles.inputHeight * 0.96),
              height: context.fortuneTheme.formStyles.inputHeight * 0.96),
        decoration: BoxDecoration(,
      color: AppColors.primary.withValues(alp,
      ha: 0.1),                borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 1.5),
      child: Icon(
                icon, color: AppColors.primary.withValues(alph,
      a: 0.9), size: context.fortuneTheme.socialSharing.shareIconSize))
            SizedBox(width: AppSpacing.spacing4),
            Expanded(
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
        ),
        children: [
                        Text(
                          title,
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      fontWeight: FontWeight.w600,
                          ),
              color: context.fortuneTheme.primaryText)
                    ))
                  SizedBox(height: AppSpacing.spacing1),
                  Text(
                    subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ))))))
            const Icon(
              Icons.arrow_forward_ios),
        size: AppDimensions.iconSizeXSmall),
        color: AppColors.textSecondary)
            ))
      )
  }

  Widget _buildToolItem(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool isNew = false,
    required VoidCallback onTap,
    bool isFirst = false)
    bool isLast = false)
  }) {
    return InkWell(
      onTap: onTap),
      borderRadius: isLast ? BorderRadius.only(,
      bottomLeft: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2),
        bottomRight: Radius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 2))) : null,
      child: Container(,
      padding: EdgeInsets.symmetric(horizont,
      al: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25, vertical: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.125),
        decoration: BoxDecoration(,
      border: Border(,
      bottom: isLast ? BorderSide.none : BorderSide(,
      color: context.fortuneTheme.dividerColor
              width: context.fortuneTheme.formStyles.inputBorderWidth)
            ))))
        child: Row(,
      children: [
            Container(
              width: context.fortuneTheme.formStyles.inputHeight * 0.88,
        ),
        height: context.fortuneTheme.formStyles.inputHeight * 0.88),
              decoration: BoxDecoration(,
      color: Colors.purple.withValues(alp,
      ha: 0.1),                borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius * 1.25),
      child: Icon(
                icon,
        ),
        color: Colors.purple.withValues(alph,
      a: 0.9),                size: context.fortuneTheme.socialSharing.shareIconSize)))
            SizedBox(width: AppSpacing.spacing4),
            Expanded(
              child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              ),
              children: [
                  Row(
                    children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      fontWeight: FontWeight.w600,
                          ),
              color: context.fortuneTheme.primaryText)
                        ))
                      if (isNew) ...[
                        SizedBox(width: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
                        Container(
                          padding: EdgeInsets.symmetric(horizonta,
      l: context.fortuneTheme.formStyles.inputPadding.horizontal * 0.375, vertical: context.fortuneTheme.formStyles.inputPadding.vertical * 0.167),
                          decoration: BoxDecoration(,
      color: AppColors.primary,
        ),
        borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputPadding.vertical * 0.25),
      child: Text(
                            'NEW'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: context.isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark,
                          ),
        fontWeight: FontWeight.bold),
        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize))))))
                    ])
                  if (subtitle != null) ...[
                    SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.125),
                    Text(
                      subtitle),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      color: AppColors.textSecondary,
                          ))
                ])))
            const Icon(
              Icons.arrow_forward_ios),
        size: AppDimensions.iconSizeXSmall),
        color: AppColors.textSecondary)
            ))
      )
  }
}