import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../../domain/models/character_affinity.dart';
import '../../domain/models/character_choice.dart';
import '../../domain/models/response_delay_config.dart';
import '../../domain/models/ai_character.dart';
import '../../data/services/character_chat_service.dart';
import '../../data/services/character_chat_local_service.dart';
import '../../data/services/character_affinity_service.dart';
import '../../data/services/character_message_notification_service.dart';
import '../../data/services/follow_up_scheduler.dart';
import '../../data/default_characters.dart';
import '../../data/fortune_characters.dart';
import '../../../../core/services/chat_sync_service.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../services/app_icon_badge_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../data/services/fortune_api/fortune_api_service.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import 'active_chat_provider.dart';
import 'character_provider.dart';
import '../utils/luts_tone_policy.dart';

/// 캐릭터별 채팅 상태 Provider (family)
final characterChatProvider = StateNotifierProvider.family<
    CharacterChatNotifier, CharacterChatState, String>(
  (ref, characterId) => CharacterChatNotifier(ref, characterId),
);

/// 캐릭터 채팅 상태 관리자
/// 모든 캐릭터 목록 (스토리 + 운세)
final _allCharacters = [...defaultCharacters, ...fortuneCharacters];

class CharacterChatNotifier extends StateNotifier<CharacterChatState> {
  static const String _firstMeetConversationMode = 'first_meet_v1';
  static const Duration _readIdleIcebreakerDelay = Duration(seconds: 10);
  final String _characterId;
  final Ref _ref;
  final CharacterChatService _service = CharacterChatService();
  final FollowUpScheduler _followUpScheduler = FollowUpScheduler();
  final CharacterChatLocalService _localService = CharacterChatLocalService();
  final CharacterAffinityService _affinityService = CharacterAffinityService();
  final StorageService _storageService = StorageService();

  /// 현재 캐릭터 정보 캐시
  AiCharacter? _cachedCharacter;
  Timer? _readIdleIcebreakerTimer;
  String? _pendingReadIdleAnchorMessageId;
  String? _lastReadIdleIcebreakerAnchorMessageId;
  bool _isUserDrafting = false;

  CharacterChatNotifier(this._ref, this._characterId)
      : super(CharacterChatState(characterId: _characterId)) {
    // 앱 시작 시 로컬 저장소에서 대화 존재 여부 확인 (캐릭터 리스트용)
    _checkLocalConversation();
  }

  /// 로컬 저장소에서 대화 존재 여부 확인
  Future<void> _checkLocalConversation() async {
    final hasLocal = await _localService.hasConversation(_characterId);
    if (hasLocal && state.messages.isEmpty) {
      // 대화가 있으면 메시지를 미리 로드 (캐릭터 리스트에서 미리보기용)
      final messages = await _localService.loadConversation(_characterId);
      if (messages.isNotEmpty && mounted) {
        // 마지막으로 읽은 시간 이후의 캐릭터 메시지 수 계산
        final lastReadTime =
            await _localService.getLastReadTimestamp(_characterId);
        int unread = 0;
        if (lastReadTime != null) {
          unread = messages
              .where((m) =>
                  m.type == CharacterChatMessageType.character &&
                  m.timestamp.isAfter(lastReadTime))
              .length;
        }
        state = state.copyWith(messages: messages, unreadCount: unread);
      }
    }
  }

  /// 캐릭터 정보 가져오기 (캐시)
  AiCharacter get _character {
    _cachedCharacter ??= _allCharacters.firstWhere(
      (c) => c.id == _characterId,
    );
    return _cachedCharacter!;
  }

