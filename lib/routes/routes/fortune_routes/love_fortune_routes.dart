import 'package:go_router/go_router.dart';
// import '../../../features/fortune/presentation/pages/love_fortune_page.dart'; // Removed - unused
import '../../../features/fortune/presentation/pages/chemistry_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_match_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_compatibility_page.dart';

final loveFortuneRoutes = [
  // Love - moved to route_config.dart (outside shell)
  
  
  // Ex-Lover Enhanced - moved to route_config.dart (outside shell)
  
  // Blind Date Instagram Analysis - moved to route_config.dart (outside shell)
  
  // Blind Date Coaching Result - moved to route_config.dart (outside shell)
  
  // Chemistry
  GoRoute(
    path: '/chemistry',
    name: 'fortune-chemistry',
    builder: (context, state) => const ChemistryPage()),
  
  // Celebrity Match
  GoRoute(
    path: '/celebrity-match',
    name: 'fortune-celebrity-match',
    builder: (context, state) => const CelebrityMatchPage()),
  
  // Celebrity Compatibility
  GoRoute(
    path: '/celebrity-compatibility',
    name: 'fortune-celebrity-compatibility',
    builder: (context, state) => const CelebrityCompatibilityPage()),
  
  
];