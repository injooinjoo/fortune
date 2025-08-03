import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/landing_page.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/callback_page.dart';
import '../screens/home/home_screen.dart';
import '../shared/layouts/main_shell.dart';
import '../screens/onboarding/onboarding_page.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../features/support/presentation/pages/help_page.dart';
import '../features/about/presentation/pages/about_page.dart';

final minimalRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) => const CallbackPage(),
      ),
      // Main app shell with persistent navigation
      /*ShellRoute(
        builder: (context, state, child) => MainShell(
          child: child,
          state: state,
        ),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(
              key: PageStorageKey('home_screen'),
            ),
          ),
        ],
      ),*/
      GoRoute(
        path: '/home',
        builder: (context, state) => MainShell(
          state: state,
          child: const HomeScreen(
            key: PageStorageKey('home_screen'),
          ),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/fortune',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('운세 목록')),
          body: const Center(
            child: Text('운세 목록 화면 - 나중에 실제 화면으로 교체'),
          ),
        ),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
});