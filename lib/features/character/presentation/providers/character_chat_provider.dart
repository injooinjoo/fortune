import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../../domain/models/character_affinity.dart';
import '../../domain/models/character_choice.dart';
import '../../domain/models/response_delay_config.dart';
import '../../data/services/character_chat_service.dart';
import '../../data/default_characters.dart';

/// 캐릭터별 채팅 상태 Provider (family)
final characterChatProvider = StateNotifierProvider.family<
    CharacterChatNotifier, CharacterChatState, String>(
  (ref, characterId) => CharacterChatNotifier(ref, characterId),
);

/// 캐릭터 채팅 상태 관리자
class CharacterChatNotifier extends StateNotifier<CharacterChatState> {
  final String _characterId;
  final CharacterChatService _service = CharacterChatService();

  CharacterChatNotifier(Ref ref, this._characterId)
      : super(CharacterChatState(characterId: _characterId));

  /// 유저 메시지 추가
  void addUserMessage(String text) {
    final message = CharacterChatMessage.user(text);
    state = state.copyWith(
      messages: [...state.messages, message],
      isProcessing: true,
    );
  }

  /// 캐릭터 메시지 추가
  void addCharacterMessage(String text) {
    final message = CharacterChatMessage.character(text, _characterId);
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
      isProcessing: false,
    );
  }

  /// 시스템 메시지 추가
  void addSystemMessage(String text) {
    final message = CharacterChatMessage.system(text);
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  /// 타이핑 인디케이터 설정
  void setTyping(bool typing) {
    state = state.copyWith(
      isTyping: typing,
      isCharacterTyping: typing,  // DM 목록용
    );
  }

  /// 마지막 사용자 메시지를 읽음 처리 (1 → 사라짐)
  void markLastUserMessageAsRead() {
    final messages = List<CharacterChatMessage>.from(state.messages);
    final lastUserIdx = messages.lastIndexWhere(
      (m) => m.type == CharacterChatMessageType.user,
    );
    if (lastUserIdx >= 0 && messages[lastUserIdx].status == MessageStatus.sent) {
      messages[lastUserIdx] = messages[lastUserIdx].copyWith(
        status: MessageStatus.read,
        readAt: DateTime.now(),
      );
      state = state.copyWith(messages: messages);
    }
  }

  /// 읽지 않은 메시지 수 초기화 (채팅방 진입 시)
  void clearUnreadCount() {
    state = state.copyWith(unreadCount: 0);
  }

  /// 읽지 않은 메시지 수 증가 (캐릭터 메시지 도착 시, 채팅방 밖에서)
  void incrementUnreadCount() {
    state = state.copyWith(unreadCount: state.unreadCount + 1);
  }

  /// 처리 중 상태 설정
  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(
      error: error,
      isTyping: false,
      isProcessing: false,
    );
  }

  /// 대화 초기화
  void clearConversation() {
    state = CharacterChatState(characterId: _characterId);
  }

  /// 호감도 업데이트
  void updateAffinity(AffinityEvent event) {
    final newAffinity = state.affinity.addPoints(event.points);
    state = state.copyWith(affinity: newAffinity);
  }

  /// 호감도 직접 설정 (불러오기용)
  void setAffinity(CharacterAffinity affinity) {
    state = state.copyWith(affinity: affinity);
  }

  /// 메시지 전송 (API 호출 포함) - 인스타그램 DM 스타일 딜레이 적용
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1단계: 유저 메시지 추가 (status: sent → "1" 표시)
    addUserMessage(text);

    // 2단계: 읽음 딜레이 (0.5~1.5초) - AI가 메시지를 "봤다"는 느낌
    final readDelay = ResponseDelayConfig.calculateReadDelay();
    await Future.delayed(Duration(milliseconds: readDelay));

    // 3단계: 읽음 처리 → "1" 사라짐
    markLastUserMessageAsRead();

    // 4단계: 타이핑 시작
    setTyping(true);

    try {
      // 캐릭터 정보 가져오기
      final character = defaultCharacters.firstWhere(
        (c) => c.id == _characterId,
      );

      // 메시지 히스토리 준비 (최근 20개, 방금 추가한 사용자 메시지 제외)
      final messagesWithoutCurrent = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutCurrent.length > 20
          ? messagesWithoutCurrent.sublist(messagesWithoutCurrent.length - 20)
          : messagesWithoutCurrent;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // API 호출
      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: character.systemPrompt,
        messages: history,
        userMessage: text,
        oocInstructions: character.oocInstructions,
      );

      // 5단계: 감정 기반 타이핑 딜레이 (클라이언트 측)
      final emotion = ResponseDelayConfig.parseEmotion(response.emotionTag);
      final typingDelay = ResponseDelayConfig.calculateTypingDelay(
        emotion: emotion,
        responseLength: response.response.length,
      );
      await Future.delayed(Duration(milliseconds: typingDelay));

      // 6단계: 캐릭터 응답 추가
      addCharacterMessage(response.response);

      // 호감도 자동 증가 (일반 대화)
      updateAffinity(AffinityEvent.normalChat);
    } catch (e) {
      setError(e.toString());
    }
  }

  /// 첫 메시지로 대화 시작
  void startConversation(String firstMessage) {
    if (state.messages.isEmpty) {
      addCharacterMessage(firstMessage);
    }
  }

  /// 대화 스레드 초기화 (DB에서 불러오기)
  Future<void> initConversation() async {
    // 이미 초기화됨
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
      final messages = await _service.loadConversation(_characterId);

      if (messages.isNotEmpty) {
        // DB에서 불러온 대화가 있으면 사용
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          isInitialized: true,
        );
      } else {
        // 없으면 캐릭터 첫 메시지로 시작
        final character = defaultCharacters.firstWhere(
          (c) => c.id == _characterId,
        );
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
        );
        if (character.firstMessage.isNotEmpty) {
          startConversation(character.firstMessage);
        }
      }
    } catch (e) {
      // 에러 시에도 초기화 완료 처리 (첫 메시지로 시작)
      final character = defaultCharacters.firstWhere(
        (c) => c.id == _characterId,
      );
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
      if (character.firstMessage.isNotEmpty) {
        startConversation(character.firstMessage);
      }
    }
  }

  /// 대화 스레드 저장 (화면 이탈 시 호출)
  Future<bool> saveOnExit() async {
    // 메시지가 없으면 저장 안 함
    if (state.messages.isEmpty) return true;

    return await _service.saveConversation(_characterId, state.messages);
  }

  /// 선택지 메시지 추가
  void addChoiceMessage(ChoiceSet choiceSet, {String? situation}) {
    final message = CharacterChatMessage.choice(choiceSet, situation: situation);
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
      isProcessing: false,
    );
  }

  /// 선택지 선택 처리 - 인스타그램 DM 스타일 딜레이 적용
  Future<void> handleChoiceSelection(CharacterChoice choice) async {
    // 선택지 메시지 제거 (마지막 메시지가 선택지인 경우)
    final messages = List<CharacterChatMessage>.from(state.messages);
    if (messages.isNotEmpty && messages.last.isChoice) {
      messages.removeLast();
    }

    // 사용자 선택을 메시지로 추가 (status: sent)
    final userMessage = CharacterChatMessage.user(choice.text);
    messages.add(userMessage);

    state = state.copyWith(
      messages: messages,
      isProcessing: true,
    );

    // 호감도 변화 적용
    if (choice.affinityChange != 0) {
      final newAffinity = state.affinity.addPoints(choice.affinityChange);
      state = state.copyWith(affinity: newAffinity);
    }

    // 읽음 딜레이 (0.5~1.5초)
    final readDelay = ResponseDelayConfig.calculateReadDelay();
    await Future.delayed(Duration(milliseconds: readDelay));

    // 읽음 처리 → "1" 사라짐
    markLastUserMessageAsRead();

    // 타이핑 시작
    setTyping(true);

    try {
      // 캐릭터 정보 가져오기
      final character = defaultCharacters.firstWhere(
        (c) => c.id == _characterId,
      );

      // 선택에 대한 캐릭터 반응 요청 (방금 추가한 사용자 선택 제외)
      final messagesWithoutCurrent = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutCurrent.length > 20
          ? messagesWithoutCurrent.sublist(messagesWithoutCurrent.length - 20)
          : messagesWithoutCurrent;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: character.systemPrompt,
        messages: history,
        userMessage: '(사용자가 "${choice.text}"를 선택함)',
        oocInstructions: character.oocInstructions,
      );

      // 감정 기반 타이핑 딜레이
      final emotion = ResponseDelayConfig.parseEmotion(response.emotionTag);
      final typingDelay = ResponseDelayConfig.calculateTypingDelay(
        emotion: emotion,
        responseLength: response.response.length,
      );
      await Future.delayed(Duration(milliseconds: typingDelay));

      addCharacterMessage(response.response);
    } catch (e) {
      setError(e.toString());
    }
  }

  /// 현재 활성 선택지가 있는지 확인
  bool get hasActiveChoice {
    return state.messages.isNotEmpty && state.messages.last.isChoice;
  }

  /// 현재 활성 선택지 가져오기
  ChoiceSet? get activeChoiceSet {
    if (!hasActiveChoice) return null;
    return state.messages.last.choiceSet;
  }
}
