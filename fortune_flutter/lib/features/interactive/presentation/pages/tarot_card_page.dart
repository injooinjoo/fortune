import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../presentation/providers/tarot_deck_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../fortune/presentation/widgets/tarot/tarot_input_view.dart';
import '../../../fortune/presentation/widgets/tarot/tarot_selection_view.dart';
import '../../../fortune/presentation/widgets/tarot/tarot_result_view.dart';

/// Provider to manage the tarot reading state
final tarotReadingStateProvider = StateNotifierProvider.autoDispose<TarotReadingStateNotifier, TarotReadingState>(
  (ref) => TarotReadingStateNotifier(),
);

/// State for the tarot reading process
class TarotReadingState {
  final TarotReadingStep currentStep;
  final String question;
  final String spreadType;
  final List<int> selectedCards;
  final Map<String, dynamic>? readingResult;
  final bool isLoading;

  TarotReadingState({
    this.currentStep = TarotReadingStep.input,
    this.question = '',
    this.spreadType = 'three',
    this.selectedCards = const [],
    this.readingResult,
    this.isLoading = false,
  });

  TarotReadingState copyWith({
    TarotReadingStep? currentStep,
    String? question,
    String? spreadType,
    List<int>? selectedCards,
    Map<String, dynamic>? readingResult,
    bool? isLoading,
  }) {
    return TarotReadingState(
      currentStep: currentStep ?? this.currentStep,
      question: question ?? this.question,
      spreadType: spreadType ?? this.spreadType,
      selectedCards: selectedCards ?? this.selectedCards,
      readingResult: readingResult ?? this.readingResult,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

enum TarotReadingStep { input, selection, result }

class TarotReadingStateNotifier extends StateNotifier<TarotReadingState> {
  TarotReadingStateNotifier() : super(TarotReadingState());

  void setQuestion(String question) {
    state = state.copyWith(question: question);
  }

  void setSpreadType(String spreadType) {
    state = state.copyWith(spreadType: spreadType);
  }

  void proceedToSelection() {
    state = state.copyWith(currentStep: TarotReadingStep.selection);
  }

  void setSelectedCards(List<int> cards) {
    state = state.copyWith(selectedCards: cards);
  }

  void setReadingResult(Map<String, dynamic> result) {
    state = state.copyWith(
      readingResult: result,
      currentStep: TarotReadingStep.result,
      isLoading: false,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void reset() {
    state = TarotReadingState();
  }
}

/// Simplified Tarot Card Page using new components
class TarotCardPage extends ConsumerStatefulWidget {
  final String? spreadType;
  final String? initialQuestion;
  final Map<String, dynamic>? extra;

  const TarotCardPage({
    super.key,
    this.spreadType,
    this.initialQuestion,
    this.extra,
  });

  @override
  ConsumerState<TarotCardPage> createState() => _TarotCardPageState();
}

class _TarotCardPageState extends ConsumerState<TarotCardPage> {
  TarotDeck? selectedDeck;
  bool _hasCheckedDeck = false;

  @override
  void initState() {
    super.initState();
    print('[TarotCardPage] === initState ===');
    print('[TarotCardPage] widget.extra: ${widget.extra}');
    print('[TarotCardPage] widget.spreadType: ${widget.spreadType}');
    print('[TarotCardPage] widget.initialQuestion: ${widget.initialQuestion}');
    
    // Initialize from parameters
    if (widget.extra != null) {
      final extra = widget.extra!;
      final deckId = extra['deckId'] as String?;
      if (deckId != null) {
        selectedDeck = TarotDeckMetadata.availableDecks[deckId];
      }
      
      final question = extra['question'] as String? ?? widget.initialQuestion ?? '';
      final spreadType = extra['spreadType'] as String? ?? widget.spreadType ?? 'three';
      
      // Set initial state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tarotReadingStateProvider.notifier).setQuestion(question);
        ref.read(tarotReadingStateProvider.notifier).setSpreadType(spreadType);
        
        // Skip directly to selection if we have a question
        if (extra['skipSpreadSelection'] == true && question.isNotEmpty) {
          ref.read(tarotReadingStateProvider.notifier).proceedToSelection();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('[TarotCardPage] === didChangeDependencies ===');
    print('[TarotCardPage] _hasCheckedDeck: $_hasCheckedDeck');
    print('[TarotCardPage] selectedDeck: $selectedDeck');
    
    // Check for deck selection
    if (!_hasCheckedDeck) {
      _hasCheckedDeck = true;
      selectedDeck ??= ref.watch(currentTarotDeckProvider);
      print('[TarotCardPage] After provider watch - selectedDeck: $selectedDeck');
      
      if (selectedDeck == null) {
        // Navigate to deck selection
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.push('/fortune/tarot-deck-selection').then((result) {
            if (mounted && result != null) {
              setState(() {
                selectedDeck = result as TarotDeck;
              });
            }
          });
        });
      }
    }
  }

  int get _requiredCards {
    final spreadType = ref.watch(tarotReadingStateProvider).spreadType;
    switch (spreadType) {
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

  Future<void> _performReading(List<int> selectedCards) async {
    final state = ref.read(tarotReadingStateProvider);
    final stateNotifier = ref.read(tarotReadingStateProvider.notifier);
    final apiService = ref.read(fortuneApiServiceProvider);
    final tokenService = ref.read(tokenServiceProvider.notifier);
    
    stateNotifier.setLoading(true);
    
    try {
      // Check token balance
      final tokenCost = _getTokenCost(state.spreadType);
      final hasEnoughTokens = await tokenService.checkAndConsumeTokens(
        tokenCost,
        'tarot',
      );
      
      if (!hasEnoughTokens) {
        Toast.show(
          context,
          message: '토큰이 부족합니다',
          type: ToastType.error,
        );
        stateNotifier.setLoading(false);
        return;
      }

      // Perform API call
      final response = await apiService.post(
        ApiEndpoints.generateFortune,
        data: {
          'type': 'tarot',
          'userInfo': {
            'question': state.question.isEmpty ? '오늘의 운세를 봐주세요' : state.question,
            'spreadType': state.spreadType,
            'selectedCards': selectedCards,
            'deckId': selectedDeck?.id ?? 'rider_waite',
          },
        },
      );

      if (response['success'] == true && response['data'] != null) {
        stateNotifier.setReadingResult(response['data']);
      } else {
        throw Exception(response['error'] ?? '타로 카드 해석에 실패했습니다');
      }
    } catch (e) {
      Toast.show(
        context,
        message: '타로 리딩 중 오류가 발생했습니다',
        type: ToastType.error,
      );
      stateNotifier.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[TarotCardPage] === Build ===');
    final theme = Theme.of(context);
    final state = ref.watch(tarotReadingStateProvider);
    print('[TarotCardPage] Current state step: ${state.currentStep}');
    print('[TarotCardPage] selectedDeck: $selectedDeck');
    
    // Show loading if no deck selected
    if (selectedDeck == null) {
      print('[TarotCardPage] No deck selected, showing loading');
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '타로 카드',
              showBackButton: true,
              showActions: true,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildCurrentStep(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(TarotReadingState state) {
    print('[TarotCardPage] _buildCurrentStep - step: ${state.currentStep}');
    switch (state.currentStep) {
      case TarotReadingStep.input:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: TarotInputView(
            key: const ValueKey('input'),
            initialQuestion: state.question,
            onQuestionChanged: (question) {
              ref.read(tarotReadingStateProvider.notifier).setQuestion(question);
            },
            onProceed: () {
              ref.read(tarotReadingStateProvider.notifier).proceedToSelection();
            },
          ),
        );
        
      case TarotReadingStep.selection:
        return TarotSelectionView(
          key: const ValueKey('selection'),
          requiredCards: _requiredCards,
          selectedDeck: selectedDeck!,
          question: state.question,
          spreadType: state.spreadType,
          onSelectionComplete: (selectedCards) {
            ref.read(tarotReadingStateProvider.notifier).setSelectedCards(selectedCards);
            _performReading(selectedCards);
          },
        );
        
      case TarotReadingStep.result:
        return TarotResultView(
          key: const ValueKey('result'),
          selectedCards: state.selectedCards,
          selectedDeck: selectedDeck!,
          question: state.question,
          spreadType: state.spreadType,
          readingResult: state.readingResult,
          isLoading: state.isLoading,
          onNewReading: () {
            ref.read(tarotReadingStateProvider.notifier).reset();
          },
          onShare: () {
            // Implement share functionality
            Toast.show(
              context,
              message: '공유 기능은 준비 중입니다',
              type: ToastType.info,
            );
          },
        );
    }
  }
}