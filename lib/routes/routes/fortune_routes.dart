
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

// import '../../features/fortune/presentation/pages/batch_fortune_page.dart' as fortune_pages;
// import '../../features/fortune/presentation/pages/fortune_snap_scroll_page.dart' as fortune_pages;
// import '../../features/fortune/presentation/pages/tarot_main_page.dart';
// import '../../features/fortune/presentation/pages/tarot_deck_selection_page.dart';
// import '../../features/fortune/presentation/pages/tarot_animated_flow_page.dart'; // File doesn't exist

final fortuneRoutes = [
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
];
