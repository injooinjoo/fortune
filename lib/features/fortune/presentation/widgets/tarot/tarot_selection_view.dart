import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/widgets/unified_button_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../core/providers/user_settings_provider.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../core/design_system/design_system.dart';
import 'tarot_deck_spread_widget.dart';

/// Simplified tarot card selection view
class TarotSelectionView extends ConsumerStatefulWidget {
  final int requiredCards;
  final TarotDeck selectedDeck;
  final Function(List<int>) onSelectionComplete;
  final String? question;
  final String spreadType;

  const TarotSelectionView({
    super.key,
    required this.requiredCards,
    required this.selectedDeck,
    required this.onSelectionComplete,
    this.question,
    this.spreadType = 'single',
  });

  @override
  ConsumerState<TarotSelectionView> createState() => _TarotSelectionViewState();
}

class _TarotSelectionViewState extends ConsumerState<TarotSelectionView> {
  final List<int> _selectedCards = [];
  bool _isShuffling = false;

  void _handleCardSelection(int index) {
    debugPrint('[TarotSelection] Card selected: $index');
    debugPrint('[TarotSelection] Current selection: $_selectedCards');
    debugPrint('[TarotSelection] Required cards: ${widget.requiredCards}');
    
    if (_selectedCards.contains(index)) {
      // 카드 선택 해제
      setState(() {
        _selectedCards.remove(index);
      });
      debugPrint('[TarotSelection] Card $index deselected');
    } else if (_selectedCards.length < widget.requiredCards) {
      // 새 카드 선택
      setState(() {
        _selectedCards.add(index);
      });
      debugPrint('[TarotSelection] Card $index selected (${_selectedCards.length}/${widget.requiredCards})');
      
      // Check if selection is complete
      if (_selectedCards.length == widget.requiredCards) {
        debugPrint('[TarotSelection] Selection complete! Proceeding...');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            widget.onSelectionComplete(_selectedCards);
          }
        });
      }
    } else {
      // 이미 필요한 수만큼 선택됨
      debugPrint('[TarotSelection] Maximum cards already selected');
    }
  }

  void _shuffleCards() {
    debugPrint('[TarotSelection] Starting shuffle animation');
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
    debugPrint('[TarotSelection] === Build Start ===');
    debugPrint('Fortune cached');
    debugPrint('Fortune cached');
    debugPrint('[TarotSelection] requiredCards: ${widget.requiredCards}');
    
    final theme = Theme.of(context);
    final fontScale = ref.watch(userSettingsProvider).fontScale;

    return Column(
      children: [
        // Header
        _buildHeader(theme, fontScale),
        const SizedBox(height: DSSpacing.lg),
        
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
                    key: const ValueKey('spread'),
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
          style: context.typography.headingLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          '${widget.requiredCards}장의 카드를 선택해주세요',
          style: context.typography.labelLarge.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        if (widget.question != null && widget.question!.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
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
                const SizedBox(width: DSSpacing.sm),
                Flexible(
                  child: Text(
                    widget.question!,
                    style: context.typography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
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
    debugPrint('[TarotSelection] Building shuffle animation widget');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0, end: 4 * math.pi),
            builder: (context, value, child) {
              debugPrint('Fortune cached');
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
          const SizedBox(height: DSSpacing.lg),
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
            child: UnifiedButton(
              text: '카드 섞기',
              onPressed: _isShuffling ? null : _shuffleCards,
              style: UnifiedButtonStyle.ghost,
              size: UnifiedButtonSize.medium,
              icon: const Icon(Icons.shuffle),
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: UnifiedButton(
              text: '다시 선택',
              onPressed: _selectedCards.isEmpty ? null : () {
                setState(() {
                  _selectedCards.clear();
                });
              },
              style: UnifiedButtonStyle.primary,
              size: UnifiedButtonSize.medium,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}