import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Chat message types
enum MessageType {
  fortuneTeller, // 해몽가 메시지
  user,         // 사용자 메시지
  loading,      // 로딩 메시지
  result,       // 해몽 결과
}

// Chat message model
class DreamChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isAnimating;
  final Map<String, dynamic>? metadata; // 추가 데이터 (상징, 감정 등)
  
  const DreamChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isAnimating = false,
    this.metadata,
  });
  
  DreamChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isAnimating,
    Map<String, dynamic>? metadata,
  }) {
    return DreamChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isAnimating: isAnimating ?? this.isAnimating,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Chat state model
class DreamChatState {
  final List<DreamChatMessage> messages;
  final bool isTyping; // 해몽가가 타이핑 중
  final bool isListening; // 음성 인식 중
  final String dreamContent; // 수집된 꿈 내용
  final Map<String, String> collectedInfo; // 수집된 정보
  final bool isAnalyzing; // 해몽 분석 중
  final String? error;
  
  const DreamChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isListening = false,
    this.dreamContent = '',
    this.collectedInfo = const {},
    this.isAnalyzing = false,
    this.error,
  });
  
  DreamChatState copyWith({
    List<DreamChatMessage>? messages,
    bool? isTyping,
    bool? isListening,
    String? dreamContent,
    Map<String, String>? collectedInfo,
    bool? isAnalyzing,
    String? error,
  }) {
    return DreamChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isListening: isListening ?? this.isListening,
      dreamContent: dreamContent ?? this.dreamContent,
      collectedInfo: collectedInfo ?? this.collectedInfo,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      error: error ?? this.error,
    );
  }
}

// Fortune teller responses
class FortuneTellerResponses {
  static const List<String> greetings = [
    "안녕하세요, 저는 당신의 꿈을 해석해드릴 해몽가입니다. 🌙\n어젯밤 꾸신 꿈이 궁금하신가요?\n편안하게 이야기해주세요.",
    "반갑습니다. 꿈의 세계로 안내해드릴 해몽가입니다. ✨\n어떤 꿈을 꾸셨는지 들려주시겠어요?",
    "환영합니다. 당신의 무의식이 전하는 메시지를 함께 찾아보겠습니다. 🔮\n꿈 이야기를 들려주세요.",
  ];
  
  static const List<String> empathyResponses = [
    "그런 꿈은 정말 {emotion}겠어요.",
    "{emotion} 꿈이었군요. 많은 분들이 비슷한 경험을 하시곤 합니다.",
    "아, 그런 상황이었군요. {emotion} 마음이 전해집니다.",
  ];
  
  static const List<String> followUpQuestions = [
    "그때 기분이 어떠셨나요?",
    "혹시 최근에 비슷한 상황이나 감정을 경험하신 적이 있나요?",
    "꿈에서 가장 인상 깊었던 부분은 무엇인가요?",
    "꿈을 꾸고 일어났을 때 어떤 느낌이 드셨나요?",
  ];
  
  static const List<String> analyzingMessages = [
    "당신의 무의식이 전하는 메시지를 듣고 있습니다... 🌟",
    "꿈의 상징들을 하나씩 풀어보고 있어요... ✨",
    "깊은 의미를 찾아가고 있습니다... 🔮",
    "꿈속 이야기의 비밀을 해독하고 있어요... 🌙",
  ];
  
  static const List<String> closingMessages = [
    "오늘 하루도 좋은 꿈 꾸세요. 🌙",
    "당신의 꿈이 행복한 메시지를 전하길 바라요. ✨",
    "무의식이 전하는 지혜를 마음에 새기시길 바랍니다. 🌟",
  ];
}

// Chat provider
class DreamChatNotifier extends StateNotifier<DreamChatState> {
  DreamChatNotifier() : super(const DreamChatState());
  
  // Initialize chat with greeting
  void startChat() {
    final greeting = FortuneTellerResponses.greetings[
      DateTime.now().millisecond % FortuneTellerResponses.greetings.length
    ];
    
    _addFortuneTellerMessage(greeting);
  }
  
