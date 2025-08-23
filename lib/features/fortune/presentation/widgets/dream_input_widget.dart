import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../services/speech_recognition_service.dart';
import '../../../../core/theme/toss_theme.dart';
import '../providers/dream_chat_provider.dart';

class DreamInputWidget extends ConsumerStatefulWidget {
  final bool enabled;
  final VoidCallback? onSendPressed;
  
  const DreamInputWidget({
    Key? key,
    this.enabled = true,
    this.onSendPressed}) : super(key: key);

  @override
  ConsumerState<DreamInputWidget> createState() => _DreamInputWidgetState();
}

class _DreamInputWidgetState extends ConsumerState<DreamInputWidget> 
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _speechService = SpeechRecognitionService();
  late AnimationController _animationController;
  bool _isVoiceMode = false;
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2));
    _animationController.repeat();
    
    _textController.addListener(() {
      setState(() {
        _hasText = _textController.text.trim().isNotEmpty;
      });
    });
    
    _initializeSpeechService();
}
  
  Future<void> _initializeSpeechService() async {
    await _speechService.initialize();
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _speechService.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    HapticUtils.lightImpact();
    ref.read(dreamChatProvider.notifier).addUserMessage(text);
    _textController.clear();
    
    widget.onSendPressed?.call();
  }
  
  void _toggleVoiceMode() {
    HapticUtils.lightImpact();
    setState(() {
      _isVoiceMode = !_isVoiceMode;
    });
    
    if (_isVoiceMode) {
      _startListening();
    } else {
      _stopListening();
    }
  }
  
  Future<void> _startListening() async {
    ref.read(dreamChatProvider.notifier).toggleListening(true);
    
    await _speechService.startListening(
      onResult: (text) {
        if (text.isNotEmpty) {
          _textController.text = text;
        }
      },
    );
  }
  
  Future<void> _stopListening() async {
    await _speechService.stopListening();
    ref.read(dreamChatProvider.notifier).toggleListening(false);
    
    // Send the message if there's text
    if (_textController.text.trim().isNotEmpty) {
      _sendMessage();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(dreamChatProvider);
    
    return Container(
      padding: EdgeInsets.only(
        left: TossTheme.spacingM,
        right: TossTheme.spacingM,
        bottom: MediaQuery.of(context).padding.bottom + TossTheme.spacingM,
        top: TossTheme.spacingS,
      ),
      decoration: const BoxDecoration(
        color: TossTheme.backgroundWhite,
        border: Border(
          top: BorderSide(
            color: TossTheme.borderGray200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (chatState.isListening) _buildVoiceListeningIndicator(theme),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TossTheme.spacingS, 
                vertical: TossTheme.spacingXS,
              ),
              decoration: BoxDecoration(
                color: TossTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(TossTheme.radiusL),
                border: Border.all(
                  color: _focusNode.hasFocus 
                      ? TossTheme.primaryBlue 
                      : TossTheme.borderGray300,
                  width: _focusNode.hasFocus ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Voice button
                  _buildVoiceButton(theme),
                  const SizedBox(width: TossTheme.spacingS),
                  
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: widget.enabled && !_isVoiceMode,
                      style: TossTheme.body3.copyWith(color: TossTheme.textBlack),
                      decoration: InputDecoration(
                        hintText: _isVoiceMode 
                            ? '음성으로 말씀해주세요...' 
                            : '꿈 이야기를 입력하세요...',
                        hintStyle: TossTheme.body3.copyWith(
                          color: TossTheme.textGray400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: TossTheme.spacingS,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  
                  // Send button
                  _buildSendButton(theme),
                ],
              ),
            ),
            const SizedBox(height: TossTheme.spacingS),
            
            // Quick response buttons
            if (widget.enabled && !_isVoiceMode) _buildQuickResponses(theme),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildVoiceButton(ThemeData theme) {
    return GestureDetector(
      onTap: widget.enabled ? _toggleVoiceMode : null,
      child: AnimatedContainer(
        duration: TossTheme.animationNormal,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isVoiceMode
              ? TossTheme.error
              : TossTheme.textGray400,
        ),
        child: Icon(
          _isVoiceMode ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
  
  Widget _buildSendButton(ThemeData theme) {
    final canSend = _hasText && widget.enabled && !_isVoiceMode;
    
    return GestureDetector(
      onTap: canSend ? _sendMessage : null,
      child: AnimatedContainer(
        duration: TossTheme.animationNormal,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: canSend
              ? TossTheme.primaryBlue
              : TossTheme.disabledGray,
        ),
        child: Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
  
  Widget _buildVoiceListeningIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: TossTheme.spacingS),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TossTheme.spacingM, 
          vertical: TossTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: TossTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(TossTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              color: TossTheme.error,
              size: 18,
            ),
            const SizedBox(width: TossTheme.spacingS),
            Text(
              '듣고 있습니다...',
              style: TossTheme.body3.copyWith(color: TossTheme.textBlack),
            ),
            const SizedBox(width: TossTheme.spacingS),
            ValueListenableBuilder<String>(
              valueListenable: _speechService.recognizedTextNotifier,
              builder: (context, text, _) {
                if (text.isNotEmpty) {
                  return Flexible(
                    child: Text(
                      text,
                      style: TossTheme.body3.copyWith(color: TossTheme.textBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return Row(
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TossTheme.textGray400,
                        shape: BoxShape.circle,
                      ),
                    )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        duration: 600.ms,
                        delay: Duration(milliseconds: index * 200),
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.5, 1.5),
                      )
                      .then()
                      .scale(
                        duration: 600.ms,
                        begin: const Offset(1.5, 1.5),
                        end: const Offset(0.5, 0.5),
                      );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn()
        .slideY(begin: -0.2, end: 0)
        .scale(begin: const Offset(0.95, 0.95));
  }
  
  Widget _buildQuickResponses(ThemeData theme) {
    // Show quick responses based on conversation state
    final chatState = ref.watch(dreamChatProvider);
    final messageCount = chatState.messages.where((m) => m.type == MessageType.user).length;
    
    List<String> quickResponses = [];
    
    if (messageCount == 0) {
      // Initial responses
      quickResponses = [
        '무서운 꿈을 꿨어요',
        '좋은 꿈이었어요',
        '이상한 꿈을 꿨어요'];
} else if (messageCount == 1) {
      // Follow-up responses
      quickResponses = [
        '불안했어요',
        '기뻤어요',
        '혼란스러웠어요'];
}
    
    if (quickResponses.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: quickResponses.length,
        separatorBuilder: (_, __) => const SizedBox(width: TossTheme.spacingS),
        itemBuilder: (context, index) {
          final response = quickResponses[index];
          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              _textController.text = response;
              _sendMessage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TossTheme.spacingM,
                vertical: TossTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: TossTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TossTheme.radiusL),
                border: Border.all(
                  color: TossTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                response,
                style: TossTheme.body3.copyWith(
                  color: TossTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }))
      .animate()
        .fadeIn(delay: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }
}