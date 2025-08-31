import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/biorhythm_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/pet_fortune_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/pet_fortune_unified_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/moving_fortune_toss_page.dart' as fortune_pages;
import '../../../features/fortune/presentation/pages/moving_date_fortune_page.dart' as fortune_pages;
import '../../../features/health/presentation/pages/health_fortune_toss_page.dart';
import '../../../features/sports/presentation/pages/sports_fortune_page.dart';
import '../../../features/fortune/presentation/pages/pet_compatibility_page.dart';

final healthSportsRoutes = [
  
  // Biorhythm - moved to route_config.dart (outside shell)
  // Moving - moved to route_config.dart (outside shell)
  
  // Moving Date
  GoRoute(
    path: '/moving-date',
    name: 'fortune-moving-date',
    builder: (context, state) => const fortune_pages.MovingDateFortunePage()),
  
  // Sports redirect routes for backward compatibility
  GoRoute(
    path: '/lucky-golf',
    name: 'fortune-lucky-golf',
    redirect: (_, __) => '/fortune/sports?type=golf'),
  GoRoute(
    path: '/lucky-baseball',
    name: 'fortune-lucky-baseball',
    redirect: (_, __) => '/fortune/sports?type=baseball'),
  GoRoute(
    path: '/lucky-tennis',
    name: 'fortune-lucky-tennis',
    redirect: (_, __) => '/fortune/sports?type=tennis'),
  GoRoute(
    path: '/lucky-running',
    name: 'fortune-lucky-running',
    redirect: (_, __) => '/fortune/sports?type=running'),
  GoRoute(
    path: '/lucky-cycling',
    name: 'fortune-lucky-cycling',
    redirect: (_, __) => '/fortune/sports?type=cycling'),
  GoRoute(
    path: '/lucky-swim',
    name: 'fortune-lucky-swim',
    redirect: (_, __) => '/fortune/sports?type=swimming'),
  GoRoute(
    path: '/lucky-fishing',
    name: 'fortune-lucky-fishing',
    redirect: (_, __) => '/fortune/sports?type=fishing'),
  GoRoute(
    path: '/lucky-hiking',
    name: 'fortune-lucky-hiking',
    redirect: (_, __) => '/fortune/sports?type=hiking'),
  GoRoute(
    path: '/lucky-yoga',
    name: 'fortune-lucky-yoga',
    redirect: (_, __) => '/fortune/sports?type=yoga'),
  GoRoute(
    path: '/lucky-fitness',
    name: 'fortune-lucky-fitness',
    redirect: (_, __) => '/fortune/sports?type=fitness')];