  /// 유저 프로필 정보를 API용 Map으로 변환
  Map<String, dynamic>? _getUserProfileMap() {
    try {
      final profileAsync = _ref.read(userProfileProvider);
      return profileAsync.maybeWhen(
        data: (profile) {
          if (profile == null) return null;

          // 나이 계산 (birthDate로부터)
          int? age;
          if (profile.birthDate != null) {
            final now = DateTime.now();
            age = now.year - profile.birthDate!.year;
            if (now.month < profile.birthDate!.month ||
                (now.month == profile.birthDate!.month &&
                    now.day < profile.birthDate!.day)) {
              age--;
            }
          }

          return {
            if (profile.name.isNotEmpty) 'name': profile.name,
            if (age != null) 'age': age,
            'gender': profile.gender.value, // Gender enum의 value
            if (profile.mbti != null) 'mbti': profile.mbti,
            if (profile.bloodType != null) 'bloodType': profile.bloodType,
            if (profile.zodiacSign != null) 'zodiacSign': profile.zodiacSign,
            if (profile.chineseZodiac != null)
              'zodiacAnimal': profile.chineseZodiac,
          };
        },
        orElse: () => null,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _buildAffinityContext() {
    return {
      'phase': state.affinity.phase.name,
      'lovePoints': state.affinity.lovePoints,
      'currentStreak': state.affinity.currentStreak,
    };
  }

  bool get _isLutsCharacter => LutsTonePolicy.isLuts(_characterId);

  LutsToneProfile _buildLutsToneProfile({String? currentUserMessage}) {
    if (!_isLutsCharacter) return LutsToneProfile.neutral;
    final profileMap = _getUserProfileMap();
    final knownUserName = profileMap?['name'] as String?;
    return LutsTonePolicy.fromConversation(
      messages: state.messages,
      currentUserMessage: currentUserMessage,
      knownUserName: knownUserName,
    );
  }

  String _buildLutsStyleGuidePrompt(LutsToneProfile profile) {
    if (!_isLutsCharacter) return '';
    return LutsTonePolicy.buildStyleGuidePrompt(
      profile,
      affinityPhase: state.affinity.phase,
    );
  }

  String _applyLutsTemplateTone(
    String message, {
    LutsToneProfile? profile,
  }) {
    if (!_isLutsCharacter) return message;
    final resolvedProfile = profile ?? _buildLutsToneProfile();
    return LutsTonePolicy.applyTemplateTone(
      message,
      resolvedProfile,
      affinityPhase: state.affinity.phase,
    );
  }

  String _applyLutsGeneratedTone(
    String message, {
    LutsToneProfile? profile,
    bool encourageContinuity = false,
  }) {
    if (!_isLutsCharacter) return message;
    final resolvedProfile = profile ?? _buildLutsToneProfile();
    return LutsTonePolicy.applyGeneratedTone(
      message,
      resolvedProfile,
      encourageContinuity: encourageContinuity,
      affinityPhase: state.affinity.phase,
    );
  }

  bool _isFormalCharacter() => _character.personality.contains('존댓말');

  String _buildFirstMeetOpening() {
    if (_isLutsCharacter) {
      const lutsToneProfile = LutsToneProfile.neutral;
      return _applyLutsTemplateTone(
        LutsTonePolicy.buildFirstMeetOpening(lutsToneProfile),
        profile: lutsToneProfile,
      );
    }

    final name = _character.name;
    if (_isFormalCharacter()) {
      return '안녕하세요, 저는 $name입니다. 처음 인사드려요. 서로 편하게 알아가고 싶어요. 요즘 가장 궁금한 한 가지를 말씀해주실래요?';
    }
    return '안녕, 나는 $name야. 우리 오늘 처음이니까 가볍게 서로 알아가보자. 요즘 제일 궁금한 거 하나만 말해줘.';
  }

  bool _isFirstMeetThread([List<CharacterChatMessage>? messages]) {
    final source = messages ?? state.messages;
    CharacterChatMessage? firstCharacterMessage;

    for (final message in source) {
      if (message.type == CharacterChatMessageType.character) {
        firstCharacterMessage = message;
        break;
      }
    }

    if (firstCharacterMessage == null) return false;
    return firstCharacterMessage.text == _buildFirstMeetOpening();
  }

  int _assistantTurnCount([List<CharacterChatMessage>? messages]) {
    final source = messages ?? state.messages;
    return source
        .where((message) => message.type == CharacterChatMessageType.character)
        .length;
  }

  bool _isFirstMeetPhase(AffinityPhase phase) =>
      phase == AffinityPhase.stranger || phase == AffinityPhase.acquaintance;

  bool _shouldApplyFirstMeetMode([List<CharacterChatMessage>? messages]) {
    final source = messages ?? state.messages;
    return _isFirstMeetThread(source) &&
        _isFirstMeetPhase(state.affinity.phase) &&
        _assistantTurnCount(source) < 4;
  }

  bool _isCurrentChatActive() {
    final activeChatId = _ref.read(activeCharacterChatProvider);
    return activeChatId == _characterId;
  }

  bool _containsQuestion(String text) =>
      text.contains('?') || text.contains('？');

  void _cancelReadIdleIcebreaker() {
    _readIdleIcebreakerTimer?.cancel();
    _readIdleIcebreakerTimer = null;
    _pendingReadIdleAnchorMessageId = null;
  }

  CharacterChatMessage? _findLastCharacterMessage() {
    for (var i = state.messages.length - 1; i >= 0; i--) {
      final message = state.messages[i];
      if (message.type == CharacterChatMessageType.character) {
        return message;
      }
    }
    return null;
  }

  bool _shouldScheduleReadIdleIcebreaker(CharacterChatMessage anchorMessage) {
    if (!_isLutsCharacter) return false;
    if (!_isCurrentChatActive()) return false;
    if (!_isFirstMeetPhase(state.affinity.phase)) return false;
    if (_isUserDrafting) return false;
    if (_containsQuestion(anchorMessage.text)) return false;
    if (state.isTyping || state.isProcessing) return false;
    if (_lastReadIdleIcebreakerAnchorMessageId == anchorMessage.id) {
      return false;
    }
    return true;
  }

  void _scheduleReadIdleIcebreaker({
    required CharacterChatMessage anchorMessage,
  }) {
    _cancelReadIdleIcebreaker();
    if (!_shouldScheduleReadIdleIcebreaker(anchorMessage)) return;

    _pendingReadIdleAnchorMessageId = anchorMessage.id;
    _readIdleIcebreakerTimer = Timer(_readIdleIcebreakerDelay, () {
      unawaited(_sendReadIdleIcebreakerIfStillIdle(anchorMessage.id));
    });
  }

  void _scheduleReadIdleIcebreakerForReadEvent() {
    final anchorMessage = _findLastCharacterMessage();
    if (anchorMessage == null) return;
    _scheduleReadIdleIcebreaker(anchorMessage: anchorMessage);
  }

  Future<void> _sendReadIdleIcebreakerIfStillIdle(
      String anchorMessageId) async {
    if (!mounted) return;
    if (_pendingReadIdleAnchorMessageId != anchorMessageId) return;
    if (!_isCurrentChatActive()) return;
    if (_isUserDrafting) return;
    if (state.isTyping || state.isProcessing) return;
    if (_lastReadIdleIcebreakerAnchorMessageId == anchorMessageId) return;

    final anchorIndex =
        state.messages.indexWhere((m) => m.id == anchorMessageId);
    if (anchorIndex < 0) return;

    final hasUserReplyAfterAnchor = state.messages
        .skip(anchorIndex + 1)
        .any((m) => m.type == CharacterChatMessageType.user);
    if (hasUserReplyAfterAnchor) return;

    final lastMessage = state.messages.isNotEmpty ? state.messages.last : null;
    if (lastMessage == null ||
        lastMessage.type != CharacterChatMessageType.character) {
      return;
    }

    final lutsToneProfile = _buildLutsToneProfile();
    final icebreaker = LutsTonePolicy.buildReadIdleIcebreakerQuestion(
      lutsToneProfile,
      affinityPhase: state.affinity.phase,
      now: DateTime.now(),
    );
    final normalized = _applyLutsTemplateTone(
      icebreaker,
      profile: lutsToneProfile,
    );
    if (normalized.isEmpty) return;

    _lastReadIdleIcebreakerAnchorMessageId = anchorMessageId;
    _pendingReadIdleAnchorMessageId = null;
    addCharacterMessage(normalized, scheduleReadIdleIcebreaker: false);
  }

  String _buildFirstMeetPrompt({required int introTurn}) {
    final safeIntroTurn = introTurn < 1 ? 1 : (introTurn > 4 ? 4 : introTurn);
    final String goal;
    if (safeIntroTurn == 1) {
      goal = '첫 인사 직후 단계: 사용자의 현재 관심사 한 가지를 듣고 가볍게 공감하세요.';
    } else if (safeIntroTurn == 2) {
      goal = '두 번째 단계: 사용자의 성향/대화 톤을 파악하는 질문 1개만 하세요.';
    } else if (safeIntroTurn == 3) {
      goal = '세 번째 단계: 관심사나 대화 선호를 확인하고 관계 기반은 최소로 유지하세요.';
    } else {
      goal = '네 번째 단계: 아이스브레이킹 마무리. 필요하면 본론으로 자연스럽게 전환하세요.';
    }

    return '''
[FIRST_MEET MODE - $_firstMeetConversationMode]
- 현재 introTurn: $safeIntroTurn
- 목표: $goal

필수 규칙:
1) 질문은 필요할 때만 0~1개 사용하세요.
2) 사전 관계/사건/공동 과거를 절대 가정하지 마세요.
3) 친밀 호칭 강요 금지. 기본 호칭은 중립적으로 유지하세요.
4) 초반 3~4턴은 소개/성향 파악 중심으로 진행하세요.
5) 사용자가 명시적으로 운세/문제 해결을 요청하면 즉시 본론으로 전환하세요.
6) 답변을 단절형 문장으로 끝내지 말고, 짧은 브릿지 문장이나 가벼운 질문으로 자연스럽게 이어가세요.
''';
  }

  /// 유저 메시지 추가
  void addUserMessage(String text) {
    _isUserDrafting = false;
    _cancelReadIdleIcebreaker();
    final message = CharacterChatMessage.user(text);
    state = state.copyWith(
      messages: [...state.messages, message],
      isProcessing: true,
    );

    // 사용자가 응답했으므로 Follow-up 타이머 취소
    _followUpScheduler.cancelFollowUp(_characterId);

    // DB 동기화 큐에 추가 (debounced)
    _queueForSync();
  }

  /// 캐릭터 메시지 추가
  void addCharacterMessage(
    String text, {
    int? affinityChange,
    bool scheduleReadIdleIcebreaker = true,
  }) {
    final message = CharacterChatMessage.character(
      text,
      _characterId,
      affinityChange: affinityChange,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
      isProcessing: false,
      isCharacterTyping: false, // DM 목록에서 "입력 중..." 해제
      unreadCount: state.unreadCount + 1, // 읽지 않은 메시지 증가
    );

    // 🆕 채팅방에 없으면 푸시 알림 + 진동 (카카오톡 스타일)
    _triggerNotificationIfNeeded(text);

    // 캐릭터 응답 후 Follow-up 스케줄 시작
    _startFollowUpSchedule();

    if (scheduleReadIdleIcebreaker) {
      _scheduleReadIdleIcebreaker(anchorMessage: message);
    } else {
      _cancelReadIdleIcebreaker();
    }

    // DB 동기화 큐에 추가 (debounced)
    _queueForSync();
  }

  /// Proactive 메시지 추가 (점심 사진 등 시간대 기반 자발적 메시지)
  ///
  /// [message] CharacterChatMessage - 이미 생성된 proactive 메시지
  void addProactiveMessage(CharacterChatMessage message) {
    final lutsToneProfile = _buildLutsToneProfile();
    final normalizedMessage = _isLutsCharacter
        ? message.copyWith(
            text: _applyLutsTemplateTone(
              message.text,
              profile: lutsToneProfile,
            ),
          )
        : message;

    state = state.copyWith(
      messages: [...state.messages, normalizedMessage],
      isTyping: false,
      isProcessing: false,
      isCharacterTyping: false,
      unreadCount: state.unreadCount + 1,
    );

    // 🆕 채팅방에 없으면 푸시 알림 + 진동 (카카오톡 스타일)
    _triggerNotificationIfNeeded(normalizedMessage.text);

    _scheduleReadIdleIcebreaker(anchorMessage: normalizedMessage);

    // DB 동기화 큐에 추가
    _queueForSync();
  }

  /// 카카오톡 스타일 알림 트리거 (채팅방에 없을 때만)
  void _triggerNotificationIfNeeded(String messageText) {
    // 현재 열려있는 채팅방 확인
    final activeChatId = _ref.read(activeCharacterChatProvider);

    // 이 캐릭터의 채팅방에 있으면 알림 안함 (카카오톡 동작)
    if (activeChatId == _characterId) return;

    // 푸시 알림 + 진동
    CharacterMessageNotificationService().notifyNewMessage(
      characterId: _characterId,
      characterName: _character.name,
      messagePreview: messageText,
    );

    // 앱 아이콘 배지 업데이트 (전체 unread 합산)
    _updateTotalUnreadBadge();
  }

  /// 앱 아이콘 배지 숫자 업데이트 (전체 캐릭터 unread 합산)
  void _updateTotalUnreadBadge() {
    int total = 0;
    for (final char in _allCharacters) {
      try {
        final chatState = _ref.read(characterChatProvider(char.id));
        total += chatState.unreadCount;
      } catch (_) {
        // Provider 없는 경우 무시
      }
    }
    AppIconBadgeService.updateBadgeCount(total);
  }

  /// DB 동기화 큐에 메시지 추가 (debounced) + 로컬 즉시 저장
  void _queueForSync() {
    if (state.messages.isEmpty) return;

    // ⚡ 로컬에 즉시 저장 (앱 강제종료 대비)
    _localService.saveConversation(_characterId, state.messages);

    // 서버 동기화 (debounced 3초)
    ChatSyncService.instance.queueForSync(
      chatId: _characterId,
      chatType: 'character',
      messages: state.messages.map((m) => m.toJson()).toList(),
    );
  }

  /// Follow-up 스케줄 시작
  void _startFollowUpSchedule() {
    final pattern = _character.behaviorPattern;

    _followUpScheduler.scheduleFollowUp(
      characterId: _characterId,
      pattern: pattern,
      onFollowUp: _handleFollowUp,
    );
  }

  /// Follow-up 콜백 처리
  void _handleFollowUp(int attemptNumber, String? message) {
    // Follow-up 메시지가 있으면 사용, 없으면 API 호출
    if (message != null && message.isNotEmpty) {
      _sendFollowUpMessage(message);
    } else {
      _generateFollowUpMessage(attemptNumber);
    }
  }

  /// 미리 정의된 Follow-up 메시지 전송
  Future<void> _sendFollowUpMessage(String message) async {
    // 타이핑 인디케이터
    setTyping(true);

    final lutsToneProfile = _buildLutsToneProfile();
    final normalizedMessage = _applyLutsTemplateTone(
      message,
      profile: lutsToneProfile,
    );

    // 캐릭터 응답 속도에 맞는 딜레이
    final typingDelay = _character.behaviorPattern.getTypingDelay();
    await Future.delayed(typingDelay);

    // 메시지 추가 (Follow-up이므로 새로운 스케줄은 시작하지 않음)
    final msg = CharacterChatMessage.character(normalizedMessage, _characterId);
    state = state.copyWith(
      messages: [...state.messages, msg],
      isTyping: false,
      isCharacterTyping: false,
      unreadCount: state.unreadCount + 1,
    );
  }

  /// AI로 Follow-up 메시지 생성
  Future<void> _generateFollowUpMessage(int attemptNumber) async {
    setTyping(true);

    try {
      final lutsToneProfile = _buildLutsToneProfile();

      // 메시지 히스토리 준비
      final recentMessages = state.messages.length > 10
          ? state.messages.sublist(state.messages.length - 10)
          : state.messages;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // Follow-up 컨텍스트 추가
      final followUpPrompt = '''
[시스템: 사용자가 한동안 응답이 없습니다. 캐릭터답게 자연스럽게 먼저 말을 걸어주세요.
- 이것은 $attemptNumber번째 시도입니다.
- 너무 길게 말하지 말고, 짧고 자연스럽게 말해주세요.
- 캐릭터의 성격과 말투를 유지해주세요.]
''';

      final lutsStylePrompt =
          _buildLutsStyleGuidePrompt(lutsToneProfile).trim();
      final enhancedSystemPrompt = [
        _character.systemPrompt,
        followUpPrompt,
        if (lutsStylePrompt.isNotEmpty) lutsStylePrompt,
      ].join('\n\n');

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedSystemPrompt,
        messages: history,
        userMessage: '[사용자 응답 대기 중]',
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
      );

      // 타이핑 딜레이
      final typingDelay = _character.behaviorPattern.getTypingDelay();
      await Future.delayed(typingDelay);

      // 메시지 추가
      final msg = CharacterChatMessage.character(
        _applyLutsGeneratedTone(
          response.response,
          profile: lutsToneProfile,
        ),
        _characterId,
      );
      state = state.copyWith(
        messages: [...state.messages, msg],
        isTyping: false,
        isCharacterTyping: false,
        unreadCount: state.unreadCount + 1,
      );
    } catch (e) {
      setTyping(false);
      // Follow-up 실패는 무시 (필수 기능 아님)
    }
  }

  /// Follow-up 스케줄 취소
  void cancelFollowUp() {
    _followUpScheduler.cancelFollowUp(_characterId);
  }

  /// 대기 중인 유저 메시지에 대한 AI 응답 생성 (앱 재시작 시)
  Future<void> _generatePendingResponse() async {
    if (state.messages.isEmpty) return;

    final lastMessage = state.messages.last;
    // 마지막이 유저 메시지가 아니면 무시
    if (lastMessage.type != CharacterChatMessageType.user) return;

    // 이미 처리 중이면 무시
    if (state.isTyping || state.isProcessing) return;

    setTyping(true);

    try {
      final lutsToneProfile =
          _buildLutsToneProfile(currentUserMessage: lastMessage.text);
      final useFirstMeetMode = _shouldApplyFirstMeetMode();
      final introTurn = _assistantTurnCount();

      // 메시지 히스토리 준비 (마지막 유저 메시지 제외)
      final messagesWithoutLast = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutLast.length > 20
          ? messagesWithoutLast.sublist(messagesWithoutLast.length - 20)
          : messagesWithoutLast;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();
      final firstMeetPrompt =
          useFirstMeetMode ? _buildFirstMeetPrompt(introTurn: introTurn) : '';
      final lutsStylePrompt =
          _buildLutsStyleGuidePrompt(lutsToneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        emojiInstruction,
        if (firstMeetPrompt.isNotEmpty) firstMeetPrompt,
        if (lutsStylePrompt.isNotEmpty) lutsStylePrompt,
      ].join('\n\n');

      // API 호출
      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: lastMessage.text,
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
        conversationMode: useFirstMeetMode ? _firstMeetConversationMode : null,
        introTurn: useFirstMeetMode ? introTurn : null,
      );

      // 타이핑 딜레이
      final emotion = ResponseDelayConfig.parseEmotion(response.emotionTag);
      final typingDelay = ResponseDelayConfig.calculateTypingDelay(
        emotion: emotion,
        responseLength: response.response.length,
      );
      await Future.delayed(Duration(milliseconds: typingDelay));

      // 캐릭터 응답 추가
      addCharacterMessage(
        _applyLutsGeneratedTone(
          response.response,
          profile: lutsToneProfile,
        ),
      );
    } catch (e) {
      setError(e.toString());
    }
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
      isCharacterTyping: typing, // DM 목록용
    );
  }

