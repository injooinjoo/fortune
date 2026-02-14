import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/design_system/design_system.dart';
import '../services/app_version_service.dart';
import '../services/storage_service.dart';
import '../presentation/widgets/app_update_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _versionCheckBlocked = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();

    // Failsafe: If still on splash after 5 seconds (increased for version check), force navigation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_versionCheckBlocked) {
        debugPrint(
            '⏰ SplashScreen: Failsafe triggered, forcing navigation to chat');
        context.go('/chat');
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
    // Ensure splash is visible for at least 3 seconds for premium feel
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) {
      debugPrint('⚠️ SplashScreen: Widget not mounted, returning');
      return;
    }

    try {
      debugPrint('🔍 SplashScreen: Getting Supabase client');
      final supabase = Supabase.instance.client;
      debugPrint('🔐 SplashScreen: Resolving current session');
      final session = await _resolveSession(supabase);
      debugPrint(
          '🔐 SplashScreen: Session status - ${session != null ? 'Authenticated' : 'Not authenticated'}');

      if (session != null) {
        await _storageService.clearGuestMode();
        try {
          debugPrint(
              '👤 SplashScreen: Checking user profile for user ${session.user.id}');

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

          // Chat-First: 모든 경우 /chat으로 이동 (온보딩은 채팅 내에서 처리)
          if (profileResponse == null ||
              profileResponse['onboarding_completed'] != true) {
            debugPrint(
                '➡️ SplashScreen: Onboarding needed, redirecting to chat');
            context.go('/chat');
          } else if (profileResponse['name'] == null ||
              profileResponse['birth_date'] == null) {
            debugPrint(
                '➡️ SplashScreen: Missing essential fields, redirecting to chat');
            context.go('/chat');
          } else {
            // Profile complete - go to chat (Chat-First home)
            debugPrint(
                '➡️ SplashScreen: Profile complete, redirecting to chat');
            context.go('/chat');
          }
        } catch (e) {
          debugPrint('❌ SplashScreen: Error checking profile: $e');
          // Chat-First: 에러 시에도 채팅으로 이동
          if (mounted) context.go('/chat');
        }
      } else {
        await _storageService.setGuestMode(true);
        // Chat-First: 비로그인 사용자도 채팅으로 이동 (게스트 모드)
        debugPrint(
            '➡️ SplashScreen: No session, redirecting to chat (guest mode)');
        if (mounted) context.go('/chat');
      }
    } catch (e) {
      debugPrint('❌ SplashScreen: Critical error in auth check: $e');
      // Chat-First: 에러 시에도 채팅으로 이동
      if (mounted) context.go('/chat');
    }
  }

  Future<Session?> _resolveSession(SupabaseClient supabase) async {
    final currentSession = supabase.auth.currentSession;
    if (currentSession != null) {
      return currentSession;
    }

    try {
      final authState = await supabase.auth.onAuthStateChange
          .firstWhere((state) =>
              state.session != null &&
              (state.event == AuthChangeEvent.initialSession ||
                  state.event == AuthChangeEvent.signedIn ||
                  state.event == AuthChangeEvent.tokenRefreshed))
          .timeout(const Duration(seconds: 3));
      return authState.session;
    } catch (_) {
      return supabase.auth.currentSession;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: child,
              ),
            );
          },
          child: Text(
            '知',
            style: TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.w300,
              color: colors.textPrimary,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
