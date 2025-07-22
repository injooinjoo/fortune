import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/tarot_metadata.dart';
import '../../../../core/constants/tarot_minor_arcana.dart';
import '../../../../core/constants/tarot_card_orientation.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/tarot_deck_provider.dart';
import '../../../../core/constants/tarot_deck_metadata.dart';
import '../../../fortune/presentation/widgets/flip_card_widget.dart';
import '../../../fortune/presentation/widgets/celtic_cross_layout.dart';
import '../../../fortune/presentation/widgets/mystical_background.dart';
import '../../../fortune/presentation/widgets/tarot_card_display.dart';
import 'package:go_router/go_router.dart';

// Provider to hold current spread type
final currentSpreadTypeProvider = StateProvider<String?>((ref) => null);

class TarotCardInput {
  final String question;

  TarotCardInput({
    required this.question,
  });
}

class TarotCard {
  final String name;
  final String meaning;
  final String position;

  TarotCard({
    required this.name,
    required this.meaning,
    required this.position,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      name: json['name'] ?? '',
      meaning: json['meaning'] ?? '',
      position: json['position'] ?? '',
    );
  }
}

class TarotResult {
  final String situation;
  final List<TarotCard> cards;
  final String interpretation;
  final String advice;

  TarotResult({
    required this.situation,
    required this.cards,
    required this.interpretation,
    required this.advice,
  });

  factory TarotResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return TarotResult(
      situation: data['situation'] ?? '',
      cards: (data['cards'] as List<dynamic>?)
          ?.map((card) => TarotCard.fromJson(card))
          .toList() ?? [],
      interpretation: data['interpretation'] ?? '',
      advice: data['advice'] ?? '',
    );
  }
}

final tarotReadingProvider = StateNotifierProvider.family<TarotReadingNotifier, AsyncValue<TarotResult?>, TarotCardInput>(
  (ref, input) => TarotReadingNotifier(ref, input),
);

class TarotReadingNotifier extends StateNotifier<AsyncValue<TarotResult?>> {
  final Ref ref;
  final TarotCardInput input;

  TarotReadingNotifier(this.ref, this.input) : super(const AsyncValue.loading()) {
    _performReading();
  }

  int _getTokenCost(String spreadType) {
    switch (spreadType) {
      case 'single':
        return 1;
      case 'three':
        return 3;
      case 'celtic':
        return 5;
      case 'relationship':
        return 4;
      case 'decision':
        return 3;
      default:
        return 3;
    }
  }

  Future<void> _performReading() async {
    try {
      final apiService = ref.read(fortuneApiServiceProvider);
      final tokenService = ref.read(tokenServiceProvider.notifier);
      
      // Check token balance based on spread type
      final spreadType = ref.read(currentSpreadTypeProvider) ?? 'three';
      final tokenCost = _getTokenCost(spreadType);
      
      final hasEnoughTokens = await tokenService.checkAndConsumeTokens(
        tokenCost,
        'tarot',
      );
      
      if (!hasEnoughTokens) {
        state = AsyncValue.error(
          Exception('토큰이 부족합니다'),
          StackTrace.current,
        );
        return;
      }

      final response = await apiService.post(
        ApiEndpoints.generateFortune,
        data: {
          'type': 'tarot',
          'userInfo': {
            'question': input.question,
            'spreadType': ref.read(currentSpreadTypeProvider) ?? 'three',
          },
        },
      );

      if (response['success'] == true) {
        state = AsyncValue.data(TarotResult.fromJson(response));
      } else {
        throw Exception(response['error'] ?? '타로 카드 해석에 실패했습니다');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class TarotCardPage extends ConsumerStatefulWidget {
  final String? spreadType;
  final String? initialQuestion;
  
  const TarotCardPage({
    super.key,
    this.spreadType,
    this.initialQuestion,
  });

  @override
  ConsumerState<TarotCardPage> createState() => _TarotCardPageState();
}

class _TarotCardPageState extends ConsumerState<TarotCardPage> with TickerProviderStateMixin {
  final _questionController = TextEditingController();
  bool _showResult = false;
  TarotCardInput? _currentInput;
  
  // Animation controllers for card selection
  late AnimationController _shuffleController;
  late AnimationController _flipController;
  late AnimationController _fanController;
  late Animation<double> _shuffleAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _fanAnimation;
  
  // Card selection state
  final List<int> _selectedCards = [];
  final List<TarotCardState> _selectedCardStates = [];
  bool _isSelecting = false;
  bool _cardsRevealed = false;
  
  // Check if deck is selected on first load
  bool _hasCheckedDeck = false;
  
  // Spread configuration
  int get _requiredCards {
    switch (widget.spreadType) {
      case 'single':
        return 1;
      case 'three':
        return 3;
      case 'celtic':
        return 10;
      case 'relationship':
        return 5;
      case 'decision':
        return 5;
      default:
        return 3;
    }
  }

  @override
  void initState() {
    super.initState();
    
    if (widget.initialQuestion != null) {
      _questionController.text = widget.initialQuestion!;
    }
    
    // Set the spread type in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentSpreadTypeProvider.notifier).state = widget.spreadType ?? 'three';
      _checkDeckSelection();
    });
    
    _shuffleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fanController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _shuffleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shuffleController,
      curve: Curves.easeInOut,
    ));
    
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
    
    _fanAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fanController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _questionController.dispose();
    _shuffleController.dispose();
    _flipController.dispose();
    _fanController.dispose();
    super.dispose();
  }
  
