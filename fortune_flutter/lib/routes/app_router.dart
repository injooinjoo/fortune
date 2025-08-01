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
import '../screens/onboarding/onboarding_page_v2.dart';
import '../screens/onboarding/onboarding_flow_page.dart';
import '../screens/onboarding/enhanced_onboarding_flow.dart';
import '../shared/layouts/main_shell.dart';
import '../screens/premium/premium_screen.dart';
import '../features/fortune/presentation/pages/fortune_list_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/time_based_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/investment_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/sports_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/enhanced_sports_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/saju_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/compatibility_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/love_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/wealth_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/mbti_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/zodiac_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/zodiac_animal_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/blood_type_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/career_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/widgets/career_fortune_selector.dart';
import '../features/fortune/presentation/pages/career_seeker_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/health_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/hourly_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_color_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_number_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_food_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_items_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_place_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/tojeong_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/traditional_saju_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/palmistry_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/physiognomy_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/physiognomy_enhanced_page.dart';
import '../features/fortune/presentation/pages/physiognomy_input_page.dart';
import '../features/fortune/presentation/pages/physiognomy_result_page.dart';
import '../features/fortune/presentation/pages/salpuli_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/marriage_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/traditional_compatibility_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/couple_match_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/ex_lover_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/blind_date_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_golf_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_baseball_fortune_page.dart' as fortune_pages;
import '../features/about/presentation/pages/about_page.dart';
import '../features/policy/presentation/pages/policy_page.dart';
import '../features/policy/presentation/pages/privacy_policy_page.dart';
import '../features/policy/presentation/pages/terms_of_service_page.dart';
import '../features/notification/presentation/pages/notification_settings_page.dart';
import '../features/fortune/presentation/pages/lucky_tennis_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_running_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_cycling_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_swim_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_investment_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/business_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_fishing_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/investment_fortune_unified_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/investment_fortune_enhanced_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/investment_fortune_enhanced_page.dart';
import '../features/fortune/presentation/pages/investment_fortune_result_page.dart' as fortune_pages;
import '../domain/entities/fortune.dart';
import '../features/fortune/presentation/pages/lucky_items_unified_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/traditional_fortune_unified_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/health_sports_unified_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/pet_fortune_unified_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/family_fortune_unified_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/personality_fortune_unified_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_hiking_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_yoga_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_fitness_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/birth_season_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/biorhythm_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/birthdate_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/birthstone_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/avoid_people_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/celebrity_fortune_enhanced_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/celebrity_match_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/chemistry_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/face_reading_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/face_reading_unified_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/five_blessings_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_job_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_outfit_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_series_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/moving_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/moving_fortune_enhanced_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/moving_date_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/network_report_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/personality_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/saju_psychology_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_lottery_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_stock_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_crypto_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/employment_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/talent_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/destiny_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/past_life_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/wish_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/timeline_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/talisman_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/talisman_enhanced_page.dart';
import '../features/fortune/presentation/pages/startup_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_exam_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_realestate_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/pet_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/children_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/traditional_fortune_enhanced_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/traditional_fortune_result_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/pet_compatibility_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/fortune_best_practices_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/daily_inspiration_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/same_birthday_celebrity_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/batch_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/dream_fortune_chat_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/fortune_snap_scroll_page.dart' as fortune_pages;
import '../features/payment/presentation/pages/token_purchase_page_v2.dart';
import '../screens/payment/token_history_page.dart';
import '../screens/subscription/subscription_page.dart';
import '../presentation/pages/todo/todo_list_page.dart';
import '../features/interactive/presentation/pages/fortune_cookie_page.dart';
import '../features/interactive/presentation/pages/interactive_list_page.dart';
import '../features/interactive/presentation/pages/dream_interpretation_page.dart';
import '../features/interactive/presentation/pages/psychology_test_page.dart';
import '../features/interactive/presentation/pages/tarot_card_page.dart';
import '../features/interactive/presentation/pages/tarot_chat_page.dart';
import '../features/interactive/presentation/pages/tarot_animated_flow_page.dart';
import '../features/fortune/presentation/pages/tarot_storytelling_page.dart';
import '../features/fortune/presentation/pages/tarot_summary_page.dart';
import '../features/fortune/presentation/pages/tarot_deck_selection_page.dart';
import '../features/fortune/presentation/pages/tarot_enhanced_page.dart';
import '../features/fortune/presentation/pages/tarot_main_page.dart';
import '../features/interactive/presentation/pages/face_reading_page.dart';
import '../features/interactive/presentation/pages/taemong_page.dart';
import '../features/interactive/presentation/pages/worry_bead_page.dart';
import '../features/interactive/presentation/pages/dream_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/redis_monitor_page.dart';
import '../features/admin/presentation/pages/token_usage_stats_page.dart';
import '../features/support/presentation/pages/customer_support_page.dart';
import '../features/support/presentation/pages/help_page.dart';
import '../features/history/presentation/pages/fortune_history_page.dart';
import '../features/feedback/presentation/pages/feedback_page.dart';
import '../features/profile/presentation/pages/statistics_detail_page.dart';
// import '../screens/demo/fortune_snap_scroll_demo.dart'; // File not found
import '../features/profile/presentation/pages/profile_verification_page.dart';
import '../features/misc/presentation/pages/consult_page.dart';
import '../features/misc/presentation/pages/explore_page.dart';
import '../features/misc/presentation/pages/special_page.dart';
// import '../features/misc/presentation/pages/test_ads_page.dart'; // File not found
import '../features/misc/presentation/pages/wish_wall_page.dart';
import '../features/trend/presentation/pages/trend_page.dart';
import '../core/utils/profile_validation.dart';
import '../services/storage_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Check if current URL is callback to preserve it
  final currentUri = Uri.base;
  final initialPath = currentUri.path.contains('/auth/callback') 
      ? currentUri.toString().replaceFirst(currentUri.origin, '')
      : '/splash';
  
  print('=== ROUTER INITIALIZATION ===');
  print('Current URI: $currentUri');
  print('Initial path: $initialPath');
  
  return GoRouter(
    initialLocation: initialPath),
        debugLogDiagnostics: true),
        redirect: (context, state) async {
      print('=== ROUTER REDIRECT CHECK ===');
      print('Current path: ${state.matchedLocation}');
      print('Full URI: ${state.uri}');
      
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      final isAuth = session != null;
      
      print('Session exists: $isAuth');
      print('User ID: ${session?.user?.id}');
      
      // Define routes that don't require auth or profile
      final publicRoutes = [
        '/',
        '/splash',
        '/signup',
        '/auth/callback',
        '/onboarding',
        '/onboarding/profile',
        '/onboarding/flow';
      
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);
      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');
      
      print('Is public route: $isPublicRoute');
      print('Is onboarding route: $isOnboardingRoute');
      
      // Check if user is in guest mode
      final storageService = StorageService();
      final isGuest = await storageService.isGuestMode();
      
      // If not authenticated and not guest, and trying to access protected route
      if (!isAuth && !isGuest && !isPublicRoute) {
        print('Redirecting to landing page - no auth and not guest');
        return '/';
      }
      
      // Check profile completion for authenticated users
      // Skip check if already on onboarding, auth routes, or if user is a guest
      if (!isOnboardingRoute && state.matchedLocation != '/auth/callback' && state.matchedLocation != '/') {
        final storageService = StorageService();
        final isGuest = await storageService.isGuestMode();
        
        // Guests can access all routes without onboarding
        if (!isGuest) {
          final needsOnboarding = await ProfileValidation.needsOnboarding();
          print('Needs onboarding: $needsOnboarding');
          
          if (needsOnboarding) {
            print('Redirecting to onboarding - profile incomplete');
            return '/onboarding';
          }
        }
      }
      
      print('No redirect needed');
      print('=== END REDIRECT CHECK ===');
      return null;
    }
    routes: [
      // Non-authenticated routes
      GoRoute(
        path: '/',
        name: 'landing'),
        builder: (context, state) => const LandingPage()
      GoRoute(
        path: '/splash',
        name: 'splash'),
        builder: (context, state) => const SplashScreen()
      GoRoute(
        path: '/signup',
        name: 'signup'),
        builder: (context, state) => const SignupScreen()
      GoRoute(
        path: '/auth/callback',
        name: 'auth-callback'),
        builder: (context, state) => const CallbackPage()
      GoRoute(
        path: '/onboarding',
        name: 'onboarding'),
        builder: (context, state) => const OnboardingFlowPage()
      GoRoute(
        path: '/onboarding/profile',
        name: 'onboarding-profile'),
        builder: (context, state) => const OnboardingPageV2()
      GoRoute(
        path: '/onboarding/flow',
        name: 'onboarding-flow'),
        builder: (context, state) => const OnboardingFlowPage()
      
      // Main app shell with persistent navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(
          child: child),
        state: state),
      routes: [
          // Home route
          GoRoute(
            path: '/home',
            name: 'home'),
        builder: (context, state) => const HomeScreen(
              key: PageStorageKey('home_screen')))
          
          // Profile route (now top-level within shell,
          GoRoute(
            path: '/profile',
            name: 'profile'),
        builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'profile-edit'),
        builder: (context, state) => const ProfileEditPage()
              GoRoute(
                path: 'statistics',
                name: 'profile-statistics'),
        builder: (context, state) => const StatisticsDetailPage()
              GoRoute(
                path: 'verification',
                name: 'profile-verification'),
        builder: (context, state) => const ProfileVerificationPage())
          
          // Settings route
          GoRoute(
            path: '/settings',
            name: 'settings'),
        builder: (context, state) => const SettingsScreen()
          
          // Settings sub-routes
          GoRoute(
            path: '/settings/social-accounts',
            name: 'social-accounts'),
        builder: (context, state) => const SocialAccountsScreen()
          GoRoute(
            path: '/settings/phone',
            name: 'phone-management'),
        builder: (context, state) => const PhoneManagementScreen()
          GoRoute(
            path: '/settings/notifications',
            name: 'notification-settings'),
        builder: (context, state) => const NotificationSettingsPage()
          
          // Physiognomy route (redirect to enhanced page,
          GoRoute(
            path: '/physiognomy',
            name: 'physiognomy'),
        redirect: (_, __) => '/fortune/physiognomy'),
          
          // Premium route
          GoRoute(
            path: '/premium',
            name: 'premium'),
        builder: (context, state) => const PremiumScreen()
          
          // Trend route
          GoRoute(
            path: '/trend',
            name: 'trend'),
        builder: (context, state) => const TrendPage()
          
          // Admin routes
          GoRoute(
            path: '/admin',
            name: 'admin'),
        builder: (context, state) => const AdminDashboardPage(),
            routes: [
              GoRoute(
                path: 'redis',
                name: 'admin-redis'),
        builder: (context, state) => const RedisMonitorPage()
              GoRoute(
                path: 'token-usage',
                name: 'admin-token-usage'),
        builder: (context, state) => const TokenUsageStatsPage())
          
          // Support route
          GoRoute(
            path: '/support',
            name: 'support'),
        builder: (context, state) => const CustomerSupportPage()
          
          // Help route
          GoRoute(
            path: '/help',
            name: 'help'),
        builder: (context, state) => const HelpPage()
          
          // Demo routes
          GoRoute(
            path: '/demo/snap-scroll',
            name: 'demo-snap-scroll'),
        builder: (context, state) => const Scaffold(body: Center(chil,
      d: Text('FortuneSnapScrollDemo not found')))
          
          // Snap scroll fortune page
          GoRoute(
            path: '/fortune/snap-scroll',
            name: 'fortune-snap-scroll'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final fortuneTypes = extra?['fortuneTypes'] as List<String>? ?? 
                  ['daily', 'love', 'money', 'health', 'career'];
              final title = extra?['title'] as String? ?? '종합 운세';
              final description = extra?['description'] as String? ?? 
                  '여러 운세를 한 번에 확인하세요';
              
              return fortune_pages.FortuneSnapScrollPage(
                title: title),
        description: description),
        fortuneTypes: fortuneTypes)
            }),
          
          // About route
          GoRoute(
            path: '/about',
            name: 'about'),
        builder: (context, state) => const AboutPage()
          
          // Policy routes
          GoRoute(
            path: '/policy',
            name: 'policy'),
        builder: (context, state) => const PolicyPage(),
            routes: [
              GoRoute(
                path: 'privacy',
                name: 'privacy-policy'),
        builder: (context, state) => const PrivacyPolicyPage()
              GoRoute(
                path: 'terms',
                name: 'terms-of-service'),
        builder: (context, state) => const TermsOfServicePage())
          
          // TODO route
          GoRoute(
            path: '/todo',
            name: 'todo'),
        builder: (context, state) => const TodoListPage()
          
          // History route
          GoRoute(
            path: '/history',
            name: 'history'),
        builder: (context, state) => const FortuneHistoryPage()
          
          // Feedback route
          GoRoute(
            path: '/feedback',
            name: 'feedback'),
        builder: (context, state) => const FeedbackPage()
          
          // Misc routes
          GoRoute(
            path: '/consult',
            name: 'consult'),
        builder: (context, state) => const ConsultPage()
          GoRoute(
            path: '/explore',
            name: 'explore'),
        builder: (context, state) => const ExplorePage()
          GoRoute(
            path: '/special',
            name: 'special'),
        builder: (context, state) => const SpecialPage()
          GoRoute(
            path: '/test-ads',
            name: 'test-ads'),
        builder: (context, state) => const Scaffold(body: Center(chil,
      d: Text('TestAdsPage not found')))
          GoRoute(
            path: '/wish-wall',
            name: 'wish-wall'),
        builder: (context, state) => const WishWallPage()
          
          // Interactive routes
          GoRoute(
            path: '/interactive',
            name: 'interactive'),
        builder: (context, state) => const InteractiveListPage(),
            routes: [
              GoRoute(
                path: 'fortune-cookie',
                name: 'interactive-fortune-cookie'),
        builder: (context, state) => const FortuneCookiePage()
              GoRoute(
                path: 'dream',
                name: 'interactive-dream'),
        builder: (context, state) => const DreamInterpretationPage()
              GoRoute(
                path: 'psychology-test',
                name: 'interactive-psychology-test'),
        builder: (context, state) => const PsychologyTestPage()
              GoRoute(
                path: 'tarot',
                name: 'interactive-tarot'),
        builder: (context, state) {
                  // Use the new clean chat-style page
                  return const TarotChatPage();
                },
                routes: [
                  GoRoute(
                    path: 'storytelling',
                    name: 'tarot-storytelling'),
        builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return TarotStorytellingPage(
    selectedCards: extra?['selectedCards'] ?? [],
      spreadType: extra?['spreadType'] ?? 'three',
                        question: extra?['question'],
  )}),
                  GoRoute(
                    path: 'summary',
      name: 'tarot-summary'),
        builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return TarotSummaryPage(
    cards: extra?['cards'] ?? [],
      interpretations: extra?['interpretations'] ?? [],
                        spreadType: extra?['spreadType'] ?? 'three',
      question: extra?['question'],
  )}),
                  GoRoute(
                    path: 'deck-selection',
      name: 'interactive-tarot-deck-selection'),
        builder: (context, state) {
                      return TarotDeckSelectionPage(
    spreadType: state.uri.queryParameters['spreadType'],
                        initialQuestion: state.uri.queryParameters['question'],
  )}),
                  GoRoute(
                    path: 'animated-flow',
                    name: 'tarot-animated-flow'),
        builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return TarotAnimatedFlowPage(
    heroTag: extra?['heroTag'] as String?,
  )})
              GoRoute(
                path: 'face-reading',
      name: 'interactive-face-reading'),
        builder: (context, state) => const FaceReadingPage()
              GoRoute(
                path: 'taemong',
                name: 'interactive-taemong'),
        builder: (context, state) => const TaemongPage()
              GoRoute(
                path: 'worry-bead',
                name: 'interactive-worry-bead'),
        builder: (context, state) => const WorryBeadPage()
              GoRoute(
                path: 'dream-journal',
                name: 'interactive-dream-journal'),
        builder: (context, state) => const DreamPage())
          
          // Fortune routes
          GoRoute(
            path: '/fortune',
            name: 'fortune'),
        builder: (context, state) => const fortune_pages.FortuneListPage(),
            routes: [
          GoRoute(
            path: 'batch',
            name: 'fortune-batch'),
        builder: (context, state) => const fortune_pages.BatchFortunePage()
          GoRoute(
            path: 'time',
            name: 'fortune-time'),
        builder: (context, state) {
              final periodParam = state.uri.queryParameters['period'];
              fortune_pages.TimePeriod? initialPeriod;
              if (periodParam != null) {
                initialPeriod = fortune_pages.TimePeriod.values.firstWhere(
                  (p) => p.value == periodParam,
                  orElse: () => fortune_pages.TimePeriod.today)
              }
              
              // Pass extra data to the page
              final extra = state.extra as Map<String, dynamic>?;
              
              return fortune_pages.TimeBasedFortunePage(
                initialPeriod: initialPeriod ?? fortune_pages.TimePeriod.today),
        initialParams: extra
              );
            }),
          GoRoute(
            path: 'time-based',
            name: 'fortune-time-based'),
        redirect: (_, state) {
              final tabParam = state.uri.queryParameters['tab'];
              if (tabParam != null) {
                return '/fortune/time?period=$tabParam';
              }
              return '/fortune/time';
            }),
          GoRoute(
            path: 'saju',
      name: 'fortune-saju'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.SajuPage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'compatibility',
            name: 'fortune-compatibility'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.CompatibilityPage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'love',
            name: 'fortune-love'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.LoveFortunePage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'wealth',
            name: 'fortune-wealth'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.WealthFortunePage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'mbti',
            name: 'fortune-mbti'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.MbtiFortunePage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'zodiac',
            name: 'fortune-zodiac'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.ZodiacFortunePage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'zodiac-animal',
            name: 'fortune-zodiac-animal'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.ZodiacAnimalFortunePage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'blood-type',
            name: 'fortune-blood-type'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.BloodTypeFortunePage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'career',
            name: 'fortune-career'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              // If no specific type, show the selector
              final type = state.uri.queryParameters['type'];
              if (type == null) {
                return const CareerFortuneSelector();
              }
              // Otherwise show the original career fortune page
              return fortune_pages.CareerFortunePage(
    initialParams: extra,
  )}
            routes: [
              // Career sub-routes
              GoRoute(
                path: 'seeker',
                name: 'fortune-career-seeker'),
        builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return fortune_pages.CareerSeekerFortunePage(
    initialParams: extra,
  )}),
              GoRoute(
                path: 'change',
                name: 'fortune-career-change'),
        builder: (context, state) {
                  // TODO: Create CareerChangeFortunePage
                  return const Center(
    child: Text('Career Change Fortune - Coming Soon',
  )}),
              GoRoute(
                path: 'future',
                name: 'fortune-career-future'),
        builder: (context, state) {
                  // TODO: Create CareerFutureFortunePage
                  return const Center(
    child: Text('Career Future Fortune - Coming Soon',
  )}),
              GoRoute(
                path: 'freelance',
                name: 'fortune-career-freelance'),
        builder: (context, state) {
                  // TODO: Create FreelanceFortunePage
                  return const Center(
    child: Text('Freelance Fortune - Coming Soon',
  )}),
              GoRoute(
                path: 'startup',
                name: 'fortune-career-startup'),
        builder: (context, state) {
                  // TODO: Create StartupFortunePage
                  return const Center(
    child: Text('Startup Fortune - Coming Soon',
  )}),
              GoRoute(
                path: 'crisis',
                name: 'fortune-career-crisis'),
        builder: (context, state) {
                  // TODO: Create CareerCrisisFortunePage
                  return const Center(
    child: Text('Career Crisis Fortune - Coming Soon',
  )})
          GoRoute(
            path: 'health',
            name: 'fortune-health'),
        builder: (context, state) => const fortune_pages.HealthFortunePage()
          GoRoute(
            path: 'lucky-color',
            name: 'fortune-lucky-color'),
        builder: (context, state) => const fortune_pages.LuckyColorFortunePage()
          GoRoute(
            path: 'lucky-number',
            name: 'fortune-lucky-number'),
        builder: (context, state) => const fortune_pages.LuckyNumberFortunePage()
          GoRoute(
            path: 'lucky-food',
            name: 'fortune-lucky-food'),
        builder: (context, state) => const fortune_pages.LuckyFoodFortunePage()
          GoRoute(
            path: 'lucky-place',
            name: 'fortune-lucky-place'),
        builder: (context, state) => const fortune_pages.LuckyPlaceFortunePage()
          GoRoute(
            path: 'tojeong',
            name: 'fortune-tojeong'),
        builder: (context, state) => const fortune_pages.TojeongFortunePage()
          GoRoute(
            path: 'traditional-saju',
            name: 'fortune-traditional-saju'),
        builder: (context, state) => const fortune_pages.TraditionalSajuFortunePage()
          GoRoute(
            path: 'palmistry',
            name: 'fortune-palmistry'),
        builder: (context, state) => const fortune_pages.PalmistryFortunePage()
          GoRoute(
            path: 'physiognomy',
            name: 'fortune-physiognomy'),
        builder: (context, state) => const PhysiognomyEnhancedPage(),
            routes: [
              GoRoute(
                path: 'input',
                name: 'physiognomy-input'),
        builder: (context, state) => const PhysiognomyInputPage()
              GoRoute(
                path: 'result',
                name: 'physiognomy-result'),
        builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final data = extra?['data'] as PhysiognomyData?;
                  if (data == null) {
                    // If no data, redirect to main physiognomy page
                    return const PhysiognomyEnhancedPage();
                  }
                  return PhysiognomyResultPage(data: data);
                })
          GoRoute(
            path: 'physiognomy-old',
            name: 'fortune-physiognomy-old'),
        builder: (context, state) => const fortune_pages.PhysiognomyFortunePage()
          GoRoute(
            path: 'salpuli',
            name: 'fortune-salpuli'),
        builder: (context, state) => const fortune_pages.SalpuliFortunePage()
          GoRoute(
            path: 'marriage',
            name: 'fortune-marriage'),
        builder: (context, state) => const fortune_pages.MarriageFortunePage()
          GoRoute(
            path: 'traditional-compatibility',
            name: 'fortune-traditional-compatibility'),
        builder: (context, state) => const fortune_pages.TraditionalCompatibilityPage()
          GoRoute(
            path: 'couple-match',
            name: 'fortune-couple-match'),
        builder: (context, state) => const fortune_pages.CoupleMatchPage()
          GoRoute(
            path: 'ex-lover',
            name: 'fortune-ex-lover'),
        builder: (context, state) => const fortune_pages.ExLoverFortunePage()
          GoRoute(
            path: 'ex-lover-enhanced',
            name: 'fortune-ex-lover-enhanced'),
        builder: (context, state) => fortune_pages.ExLoverFortuneEnhancedPage(
              extras: state.extra as Map<String, dynamic>?)
            )
          GoRoute(
            path: 'blind-date',
      name: 'fortune-blind-date'),
        builder: (context, state) => const fortune_pages.BlindDateFortunePage()
          GoRoute(
            path: 'sports',
            name: 'fortune-sports'),
        builder: (context, state) {
              final sportParam = state.uri.queryParameters['type'];
              fortune_pages.SportType? initialType;
              if (sportParam != null) {
                initialType = fortune_pages.SportType.values.firstWhere(
                  (s) => s.value == sportParam,
                  orElse: () => fortune_pages.SportType.fitness)
              }
              return fortune_pages.SportsFortunePage(
    initialType: initialType ?? fortune_pages.SportType.fitness,
  )}),
          GoRoute(
            path: 'investment',
      name: 'fortune-investment'),
        builder: (context, state) => const fortune_pages.InvestmentFortuneUnifiedPage()
          GoRoute(
            path: 'investment-enhanced',
            name: 'fortune-investment-enhanced'),
        builder: (context, state) => const fortune_pages.InvestmentFortuneEnhancedPage(),
            routes: [
              GoRoute(
                path: 'result',
                name: 'fortune-investment-enhanced-result'),
        builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final fortune = extra?['fortune'] as Fortune?;
                  final investmentData = extra?['investmentData'] as InvestmentFortuneData?;
                  
                  if (fortune == null || investmentData == null) {
                    // If no data, redirect to main investment page
                    return const fortune_pages.InvestmentFortuneEnhancedPage();
                  }
                  
                  return fortune_pages.InvestmentFortuneResultPage(
                    fortune: fortune),
        investmentData: investmentData)
                })
          GoRoute(
            path: 'business',
            name: 'fortune-business'),
        builder: (context, state) => const fortune_pages.BusinessFortunePage()
          // Sports routes redirect to integrated sports page
          GoRoute(
            path: 'lucky-golf',
            name: 'fortune-lucky-golf'),
        redirect: (_, __) => '/fortune/sports?type=golf'),
          GoRoute(
            path: 'lucky-baseball',
      name: 'fortune-lucky-baseball'),
        redirect: (_, __) => '/fortune/sports?type=baseball'),
          GoRoute(
            path: 'lucky-tennis',
      name: 'fortune-lucky-tennis'),
        redirect: (_, __) => '/fortune/sports?type=tennis'),
          GoRoute(
            path: 'lucky-running',
      name: 'fortune-lucky-running'),
        redirect: (_, __) => '/fortune/sports?type=running'),
          GoRoute(
            path: 'lucky-cycling',
      name: 'fortune-lucky-cycling'),
        redirect: (_, __) => '/fortune/sports?type=cycling'),
          GoRoute(
            path: 'lucky-swim',
      name: 'fortune-lucky-swim'),
        redirect: (_, __) => '/fortune/sports?type=swimming'),
          GoRoute(
            path: 'lucky-fishing',
      name: 'fortune-lucky-fishing'),
        redirect: (_, __) => '/fortune/sports?type=fishing'),
          GoRoute(
            path: 'lucky-hiking',
      name: 'fortune-lucky-hiking'),
        redirect: (_, __) => '/fortune/sports?type=hiking'),
          GoRoute(
            path: 'lucky-yoga',
      name: 'fortune-lucky-yoga'),
        redirect: (_, __) => '/fortune/sports?type=yoga'),
          GoRoute(
            path: 'lucky-fitness',
      name: 'fortune-lucky-fitness'),
        redirect: (_, __) => '/fortune/sports?type=fitness'),
          GoRoute(
            path: 'birth-season',
      name: 'fortune-birth-season'),
        builder: (context, state) => const fortune_pages.BirthSeasonFortunePage()
          GoRoute(
            path: 'biorhythm',
            name: 'fortune-biorhythm'),
        builder: (context, state) => const fortune_pages.BiorhythmFortunePage()
          GoRoute(
            path: 'birthdate',
            name: 'fortune-birthdate'),
        builder: (context, state) => const fortune_pages.BirthdateFortunePage()
          GoRoute(
            path: 'birthstone',
            name: 'fortune-birthstone'),
        builder: (context, state) => const fortune_pages.BirthstoneFortunePage()
          GoRoute(
            path: 'avoid-people',
            name: 'fortune-avoid-people'),
        builder: (context, state) => const fortune_pages.AvoidPeopleFortunePage()
          GoRoute(
            path: 'celebrity',
            name: 'fortune-celebrity'),
        builder: (context, state) => const fortune_pages.CelebrityFortuneEnhancedPage()
          GoRoute(
            path: 'celebrity-match',
            name: 'fortune-celebrity-match'),
        builder: (context, state) => const fortune_pages.CelebrityMatchPage()
          GoRoute(
            path: 'same-birthday-celebrity',
            name: 'fortune-same-birthday-celebrity'),
        builder: (context, state) => const fortune_pages.SameBirthdayCelebrityFortunePage()
          GoRoute(
            path: 'chemistry',
            name: 'fortune-chemistry'),
        builder: (context, state) => const fortune_pages.ChemistryFortunePage()
          GoRoute(
            path: 'face-reading',
            name: 'fortune-face-reading'),
        builder: (context, state) => const fortune_pages.FaceReadingUnifiedPage()
          GoRoute(
            path: 'five-blessings',
            name: 'fortune-five-blessings'),
        builder: (context, state) => const fortune_pages.FiveBlessingsFortunePage()
          GoRoute(
            path: 'lucky-job',
            name: 'fortune-lucky-job'),
        builder: (context, state) => const fortune_pages.LuckyJobFortunePage()
          GoRoute(
            path: 'lucky-outfit',
            name: 'fortune-lucky-outfit'),
        builder: (context, state) => const fortune_pages.LuckyOutfitFortunePage()
          GoRoute(
            path: 'lucky-series',
            name: 'fortune-lucky-series'),
        builder: (context, state) => const fortune_pages.LuckySeriesFortunePage()
          GoRoute(
            path: 'moving',
            name: 'fortune-moving'),
        builder: (context, state) => const fortune_pages.MovingFortunePage()
          GoRoute(
            path: 'moving-enhanced',
            name: 'fortune-moving-enhanced'),
        builder: (context, state) => const fortune_pages.MovingFortuneEnhancedPage()
          GoRoute(
            path: 'moving-date',
            name: 'fortune-moving-date'),
        builder: (context, state) => const fortune_pages.MovingDateFortunePage()
          GoRoute(
            path: 'network-report',
            name: 'fortune-network-report'),
        builder: (context, state) => const fortune_pages.NetworkReportFortunePage()
          GoRoute(
            path: 'new-year',
            name: 'fortune-new-year'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.TimeBasedFortunePage(
                initialPeriod: fortune_pages.TimePeriod.yearly),
        initialParams: extra,
              );
            }),
          GoRoute(
            path: 'saju-psychology',
            name: 'fortune-saju-psychology'),
        builder: (context, state) => const fortune_pages.SajuPsychologyFortunePage()
          GoRoute(
            path: 'lucky-lottery',
            name: 'fortune-lucky-lottery'),
        builder: (context, state) => const fortune_pages.LuckyLotteryFortunePage()
          GoRoute(
            path: 'lucky-stock',
            name: 'fortune-lucky-stock'),
        builder: (context, state) => const fortune_pages.LuckyStockFortunePage()
          GoRoute(
            path: 'lucky-crypto',
            name: 'fortune-lucky-crypto'),
        builder: (context, state) => const fortune_pages.LuckyCryptoFortunePage()
          GoRoute(
            path: 'employment',
            name: 'fortune-employment'),
        builder: (context, state) => const fortune_pages.EmploymentFortunePage()
          GoRoute(
            path: 'talent',
            name: 'fortune-talent'),
        builder: (context, state) => const fortune_pages.TalentFortunePage()
          GoRoute(
            path: 'destiny',
            name: 'fortune-destiny'),
        builder: (context, state) => const fortune_pages.DestinyFortunePage()
          GoRoute(
            path: 'past-life',
            name: 'fortune-past-life'),
        builder: (context, state) => const fortune_pages.PastLifeFortunePage()
          GoRoute(
            path: 'dream',
            name: 'fortune-dream'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.DreamFortuneChatPage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'dream-chat',
            name: 'fortune-dream-chat'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.DreamFortuneChatPage(
    initialParams: extra,
  )}),
          GoRoute(
            path: 'wish',
            name: 'fortune-wish'),
        builder: (context, state) => const fortune_pages.WishFortunePage()
          GoRoute(
            path: 'timeline',
            name: 'fortune-timeline'),
        builder: (context, state) => const fortune_pages.TimelineFortunePage()
          GoRoute(
            path: 'talisman',
            name: 'fortune-talisman'),
        builder: (context, state) => const TalismanEnhancedPage()
          GoRoute(
            path: 'yearly',
            name: 'fortune-yearly'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return fortune_pages.TimeBasedFortunePage(
                initialPeriod: fortune_pages.TimePeriod.yearly),
        initialParams: extra,
              );
            }),
          GoRoute(
            path: 'startup',
            name: 'fortune-startup'),
        builder: (context, state) => const fortune_pages.StartupFortunePage()
          GoRoute(
            path: 'lucky-exam',
            name: 'fortune-lucky-exam'),
        builder: (context, state) => const fortune_pages.LuckyExamFortunePage()
          GoRoute(
            path: 'lucky-realestate',
            name: 'fortune-lucky-realestate'),
        builder: (context, state) => const fortune_pages.LuckyRealEstateFortunePage()
          GoRoute(
            path: 'best-practices',
            name: 'fortune-best-practices'),
        builder: (context, state) => const fortune_pages.FortuneBestPracticesPage()
          GoRoute(
            path: 'inspiration',
            name: 'fortune-inspiration'),
        builder: (context, state) => const fortune_pages.DailyInspirationPage()
          GoRoute(
            path: 'history',
            name: 'fortune-history'),
        builder: (context, state) => const FortuneHistoryPage()
          GoRoute(
            path: 'pet-compatibility',
            name: 'fortune-pet-compatibility'),
        builder: (context, state) => const fortune_pages.PetCompatibilityPage(
              fortuneType: 'pet-compatibility'),
        title: '반려동물 궁합'),
        description: '나와 반려동물의 궁합을 확인해보세요')
            )
          GoRoute(
            path: 'children',
            name: 'fortune-children'),
        builder: (context, state) => const fortune_pages.ChildrenFortunePage(
              fortuneType: 'children'),
        title: '자녀 운세'),
        description: '자녀와 관련된 운세를 확인해보세요'),
        specificFortuneType: 'children')
            )
          GoRoute(
            path: 'parenting',
            name: 'fortune-parenting'),
        builder: (context, state) => const fortune_pages.ChildrenFortunePage(
              fortuneType: 'parenting'),
        title: '육아 운세'),
        description: '육아와 관련된 운세를 확인해보세요'),
        specificFortuneType: 'parenting')
            )
          GoRoute(
            path: 'pregnancy',
            name: 'fortune-pregnancy'),
        builder: (context, state) => const fortune_pages.ChildrenFortunePage(
              fortuneType: 'pregnancy'),
        title: '태교 운세'),
        description: '태교와 관련된 운세를 확인해보세요'),
        specificFortuneType: 'pregnancy')
            )
          GoRoute(
            path: 'family-harmony',
            name: 'fortune-family-harmony'),
        builder: (context, state) => const fortune_pages.ChildrenFortunePage(
              fortuneType: 'family-harmony'),
        title: '가족 화합 운세'),
        description: '가족의 화합과 관련된 운세를 확인해보세요'),
        specificFortuneType: 'family-harmony')
            )
          GoRoute(
            path: 'lucky-items',
            name: 'fortune-lucky-items'),
        builder: (context, state) => const fortune_pages.LuckyItemsUnifiedPage()
          GoRoute(
            path: 'traditional',
            name: 'fortune-traditional'),
        builder: (context, state) => const fortune_pages.TraditionalFortuneUnifiedPage()
          GoRoute(
            path: 'traditional-unified',
            name: 'fortune-traditional-unified'),
        builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              if (extra != null && extra['fortuneData'] != null) {
                return fortune_pages.TraditionalFortuneResultPage(
    fortuneData: extra['fortuneData'],
  )}
              // If no fortune data, navigate to input page
              return const fortune_pages.TraditionalFortuneEnhancedPage();
            }),
          GoRoute(
            path: 'health-sports',
            name: 'fortune-health-sports'),
        builder: (context, state) => const fortune_pages.HealthSportsUnifiedPage()
          GoRoute(
            path: 'enhanced-sports',
            name: 'fortune-enhanced-sports'),
        builder: (context, state) => const fortune_pages.EnhancedSportsFortunePage()
          GoRoute(
            path: 'pet',
            name: 'fortune-pet'),
        builder: (context, state) => const fortune_pages.PetFortuneUnifiedPage()
          GoRoute(
            path: 'family',
            name: 'fortune-family'),
        builder: (context, state) => const fortune_pages.FamilyFortuneUnifiedPage()
          GoRoute(
            path: 'personality',
            name: 'fortune-personality'),
        builder: (context, state) => const fortune_pages.PersonalityFortuneUnifiedPage()
          GoRoute(
            path: 'tarot',
            name: 'fortune-tarot'),
        builder: (context, state) {
              return const TarotMainPage();
            },
            routes: [
              GoRoute(
                path: 'deck-selection',
                name: 'fortune-tarot-deck-selection'),
        builder: (context, state) {
                  return TarotDeckSelectionPage(
    spreadType: state.uri.queryParameters['spreadType'],
                    initialQuestion: state.uri.queryParameters['question'],
  )}),
              GoRoute(
                path: 'animated-flow',
                name: 'fortune-tarot-animated-flow'),
        builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return TarotAnimatedFlowPage(
    heroTag: extra?['heroTag'] as String?,
  )})))
    
    // Payment routes (outside shell - no bottom navigation,
    GoRoute(
      path: '/payment/tokens',
      name: 'token-purchase'),
        builder: (context, state) => const TokenPurchasePageV2()
    GoRoute(
      path: '/payment/history',
      name: 'token-history'),
        builder: (context, state) => const TokenHistoryPage()
    GoRoute(
      path: '/subscription',
      name: 'subscription'),
        builder: (context, state) => const SubscriptionPage()
  errorBuilder: (context, state) => Scaffold(
      body: Center(,
      child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              ),
              children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('페이지를 찾을 수 없습니다: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 가기'),
      ),
    ),
  );
});