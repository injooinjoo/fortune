import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/love_fortune_page.dart';
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
  // Love
  GoRoute(
    path: '/love',
    name: 'fortune-love',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return LoveFortunePage(
        initialParams: extra);
    }),
  
  // Compatibility
  GoRoute(
    path: '/compatibility',
    name: 'fortune-compatibility',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return CompatibilityPage(
        initialParams: extra);
    }),
  
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
  
  // Ex-Lover
  GoRoute(
    path: '/ex-lover',
    name: 'fortune-ex-lover',
    builder: (context, state) => const ExLoverFortunePage()),
  
  // Ex-Lover Enhanced
  GoRoute(
    path: '/ex-lover-enhanced',
    name: 'fortune-ex-lover-enhanced',
    builder: (context, state) => const ExLoverFortuneEnhancedPage()),
  
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
  
  // Pet Compatibility
  GoRoute(
    path: '/pet-compatibility',
    name: 'fortune-pet-compatibility',
    builder: (context, state) => const PetCompatibilityPage(
      fortuneType: 'pet-compatibility',
      title: '반려동물 궁합',
      description: '나와 반려동물의 궁합을 확인해보세요')),
  
  // Avoid People
  GoRoute(
    path: '/avoid-people',
    name: 'fortune-avoid-people',
    builder: (context, state) => const AvoidPeopleFortunePage())
];