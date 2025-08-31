import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/time_based_fortune_page.dart';
import '../../../features/fortune/presentation/pages/daily_calendar_fortune_page.dart';

final timeBasedRoutes = [
  // Time-based Fortune
  GoRoute(
    path: '/time',
    name: 'fortune-time',
    builder: (context, state) {
      final periodParam = state.uri.queryParameters['period'];
      TimePeriod? initialPeriod;
      if (periodParam != null) {
        initialPeriod = TimePeriod.values.firstWhere(
          (p) => p.value == periodParam,
          orElse: () => TimePeriod.tomorrow);
      }
      
      // Pass extra data to the page
      final extra = state.extra as Map<String, dynamic>?;
      
      return TimeBasedFortunePage(
        initialPeriod: initialPeriod ?? TimePeriod.tomorrow,
        initialParams: extra);
    }),
  
  // Time-based redirect (for backward compatibility)
  GoRoute(
    path: '/time-based',
    name: 'fortune-time-based',
    redirect: (_, state) {
      final tabParam = state.uri.queryParameters['tab'];
      if (tabParam != null) {
        return '/fortune/time?period=$tabParam';
      }
      return '/fortune/time';
    }),
  
  
  // Yearly
  GoRoute(
    path: '/yearly',
    name: 'fortune-yearly',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return TimeBasedFortunePage(
        initialPeriod: TimePeriod.yearly,
        initialParams: extra);
    }),
  
  // New Year
  GoRoute(
    path: '/new-year',
    name: 'fortune-new-year',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return TimeBasedFortunePage(
        initialPeriod: TimePeriod.yearly,
        initialParams: extra);
    })];