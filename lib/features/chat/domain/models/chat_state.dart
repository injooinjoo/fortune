import 'chat_message.dart';

/// 채팅 상태 모델
class ChatState {
  /// 메시지 목록
  final List<ChatMessage> messages;

  /// 처리 중 여부
  final bool isProcessing;

  /// 타이핑 표시 여부
  final bool isTyping;

  /// 현재 운세 유형
  final String? currentFortuneType;

  /// 에러 메시지
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isProcessing = false,
    this.isTyping = false,
    this.currentFortuneType,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isProcessing,
    bool? isTyping,
    String? currentFortuneType,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      isTyping: isTyping ?? this.isTyping,
      currentFortuneType: currentFortuneType ?? this.currentFortuneType,
      error: error ?? this.error,
    );
  }

  /// 메시지가 없는지 확인
  bool get isEmpty => messages.isEmpty;

  /// 메시지가 있는지 확인
  bool get hasMessages => messages.isNotEmpty;
}
