import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/personality_dna_model.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../fortune/domain/models/match_insight.dart';
import '../../../fortune/domain/models/past_life_result.dart';
import '../../../fortune/domain/models/yearly_encounter_result.dart';
import '../../../chat_insight/data/models/chat_insight_result.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_state.dart';

const _uuid = Uuid();

/// 채팅 메시지 StateNotifier (로컬 저장 지원)
class ChatMessagesNotifier extends StateNotifier<ChatState> {
  final SharedPreferences _prefs;
  static const _storageKey = 'chat_messages_v1';
  static const _maxStoredMessages = 100;

  ChatMessagesNotifier(this._prefs) : super(const ChatState()) {
    _loadMessages();
  }

  /// 로컬에 저장된 메시지 로드
  Future<void> _loadMessages() async {
    try {
      final stored = _prefs.getString(_storageKey);
      if (stored != null) {
        final list = jsonDecode(stored) as List;
        final messages = list
            .map((j) => ChatMessage.fromJson(j as Map<String, dynamic>))
            .toList();
        state = state.copyWith(messages: messages);
      }
    } catch (e) {
      debugPrint('채팅 히스토리 로드 실패: $e');
    }
  }

  /// 메시지를 로컬에 저장
  Future<void> _saveMessages() async {
    try {
      final persistable = state.messages
          .where((m) => m.isPersistable)
          .toList();
      // 최근 N개만 저장
      final toSave = persistable.length > _maxStoredMessages
          ? persistable.sublist(persistable.length - _maxStoredMessages)
          : persistable;
      final json = toSave.map((m) => m.toJson()).toList();
      await _prefs.setString(_storageKey, jsonEncode(json));
    } catch (e) {
      debugPrint('채팅 히스토리 저장 실패: $e');
    }
  }

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
    _saveMessages();
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
    _saveMessages();
  }

  /// 운세 결과 메시지 추가
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addFortuneResultMessage({
    required String text,
    required String fortuneType,
    String? sectionKey,
    Fortune? fortune,
    DateTime? selectedDate,
    MatchInsight? matchInsight,
    PastLifeResult? pastLifeResult,
    YearlyEncounterResult? yearlyEncounterResult,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.fortuneResult,
      text: text,
      timestamp: DateTime.now(),
      fortuneType: fortuneType,
      sectionKey: sectionKey,
      fortune: fortune,
      selectedDate: selectedDate,
      matchInsight: matchInsight,
      pastLifeResult: pastLifeResult,
      yearlyEncounterResult: yearlyEncounterResult,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 사주 분석 결과 메시지 추가
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addSajuResultMessage({
    String? text,
    required Map<String, dynamic> sajuData,
    Map<String, dynamic>? sajuFortuneResult,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.sajuResult,
      text: text,
      timestamp: DateTime.now(),
      sajuData: sajuData,
      sajuFortuneResult: sajuFortuneResult,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 성격 DNA 결과 메시지 추가
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addPersonalityDnaResult({
    required PersonalityDNA dna,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.personalityDnaResult,
      timestamp: DateTime.now(),
      personalityDna: dna,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 부적 결과 메시지 추가 (이미지 + 짧은 설명)
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addTalismanResult({
    required String imageUrl,
    required String categoryName,
    required String shortDescription,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.talismanResult,
      timestamp: DateTime.now(),
      talismanImageUrl: imageUrl,
      talismanCategoryName: categoryName,
      talismanShortDescription: shortDescription,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 감사일기 결과 메시지 추가 (일기장 스타일 카드)
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addGratitudeResultMessage({
    required String gratitude1,
    required String gratitude2,
    required String gratitude3,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.gratitudeResult,
      timestamp: DateTime.now(),
      gratitude1: gratitude1,
      gratitude2: gratitude2,
      gratitude3: gratitude3,
      gratitudeDate: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// AI 코칭 결과 메시지 추가
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addCoachingResultMessage({
    required String situation,
    required String coachingAdvice,
    required List<String> actionItems,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.coachingResult,
      timestamp: DateTime.now(),
      coachingSituation: situation,
      coachingAdvice: coachingAdvice,
      coachingActionItems: actionItems,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 결정 분석 결과 메시지 추가
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addDecisionResultMessage({
    required String question,
    required List<Map<String, dynamic>> options,
    required String recommendation,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.decisionResult,
      timestamp: DateTime.now(),
      decisionQuestion: question,
      decisionOptions: options,
      decisionRecommendation: recommendation,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 하루 회고 결과 메시지 추가
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addDailyReviewResultMessage({
    required String highlight,
    required String learning,
    required String tomorrow,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.dailyReviewResult,
      timestamp: DateTime.now(),
      dailyReviewHighlight: highlight,
      dailyReviewLearning: learning,
      dailyReviewTomorrow: tomorrow,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 주간 리포트 결과 메시지 추가
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addWeeklyReviewResultMessage({
    required String summary,
    required List<String> trends,
    required List<String> actions,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 기존 대화 지우기 (자석 기능 대체)
    if (clearFirst) {
      state = const ChatState();
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.weeklyReviewResult,
      timestamp: DateTime.now(),
      weeklyReviewSummary: summary,
      weeklyReviewTrends: trends,
      weeklyReviewActions: actions,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 카톡 대화 분석 결과 메시지 추가
  void addChatInsightResult({required ChatInsightResult chatInsight}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.chatInsightResult,
      text: '대화 분석 결과',
      timestamp: DateTime.now(),
      chatInsight: chatInsight,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }

  /// 시스템 메시지 추가 (추천 칩)
  /// [showAllChips] true면 모든 기본 칩 표시 (전체운세보기 등)
  void addSystemMessage({List<String>? chipIds, bool showAllChips = false}) {
    final message = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.system,
      timestamp: DateTime.now(),
      chipIds: showAllChips ? ['__all__'] : chipIds,
    );
    state = state.copyWith(
      messages: [...state.messages, message],
    );
    _saveMessages();
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

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// 대화 초기화
  void clearConversation() {
    state = const ChatState();
    _prefs.remove(_storageKey);
  }
}

/// 채팅 메시지 Provider
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, ChatState>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ChatMessagesNotifier(prefs);
  },
);
