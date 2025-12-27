// Import all fortune route categories
import 'fortune_routes/basic_fortune_routes.dart';
import 'fortune_routes/career_fortune_routes.dart';
import 'fortune_routes/lucky_item_routes.dart';
import 'fortune_routes/traditional_fortune_routes.dart';
import 'fortune_routes/health_sports_routes.dart';
import 'fortune_routes/personality_routes.dart';
import 'fortune_routes/time_based_routes.dart';
import 'fortune_routes/special_fortune_routes.dart';

final fortuneRoutes = [
  // Include all categorized fortune routes
  ...basicFortuneRoutes,
  ...careerFortuneRoutes,
  ...luckyItemRoutes,
  ...traditionalFortuneRoutes,
  ...healthSportsRoutes,
  ...personalityRoutes,
  ...timeBasedRoutes,
  ...specialFortuneRoutes,
];