  void _checkDeckSelection() {
    if (!_hasCheckedDeck) {
      _hasCheckedDeck = true;
      final selectedDeck = ref.read(selectedTarotDeckProvider);
      // If no deck is selected, navigate to deck selection
      if (selectedDeck == null || selectedDeck.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pushReplacementNamed(
              'tarot-deck-selection',
              queryParameters: {
                if (widget.spreadType != null) 'spreadType': widget.spreadType!,
                if (widget.initialQuestion != null) 'question': widget.initialQuestion!,
              },
            );
          }
        });
      }
    }
  }

  void _startCardSelection() {
    if (widget.spreadType != 'single' && _questionController.text.isEmpty) {
      Toast.show(
        context,
        message: '질문을 입력해주세요',
        type: ToastType.warning,
      );
      return;
    }

    // Light haptic feedback for start
    HapticFeedback.lightImpact();

    setState(() {
      _isSelecting = true;
      _selectedCards.clear();
      _cardsRevealed = false;
    });
    
    _shuffleController.repeat();
    _fanController.forward();
  }

  void _selectCard(int index) {
    if (_selectedCards.contains(index) || _selectedCards.length >= _requiredCards) return;
    
    // Haptic feedback for card selection
    HapticFeedback.mediumImpact();
    
    setState(() {
      _selectedCards.add(index);
      _selectedCardStates.add(TarotCardState.fromSelection(index));
    });
    
    if (_selectedCards.length == _requiredCards) {
      _shuffleController.stop();
      // Heavy impact for completion
      HapticFeedback.heavyImpact();
      _performReading();
    }
  }

  void _performReading() {
    final selectedDeck = ref.read(selectedTarotDeckProvider);
    // Navigate to storytelling page instead of showing result
    context.pushNamed(
      'tarot-storytelling',
      extra: {
        'selectedCards': _selectedCards,
        'spreadType': widget.spreadType ?? 'three',
        'question': _questionController.text.isNotEmpty ? _questionController.text : null,
        'deckId': selectedDeck,
      },
    );
  }

  void _reset() {
    setState(() {
      _showResult = false;
      _currentInput = null;
      _questionController.clear();
      _selectedCards.clear();
      _isSelecting = false;
      _cardsRevealed = false;
    });
    _shuffleController.reset();
    _flipController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    final selectedDeck = ref.watch(currentTarotDeckProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: MysticalBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: '타로카드',
                showBackButton: true,
                showActions: !_showResult,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.style),
                    onPressed: () {
                      context.pushNamed(
                        'tarot-deck-selection',
                        queryParameters: {
                          if (widget.spreadType != null) 'spreadType': widget.spreadType!,
                          if (_questionController.text.isNotEmpty) 'question': _questionController.text,
                        },
                      );
                    },
                    tooltip: '덱 변경',
                  ),
                ],
              ),
              Expanded(
                child: _showResult && _currentInput != null
                    ? _TarotResultView(
                        input: _currentInput!,
                        selectedCards: _selectedCards,
                        selectedCardStates: _selectedCardStates,
                        spreadType: widget.spreadType,
                        onReset: _reset,
                        fontScale: fontScale,
                        selectedDeck: selectedDeck,
                      )
                    : _TarotInputView(
                        questionController: _questionController,
                        isSelecting: _isSelecting,
                        selectedCards: _selectedCards,
                        shuffleAnimation: _shuffleAnimation,
                        fanAnimation: _fanAnimation,
                        requiredCards: _requiredCards,
                        spreadType: widget.spreadType,
                        onStartSelection: _startCardSelection,
                        onSelectCard: _selectCard,
                        fontScale: fontScale,
                        selectedDeck: selectedDeck,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarotInputView extends StatelessWidget {
  final TextEditingController questionController;
  final bool isSelecting;
  final List<int> selectedCards;
  final Animation<double> shuffleAnimation;
  final Animation<double> fanAnimation;
  final int requiredCards;
  final String? spreadType;
  final VoidCallback onStartSelection;
  final Function(int) onSelectCard;
  final double fontScale;
  final TarotDeck selectedDeck;

  const _TarotInputView({
    required this.questionController,
    required this.isSelecting,
    required this.selectedCards,
    required this.shuffleAnimation,
    required this.fanAnimation,
    required this.requiredCards,
    this.spreadType,
    required this.onStartSelection,
    required this.onSelectCard,
    required this.fontScale,
    required this.selectedDeck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Icon
          GlassContainer(
            width: 120,
            height: 120,
            borderRadius: BorderRadius.circular(60),
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.4),
                Colors.indigo.withValues(alpha: 0.4),
              ],
            ),
            blur: 15,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 56,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                // Rotating glow effect
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 2 * math.pi),
                  duration: const Duration(seconds: 10),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.purple.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.indigo.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.purple.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Animation repeats automatically
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            '타로카드로 보는 운세',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 28 * fontScale,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.purple.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Selected deck info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selectedDeck.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selectedDeck.primaryColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              selectedDeck.koreanName,
              style: TextStyle(
                fontSize: 14 * fontScale,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            isSelecting 
                ? '카드를 ${requiredCards}장 선택해주세요 (${selectedCards.length}/$requiredCards)'
                : spreadType == 'single' 
                    ? '오늘의 메시지를 받아보세요'
                    : '마음 속 질문을 입력하고 카드를 뽑아보세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16 * fontScale,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          if (!isSelecting) ...[
            // Question Input (hide for single card)
            if (spreadType != 'single') ...[
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '질문하기',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16 * fontScale,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: questionController,
                      style: TextStyle(fontSize: 16 * fontScale),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '예: 지금 진행하는 프로젝트가 잘 될까요?',
                        filled: true,
                        fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Start Button
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                onPressed: onStartSelection,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20 * fontScale),
                      const SizedBox(width: 8),
                      Text(
                        '타로 카드 섞기',
                        style: TextStyle(
                          fontSize: 18 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // Enhanced Card Selection with Fan Layout
            _TarotCardFanSelection(
              shuffleAnimation: shuffleAnimation,
              fanAnimation: fanAnimation,
              selectedCards: selectedCards,
              requiredCards: requiredCards,
              onSelectCard: onSelectCard,
              fontScale: fontScale,
              selectedDeck: selectedDeck,
            ),
          ],
        ],
      ),
    );
  }
}

