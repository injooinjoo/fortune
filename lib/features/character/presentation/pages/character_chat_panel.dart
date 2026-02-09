import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_choice.dart';
import '../providers/character_chat_provider.dart';
import '../widgets/character_intro_card.dart';
import '../widgets/character_message_bubble.dart';
import '../widgets/character_choice_widget.dart';
import '../widgets/wave_typing_indicator.dart';

/// 1:1 캐릭터 롤플레이 채팅 패널
class CharacterChatPanel extends ConsumerStatefulWidget {
  final AiCharacter character;
  final VoidCallback? onBack;

  const CharacterChatPanel({
    super.key,
    required this.character,
    this.onBack,
  });

  @override
  ConsumerState<CharacterChatPanel> createState() => _CharacterChatPanelState();
}

class _CharacterChatPanelState extends ConsumerState<CharacterChatPanel>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  /// Notifier 참조 캐시 (dispose 후 ref 사용 불가 문제 해결)
  CharacterChatNotifier? _cachedNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 기존 대화 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cachedNotifier =
          ref.read(characterChatProvider(widget.character.id).notifier);
      _cachedNotifier?.initConversation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 화면 이탈 시 저장 (캐시된 notifier 사용 - ref 사용 불가)
    _cachedNotifier?.saveOnExit();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 백그라운드로 갈 때 저장
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveConversation();
    }
  }

  Future<void> _saveConversation() async {
    // mounted 상태에서는 ref 사용, 아니면 캐시된 notifier 사용
    if (mounted) {
      await ref
          .read(characterChatProvider(widget.character.id).notifier)
          .saveOnExit();
    } else {
      await _cachedNotifier?.saveOnExit();
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(characterChatProvider(widget.character.id).notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startConversation() {
    ref
        .read(characterChatProvider(widget.character.id).notifier)
        .startConversation(widget.character.firstMessage);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(characterChatProvider(widget.character.id));

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // 뒤로가기 시 저장
          await _saveConversation();
        }
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(context),
              const Divider(height: 1),
              // 채팅 영역
              Expanded(
                child: chatState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chatState.hasConversation
                        ? _buildChatList(chatState)
                        : CharacterIntroCard(
                            character: widget.character,
                            onStartConversation: _startConversation,
                          ),
              ),
              // 입력 영역 (대화 시작 후에만)
              if (chatState.hasConversation) _buildInputArea(chatState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // 백버튼
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onBack?.call();
            },
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // 프로필 영역 (탭 가능)
          Expanded(
            child: GestureDetector(
              onTap: () => _showCharacterProfile(context),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: widget.character.accentColor,
                    backgroundImage: widget.character.avatarAsset.isNotEmpty
                        ? AssetImage(widget.character.avatarAsset)
                        : null,
                    child: widget.character.avatarAsset.isEmpty
                        ? Text(
                            widget.character.initial,
                            style: context.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.character.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          widget.character.personality.length > 30
                              ? '${widget.character.personality.substring(0, 30)}...'
                              : widget.character.personality,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showCharacterProfile(context),
          ),
        ],
      ),
    );
  }

  void _showCharacterProfile(BuildContext context) {
    HapticFeedback.lightImpact();
    context.push('/character/${widget.character.id}', extra: widget.character);
  }

  Widget _buildChatList(dynamic chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length && chatState.isTyping) {
          return _buildTypingIndicator();
        }

        final message = chatState.messages[index] as CharacterChatMessage;

        // 선택지 메시지인 경우
        if (message.isChoice && message.choiceSet != null) {
          return CharacterChoiceWidget(
            choiceSet: message.choiceSet!,
            character: widget.character,
            onChoiceSelected: (choice) => _handleChoiceSelection(choice),
            onTimeout: () {
              // 타임아웃 시 기본 선택지 선택
              if (message.choiceSet!.defaultChoiceIndex != null) {
                final defaultChoice = message.choiceSet!
                    .choices[message.choiceSet!.defaultChoiceIndex!];
                _handleChoiceSelection(defaultChoice);
              }
            },
          );
        }

        return CharacterMessageBubble(
          message: message,
          character: widget.character,
        );
      },
    );
  }

  void _handleChoiceSelection(CharacterChoice choice) {
    ref
        .read(characterChatProvider(widget.character.id).notifier)
        .handleChoiceSelection(choice);
    _scrollToBottom();
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: widget.character.accentColor,
            child: Text(
              widget.character.initial,
              style: context.labelMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: WaveTypingIndicator(
              dotColor: Colors.grey[500],
              dotSize: 8,
              bounceHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(dynamic chatState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: context.bodyMedium.copyWith(
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: context.bodyMedium,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: chatState.isProcessing ? null : _sendMessage,
            child: Icon(
              Icons.send_rounded,
              size: 28,
              color: chatState.isProcessing
                  ? Colors.grey[300]
                  : widget.character.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

