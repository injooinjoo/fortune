import 'dart:math' as math;

import 'package:flutter/material.dart';
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
    print('Fortune cached');
    print('Fortune cached');
    print('cards: ${widget.requiredCards}');
    
    if (_selectedCards.contains(index)) {
      setState(() {
        _selectedCards.remove(index);
      });
    } else if (_selectedCards.length < widget.requiredCards) {
      setState(() {
        _selectedCards.add(index);
      });
      
      // Check if selection is complete
      if (_selectedCards.length == widget.requiredCards) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onSelectionComplete(_selectedCards);
        });
      }
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
            color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                : theme.colorScheme.onSurface.withOpacity(0.2),
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
            child: OutlinedButton.icon(
              onPressed: _isShuffling ? null : _shuffleCards,
              icon: const Icon(Icons.shuffle),
              label: Text(
                '카드 섞기',
                style: TextStyle(fontSize: 16 * fontScale),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: _selectedCards.isEmpty ? null : () {
                setState(() {
                  _selectedCards.clear();
                });
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                '다시 선택',
                style: TextStyle(fontSize: 16 * fontScale),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}