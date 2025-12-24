import 'package:go_router/go_router.dart';
import '../../core/utils/page_transitions.dart';
import '../../features/wellness/presentation/pages/wellness_page.dart';
import '../../features/wellness/presentation/pages/meditation_page.dart';

/// 웰니스 관련 라우트
final wellnessRoutes = [
  GoRoute(
    path: '/wellness',
    name: 'wellness',
    pageBuilder: (context, state) => PageTransitions.slideTransition(
      context,
      state,
      const WellnessPage(),
    ),
    routes: [
      GoRoute(
        path: 'meditation',
        name: 'wellness-meditation',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const MeditationPage(),
        ),
      ),
    ],
  ),
];
