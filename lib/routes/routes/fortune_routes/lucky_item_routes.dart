import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/lucky_color_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_number_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_food_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_place_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_items_unified_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_outfit_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/lucky_series_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/birthstone_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/talisman_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/talisman_enhanced_page.dart';
import '../../../features/fortune/presentation/pages/five_blessings_fortune_page.dart' as fortune_pages;

final luckyItemRoutes = [
  // Lucky Items Unified
  GoRoute(
    path: 'lucky-items',
    name: 'fortune-lucky-items',
    builder: (context, state) => const fortune_pages.LuckyItemsUnifiedPage(),
  ),
  
  // Lucky Color
  GoRoute(
    path: 'lucky-color',
    name: 'fortune-lucky-color',
    builder: (context, state) => const fortune_pages.LuckyColorFortunePage(),
  ),
  
  // Lucky Number
  GoRoute(
    path: 'lucky-number',
    name: 'fortune-lucky-number',
    builder: (context, state) => const fortune_pages.LuckyNumberFortunePage(),
  ),
  
  // Lucky Food
  GoRoute(
    path: 'lucky-food',
    name: 'fortune-lucky-food',
    builder: (context, state) => const fortune_pages.LuckyFoodFortunePage(),
  ),
  
  // Lucky Place
  GoRoute(
    path: 'lucky-place',
    name: 'fortune-lucky-place',
    builder: (context, state) => const fortune_pages.LuckyPlaceFortunePage(),
  ),
  
  // Lucky Outfit
  GoRoute(
    path: 'lucky-outfit',
    name: 'fortune-lucky-outfit',
    builder: (context, state) => const fortune_pages.LuckyOutfitFortunePage(),
  ),
  
  // Lucky Series
  GoRoute(
    path: 'lucky-series',
    name: 'fortune-lucky-series',
    builder: (context, state) => const fortune_pages.LuckySeriesFortunePage(),
  ),
  
  // Birthstone
  GoRoute(
    path: 'birthstone',
    name: 'fortune-birthstone',
    builder: (context, state) => const fortune_pages.BirthstoneFortunePage(),
  ),
  
  // Talisman
  GoRoute(
    path: 'talisman',
    name: 'fortune-talisman',
    builder: (context, state) => const TalismanEnhancedPage(),
  ),
  
  // Five Blessings
  GoRoute(
    path: 'five-blessings',
    name: 'fortune-five-blessings',
    builder: (context, state) => const fortune_pages.FiveBlessingsFortunePage(),
  ),
];