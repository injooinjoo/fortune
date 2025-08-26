import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/love_fortune_page.dart';
import '../../../features/fortune/presentation/pages/love/love_fortune_main_page.dart';
import '../../../features/fortune/presentation/pages/compatibility_page.dart';
import '../../../features/fortune/presentation/pages/marriage_fortune_page.dart';
import '../../../features/fortune/presentation/pages/traditional_compatibility_page.dart';
import '../../../features/fortune/presentation/pages/couple_match_page.dart';
import '../../../features/fortune/presentation/pages/ex_lover_fortune_page.dart';
import '../../../features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart';
import '../../../features/fortune/presentation/pages/blind_date_fortune_page.dart';
import '../../../features/fortune/presentation/pages/chemistry_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_match_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_compatibility_page.dart';
import '../../../features/fortune/presentation/pages/pet_compatibility_page.dart';
import '../../../features/fortune/presentation/pages/avoid_people_fortune_page.dart';
import '../../../domain/entities/fortune.dart';

final loveFortuneRoutes = [
  // Love - moved to route_config.dart (outside shell)
  
  // Marriage
  GoRoute(
    path: '/marriage',
    name: 'fortune-marriage',
    builder: (context, state) => const MarriageFortunePage()),
  
  // Traditional Compatibility
  GoRoute(
    path: '/traditional-compatibility',
    name: 'fortune-traditional-compatibility',
    builder: (context, state) => const TraditionalCompatibilityPage()),
  
  // Couple Match
  GoRoute(
    path: '/couple-match',
    name: 'fortune-couple-match',
    builder: (context, state) => const CoupleMatchPage()),
  
  // Ex-Lover Enhanced - moved to route_config.dart (outside shell)
  
  // Blind Date
  GoRoute(
    path: '/blind-date',
    name: 'fortune-blind-date',
    builder: (context, state) => const BlindDateFortunePage()),
  
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