import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/profile_validation.dart';
import 'landing_page_state.dart';
import 'landing_page_handlers.dart';
import 'widgets/index.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with WidgetsBindingObserver, LandingPageState, LandingPageHandlers {

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🎨 Building LandingPage: _isCheckingAuth=$isCheckingAuth, _isAuthProcessing=$isAuthProcessing');

    if (isCheckingAuth) {
      debugPrint('🅿️ Showing loading screen because _isCheckingAuth is true');
      return const LandingLoadingScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          // GPT-5 style gradient background
          const LandingGradientBackground(),

          // Animated blur effects
          const LandingAnimatedBlurEffects(),

          SafeArea(
            child: Column(
              children: [
                // Header with dark mode toggle
                const LandingThemeToggle(),

                // Main content
                Expanded(
                  child: LandingMainContent(
                    onStartPressed: startOnboarding,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation handlers that need context from the widget
  @override
  Future<void> checkAuthState() async {
    await super.checkAuthState();

    // Handle navigation after auth state check
    if (!mounted) return;

    // 실제 세션 확인 (Supabase에서 가져오기)
    final session = isSupabaseAvailable
        ? Supabase.instance.client.auth.currentSession
        : null;

    debugPrint('🔍 [LandingPage] checkAuthState: session=${session != null}');

    if (session != null) {
      final needsOnboarding = await ProfileValidation.needsOnboarding();
      debugPrint('🔍 [LandingPage] needsOnboarding=$needsOnboarding');

      if (!needsOnboarding && mounted) {
        final uri = Uri.base;
        final returnUrl = uri.queryParameters['returnUrl'];

        if (returnUrl != null) {
          debugPrint('🔍 [LandingPage] Navigating to returnUrl: $returnUrl');
          context.go(Uri.decodeComponent(returnUrl));
        } else {
          debugPrint('🔍 [LandingPage] Navigating to /home');
          context.go('/home');
        }
      }
    }
  }
}