  // Add user message
  void addUserMessage(String content) {
    final message = DreamChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, message],
      dreamContent: state.dreamContent.isEmpty 
          ? content 
          : '${state.dreamContent} $content',
    );
    
    // Process the message and generate response
    _processUserMessage(content);
  }
  
  // Add fortune teller message with typing animation
  Future<void> _addFortuneTellerMessage(String content, {bool animate = true}) async {
    if (animate) {
      state = state.copyWith(isTyping: true);
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    
    final message = DreamChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.fortuneTeller,
      timestamp: DateTime.now(),
      isAnimating: animate,
    );
    
    state = state.copyWith(
      messages: [...state.messages, message],
      isTyping: false,
    );
  }
  
  // Process user message and generate appropriate response
  Future<void> _processUserMessage(String content) async {
    // Determine the stage of conversation
    final messageCount = state.messages.where((m) => m.type == MessageType.user).length;
    
    if (messageCount == 1) {
      // First message - show empathy and ask follow-up
      await _showEmpathyAndAskFollowUp(content);
    } else if (messageCount == 2) {
      // Second message - start analysis
      await _startDreamAnalysis();
    }
  }
  
  // Show empathy and ask follow-up question
  Future<void> _showEmpathyAndAskFollowUp(String dreamContent) async {
    // Determine emotion from content
    String emotion = "신기하셨";
    if (dreamContent.contains("무서") || dreamContent.contains("떨어") || dreamContent.contains("쫓")) {
      emotion = "무서우셨";
    } else if (dreamContent.contains("슬") || dreamContent.contains("울")) {
      emotion = "슬프셨";
    } else if (dreamContent.contains("행복") || dreamContent.contains("기쁨") || dreamContent.contains("날")) {
      emotion = "기쁘셨";
    }
    
    // Show empathy
    final empathyTemplate = FortuneTellerResponses.empathyResponses[
      DateTime.now().millisecond % FortuneTellerResponses.empathyResponses.length
    ];
    final empathyMessage = empathyTemplate.replaceAll('{emotion}', emotion);
    await _addFortuneTellerMessage(empathyMessage);
    
    // Ask follow-up question
    await Future.delayed(const Duration(milliseconds: 800));
    final followUp = FortuneTellerResponses.followUpQuestions[
      DateTime.now().millisecond % FortuneTellerResponses.followUpQuestions.length
    ];
    await _addFortuneTellerMessage(followUp);
  }
  
  // Start dream analysis
  Future<void> _startDreamAnalysis() async {
    // Acknowledge the response
    await _addFortuneTellerMessage(
      "네, 이해했습니다. 이제 이 꿈이 무엇을 의미하는지 함께 살펴볼까요?"
    );
    
    // Show analyzing message
    state = state.copyWith(isAnalyzing: true);
    
    final analyzingMsg = FortuneTellerResponses.analyzingMessages[
      DateTime.now().millisecond % FortuneTellerResponses.analyzingMessages.length
    ];
    
    final loadingMessage = DreamChatMessage(
      id: 'loading',
      content: analyzingMsg,
      type: MessageType.loading,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, loadingMessage],
    );
    
    // Simulate analysis time
    await Future.delayed(const Duration(seconds: 3));
    
    // Remove loading message
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != 'loading').toList(),
      isAnalyzing: false,
    );
    
    // Add result message
    await _addDreamInterpretation();
  }
  
  // Add dream interpretation result
  Future<void> _addDreamInterpretation() async {
    // This would be replaced with actual AI interpretation
    const interpretation = """
이 꿈은 전체적으로 **변화에 대한 두려움**과 **새로운 시작**을 나타내고 있어요.

🌟 **주요 상징 해석**
떨어지는 것은 통제력을 잃는 것에 대한 불안을 의미하지만, 다치지 않았다는 것은 당신 내면의 강인함과 회복력을 보여줍니다.

💫 **현실과의 연결**
최근 새로운 도전이나 중요한 결정을 앞두고 계신 것 같아요. 변화는 누구에게나 두려운 일이지만, 당신은 이미 그것을 극복할 힘을 가지고 있습니다.

🌙 **조언**
이럴 때는 자신을 믿고 한 걸음씩 나아가는 것이 중요해요. 완벽하지 않아도 괜찮습니다. 당신의 무의식은 이미 준비가 되어 있다고 말하고 있어요.

✨ **오늘의 리추얼**
잠들기 전, 자신에게 "나는 충분히 강하고 준비되어 있다"고 말해보세요. 
긍정적인 확언은 무의식에 좋은 영향을 줄 거예요.
""";
    
    final resultMessage = DreamChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: interpretation,
      type: MessageType.result,
      timestamp: DateTime.now(),
      isAnimating: true,
    );
    
    state = state.copyWith(
      messages: [...state.messages, resultMessage],
    );
    
    // Add closing message
    await Future.delayed(const Duration(seconds: 2));
    final closing = FortuneTellerResponses.closingMessages[
      DateTime.now().millisecond % FortuneTellerResponses.closingMessages.length
    ];
    await _addFortuneTellerMessage(closing);
  }
  
  // Toggle voice listening
  void toggleListening(bool isListening) {
    state = state.copyWith(isListening: isListening);
  }
  
  // Reset chat
  void resetChat() {
    state = const DreamChatState();
    startChat();
  }
  
  // Set error
  void setError(String? error) {
    state = state.copyWith(error: error);
  }
}

// Provider
final dreamChatProvider = StateNotifierProvider<DreamChatNotifier, DreamChatState>((ref) {
  return DreamChatNotifier();
});