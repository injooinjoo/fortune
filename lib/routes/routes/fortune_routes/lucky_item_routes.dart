import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/lucky_color_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_number_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_food_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_place_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_items_unified_page.dart';
import '../../../features/fortune/presentation/pages/lucky_outfit_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_series_fortune_page.dart';
import '../../../features/fortune/presentation/pages/birthstone_fortune_page.dart';
import '../../../features/fortune/presentation/pages/talisman_fortune_page.dart';
import '../../../features/fortune/presentation/pages/five_blessings_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_items_results_page.dart';

final luckyItemRoutes = [
  // Lucky Items Unified
  GoRoute(
    path: '/lucky-items',
    name: 'fortune-lucky-items',
    builder: (context, state) => const LuckyItemsUnifiedPage()),
    
  // Lucky Items Results (New)
  GoRoute(
    path: '/lucky-items-results',
    name: 'fortune-lucky-items-results',
    builder: (context, state) => const LuckyItemsResultsPage()),
  
  // Lucky Color
  GoRoute(
    path: '/lucky-color',
    name: 'fortune-lucky-color',
    builder: (context, state) => const LuckyColorFortunePage()),
  
  // Lucky Number
  GoRoute(
    path: '/lucky-number',
    name: 'fortune-lucky-number',
    builder: (context, state) => const LuckyNumberFortunePage()),
  
  // Lucky Food
  GoRoute(
    path: '/lucky-food',
    name: 'fortune-lucky-food',
    builder: (context, state) => const LuckyFoodFortunePage()),
  
  // Lucky Place
  GoRoute(
    path: '/lucky-place',
    name: 'fortune-lucky-place',
    builder: (context, state) => const LuckyPlaceFortunePage()),
  
  // Lucky Outfit
  GoRoute(
    path: '/lucky-outfit',
    name: 'fortune-lucky-outfit',
    builder: (context, state) => const LuckyOutfitFortunePage()),
  
  // Lucky Series
  GoRoute(
    path: '/lucky-series',
    name: 'fortune-lucky-series',
    builder: (context, state) => const LuckySeriesFortunePage()),
  
  // Birthstone
  GoRoute(
    path: '/birthstone',
    name: 'fortune-birthstone',
    builder: (context, state) => const BirthstoneFortunePage()),
  
  // Talisman (Lucky Item) - moved to route_config.dart (outside shell)
  
  // Five Blessings
  GoRoute(
    path: '/five-blessings',
    name: 'fortune-five-blessings',
    builder: (context, state) => const FiveBlessingsFortunePage()),
];