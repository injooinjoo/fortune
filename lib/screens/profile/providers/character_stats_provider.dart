import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/character/domain/models/ai_character.dart';
import '../../../features/character/domain/models/character_affinity.dart';
import '../../../features/character/domain/models/character_chat_state.dart';
import '../../../features/character/presentation/providers/character_chat_provider.dart';
import '../../../features/character/data/default_characters.dart';

/// 프로필 화면용 캐릭터 통계 모델
class CharacterStats {
  /// 전체 메시지 수
  final int totalMessages;

  /// 대화 중인 캐릭터 수
  final int totalConversations;

  /// 가장 높은 호감도를 가진 캐릭터
  final AiCharacter? topCharacter;

  /// 가장 높은 호감도
  final CharacterAffinity? topAffinity;

  /// 총 읽지 않은 메시지 수
  final int totalUnread;

  const CharacterStats({
    this.totalMessages = 0,
    this.totalConversations = 0,
    this.topCharacter,
    this.topAffinity,
    this.totalUnread = 0,
  });

  /// 대화 내역 없음
  bool get isEmpty => totalMessages == 0;

  /// 호감도 퍼센트 (대표 캐릭터)
  int get topAffinityPercent => topAffinity?.lovePercent ?? 0;

  /// 관계 단계 이름 (대표 캐릭터)
  String get topPhaseName => topAffinity?.phaseName ?? '낯선 사이';

  /// 호감도 이모지 (대표 캐릭터)
  String get topLoveEmoji => topAffinity?.loveEmoji ?? '💔';
}

/// 캐릭터 통계 Provider
/// 모든 스토리 캐릭터의 채팅 상태를 집계하여 통계 반환
final characterStatsProvider = Provider<CharacterStats>((ref) {
  int totalMessages = 0;
  int totalConversations = 0;
  int totalUnread = 0;
  AiCharacter? topCharacter;
  int highestAffinity = 0;
  CharacterAffinity? topAffinity;

  for (final character in defaultCharacters) {
    final chatState = ref.watch(characterChatProvider(character.id));

    // 메시지 수 집계
    totalMessages += chatState.messages.length;

    // 읽지 않은 메시지 집계
    totalUnread += chatState.unreadCount;

    // 대화 중인 캐릭터 수 집계
    if (chatState.hasConversation) {
      totalConversations++;
    }

    // 가장 높은 호감도 캐릭터 찾기
    if (chatState.affinity.lovePoints > highestAffinity) {
      highestAffinity = chatState.affinity.lovePoints;
      topCharacter = character;
      topAffinity = chatState.affinity;
    }
  }

  return CharacterStats(
    totalMessages: totalMessages,
    totalConversations: totalConversations,
    topCharacter: topCharacter,
    topAffinity: topAffinity,
    totalUnread: totalUnread,
  );
});

/// 개별 캐릭터 채팅 상태 목록 Provider
/// 정렬된 캐릭터 목록 (호감도 높은 순)
final sortedCharacterStatesProvider =
    Provider<List<(AiCharacter, CharacterChatState)>>((ref) {
  final states = <(AiCharacter, CharacterChatState)>[];

  for (final character in defaultCharacters) {
    final chatState = ref.watch(characterChatProvider(character.id));
    if (chatState.hasConversation) {
      states.add((character, chatState));
    }
  }

  // 호감도 높은 순 정렬
  states.sort((a, b) => b.$2.affinity.lovePoints.compareTo(a.$2.affinity.lovePoints));

  return states;
});
