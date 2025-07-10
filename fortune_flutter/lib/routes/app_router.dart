import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/splash_screen.dart';
import '../screens/landing_page.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/callback_page.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/onboarding_page.dart';
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
import '../screens/payment/token_purchase_page.dart';
import '../screens/payment/token_history_page.dart';
import '../screens/subscription/subscription_page.dart';
import '../presentation/pages/todo/todo_list_page.dart';

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
      
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/signup' ||
                         state.matchedLocation == '/' ||
                         state.matchedLocation == '/auth/callback';
      
      print('Is auth route: $isAuthRoute');
      
      // 인증이 필요한 경로에서 인증되지 않은 경우
      if (!isAuth && !isAuthRoute) {
        print('Redirecting to landing page - no auth');
        return '/';
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
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
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
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        name: 'onboarding-profile',
        builder: (context, state) => const OnboardingPage(),
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
          
          // TODO route
          GoRoute(
            path: '/todo',
            name: 'todo',
            builder: (context, state) => const TodoListPage(),
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
          ],
        ),
      ],
    ),
    
    // Payment routes (outside shell - no bottom navigation)
    GoRoute(
      path: '/payment/tokens',
      name: 'token-purchase',
      builder: (context, state) => const TokenPurchasePage(),
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