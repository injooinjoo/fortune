import 'package:go_router/go_router.dart';
import '../../../core/constants/fortune_metadata.dart';
import '../../../features/fortune/presentation/pages/dream_fortune_chat_page.dart';
import '../../../features/fortune/presentation/pages/dream_fortune_page.dart';
import '../../../features/fortune/presentation/pages/family_fortune_unified_page.dart';
import '../../../features/fortune/presentation/pages/children_fortune_page.dart';
import '../../../features/fortune/presentation/pages/fortune_best_practices_page.dart';
import '../../../features/fortune/presentation/pages/lucky_job_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_sidejob_fortune_page.dart';
import '../../../features/fortune/presentation/pages/esports_fortune_page.dart';
import '../../../features/fortune/presentation/pages/influencer_fortune_page.dart';
import '../../../features/fortune/presentation/pages/politician_fortune_page.dart';
import '../../../features/fortune/presentation/pages/sports_player_fortune_page.dart';
import '../../../features/fortune/presentation/pages/crypto_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lottery_fortune_page.dart';
import '../../../features/fortune/presentation/pages/relationship_fortune_page.dart';
import '../../../features/fortune/presentation/pages/ai_comprehensive_fortune_page.dart';
import '../../../features/fortune/presentation/pages/batch_fortune_page.dart';
import '../../../features/fortune/presentation/pages/dynamic_fortune_page.dart';
import '../../../features/fortune/presentation/pages/tarot_main_page.dart';
import '../../../features/fortune/presentation/pages/tarot_deck_selection_page.dart';
import '../../../features/fortune/presentation/pages/tarot_enhanced_page.dart';
import '../../../features/fortune/presentation/pages/tarot_storytelling_page.dart';
import '../../../features/fortune/presentation/pages/tarot_summary_page.dart';
import '../../../features/fortune/presentation/pages/fortune_snap_scroll_page.dart';

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
    redirect: (_, __) => '/fortune/physiognomy'),
  
  // Dream Fortune (별도 페이지)
  GoRoute(
    path: '/dream-fortune',
    name: 'fortune-dream-fortune',
    builder: (context, state) => const DreamFortunePage()),
  
  // Crypto Fortune
  GoRoute(
    path: '/crypto',
    name: 'fortune-crypto',
    builder: (context, state) => const CryptoFortunePage()),
  
  // Lottery Fortune
  GoRoute(
    path: '/lottery',
    name: 'fortune-lottery',
    builder: (context, state) => const LotteryFortunePage()),
  
  // Relationship Fortune
  GoRoute(
    path: '/relationship',
    name: 'fortune-relationship',
    builder: (context, state) => const RelationshipFortunePage()),
  
  // AI Comprehensive Fortune
  GoRoute(
    path: '/ai-comprehensive',
    name: 'fortune-ai-comprehensive',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return AiComprehensiveFortunePage(
        initialParams: extra);
    }),
  
  // Batch Fortune
  GoRoute(
    path: '/batch',
    name: 'fortune-batch',
    builder: (context, state) => const BatchFortunePage()),
  
  // Dynamic Fortune
  GoRoute(
    path: '/dynamic',
    name: 'fortune-dynamic',
    builder: (context, state) => const DynamicFortunePage(fortuneType: FortuneType.daily)),
  
  // Fortune Snap Scroll
  GoRoute(
    path: '/snap-scroll',
    name: 'fortune-snap-scroll',
    builder: (context, state) => const FortuneSnapScrollPage(
      title: '운세 스냅 스크롤',
      description: '운세를 확인해보세요',
      fortuneTypes: ['general'])),
  
  // Tarot Main
  GoRoute(
    path: '/tarot',
    name: 'fortune-tarot',
    builder: (context, state) => const TarotMainPage()),
  
  // Tarot Deck Selection
  GoRoute(
    path: '/tarot-deck',
    name: 'fortune-tarot-deck',
    builder: (context, state) => const TarotDeckSelectionPage()),
  
  // Tarot Enhanced
  GoRoute(
    path: '/tarot-enhanced',
    name: 'fortune-tarot-enhanced',
    builder: (context, state) => const TarotEnhancedPage()),
  
  // Tarot Storytelling
  GoRoute(
    path: '/tarot-storytelling',
    name: 'fortune-tarot-storytelling',
    builder: (context, state) => TarotStorytellingPage(
      selectedCards: const [],
      spreadType: 'basic')),
  
  // Tarot Summary
  GoRoute(
    path: '/tarot-summary',
    name: 'fortune-tarot-summary',
    builder: (context, state) => const TarotSummaryPage(
      cards: [],
      interpretations: [],
      spreadType: 'basic')),
];