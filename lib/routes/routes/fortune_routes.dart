import 'package:go_router/go_router.dart';

// Import all fortune route categories
import 'fortune_routes/basic_fortune_routes.dart';
import 'fortune_routes/love_fortune_routes.dart';
import 'fortune_routes/career_fortune_routes.dart';
import 'fortune_routes/lucky_item_routes.dart';
import 'fortune_routes/traditional_fortune_routes.dart';
import 'fortune_routes/health_sports_routes.dart';
import 'fortune_routes/personality_routes.dart';
import 'fortune_routes/time_based_routes.dart';
import 'fortune_routes/special_fortune_routes.dart';

import '../../features/fortune/presentation/pages/fortune_list_page.dart' as fortune_pages;
import '../../features/fortune/presentation/pages/batch_fortune_page.dart' as fortune_pages;
import '../../features/fortune/presentation/pages/fortune_snap_scroll_page.dart' as fortune_pages;
import '../../features/fortune/presentation/pages/tarot_main_page.dart';
import '../../features/fortune/presentation/pages/tarot_deck_selection_page.dart';
import '../../features/fortune/presentation/pages/tarot_animated_flow_page.dart';

final fortuneRoutes = [
  GoRoute(
    path: '/fortune',
    name: 'fortune',
    builder: (context, state) => const fortune_pages.FortuneListPage(),
    routes: [
      // Batch fortune
      GoRoute(
        path: 'batch',
        name: 'fortune-batch',
        builder: (context, state) => const fortune_pages.BatchFortunePage(),
      ),
      
      // Snap scroll fortune
      GoRoute(
        path: 'snap-scroll',
        name: 'fortune-snap-scroll',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final fortuneTypes = extra?['fortuneTypes'] as List<String>? ?? 
              ['daily', 'love', 'money', 'health', 'career'];
          final title = extra?['title'] as String? ?? '종합 운세';
          final description = extra?['description'] as String? ?? 
              '여러 운세를 한 번에 확인하세요';
          
          return fortune_pages.FortuneSnapScrollPage(
            title: title,
            description: description,
            fortuneTypes: fortuneTypes,
          );
        },
      ),
      
      // Tarot routes
      GoRoute(
        path: 'tarot',
        name: 'fortune-tarot',
        builder: (context, state) {
          return const TarotMainPage();
        },
        routes: [
          GoRoute(
            path: 'deck-selection',
            name: 'fortune-tarot-deck-selection',
            builder: (context, state) {
              return TarotDeckSelectionPage(
                spreadType: state.uri.queryParameters['spreadType'],
                initialQuestion: state.uri.queryParameters['question'],
              );
            },
          ),
          GoRoute(
            path: 'animated-flow',
            name: 'fortune-tarot-animated-flow',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return TarotAnimatedFlowPage(
                heroTag: extra?['heroTag'],
              );
            },
          ),
        ],
      ),
      
      // Include all categorized fortune routes
      ...basicFortuneRoutes,
      ...loveFortuneRoutes,
      ...careerFortuneRoutes,
      ...luckyItemRoutes,
      ...traditionalFortuneRoutes,
      ...healthSportsRoutes,
      ...personalityRoutes,
      ...timeBasedRoutes,
      ...specialFortuneRoutes,
    ],
  ),
];