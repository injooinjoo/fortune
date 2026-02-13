import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/callback_page.dart';
import '../../screens/onboarding/onboarding_page.dart';
import '../../core/utils/page_transitions.dart';

final authRoutes = [
  // 루트 경로는 /chat으로 리다이렉트 (Chat-First)
  GoRoute(
    path: '/',
    name: 'root',
    redirect: (context, state) => '/chat',
  ),
  GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => PageTransitions.noTransition(
            context,
            state,
            const SplashScreen(),
          )),
  GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen()),
  GoRoute(
      path: '/auth/callback',
      name: 'auth-callback',
      builder: (context, state) => const CallbackPage()),
  GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage()),
  // GoRoute(
  //   path: '/onboarding/profile',
  //   name: 'onboarding-profile',
  //   builder: (context, state) => const OnboardingPageV2(),
  // ),
  // GoRoute(
  //   path: '/onboarding/flow',
  //   name: 'onboarding-flow',
  //   builder: (context, state) => const OnboardingFlowPage(),
  // )
];
