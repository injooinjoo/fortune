import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    
    // 로고 회전 애니메이션
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // 2초 후 인증 확인
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    print('🚀 SplashScreen: Starting auth check...');
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      print('⚠️ SplashScreen: Widget not mounted, returning');
      return;
    }

    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    print('🔐 SplashScreen: Session status - ${session != null ? 'Authenticated' : 'Not authenticated'}');

    if (session != null) {
      try {
        print('👤 SplashScreen: Checking user profile for user ${session.user.id}');
        final profileResponse = await supabase
            .from('user_profiles')
            .select()
            .eq('id', session.user.id)
            .maybeSingle();

        print('📋 SplashScreen: Profile response - $profileResponse');

        if (profileResponse == null ||
            profileResponse['onboarding_completed'] != true ||
            profileResponse['name'] == null ||
            profileResponse['birth_date'] == null ||
            profileResponse['gender'] == null) {
          print('➡️ SplashScreen: Redirecting to onboarding');
          context.go('/onboarding');
        } else {
          print('➡️ SplashScreen: Redirecting to home');
          context.go('/home');
        }
      } catch (e) {
        print('❌ SplashScreen: Error checking profile: $e');
        context.go('/onboarding');
      }
    } else {
      print('➡️ SplashScreen: No session, redirecting to landing');
      context.go('/');
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            );
          },
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