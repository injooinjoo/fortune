import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../../shared/components/app_header.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/providers/user_settings_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/tarot_deck_provider.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';

// Example questions for quick access
final tarotExampleQuestions = [
  '오늘의 운세를 알려주세요',
  '연애운이 궁금해요',
  '중요한 결정을 앞두고 있어요',
  '이번 달 금전운은 어떤가요?',
  '직장에서의 인간관계가 걱정돼요',
  '새로운 시작을 앞두고 있어요'];

// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<TarotCardInfo>? cards;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.cards,
    this.isLoading = false,
  });
}

class TarotCardInfo {
  final String name;
  final String meaning;
  final String imageUrl;
  final bool isReversed;

  TarotCardInfo({
    required this.name,
    required this.meaning,
    required this.imageUrl,
    required this.isReversed,
  });
}

// Chat messages provider
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  (ref) => ChatMessagesNotifier(),
);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void updateLastMessage(ChatMessage message) {
    if (state.isNotEmpty) {
      state = [...state.sublist(0, state.length - 1), message];
    }
  }

  void clear() {
    state = [];
  }
}

class TarotChatPage extends ConsumerStatefulWidget {
  const TarotChatPage({super.key});

  @override
  ConsumerState<TarotChatPage> createState() => _TarotChatPageState();
}

