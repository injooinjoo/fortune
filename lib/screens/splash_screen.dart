import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

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
    await Future.delayed(Duration(milliseconds: 2000)); // Keeping explicit 2s for splash timing

    if (!mounted) return;

    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session != null) {
      try {
        final profileResponse = await supabase
            .from('user_profiles')
            .select()
            .eq('id', session.user.id)
            .maybeSingle();

        if (profileResponse == null ||
            profileResponse['onboarding_completed'] != true ||
            profileResponse['name'] == null ||
            profileResponse['birth_date'] == null ||
            profileResponse['gender'] == null) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      } catch (e) {
        debugPrint('Error checking profile: $e');
        context.go('/onboarding');
      }
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.fortuneTheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.cardBackground : AppColors.textPrimary,
      body: Center(
        child: SvgPicture.asset(
          'assets/images/main_logo.svg',
          width: theme.microInteractions.fabPressScale * 125,
          height: theme.microInteractions.fabPressScale * 125,
          colorFilter: ColorFilter.mode(
            isDark ? theme.primaryText : AppColors.textPrimaryDark,
            BlendMode.srcIn)).animate().fadeIn(duration: theme.animationDurations.veryLong)));
  }
}
