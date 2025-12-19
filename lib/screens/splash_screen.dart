import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/obangseok_colors.dart';
import '../core/components/loading_video_player.dart';
import '../services/app_version_service.dart';
import '../presentation/widgets/app_update_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _versionCheckBlocked = false;

  @override
  void initState() {
    super.initState();

    // Failsafe: If still on splash after 5 seconds (increased for version check), force navigation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_versionCheckBlocked) {
        debugPrint('⏰ SplashScreen: Failsafe triggered, forcing navigation to landing');
        context.go('/');
      }
    });

    // 버전 체크 → 인증 확인 순서로 진행
    _performVersionCheck();
  }

  /// 앱 버전 체크
  Future<void> _performVersionCheck() async {
    debugPrint('📱 SplashScreen: Starting version check');

    try {
      final versionService = AppVersionService();
      final versionInfo = await versionService.checkVersion();

      if (!mounted) return;

      switch (versionInfo.result) {
        case VersionCheckResult.forceUpdateRequired:
          debugPrint('🚨 SplashScreen: Force update required');
          _versionCheckBlocked = true;
          await AppUpdateDialog.showForceUpdate(context, versionInfo);
          // 다이얼로그가 닫히면 앱이 종료되거나 스토어로 이동함
          return;

        case VersionCheckResult.maintenance:
          debugPrint('🔧 SplashScreen: Maintenance mode');
          _versionCheckBlocked = true;
          await AppUpdateDialog.showMaintenance(context, versionInfo);
          return;

        case VersionCheckResult.updateAvailable:
          debugPrint('📦 SplashScreen: Optional update available');
          // 선택적 업데이트는 표시 후 진행
          await AppUpdateDialog.showOptionalUpdate(context, versionInfo);
          if (!mounted) return;
          _performAuthCheck();
          return;

        case VersionCheckResult.upToDate:
        case VersionCheckResult.checkFailed:
          // 최신 버전이거나 체크 실패 시 정상 진행
          debugPrint('✅ SplashScreen: Version check passed or skipped');
          _performAuthCheck();
          return;
      }
    } catch (e) {
      debugPrint('❌ SplashScreen: Version check error: $e');
      // 버전 체크 실패 시 정상 진행
      _performAuthCheck();
    }
  }

  Future<void> _performAuthCheck() async {
    debugPrint('🚀 SplashScreen: Starting auth check');
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      debugPrint('⚠️ SplashScreen: Widget not mounted, returning');
      return;
    }

    try {
      debugPrint('🔍 SplashScreen: Getting Supabase client');
      final supabase = Supabase.instance.client;
      debugPrint('🔐 SplashScreen: Checking current session');
      final session = supabase.auth.currentSession;
      debugPrint('🔐 SplashScreen: Session status - ${session != null ? 'Authenticated' : 'Not authenticated'}');

      if (session != null) {
        try {
          debugPrint('👤 SplashScreen: Checking user profile for user ${session.user.id}');

          // Add timeout to prevent hanging
          final profileResponse = await supabase
              .from('user_profiles')
              .select()
              .eq('id', session.user.id)
              .maybeSingle()
              .timeout(
                const Duration(seconds: 2),
                onTimeout: () {
                  debugPrint('⏱️ SplashScreen: Profile fetch timeout');
                  return null;
                },
              );

          debugPrint('📋 SplashScreen: Profile response - $profileResponse');

          if (!mounted) return;

          if (profileResponse == null ||
              profileResponse['onboarding_completed'] != true) {
            // No profile or onboarding not completed - go to full onboarding
            debugPrint('➡️ SplashScreen: Redirecting to onboarding');
            context.go('/onboarding/toss-style');
          } else if (profileResponse['name'] == null ||
                     profileResponse['birth_date'] == null) {
            // Has profile but missing essential fields - go to partial onboarding
            debugPrint('➡️ SplashScreen: Missing essential fields, redirecting to partial onboarding');
            context.go('/onboarding/toss-style?partial=true');
          } else {
            // Profile complete - go to home
            debugPrint('➡️ SplashScreen: Redirecting to home');
            context.go('/home');
          }
        } catch (e) {
          debugPrint('❌ SplashScreen: Error checking profile: $e');
          // If error while logged in, still go to landing for clean start
          if (mounted) context.go('/');
        }
      } else {
        // Always redirect non-logged-in users to landing page
        debugPrint('➡️ SplashScreen: No session, redirecting to landing page');
        if (mounted) context.go('/');
      }
    } catch (e) {
      debugPrint('❌ SplashScreen: Critical error in auth check: $e');
      // On any critical error, go to landing page
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // 수묵화 스타일 그라데이션 배경
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    ObangseokColors.heukLight,
                    ObangseokColors.heuk,
                    ObangseokColors.heukDark,
                  ]
                : [
                    ObangseokColors.misaekLight,
                    ObangseokColors.misaek,
                    ObangseokColors.misaekDark,
                  ],
          ),
        ),
        child: Stack(
          children: [
            // 한지 텍스처 오버레이
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.03 : 0.06,
                child: Image.asset(
                  'assets/images/hanji_texture.png',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                  color: isDark ? Colors.white : null,
                  colorBlendMode: isDark ? BlendMode.overlay : null,
                  errorBuilder: (context, error, stackTrace) {
                    // 텍스처 이미지가 없어도 gracefully 처리
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            // 로딩 비디오
            const Center(
              child: LoadingVideoPlayer(
                width: 200,
                height: 200,
                loop: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}