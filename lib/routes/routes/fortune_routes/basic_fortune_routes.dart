import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/saju_page.dart';
import '../../../features/fortune/presentation/pages/mbti_fortune_page.dart';
import '../../../features/fortune/presentation/pages/destiny_fortune_page.dart';
import '../../../features/fortune/presentation/pages/wish_fortune_page.dart';
import '../../../features/fortune/presentation/pages/network_report_fortune_page.dart';
import '../../../features/history/presentation/pages/fortune_history_page.dart';

final basicFortuneRoutes = [
  // Saju (Four Pillars)
  GoRoute(
    path: '/saju',
    name: 'fortune-saju',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return const SajuPage();
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
  
  
  // Destiny
  GoRoute(
    path: '/destiny',
    name: 'fortune-destiny',
    builder: (context, state) => const DestinyFortunePage()),
  
  // Past Life - removed (page deleted)
  // Timeline - removed (page deleted)
  // Daily Inspiration - removed (page deleted)

  // Wish
  GoRoute(
    path: '/wish',
    name: 'fortune-wish',
    builder: (context, state) => const WishFortunePage()),

  // Network Report
  GoRoute(
    path: '/network-report',
    name: 'fortune-network-report',
    builder: (context, state) => const NetworkReportFortunePage()),
  
  // History
  GoRoute(
    path: '/history',
    name: 'fortune-history',
    builder: (context, state) => const FortuneHistoryPage())];