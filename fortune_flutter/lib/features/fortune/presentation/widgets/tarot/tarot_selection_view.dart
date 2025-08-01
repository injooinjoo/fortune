import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/tarot_deck_metadata.dart';
import '../../../../../presentation/providers/font_size_provider.dart';
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../shared/components/app_header.dart' show FontSize;
import 'tarot_deck_spread_widget.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

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
    print('[TarotSelection] Card selection - index: $index');
    print('[TarotSelection] Current selected cards: $_selectedCards');
    print('[TarotSelection] Required cards: ${widget.requiredCards}');
    
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
        Future.delayed(AppAnimations.durationLong, () {
          widget.onSelectionComplete(_selectedCards);
});
}
    },
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
    print('[TarotSelection] isShuffling: $_isShuffling');
    print('[TarotSelection] selectedCards: $_selectedCards');
    print('[TarotSelection] requiredCards: ${widget.requiredCards}');
    
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;

    return Column(
      children: [
        // Header
        _buildHeader(theme, fontScale),
        const SizedBox(height: AppSpacing.spacing6),
        
        // Progress indicator
        _buildProgressIndicator(theme),
        const SizedBox(height: AppSpacing.spacing8),
        
        // Card spread
        Expanded(
          child: AnimatedSwitcher(
            duration: AppAnimations.durationLong,
            child: _isShuffling
                ? _buildShufflingAnimation(,
                : TarotDeckSpreadWidget(
                    key: ValueKey('spread'),
                    cardCount: 22, // Major Arcana only for simplicity
                    selectedDeck: widget.selectedDeck,
                    onCardSelected: _handleCardSelection,
                    selectedIndices: _selectedCards,
                    spreadType: SpreadType.fan,
                  ),
        ),
        
        // Action buttons
        _buildActionButtons(theme, fontScale),
      ]
    );
}

  Widget _buildHeader(ThemeData theme, double fontScale) {
    return Column(
      children: [
        Text(
          '카드를 선택하세요',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale,
          ),
        const SizedBox(height: AppSpacing.spacing2),
        Text(
          '${widget.requiredCards}장의 카드를 선택해주세요',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale,
          ),
        if (widget.question != null && widget.question!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spacing4),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.spacing2),
                Flexible(
                  child: Text(
                    widget.question!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize * fontScale,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
        ],
      ]
    );
}

  Widget _buildProgressIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.requiredCards, (index) {
        final isSelected = index < _selectedCards.length;
        return Container(
          width: 40,
          height: AppSpacing.spacing1,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing1),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSpacing.spacing0 * 0.5),
        );
},
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
              print('[TarotSelection] Shuffle animation value: $value');
              return Transform.rotate(
                angle: value,
                child: Icon(
                  Icons.shuffle,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ));
},
          ),
          const SizedBox(height: AppSpacing.spacing6),
          Text(
            '카드를 섞는 중...',
            style: Theme.of(context).textTheme.titleLarge,
        ],
      
    );
}

  Widget _buildActionButtons(ThemeData theme, double fontScale) {
    return Padding(
      padding: AppSpacing.paddingAll16,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isShuffling ? null : _shuffleCards,
              icon: const Icon(Icons.shuffle),
              label: Text(
                '카드 섞기',
                style: Theme.of(context).textTheme.bodyMedium,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing3),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusMedium,
                ),
            ),
          const SizedBox(width: AppSpacing.spacing4),
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
                style: Theme.of(context).textTheme.bodyMedium,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing3),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusMedium,
                ),
            ),
        ],
      
    );
}
}

