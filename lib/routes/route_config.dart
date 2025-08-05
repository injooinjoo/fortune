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

// import '../features/profile/presentation/pages/statistics_detail_page.dart';
// import '../features/profile/presentation/pages/profile_verification_page.dart';
// import '../features/misc/presentation/pages/consult_page.dart';
// import '../features/misc/presentation/pages/explore_page.dart';
// import '../features/misc/presentation/pages/special_page.dart';
// import '../features/misc/presentation/pages/wish_wall_page.dart';
// import '../features/trend/presentation/pages/trend_page.dart';
// import '../features/notification/presentation/pages/notification_settings_page.dart';
// import '../features/admin/presentation/pages/admin_dashboard_page.dart';
// import '../features/admin/presentation/pages/redis_monitor_page.dart';
// import '../features/admin/presentation/pages/token_usage_stats_page.dart';
// import '../features/support/presentation/pages/customer_support_page.dart';
// import '../features/support/presentation/pages/help_page.dart';
// import '../features/about/presentation/pages/about_page.dart';
// import '../features/policy/presentation/pages/policy_page.dart';
// import '../features/policy/presentation/pages/privacy_policy_page.dart';
// import '../features/policy/presentation/pages/terms_of_service_page.dart';
// import '../features/history/presentation/pages/fortune_history_page.dart';
// import '../features/feedback/presentation/pages/feedback_page.dart';
// import '../presentation/pages/todo/todo_list_page.dart';
// import '../features/payment/presentation/pages/token_purchase_page_v2.dart';
// import '../screens/payment/token_history_page.dart';
// import '../screens/subscription/subscription_page.dart';

// // Import route groups
// import 'routes/auth_routes.dart';
// import 'routes/fortune_routes.dart';
// import 'routes/interactive_routes.dart';

import '../core/utils/profile_validation.dart';
import '../services/storage_service.dart';


// Temporary empty route lists
const authRoutes = <RouteBase>[];
const fortuneRoutes = <RouteBase>[];
const interactiveRoutes = <RouteBase>[];

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
      // Splash route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Landing route
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      GoRoute(
        path: '/auth/callback',
        name: 'callback',
        builder: (context, state) => const CallbackPage(),
      ),
      
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const TossStyleOnboardingPage(),
      ),
      
      // Non-authenticated routes
      ...authRoutes,
      
      // Fortune routes
      ...fortuneRoutes,
      
      // Interactive routes
      ...interactiveRoutes,
      
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
        ],
      ),
    ],
  );
});