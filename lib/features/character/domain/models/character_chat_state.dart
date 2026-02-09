import 'character_chat_message.dart';
import 'character_affinity.dart';

/// 캐릭터 채팅 상태 모델
class CharacterChatState {
  final String characterId;
  final List<CharacterChatMessage> messages;
  final bool isTyping;
  final bool isProcessing;
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final CharacterAffinity affinity;
  final int unreadCount;           // 읽지 않은 캐릭터 메시지 수
  final bool isCharacterTyping;    // 캐릭터가 타이핑 중 (DM 목록용)

  const CharacterChatState({
    required this.characterId,
    this.messages = const [],
    this.isTyping = false,
    this.isProcessing = false,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    this.affinity = const CharacterAffinity(),
    this.unreadCount = 0,
    this.isCharacterTyping = false,
  });

  /// 마지막 메시지 텍스트 (DM 미리보기용)
  String? get lastMessageText => messages.isNotEmpty ? messages.last.text : null;

  /// 마지막 메시지 시간
  DateTime? get lastMessageTime =>
      messages.isNotEmpty ? messages.last.timestamp : null;

  /// 대화 존재 여부
  bool get hasConversation => messages.isNotEmpty;

  /// 마지막 메시지 미리보기 (최대 30자)
  String get lastMessagePreview {
    if (messages.isEmpty) return '새 대화';
    final text = messages.last.text;
    return text.length > 30 ? '${text.substring(0, 30)}...' : text;
  }

  /// 정렬 우선순위 계산 (DM 목록용)
  int get sortPriority {
    if (isCharacterTyping) return 0;  // 입력 중 최상위
    if (unreadCount > 0) return 1;    // 새 메시지 있음
    return 2;                          // 일반
  }

  CharacterChatState copyWith({
    String? characterId,
    List<CharacterChatMessage>? messages,
    bool? isTyping,
    bool? isProcessing,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    CharacterAffinity? affinity,
    int? unreadCount,
    bool? isCharacterTyping,
  }) {
    return CharacterChatState(
      characterId: characterId ?? this.characterId,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
      affinity: affinity ?? this.affinity,
      unreadCount: unreadCount ?? this.unreadCount,
      isCharacterTyping: isCharacterTyping ?? this.isCharacterTyping,
    );
  }
}
