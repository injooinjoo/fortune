import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/cache/cache_service.dart';
import '../../services/storage_service.dart';
import '../../core/design_system/design_system.dart';
import '../../data/services/fortune_api_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../presentation/providers/providers.dart';
import '../../presentation/widgets/social_login_bottom_sheet.dart';
import './providers/character_stats_provider.dart';
import '../../core/services/fortune_haptic_service.dart';
import '../../core/providers/user_settings_provider.dart';
import '../../shared/components/settings_list_tile.dart';
import '../../shared/components/section_header.dart';
import '../../shared/components/premium_membership_card.dart';
import '../../features/settings/presentation/widgets/storage_management_widget.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/extensions/l10n_extension.dart';
import 'widgets/profile_list_sheet.dart';
import 'widgets/language_selection_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  /// 외부에서 전달받은 스크롤 컨트롤러 (바텀시트 드래그용)
  final ScrollController? scrollController;

  /// 바텀시트 모드 여부 (true일 경우 Scaffold/AppBar 없이 콘텐츠만 렌더링)
  final bool isInBottomSheet;

  const ProfileScreen({
    super.key,
    this.scrollController,
    this.isInBottomSheet = false,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _storageService = StorageService();
  Map<String, dynamic>? userProfile;
  Map<String, dynamic>? localProfile;
  Map<String, dynamic>? userStats;
  List<int> fortuneScores = [];
  bool isLoading = true;
  bool isLoadingHistory = false;

  // Scroll controller and variables for navigation bar hiding
  ScrollController? _internalScrollController;
  ScrollController get _scrollController =>
      widget.scrollController ?? _internalScrollController!;
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;

  // Design System Helper Methods
  Color _getTextColor(BuildContext context) {
    return context.colors.textPrimary;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return context.colors.textSecondary;
  }

  Color _getBackgroundColor(BuildContext context) {
    return context.colors.surface;
  }

  Color _getSectionBackgroundColor(BuildContext context) {
    return context.colors.surface;
  }

  // 로그아웃 처리
  Future<void> _handleLogout() async {
    final shouldLogout = await DSModal.confirm(
      context: context,
      title: context.l10n.logout,
      message: context.l10n.logoutConfirm,
      confirmText: context.l10n.logout,
      cancelText: context.l10n.cancel,
      isDestructive: true,
    );

    if (shouldLogout == true) {
      // 1. Supabase 로그아웃
      await supabase.auth.signOut();

      // 2. 로컬 데이터 정리
      await _storageService.clearUserProfile();
      await _storageService.clearGuestMode();
      await _storageService.clearGuestId();

      // 3. 캐시 정리
      final cacheService = CacheService();
      cacheService.clearAllCache();

      if (mounted) {
        // 4. 온보딩 채팅으로 이동 (Chat-First)
        context.go('/chat');
      }
    }
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
        parts.add(
            '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}');
      } catch (e) {
        // 파싱 실패 시 무시
      }
    }

    if (gender != null) {
      switch (gender) {
        case 'male':
          parts.add(context.l10n.genderMale);
          break;
        case 'female':
          parts.add(context.l10n.genderFemale);
          break;
        case 'other':
          parts.add(context.l10n.genderOther);
          break;
      }
    }

    return parts.join(' · ');
  }

  // Minimal List Components (스크린샷 스타일)
  // _buildSectionHeader replaced by SectionHeader component

  // _buildListItem replaced by SettingsListTile component

  @override
  void initState() {
    super.initState();

    // Initialize scroll controller with navigation bar hiding logic
    // 외부에서 전달받지 않은 경우에만 내부 컨트롤러 생성
    if (widget.scrollController == null) {
      _internalScrollController = ScrollController();
    }
    _scrollController.addListener(_onScroll);

    // 비로그인 상태면 로그인 바텀시트 표시
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginBottomSheet();
      });
    } else {
      _loadUserData();
    }
  }

  /// 비로그인 시 로그인 바텀시트 표시
  Future<void> _showLoginBottomSheet() async {
    if (!mounted) return;

    await SocialLoginBottomSheet.show(
      context,
      ref: ref,
      onGoogleLogin: () async {
        Navigator.pop(context);
        await ref.read(socialAuthProvider.notifier).signInWithGoogle();
        if (mounted && supabase.auth.currentUser != null) {
          _loadUserData();
        }
      },
      onAppleLogin: () async {
        Navigator.pop(context);
        await ref.read(socialAuthProvider.notifier).signInWithApple();
        if (mounted && supabase.auth.currentUser != null) {
          _loadUserData();
        }
      },
      onKakaoLogin: () {},
      onNaverLogin: () {},
    );

    // 바텀시트 닫히고 아직 비로그인이면 이전 페이지로
    if (mounted && supabase.auth.currentUser == null) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    // 내부에서 생성한 컨트롤러만 dispose
    _internalScrollController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 바텀시트 모드에서는 네비게이션 바 관련 로직 스킵
    if (widget.isInBottomSheet) return;

    final currentScrollOffset = _scrollController.offset;
    const scrollThreshold = 10.0; // 매우 민감하게 반응하도록 임계값 감소

    // 스크롤 방향 감지
    final scrollDelta = currentScrollOffset - _lastScrollOffset;

    // 임계값 이상 스크롤했을 때만 처리
    if (scrollDelta.abs() > scrollThreshold) {
      final isScrollingDown = scrollDelta > 0;

      // 방향이 바뀌었거나, 같은 방향으로 계속 스크롤 중일 때
      if (isScrollingDown != _isScrollingDown ||
          scrollDelta.abs() > scrollThreshold) {
        _isScrollingDown = isScrollingDown;
        _lastScrollOffset = currentScrollOffset;

        // Update navigation visibility
        final navigationNotifier =
            ref.read(navigationVisibilityProvider.notifier);
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
          if (e
              .toString()
              .contains('relation "public.user_statistics" does not exist')) {
            debugPrint(
                'user_statistics table not found - using default values');
          }
        }

        // 오늘의 일일 운세 점수 조회 (UTC 기준)
        Map<String, dynamic>? todayFortuneResponse;
        try {
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day).toUtc();
          final todayEnd = todayStart.add(const Duration(days: 1));
          todayFortuneResponse = await supabase
              .from('fortune_history')
              .select('score')
              .eq('user_id', userId)
              .eq('fortune_type', 'daily')
              .gte('created_at', todayStart.toIso8601String())
              .lt('created_at', todayEnd.toIso8601String())
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
        } catch (e) {
          debugPrint('오늘 운세 점수 조회 실패: $e');
        }

        if (mounted) {
          setState(() {
            userProfile = response;
            userStats = statsResponse ??
                {
                  'total_fortunes_viewed': 0,
                  'consecutive_days': 0,
                  'last_login': DateTime.now().toIso8601String(),
                  'favorite_fortune_type': null,
                  'login_count': 0,
                  'streak_days': 0,
                  'total_tokens_earned': 0,
                  'total_tokens_spent': 0,
                  'profile_completion_percentage': 0,
                  'achievements': [],
                };
            // 오늘 운세 점수가 있으면 추가
            if (todayFortuneResponse != null &&
                todayFortuneResponse['score'] != null) {
              userStats!['today_score'] = todayFortuneResponse['score'];
            }
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
              'total_fortunes_viewed': 0,
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
      final scores =
          await fortuneApiService.getUserFortuneHistory(userId: userId);

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

    // 로딩 중
    if (isLoading) {
      // 바텀시트 모드에서는 Scaffold 없이 로딩 표시
      if (widget.isInBottomSheet) {
        return Center(
          child: CircularProgressIndicator(
            color: context.colors.accent,
          ),
        );
      }
      return Scaffold(
        backgroundColor: _getBackgroundColor(context),
        body: Center(
          child: CircularProgressIndicator(
            color: context.colors.accent,
          ),
        ),
      );
    }

    // 콘텐츠 빌드
    final content = SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 바텀시트 모드에서 헤더 표시
          if (widget.isInBottomSheet)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.pageHorizontal,
                vertical: DSSpacing.md,
              ),
              child: Row(
                children: [
                  Text(
                    context.l10n.myProfile,
                    style: context.heading2.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: context.colors.textPrimary,
                    ),
                    onPressed: () {
                      ref.read(fortuneHapticServiceProvider).selection();
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: DSSpacing.md),

          // 프로필 요약 카드
          if (userProfile != null || localProfile != null)
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: context.colors.border,
                  width: 1,
                ),
              ),
              child: SettingsListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: (userProfile ??
                              localProfile)?['profile_image_url'] !=
                          null
                      ? NetworkImage(
                          (userProfile ?? localProfile)!['profile_image_url'])
                      : null,
                  child: (userProfile ?? localProfile)?['profile_image_url'] ==
                          null
                      ? const Icon(Icons.person, size: 24)
                      : null,
                ),
                // 로컬 스토리지 이름 우선 (사용자가 직접 입력한 이름), DB 이름 폴백
                title: localProfile?['name'] ?? userProfile?['name'] ?? context.l10n.user,
                subtitle: _formatProfileSubtitle(),
                trailing: Icon(
                  Icons.chevron_right,
                  color: _getSecondaryTextColor(context),
                ),
                onTap: _navigateToProfileEdit,
                isLast: true,
              ),
            ),

          // 다른 프로필 보기 텍스트 링크
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.pageHorizontal),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showProfileList(context),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  context.l10n.viewOtherProfiles,
                  style: context.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),

          // 프리미엄 & 토큰 통합 카드
          const PremiumMembershipCard(),

          // AI 캐릭터 & 채팅 섹션
          _buildCharacterSection(context),

          // 탐구 활동 섹션
          SectionHeader(title: context.l10n.explorationActivity),
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: DSSpacing.pageHorizontal),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: context.colors.border,
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
              children: [
                SettingsListTile(
                  icon: Icons.today_outlined,
                  title: context.l10n.todayInsight,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (userStats?['today_score'] != null) ...[
                        Text(
                          '${userStats!['today_score']}',
                          style: context.heading3.copyWith(
                            color: _getTextColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          context.l10n.scorePoint,
                          style: context.bodyMedium.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                      ] else
                        Text(
                          context.l10n.notChecked,
                          style: context.bodyMedium.copyWith(
                            color: _getSecondaryTextColor(context),
                          ),
                        ),
                    ],
                  ),
                ),
                SettingsListTile(
                  icon: Icons.local_fire_department_outlined,
                  title: context.l10n.consecutiveDays,
                  trailing: Text(
                    context.l10n.dayCount(userStats?['consecutive_days'] ?? 0),
                    style: context.bodyMedium.copyWith(
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                ),
                SettingsListTile(
                  icon: Icons.visibility_outlined,
                  title: context.l10n.totalExplorations,
                  trailing: Text(
                    context.l10n.timesCount(userStats?['total_fortunes_viewed'] ?? 0),
                    style: context.bodyMedium.copyWith(
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                  isLast: true,
                ),
              ],
            ),
          ),

          // 토큰 획득 안내
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.pageHorizontal + 4,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.tokenEarnInfo,
                    style: context.bodySmall.copyWith(
                      color: context.colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 내 정보 섹션 (통합, 접을 수 있음)
          if (userProfile != null || localProfile != null) ...[
            SectionHeader(title: context.l10n.myInfo),
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.pageHorizontal),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: context.colors.border,
                  width: 1,
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.xs,
                  ),
                  leading: Icon(
                    Icons.auto_awesome,
                    color: context.colors.textSecondary,
                    size: 22,
                  ),
                  title: Text(
                    context.l10n.birthdateAndSaju,
                    style: context.bodyMedium.copyWith(
                      color: _getTextColor(context),
                    ),
                  ),
                  subtitle: Text(
                    _formatBirthDateShort(),
                    style: context.bodySmall.copyWith(
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                  children: [
                    // 생년월일
                    SettingsListTile(
                      icon: Icons.cake_outlined,
                      title: context.l10n.birthdate,
                      trailing: Text(
                        _formatBirthDate(
                            (userProfile ?? localProfile)?['birth_date'], context),
                        style: context.bodyMedium.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                      onTap: _navigateToProfileEdit,
                    ),
                    // 출생시간
                    SettingsListTile(
                      icon: Icons.access_time_outlined,
                      title: context.l10n.birthTime,
                      trailing: Text(
                        (userProfile ?? localProfile)?['birth_time'] ?? context.l10n.notEntered,
                        style: context.bodyMedium.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                      onTap: _navigateToProfileEdit,
                    ),
                    // 띠
                    SettingsListTile(
                      icon: Icons.pets_outlined,
                      title: context.l10n.chineseZodiac,
                      trailing: Text(
                        (userProfile ?? localProfile)?['chinese_zodiac'] ?? context.l10n.notEntered,
                        style: context.bodyMedium.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                    // 별자리
                    SettingsListTile(
                      icon: Icons.stars_outlined,
                      title: context.l10n.zodiacSign,
                      trailing: Text(
                        (userProfile ?? localProfile)?['zodiac_sign'] ?? context.l10n.notEntered,
                        style: context.bodyMedium.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                    // 혈액형
                    SettingsListTile(
                      icon: Icons.water_drop_outlined,
                      title: context.l10n.bloodType,
                      trailing: Text(
                        (userProfile ?? localProfile)?['blood_type'] != null
                            ? context.l10n.bloodTypeFormat((userProfile ?? localProfile)!['blood_type'])
                            : context.l10n.notEntered,
                        style: context.bodyMedium.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                      onTap: _navigateToProfileEdit,
                    ),
                    // MBTI
                    SettingsListTile(
                      icon: Icons.psychology_outlined,
                      title: 'MBTI',
                      trailing: Text(
                        (userProfile ?? localProfile)?['mbti']?.toUpperCase() ??
                            context.l10n.notEntered,
                        style: context.bodyMedium.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                      ),
                      onTap: _navigateToProfileEdit,
                    ),
                    // 구분선
                    Divider(
                      height: 1,
                      color: context.colors.border,
                      indent: DSSpacing.md,
                      endIndent: DSSpacing.md,
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    // 사주 종합
                    SettingsListTile(
                      icon: Icons.auto_awesome,
                      title: context.l10n.sajuSummary,
                      subtitle: context.l10n.sajuSummaryDesc,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _getSecondaryTextColor(context),
                      ),
                      onTap: () {
                        context.push('/profile/saju-summary');
                      },
                    ),
                    // 인사이트 기록
                    SettingsListTile(
                      icon: Icons.history,
                      title: context.l10n.insightHistory,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _getSecondaryTextColor(context),
                      ),
                      onTap: () => context.push('/profile/history'),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 도구 섹션
          SectionHeader(title: context.l10n.tools),
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: DSSpacing.pageHorizontal),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: context.colors.border,
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
              children: [
                SettingsListTile(
                  icon: Icons.share_outlined,
                  title: context.l10n.shareWithFriend,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () async {
                    await _inviteFriend();
                  },
                ),
                SettingsListTile(
                  icon: Icons.verified_outlined,
                  title: context.l10n.profileVerification,
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

          // ───────────────────────────────────────────────────────
          // 설정 섹션 (settings_screen.dart에서 통합)
          // ───────────────────────────────────────────────────────

          // 계정 관리 섹션
          SectionHeader(title: context.l10n.accountManagement),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _getSectionBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SettingsListTile(
                  icon: Icons.link_outlined,
                  title: context.l10n.socialAccountLink,
                  subtitle: context.l10n.socialAccountLinkDesc,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () => context.push('/profile/social-accounts'),
                ),
                SettingsListTile(
                  icon: Icons.phone_outlined,
                  title: context.l10n.phoneManagement,
                  subtitle: context.l10n.phoneManagementDesc,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () => context.push('/profile/phone-management'),
                ),
                SettingsListTile(
                  icon: Icons.notifications_outlined,
                  title: context.l10n.notificationSettings,
                  subtitle: context.l10n.notificationSettingsDesc,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () => context.push('/profile/notifications'),
                  isLast: true,
                ),
              ],
            ),
          ),

          // 앱 설정 섹션
          SectionHeader(title: context.l10n.appSettings),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _getSectionBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SettingsListTile(
                  icon: Icons.vibration_outlined,
                  title: context.l10n.hapticFeedback,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ref.watch(userSettingsProvider).hapticEnabled ? 'ON' : 'OFF',
                        style: context.bodyMedium.copyWith(
                          color: ref.watch(userSettingsProvider).hapticEnabled
                              ? context.colors.accent
                              : _getSecondaryTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DSToggle(
                        value: ref.watch(userSettingsProvider).hapticEnabled,
                        onChanged: (value) {
                          ref
                              .read(userSettingsProvider.notifier)
                              .setHapticEnabled(value);
                          if (value) {
                            DSHaptics.light();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final localeNotifier = ref.watch(localeProvider.notifier);
                    return SettingsListTile(
                      icon: Icons.language_outlined,
                      title: context.l10n.language,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localeNotifier.currentLanguage.nativeName,
                            style: context.bodyMedium.copyWith(
                              color: _getSecondaryTextColor(context),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: _getSecondaryTextColor(context),
                          ),
                        ],
                      ),
                      onTap: () {
                        LanguageSelectionSheet.show(context);
                      },
                    );
                  },
                ),
                SettingsListTile(
                  icon: Icons.storage_outlined,
                  title: context.l10n.storageManagement,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StorageManagementPage(),
                      ),
                    );
                  },
                  isLast: true,
                ),
              ],
            ),
          ),

          // 지원 섹션
          SectionHeader(title: context.l10n.support),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _getSectionBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SettingsListTile(
                  icon: Icons.help_outline,
                  title: context.l10n.help,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () => context.push('/help'),
                ),
                SettingsListTile(
                  icon: Icons.privacy_tip_outlined,
                  title: context.l10n.privacyPolicy,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () => context.push('/privacy-policy'),
                ),
                SettingsListTile(
                  icon: Icons.description_outlined,
                  title: context.l10n.termsOfService,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () => context.push('/terms-of-service'),
                ),
                SettingsListTile(
                  icon: Icons.logout_outlined,
                  title: context.l10n.logout,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: _handleLogout,
                ),
                SettingsListTile(
                  icon: Icons.person_remove_outlined,
                  title: context.l10n.memberWithdrawal,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () => context.push('/profile/account-deletion'),
                  isLast: true,
                ),
              ],
            ),
          ),

          // 버전 정보
          const SizedBox(height: DSSpacing.md),
          Center(
            child: Text(
              'Fortune v1.0.0',
              style: context.bodySmall.copyWith(
                color: _getSecondaryTextColor(context),
              ),
            ),
          ),

          // 네비게이션 바 높이(56) + SafeArea 하단 여백 확보
          // 바텀시트 모드에서는 하단 패딩 줄임
          SizedBox(height: widget.isInBottomSheet ? 40 : 100),
        ],
      ),
    );

    // 바텀시트 모드에서는 콘텐츠만 반환
    if (widget.isInBottomSheet) {
      return content;
    }

    // 일반 모드에서는 Scaffold로 래핑
    return Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: context.colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.myProfile,
          style: context.heading2.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: context.colors.textPrimary,
            ),
            onPressed: () {
              ref.read(fortuneHapticServiceProvider).selection();
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: content,
      ),
    );
  }

  // AI 캐릭터 & 채팅 섹션 빌더
  Widget _buildCharacterSection(BuildContext context) {
    final stats = ref.watch(characterStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.aiCharacterChat),
        Container(
          margin: const EdgeInsets.symmetric(
              horizontal: DSSpacing.pageHorizontal),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.md),
            border: Border.all(
              color: context.colors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 대표 캐릭터 (가장 높은 호감도)
              if (stats.topCharacter != null)
                SettingsListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: stats.topCharacter!.accentColor,
                    backgroundImage: stats.topCharacter!.avatarAsset.isNotEmpty
                        ? AssetImage(stats.topCharacter!.avatarAsset)
                        : null,
                    child: stats.topCharacter!.avatarAsset.isEmpty
                        ? Text(
                            stats.topCharacter!.name.isNotEmpty
                                ? stats.topCharacter!.name[0]
                                : '?',
                            style: context.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: stats.topCharacter!.name,
                  subtitle: '${stats.topPhaseName} · ${stats.topLoveEmoji} ${stats.topAffinityPercent}%',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () {
                    ref.read(fortuneHapticServiceProvider).buttonTap();
                    context.push('/character/${stats.topCharacter!.id}', extra: stats.topCharacter);
                  },
                )
              else
                SettingsListTile(
                  icon: Icons.favorite_outline,
                  title: context.l10n.startCharacterChat,
                  subtitle: context.l10n.meetNewCharacters,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _getSecondaryTextColor(context),
                  ),
                  onTap: () {
                    ref.read(fortuneHapticServiceProvider).buttonTap();
                    context.go('/chat');
                  },
                ),

              // 총 대화 수
              SettingsListTile(
                icon: Icons.chat_bubble_outline,
                title: context.l10n.totalConversations,
                trailing: Text(
                  context.l10n.conversationCount(stats.totalMessages),
                  style: context.bodyMedium.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ),

              // 활성 캐릭터 수
              SettingsListTile(
                icon: Icons.people_outline,
                title: context.l10n.activeCharacters,
                trailing: Text(
                  context.l10n.characterCount(stats.totalConversations),
                  style: context.bodyMedium.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ),

              // 캐릭터 목록 바로가기
              SettingsListTile(
                icon: Icons.grid_view_outlined,
                title: context.l10n.viewAllCharacters,
                trailing: Icon(
                  Icons.chevron_right,
                  color: _getSecondaryTextColor(context),
                ),
                onTap: () {
                  ref.read(fortuneHapticServiceProvider).buttonTap();
                  context.go('/chat');
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Methods
  String _formatBirthDate(String? birthDate, BuildContext ctx) {
    if (birthDate == null || birthDate.isEmpty) return ctx.l10n.notEntered;

    try {
      final date = DateTime.parse(birthDate);
      return ctx.l10n.dateFormatYMD(date.year, date.month, date.day);
    } catch (e) {
      return ctx.l10n.notEntered;
    }
  }

  /// 간략한 생년월일 포맷 (YYYY.MM.DD)
  String _formatBirthDateShort() {
    final profile = userProfile ?? localProfile;
    final birthDate = profile?['birth_date'] as String?;
    if (birthDate == null || birthDate.isEmpty) return context.l10n.notEntered;

    try {
      final date = DateTime.parse(birthDate);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return context.l10n.notEntered;
    }
  }

  Future<void> _navigateToProfileEdit() async {
    ref.read(fortuneHapticServiceProvider).buttonTap();
    final result = await context.push<bool>('/profile/edit');
    if (result == true && mounted) {
      _loadUserData();
    }
  }

  void _showProfileList(BuildContext context) {
    ref.read(fortuneHapticServiceProvider).buttonTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (_) => const ProfileListSheet(),
    );
  }

  Future<void> _inviteFriend() async {
    final currentUser = supabase.auth.currentUser;
    final appStoreUrl = 'https://apps.apple.com/app/fortune';
    final playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.beyond.fortune';
    final inviteCode = currentUser?.id.substring(0, 8) ?? 'FORTUNE2024';

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
