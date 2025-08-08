import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../services/speech_recognition_service.dart';
import '../providers/dream_chat_provider.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

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
      duration: const Duration(seconds: 2),;
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
      }
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
        left: AppSpacing.spacing4,
        right: AppSpacing.spacing4,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3)]),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (chatState.isListening) _buildVoiceListeningIndicator(theme),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
              borderRadius: BorderRadius.circular(AppSpacing.spacing7))),
              blur: 20,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05)]),
              child: Row(
                children: [
                  // Voice button
                  _buildVoiceButton(theme),
                  const SizedBox(width: AppSpacing.spacing3),
                  
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: widget.enabled && !_isVoiceMode,
                      style: Theme.of(context).textTheme.bodyMedium),
                      decoration: InputDecoration(
                        hintText: _isVoiceMode 
                            ? '음성으로 말씀해주세요...' 
                            : '꿈 이야기를 입력하세요...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing0,
                          vertical: AppSpacing.spacing3),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage()),
                  
                  // Send button
                  _buildSendButton(theme)]),
            const SizedBox(height: AppSpacing.spacing2),
            
            // Quick response buttons
            if (widget.enabled && !_isVoiceMode) _buildQuickResponses(theme)])).animate().fadeIn().slideY(begin: 0.2, end: 0)
}
  
  Widget _buildVoiceButton(ThemeData theme) {
    return GestureDetector(
      onTap: widget.enabled ? _toggleVoiceMode : null,
      child: AnimatedContainer(
        duration: AppAnimations.durationShort,
        width: 40,
        height: AppDimensions.buttonHeightSmall,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isVoiceMode
              ? LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.6),
                    Colors.red.withOpacity(0.8)],
                ,
              : LinearGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.3),
                    Colors.deepPurple.withOpacity(0.3)]),
        child: Icon(
          _isVoiceMode ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 24));
}
  
  Widget _buildSendButton(ThemeData theme) {
    final canSend = _hasText && widget.enabled && !_isVoiceMode;
    
    return GestureDetector(
      onTap: canSend ? _sendMessage : null,
      child: AnimatedContainer(
        duration: AppAnimations.durationShort,
        width: 40,
        height: AppDimensions.buttonHeightSmall,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: canSend
              ? LinearGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.6),
                    Colors.deepPurple.withOpacity(0.8)],
                ,
              : LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.9).withOpacity(0.3),
                    Colors.grey.withOpacity(0.87).withOpacity(0.3)]),
        child: Icon(
          Icons.send_rounded,
          color: canSend ? Colors.white : Colors.white30,
          size: 20),;
}
  
  Widget _buildVoiceListeningIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacing3),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5, vertical: AppSpacing.spacing3),
        borderRadius: AppDimensions.borderRadius(AppDimensions.radiusXLarge),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              color: Colors.red.withOpacity(0.6),
              size: 20),
            const SizedBox(width: AppSpacing.spacing2),
            Text(
              '듣고 있습니다...',),
              style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: AppSpacing.spacing2),
            ValueListenableBuilder<String>(
              valueListenable: _speechService.recognizedTextNotifier,
              builder: (context, text, _) {
                if (text.isNotEmpty) {
                  return Flexible(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis);
}
                return Row(
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing0 * 0.5),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        shape: BoxShape.circle),.animate(
                      onPlay: (controller) => controller.repeat(),.scale(
                      duration: 600.ms,
                      delay: Duration(milliseconds: index * 200),
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.5, 1.5),.then().scale(
                      duration: 600.ms,
                      begin: const Offset(1.5, 1.5),
                      end: const Offset(0.5, 0.5),;
});
})])).animate()
                  .fadeIn(,
        .slideY(begin: -0.2, end: 0,
        .scale(begin: const Offset(0.95, 0.95);
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
    
    if (quickResponses.isEmpty) return const SizedBox.shrink()
    
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing1),
        itemCount: quickResponses.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.spacing2),
        itemBuilder: (context, index) {
          final response = quickResponses[index];
          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              _textController.text = response;
              _sendMessage();
},
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing2),
              borderRadius: BorderRadius.circular(AppSpacing.spacing4 * 1.125))),
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.3),
                  Colors.deepPurple.withOpacity(0.3)]),
              child: Text(
                response,
                style: Theme.of(context).textTheme.bodyMedium)
          );
}),.animate()
                  .fadeIn(delay: 300.ms,
        .slideY(begin: 0.2, end: 0);
}
}