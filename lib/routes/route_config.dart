// route_config.dart - Router configuration separated into smaller, manageable files

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/splash_screen.dart';
import '../screens/landing_page.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/callback_page.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_edit_page.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/social_accounts_screen.dart';
import '../screens/settings/phone_management_screen.dart';
import '../screens/onboarding/onboarding_page.dart';
import '../screens/onboarding/toss_style_onboarding_page.dart';
import '../shared/layouts/main_shell.dart';
import '../screens/premium/premium_screen.dart';

// Import feature pages
import '../features/trend/presentation/pages/trend_page.dart';
import '../features/notification/presentation/pages/notification_settings_page.dart';
import '../features/support/presentation/pages/help_page.dart';
import '../features/policy/presentation/pages/privacy_policy_page.dart';
import '../features/policy/presentation/pages/terms_of_service_page.dart';
import '../features/history/presentation/pages/fortune_history_page.dart';
import '../features/payment/presentation/pages/token_purchase_page_v2.dart';
import '../screens/subscription/subscription_page.dart';

// Import route groups
import 'routes/auth_routes.dart';
import 'routes/fortune_routes.dart';
import 'routes/interactive_routes.dart';

import '../core/utils/profile_validation.dart';
import '../services/storage_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
    routes: [
      // Special onboarding route (not in auth routes)
      GoRoute(
        path: '/onboarding/toss-style',
        name: 'onboarding-toss-style',
        builder: (context, state) => const TossStyleOnboardingPage(),
      ),
      
      // Non-authenticated routes
      ...authRoutes,
      
      // Fortune routes
      ...fortuneRoutes,
      
      // Interactive routes
      ...interactiveRoutes,
      
      // Additional routes
      GoRoute(
        path: '/payment/tokens',
        name: 'token-purchase',
        builder: (context, state) => const TokenPurchasePageV2(),
      ),
      
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),
      
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),
      
      GoRoute(
        path: '/policy/privacy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      
      GoRoute(
        path: '/policy/terms',
        name: 'terms-of-service',
        builder: (context, state) => const TermsOfServicePage(),
      ),
      
      // Home route with main shell
      ShellRoute(
        builder: (context, state, child) => MainShell(
          child: child,
          state: state,
        ),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/edit',
            name: 'profile-edit',
            builder: (context, state) => const ProfileEditPage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/settings/social-accounts',
            name: 'social-accounts',
            builder: (context, state) => const SocialAccountsScreen(),
          ),
          GoRoute(
            path: '/settings/phone-management',
            name: 'phone-management',
            builder: (context, state) => const PhoneManagementScreen(),
          ),
          GoRoute(
            path: '/premium',
            name: 'premium',
            builder: (context, state) => const PremiumScreen(),
          ),
          GoRoute(
            path: '/trend',
            name: 'trend',
            builder: (context, state) => const TrendPage(),
          ),
          GoRoute(
            path: '/settings/notifications',
            name: 'notification-settings',
            builder: (context, state) => const NotificationSettingsPage(),
          ),
          GoRoute(
            path: '/fortune/history',
            name: 'fortune-history',
            builder: (context, state) => const FortuneHistoryPage(),
          ),
        ],
      ),
    ],
  );
});