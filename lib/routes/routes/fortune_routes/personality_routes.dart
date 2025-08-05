import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/personality_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/personality_fortune_unified_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/birth_season_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/birthdate_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/celebrity_fortune_enhanced_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/same_birthday_celebrity_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lifestyle_fortune_page.dart' as fortune_pages;

final personalityRoutes = [
  // Personality Fortune Unified
  GoRoute(
    path: 'personality',
    name: 'fortune-personality',
    builder: (context, state) => const fortune_pages.PersonalityFortuneUnifiedPage()),
  
  // Birth Season
  GoRoute(
    path: 'birth-season',
    name: 'fortune-birth-season',
    builder: (context, state) => const fortune_pages.BirthSeasonFortunePage()),
  
  // Birthdate
  GoRoute(
    path: 'birthdate',
    name: 'fortune-birthdate',
    builder: (context, state) => const fortune_pages.BirthdateFortunePage()),
  
  // Celebrity
  GoRoute(
    path: 'celebrity',
    name: 'fortune-celebrity',
    builder: (context, state) => const fortune_pages.CelebrityFortuneEnhancedPage()),
  
  // Same Birthday Celebrity
  GoRoute(
    path: 'same-birthday-celebrity',
    name: 'fortune-same-birthday-celebrity',
    builder: (context, state) => const fortune_pages.SameBirthdayCelebrityFortunePage()),
  
  // Lifestyle
  GoRoute(
    path: 'lifestyle',
    name: 'fortune-lifestyle',
    builder: (context, state) => const fortune_pages.LifestyleFortunePage())];