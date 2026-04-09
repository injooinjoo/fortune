import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/design_system/design_system.dart';
import '../core/services/supabase_connection_service.dart';
import '../core/utils/logger.dart';
import '../core/widgets/paper_runtime_chrome.dart';
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

  SupabaseClient? _tryGetSupabaseClient() {
    if (!SupabaseConnectionService.isInitialized) {
      return null;
    }

    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    // Failsafe: If still on splash after 5 seconds (increased for version check), force navigation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_versionCheckBlocked) {
        Logger.debug(
            'SplashScreen: Failsafe triggered, forcing navigation to chat');
        context.go('/chat');
      }
    });

    // 버전 체크 → 인증 확인 순서로 진행
    _performVersionCheck();
  }

  /// 앱 버전 체크
  Future<void> _performVersionCheck() async {
    Logger.debug('SplashScreen: Starting version check');

    try {
      final versionService = AppVersionService();
      final versionInfo = await versionService.checkVersion();

      if (!mounted) return;

      switch (versionInfo.result) {
        case VersionCheckResult.forceUpdateRequired:
          Logger.debug('SplashScreen: Force update required');
          _versionCheckBlocked = true;
          await AppUpdateDialog.showForceUpdate(context, versionInfo);
          // 다이얼로그가 닫히면 앱이 종료되거나 스토어로 이동함
          return;

        case VersionCheckResult.maintenance:
          Logger.debug('SplashScreen: Maintenance mode');
          _versionCheckBlocked = true;
          await AppUpdateDialog.showMaintenance(context, versionInfo);
          return;

        case VersionCheckResult.updateAvailable:
          Logger.debug('SplashScreen: Optional update available');
          // 선택적 업데이트는 표시 후 진행
          await AppUpdateDialog.showOptionalUpdate(context, versionInfo);
          if (!mounted) return;
          _performAuthCheck();
          return;

        case VersionCheckResult.upToDate:
        case VersionCheckResult.checkFailed:
          // 최신 버전이거나 체크 실패 시 정상 진행
          Logger.debug('SplashScreen: Version check passed or skipped');
          _performAuthCheck();
          return;
      }
    } catch (e) {
      Logger.debug('SplashScreen: Version check error: $e');
      // 버전 체크 실패 시 정상 진행
      _performAuthCheck();
    }
  }

  Future<void> _performAuthCheck() async {
    Logger.debug('SplashScreen: Starting auth check');
    // Ensure splash is visible for at least 3 seconds for premium feel
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) {
      Logger.debug('SplashScreen: Widget not mounted, returning');
      return;
    }

    try {
      Logger.debug('SplashScreen: Getting Supabase client');
      final supabase = _tryGetSupabaseClient();
      if (supabase == null) {
        Logger.debug(
            'SplashScreen: Supabase unavailable, redirecting to chat (guest mode)');
        await _storageService.setGuestMode(true);
        if (mounted) context.go('/chat');
        return;
      }
      Logger.debug('SplashScreen: Resolving current session');
      final session = await _resolveSession(supabase);
      Logger.debug(
          'SplashScreen: Session status - ${session != null ? 'Authenticated' : 'Not authenticated'}');

      if (session != null) {
        await _storageService.clearGuestMode();
        try {
          Logger.debug(
              'SplashScreen: Checking user profile for user ${session.user.id}');

          // Add timeout to prevent hanging
          final profileResponse = await supabase
              .from('user_profiles')
              .select()
              .eq('id', session.user.id)
              .maybeSingle()
              .timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              Logger.debug('SplashScreen: Profile fetch timeout');
              return null;
            },
          );

          Logger.debug('SplashScreen: Profile response - $profileResponse');

          if (!mounted) return;

          // Chat-First: 모든 경우 /chat으로 이동 (온보딩은 채팅 내에서 처리)
          if (profileResponse == null ||
              profileResponse['onboarding_completed'] != true) {
            Logger.debug(
                'SplashScreen: Onboarding needed, redirecting to chat');
            context.go('/chat');
          } else if (profileResponse['name'] == null ||
              profileResponse['birth_date'] == null) {
            Logger.debug(
                'SplashScreen: Missing essential fields, redirecting to chat');
            context.go('/chat');
          } else {
            // Profile complete - go to chat (Chat-First home)
            Logger.debug(
                'SplashScreen: Profile complete, redirecting to chat');
            context.go('/chat');
          }
        } catch (e) {
          Logger.debug('SplashScreen: Error checking profile: $e');
          // Chat-First: 에러 시에도 채팅으로 이동
          if (mounted) context.go('/chat');
        }
      } else {
        await _storageService.setGuestMode(true);
        // Chat-First: 비로그인 사용자도 채팅으로 이동 (게스트 모드)
        Logger.debug(
            'SplashScreen: No session, redirecting to chat (guest mode)');
        if (mounted) context.go('/chat');
      }
    } catch (e) {
      Logger.debug('SplashScreen: Critical error in auth check: $e');
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
    final typography = context.typography;
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: colors.background,
      body: PaperRuntimeBackground(
        ringAlignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: spacing.xl),
        child: Column(
          children: [
            const Spacer(flex: 5),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PaperRuntimePanel(
                    elevated: false,
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DSRadius.xl),
                      child: Image.asset(
                        'assets/images/zpzg_logo_light.webp',
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  Text(
                    '대화로 시작하는 자기 발견',
                    style: typography.headingMedium.copyWith(
                      color: colors.textPrimary,
                      height: 1.16,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    '나만의 인사이트를 발견해보세요',
                    style: typography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: EdgeInsets.only(bottom: spacing.lg),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.textPrimary.withValues(alpha: 0.88),
                  ),
                  backgroundColor: colors.border.withValues(alpha: 0.32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
