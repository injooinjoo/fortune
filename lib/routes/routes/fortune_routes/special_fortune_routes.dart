import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/dream_fortune_chat_page.dart';
import '../../../features/fortune/presentation/pages/family_fortune_unified_page.dart';
import '../../../features/fortune/presentation/pages/children_fortune_page.dart';
import '../../../features/fortune/presentation/pages/fortune_best_practices_page.dart';
import '../../../features/fortune/presentation/pages/lucky_job_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_sidejob_fortune_page.dart';
import '../../../features/fortune/presentation/pages/esports_fortune_page.dart';
import '../../../features/fortune/presentation/pages/influencer_fortune_page.dart';
import '../../../features/fortune/presentation/pages/politician_fortune_page.dart';
import '../../../features/fortune/presentation/pages/sports_player_fortune_page.dart';

final specialFortuneRoutes = [
  // Dream Fortune
  GoRoute(
    path: '/dream',
    name: 'fortune-dream',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return DreamFortuneChatPage(
        initialParams: extra);
    }),
  
  // Dream Chat
  GoRoute(
    path: '/dream-chat',
    name: 'fortune-dream-chat',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return DreamFortuneChatPage(
        initialParams: extra);
    }),
  
  // Family Fortune Unified
  GoRoute(
    path: '/family',
    name: 'fortune-family',
    builder: (context, state) => const FamilyFortuneUnifiedPage()),
  
  // Children
  GoRoute(
    path: '/children',
    name: 'fortune-children',
    builder: (context, state) => const ChildrenFortunePage(
      fortuneType: 'children',
      title: '자녀 운세',
      description: '자녀와 관련된 운세를 확인해보세요',
      specificFortuneType: 'children')),
  
  // Parenting
  GoRoute(
    path: '/parenting',
    name: 'fortune-parenting',
    builder: (context, state) => const ChildrenFortunePage(
      fortuneType: 'parenting',
      title: '육아 운세',
      description: '육아와 관련된 운세를 확인해보세요',
      specificFortuneType: 'parenting')),
  
  // Pregnancy
  GoRoute(
    path: '/pregnancy',
    name: 'fortune-pregnancy',
    builder: (context, state) => const ChildrenFortunePage(
      fortuneType: 'pregnancy',
      title: '태교 운세',
      description: '태교와 관련된 운세를 확인해보세요',
      specificFortuneType: 'pregnancy')),
  
  // Family Harmony
  GoRoute(
    path: '/family-harmony',
    name: 'fortune-family-harmony',
    builder: (context, state) => const ChildrenFortunePage(
      fortuneType: 'family-harmony',
      title: '가족 화합 운세',
      description: '가족의 화합과 관련된 운세를 확인해보세요',
      specificFortuneType: 'family-harmony')),
  
  // Best Practices
  GoRoute(
    path: '/best-practices',
    name: 'fortune-best-practices',
    builder: (context, state) => const FortuneBestPracticesPage()),
  
  // Lucky Job
  GoRoute(
    path: '/lucky-job',
    name: 'fortune-lucky-job',
    builder: (context, state) => const LuckyJobFortunePage()),
  
  // Lucky Side Job
  GoRoute(
    path: '/lucky-sidejob',
    name: 'fortune-lucky-sidejob',
    builder: (context, state) => const LuckySideJobFortunePage()),
  
  // E-Sports
  GoRoute(
    path: '/esports',
    name: 'fortune-esports',
    builder: (context, state) => const EsportsFortunePage()),
  
  // Influencer
  GoRoute(
    path: '/influencer',
    name: 'fortune-influencer',
    builder: (context, state) => const InfluencerFortunePage()),
  
  // Politician
  GoRoute(
    path: '/politician',
    name: 'fortune-politician',
    builder: (context, state) => const PoliticianFortunePage()),
  
  // Sports Player
  GoRoute(
    path: '/sports-player',
    name: 'fortune-sports-player',
    builder: (context, state) => const SportsPlayerFortunePage()),
  
  // Physiognomy redirect (for convenience)
  GoRoute(
    path: '/physiognomy',
    name: 'physiognomy',
    redirect: (_, __) => '/fortune/physiognomy')];