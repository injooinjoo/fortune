import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/daily_fortune_page.dart';
import '../../../features/fortune/presentation/pages/wealth_fortune_page.dart';
import '../../../features/fortune/presentation/pages/saju_page.dart';
import '../../../features/fortune/presentation/pages/zodiac_fortune_page.dart';
import '../../../features/fortune/presentation/pages/zodiac_animal_fortune_page.dart';
import '../../../features/fortune/presentation/pages/blood_type_fortune_page.dart';
import '../../../features/fortune/presentation/pages/mbti_fortune_page.dart';
import '../../../features/fortune/presentation/pages/destiny_fortune_page.dart';
import '../../../features/fortune/presentation/pages/past_life_fortune_page.dart';
import '../../../features/fortune/presentation/pages/wish_fortune_page.dart';
import '../../../features/fortune/presentation/pages/timeline_fortune_page.dart';
import '../../../features/fortune/presentation/pages/network_report_fortune_page.dart';
import '../../../features/fortune/presentation/pages/daily_inspiration_page.dart';
import '../../../features/history/presentation/pages/fortune_history_page.dart';

final basicFortuneRoutes = [
  // Saju (Four Pillars)
  GoRoute(
    path: '/saju',
    name: 'fortune-saju',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return SajuPage(
        initialParams: extra);
    }),
  
  // Zodiac
  GoRoute(
    path: '/zodiac',
    name: 'fortune-zodiac',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return ZodiacFortunePage(
        initialParams: extra);
    }),
  
  // Zodiac Animal
  GoRoute(
    path: '/zodiac-animal',
    name: 'fortune-zodiac-animal',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return ZodiacAnimalFortunePage(
        initialParams: extra);
    }),
  
  // Blood Type
  GoRoute(
    path: '/blood-type',
    name: 'fortune-blood-type',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return BloodTypeFortunePage(
        initialParams: extra);
    }),
  
  // MBTI
  GoRoute(
    path: '/mbti',
    name: 'fortune-mbti',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return MbtiFortunePage(
        initialParams: extra);
    }),
  
  // Wealth
  GoRoute(
    path: '/wealth',
    name: 'fortune-wealth',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return WealthFortunePage(
        initialParams: extra);
    }),
  
  // Destiny
  GoRoute(
    path: '/destiny',
    name: 'fortune-destiny',
    builder: (context, state) => const DestinyFortunePage()),
  
  // Past Life
  GoRoute(
    path: '/past-life',
    name: 'fortune-past-life',
    builder: (context, state) => const PastLifeFortunePage()),
  
  // Wish
  GoRoute(
    path: '/wish',
    name: 'fortune-wish',
    builder: (context, state) => const WishFortunePage()),
  
  // Timeline
  GoRoute(
    path: '/timeline',
    name: 'fortune-timeline',
    builder: (context, state) => const TimelineFortunePage()),
  
  // Network Report
  GoRoute(
    path: '/network-report',
    name: 'fortune-network-report',
    builder: (context, state) => const NetworkReportFortunePage()),
  
  // Daily Inspiration
  GoRoute(
    path: '/inspiration',
    name: 'fortune-inspiration',
    builder: (context, state) => const DailyInspirationPage()),
  
  // History
  GoRoute(
    path: '/history',
    name: 'fortune-history',
    builder: (context, state) => const FortuneHistoryPage())];