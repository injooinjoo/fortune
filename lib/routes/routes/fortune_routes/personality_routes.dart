import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/personality_dna_page.dart';
// Removed merged pages: celebrity_fortune_page_v2, same_birthday_celebrity
// All merged into /celebrity in route_config.dart (FortuneListPage)

final personalityRoutes = [
  // Personality DNA (성격 DNA)
  GoRoute(
    path: '/personality-dna',
    name: 'fortune-personality-dna',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return PersonalityDNAPage(initialParams: extra);
    }),
];