import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../shared/components/soul_consume_animation.dart';
import '../../../../core/constants/soul_rates.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../services/ad_service.dart';
import '../providers/dream_chat_provider.dart';
import '../widgets/dream_chat_bubble.dart';
import '../widgets/dream_input_widget.dart';

class DreamFortuneChatPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;
  
  const DreamFortuneChatPage({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<DreamFortuneChatPage> createState() => _DreamFortuneChatPageState();
}

class _DreamFortuneChatPageState extends ConsumerState<DreamFortuneChatPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasConsumedSoul = false;
  bool _hasShownFirstMessageAd = false;
  
  @override
  void initState() {
    super.initState();
    
    // Start the chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Hide navigation bar
      ref.read(navigationVisibilityProvider.notifier).hide();
      
      ref.read(dreamChatProvider.notifier).startChat();
      
      // Check if we should auto-generate (coming from ad screen),
      final autoGenerate = widget.initialParams?['autoGenerate'] as bool? ?? false;
      if (autoGenerate && !_hasConsumedSoul) {
        _consumeSoulIfNeeded();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _consumeSoulIfNeeded() async {
    if (_hasConsumedSoul) return;
    
    // Check soul consumption
    final tokenState = ref.read(tokenProvider);
    final tokenNotifier = ref.read(tokenProvider.notifier);
    final isPremium = tokenState.hasUnlimitedAccess;
    
    if (!isPremium && !tokenNotifier.canAccessFortune('dream')) {
      // Not enough souls - this should have been checked before navigation
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    // Consume souls if not premium
    if (!isPremium) {
      final soulAmount = SoulRates.getSoulAmount('dream');
      HapticUtils.heavyImpact();
      
      // Show soul consumption animation
      SoulConsumeAnimation.show(
        context: context,
        soulAmount: soulAmount,
      );
      
      // Actually consume the souls
      await tokenNotifier.consumeTokens(
        fortuneType: 'dream',
        amount: soulAmount,
      );
      _hasConsumedSoul = true;
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
  
  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(dreamChatProvider);
    
    // Auto scroll when new messages arrive
    ref.listen<DreamChatState>(dreamChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });
    
    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            AppHeader(
              title: '꿈 해몽',
              showBackButton: true,
              centerTitle: true,
              onBackPressed: () {
                // Show navigation bar when going back
                ref.read(navigationVisibilityProvider.notifier).show();
                _showExitConfirmDialog();
              },
            ),
            
            // Chat messages
            Expanded(
              child: Container(
                color: TossTheme.backgroundSecondary,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: TossTheme.spacingM, vertical: TossTheme.spacingS),
                  itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < chatState.messages.length) {
                      final message = chatState.messages[index];
                      final showAvatar = index == 0 || 
                          (index > 0 && 
                           chatState.messages[index - 1].type != message.type);
                      
                      return DreamChatBubble(
                        message: message,
                        showAvatar: showAvatar,
                      );
                    } else {
                      // Typing indicator
                      return const TypingIndicator();
                    }
                  },
                ),
              ),
            ),
            
            // Input area
            Container(
              color: TossTheme.backgroundWhite,
              child: DreamInputWidget(
                enabled: !chatState.isAnalyzing,
                onSendPressed: () async {
                  // Show ad on first user message
                  if (!_hasShownFirstMessageAd) {
                    _hasShownFirstMessageAd = true;
                    await AdService.instance.showInterstitialAdWithCallback(
                      onAdCompleted: () {
                        _scrollToBottom();
                        // Consume soul on first message if not done yet
                        if (!_hasConsumedSoul) {
                          _consumeSoulIfNeeded();
                        }
                      },
                      onAdFailed: () {
                        _scrollToBottom();
                        // Consume soul on first message if not done yet
                        if (!_hasConsumedSoul) {
                          _consumeSoulIfNeeded();
                        }
                      },
                    );
                  } else {
                    _scrollToBottom();
                    // Consume soul on first message if not done yet
                    if (!_hasConsumedSoul) {
                      _consumeSoulIfNeeded();
                    }
                  }
                },
              ),
            ),
            
            // Loading overlay
            if (chatState.isAnalyzing)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: TossTheme.primaryBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  
  void _showExitConfirmDialog() {
    final chatState = ref.read(dreamChatProvider);
    final hasMessages = chatState.messages.where((m) => m.type == MessageType.user).isNotEmpty;
    
    if (!hasMessages) {
      Navigator.of(context).pop();
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TossTheme.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TossTheme.radiusL),
        ),
        title: Text(
          '꿈 해몽을 중단하시겠습니까?',
          style: TossTheme.heading3.copyWith(color: TossTheme.textBlack),
        ),
        content: Text(
          '대화 내용이 저장되지 않습니다.',
          style: TossTheme.body3.copyWith(color: TossTheme.textGray600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '계속하기',
              style: TossTheme.button.copyWith(color: TossTheme.textGray600),
            ),
          ),
          TextButton(
            onPressed: () {
              // First pop the dialog
              Navigator.of(context).pop();
              // Then pop the page and reset state
              Navigator.of(context).pop();
              // Show navigation bar after navigation is complete
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(navigationVisibilityProvider.notifier).show();
              });
              // Reset the chat state
              ref.read(dreamChatProvider.notifier).resetChat();
            },
            child: Text(
              '나가기',
              style: TossTheme.button.copyWith(color: TossTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}