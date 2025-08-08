import 'package:go_router/go_router.dart';
// import '../../../features/fortune/presentation/pages/love_fortune_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/compatibility_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/marriage_fortune_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/traditional_compatibility_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/couple_match_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/ex_lover_fortune_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/ex_lover_fortune_result_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/blind_date_fortune_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/chemistry_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/celebrity_match_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/celebrity_compatibility_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/pet_compatibility_page.dart' as fortune_pages;
// import '../../../features/fortune/presentation/pages/avoid_people_fortune_page.dart' as fortune_pages;
import '../../../domain/entities/fortune.dart';

final loveFortuneRoutes = [
  // TEMPORARILY DISABLED DUE TO SYNTAX ERRORS - 2025-08-06
  // All love fortune routes are temporarily commented out to allow the app to build
  // These will be re-enabled after fixing the syntax errors in the respective pages
  
  // // Love
  // GoRoute(
  //   path: 'love',
  //   name: 'fortune-love',
  //   builder: (context, state) {
  //     final extra = state.extra as Map<String, dynamic>?;
  //     return fortune_pages.LoveFortunePage(
  //       initialParams: extra);
  //   }),
  
  // // Compatibility
  // GoRoute(
  //   path: 'compatibility',
  //   name: 'fortune-compatibility',
  //   builder: (context, state) {
  //     final extra = state.extra as Map<String, dynamic>?;
  //     return fortune_pages.CompatibilityPage(
  //       initialParams: extra);
  //   }),
  
  // // Marriage
  // GoRoute(
  //   path: 'marriage',
  //   name: 'fortune-marriage',
  //   builder: (context, state) => const fortune_pages.MarriageFortunePage()),
  
  // // Traditional Compatibility
  // GoRoute(
  //   path: 'traditional-compatibility',
  //   name: 'fortune-traditional-compatibility',
  //   builder: (context, state) => const fortune_pages.TraditionalCompatibilityPage()),
  
  // // Couple Match
  // GoRoute(
  //   path: 'couple-match',
  //   name: 'fortune-couple-match',
  //   builder: (context, state) => const fortune_pages.CoupleMatchPage()),
  
  // // Ex-Lover
  // GoRoute(
  //   path: 'ex-lover',
  //   name: 'fortune-ex-lover',
  //   builder: (context, state) => const fortune_pages.ExLoverFortunePage()),
  
  // // Ex-Lover Enhanced
  // GoRoute(
  //   path: 'ex-lover-enhanced',
  //   name: 'fortune-ex-lover-enhanced',
  //   builder: (context, state) => fortune_pages.ExLoverFortuneEnhancedPage(
  //     extras: state.extra as Map<String, dynamic>?)),
  
  // // Blind Date
  // GoRoute(
  //   path: 'blind-date',
  //   name: 'fortune-blind-date',
  //   builder: (context, state) => const fortune_pages.BlindDateFortunePage()),
  
  // // Chemistry
  // GoRoute(
  //   path: 'chemistry',
  //   name: 'fortune-chemistry',
  //   builder: (context, state) => const fortune_pages.ChemistryFortunePage()),
  
  // // Celebrity Match
  // GoRoute(
  //   path: 'celebrity-match',
  //   name: 'fortune-celebrity-match',
  //   builder: (context, state) => const fortune_pages.CelebrityMatchPage()),
  
  // // Pet Compatibility
  // GoRoute(
  //   path: 'pet-compatibility',
  //   name: 'fortune-pet-compatibility',
  //   builder: (context, state) => const fortune_pages.PetCompatibilityPage(
  //     fortuneType: 'pet-compatibility',
  //     title: '반려동물 궁합',
  //     description: '나와 반려동물의 궁합을 확인해보세요')),
  
  // // Avoid People
  // GoRoute(
  //   path: 'avoid-people',
  //   name: 'fortune-avoid-people',
  //   builder: (context, state) => const fortune_pages.AvoidPeopleFortunePage())
];