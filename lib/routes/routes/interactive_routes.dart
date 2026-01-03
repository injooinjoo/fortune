import 'package:go_router/go_router.dart';
import '../../features/interactive/presentation/pages/interactive_list_page.dart';
import '../../features/interactive/presentation/pages/dream_interpretation_page.dart';
import '../../features/interactive/presentation/pages/psychology_test_page.dart';
import '../../features/interactive/presentation/pages/tarot_chat_page.dart';
import '../../features/interactive/presentation/pages/tarot_animated_flow_page.dart';
import '../../features/interactive/presentation/pages/face_reading_page.dart';
import '../../features/interactive/presentation/pages/taemong_page.dart';
import '../../features/interactive/presentation/pages/worry_bead_page.dart';
import '../../features/interactive/presentation/pages/dream_page.dart';

final interactiveRoutes = [
  GoRoute(
    path: '/interactive',
    name: 'interactive',
    builder: (context, state) => const InteractiveListPage(),
    routes: [
      // fortune-cookie는 /fortune-cookie 경로로 ShellRoute 밖에서 처리 (네비게이션 바 숨김)
      GoRoute(
        path: 'dream',
        name: 'interactive-dream',
        builder: (context, state) => const DreamInterpretationPage()),
      GoRoute(
        path: 'psychology-test',
        name: 'interactive-psychology-test',
        builder: (context, state) => const PsychologyTestPage()),
      GoRoute(
        path: 'tarot',
        name: 'interactive-tarot',
        builder: (context, state) {
          // Use the new clean chat-style page
          return const TarotChatPage();
        },
        routes: [
          GoRoute(
            path: 'animated-flow',
            name: 'tarot-animated-flow',
            builder: (context, state) {
              return const TarotAnimatedFlowPage();
            })]),
      GoRoute(
        path: 'face-reading',
        name: 'interactive-face-reading',
        builder: (context, state) => const FaceReadingPage()),
      GoRoute(
        path: 'taemong',
        name: 'interactive-taemong',
        builder: (context, state) => const TaemongPage()),
      GoRoute(
        path: 'worry-bead',
        name: 'interactive-worry-bead',
        builder: (context, state) => const WorryBeadPage()),
      GoRoute(
        path: 'dream-journal',
        name: 'interactive-dream-journal',
        builder: (context, state) => const DreamPage())])];