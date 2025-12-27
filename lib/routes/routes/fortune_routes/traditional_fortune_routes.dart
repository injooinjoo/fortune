import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/traditional_fortune_page.dart';
import '../../../features/fortune/presentation/pages/face_reading_fortune_page.dart';
import '../../../features/fortune/presentation/pages/tarot_page.dart';
// Removed merged pages: tojeong, palmistry, saju, destiny
// All merged into /traditional in FortuneListPage

final traditionalFortuneRoutes = [
  // Traditional Fortune (통합 사주 운세)
  GoRoute(
    path: '/traditional',
    name: 'fortune-traditional',
    builder: (context, state) => const TraditionalFortunePage()),

  // Face Reading (관상)
  GoRoute(
    path: '/face-reading',
    name: 'fortune-face-reading',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return FaceReadingFortunePage(initialParams: extra);
    }),

  // Tarot (타로)
  GoRoute(
    path: '/tarot',
    name: 'fortune-tarot',
    builder: (context, state) => const TarotPage()),
];