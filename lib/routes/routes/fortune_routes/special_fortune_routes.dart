import 'package:go_router/go_router.dart';
import '../../../features/fortune/presentation/pages/dream_fortune_voice_page.dart';
// Removed unused pages: esports, dream_fortune, best_practices, lucky_job, lucky_sidejob,
// influencer, politician, ai_comprehensive, batch, dynamic, snap_scroll, legacy tarot,
// physiognomy (dead redirect), talisman (duplicate - kept in route_config.dart as /lucky-talisman)
// past_life (moved to Chat-First architecture - handled in chat_home_page.dart)

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
];