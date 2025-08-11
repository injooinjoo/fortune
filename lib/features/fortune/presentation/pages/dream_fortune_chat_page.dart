import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../../shared/components/app_header.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../shared/components/soul_consume_animation.dart';
import '../../../../core/constants/soul_rates.dart';
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

class _DreamFortuneChatPageState extends ConsumerState<DreamFortuneChatPage> 
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _backgroundAnimationController;
  bool _hasConsumedSoul = false;
  
  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20));
    _backgroundAnimationController.repeat();
    
    // Start the chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    _backgroundAnimationController.dispose();
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mystical background
          _buildMysticalBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                AppHeader(
                  title: '꿈 해몽',
                  showBackButton: true,
                  centerTitle: true,
                  onBackPressed: () {
                    _showExitConfirmDialog();
                  },
                ),
                
                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
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
                
                // Input area
                DreamInputWidget(
                  enabled: !chatState.isAnalyzing,
                  onSendPressed: () {
                    _scrollToBottom();
                    // Consume soul on first message if not done yet
                    if (!_hasConsumedSoul) {
                      _consumeSoulIfNeeded();
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Loading overlay
          if (chatState.isAnalyzing),
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMysticalBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade900.withOpacity(0.8),
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated gradient overlay
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      math.sin(_backgroundAnimationController.value * 2 * math.pi) * 0.5,
                      math.cos(_backgroundAnimationController.value * 2 * math.pi) * 0.5,
                    ),
                    radius: 1.5,
                    colors: [
                      Colors.deepPurple.shade600.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            }),
          
          // Stars
          ...List.generate(30, (index) {
            final random = index * 0.03;
            final size = 1.0 + (index % 3);
            final top = (index * 41 % 100) / 100.0;
            final left = (index * 67 % 100) / 100.0;
            
            return Positioned(
              top: MediaQuery.of(context).size.height * top,
              left: MediaQuery.of(context).size.width * left,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3 + random),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .scale(
                    duration: Duration(seconds: 3 + index % 3),
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                  )
                  .then()
                  .scale(
                    duration: Duration(seconds: 3 + index % 3),
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                  ),
            );
          }),
          
          // Floating particles
          ...List.generate(10, (index) {
            final size = 2.0 + (index % 3);
            return Positioned(
              bottom: -50,
              left: (index * 101 % 100) / 100.0 * MediaQuery.of(context).size.width,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade300.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .moveY(
                    duration: Duration(seconds: 10 + index * 2),
                    begin: 0,
                    end: -MediaQuery.of(context).size.height - 100,
                  )
                  .fadeIn()
                  .then(delay: Duration(seconds: index))
                  .fadeOut(),
            );
          }),
        ],
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
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          '꿈 해몽을 중단하시겠습니까?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '대화 내용이 저장되지 않습니다.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Reset the chat state
              ref.read(dreamChatProvider.notifier).resetChat();
            },
            child: Text(
              '나가기',
              style: TextStyle(color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
  }
}