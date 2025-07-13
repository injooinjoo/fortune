import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/shared/components/fortune_loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    if (session != null) {
      context.go('/home');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Top text "About Me"
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Text(
                'About Me',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ).animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: -0.2, end: 0),
            ),
            
            // Center logo
            Center(
              child: SvgPicture.asset(
                'assets/images/main_logo.svg',
                width: 120,
                height: 120,
                colorFilter: ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ).animate()
                .fadeIn(duration: 1000.ms)
                .scale(
                  begin: Offset(0.8, 0.8),
                  end: Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),
            ),
            
            // Bottom loading indicator
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: FortuneLoadingIndicator(
                  size: 30,
                  color: Colors.black87,
                  strokeWidth: 2.5,
                ).animate()
                  .fadeIn(delay: 1000.ms, duration: 600.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}