import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/personality_fortune_page.dart';
import '../../../features/fortune/presentation/pages/personality_fortune_unified_page.dart';
import '../../../features/fortune/presentation/pages/birth_season_fortune_page.dart';
import '../../../features/fortune/presentation/pages/birthdate_fortune_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_fortune_enhanced_page.dart';
import '../../../features/fortune/presentation/pages/same_birthday_celebrity_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lifestyle_fortune_page.dart';
import '../../../features/fortune/presentation/pages/personality_dna_page.dart';
import '../../../core/models/personality_dna_model.dart';

final personalityRoutes = [
  // Personality Fortune Unified
  GoRoute(
    path: '/personality',
    name: 'fortune-personality',
    builder: (context, state) => const PersonalityFortuneUnifiedPage()),
  
  // Personality Fortune
  GoRoute(
    path: '/personality-fortune',
    name: 'fortune-personality-fortune',
    builder: (context, state) => const PersonalityFortunePage()),
  
  // Birth Season
  GoRoute(
    path: '/birth-season',
    name: 'fortune-birth-season',
    builder: (context, state) => const BirthSeasonFortunePage()),
  
  // Birthdate
  GoRoute(
    path: '/birthdate',
    name: 'fortune-birthdate',
    builder: (context, state) => const BirthdateFortunePage()),
  
  // Celebrity
  GoRoute(
    path: '/celebrity',
    name: 'fortune-celebrity',
    builder: (context, state) => const CelebrityFortuneEnhancedPage()),
  
  // Same Birthday Celebrity
  GoRoute(
    path: '/same-birthday-celebrity',
    name: 'fortune-same-birthday-celebrity',
    builder: (context, state) => const SameBirthdayCelebrityFortunePage()),
  
  // Lifestyle
  GoRoute(
    path: '/lifestyle',
    name: 'fortune-lifestyle',
    builder: (context, state) => const LifestyleFortunePage()),
  
  // Personality DNA
  GoRoute(
    path: '/personality-dna',
    name: 'fortune-personality-dna',
    builder: (context, state) => PersonalityDNAPage(
      initialDNA: state.extra as PersonalityDNA?,
    )),
];