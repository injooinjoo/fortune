import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../presentation/providers/token_provider.dart';

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

  Future<void> _performReading() async {
    try {
      final apiService = ref.read(fortuneApiServiceProvider);
      final tokenService = ref.read(tokenServiceProvider.notifier);
      
      // Check token balance
      final hasEnoughTokens = await tokenService.checkAndConsumeTokens(
        3,
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
  const TarotCardPage({super.key});

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
  late Animation<double> _shuffleAnimation;
  late Animation<double> _flipAnimation;
  
  // Card selection state
  final List<int> _selectedCards = [];
  bool _isSelecting = false;
  bool _cardsRevealed = false;

  @override
  void initState() {
    super.initState();
    _shuffleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
  }

  @override
  void dispose() {
    _questionController.dispose();
    _shuffleController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _startCardSelection() {
    if (_questionController.text.isEmpty) {
      Toast.show(
        context,
        message: '질문을 입력해주세요',
        type: ToastType.warning,
      );
      return;
    }

    setState(() {
      _isSelecting = true;
      _selectedCards.clear();
      _cardsRevealed = false;
    });
    
    _shuffleController.repeat();
  }

  void _selectCard(int index) {
    if (_selectedCards.contains(index) || _selectedCards.length >= 3) return;
    
    setState(() {
      _selectedCards.add(index);
    });
    
    if (_selectedCards.length == 3) {
      _shuffleController.stop();
      _performReading();
    }
  }

  void _performReading() {
    setState(() {
      _currentInput = TarotCardInput(
        question: _questionController.text,
      );
      _showResult = true;
    });
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '타로카드',
              showBackButton: true,
              showActions: !_showResult,
            ),
            Expanded(
              child: _showResult && _currentInput != null
                  ? _TarotResultView(
                      input: _currentInput!,
                      selectedCards: _selectedCards,
                      onReset: _reset,
                      fontScale: fontScale,
                    )
                  : _TarotInputView(
                      questionController: _questionController,
                      isSelecting: _isSelecting,
                      selectedCards: _selectedCards,
                      shuffleAnimation: _shuffleAnimation,
                      onStartSelection: _startCardSelection,
                      onSelectCard: _selectCard,
                      fontScale: fontScale,
                    ),
            ),
          ],
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
  final VoidCallback onStartSelection;
  final Function(int) onSelectCard;
  final double fontScale;

  const _TarotInputView({
    required this.questionController,
    required this.isSelecting,
    required this.selectedCards,
    required this.shuffleAnimation,
    required this.onStartSelection,
    required this.onSelectCard,
    required this.fontScale,
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
            width: 100,
            height: 100,
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.3),
                Colors.indigo.withValues(alpha: 0.3),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.style_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            '타로카드로 보는 운세',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24 * fontScale,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSelecting 
                ? '카드를 3장 선택해주세요 (${selectedCards.length}/3)'
                : '마음 속 질문을 입력하고 카드를 뽑아보세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16 * fontScale,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          if (!isSelecting) ...[
            // Question Input
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
            // Card Selection Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final isSelected = selectedCards.contains(index);
                final selectionOrder = selectedCards.indexOf(index);
                
                return AnimatedBuilder(
                  animation: shuffleAnimation,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(isSelected ? 0 : shuffleAnimation.value * 0.1),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => onSelectCard(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          transform: isSelected
                              ? (Matrix4.identity()..scale(0.95))
                              : Matrix4.identity(),
                          child: Stack(
                            children: [
                              GlassContainer(
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [
                                          Colors.purple.withValues(alpha: 0.4),
                                          Colors.indigo.withValues(alpha: 0.4),
                                        ]
                                      : [
                                          theme.colorScheme.primary.withValues(alpha: 0.2),
                                          theme.colorScheme.secondary.withValues(alpha: 0.2),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      )
                                    : null,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.style,
                                        size: 48,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${selectionOrder + 1}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16 * fontScale,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
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
  final VoidCallback onReset;
  final double fontScale;

  const _TarotResultView({
    required this.input,
    required this.selectedCards,
    required this.onReset,
    required this.fontScale,
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
                          final card = result.cards[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 0 : 8,
                              right: index == result.cards.length - 1 ? 0 : 8,
                            ),
                            child: _TarotCardWidget(
                              card: card,
                              cardNumber: index + 1,
                              fontScale: fontScale,
                            ),
                          );
                        },
                      ),
                    ),
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