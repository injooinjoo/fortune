import 'package:go_router/go_router.dart';
import '../core/utils/page_transitions.dart';
import '../features/character/domain/models/ai_character.dart';
import '../features/character/presentation/pages/character_profile_page.dart';
import '../features/character/presentation/pages/friend_creation_pages.dart';

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
  GoRoute(
    path: '/friends/new/basic',
    name: 'friend-create-basic',
    pageBuilder: (context, state) => PageTransitions.slideTransition(
      context,
      state,
      const FriendCreationBasicPage(),
    ),
  ),
  GoRoute(
    path: '/friends/new/persona',
    name: 'friend-create-persona',
    pageBuilder: (context, state) => PageTransitions.slideTransition(
      context,
      state,
      const FriendCreationPersonaPage(),
    ),
  ),
  GoRoute(
    path: '/friends/new/story',
    name: 'friend-create-story',
    pageBuilder: (context, state) => PageTransitions.slideTransition(
      context,
      state,
      const FriendCreationStoryPage(),
    ),
  ),
  GoRoute(
    path: '/friends/new/review',
    name: 'friend-create-review',
    pageBuilder: (context, state) => PageTransitions.slideTransition(
      context,
      state,
      const FriendCreationReviewPage(),
    ),
  ),
  GoRoute(
    path: '/friends/new/creating',
    name: 'friend-create-creating',
    pageBuilder: (context, state) => PageTransitions.fadeTransition(
      context,
      state,
      const FriendCreationCreatingPage(),
    ),
  ),
];
