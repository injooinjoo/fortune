import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_character.dart';
import 'character_provider.dart';
import 'character_chat_provider.dart';

/// 정렬된 캐릭터 목록 Provider (인스타그램 DM 스타일)
/// 정렬 우선순위:
/// 1. 타이핑 중인 캐릭터
/// 2. 읽지 않은 메시지가 있는 캐릭터
/// 3. 최근 대화 시간순
final sortedCharactersProvider = Provider<List<AiCharacter>>((ref) {
  final characters = ref.watch(charactersProvider);

  // 각 캐릭터의 채팅 상태와 함께 정렬
  final withState = characters.map((char) {
    final state = ref.watch(characterChatProvider(char.id));
    return (character: char, state: state);
  }).toList();

  // 정렬
  withState.sort((a, b) {
    // 1순위: 타이핑 중
    if (a.state.isCharacterTyping != b.state.isCharacterTyping) {
      return a.state.isCharacterTyping ? -1 : 1;
    }

    // 2순위: 읽지 않은 메시지 수
    if (a.state.unreadCount != b.state.unreadCount) {
      return b.state.unreadCount.compareTo(a.state.unreadCount);
    }

    // 3순위: 최근 메시지 시간
    final aTime = a.state.lastMessageTime ?? DateTime(2000);
    final bTime = b.state.lastMessageTime ?? DateTime(2000);
    return bTime.compareTo(aTime);
  });

  return withState.map((e) => e.character).toList();
});
