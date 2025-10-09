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
import '../screens/profile/saju_detail_page.dart';
import '../screens/profile/elements_detail_page.dart';
import '../screens/profile/profile_verification_page.dart';
import '../features/history/presentation/pages/fortune_history_page.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/social_accounts_screen.dart';
import '../screens/settings/phone_management_screen.dart';
import '../screens/onboarding/onboarding_page.dart';
import '../shared/layouts/main_shell.dart';
import '../screens/premium/premium_screen.dart';

// Import feature pages
import '../features/trend/presentation/pages/trend_page.dart';
import '../features/fortune/presentation/pages/fortune_list_page.dart';
import '../features/notification/presentation/pages/notification_settings_page.dart';
import '../features/support/presentation/pages/help_page.dart';
import '../features/policy/presentation/pages/privacy_policy_page.dart';
import '../features/policy/presentation/pages/terms_of_service_page.dart';
import '../features/history/presentation/pages/fortune_history_page.dart';
import '../features/payment/presentation/pages/token_purchase_page_v2.dart';

// Import pages that need to hide navigation bar
import '../features/fortune/presentation/pages/moving_fortune_toss_page.dart';
import '../features/fortune/presentation/pages/traditional_saju_toss_page.dart';
import '../features/fortune/presentation/pages/talisman_fortune_page.dart';
import '../features/fortune/presentation/pages/biorhythm_fortune_page.dart';
import '../features/fortune/presentation/pages/love/love_fortune_main_page.dart';
import '../features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart';
import '../features/fortune/presentation/pages/ex_lover_fortune_simple_page.dart';
import '../features/fortune/presentation/pages/ex_lover_emotional_result_page.dart';
import '../features/fortune/domain/models/ex_lover_simple_model.dart';
import '../features/fortune/presentation/pages/blind_date_fortune_page.dart';
import '../features/fortune/presentation/pages/investment_fortune_enhanced_page.dart';
import '../screens/subscription/subscription_page.dart';

// Import page classes for routes outside shell
import '../features/health/presentation/pages/health_fortune_toss_page.dart';
import '../features/sports/presentation/pages/sports_fortune_page.dart' show ExerciseFortunePage;
import '../features/fortune/presentation/pages/compatibility_page.dart';
import '../features/fortune/presentation/pages/avoid_people_fortune_page.dart';
// import '../features/fortune/presentation/pages/avoid_people_result_page.dart'; // Removed - file not found
// import '../features/fortune/domain/models/avoid_person_analysis.dart'; // Removed - file not found
// import '../features/fortune/presentation/pages/career_fortune_page.dart'; // Removed - unused
import '../features/fortune/presentation/pages/career_coaching_input_page.dart';
import '../features/fortune/presentation/pages/career_coaching_result_page.dart';
import '../features/fortune/domain/models/career_coaching_model.dart';
import '../features/fortune/presentation/pages/lucky_exam_fortune_page.dart';
import '../features/interactive/presentation/pages/fortune_cookie_page.dart';
import '../features/fortune/presentation/pages/celebrity_fortune_enhanced_page.dart';
import '../features/fortune/presentation/pages/pet_compatibility_page.dart';
import '../features/fortune/presentation/pages/family_fortune_unified_page.dart';
import '../features/fortune/presentation/pages/daily_calendar_fortune_page.dart';
// import '../features/fortune/presentation/pages/mbti_fortune_page.dart'; // Now in fortuneRoutes

// Import admin pages
import '../features/admin/pages/celebrity_crawling_page.dart';

// Import route groups
import 'routes/auth_routes.dart';
import 'routes/fortune_routes.dart';
import 'routes/interactive_routes.dart';

