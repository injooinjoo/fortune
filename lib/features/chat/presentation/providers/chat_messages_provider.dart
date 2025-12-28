import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/fortune.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_state.dart';

const _uuid = Uuid();

/// 채팅 메시지 StateNotifier
class ChatMessagesNotifier extends StateNotifier<ChatState> {
  ChatMessagesNotifier() : super(const ChatState());

  /// 사용자 메시지 추가
  void addUserMessage(String text) {
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.user,
      text: text,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  /// AI 메시지 추가
  void addAiMessage(String text) {
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.ai,
      text: text,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 운세 결과 메시지 추가
  void addFortuneResultMessage({
    required String text,
    required String fortuneType,
    String? sectionKey,
    bool isBlurred = false,
    List<String> blurredSections = const [],
    Fortune? fortune,
  }) {
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.fortuneResult,
      text: text,
      timestamp: DateTime.now(),
      fortuneType: fortuneType,
      sectionKey: sectionKey,
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      fortune: fortune,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 사주 분석 결과 메시지 추가
  void addSajuResultMessage({
    String? text,
    required Map<String, dynamic> sajuData,
    Map<String, dynamic>? sajuFortuneResult,
    bool isBlurred = false,
    List<String> blurredSections = const [],
  }) {
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.sajuResult,
      text: text,
      timestamp: DateTime.now(),
      sajuData: sajuData,
      sajuFortuneResult: sajuFortuneResult,
      isBlurred: isBlurred,
      blurredSections: blurredSections,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 시스템 메시지 추가 (추천 칩)
  void addSystemMessage({List<String>? chipIds}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.system,
      timestamp: DateTime.now(),
      chipIds: chipIds,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  /// 타이핑 인디케이터 표시
  void showTypingIndicator() {
    state = state.copyWith(isTyping: true);
  }

  /// 타이핑 인디케이터 숨기기
  void hideTypingIndicator() {
    state = state.copyWith(isTyping: false);
  }

  /// 처리 중 상태 설정
  void setProcessing(bool isProcessing) {
    state = state.copyWith(isProcessing: isProcessing);
  }

  /// 현재 운세 유형 설정
  void setCurrentFortuneType(String? fortuneType) {
    state = state.copyWith(currentFortuneType: fortuneType);
  }

  /// 특정 메시지 블러 해제
  void unblurMessage(String messageId) {
    final updated = state.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(isBlurred: false);
      }
      return m;
    }).toList();

    state = state.copyWith(messages: updated);
  }

  /// 모든 메시지 블러 해제
  void unblurAllMessages() {
    final updated = state.messages.map((m) {
      return m.copyWith(isBlurred: false);
    }).toList();

    state = state.copyWith(messages: updated);
  }

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// 대화 초기화
  void clearConversation() {
    state = const ChatState();
  }
}

/// 채팅 메시지 Provider
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, ChatState>(
  (ref) => ChatMessagesNotifier(),
);
