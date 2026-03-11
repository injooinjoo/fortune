import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/onboarding/onboarding_page.dart';
import '../features/policy/presentation/pages/privacy_policy_page.dart';
import '../features/policy/presentation/pages/terms_of_service_page.dart';
import '../screens/profile/account_deletion_page.dart';

// Retained product surfaces
import '../features/character/presentation/pages/swipe_home_shell.dart';
import '../features/fortune/presentation/pages/manseryeok_page.dart';

import 'routes/auth_routes.dart';
import 'character_routes.dart';

import '../core/theme/theme_keys.dart';
import '../core/utils/page_transitions.dart';
import '../core/utils/route_observer_logger.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    observers: kDebugMode ? [RouteObserverLogger()] : [],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
    routes: [
      ...authRoutes,
      GoRoute(
        path: '/onboarding/toss-style',
        name: 'onboarding-toss-style',
        builder: (context, state) {
          final isPartial = state.uri.queryParameters['partial'] == 'true';
          return OnboardingPage(isPartialCompletion: isPartial);
        },
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) => PageTransitions.noTransition(
          context,
          state,
          const SwipeHomeShell(),
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        redirect: (context, state) => '/chat',
      ),
      GoRoute(
        path: '/manseryeok',
        name: 'manseryeok',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const ManseryeokPage(),
        ),
      ),
      GoRoute(
        path: '/account-deletion',
        name: 'account-deletion',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const AccountDeletionPage(),
        ),
      ),
      ...characterRoutes,
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        builder: (context, state) => const TermsOfServicePage(),
      ),
    ],
  );
});