import '../core/utils/profile_validation.dart';
import '../core/utils/page_transitions.dart';
import '../services/storage_service.dart';
import '../core/utils/route_observer_logger.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false, // Disabled to prevent freezing on real devices
    observers: kDebugMode ? [RouteObserverLogger()] : [],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
    routes: [
      // Non-authenticated routes (outside shell)
      ...authRoutes,
      
      // Special onboarding route (not in shell)
      GoRoute(
        path: '/onboarding/toss-style',
        name: 'onboarding-toss-style',
        builder: (context, state) {
          final isPartial = state.uri.queryParameters['partial'] == 'true';
          return OnboardingPage(isPartialCompletion: isPartial);
        },
      ),
      
      // Shell route that provides persistent navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(
          child: child,
          state: state,
        ),
        routes: [
          // Home route
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const HomeScreen(),
            ),
          ),
          
          // Profile routes
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const ProfileScreen(),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'profile-edit',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const ProfileEditPage(),
                ),
              ),
              GoRoute(
                path: 'saju',
                name: 'profile-saju',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const SajuDetailPage(),
                ),
              ),
              GoRoute(
                path: 'elements',
                name: 'profile-elements',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const ElementsDetailPage(),
                ),
              ),
              GoRoute(
                path: 'verification',
                name: 'profile-verification',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const ProfileVerificationPage(),
                ),
              ),
              GoRoute(
                path: 'history',
                name: 'profile-history',
                pageBuilder: (context, state) => PageTransitions.slideTransition(
                  context,
                  state,
                  const FortuneHistoryPage(),
                ),
              ),
            ],
          ),
          
          // Premium & Payment routes
          GoRoute(
            path: '/premium',
            name: 'premium',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const PremiumScreen(),
            ),
          ),

          // Feature pages
          GoRoute(
            path: '/trend',
            name: 'trend',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const TrendPage(),
            ),
          ),

          // Main fortune page
          GoRoute(
            path: '/fortune',
            name: 'fortune',
            pageBuilder: (context, state) => PageTransitions.tabTransition(
              context,
              state,
              const FortuneListPage(),
            ),
          ),

          // Interactive routes (inside shell)
          ...interactiveRoutes,
        ],
      ),

      // Fortune routes (outside shell - no navigation bar for consistent UX)
      ...fortuneRoutes,

      // Settings routes (outside shell - no navigation bar)
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const SettingsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'social-accounts',
            name: 'social-accounts',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const SocialAccountsScreen(),
            ),
          ),
          GoRoute(
            path: 'phone-management',
            name: 'phone-management',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const PhoneManagementScreen(),
            ),
          ),
          GoRoute(
            path: 'notifications',
            name: 'notification-settings',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const NotificationSettingsPage(),
            ),
          ),
        ],
      ),
      
      // Fortune routes that need to hide navigation bar
      GoRoute(
        path: '/health-toss',
        name: 'fortune-health-toss',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const HealthFortuneTossPage(),
        ),
      ),
      GoRoute(
        path: '/exercise',
        name: 'fortune-exercise',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const ExerciseFortunePage(),
        ),
      ),
      GoRoute(
        path: '/sports-game',
        name: 'fortune-sports-game',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const ExerciseFortunePage(),
        ),
      ),
      
      // Fortune routes that need to hide navigation bar (additional)
      GoRoute(
        path: '/compatibility',
        name: 'fortune-compatibility',
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          return PageTransitions.slideTransition(
            context,
            state,
            CompatibilityPage(initialParams: params.isNotEmpty ? params : null),
          );
        },
      ),
      GoRoute(
        path: '/avoid-people',
        name: 'fortune-avoid-people',
        builder: (context, state) => const AvoidPeopleFortunePage(),
      ),
      GoRoute(
        path: '/career',
        name: 'fortune-career',
        builder: (context, state) => const CareerCoachingInputPage(),
      ),
      GoRoute(
        path: '/career-coaching-result',
        name: 'career-coaching-result',
        builder: (context, state) {
          final input = state.extra as CareerCoachingInput?;
          if (input == null) {
            return const CareerCoachingInputPage();
          }
          return CareerCoachingResultPage(input: input);
        },
      ),
      GoRoute(
        path: '/lucky-exam',
        name: 'fortune-lucky-exam',
        builder: (context, state) => const LuckyExamFortunePage(),
      ),
      // MBTI - now included in fortuneRoutes (moved back to basic_fortune_routes.dart)
      
      
      // Fortune Cookie (outside shell - no navigation bar)
      GoRoute(
        path: '/fortune-cookie',
        name: 'fortune-cookie',
        builder: (context, state) => const FortuneCookiePage(),
      ),
      
      // Celebrity Fortune (outside shell - no navigation bar)
      GoRoute(
        path: '/celebrity',
        name: 'fortune-celebrity',
        builder: (context, state) => const CelebrityFortuneEnhancedPage(),
      ),
      
      
      // Family Fortune (outside shell - no navigation bar)
      GoRoute(
        path: '/family',
        name: 'fortune-family',
        builder: (context, state) => const FamilyFortuneUnifiedPage(),
      ),
      
      // Pet Compatibility (outside shell - no navigation bar)
      GoRoute(
        path: '/pet',
        name: 'fortune-pet',
        builder: (context, state) => const PetCompatibilityPage(
          fortuneType: 'pet-compatibility',
          title: '반려동물 궁합',
          description: '나와 반려동물의 궁합을 확인해보세요'
        )),
      
      // Other routes outside shell
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: '/token-purchase',
        name: 'token-purchase',
        builder: (context, state) => const TokenPurchasePageV2(),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),
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
      
      // Fortune routes that need to hide navigation bar
      GoRoute(
        path: '/moving',
        name: 'fortune-moving',
        builder: (context, state) => const MovingFortuneTossPage(),
      ),
      GoRoute(
        path: '/daily-calendar',
        name: 'fortune-daily-calendar',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DailyCalendarFortunePage(initialParams: extra);
        },
      ),
      GoRoute(
        path: '/traditional-saju',
        name: 'fortune-traditional-saju',
        builder: (context, state) => const TraditionalSajuTossPage(),
      ),
      // Physiognomy route removed - page deleted
      GoRoute(
        path: '/lucky-talisman',
        name: 'fortune-lucky-talisman',
        builder: (context, state) => const TalismanFortunePage(),
      ),
      GoRoute(
        path: '/biorhythm',
        name: 'fortune-biorhythm',
        builder: (context, state) => const BiorhythmFortunePage(),
      ),
      GoRoute(
        path: '/love',
        name: 'fortune-love',
        builder: (context, state) => const LoveFortuneMainPage(),
      ),
      GoRoute(
        path: '/ex-lover-enhanced',
        name: 'fortune-ex-lover-enhanced',
        builder: (context, state) => const ExLoverFortuneEnhancedPage(),
      ),
      GoRoute(
        path: '/ex-lover-simple',
        name: 'fortune-ex-lover-simple',
        builder: (context, state) => const ExLoverFortuneSimplePage(),
      ),
      GoRoute(
        path: '/ex-lover-emotional-result',
        name: 'fortune-ex-lover-emotional-result',
        builder: (context, state) {
          final input = state.extra as ExLoverSimpleInput?;
          if (input == null) {
            return const ExLoverFortuneSimplePage();
          }
          return ExLoverEmotionalResultPage(input: input);
        },
      ),
      GoRoute(
        path: '/investment-enhanced',
        name: 'fortune-investment-enhanced',
        builder: (context, state) => const InvestmentFortuneEnhancedPage(),
      ),
      
      // Blind Date Fortune (with Edge Function)
      GoRoute(
        path: '/blind-date',
        name: 'fortune-blind-date',
        builder: (context, state) => const BlindDateFortunePage(),
      ),

      // Admin routes (outside shell - no navigation bar)
      GoRoute(
        path: '/admin/celebrity-crawling',
        name: 'admin-celebrity-crawling',
        builder: (context, state) => const CelebrityCrawlingPage(),
      ),
    ],
  );
});