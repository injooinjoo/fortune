import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/character/domain/models/ai_character.dart';
import '../../../features/character/domain/models/character_affinity.dart';
import '../../../features/character/domain/models/character_chat_state.dart';
import '../../../features/character/presentation/providers/character_chat_provider.dart';
import '../../../features/character/presentation/providers/character_provider.dart';

class ProfileRelationshipEntry {
  const ProfileRelationshipEntry({
    required this.character,
    required this.chatState,
  });

  final AiCharacter character;
  final CharacterChatState chatState;

  CharacterAffinity get affinity => chatState.affinity;
  int get lovePercent => affinity.lovePercent;
  String get phaseName => affinity.phaseName;
  int get totalMessages => chatState.messages.length;
  int get unreadCount => chatState.unreadCount;
  bool get hasConversation => chatState.hasConversation;
  String get previewText => chatState.lastMessagePreview;
}

class ProfileRelationshipStats {
  const ProfileRelationshipStats({
    required this.entries,
    required this.totalMessages,
    required this.totalConversations,
    required this.totalUnread,
    required this.activeRelationshipCount,
    this.topEntry,
  });

  final List<ProfileRelationshipEntry> entries;
  final int totalMessages;
  final int totalConversations;
  final int totalUnread;
  final int activeRelationshipCount;
  final ProfileRelationshipEntry? topEntry;

  bool get isEmpty => totalConversations == 0 && activeRelationshipCount == 0;
}

ProfileRelationshipStats buildProfileRelationshipStats({
  required List<AiCharacter> characters,
  required CharacterChatState Function(String characterId) resolveState,
}) {
  final entries = characters
      .map(
        (character) => ProfileRelationshipEntry(
          character: character,
          chatState: resolveState(character.id),
        ),
      )
      .toList();

  entries.sort((left, right) {
    final affinityCompare =
        right.affinity.lovePoints.compareTo(left.affinity.lovePoints);
    if (affinityCompare != 0) {
      return affinityCompare;
    }

    final messageCompare = right.totalMessages.compareTo(left.totalMessages);
    if (messageCompare != 0) {
      return messageCompare;
    }

    return left.character.name.compareTo(right.character.name);
  });

  ProfileRelationshipEntry? topEntry;
  for (final entry in entries) {
    if (entry.affinity.lovePoints > 0 || entry.hasConversation) {
      topEntry = entry;
      break;
    }
  }

  return ProfileRelationshipStats(
    entries: List.unmodifiable(entries),
    totalMessages:
        entries.fold(0, (sum, entry) => sum + entry.chatState.messages.length),
    totalConversations:
        entries.where((entry) => entry.chatState.hasConversation).length,
    totalUnread: entries.fold(0, (sum, entry) => sum + entry.unreadCount),
    activeRelationshipCount: entries
        .where(
          (entry) =>
              entry.affinity.lovePoints > 0 || entry.chatState.hasConversation,
        )
        .length,
    topEntry: topEntry,
  );
}

final profileRelationshipStatsProvider =
    Provider<ProfileRelationshipStats>((ref) {
  final storyCharacters = ref.watch(storyCharactersProvider);

  return buildProfileRelationshipStats(
    characters: storyCharacters,
    resolveState: (characterId) =>
        ref.watch(characterChatProvider(characterId)),
  );
});
