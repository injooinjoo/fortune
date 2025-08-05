import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/time_based_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/hourly_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/daily_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/today_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/tomorrow_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/weekly_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/monthly_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/yearly_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/new_year_page.dart' as fortune_pages;

final timeBasedRoutes = [
  // Time-based Fortune
  GoRoute(
    path: 'time',
    name: 'fortune-time',
    builder: (context, state) {
      final periodParam = state.uri.queryParameters['period'];
      fortune_pages.TimePeriod? initialPeriod;
      if (periodParam != null) {
        initialPeriod = fortune_pages.TimePeriod.values.firstWhere(
          (p) => p.value == periodParam,
          orElse: () => fortune_pages.TimePeriod.today);
      }
      
      // Pass extra data to the page
      final extra = state.extra as Map<String, dynamic>?;
      
      return fortune_pages.TimeBasedFortunePage(
        initialPeriod: initialPeriod ?? fortune_pages.TimePeriod.today,
        initialParams: extra);
    }),
  
  // Time-based redirect (for backward compatibility)
  GoRoute(
    path: 'time-based',
    name: 'fortune-time-based',
    redirect: (_, state) {
      final tabParam = state.uri.queryParameters['tab'];
      if (tabParam != null) {
        return '/fortune/time?period=$tabParam';
      }
      return '/fortune/time';
    }),
  
  // Hourly
  GoRoute(
    path: 'hourly',
    name: 'fortune-hourly',
    builder: (context, state) => const fortune_pages.HourlyFortunePage()),
  
  // Daily
  GoRoute(
    path: 'daily',
    name: 'fortune-daily',
    builder: (context, state) => const fortune_pages.DailyFortunePage()),
  
  // Today
  GoRoute(
    path: 'today',
    name: 'fortune-today',
    builder: (context, state) => const fortune_pages.TodayFortunePage()),
  
  // Tomorrow
  GoRoute(
    path: 'tomorrow',
    name: 'fortune-tomorrow',
    builder: (context, state) => const fortune_pages.TomorrowFortunePage()),
  
  // Weekly
  GoRoute(
    path: 'weekly',
    name: 'fortune-weekly',
    builder: (context, state) => const fortune_pages.WeeklyFortunePage()),
  
  // Monthly
  GoRoute(
    path: 'monthly',
    name: 'fortune-monthly',
    builder: (context, state) => const fortune_pages.MonthlyFortunePage()),
  
  // Yearly
  GoRoute(
    path: 'yearly',
    name: 'fortune-yearly',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return fortune_pages.TimeBasedFortunePage(
        initialPeriod: fortune_pages.TimePeriod.yearly,
        initialParams: extra);
    }),
  
  // New Year
  GoRoute(
    path: 'new-year',
    name: 'fortune-new-year',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return fortune_pages.TimeBasedFortunePage(
        initialPeriod: fortune_pages.TimePeriod.yearly,
        initialParams: extra);
    })];