import 'package:go_router/go_router.dart';
import '../../../core/constants/fortune_metadata.dart';
import '../../../features/fortune/presentation/pages/dream_fortune_chat_page.dart';
import '../../../features/fortune/presentation/pages/talisman_fortune_page.dart';
// Removed unused pages: esports, dream_fortune, best_practices, lucky_job, lucky_sidejob,
// influencer, politician, ai_comprehensive, batch, dynamic, snap_scroll, legacy tarot

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
  
  
  
  
  // Removed unused routes: best-practices, lucky-job, lucky-sidejob, esports,
  // influencer, politician, dream-fortune, ai-comprehensive, batch, dynamic,
  // snap-scroll, legacy tarot pages

  // Physiognomy redirect (for convenience)
  GoRoute(
    path: '/physiognomy',
    name: 'physiognomy',
    redirect: (_, __) => '/fortune/physiognomy'),

  // Talisman Fortune
  GoRoute(
    path: '/talisman',
    name: 'fortune-talisman',
    builder: (context, state) => const TalismanFortunePage()),
];