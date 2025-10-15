import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../../shared/components/toss_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../presentation/providers/font_size_provider.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../shared/components/app_header.dart' show FontSize;
import 'tarot_deck_spread_widget.dart';

/// Simplified tarot card selection view
class TarotSelectionView extends ConsumerStatefulWidget {
  final int requiredCards;
  final TarotDeck selectedDeck;
  final Function(List<int>) onSelectionComplete;
  final String? question;
  final String spreadType;

  const TarotSelectionView({
    Key? key,
    required this.requiredCards,
    required this.selectedDeck,
    required this.onSelectionComplete,
    this.question,
    this.spreadType = 'single',
  }) : super(key: key);

  @override
  ConsumerState<TarotSelectionView> createState() => _TarotSelectionViewState();
}

class _TarotSelectionViewState extends ConsumerState<TarotSelectionView> {
  final List<int> _selectedCards = [];
  bool _isShuffling = false;

  void _handleCardSelection(int index) {
    print('[TarotSelection] Card selected: $index');
    print('[TarotSelection] Current selection: $_selectedCards');
    print('[TarotSelection] Required cards: ${widget.requiredCards}');
    
    if (_selectedCards.contains(index)) {
      // 카드 선택 해제
      setState(() {
        _selectedCards.remove(index);
      });
      print('[TarotSelection] Card $index deselected');
    } else if (_selectedCards.length < widget.requiredCards) {
      // 새 카드 선택
      setState(() {
        _selectedCards.add(index);
      });
      print('[TarotSelection] Card $index selected (${_selectedCards.length}/${widget.requiredCards})');
      
      // Check if selection is complete
      if (_selectedCards.length == widget.requiredCards) {
        print('[TarotSelection] Selection complete! Proceeding...');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            widget.onSelectionComplete(_selectedCards);
          }
        });
      }
    } else {
      // 이미 필요한 수만큼 선택됨
      print('[TarotSelection] Maximum cards already selected');
    }
  }

  void _shuffleCards() {
    print('[TarotSelection] Starting shuffle animation');
    setState(() {
      _isShuffling = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isShuffling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[TarotSelection] === Build Start ===');
    print('Fortune cached');
    print('Fortune cached');
    print('[TarotSelection] requiredCards: ${widget.requiredCards}');
    
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    return Column(
      children: [
        // Header
        _buildHeader(theme, fontScale),
        const SizedBox(height: 24),
        
        // Progress indicator
        _buildProgressIndicator(theme),
        const SizedBox(height: 32),
        
        // Card spread
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isShuffling
                ? _buildShufflingAnimation()
                : TarotDeckSpreadWidget(
                    key: ValueKey('spread'),
                    cardCount: 22, // Major Arcana only for simplicity
                    selectedDeck: widget.selectedDeck,
                    onCardSelected: _handleCardSelection,
                    selectedIndices: _selectedCards,
                    spreadType: SpreadType.fan,
                    enableSelection: true, // 카드 선택 활성화
                  ),
          ),
        ),
        
        // Action buttons
        _buildActionButtons(theme, fontScale),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, double fontScale) {
    return Column(
      children: [
        Text(
          '카드를 선택하세요',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24 * fontScale,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.requiredCards}장의 카드를 선택해주세요',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 16 * fontScale,
          ),
        ),
        if (widget.question != null && widget.question!.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.question!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 14 * fontScale,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.requiredCards, (index) {
        final isSelected = index < _selectedCards.length;
        return Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildShufflingAnimation() {
    print('[TarotSelection] Building shuffle animation widget');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0, end: 4 * math.pi),
            builder: (context, value, child) {
              print('Fortune cached');
              return Transform.rotate(
                angle: value,
                child: Icon(
                  Icons.shuffle,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            '카드를 섞는 중...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, double fontScale) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TossButton(
              text: '카드 섞기',
              onPressed: _isShuffling ? null : _shuffleCards,
              style: TossButtonStyle.ghost,
              size: TossButtonSize.medium,
              icon: Icon(Icons.shuffle),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TossButton(
              text: '다시 선택',
              onPressed: _selectedCards.isEmpty ? null : () {
                setState(() {
                  _selectedCards.clear();
                });
              },
              style: TossButtonStyle.primary,
              size: TossButtonSize.medium,
              icon: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}