import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/tojeong_fortune_page.dart';
import '../../../features/fortune/presentation/pages/traditional_saju_fortune_page.dart';
import '../../../features/fortune/presentation/pages/traditional_saju_toss_page.dart';
import '../../../features/fortune/presentation/pages/palmistry_fortune_page.dart';
import '../../../features/fortune/presentation/pages/physiognomy_fortune_page.dart';
import '../../../features/fortune/presentation/pages/salpuli_fortune_page.dart';
import '../../../features/fortune/presentation/pages/saju_psychology_fortune_page.dart';
import '../../../features/fortune/presentation/pages/traditional_fortune_unified_page.dart';
import '../../../features/fortune/presentation/pages/face_reading_fortune_page.dart';
import '../../../features/fortune/presentation/pages/tarot_renewed_page.dart';

final traditionalFortuneRoutes = [
  // Traditional Fortune Unified
  GoRoute(
    path: '/traditional',
    name: 'fortune-traditional',
    builder: (context, state) => const TraditionalFortuneUnifiedPage()),
  
  // Tojeong Fortune
  GoRoute(
    path: '/tojeong',
    name: 'fortune-tojeong',
    builder: (context, state) => const TojeongFortunePage()),
  
  // Traditional Saju - moved to route_config.dart (outside shell)
  
  // Palmistry
  GoRoute(
    path: '/palmistry',
    name: 'fortune-palmistry',
    builder: (context, state) => const PalmistryFortunePage()),
  
  // Physiognomy Fortune - moved to route_config.dart (outside shell)
  
  // Salpuli
  GoRoute(
    path: '/salpuli',
    name: 'fortune-salpuli',
    builder: (context, state) => const SalpuliFortunePage()),
  
  // Saju Psychology
  GoRoute(
    path: '/saju-psychology',
    name: 'fortune-saju-psychology',
    builder: (context, state) => const SajuPsychologyFortunePage()),
  
  // Face Reading
  GoRoute(
    path: '/face-reading',
    name: 'fortune-face-reading',
    builder: (context, state) => const FaceReadingFortunePage()),
  
  // Tarot Renewed (Main)
  GoRoute(
    path: '/tarot',
    name: 'fortune-tarot',
    builder: (context, state) => const TarotRenewedPage()),
];