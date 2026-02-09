import 'package:go_router/go_router.dart';
import '../core/utils/page_transitions.dart';
import '../features/character/domain/models/ai_character.dart';
import '../features/character/presentation/pages/character_profile_page.dart';

/// 캐릭터 관련 라우트
final List<GoRoute> characterRoutes = [
  GoRoute(
    path: '/character/:id',
    name: 'character-profile',
    pageBuilder: (context, state) {
      final character = state.extra as AiCharacter?;
      return PageTransitions.slideTransition(
        context,
        state,
        CharacterProfilePage(
          characterId: state.pathParameters['id']!,
          character: character,
        ),
      );
    },
  ),
];
