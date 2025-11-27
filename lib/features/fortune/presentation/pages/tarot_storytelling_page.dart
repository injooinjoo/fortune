import 'package:flutter/material.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/providers/user_settings_provider.dart';
import '../widgets/tarot_card_reveal_widget.dart';
import '../widgets/tarot_interpretation_bubble.dart';
import '../widgets/mystical_background.dart';
import '../providers/tarot_storytelling_provider.dart';
import 'package:go_router/go_router.dart';

class TarotStorytellingPage extends ConsumerStatefulWidget {
  final List<int> selectedCards;
  final String spreadType;
  final String? question;

  const TarotStorytellingPage({
    super.key,
    required this.selectedCards,
    required this.spreadType,
    this.question,
  });

  @override
  ConsumerState<TarotStorytellingPage> createState() => _TarotStorytellingPageState();
}

class _TarotStorytellingPageState extends ConsumerState<TarotStorytellingPage>
    with TickerProviderStateMixin {
  int _currentCardIndex = 0;
  bool _isRevealing = false;
  bool _showInterpretation = false;
  final List<bool> _cardRevealed = [];
  final List<String> _interpretations = [];
  final ScrollController _scrollController = ScrollController();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize revealed states
    for (int i = 0; i < widget.selectedCards.length; i++) {
      _cardRevealed.add(false);
    }

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic));

    // Start with introduction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIntroduction();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
    }

  void _showIntroduction() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    _slideController.forward();
    }

  void _revealNextCard() async {
    if (_currentCardIndex >= widget.selectedCards.length) return;

    setState(() {
      _isRevealing = true;
      _showInterpretation = false;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Trigger card reveal
    setState(() {
      _cardRevealed[_currentCardIndex] = true;
    });

    // Wait for card flip animation
    await Future.delayed(const Duration(milliseconds: 1000));

    // Get interpretation from provider
    final interpretation = await ref.read(
      tarotInterpretationProvider(
        TarotInterpretationRequest(
          cardIndex: widget.selectedCards[_currentCardIndex],
          position: _currentCardIndex,
          spreadType: widget.spreadType,
          question: widget.question)).future);

    setState(() {
      _interpretations.add(interpretation);
      _showInterpretation = true;
      _isRevealing = false;
    });

    // Auto scroll to bottom
    _scrollToBottom();
    }

  void _proceedToNext() {
    if (_currentCardIndex < widget.selectedCards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showInterpretation = false;
      });
      _fadeController.forward();
    } else {
      // Navigate to final summary
      _showFinalSummary();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut);
      }
    });
  }

  void _showFinalSummary() {
    context.pushReplacementNamed(
      'tarot-summary',
      extra: {
        'cards': widget.selectedCards,
        'interpretations': _interpretations,
        'spreadType': widget.spreadType,
        'question': widget.question});
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ref.watch(userSettingsProvider).fontScale;

    return Scaffold(
      backgroundColor: TossDesignSystem.black,
      appBar: const StandardFortuneAppBar(
        title: '타로 리딩',
      ),
      body: MysticalBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(

                    children: [
                      // Introduction or current card section
                      if (_currentCardIndex == 0 && !_cardRevealed[0])
                        _buildIntroduction(fontScale)
                      else
                        _buildCurrentCardSection(fontScale),
                      
                      const SizedBox(height: 24),
                      // Interpretation bubbles
                      ..._buildInterpretationHistory(fontScale),
                      
                      const SizedBox(height: 80), // Space for bottom button
                    ],
                  ),
                ),
              ),
              
              // Action button
              _buildActionButton(fontScale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentCardIndex + 1) / widget.selectedCards.length;
    
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: TossDesignSystem.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Progress with gradient and glow
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9333EA),
                    const Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9333EA).withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1),
                ],
              ),
            ),
          ),
          // Shimmer effect
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.white.withValues(alpha: 0),
                        TossDesignSystem.white.withValues(alpha: 0.3 * _fadeController.value),
                        TossDesignSystem.white.withValues(alpha: 0)],
                      stops: const [0.0, 0.5, 1.0]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction(double fontScale) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(

          children: [
            // Enhanced mystical icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating aura
                    Transform.rotate(
                      angle: value * 2 * math.pi,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              TossDesignSystem.purple.withValues(alpha: 0),
                              const Color(0xFF9333EA).withValues(alpha: 0.3),
                              TossDesignSystem.purple.withValues(alpha: 0.3),
                              TossDesignSystem.purple.withValues(alpha: 0)],
                          ),
                        ),
                      ),
                    ),
                    // Center icon
                    Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: TossDesignSystem.white,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF9333EA),
                          blurRadius: 20),
                      ],
                    ),
                  ],
                );
              }),
            const SizedBox(height: 24),
            Text(
              '타로 카드가 당신에게 전하는 메시지',
              style: context.heading2.copyWith(
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.white),
              textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              widget.question ?? '오늘의 운세를 알아보겠습니다',
              style: context.buttonMedium.copyWith(
                color: TossDesignSystem.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
            const SizedBox(height: 32),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.purple.withValues(alpha: 0.2),
                  TossDesignSystem.purple.withValues(alpha: 0.2)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TossDesignSystem.white.withValues(alpha: 0.1),
                width: 1),
              child: Column(

                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          TossDesignSystem.white.withValues(alpha: 0.1),
                          TossDesignSystem.transparent])),
                    child: Icon(
                      Icons.info_outline,
                      color: TossDesignSystem.white.withValues(alpha: 0.9),
                      size: 24)),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.selectedCards.length}장의 카드를 하나씩 공개하며\n각 카드가 전하는 메시지를 들려드리겠습니다.',
                    style: context.bodySmall.copyWith(
                      color: TossDesignSystem.white,
                      height: 1.5,
                      letterSpacing: 0.5),
                    textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCardSection(double fontScale) {
    if (_currentCardIndex >= widget.selectedCards.length) return const SizedBox();

    final positionName = TarotHelper.getPositionDescription(
      widget.spreadType,
      _currentCardIndex);

    return Column(
      children: [
        // Position title
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9333EA).withValues(alpha: 0.3),
                  const Color(0xFF7C3AED).withValues(alpha: 0.3)]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: TossDesignSystem.white.withValues(alpha: 0.2),
                width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9333EA).withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2)]),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_currentCardIndex + 1}',
                      style: context.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TossDesignSystem.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  positionName,
                  style: context.buttonMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Card reveal area
        SizedBox(
          height: 300,
          child: Center(
            child: TarotCardRevealWidget(
              cardIndex: widget.selectedCards[_currentCardIndex],
              isRevealed: _cardRevealed[_currentCardIndex],
              onTap: !_cardRevealed[_currentCardIndex] ? _revealNextCard : null,
              width: 180,
              height: 280,
            ),
          ),
        ),
        
        // Current interpretation
        if (_showInterpretation && _currentCardIndex < _interpretations.length) 
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: TarotInterpretationBubble(
                interpretation: _interpretations[_currentCardIndex],
                isCurrentCard: true,
                fontScale: fontScale),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildInterpretationHistory(double fontScale) {
    final history = <Widget>[];
    
    for (int i = 0; i < _currentCardIndex; i++) {
      if (i < _interpretations.length) {
        final cardInfo = TarotMetadata.majorArcana[widget.selectedCards[i] % 22];
        final positionName = TarotHelper.getPositionDescription(widget.spreadType, i);
        
        history.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card summary header
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.purple.withValues(alpha: 0.1),
                      TossDesignSystem.purple.withValues(alpha: 0.1)]),
                  child: Row(
                    children: [
                      // Mini card image
                      Container(
                        width: 40,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/tarot/${_getCardImagePath(widget.selectedCards[i])}'),
                            fit: BoxFit.cover),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9333EA).withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1)])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${i + 1}. $positionName',
                              style: context.labelMedium.copyWith(
                                color: TossDesignSystem.white.withValues(alpha: 0.7))),
                            Text(
                              cardInfo?.name ?? 'Unknown Card',
                              style: context.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: TossDesignSystem.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Interpretation
                TarotInterpretationBubble(
                  interpretation: _interpretations[i],
                  isCurrentCard: false,
                  fontScale: fontScale),
              ],
            ),
          ),
        );
      }
    }
    
    return history;
  }

  Widget _buildActionButton(double fontScale) {
    String buttonText;
    VoidCallback? onPressed;

    if (_currentCardIndex == 0 && !_cardRevealed[0]) {
      buttonText = '첫 번째 카드 공개하기';
      onPressed = _revealNextCard;
    } else if (_isRevealing) {
      buttonText = '해석 중...';
      onPressed = null;
    } else if (!_cardRevealed[_currentCardIndex]) {
      buttonText = '카드 뒤집기';
      onPressed = _revealNextCard;
    } else if (_showInterpretation) {
      if (_currentCardIndex < widget.selectedCards.length - 1) {
        buttonText = '다음 카드 보기';
        onPressed = _proceedToNext;
      } else {
        buttonText = '전체 해석 보기';
        onPressed = _showFinalSummary;
      }
    } else {
      buttonText = '잠시만 기다려주세요...';
      onPressed = null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TossDesignSystem.transparent,
            TossDesignSystem.black.withValues(alpha: 0.8)])),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: UnifiedButton(
            text: buttonText,
            onPressed: onPressed,
            style: UnifiedButtonStyle.primary,
            size: UnifiedButtonSize.large,
            icon: onPressed != null && !_isRevealing
                ? Icon(_currentCardIndex == widget.selectedCards.length - 1 && _showInterpretation
                    ? Icons.auto_awesome
                    : Icons.arrow_forward)
                : null,
          ),
        ),
      ),
    );
  }

  String _getCardImagePath(int cardIndex) {
    // Default to before_tarot deck
    const deckPath = 'decks/before_tarot';
    
    if (cardIndex < 22) {
      // Major Arcana
      final cardNames = [
        'fool', 'magician', 'high_priestess', 'empress', 'emperor', 'hierophant', 'lovers', 'chariot', 'strength', 'hermit',
        'wheel_of_fortune', 'justice', 'hanged_man', 'death', 'temperance', 'devil', 'tower', 'star', 'moon', 'sun', 'judgement', 'world'
      ];
      return '$deckPath/major/${cardIndex.toString().padLeft(2, '0')}_${cardNames[cardIndex]}.jpg';
    } else if (cardIndex < 36) {
      // Wands
      final wandsIndex = cardIndex - 21;
      final cardName = wandsIndex <= 10 ? 'of_wands' : _getCourtCardName(wandsIndex, 'wands');
      return '$deckPath/wands/${wandsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 50) {
      // Cups
      final cupsIndex = cardIndex - 35;
      final cardName = cupsIndex <= 10 ? 'of_cups' : _getCourtCardName(cupsIndex, 'cups');
      return '$deckPath/cups/${cupsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else if (cardIndex < 64) {
      // Swords
      final swordsIndex = cardIndex - 49;
      final cardName = swordsIndex <= 10 ? 'of_swords' : _getCourtCardName(swordsIndex, 'swords');
      return '$deckPath/swords/${swordsIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    } else {
      // Pentacles
      final pentaclesIndex = cardIndex - 63;
      final cardName = pentaclesIndex <= 10 ? 'of_pentacles' : _getCourtCardName(pentaclesIndex, 'pentacles');
      return '$deckPath/pentacles/${pentaclesIndex.toString().padLeft(2, '0')}_$cardName.jpg';
    }
  }

  String _getCourtCardName(int index, String suit) {
    switch (index) {
      case 11: return 'page_of_$suit';
      case 12: return 'knight_of_$suit';
      case 13: return 'queen_of_$suit';
      case 14: return 'king_of_$suit';
      default: return 'of_$suit';
    }
  }
}