class _TarotChatPageState extends ConsumerState<TarotChatPage> 
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;
  bool _hasCheckedDeck = false;
  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _cardAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    // Clear messages when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatMessagesProvider.notifier).clear();
      _checkDeckSelection();
      // Ensure navigation is hidden when this page loads
      ref.read(navigationVisibilityProvider.notifier).hide();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _checkDeckSelection() {
    if (!_hasCheckedDeck) {
      _hasCheckedDeck = true;
      final selectedDeck = ref.read(selectedTarotDeckProvider);
      if (selectedDeck.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pushReplacementNamed('fortune-tarot');
          }
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isProcessing) return;

    final messages = ref.read(chatMessagesProvider.notifier);
    final tokenService = ref.read(tokenServiceProvider.notifier);
    final apiService = ref.read(fortuneApiServiceProvider);

    // Add user message
    messages.addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _inputController.clear();
    setState(() => _isProcessing = true);
    _scrollToBottom();

    // Add loading messages with animation
    messages.addMessage(ChatMessage(
      text: '카드를 섞고 있습니다... 🎴',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    ));
    _scrollToBottom();
    
    // Start card drawing animation
    await Future.delayed(const Duration(seconds: 1));
    
    messages.updateLastMessage(ChatMessage(
      text: '당신을 위한 카드를 뽑고 있습니다... ✨',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    ));
    
    await Future.delayed(const Duration(seconds: 1));
    
    messages.updateLastMessage(ChatMessage(
      text: '카드의 메시지를 해석하고 있습니다... 🔮',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    ));
    _scrollToBottom();

    try {
      // Check tokens (3 tokens for standard reading)
      final hasEnoughTokens = await tokenService.checkAndConsumeTokens(3, 'tarot');
      
      if (!hasEnoughTokens) {
        messages.updateLastMessage(ChatMessage(
          text: '토큰이 부족합니다. 토큰을 충전해주세요.',
          isUser: false,
          timestamp: DateTime.now()));
        setState(() => _isProcessing = false);
        return;
      }

      // Call API
      final response = await apiService.post(
        ApiEndpoints.generateFortune,
        data: {
          'type': 'tarot',
          'userInfo': {
            'question': text,
            'spreadType': 'three', // Default to 3-card spread
          }});

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        final interpretation = FortuneTextCleaner.cleanNullable(data['interpretation'] as String?);
        final advice = FortuneTextCleaner.cleanNullable(data['advice'] as String?);
        final cards = (data['cards'] as List<dynamic>?)?.map((card) {
          return TarotCardInfo(
            name: card['name'] ?? '',
            meaning: card['meaning'] ?? '',
            imageUrl: card['imageUrl'] ?? '',
            isReversed: card['isReversed'] ?? false,
          );
        }).toList();

        // Update with actual response
        messages.updateLastMessage(ChatMessage(
          text: '$interpretation\n\n💡 조언: $advice',
          isUser: false,
          timestamp: DateTime.now(),
          cards: cards,
        ));
      } else {
        // API 실패 시 로컬 타로 카드 사용
        _generateLocalTarotResult(text, messages);
      }
    } catch (e) {
      // 에러 발생 시에도 로컬 타로 카드 사용
      _generateLocalTarotResult(text, messages);
    } finally {
      setState(() => _isProcessing = false);
      _scrollToBottom();
    }
  }

  void _generateLocalTarotResult(String question, ChatMessagesNotifier messages) {
    final random = Random();
    final List<TarotCardInfo> selectedCards = [];
    final List<int> usedIndices = [];
    
    // 3장의 카드 선택 (과거, 현재, 미래)
    for (int i = 0; i < 3; i++) {
      int cardNumber;
      do {
        cardNumber = TarotMetadata.majorArcana.keys.toList()[random.nextInt(TarotMetadata.majorArcana.length)];
      } while (usedIndices.contains(cardNumber));
      
      usedIndices.add(cardNumber);
      final card = TarotMetadata.majorArcana[cardNumber]!;
      final isReversed = random.nextInt(100) < 30; // 30% 확률로 역방향
      
      selectedCards.add(TarotCardInfo(
        name: card.name,
        meaning: isReversed ? card.reversedMeaning : card.uprightMeaning,
        imageUrl: 'assets/images/tarot/major_${cardNumber.toString().padLeft(2, '0')}.jpg',
        isReversed: isReversed,
      ));
    }
    
    // 질문에 따른 해석 생성
    String interpretation = _generateInterpretation(question, selectedCards);
    String advice = _generateAdvice(question, selectedCards);
    
    messages.updateLastMessage(ChatMessage(
      text: '$interpretation\n\n💡 조언: $advice',
      isUser: false,
      timestamp: DateTime.now(),
      cards: selectedCards,
    ));
  }
  
  String _generateInterpretation(String question, List<TarotCardInfo> cards) {
    String baseInterpretation = '';
    
    // 3장 카드 스프레드 - 과거, 현재, 미래로 해석
    baseInterpretation += '📅 **과거의 영향**\n';
    baseInterpretation += '카드: ${cards[0].name}${cards[0].isReversed ? " (역방향)" : ""}\n';
    baseInterpretation += '${cards[0].meaning}\n\n';
    
    baseInterpretation += '⏰ **현재의 상황**\n';
    baseInterpretation += '카드: ${cards[1].name}${cards[1].isReversed ? " (역방향)" : ""}\n';
    baseInterpretation += '${cards[1].meaning}\n\n';
    
    baseInterpretation += '🌟 **미래의 가능성**\n';
    baseInterpretation += '카드: ${cards[2].name}${cards[2].isReversed ? " (역방향)" : ""}\n';
    baseInterpretation += cards[2].meaning;
    
    // 질문 키워드에 따른 추가 해석
    if (question.contains('연애') || question.contains('사랑')) {
      baseInterpretation = '❤️ **연애운 3장 타로 리딩**\n\n$baseInterpretation';
    } else if (question.contains('직장') || question.contains('일')) {
      baseInterpretation = '💼 **직장운 3장 타로 리딩**\n\n$baseInterpretation';
    } else if (question.contains('돈') || question.contains('재물')) {
      baseInterpretation = '💰 **금전운 3장 타로 리딩**\n\n$baseInterpretation';
    } else {
      baseInterpretation = '🎴 **종합 3장 타로 리딩**\n\n$baseInterpretation';
    }
    
    return baseInterpretation;
  }
  
  String _generateAdvice(String question, List<TarotCardInfo> cards) {
    // 카드 조합에 따른 조언 생성
    final List<String> adviceList = [];
    
    for (var card in cards) {
      final metadata = TarotMetadata.majorArcana.values.firstWhere(
        (m) => m.name == card.name,
        orElse: () => TarotMetadata.majorArcana[0]!,
      );
      adviceList.add(metadata.advice);
    }
    
    // 랜덤하게 하나의 조언 선택 또는 조합
    return adviceList[Random().nextInt(adviceList.length)];
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final fontScale = ref.watch(userSettingsProvider).fontScale;

    return Scaffold(
      backgroundColor: TossDesignSystem.gray50,
      body: SafeArea(
        child: Column(
          children: [
            // Clean header
            AppHeader(
              title: '타로 리딩',
              showBackButton: true,
              backgroundColor: TossDesignSystem.white,
              elevation: 0.5,
              actions: [
                IconButton(
                  icon: const Icon(Icons.style, size: 20),
                  onPressed: () {
                    context.pushNamed('interactive-tarot-deck-selection');
                  },
                  tooltip: '덱 변경')]),
            
            // Main content area
            Expanded(
              child: messages.isEmpty
                  ? _buildWelcomeView(fontScale)
                  : _buildChatView(messages, fontScale)),
            
            // Bottom input area
            _buildInputArea(fontScale)])));
  }

  Widget _buildWelcomeView(double fontScale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Simple icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TossDesignSystem.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2))]),
            child: const Icon(
              Icons.auto_awesome,
              size: 40,
              color: TossDesignSystem.gray900)),
          
          const SizedBox(height: 24),
          
          // Welcome text
          Text(
            '타로 리딩에 오신 것을 환영합니다',
            style: context.heading2.copyWith(
              fontWeight: FontWeight.bold,
              color: TossDesignSystem.gray900)),

          const SizedBox(height: 12),

          Text(
            '궁금한 것을 물어보시면 타로 카드로 답변해 드릴게요',
            style: context.buttonMedium.copyWith(
              color: TossDesignSystem.gray600),
            textAlign: TextAlign.center),

          const SizedBox(height: 40),

          // Example questions
          Text(
            '이런 질문을 해보세요',
            style: context.buttonMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.gray900)),
          
          const SizedBox(height: 16),
          
          // Question grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: tarotExampleQuestions.map((question) {
              return _buildExampleCard(question, fontScale);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String question, double fontScale) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.42),
      child: Material(
        color: TossDesignSystem.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            debugPrint('[TarotChat] Example question tapped: $question');
            HapticFeedback.lightImpact();
            _sendMessage(question);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TossDesignSystem.gray200,
                width: 1),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))]),
            child: Text(
              question,
              style: context.bodySmall.copyWith(
                color: TossDesignSystem.gray900,
                fontWeight: FontWeight.w500,
                height: 1.4),
              textAlign: TextAlign.center)))));
  }

  Widget _buildChatView(List<ChatMessage> messages, double fontScale) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildChatBubble(message, fontScale);
      });
  }

  Widget _buildChatBubble(ChatMessage message, double fontScale) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TossDesignSystem.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: TossDesignSystem.gray600,
                  width: 1)),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: TossDesignSystem.gray900,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? TossDesignSystem.gray900 : TossDesignSystem.white,
                borderRadius: BorderRadius.circular(16),
                border: !isUser ? Border.all(
                  color: TossDesignSystem.gray600,
                  width: 1) : null,
                boxShadow: [
                  BoxShadow(
                    color: TossDesignSystem.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isLoading)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              TossDesignSystem.gray600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          message.text,
                          style: context.bodySmall.copyWith(
                            color: isUser ? TossDesignSystem.white : TossDesignSystem.gray900,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      message.text,
                      style: context.bodySmall.copyWith(
                        color: isUser ? TossDesignSystem.white : TossDesignSystem.gray900,
                        height: 1.4,
                      ),
                    ),
                  
                  // Display cards if available
                  if (message.cards != null && message.cards!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: message.cards!.map((card) {
                          return _buildMiniCard(card, fontScale);
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMiniCard(TarotCardInfo card, double fontScale) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TossDesignSystem.gray300,
          width: 1),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            // 카드 이미지
            SizedBox(
              height: 120,
              width: 100,
              child: Image.asset(
                card.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: TossDesignSystem.gray100,
                    child: Icon(
                      Icons.style,
                      size: 40,
                      color: TossDesignSystem.gray600,
                    ),
                  );
                },
              ),
            ),
            // 카드 이름
            Container(
              color: TossDesignSystem.white,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    card.name,
                    style: context.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: TossDesignSystem.gray900,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (card.isReversed) ...[
                    const SizedBox(height: 2),
                    Text(
                      '(역방향)',
                      style: context.labelTiny.copyWith(
                        color: TossDesignSystem.gray600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(double fontScale) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: TossDesignSystem.white,
        border: Border(
          top: BorderSide(
            color: TossDesignSystem.gray600,
            width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: context.buttonMedium.copyWith(
                color: TossDesignSystem.gray900),
              decoration: InputDecoration(
                hintText: '궁금한 것을 물어보세요...',
                hintStyle: context.buttonMedium.copyWith(
                  color: TossDesignSystem.gray600),
                filled: true,
                fillColor: TossDesignSystem.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12)),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _isProcessing ? null : _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _isProcessing ? TossDesignSystem.gray600 : TossDesignSystem.gray900,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: TossDesignSystem.white,
                size: 20,
              ),
              onPressed: _isProcessing ? null : () => _sendMessage(_inputController.text),
            ),
          ),
        ],
      ),
    );
  }
}