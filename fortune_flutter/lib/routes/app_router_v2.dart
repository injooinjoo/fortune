import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/fortune_metadata.dart';
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
import '../screens/onboarding/enhanced_onboarding_flow.dart';
import '../shared/layouts/main_shell.dart';
import '../screens/physiognomy/physiognomy_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../features/fortune/presentation/pages/fortune_list_page.dart';
import '../features/fortune/presentation/pages/dynamic_fortune_page.dart';
import '../features/about/presentation/pages/about_page.dart';
import '../features/policy/presentation/pages/policy_page.dart';
import '../features/policy/presentation/pages/privacy_policy_page.dart';
import '../features/policy/presentation/pages/terms_of_service_page.dart';
import '../features/payment/presentation/pages/token_purchase_page.dart';
import '../features/payment/presentation/pages/payment_success_page.dart';
import '../features/history/presentation/pages/fortune_history_page.dart';
import '../features/notification/presentation/pages/notification_settings_page.dart';
import '../features/support/presentation/pages/customer_support_page.dart';
import '../features/support/presentation/pages/faq_page.dart';
import '../core/utils/logger.dart';

final appRouterProviderV2 = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);
  
  // Listen to auth state changes
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    authNotifier.value = session != null;
    Logger.info('Auth state changed: ${session != null ? 'Authenticated' : 'Not authenticated'}');
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Landing Page
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingPage(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/callback',
        builder: (context, state) => const CallbackPage(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const EnhancedOnboardingFlow(),
      ),
      
      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/fortune-list',
            builder: (context, state) => const FortuneListPage(),
            routes: [
              // Dynamic fortune route that handles all fortune types
              GoRoute(
                path: ':fortuneType',
                builder: (context, state) {
                  final fortuneTypeKey = state.pathParameters['fortuneType']!;
                  final fortuneType = FortuneType.fromKey(fortuneTypeKey);
                  
                  if (fortuneType == null) {
                    // Handle unknown fortune type
                    return Scaffold(
                      appBar: AppBar(title: const Text('오류')),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            SizedBox(height: AppSpacing.spacing4),
                            Text('알 수 없는 운세 타입: $fortuneTypeKey'),
                            SizedBox(height: AppSpacing.spacing4),
                            ElevatedButton(
                              onPressed: () => context.go('/fortune-list'),
                              child: const Text('목록으로 돌아가기'),
                            ),
                          ],
                        ),
                      )
                    );
                  }
                  
                  return DynamicFortunePage(fortuneType: fortuneType);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const ProfileEditPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/premium',
            builder: (context, state) => const PremiumScreen(),
          ),
          GoRoute(
            path: '/physiognomy',
            builder: (context, state) => const PhysiognomyScreen(),
          ),
        ],
      ),
      
      // Settings and related pages
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'social-accounts',
            builder: (context, state) => const SocialAccountsScreen(),
          ),
          GoRoute(
            path: 'phone-management',
            builder: (context, state) => const PhoneManagementScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationSettingsPage(),
          ),
        ],
      ),
      
      // Payment
      GoRoute(
        path: '/token-purchase',
        builder: (context, state) => const TokenPurchasePage(),
      ),
      GoRoute(
        path: '/payment-success',
        builder: (context, state) {
          final productId = state.extra as String?;
          return PaymentSuccessPage(productId: productId);
        },
      ),
      
      // History
      GoRoute(
        path: '/fortune-history',
        builder: (context, state) => const FortuneHistoryPage(),
      ),
      
      // Support
      GoRoute(
        path: '/support',
        builder: (context, state) => const CustomerSupportPage(),
        routes: [
          GoRoute(
            path: 'faq',
            builder: (context, state) => const FaqPage(),
          ),
        ],
      ),
      
      // Policy pages
      GoRoute(
        path: '/policy',
        builder: (context, state) => const PolicyPage(),
        routes: [
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacyPolicyPage(),
          ),
          GoRoute(
            path: 'terms',
            builder: (context, state) => const TermsOfServicePage(),
          ),
        ],
      ),
      
      // About
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
    ],
    
    // Redirect logic
    redirect: (context, state) {
      final isAuthenticated = authNotifier.value;
      final isAuthRoute = state.matchedLocation == '/landing' || 
                         state.matchedLocation == '/signup' ||
                         state.matchedLocation == '/callback';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isSplash = state.matchedLocation == '/splash';
      
      // Always allow splash screen
      if (isSplash) return null;
      
      // If not authenticated and not on auth route, redirect to landing
      if (!isAuthenticated && !isAuthRoute) {
        return '/landing';
      }
      
      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isAuthRoute && !isOnboarding) {
        return '/home';
      }
      
      return null;
    },
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('오류')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: AppSpacing.spacing4),
            const Text(
              '페이지를 찾을 수 없습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.spacing2),
            Text(
              state.error?.toString() ?? '알 수 없는 오류가 발생했습니다',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            SizedBox(height: AppSpacing.spacing6),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    )
  );
});

// Helper function to generate fortune routes dynamically
List<RouteBase> _generateFortuneRoutes() {
  return FortuneType.values.map((type) {
    return GoRoute(
      path: type.key,
      builder: (context, state) => DynamicFortunePage(fortuneType: type),
    );
  }).toList();
}