import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/personality_dna_model.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../fortune/domain/models/match_insight.dart';
import '../../../fortune/domain/models/past_life_result.dart';
import '../../../fortune/domain/models/yearly_encounter_result.dart';
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
  /// [clearFirst] true이면 기존 대화를 지우고 결과만 표시 (기본값: true)
  void addFortuneResultMessage({
    required String text,
    required String fortuneType,
    String? sectionKey,
    bool isBlurred = false,
    List<String> blurredSections = const [],
    Fortune? fortune,
    DateTime? selectedDate,
    MatchInsight? matchInsight,
    PastLifeResult? pastLifeResult,
    YearlyEncounterResult? yearlyEncounterResult,
    bool clearFirst = true,
  }) {
    // 결과 표시 시 강한 햅틱 피드백
    HapticUtils.heavyImpact();

    // 블러 상태 로깅
    Logger.info(
      '🔒 [ChatMessagesNotifier] addFortuneResultMessage - '
      'type=$fortuneType, isBlurred=$isBlurred, '
      'sections=$blurredSections',
    );

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
      isBlurred: isBlurred,
      blurredSections: blurredSections,
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
    bool isBlurred = false,
    List<String> blurredSections = const [],
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
      isBlurred: isBlurred,
      blurredSections: blurredSections,
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
    bool isBlurred = false,
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
      isBlurred: isBlurred,
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
    bool isBlurred = false,
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
      isBlurred: isBlurred,
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
    Logger.info('🔓 [ChatMessagesNotifier] unblurAllMessages() 시작 - 메시지 수: ${state.messages.length}');
    final updated = state.messages.map((m) {
      if (m.isBlurred) {
        Logger.info('🔓 [ChatMessagesNotifier] 블러 해제: ${m.type} (id: ${m.id})');
      }
      return m.copyWith(isBlurred: false);
    }).toList();

    state = state.copyWith(messages: updated);
    Logger.info('🔓 [ChatMessagesNotifier] unblurAllMessages() 완료');
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
