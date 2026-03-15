import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/data/default_characters.dart';
import 'package:fortune/features/character/domain/models/character_affinity.dart';
import 'package:fortune/features/character/domain/models/character_chat_message.dart';
import 'package:fortune/features/character/domain/models/character_chat_state.dart';
import 'package:fortune/screens/profile/providers/character_relationships_provider.dart';

void main() {
  test('buildProfileRelationshipStats summarizes and sorts story relationships',
      () {
    final characters = defaultCharacters.take(3).toList();
    final states = <String, CharacterChatState>{
      characters[0].id: CharacterChatState(
        characterId: characters[0].id,
        messages: [
          CharacterChatMessage.character('안녕', characters[0].id),
          CharacterChatMessage.user('반가워'),
        ],
        unreadCount: 1,
        affinity: CharacterAffinity(
          lovePoints: 320,
          phase: AffinityPhase.fromPoints(320),
        ),
      ),
      characters[1].id: CharacterChatState(
        characterId: characters[1].id,
        messages: [
          CharacterChatMessage.character('오늘 어땠어요?', characters[1].id),
        ],
        affinity: CharacterAffinity(
          lovePoints: 680,
          phase: AffinityPhase.fromPoints(680),
        ),
      ),
      characters[2].id: CharacterChatState(
        characterId: characters[2].id,
        affinity: const CharacterAffinity(),
      ),
    };

    final stats = buildProfileRelationshipStats(
      characters: characters,
      resolveState: (characterId) => states[characterId]!,
    );

    expect(stats.totalMessages, 3);
    expect(stats.totalConversations, 2);
    expect(stats.totalUnread, 1);
    expect(stats.activeRelationshipCount, 2);
    expect(stats.topEntry?.character.id, characters[1].id);
    expect(
      stats.entries.map((entry) => entry.character.id).toList(),
      [characters[1].id, characters[0].id, characters[2].id],
    );
  });
}