  /// 아직 읽지 않은 사용자 메시지를 모두 읽음 처리 (sent -> read)
  ///
  /// 연속 전송 시 이전 메시지의 "1"이 남는 현상을 막기 위해
  /// 마지막 하나가 아니라 pending 상태 전체를 정리합니다.
  void markPendingUserMessagesAsRead() {
    final now = DateTime.now();
    final messages = List<CharacterChatMessage>.from(state.messages);
    var hasChanged = false;

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.type == CharacterChatMessageType.user &&
          message.status == MessageStatus.sent) {
        messages[i] = message.copyWith(
          status: MessageStatus.read,
          readAt: now,
        );
        hasChanged = true;
      }
    }

    if (hasChanged) {
      state = state.copyWith(messages: messages);
    }
  }

  /// @deprecated Use [markPendingUserMessagesAsRead]
  void markLastUserMessageAsRead() => markPendingUserMessagesAsRead();

  /// 읽지 않은 메시지 수 초기화 (채팅방 진입 시)
  void clearUnreadCount() {
    state = state.copyWith(unreadCount: 0);
    // 마지막으로 읽은 시간 저장 (앱 재시작 후에도 유지)
    _localService.saveLastReadTimestamp(_characterId);
    _scheduleReadIdleIcebreakerForReadEvent();
  }

  void onUserDraftChanged(String draftText) {
    final hasDraft = draftText.trim().isNotEmpty;
    if (_isUserDrafting == hasDraft) return;

    _isUserDrafting = hasDraft;
    if (hasDraft) {
      _cancelReadIdleIcebreaker();
      return;
    }

    _scheduleReadIdleIcebreakerForReadEvent();
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

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 레거시 대화 초기화 (비동기 정리 API로 위임)
  void clearConversation() {
    unawaited(clearConversationData());
  }

  /// 대화/호감도/서버 스레드까지 포함한 명시적 초기화
  Future<void> clearConversationData() async {
    _cancelReadIdleIcebreaker();
    cancelFollowUp();

    await _service.deleteConversation(_characterId);
    await _affinityService.deleteAffinity(
      _characterId,
      deleteFromServer: true,
    );

    // 서버 동기화 큐에도 빈 메시지를 반영해 레이스 조건을 줄임
    await ChatSyncService.instance.queueForSync(
      chatId: _characterId,
      chatType: 'character',
      messages: const <Map<String, dynamic>>[],
    );

    final selectedCharacter = _ref.read(selectedCharacterProvider);
    if (selectedCharacter?.id == _characterId) {
      _ref.read(activeCharacterChatProvider.notifier).state = null;
      _ref.read(chatModeProvider.notifier).state = ChatMode.fortune;
      _ref.read(selectedCharacterProvider.notifier).state = null;
    }

    state = CharacterChatState(characterId: _characterId);
  }

  /// 호감도 업데이트 (기존 호환용)
  void updateAffinity(AffinityEvent event) {
    updateAffinityWithPoints(event.points, event.interactionType);
  }

  /// 호감도 업데이트 (동적 포인트 지원)
  void updateAffinityWithPoints(int points,
      [AffinityInteractionType interactionType =
          AffinityInteractionType.neutral]) {
    final previousPhase = state.affinity.phase;
    final newAffinity = state.affinity.addPointsWithTracking(
      points,
      interactionType: interactionType,
    );
    state = state.copyWith(affinity: newAffinity);

    // 단계 전환 감지
    if (newAffinity.phase != previousPhase &&
        newAffinity.phase.index > previousPhase.index) {
      _onPhaseTransition(previousPhase, newAffinity.phase);
    }

    // 백그라운드에서 저장 (debounced)
    _affinityService.saveAffinity(_characterId, newAffinity,
        syncToServer: true);
  }

  /// 단계 전환 시 호출
  void _onPhaseTransition(AffinityPhase previousPhase, AffinityPhase newPhase) {
    final transition = PhaseTransitionResult(
      previousPhase: previousPhase,
      newPhase: newPhase,
    );

    // 축하 메시지를 시스템 메시지로 추가
    if (transition.isUpgrade && transition.celebrationMessage.isNotEmpty) {
      final systemMessage = CharacterChatMessage.system(
        '🎉 ${transition.celebrationMessage}\n✨ ${transition.unlockDescription}',
      );
      state = state.copyWith(
        messages: [...state.messages, systemMessage],
      );
    }
  }

  /// 호감도 직접 설정 (불러오기용)
  void setAffinity(CharacterAffinity affinity) {
    state = state.copyWith(affinity: affinity);
  }

  /// 메시지 전송 (API 호출 포함) - 인스타그램 DM 스타일 딜레이 적용
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 🪙 토큰 소비 체크 (4토큰/메시지)
    final hasUnlimitedAccess = _ref.read(hasUnlimitedTokensProvider);
    if (!hasUnlimitedAccess) {
      final tokenCost = SoulRates.getTokenCost('character-chat');
      final tokenNotifier = _ref.read(tokenProvider.notifier);
      final consumed = await tokenNotifier.consumeTokens(
        fortuneType: 'character-chat',
        amount: tokenCost,
      );

      if (!consumed) {
        state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
        return;
      }
    }

    // 1단계: 유저 메시지 추가 (status: sent → "1" 표시)
    addUserMessage(text);

    // 2단계: 읽음 딜레이 (0.5~1.5초) - AI가 메시지를 "봤다"는 느낌
    final readDelay = ResponseDelayConfig.calculateReadDelay();
    await Future.delayed(Duration(milliseconds: readDelay));

    // 3단계: 읽음 처리 → pending "1" 전체 정리
    markPendingUserMessagesAsRead();

    // 4단계: 타이핑 시작
    setTyping(true);

    try {
      final lutsToneProfile = _buildLutsToneProfile(currentUserMessage: text);
      final useFirstMeetMode = _shouldApplyFirstMeetMode();
      final introTurn = _assistantTurnCount();

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

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();
      final firstMeetPrompt =
          useFirstMeetMode ? _buildFirstMeetPrompt(introTurn: introTurn) : '';
      final lutsStylePrompt =
          _buildLutsStyleGuidePrompt(lutsToneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        emojiInstruction,
        if (firstMeetPrompt.isNotEmpty) firstMeetPrompt,
        if (lutsStylePrompt.isNotEmpty) lutsStylePrompt,
      ].join('\n\n');

      // API 호출
      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: text,
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
        conversationMode: useFirstMeetMode ? _firstMeetConversationMode : null,
        introTurn: useFirstMeetMode ? introTurn : null,
      );

      // 5단계: 감정 기반 타이핑 딜레이 (클라이언트 측)
      final emotion = ResponseDelayConfig.parseEmotion(response.emotionTag);
      final typingDelay = ResponseDelayConfig.calculateTypingDelay(
        emotion: emotion,
        responseLength: response.response.length,
      );
      await Future.delayed(Duration(milliseconds: typingDelay));

      // 호감도 포인트 계산 (애니메이션용)
      final affinityPoints = response.affinityDelta.points;
      final normalizedResponse = _applyLutsGeneratedTone(
        response.response,
        profile: lutsToneProfile,
        encourageContinuity: useFirstMeetMode,
      );

      // 6단계: 캐릭터 응답 추가 (호감도 변경값 포함)
      addCharacterMessage(normalizedResponse, affinityChange: affinityPoints);

      // 호감도 동적 업데이트 (AI 평가 기반)
      final interactionType = response.affinityDelta.isPositive
          ? AffinityInteractionType.positive
          : response.affinityDelta.isNegative
              ? AffinityInteractionType.negative
              : AffinityInteractionType.neutral;
      updateAffinityWithPoints(affinityPoints, interactionType);
    } catch (e) {
      setError(e.toString());
    }
  }

  /// 첫 메시지로 대화 시작 (unreadCount 증가 없이 - 사용자가 채팅방에 있으므로)
  void startConversation([String? legacyFirstMessage]) {
    if (legacyFirstMessage != null) {
      // 하위 호환: 전달값이 있더라도 first-meet 시작 문구를 항상 사용합니다.
    }
    if (state.messages.isEmpty) {
      final message = CharacterChatMessage.character(
          _buildFirstMeetOpening(), _characterId);
      state = state.copyWith(
        messages: [...state.messages, message],
        // unreadCount는 증가시키지 않음 - 사용자가 이미 채팅방에 있음
      );
    }
  }

  /// 운세 상담 요청 (운세 전문가 캐릭터용)
  /// 실제 운세 API를 호출하여 상세한 운세 데이터를 가져온 후, 캐릭터가 전달
  Future<void> sendFortuneRequest(
      String fortuneType, String requestMessage) async {
    // 🪙 토큰 소비 체크 (4토큰/메시지)
    final hasUnlimitedAccess = _ref.read(hasUnlimitedTokensProvider);
    if (!hasUnlimitedAccess) {
      final tokenCost = SoulRates.getTokenCost('character-chat');
      final tokenNotifier = _ref.read(tokenProvider.notifier);
      final consumed = await tokenNotifier.consumeTokens(
        fortuneType: 'character-chat',
        amount: tokenCost,
      );

      if (!consumed) {
        state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
        return;
      }
    }

    // 1단계: 유저 메시지 추가
    addUserMessage(requestMessage);

    // 2단계: 읽음 딜레이
    final readDelay = ResponseDelayConfig.calculateReadDelay();
    await Future.delayed(Duration(milliseconds: readDelay));

    // 3단계: 읽음 처리
    markPendingUserMessagesAsRead();

    // 4단계: 타이핑 시작
    setTyping(true);

    try {
      final lutsToneProfile =
          _buildLutsToneProfile(currentUserMessage: requestMessage);
      // 🆕 실제 운세 API 호출하여 상세 데이터 가져오기
      final fortuneData = await _fetchFortuneData(fortuneType, {});
      final fortuneDataContext = _formatFortuneDataForContext(fortuneData);

      // 메시지 히스토리 준비
      final messagesWithoutCurrent = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutCurrent.length > 20
          ? messagesWithoutCurrent.sublist(messagesWithoutCurrent.length - 20)
          : messagesWithoutCurrent;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();

      // 운세 상담 컨텍스트를 포함한 API 호출 (실제 운세 데이터 포함)
      final fortuneContext = '''
[운세 상담 요청]
- 운세 타입: $fortuneType
- 사용자 요청: $requestMessage

[실제 운세 분석 결과]
$fortuneDataContext

위의 실제 운세 분석 결과를 바탕으로 사용자에게 운세를 전달해주세요.
캐릭터의 말투와 성격을 유지하면서 운세 정보를 자연스럽게 전달해주세요.
점수, 행운 아이템, 추천 사항 등 실제 데이터를 활용하여 구체적으로 이야기해주세요.

$emojiInstruction
''';

      final lutsStylePrompt =
          _buildLutsStyleGuidePrompt(lutsToneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        fortuneContext,
        if (lutsStylePrompt.isNotEmpty) lutsStylePrompt,
      ].join('\n\n');

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: requestMessage,
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
      );

      // 5단계: 감정 기반 타이핑 딜레이
      final emotion = ResponseDelayConfig.parseEmotion(response.emotionTag);
      final typingDelay = ResponseDelayConfig.calculateTypingDelay(
        emotion: emotion,
        responseLength: response.response.length,
      );
      await Future.delayed(Duration(milliseconds: typingDelay));

      // 호감도 포인트 계산 (애니메이션용)
      final affinityPoints = response.affinityDelta.points;
      final normalizedResponse = _applyLutsGeneratedTone(
        response.response,
        profile: lutsToneProfile,
      );

      // 6단계: 캐릭터 응답 추가 (호감도 변경값 포함)
      addCharacterMessage(normalizedResponse, affinityChange: affinityPoints);

      // 호감도 동적 업데이트 (AI 평가 기반)
      final interactionType = response.affinityDelta.isPositive
          ? AffinityInteractionType.positive
          : response.affinityDelta.isNegative
              ? AffinityInteractionType.negative
              : AffinityInteractionType.neutral;
      updateAffinityWithPoints(affinityPoints, interactionType);
    } catch (e) {
      Logger.error('[CharacterChat] Fortune request failed', e);
      setError(e.toString());
    }
  }

  /// 운세 상담 요청 (설문 답변 포함 - 캐릭터가 설문 결과 기반으로 상담)
  /// 실제 운세 API를 호출하여 상세한 운세 데이터를 가져온 후, 캐릭터가 전달
  Future<void> sendFortuneRequestWithAnswers(
    String fortuneType,
    String requestMessage,
    Map<String, dynamic> surveyAnswers,
  ) async {
    // 토큰 소비 체크 (4토큰/메시지)
    final hasUnlimitedAccess = _ref.read(hasUnlimitedTokensProvider);
    if (!hasUnlimitedAccess) {
      final tokenCost = SoulRates.getTokenCost('character-chat');
      final tokenNotifier = _ref.read(tokenProvider.notifier);
      final consumed = await tokenNotifier.consumeTokens(
        fortuneType: 'character-chat',
        amount: tokenCost,
      );

      if (!consumed) {
        state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
        return;
      }
    }

    // 1단계: 유저 메시지 추가
    addUserMessage(requestMessage);

    // 2단계: 읽음 딜레이
    final readDelay = ResponseDelayConfig.calculateReadDelay();
    await Future.delayed(Duration(milliseconds: readDelay));

    // 3단계: 읽음 처리
    markPendingUserMessagesAsRead();

    // 4단계: 타이핑 시작
    setTyping(true);

    try {
      final lutsToneProfile =
          _buildLutsToneProfile(currentUserMessage: requestMessage);
      // 🆕 실제 운세 API 호출하여 상세 데이터 가져오기 (설문 답변 포함)
      final fortuneData = await _fetchFortuneData(fortuneType, surveyAnswers);
      final fortuneDataContext = _formatFortuneDataForContext(fortuneData);

      // 메시지 히스토리 준비
      final messagesWithoutCurrent = state.messages.length > 1
          ? state.messages.sublist(0, state.messages.length - 1)
          : <CharacterChatMessage>[];
      final recentMessages = messagesWithoutCurrent.length > 20
          ? messagesWithoutCurrent.sublist(messagesWithoutCurrent.length - 20)
          : messagesWithoutCurrent;
      final history = recentMessages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();

      // 설문 답변을 사람이 읽기 쉬운 형식으로 변환
      final answersDescription = _formatSurveyAnswers(surveyAnswers);

      // 운세 상담 컨텍스트 (설문 답변 + 실제 운세 데이터 포함)
      final fortuneContext = '''
[운세 상담 요청]
- 운세 타입: $fortuneType
- 사용자 요청: $requestMessage
- 사용자 설문 답변:
$answersDescription

[실제 운세 분석 결과]
$fortuneDataContext

위의 실제 운세 분석 결과를 바탕으로 사용자에게 운세를 전달해주세요.
캐릭터의 말투와 성격을 유지하면서 설문 답변 내용을 자연스럽게 반영해주세요.
점수, 행운 아이템, 추천 사항 등 실제 데이터를 활용하여 구체적으로 이야기해주세요.
사용자가 선택한 내용을 언급하면서 더 친근하고 맞춤화된 조언을 해주세요.

$emojiInstruction
''';

      final lutsStylePrompt =
          _buildLutsStyleGuidePrompt(lutsToneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        fortuneContext,
        if (lutsStylePrompt.isNotEmpty) lutsStylePrompt,
      ].join('\n\n');

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: requestMessage,
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
      );

      // 5단계: 감정 기반 타이핑 딜레이
      final emotion = ResponseDelayConfig.parseEmotion(response.emotionTag);
      final typingDelay = ResponseDelayConfig.calculateTypingDelay(
        emotion: emotion,
        responseLength: response.response.length,
      );
      await Future.delayed(Duration(milliseconds: typingDelay));

      // 호감도 포인트 계산 (애니메이션용)
      final affinityPoints = response.affinityDelta.points;
      final normalizedResponse = _applyLutsGeneratedTone(
        response.response,
        profile: lutsToneProfile,
      );

      // 6단계: 캐릭터 응답 추가 (호감도 변경값 포함)
      addCharacterMessage(normalizedResponse, affinityChange: affinityPoints);

      // 호감도 동적 업데이트 (AI 평가 기반)
      final interactionType = response.affinityDelta.isPositive
          ? AffinityInteractionType.positive
          : response.affinityDelta.isNegative
              ? AffinityInteractionType.negative
              : AffinityInteractionType.neutral;
      updateAffinityWithPoints(affinityPoints, interactionType);
    } catch (e) {
      Logger.error('[CharacterChat] Fortune request with answers failed', e);
      setError(e.toString());
    }
  }

  /// 설문 답변을 사람이 읽기 쉬운 형식으로 변환
  String _formatSurveyAnswers(Map<String, dynamic> answers) {
    if (answers.isEmpty) return '(설문 답변 없음)';

    final buffer = StringBuffer();
    for (final entry in answers.entries) {
      final key = entry.key;
      final value = entry.value;

      // 값 형식에 따라 처리
      String formattedValue;
      if (value is List) {
        formattedValue = value.join(', ');
      } else if (value is Map) {
        formattedValue =
            value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      } else {
        formattedValue = value.toString();
      }

      buffer.writeln('  - $key: $formattedValue');
    }
    return buffer.toString();
  }

  Future<String> _resolveFortuneUserId() async {
    final profileAsync = _ref.read(userProfileProvider);
    final profileId = profileAsync.maybeWhen(
      data: (profile) => profile?.id,
      orElse: () => null,
    );

    if (profileId != null && profileId.isNotEmpty) {
      return profileId;
    }

    return _storageService.getOrCreateGuestId();
  }

  /// 🆕 운세 API 호출하여 Fortune 데이터 가져오기
  Future<Fortune?> _fetchFortuneData(
    String fortuneType,
    Map<String, dynamic> answers,
  ) async {
    try {
      final apiService = _ref.read(fortuneApiServiceProvider);
      final userProfile = _getUserProfileMap();

      // fortuneType을 API 타입으로 매핑
      final apiFortuneType = _mapToApiFortuneType(fortuneType);

      // 사용자 프로필 정보 추가
      final params = <String, dynamic>{
        ...answers,
        if (userProfile != null) ...userProfile,
      };

      Logger.info('[CharacterChat] Calling fortune API', {
        'fortuneType': apiFortuneType,
        'hasParams': params.isNotEmpty,
      });

      // 유저 ID 가져오기 (비로그인은 guest_<uuid> 사용)
      final userId = await _resolveFortuneUserId();

      final fortune = await apiService.getFortune(
        userId: userId,
        fortuneType: apiFortuneType,
        params: params,
      );

      Logger.info('[CharacterChat] Fortune API success', {
        'fortuneType': apiFortuneType,
        'hasContent': fortune.content.isNotEmpty,
        'score': fortune.overallScore,
      });

      return fortune;
    } catch (e) {
      Logger.warning('[CharacterChat] Fortune API failed, using fallback',
          {'error': e.toString()});
      return null;
    }
  }

  /// fortuneType 문자열을 API fortuneType으로 매핑
  String _mapToApiFortuneType(String fortuneType) {
    const mapping = {
      'daily': 'daily',
      'newYear': 'new_year',
      'daily_calendar': 'daily_calendar',
      'career': 'career',
      'love': 'love',
      'compatibility': 'compatibility',
      'tarot': 'tarot',
      'mbti': 'mbti',
      'traditional': 'saju',
      'faceReading': 'face-reading',
      'biorhythm': 'biorhythm',
      'money': 'money',
      'luckyItems': 'lucky-items',
      'lotto': 'lotto',
      'health': 'health',
      'dream': 'dream',
      'pastLife': 'past-life',
      'gameEnhance': 'game-enhance',
      'pet': 'pet',
      'family': 'family',
      'naming': 'naming',
    };
    return mapping[fortuneType] ?? fortuneType;
  }

  /// 🆕 Fortune 데이터를 캐릭터 컨텍스트용 텍스트로 변환
  String _formatFortuneDataForContext(Fortune? fortune) {
    if (fortune == null) {
      return '(운세 데이터를 가져오지 못했습니다. 일반적인 조언을 제공해주세요.)';
    }

    final buffer = StringBuffer();

    // 기본 운세 내용
    if (fortune.content.isNotEmpty) {
      buffer.writeln('📌 운세 내용: ${fortune.content}');
    }

    // 전체 점수
    if (fortune.overallScore != null) {
      buffer.writeln('⭐ 전체 점수: ${fortune.overallScore}점');
    }

    // 설명
    if (fortune.description != null && fortune.description!.isNotEmpty) {
      buffer.writeln('📝 설명: ${fortune.description}');
    }

    // 요약
    if (fortune.summary != null && fortune.summary!.isNotEmpty) {
      buffer.writeln('📋 요약: ${fortune.summary}');
    }

    // 육각형 점수 (연애, 재물, 건강 등)
    if (fortune.hexagonScores != null && fortune.hexagonScores!.isNotEmpty) {
      buffer.writeln('📊 세부 점수:');
      fortune.hexagonScores!.forEach((key, value) {
        buffer.writeln('  - $key: $value점');
      });
    }

    // 점수 세부 분류
    if (fortune.scoreBreakdown != null && fortune.scoreBreakdown!.isNotEmpty) {
      buffer.writeln('📈 점수 분석:');
      fortune.scoreBreakdown!.forEach((key, value) {
        buffer.writeln('  - $key: $value');
      });
    }

    // 행운 아이템
    if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) {
      buffer.writeln('🍀 행운 아이템:');
      fortune.luckyItems!.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          buffer.writeln('  - $key: $value');
        }
      });
    }

    // 추천 사항
    if (fortune.recommendations != null &&
        fortune.recommendations!.isNotEmpty) {
      buffer.writeln('💡 추천 사항:');
      for (final rec in fortune.recommendations!) {
        buffer.writeln('  - $rec');
      }
    }

    // 주의 사항
    if (fortune.warnings != null && fortune.warnings!.isNotEmpty) {
      buffer.writeln('⚠️ 주의 사항:');
      for (final warning in fortune.warnings!) {
        buffer.writeln('  - $warning');
      }
    }

    // 특별 팁
    if (fortune.specialTip != null && fortune.specialTip!.isNotEmpty) {
      buffer.writeln('✨ 특별 팁: ${fortune.specialTip}');
    }

    // 인사말 (있으면)
    if (fortune.greeting != null && fortune.greeting!.isNotEmpty) {
      buffer.writeln('👋 인사말: ${fortune.greeting}');
    }

    return buffer.toString();
  }

  /// 대화 스레드 초기화 (DB에서 불러오기)
  Future<void> initConversation() async {
    // 채팅방 진입 시 항상 읽지 않은 메시지 초기화 (isInitialized 체크 전에!)
    clearUnreadCount();

    // 이미 초기화됨
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
      // 호감도 로드 (로컬 우선, 서버 폴백)
      final affinity = await _affinityService.loadAffinity(_characterId);
      state = state.copyWith(affinity: affinity);

      final messages = await _service.loadConversation(_characterId);

      if (messages.isNotEmpty) {
        // DB에서 불러온 대화가 있으면 사용
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          isInitialized: true,
        );

        // 마지막 메시지가 유저면 → AI 응답 생성 (앱 재시작 시 무시 방지)
        if (messages.last.type == CharacterChatMessageType.user) {
          _generatePendingResponse();
        } else {
          // 캐릭터 메시지면 Follow-up 스케줄 시작
          _startFollowUpSchedule();
        }
      } else {
        // 없으면 캐릭터 첫 메시지로 시작
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
        );
        startConversation();
      }
    } catch (e) {
      // 에러 시에도 초기화 완료 처리 (첫 메시지로 시작)
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
      startConversation();
    }
  }

  /// 대화 스레드 저장 (화면 이탈 시 호출)
  Future<bool> saveOnExit() async {
    // 호감도 저장 (항상)
    await _affinityService.saveAffinity(_characterId, state.affinity);

    // 메시지가 없으면 저장 안 함
    if (state.messages.isEmpty) return true;

    return await _service.saveConversation(_characterId, state.messages);
  }

  /// 선택지 메시지 추가
  void addChoiceMessage(ChoiceSet choiceSet, {String? situation}) {
    final message =
        CharacterChatMessage.choice(choiceSet, situation: situation);
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
      isProcessing: false,
    );
  }

  /// 선택지 선택 처리 - 인스타그램 DM 스타일 딜레이 적용
  Future<void> handleChoiceSelection(CharacterChoice choice) async {
    // 🪙 토큰 소비 체크 (4토큰/메시지)
    final hasUnlimitedAccess = _ref.read(hasUnlimitedTokensProvider);
    if (!hasUnlimitedAccess) {
      final tokenCost = SoulRates.getTokenCost('character-chat');
      final tokenNotifier = _ref.read(tokenProvider.notifier);
      final consumed = await tokenNotifier.consumeTokens(
        fortuneType: 'character-chat',
        amount: tokenCost,
      );

      if (!consumed) {
        state = state.copyWith(error: 'INSUFFICIENT_TOKENS');
        return;
      }
    }

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

    // 읽음 처리 → pending "1" 전체 정리
    markPendingUserMessagesAsRead();

    // 타이핑 시작
    setTyping(true);

    try {
      final lutsToneProfile =
          _buildLutsToneProfile(currentUserMessage: choice.text);
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

      // 이모티콘 빈도 지시문 추가
      final emojiInstruction = _character.behaviorPattern.getEmojiInstruction();
      final lutsStylePrompt =
          _buildLutsStyleGuidePrompt(lutsToneProfile).trim();
      final enhancedPrompt = [
        _character.systemPrompt,
        emojiInstruction,
        if (lutsStylePrompt.isNotEmpty) lutsStylePrompt,
      ].join('\n\n');

      final response = await _service.sendMessage(
        characterId: _characterId,
        systemPrompt: enhancedPrompt,
        messages: history,
        userMessage: '(사용자가 "${choice.text}"를 선택함)',
        oocInstructions: _character.oocInstructions,
        emojiFrequency: _character.behaviorPattern.emojiFrequencyString,
        emoticonStyle: _character.behaviorPattern.emoticonStyleString,
        characterName: _character.name,
        characterTraits: _character.personality,
        clientTimestamp: DateTime.now().toIso8601String(),
        userProfile: _getUserProfileMap(),
        affinityContext: _buildAffinityContext(),
      );

      // 감정 기반 타이핑 딜레이
      final emotion = ResponseDelayConfig.parseEmotion(response.emotionTag);
      final typingDelay = ResponseDelayConfig.calculateTypingDelay(
        emotion: emotion,
        responseLength: response.response.length,
      );
      await Future.delayed(Duration(milliseconds: typingDelay));

      addCharacterMessage(
        _applyLutsGeneratedTone(
          response.response,
          profile: lutsToneProfile,
        ),
      );
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

  @override
  void dispose() {
    _cancelReadIdleIcebreaker();
    super.dispose();
  }
}
