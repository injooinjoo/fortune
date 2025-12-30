import 'package:go_router/go_router.dart';
// import '../../../features/fortune/presentation/pages/time_based_fortune_page.dart'; // Removed - unused
import '../../../features/fortune/presentation/pages/daily_calendar_fortune_page.dart';

final timeBasedRoutes = [
  // Time-based Fortune
  GoRoute(
    path: '/time',
    name: 'fortune-time',
    builder: (context, state) {
      // TimeBasedFortunePage was removed, redirect to DailyCalendarFortunePage
      return const DailyCalendarFortunePage();
    }),
  
  // Time-based redirect (for backward compatibility)
  GoRoute(
    path: '/time-based',
    name: 'fortune-time-based',
    redirect: (_, state) {
      final tabParam = state.uri.queryParameters['tab'];
      if (tabParam != null) {
        return '/time?period=$tabParam';
      }
      return '/time';
    }),

  // New Year
  GoRoute(
    path: '/new-year',
    name: 'fortune-new-year',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return DailyCalendarFortunePage(initialParams: extra);
    })];