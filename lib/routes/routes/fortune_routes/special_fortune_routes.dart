import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/dream_fortune_voice_page.dart';
import '../../../features/fortune/presentation/pages/talisman_fortune_page.dart';
// Removed unused pages: esports, dream_fortune, best_practices, lucky_job, lucky_sidejob,
// influencer, politician, ai_comprehensive, batch, dynamic, snap_scroll, legacy tarot

final specialFortuneRoutes = [
  // Dream Fortune (Voice)
  GoRoute(
    path: '/dream',
    name: 'fortune-dream',
    builder: (context, state) => const DreamFortuneVoicePage(),
  ),

  // Dream Chat (Redirect to Voice)
  GoRoute(
    path: '/dream-chat',
    name: 'fortune-dream-chat',
    builder: (context, state) => const DreamFortuneVoicePage(),
  ),
  
  
  
  
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