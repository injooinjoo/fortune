import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/design_system/design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Failsafe: If still on splash after 3 seconds, force navigation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        debugPrint('⏰ SplashScreen: Failsafe triggered, forcing navigation to landing');
        context.go('/');
      }
    });

    // 인증 확인 시작
    _performAuthCheck();
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
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Image.asset(
          context.isDark
            ? 'assets/images/flower_transparent_white.png'
            : 'assets/images/flower_transparent.png',
          width: 120,
          height: 120,
        ).animate()
          .fadeIn(duration: 600.ms)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.easeOutBack,
          ),
      ),
    );
  }
}