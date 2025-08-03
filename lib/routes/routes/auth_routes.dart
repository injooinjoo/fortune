import 'package:go_router/go_router.dart';
import '../../screens/landing_page.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/callback_page.dart';
import '../../screens/onboarding/onboarding_page.dart';
// import '../../screens/onboarding/onboarding_page_v2.dart';
// import '../../screens/onboarding/onboarding_flow_page.dart';

final authRoutes = [
  GoRoute(
    path: '/',
    name: 'landing',
    builder: (context, state) => const LandingPage(),
  ),
  GoRoute(
    path: '/splash',
    name: 'splash',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: '/signup',
    name: 'signup',
    builder: (context, state) => const SignupScreen(),
  ),
  GoRoute(
    path: '/auth/callback',
    name: 'auth-callback',
    builder: (context, state) => const CallbackPage(),
  ),
  GoRoute(
    path: '/onboarding',
    name: 'onboarding',
    builder: (context, state) => const OnboardingPage(),
  ),
  // GoRoute(
  //   path: '/onboarding/profile',
  //   name: 'onboarding-profile',
  //   builder: (context, state) => const OnboardingPageV2(),
  // ),
  // GoRoute(
  //   path: '/onboarding/flow',
  //   name: 'onboarding-flow',
  //   builder: (context, state) => const OnboardingFlowPage(),
  // ),
];