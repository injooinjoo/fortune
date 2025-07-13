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
import '../screens/onboarding/onboarding_page.dart';
import '../screens/onboarding/onboarding_page_v2.dart';
import '../screens/onboarding/onboarding_flow_page.dart';
import '../screens/onboarding/enhanced_onboarding_flow.dart';
import '../shared/layouts/main_shell.dart';
import '../screens/physiognomy/physiognomy_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../features/fortune/presentation/pages/fortune_list_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/daily_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/today_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/tomorrow_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/weekly_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/monthly_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/saju_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/compatibility_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/love_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/wealth_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/mbti_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/zodiac_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/zodiac_animal_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/blood_type_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/career_fortune_page.dart' as fortune_pages;
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
import '../features/fortune/presentation/pages/salpuli_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/marriage_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/traditional_compatibility_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/couple_match_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/ex_lover_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/blind_date_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_golf_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_baseball_fortune_page.dart' as fortune_pages;
import '../features/about/presentation/pages/about_page.dart';
import '../features/policy/presentation/pages/policy_page.dart';
import '../features/policy/presentation/pages/privacy_policy_page.dart';
import '../features/policy/presentation/pages/terms_of_service_page.dart';
import '../features/fortune/presentation/pages/lucky_tennis_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_running_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_cycling_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_swim_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_investment_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/business_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_fishing_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_hiking_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_yoga_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_fitness_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/birth_season_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/biorhythm_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/birthdate_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/birthstone_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/avoid_people_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/celebrity_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/celebrity_match_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/chemistry_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/face_reading_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/five_blessings_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_job_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_outfit_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_series_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/moving_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/moving_date_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/network_report_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/new_year_fortune_page.dart' as fortune_pages;
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
import '../features/fortune/presentation/pages/yearly_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/startup_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_sidejob_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_exam_fortune_page.dart' as fortune_pages;
import '../features/fortune/presentation/pages/lucky_realestate_fortune_page.dart' as fortune_pages;
import '../features/payment/presentation/pages/token_purchase_page_v2.dart';
import '../screens/payment/token_history_page.dart';
import '../screens/subscription/subscription_page.dart';
import '../presentation/pages/todo/todo_list_page.dart';
import '../features/interactive/presentation/pages/fortune_cookie_page.dart';
import '../features/interactive/presentation/pages/interactive_list_page.dart';
import '../features/interactive/presentation/pages/dream_interpretation_page.dart';
import '../features/interactive/presentation/pages/psychology_test_page.dart';
import '../features/interactive/presentation/pages/tarot_card_page.dart';
import '../features/interactive/presentation/pages/face_reading_page.dart';
import '../features/interactive/presentation/pages/taemong_page.dart';
import '../features/interactive/presentation/pages/worry_bead_page.dart';
import '../features/interactive/presentation/pages/dream_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/redis_monitor_page.dart';
import '../features/admin/presentation/pages/token_usage_stats_page.dart';
import '../features/support/presentation/pages/customer_support_page.dart';
import '../features/history/presentation/pages/fortune_history_page.dart';
import '../features/feedback/presentation/pages/feedback_page.dart';
import '../features/misc/presentation/pages/consult_page.dart';
import '../features/misc/presentation/pages/explore_page.dart';
import '../features/misc/presentation/pages/special_page.dart';
import '../features/misc/presentation/pages/test_ads_page.dart';
import '../features/misc/presentation/pages/wish_wall_page.dart';
import '../features/feed/presentation/pages/feed_page.dart';
import '../core/utils/profile_validation.dart';
import '../services/storage_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Check if current URL is callback to preserve it
  final currentUri = Uri.base;
  final initialPath = currentUri.path.contains('/auth/callback') 
      ? currentUri.toString().replaceFirst(currentUri.origin, '')
      : '/';
  
  print('=== ROUTER INITIALIZATION ===');
  print('Current URI: $currentUri');
  print('Initial path: $initialPath');
  
  return GoRouter(
    initialLocation: initialPath,
    debugLogDiagnostics: true,
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
        '/signup',
        '/auth/callback',
        '/onboarding',
        '/onboarding/profile',
        '/onboarding/flow',
      ];
      
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
    },
    routes: [
      // Non-authenticated routes
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
        builder: (context, state) => const OnboardingFlowPage(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        name: 'onboarding-profile',
        builder: (context, state) => const OnboardingPageV2(),
      ),
      GoRoute(
        path: '/onboarding/flow',
        name: 'onboarding-flow',
        builder: (context, state) => const EnhancedOnboardingFlow(),
      ),
      
      // Main app shell with persistent navigation
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
            builder: (context, state) => const HomeScreen(),
          ),
          
          // Profile route (now top-level within shell)
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'profile-edit',
                builder: (context, state) => const ProfileEditPage(),
              ),
            ],
          ),
          
          // Physiognomy route
          GoRoute(
            path: '/physiognomy',
            name: 'physiognomy',
            builder: (context, state) => const PhysiognomyScreen(),
          ),
          
          // Premium route
          GoRoute(
            path: '/premium',
            name: 'premium',
            builder: (context, state) => const PremiumScreen(),
          ),
          
          // Feed route
          GoRoute(
            path: '/feed',
            name: 'feed',
            builder: (context, state) => const FeedPage(),
          ),
          
          // Admin routes
          GoRoute(
            path: '/admin',
            name: 'admin',
            builder: (context, state) => const AdminDashboardPage(),
            routes: [
              GoRoute(
                path: 'redis',
                name: 'admin-redis',
                builder: (context, state) => const RedisMonitorPage(),
              ),
              GoRoute(
                path: 'token-usage',
                name: 'admin-token-usage',
                builder: (context, state) => const TokenUsageStatsPage(),
              ),
            ],
          ),
          
          // Support route
          GoRoute(
            path: '/support',
            name: 'support',
            builder: (context, state) => const CustomerSupportPage(),
          ),
          
          // About route
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutPage(),
          ),
          
          // Policy routes
          GoRoute(
            path: '/policy',
            name: 'policy',
            builder: (context, state) => const PolicyPage(),
            routes: [
              GoRoute(
                path: 'privacy',
                name: 'privacy-policy',
                builder: (context, state) => const PrivacyPolicyPage(),
              ),
              GoRoute(
                path: 'terms',
                name: 'terms-of-service',
                builder: (context, state) => const TermsOfServicePage(),
              ),
            ],
          ),
          
          // TODO route
          GoRoute(
            path: '/todo',
            name: 'todo',
            builder: (context, state) => const TodoListPage(),
          ),
          
          // History route
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (context, state) => const FortuneHistoryPage(),
          ),
          
          // Feedback route
          GoRoute(
            path: '/feedback',
            name: 'feedback',
            builder: (context, state) => const FeedbackPage(),
          ),
          
          // Misc routes
          GoRoute(
            path: '/consult',
            name: 'consult',
            builder: (context, state) => const ConsultPage(),
          ),
          GoRoute(
            path: '/explore',
            name: 'explore',
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: '/special',
            name: 'special',
            builder: (context, state) => const SpecialPage(),
          ),
          GoRoute(
            path: '/test-ads',
            name: 'test-ads',
            builder: (context, state) => const TestAdsPage(),
          ),
          GoRoute(
            path: '/wish-wall',
            name: 'wish-wall',
            builder: (context, state) => const WishWallPage(),
          ),
          
          // Interactive routes
          GoRoute(
            path: '/interactive',
            name: 'interactive',
            builder: (context, state) => const InteractiveListPage(),
            routes: [
              GoRoute(
                path: 'fortune-cookie',
                name: 'interactive-fortune-cookie',
                builder: (context, state) => const FortuneCookiePage(),
              ),
              GoRoute(
                path: 'dream',
                name: 'interactive-dream',
                builder: (context, state) => const DreamInterpretationPage(),
              ),
              GoRoute(
                path: 'psychology-test',
                name: 'interactive-psychology-test',
                builder: (context, state) => const PsychologyTestPage(),
              ),
              GoRoute(
                path: 'tarot',
                name: 'interactive-tarot',
                builder: (context, state) => const TarotCardPage(),
              ),
              GoRoute(
                path: 'face-reading',
                name: 'interactive-face-reading',
                builder: (context, state) => const FaceReadingPage(),
              ),
              GoRoute(
                path: 'taemong',
                name: 'interactive-taemong',
                builder: (context, state) => const TaemongPage(),
              ),
              GoRoute(
                path: 'worry-bead',
                name: 'interactive-worry-bead',
                builder: (context, state) => const WorryBeadPage(),
              ),
              GoRoute(
                path: 'dream-journal',
                name: 'interactive-dream-journal',
                builder: (context, state) => const DreamPage(),
              ),
            ],
          ),
          
          // Fortune routes
          GoRoute(
            path: '/fortune',
            name: 'fortune',
            builder: (context, state) => const fortune_pages.FortuneListPage(),
            routes: [
          GoRoute(
            path: 'today',
            name: 'fortune-today',
            builder: (context, state) => const fortune_pages.TodayFortunePage(),
          ),
          GoRoute(
            path: 'tomorrow',
            name: 'fortune-tomorrow',
            builder: (context, state) => const fortune_pages.TomorrowFortunePage(),
          ),
          GoRoute(
            path: 'weekly',
            name: 'fortune-weekly',
            builder: (context, state) => const fortune_pages.WeeklyFortunePage(),
          ),
          GoRoute(
            path: 'monthly',
            name: 'fortune-monthly',
            builder: (context, state) => const fortune_pages.MonthlyFortunePage(),
          ),
          GoRoute(
            path: 'daily',
            name: 'fortune-daily',
            builder: (context, state) => const fortune_pages.DailyFortunePage(),
          ),
          GoRoute(
            path: 'saju',
            name: 'fortune-saju',
            builder: (context, state) => const fortune_pages.SajuPage(),
          ),
          GoRoute(
            path: 'compatibility',
            name: 'fortune-compatibility',
            builder: (context, state) => const fortune_pages.CompatibilityPage(),
          ),
          GoRoute(
            path: 'love',
            name: 'fortune-love',
            builder: (context, state) => const fortune_pages.LoveFortunePage(),
          ),
          GoRoute(
            path: 'wealth',
            name: 'fortune-wealth',
            builder: (context, state) => const fortune_pages.WealthFortunePage(),
          ),
          GoRoute(
            path: 'mbti',
            name: 'fortune-mbti',
            builder: (context, state) => const fortune_pages.MbtiFortunePage(),
          ),
          GoRoute(
            path: 'zodiac',
            name: 'fortune-zodiac',
            builder: (context, state) => const fortune_pages.ZodiacFortunePage(),
          ),
          GoRoute(
            path: 'zodiac-animal',
            name: 'fortune-zodiac-animal',
            builder: (context, state) => const fortune_pages.ZodiacAnimalFortunePage(),
          ),
          GoRoute(
            path: 'blood-type',
            name: 'fortune-blood-type',
            builder: (context, state) => const fortune_pages.BloodTypeFortunePage(),
          ),
          GoRoute(
            path: 'career',
            name: 'fortune-career',
            builder: (context, state) => const fortune_pages.CareerFortunePage(),
          ),
          GoRoute(
            path: 'health',
            name: 'fortune-health',
            builder: (context, state) => const fortune_pages.HealthFortunePage(),
          ),
          GoRoute(
            path: 'hourly',
            name: 'fortune-hourly',
            builder: (context, state) => const fortune_pages.HourlyFortunePage(),
          ),
          GoRoute(
            path: 'lucky-color',
            name: 'fortune-lucky-color',
            builder: (context, state) => const fortune_pages.LuckyColorFortunePage(),
          ),
          GoRoute(
            path: 'lucky-number',
            name: 'fortune-lucky-number',
            builder: (context, state) => const fortune_pages.LuckyNumberFortunePage(),
          ),
          GoRoute(
            path: 'lucky-food',
            name: 'fortune-lucky-food',
            builder: (context, state) => const fortune_pages.LuckyFoodFortunePage(),
          ),
          GoRoute(
            path: 'lucky-items',
            name: 'fortune-lucky-items',
            builder: (context, state) => const fortune_pages.LuckyItemsFortunePage(),
          ),
          GoRoute(
            path: 'lucky-place',
            name: 'fortune-lucky-place',
            builder: (context, state) => const fortune_pages.LuckyPlaceFortunePage(),
          ),
          GoRoute(
            path: 'tojeong',
            name: 'fortune-tojeong',
            builder: (context, state) => const fortune_pages.TojeongFortunePage(),
          ),
          GoRoute(
            path: 'traditional-saju',
            name: 'fortune-traditional-saju',
            builder: (context, state) => const fortune_pages.TraditionalSajuFortunePage(),
          ),
          GoRoute(
            path: 'palmistry',
            name: 'fortune-palmistry',
            builder: (context, state) => const fortune_pages.PalmistryFortunePage(),
          ),
          GoRoute(
            path: 'physiognomy',
            name: 'fortune-physiognomy',
            builder: (context, state) => const fortune_pages.PhysiognomyFortunePage(),
          ),
          GoRoute(
            path: 'salpuli',
            name: 'fortune-salpuli',
            builder: (context, state) => const fortune_pages.SalpuliFortunePage(),
          ),
          GoRoute(
            path: 'marriage',
            name: 'fortune-marriage',
            builder: (context, state) => const fortune_pages.MarriageFortunePage(),
          ),
          GoRoute(
            path: 'traditional-compatibility',
            name: 'fortune-traditional-compatibility',
            builder: (context, state) => const fortune_pages.TraditionalCompatibilityPage(),
          ),
          GoRoute(
            path: 'couple-match',
            name: 'fortune-couple-match',
            builder: (context, state) => const fortune_pages.CoupleMatchPage(),
          ),
          GoRoute(
            path: 'ex-lover',
            name: 'fortune-ex-lover',
            builder: (context, state) => const fortune_pages.ExLoverFortunePage(),
          ),
          GoRoute(
            path: 'blind-date',
            name: 'fortune-blind-date',
            builder: (context, state) => const fortune_pages.BlindDateFortunePage(),
          ),
          GoRoute(
            path: 'lucky-golf',
            name: 'fortune-lucky-golf',
            builder: (context, state) => const fortune_pages.LuckyGolfFortunePage(),
          ),
          GoRoute(
            path: 'lucky-baseball',
            name: 'fortune-lucky-baseball',
            builder: (context, state) => const fortune_pages.LuckyBaseballFortunePage(),
          ),
          GoRoute(
            path: 'lucky-tennis',
            name: 'fortune-lucky-tennis',
            builder: (context, state) => const fortune_pages.LuckyTennisFortunePage(),
          ),
          GoRoute(
            path: 'lucky-running',
            name: 'fortune-lucky-running',
            builder: (context, state) => const fortune_pages.LuckyRunningFortunePage(),
          ),
          GoRoute(
            path: 'lucky-cycling',
            name: 'fortune-lucky-cycling',
            builder: (context, state) => const fortune_pages.LuckyCyclingFortunePage(),
          ),
          GoRoute(
            path: 'lucky-swim',
            name: 'fortune-lucky-swim',
            builder: (context, state) => const fortune_pages.LuckySwimFortunePage(),
          ),
          GoRoute(
            path: 'lucky-investment',
            name: 'fortune-lucky-investment',
            builder: (context, state) => const fortune_pages.LuckyInvestmentFortunePage(),
          ),
          GoRoute(
            path: 'business',
            name: 'fortune-business',
            builder: (context, state) => const fortune_pages.BusinessFortunePage(),
          ),
          GoRoute(
            path: 'lucky-fishing',
            name: 'fortune-lucky-fishing',
            builder: (context, state) => const fortune_pages.LuckyFishingFortunePage(),
          ),
          GoRoute(
            path: 'lucky-hiking',
            name: 'fortune-lucky-hiking',
            builder: (context, state) => const fortune_pages.LuckyHikingFortunePage(),
          ),
          GoRoute(
            path: 'lucky-yoga',
            name: 'fortune-lucky-yoga',
            builder: (context, state) => const fortune_pages.LuckyYogaFortunePage(),
          ),
          GoRoute(
            path: 'lucky-fitness',
            name: 'fortune-lucky-fitness',
            builder: (context, state) => const fortune_pages.LuckyFitnessFortunePage(),
            ),
          GoRoute(
            path: 'birth-season',
            name: 'fortune-birth-season',
            builder: (context, state) => const fortune_pages.BirthSeasonFortunePage(),
          ),
          GoRoute(
            path: 'biorhythm',
            name: 'fortune-biorhythm',
            builder: (context, state) => const fortune_pages.BiorhythmFortunePage(),
          ),
          GoRoute(
            path: 'birthdate',
            name: 'fortune-birthdate',
            builder: (context, state) => const fortune_pages.BirthdateFortunePage(),
          ),
          GoRoute(
            path: 'birthstone',
            name: 'fortune-birthstone',
            builder: (context, state) => const fortune_pages.BirthstoneFortunePage(),
          ),
          GoRoute(
            path: 'avoid-people',
            name: 'fortune-avoid-people',
            builder: (context, state) => const fortune_pages.AvoidPeopleFortunePage(),
          ),
          GoRoute(
            path: 'celebrity',
            name: 'fortune-celebrity',
            builder: (context, state) => const fortune_pages.CelebrityFortunePage(),
          ),
          GoRoute(
            path: 'celebrity-match',
            name: 'fortune-celebrity-match',
            builder: (context, state) => const fortune_pages.CelebrityMatchPage(),
          ),
          GoRoute(
            path: 'chemistry',
            name: 'fortune-chemistry',
            builder: (context, state) => const fortune_pages.ChemistryFortunePage(),
          ),
          GoRoute(
            path: 'face-reading',
            name: 'fortune-face-reading',
            builder: (context, state) => const fortune_pages.FaceReadingFortunePage(),
          ),
          GoRoute(
            path: 'five-blessings',
            name: 'fortune-five-blessings',
            builder: (context, state) => const fortune_pages.FiveBlessingsFortunePage(),
          ),
          GoRoute(
            path: 'lucky-job',
            name: 'fortune-lucky-job',
            builder: (context, state) => const fortune_pages.LuckyJobFortunePage(),
          ),
          GoRoute(
            path: 'lucky-outfit',
            name: 'fortune-lucky-outfit',
            builder: (context, state) => const fortune_pages.LuckyOutfitFortunePage(),
          ),
          GoRoute(
            path: 'lucky-series',
            name: 'fortune-lucky-series',
            builder: (context, state) => const fortune_pages.LuckySeriesFortunePage(),
          ),
          GoRoute(
            path: 'moving',
            name: 'fortune-moving',
            builder: (context, state) => const fortune_pages.MovingFortunePage(),
          ),
          GoRoute(
            path: 'moving-date',
            name: 'fortune-moving-date',
            builder: (context, state) => const fortune_pages.MovingDateFortunePage(),
          ),
          GoRoute(
            path: 'network-report',
            name: 'fortune-network-report',
            builder: (context, state) => const fortune_pages.NetworkReportFortunePage(),
          ),
          GoRoute(
            path: 'new-year',
            name: 'fortune-new-year',
            builder: (context, state) => const fortune_pages.NewYearFortunePage(),
          ),
          GoRoute(
            path: 'personality',
            name: 'fortune-personality',
            builder: (context, state) => const fortune_pages.PersonalityFortunePage(),
          ),
          GoRoute(
            path: 'saju-psychology',
            name: 'fortune-saju-psychology',
            builder: (context, state) => const fortune_pages.SajuPsychologyFortunePage(),
          ),
          GoRoute(
            path: 'lucky-lottery',
            name: 'fortune-lucky-lottery',
            builder: (context, state) => const fortune_pages.LuckyLotteryFortunePage(),
          ),
          GoRoute(
            path: 'lucky-stock',
            name: 'fortune-lucky-stock',
            builder: (context, state) => const fortune_pages.LuckyStockFortunePage(),
          ),
          GoRoute(
            path: 'lucky-crypto',
            name: 'fortune-lucky-crypto',
            builder: (context, state) => const fortune_pages.LuckyCryptoFortunePage(),
          ),
          GoRoute(
            path: 'employment',
            name: 'fortune-employment',
            builder: (context, state) => const fortune_pages.EmploymentFortunePage(),
          ),
          GoRoute(
            path: 'talent',
            name: 'fortune-talent',
            builder: (context, state) => const fortune_pages.TalentFortunePage(),
          ),
          GoRoute(
            path: 'destiny',
            name: 'fortune-destiny',
            builder: (context, state) => const fortune_pages.DestinyFortunePage(),
          ),
          GoRoute(
            path: 'past-life',
            name: 'fortune-past-life',
            builder: (context, state) => const fortune_pages.PastLifeFortunePage(),
          ),
          GoRoute(
            path: 'wish',
            name: 'fortune-wish',
            builder: (context, state) => const fortune_pages.WishFortunePage(),
          ),
          GoRoute(
            path: 'timeline',
            name: 'fortune-timeline',
            builder: (context, state) => const fortune_pages.TimelineFortunePage(),
          ),
          GoRoute(
            path: 'talisman',
            name: 'fortune-talisman',
            builder: (context, state) => const fortune_pages.TalismanFortunePage(),
          ),
          GoRoute(
            path: 'yearly',
            name: 'fortune-yearly',
            builder: (context, state) => const fortune_pages.YearlyFortunePage(),
          ),
          GoRoute(
            path: 'startup',
            name: 'fortune-startup',
            builder: (context, state) => const fortune_pages.StartupFortunePage(),
          ),
          GoRoute(
            path: 'lucky-sidejob',
            name: 'fortune-lucky-sidejob',
            builder: (context, state) => const fortune_pages.LuckySideJobFortunePage(),
          ),
          GoRoute(
            path: 'lucky-exam',
            name: 'fortune-lucky-exam',
            builder: (context, state) => const fortune_pages.LuckyExamFortunePage(),
          ),
          GoRoute(
            path: 'lucky-realestate',
            name: 'fortune-lucky-realestate',
            builder: (context, state) => const fortune_pages.LuckyRealEstateFortunePage(),
          ),
          ],
        ),
      ],
    ),
    
    // Payment routes (outside shell - no bottom navigation)
    GoRoute(
      path: '/payment/tokens',
      name: 'token-purchase',
      builder: (context, state) => const TokenPurchasePageV2(),
    ),
    GoRoute(
      path: '/payment/history',
      name: 'token-history',
      builder: (context, state) => const TokenHistoryPage(),
    ),
    GoRoute(
      path: '/subscription',
      name: 'subscription',
      builder: (context, state) => const SubscriptionPage(),
    ),
  ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('페이지를 찾을 수 없습니다: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 가기'),
            ),
          ],
        ),
      ),
    ),
  );
});