class _TarotResultView extends ConsumerWidget {
  final TarotCardInput input;
  final List<int> selectedCards;
  final List<TarotCardState> selectedCardStates;
  final String? spreadType;
  final VoidCallback onReset;
  final double fontScale;
  final TarotDeck selectedDeck;

  const _TarotResultView({
    required this.input,
    required this.selectedCards,
    required this.selectedCardStates,
    this.spreadType,
    required this.onReset,
    required this.fontScale,
    required this.selectedDeck,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readingAsync = ref.watch(tarotReadingProvider(input));

    return readingAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(size: 60),
            SizedBox(height: 24),
            Text(
              'AI가 카드를 해석하고 있습니다...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString().contains('토큰')
                    ? '토큰이 부족합니다'
                    : '타로 카드 해석 중 오류가 발생했습니다',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassButton(
                onPressed: onReset,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('다시 시도'),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (result) => result == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Question & Situation
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withValues(alpha: 0.1),
                        Colors.indigo.withValues(alpha: 0.1),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '질문',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * fontScale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          input.question,
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.visibility_outlined, color: theme.colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              '현재 상황',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * fontScale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.situation,
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Selected Cards
                  if (result.cards.isNotEmpty) ...[
                    if (spreadType == 'celtic') ...[
                      // Celtic Cross Layout
                      CelticCrossLayout(
                        cards: result.cards,
                        fontScale: fontScale,
                      ),
                    ] else ...[
                      // Standard horizontal layout for other spreads
                      Text(
                        '선택하신 카드',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20 * fontScale,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: result.cards.length,
                          itemBuilder: (context, index) {
                            if (index < selectedCardStates.length) {
                              final cardState = selectedCardStates[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0 ? 0 : 8,
                                  right: index == result.cards.length - 1 ? 0 : 8,
                                ),
                                child: Column(
                                  children: [
                                    TarotCardDisplay(
                                      cardState: cardState,
                                      selectedDeck: selectedDeck,
                                      width: 120,
                                      height: 180,
                                      isFlipped: true,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 120,
                                      child: Text(
                                        result.cards[index].position,
                                        style: TextStyle(
                                          fontSize: 12 * fontScale,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                  
                  // Interpretation
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_stories, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'AI의 해석',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * fontScale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          result.interpretation,
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Advice
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary.withValues(alpha: 0.1),
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: theme.colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              '조언',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * fontScale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          result.advice,
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      onPressed: onReset,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 20 * fontScale),
                            const SizedBox(width: 8),
                            Text(
                              '다시 뽑기',
                              style: TextStyle(
                                fontSize: 18 * fontScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TarotCardWidget extends StatelessWidget {
  final TarotCard card;
  final int cardNumber;
  final double fontScale;

  const _TarotCardWidget({
    required this.card,
    required this.cardNumber,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      width: 180,
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        colors: [
          Colors.purple.withValues(alpha: 0.2),
          Colors.indigo.withValues(alpha: 0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
        width: 1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$cardNumber',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * fontScale,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                card.position,
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Icon(
            Icons.style,
            size: 60,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          Column(
            children: [
              Text(
                card.name,
                style: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                card.meaning,
                style: TextStyle(
                  fontSize: 13 * fontScale,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Enhanced card selection with fan layout
class _TarotCardFanSelection extends StatelessWidget {
  final Animation<double> shuffleAnimation;
  final Animation<double> fanAnimation;
  final List<int> selectedCards;
  final int requiredCards;
  final Function(int) onSelectCard;
  final double fontScale;
  final TarotDeck selectedDeck;

  const _TarotCardFanSelection({
    required this.shuffleAnimation,
    required this.fanAnimation,
    required this.selectedCards,
    required this.requiredCards,
    required this.onSelectCard,
    required this.fontScale,
    required this.selectedDeck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardCount = 78; // All tarot cards (22 Major + 56 Minor Arcana)
    final centerX = screenWidth / 2;
    
    return AnimatedBuilder(
      animation: Listenable.merge([fanAnimation, shuffleAnimation]),
      builder: (context, child) {
        return Container(
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Selection hint
              if (selectedCards.isEmpty && fanAnimation.value > 0.8)
                Positioned(
                  bottom: 20,
                  child: FadeTransition(
                    opacity: fanAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '카드를 선택해주세요',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14 * fontScale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Cards
              ...List.generate(cardCount, (index) {
                final progress = fanAnimation.value;
                final shuffleOffset = shuffleAnimation.value * 2 * math.pi;
                
                // Create arc layout
                final cardPosition = (index - cardCount / 2) / (cardCount / 2);
                final angle = cardPosition * 0.8 * progress; // Arc spread
                final radius = 200.0 * progress;
                
                // Calculate position on arc
                final x = radius * math.sin(angle);
                final y = radius * (1 - math.cos(angle)) - 100;
                
                // Add shuffle movement
                final shuffleX = math.sin(shuffleOffset + index) * 5;
                final shuffleY = math.cos(shuffleOffset + index) * 3;
                
                final isSelected = selectedCards.contains(index);
                final selectionOrder = selectedCards.indexOf(index);
                
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  left: centerX + x + shuffleX - 40,
                  top: 200 + y + shuffleY - 60,
                  child: Transform.rotate(
                    angle: angle * 0.7,
                    alignment: Alignment.bottomCenter,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: isSelected ? 1.15 : 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: isSelected
                            ? (Matrix4.identity()
                              ..translate(0.0, -20.0))
                            : Matrix4.identity(),
                        child: GestureDetector(
                          onTap: () {
                            if (!isSelected && selectedCards.length < requiredCards) {
                              onSelectCard(index);
                            }
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: _EnhancedTarotCard(
                              cardIndex: index,
                              isSelected: isSelected,
                              selectionOrder: selectionOrder,
                              fontScale: fontScale,
                              isHoverable: !isSelected && selectedCards.length < requiredCards,
                              selectedDeck: selectedDeck,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// Enhanced tarot card widget with better visuals
class _EnhancedTarotCard extends StatefulWidget {
  final int cardIndex;
  final bool isSelected;
  final int selectionOrder;
  final double fontScale;
  final bool isHoverable;
  final TarotDeck selectedDeck;

  const _EnhancedTarotCard({
    required this.cardIndex,
    required this.isSelected,
    required this.selectionOrder,
    required this.fontScale,
    required this.isHoverable,
    required this.selectedDeck,
  });

  @override
  State<_EnhancedTarotCard> createState() => _EnhancedTarotCardState();
}

class _EnhancedTarotCardState extends State<_EnhancedTarotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.isHoverable) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowIntensity = widget.isSelected || _isHovered 
              ? _glowController.value 
              : 0.0;
          
          return Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                // Base shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
                // Glow effect
                if (widget.isSelected)
                  BoxShadow(
                    color: const Color(0xFF9333EA).withValues(alpha: 0.6 + glowIntensity * 0.2),
                    blurRadius: 20 + glowIntensity * 10,
                    spreadRadius: 2,
                  ),
                if (_isHovered && !widget.isSelected)
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Card back design
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.selectedDeck.primaryColor.withValues(alpha: 0.8),
                          widget.selectedDeck.secondaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  
                  // Pattern overlay
                  CustomPaint(
                    painter: _CardBackPatternPainter(
                      glowIntensity: glowIntensity,
                    ),
                    size: const Size(80, 120),
                  ),
                  
                  // Center emblem with deck initial
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 28,
                          color: Colors.white.withValues(alpha: 0.8 + glowIntensity * 0.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.selectedDeck.code.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.6 + glowIntensity * 0.2),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection indicator
                  if (widget.isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9333EA),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.selectionOrder + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Hover effect overlay
                  if (_isHovered && !widget.isSelected)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Card back pattern painter
class _CardBackPatternPainter extends CustomPainter {
  final double glowIntensity;

  _CardBackPatternPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw mystical patterns
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Outer circle
    paint.color = Colors.white.withValues(alpha: 0.1 + glowIntensity * 0.1);
    canvas.drawCircle(Offset(centerX, centerY), 30, paint);

    // Inner patterns
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final x1 = centerX + 20 * math.cos(angle);
      final y1 = centerY + 20 * math.sin(angle);
      final x2 = centerX + 30 * math.cos(angle);
      final y2 = centerY + 30 * math.sin(angle);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Corner decorations
    paint.color = Colors.white.withValues(alpha: 0.2 + glowIntensity * 0.1);
    final cornerSize = 10.0;
    
    // Top left
    canvas.drawLine(Offset(0, cornerSize), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(cornerSize, 0), paint);
    
    // Top right
    canvas.drawLine(Offset(size.width - cornerSize, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize), paint);
    
    // Bottom left
    canvas.drawLine(Offset(0, size.height - cornerSize), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize, size.height), paint);
    
    // Bottom right
    canvas.drawLine(Offset(size.width - cornerSize, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}