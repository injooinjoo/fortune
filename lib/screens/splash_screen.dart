import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/toss_design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // 2초 후 인증 확인
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    print('🚀 SplashScreen: Starting auth check...');
    
    // Set a maximum timeout for the entire auth check process
    try {
      await Future.any([
        _performAuthCheck(),
        Future.delayed(const Duration(seconds: 7), () {
          print('⏰ SplashScreen: Maximum timeout reached, redirecting to landing');
          if (mounted) context.go('/');
        }),
      ]);
    } catch (e) {
      print('❌ SplashScreen: Auth check failed: $e');
      if (mounted) context.go('/');
    }
  }

  Future<void> _performAuthCheck() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      print('⚠️ SplashScreen: Widget not mounted, returning');
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      print('🔐 SplashScreen: Session status - ${session != null ? 'Authenticated' : 'Not authenticated'}');

      if (session != null) {
        try {
          print('👤 SplashScreen: Checking user profile for user ${session.user.id}');
          
          // Add timeout to prevent hanging
          final profileResponse = await supabase
              .from('user_profiles')
              .select()
              .eq('id', session.user.id)
              .maybeSingle()
              .timeout(
                const Duration(seconds: 3),
                onTimeout: () {
                  print('⏱️ SplashScreen: Profile fetch timeout');
                  return null;
                },
              );

          print('📋 SplashScreen: Profile response - $profileResponse');

          if (!mounted) return;

          if (profileResponse == null ||
              profileResponse['onboarding_completed'] != true) {
            // No profile or onboarding not completed - go to full onboarding
            print('➡️ SplashScreen: Redirecting to onboarding');
            context.go('/onboarding/toss-style');
          } else if (profileResponse['name'] == null ||
                     profileResponse['birth_date'] == null) {
            // Has profile but missing essential fields - go to partial onboarding
            print('➡️ SplashScreen: Missing essential fields, redirecting to partial onboarding');
            context.go('/onboarding/toss-style?partial=true');
          } else {
            // Profile complete - go to home
            print('➡️ SplashScreen: Redirecting to home');
            context.go('/home');
          }
        } catch (e) {
          print('❌ SplashScreen: Error checking profile: $e');
          // If error while logged in, still go to landing for clean start
          if (mounted) context.go('/');
        }
      } else {
        // Always redirect non-logged-in users to landing page
        print('➡️ SplashScreen: No session, redirecting to landing page');
        if (mounted) context.go('/');
      }
    } catch (e) {
      print('❌ SplashScreen: Critical error in auth check: $e');
      // On any critical error, go to landing page
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/app_icon.png',
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