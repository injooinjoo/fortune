import 'package:go_router/go_router.dart';
import '../../../core/constants/fortune_metadata.dart';
import '../../../features/fortune/presentation/pages/dream_fortune_chat_page.dart';
import '../../../features/fortune/presentation/pages/dream_fortune_page.dart';
import '../../../features/fortune/presentation/pages/fortune_best_practices_page.dart';
import '../../../features/fortune/presentation/pages/lucky_job_fortune_page.dart';
import '../../../features/fortune/presentation/pages/lucky_sidejob_fortune_page.dart';
import '../../../features/fortune/presentation/pages/esports_fortune_page.dart';
import '../../../features/fortune/presentation/pages/influencer_fortune_page.dart';
import '../../../features/fortune/presentation/pages/politician_fortune_page.dart';
import '../../../features/fortune/presentation/pages/ai_comprehensive_fortune_page.dart';
import '../../../features/fortune/presentation/pages/batch_fortune_page.dart';
import '../../../features/fortune/presentation/pages/dynamic_fortune_page.dart';
import '../../../features/fortune/presentation/pages/tarot_main_page.dart';
import '../../../features/fortune/presentation/pages/tarot_deck_selection_page.dart';
import '../../../features/fortune/presentation/pages/tarot_storytelling_page.dart';
import '../../../features/fortune/presentation/pages/tarot_summary_page.dart';
import '../../../features/fortune/presentation/pages/fortune_snap_scroll_page.dart';
import '../../../features/fortune/presentation/pages/talisman_fortune_page.dart';

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
  
  // Tarot Main (Legacy)
  GoRoute(
    path: '/tarot-legacy',
    name: 'fortune-tarot-legacy',
    builder: (context, state) => const TarotMainPage()),
  
  // Tarot Deck Selection (Legacy)
  GoRoute(
    path: '/tarot-deck-legacy',
    name: 'fortune-tarot-deck-legacy',
    builder: (context, state) => const TarotDeckSelectionPage()),

  // Tarot Storytelling (Legacy)
  GoRoute(
    path: '/tarot-storytelling-legacy',
    name: 'fortune-tarot-storytelling-legacy',
    builder: (context, state) => TarotStorytellingPage(
      selectedCards: const [],
      spreadType: 'basic')),
  
  // Tarot Summary (Legacy)
  GoRoute(
    path: '/tarot-summary-legacy',
    name: 'fortune-tarot-summary-legacy',
    builder: (context, state) => const TarotSummaryPage(
      cards: [],
      interpretations: [],
      spreadType: 'basic')),
  
  // Talisman Fortune
  GoRoute(
    path: '/talisman',
    name: 'fortune-talisman',
    builder: (context, state) => const TalismanFortunePage()),
];