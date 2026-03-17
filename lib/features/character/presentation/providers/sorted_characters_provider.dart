import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_character.dart';
import 'character_provider.dart';
import 'character_chat_provider.dart';

List<AiCharacter> _sortCharactersByChatActivity(
  Ref ref,
  List<AiCharacter> characters,
) {
  final withState = characters.map((char) {
    final state = ref.watch(characterChatProvider(char.id));
    return (character: char, state: state);
  }).toList();

  withState.sort((a, b) {
    if (a.state.isCharacterTyping != b.state.isCharacterTyping) {
      return a.state.isCharacterTyping ? -1 : 1;
    }

    if (a.state.unreadCount != b.state.unreadCount) {
      return b.state.unreadCount.compareTo(a.state.unreadCount);
    }

    final aTime = a.state.lastMessageTime ?? DateTime(2000);
    final bTime = b.state.lastMessageTime ?? DateTime(2000);
    return bTime.compareTo(aTime);
  });

  return withState.map((entry) => entry.character).toList();
}

/// 정렬된 캐릭터 목록 Provider (인스타그램 DM 스타일)
/// 정렬 우선순위:
/// 1. 타이핑 중인 캐릭터
/// 2. 읽지 않은 메시지가 있는 캐릭터
/// 3. 최근 대화 시간순
final sortedCharactersProvider = Provider<List<AiCharacter>>((ref) {
  final characters = ref.watch(charactersProvider);
  return _sortCharactersByChatActivity(ref, characters);
});

/// 스토리 탭 전용 정렬 목록
final sortedStoryCharactersProvider = Provider<List<AiCharacter>>((ref) {
  final characters = ref.watch(storyCharactersProvider);
  return _sortCharactersByChatActivity(ref, characters);
});

/// 운세 탭 전용 정렬 목록
final sortedFortuneCharactersProvider = Provider<List<AiCharacter>>((ref) {
  final characters = ref.watch(fortuneCharactersProvider);
  return _sortCharactersByChatActivity(ref, characters);
});
