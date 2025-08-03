// Add these routes to app_router.dart

// Import statements to,
    add:
import 'package:fortune/features/fortune/presentation/pages/lucky_lottery_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/lucky_stock_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/lucky_crypto_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/lucky_yoga_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/lucky_fitness_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/health_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/employment_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/talent_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/destiny_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/past_life_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/wish_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/timeline_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/talisman_fortune_page.dart';
import 'package:fortune/features/fortune/presentation/pages/yearly_fortune_page.dart';

// Routes to add in the fortune,
    section:
GoRoute(
  path: 'lucky-lottery',
  name: 'fortune-lucky-lottery',
  builder: (context, state) => const LuckyLotteryFortunePage(),
),
GoRoute(
  path: 'lucky-stock',
  name: 'fortune-lucky-stock',
  builder: (context, state) => const LuckyStockFortunePage(),
),
GoRoute(
  path: 'lucky-crypto',
  name: 'fortune-lucky-crypto',
  builder: (context, state) => const LuckyCryptoFortunePage(),
),
GoRoute(
  path: 'lucky-yoga',
  name: 'fortune-lucky-yoga',
  builder: (context, state) => const LuckyYogaFortunePage(),
),
GoRoute(
  path: 'lucky-fitness',
  name: 'fortune-lucky-fitness',
  builder: (context, state) => const LuckyFitnessFortunePage(),
),
GoRoute(
  path: 'health',
  name: 'fortune-health',
  builder: (context, state) => const HealthFortunePage(),
),
GoRoute(
  path: 'employment',
  name: 'fortune-employment',
  builder: (context, state) => const EmploymentFortunePage(),
),
GoRoute(
  path: 'talent',
  name: 'fortune-talent',
  builder: (context, state) => const TalentFortunePage(),
),
GoRoute(
  path: 'destiny',
  name: 'fortune-destiny',
  builder: (context, state) => const DestinyFortunePage(),
),
GoRoute(
  path: 'past-life',
  name: 'fortune-past-life',
  builder: (context, state) => const PastLifeFortunePage(),
),
GoRoute(
  path: 'wish',
  name: 'fortune-wish',
  builder: (context, state) => const WishFortunePage(),
),
GoRoute(
  path: 'timeline',
  name: 'fortune-timeline',
  builder: (context, state) => const TimelineFortunePage(),
),
GoRoute(
  path: 'talisman',
  name: 'fortune-talisman',
  builder: (context, state) => const TalismanFortunePage(),
),
GoRoute(
  path: 'yearly',
  name: 'fortune-yearly',
  builder: (context, state) => const YearlyFortunePage(),
),
