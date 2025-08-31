import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/birth_season_fortune_page.dart';
import '../../../features/fortune/presentation/pages/birthdate_fortune_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_fortune_enhanced_page.dart';
import '../../../features/fortune/presentation/pages/celebrity_fortune_page_v2.dart';
import '../../../features/fortune/presentation/pages/same_birthday_celebrity_fortune_page.dart';
import '../../../features/fortune/presentation/pages/personality_dna_page.dart';
import '../../../core/models/personality_dna_model.dart';

final personalityRoutes = [
  
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
  
  // Celebrity Fortune (New Saju-based)
  GoRoute(
    path: '/celebrity-saju',
    name: 'fortune-celebrity-saju',
    builder: (context, state) => const CelebrityFortunePageV2()),
  
  // Same Birthday Celebrity
  GoRoute(
    path: '/same-birthday-celebrity',
    name: 'fortune-same-birthday-celebrity',
    builder: (context, state) => const SameBirthdayCelebrityFortunePage()),
  
  
  // Personality DNA
  GoRoute(
    path: '/personality-dna',
    name: 'fortune-personality-dna',
    builder: (context, state) => PersonalityDNAPage(
      initialDNA: state.extra as PersonalityDNA?,
    )),
];