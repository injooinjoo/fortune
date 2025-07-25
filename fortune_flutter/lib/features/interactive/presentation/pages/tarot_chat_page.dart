import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/tarot_deck_provider.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';

// Example questions for quick access
final tarotExampleQuestions = [
  '오늘의 운세를 알려주세요',
  '연애운이 궁금해요',
  '중요한 결정을 앞두고 있어요',
  '이번 달 금전운은 어떤가요?',
  '직장에서의 인간관계가 걱정돼요',
  '새로운 시작을 앞두고 있어요',
];

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

class _TarotChatPageState extends ConsumerState<TarotChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;
  bool _hasCheckedDeck = false;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _checkDeckSelection() {
    if (!_hasCheckedDeck) {
      _hasCheckedDeck = true;
      final selectedDeck = ref.read(selectedTarotDeckProvider);
      if (selectedDeck == null || selectedDeck.isEmpty) {
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

    // Add loading message
    messages.addMessage(ChatMessage(
      text: '타로 카드를 섞고 있습니다...',
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
          timestamp: DateTime.now(),
        ));
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
          },
        },
      );

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        final interpretation = data['interpretation'] ?? '';
        final advice = data['advice'] ?? '';
        final cards = (data['cards'] as List<dynamic>?)?.map((card) {
          return TarotCardInfo(
            name: card['name'] ?? '',
            meaning: card['meaning'] ?? '',
            imageUrl: '', // TODO: Add card images
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
        throw Exception(response['error'] ?? '타로 카드 해석에 실패했습니다');
      }
    } catch (e) {
      messages.updateLastMessage(ChatMessage(
        text: '죄송합니다. 오류가 발생했습니다: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      setState(() => _isProcessing = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = ref.watch(chatMessagesProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    final selectedDeck = ref.watch(currentTarotDeckProvider);

    return Scaffold(
      backgroundColor: AppColors.eventbriteBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Clean header
            AppHeader(
              title: '타로 리딩',
              showBackButton: true,
              backgroundColor: Colors.white,
              elevation: 0.5,
              actions: [
                IconButton(
                  icon: const Icon(Icons.style, size: 20),
                  onPressed: () {
                    context.pushNamed('interactive-tarot-deck-selection');
                  },
                  tooltip: '덱 변경',
                ),
              ],
            ),
            
            // Main content area
            Expanded(
              child: messages.isEmpty
                  ? _buildWelcomeView(fontScale)
                  : _buildChatView(messages, fontScale),
            ),
            
            // Bottom input area
            _buildInputArea(fontScale),
          ],
        ),
      ),
    );
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
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 40,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Welcome text
          Text(
            '타로 리딩에 오신 것을 환영합니다',
            style: TextStyle(
              fontSize: 24 * fontScale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '궁금한 것을 물어보시면 타로 카드로 답변해 드릴게요',
            style: TextStyle(
              fontSize: 16 * fontScale,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Example questions
          Text(
            '이런 질문을 해보세요',
            style: TextStyle(
              fontSize: 16 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
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
    return InkWell(
      onTap: () => _sendMessage(question),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.42,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.eventbriteButtonBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          question,
          style: TextStyle(
            fontSize: 14 * fontScale,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChatView(List<ChatMessage> messages, double fontScale) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildChatBubble(message, fontScale);
      },
    );
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
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.eventbriteButtonBorder,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.textPrimary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: !isUser ? Border.all(
                  color: AppColors.eventbriteButtonBorder,
                  width: 1,
                ) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                              AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: isUser ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14 * fontScale,
                        color: isUser ? Colors.white : AppColors.textPrimary,
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.eventbriteBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.eventbriteButtonBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.style,
            size: 32,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            card.name,
            style: TextStyle(
              fontSize: 12 * fontScale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (card.isReversed) ...[
            const SizedBox(height: 2),
            Text(
              '(역방향)',
              style: TextStyle(
                fontSize: 10 * fontScale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(double fontScale) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.eventbriteButtonBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: TextStyle(
                fontSize: 16 * fontScale,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '궁금한 것을 물어보세요...',
                hintStyle: TextStyle(
                  fontSize: 16 * fontScale,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.eventbriteBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _isProcessing ? null : _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _isProcessing ? AppColors.textSecondary : AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
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