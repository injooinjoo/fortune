import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/love_fortune_page.dart';
import '../../../features/fortune/presentation/pages/love/love_fortune_main_page.dart';
import '../../../features/fortune/presentation/pages/compatibility_page.dart';
import '../../../features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart';
import '../../../features/fortune/presentation/pages/blind_date_instagram_page.dart';
import '../../../features/fortune/presentation/pages/blind_date_coaching_page.dart';
import '../../../features/fortune/domain/models/blind_date_instagram_model.dart';
import '../../../features/fortune/presentation/pages/chemistry_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_match_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_compatibility_page.dart';
import '../../../features/fortune/presentation/pages/pet_compatibility_page.dart';
import '../../../features/fortune/presentation/pages/avoid_people_fortune_page.dart';
import '../../../domain/entities/fortune.dart';

final loveFortuneRoutes = [
  // Love - moved to route_config.dart (outside shell)
  
  
  // Ex-Lover Enhanced - moved to route_config.dart (outside shell)
  
  // Blind Date Instagram Analysis
  GoRoute(
    path: '/blind-date',
    name: 'fortune-blind-date',
    builder: (context, state) => const BlindDateInstagramPage()),
  
  // Blind Date Coaching Result
  GoRoute(
    path: '/blind-date-coaching',
    name: 'fortune-blind-date-coaching',
    builder: (context, state) {
      final input = state.extra as BlindDateInstagramInput?;
      if (input == null) {
        return const BlindDateInstagramPage();
      }
      return BlindDateCoachingPage(input: input);
    }),
  
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