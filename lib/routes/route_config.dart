// route_config.dart - Router configuration separated into smaller, manageable files

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/splash_screen.dart';
import '../screens/landing_page.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/callback_page.dart';
// import '../screens/home/home_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/profile/profile_edit_page.dart';
// import '../screens/settings/settings_screen.dart';
// import '../screens/settings/social_accounts_screen.dart';
// import '../screens/settings/phone_management_screen.dart';
import '../screens/onboarding/onboarding_page.dart';
import '../screens/onboarding/toss_style_onboarding_page.dart';
// import '../shared/layouts/main_shell.dart';
// import '../screens/premium/premium_screen.dart';

// Import feature pages
// import '../features/trend/presentation/pages/trend_page.dart';
// import '../features/notification/presentation/pages/notification_settings_page.dart';
// import '../features/support/presentation/pages/help_page.dart';
// import '../features/policy/presentation/pages/privacy_policy_page.dart';
// import '../features/policy/presentation/pages/terms_of_service_page.dart';
// import '../features/history/presentation/pages/fortune_history_page.dart';
// import '../features/payment/presentation/pages/token_purchase_page_v2.dart';
// import '../screens/subscription/subscription_page.dart';

// Import route groups
import 'routes/auth_routes.dart';
// import 'routes/fortune_routes.dart';
// import 'routes/interactive_routes.dart';

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
    ],
  );
});